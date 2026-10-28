'use strict';

// Node-only synthetic regression for the two v0.2.13 runtime repairs.
// No whole WSH entry point, native commands, Lean, Lake, or C# is executed.
const fs = require('fs');
const path = require('path');
const assert = require('assert');
const {makeHost, sha256} = require('./runtime_host');
const source = require('./candidate_sources');
const observed = require('./reported_case_fixture');

const args = {};
for (let i = 2; i < process.argv.length; i += 2) {
  assert(['--package-root', '--report'].includes(process.argv[i]), 'unknown argument');
  assert(process.argv[i + 1], 'missing argument');
  args[process.argv[i].slice(2)] = path.resolve(process.argv[i + 1]);
}
assert(args['package-root'] && args.report, 'Use --package-root DIRECTORY --report FILE');
const paths = {runner: path.join(args['package-root'], 'tools', 'native_runner.js')};
const runnerBytes = fs.readFileSync(paths.runner), runnerSHA = sha256(runnerBytes);
const setterCount = [...runnerBytes.toString('utf8').matchAll(/env\("([A-Z_]+)"\)\s*=(?!=)/g)].length;
assert.strictEqual(setterCount, 7, 'unexpected WSH COM setter adaptation count');
const results = [];
const oneModule = {'Review.Single': []};
const launches = h => h.events.filter(e => e.kind === 'process_launch');
const lean = h => launches(h).filter(e => e.process_kind === 'lean');
function fixture(options = {}, graph) { return makeHost(paths, options).installFixture(graph).startup(); }
function test(name, action) {
  try { results.push({name, outcome: 'PASS', evidence: action() || {}}); }
  catch (e) { results.push({name, outcome: 'FAIL', error: e.message, stack: e.stack}); }
}
function reportedOptions(extra = {}) {
  return Object.assign({memoryState: {totalMB: observed.syntheticOneConsistentPolicy.totalMB, freeMB: observed.freeMB},
    env: {RH_RAM_WARM: 'AUTO'}}, extra);
}

test('reported_5479_idle_frontier_degrades_to_serial_16_threads', () => {
  const h = fixture(reportedOptions()); h.run(); h.context.finalAudit();
  const c = h.context, p = c.parallelRuntime;
  assert.strictEqual(p.preferredReserveMB, 6380);
  assert.strictEqual(p.preferredReserveMB + p.workerMemoryMB, observed.requiredMB);
  assert.strictEqual(p.minimumReserveMB, 1024); assert.strictEqual(p.reserveMB, 1024);
  assert.strictEqual(p.workerMemoryMB, 4096); assert.strictEqual(p.ramCapMB, 0);
  assert.strictEqual(p.memoryFallback, true); assert.strictEqual(p.ramDisabledForMemory, true);
  assert.strictEqual(p.workers, 1);
  assert(lean(h).every(e => e.threads === 16 && e.live_lean_count === 1));
  assert.strictEqual(launches(h).filter(e => e.process_kind === 'ram_warm').length, 0);
  assert.strictEqual(c.failed, 0); assert(c.moduleKeys.Audit);
  assert.strictEqual(p.shutdownComplete, false, 'mid-run memory recovery must not run global shutdown');
  c.result(false, 'SIMULATED runtime path only; no native proof claim');
  const report = JSON.parse(h.memory.text(c.root + '\\run-result.json'));
  assert.strictEqual(report.memory_serial_fallback, true);
  assert.strictEqual(report.memory_effective_reserve_mib, 1024);
  assert.strictEqual(report.finite_checker_equivalence, 'OPEN');
  return {free_mib: 5479, previous_required_mib: 10476, effective_required_mib: 5120,
    workers: 1, threads_per_compile_or_audit: 16, warmer_cap_mib: 0, simulated_modules_accepted: c.compiled};
});

test('serial_minimum_boundary_denies_5119_and_allows_5120', () => {
  const outcomes = [];
  for (const free of [5119, 5120]) {
    const h = fixture(reportedOptions({memoryState: {totalMB: 31900, freeMB: free}}), oneModule);
    if (free === 5119) {
      assert.throws(() => h.run(), /FREE_MB=5119\|REQUIRED_MB=5120\|LIVE_WORKERS=0\|POLICY=SERIAL_MINIMUM/);
      assert.strictEqual(h.context.stage, 'RESOURCE_ADMISSION');
      assert.strictEqual(launches(h).length, 0); assert.strictEqual(h.sleeps.length, 0);
      outcomes.push({free_mib: free, admitted: false});
    } else {
      h.run(); assert.strictEqual(h.context.compiled, 1);
      assert.strictEqual(h.context.parallelRuntime.memoryFallback, true);
      outcomes.push({free_mib: free, admitted: true});
    }
  }
  return {boundary_results: outcomes};
});

test('explicit_system_reserve_and_worker_allowance_are_not_lowered', () => {
  const scenarios = [
    {env: {RH_SYSTEM_RESERVE_MB: '4096', RH_RAM_WARM: 'AUTO'}, minimum: 4096, worker: 4096, required: 8192},
    {env: {RH_WORKER_MEMORY_MB: '8192', RH_RAM_WARM: 'AUTO'}, minimum: 1024, worker: 8192, required: 9216},
  ];
  for (const s of scenarios) {
    const h = fixture(reportedOptions({env: s.env}), oneModule);
    assert.throws(() => h.run(), new RegExp('REQUIRED_MB=' + s.required));
    assert.strictEqual(h.context.parallelRuntime.minimumReserveMB, s.minimum);
    assert.strictEqual(h.context.parallelRuntime.workerMemoryMB, s.worker);
    assert.strictEqual(h.context.parallelRuntime.memoryFallback, false);
    assert.strictEqual(launches(h).length, 0);
  }
  return {explicit_reserve_required_mib: 8192, explicit_worker_required_mib: 9216, unauthorized_lowering: false};
});

test('known_pressure_then_unknown_fresh_WMI_never_becomes_unknown_serial_bypass', () => {
  const h = fixture(reportedOptions({memoryState: host => host.memoryQueries === 1
    ? {totalMB: 31900, freeMB: 5479} : null}), oneModule);
  assert.throws(() => h.run(), /MEMORY_REFRESH_UNKNOWN_AFTER_PRESSURE/);
  assert.strictEqual(launches(h).length, 0);
  assert.strictEqual(h.context.parallelRuntime.memoryPressureSeen, true);
  assert.strictEqual(h.context.parallelMemoryAllowsLaunch(), false);
  assert.strictEqual(h.context.parallelRuntime.memoryDenial, 'MEMORY_UNKNOWN_AFTER_KNOWN_PRESSURE');
  return {fresh_memory_unavailable: true, native_launches: 0, pressure_state_preserved: true};
});

test('live_worker_forbids_serial_policy_change_and_additional_admission', () => {
  const h = fixture({memoryState: {totalMB: 31900, freeMB: 30000}}), c = h.context;
  c.configureParallelRuntime(); const workers = c.parallelRuntime.workers, reserve = c.parallelRuntime.reserveMB;
  c.parallelRuntime.active = [{name: 'Review.Base', phase: 'COMPILE', threads: 4, proc: {Status: 0, ProcessID: 7001}}];
  h.memoryState = {totalMB: 31900, freeMB: 5479}; h.clock += 2100;
  assert.strictEqual(c.parallelMemoryAllowsLaunch(), false);
  const queries = h.memoryQueries;
  assert.strictEqual(c.parallelTrySerialFallback(), false);
  assert.strictEqual(h.memoryQueries, queries);
  assert.strictEqual(c.parallelRuntime.workers, workers); assert.strictEqual(c.parallelRuntime.reserveMB, reserve);
  assert.strictEqual(c.parallelRuntime.memoryFallback, false);
  assert.strictEqual(launches(h).length, 0);
  return {live_workers: 1, extra_worker_admitted: false, serial_policy_changed: false};
});

function attachWarmer(h, mode, freeAfter) {
  const c = h.context;
  h.installLock(); c.configureParallelRuntime(); c.parallelRuntime.ramCapMB = 2048;
  const ram = {token: 'mock-warmer-token', requestSHA: 'a'.repeat(64), requestCount: 1, budgetBytes: 2048 * 1048576,
    status: c.helpers + '\\warmer.status', stop: c.helpers + '\\warmer.stop', proc: null};
  const initial = h.clock + 2100; let observedExit = false;
  const proc = {ProcessID: 7002, ExitCode: 0};
  Object.defineProperty(proc, 'Status', {get() {
    if (mode === 'unknown') throw new Error('SIMULATED unknown warmer state');
    if (mode === 'exit' && h.memory.exists(ram.stop) && h.clock - initial >= 300) { observedExit = true; return 1; }
    return 0;
  }});
  ram.proc = proc; c.parallelRuntime.ram = ram;
  h.memoryState = () => ({totalMB: 31900, freeMB: observedExit ? freeAfter : 4000});
  h.clock += 2100;
  return {ram, initial: h.clock, exited: () => observedExit};
}

test('warmer_exit_requires_fresh_memory_measurement_without_crediting_mapped_bytes', () => {
  const outcomes = [];
  for (const freeAfter of [5479, 5119]) {
    const h = fixture({memoryState: {totalMB: 31900, freeMB: 30000}}), c = h.context;
    const {ram, exited} = attachWarmer(h, 'exit', freeAfter);
    const allowed = c.parallelMemoryAllowsLaunch();
    assert(exited()); assert(h.memory.exists(ram.stop));
    assert.strictEqual(h.memory.text(ram.stop), ram.token + '\n');
    assert.strictEqual(allowed, freeAfter >= 5120);
    assert.strictEqual(c.parallelRuntime.shutdownComplete, false);
    assert.strictEqual(c.parallelRuntime.shutdownKeepLock, false); assert(c.lockHeld);
    assert.strictEqual(c.parallelRuntime.memory.freeMB, freeAfter);
    if (allowed) { assert.strictEqual(c.parallelRuntime.ramCapMB, 0); assert.strictEqual(c.parallelRuntime.workers, 1); }
    else assert.strictEqual(c.parallelRuntime.memoryFallback, false);
    outcomes.push({fresh_free_mib: freeAfter, admitted: allowed, warmer_exit_confirmed: true, global_shutdown_called: false});
  }
  return {outcomes};
});

test('warmer_timeout_or_unknown_status_preserves_lock_and_blocks_fallback', () => {
  const outcomes = [];
  for (const mode of ['timeout', 'unknown']) {
    const h = fixture({memoryState: {totalMB: 31900, freeMB: 30000}}), c = h.context;
    const {ram, initial} = attachWarmer(h, mode, 5479);
    assert.strictEqual(c.parallelMemoryAllowsLaunch(), false);
    assert.strictEqual(c.parallelRuntime.memoryFallback, false);
    assert.strictEqual(c.parallelRuntime.ram, ram); assert(c.lockHeld);
    assert.strictEqual(c.parallelRuntime.shutdownComplete, false);
    assert(c.parallelRuntime.memoryDenial.includes(mode === 'timeout' ? 'RAM_WARM_RELEASE_UNCONFIRMED' : 'RAM_WARM_RELEASE_UNCERTAIN'));
    assert.strictEqual(h.clock - initial, mode === 'timeout' ? 5000 : 0);
    assert.strictEqual(launches(h).length, 0);
    outcomes.push({warmer_state: mode, fake_wait_ms: h.clock - initial, lock_retained: true, native_launches: 0});
  }
  return {outcomes};
});

test('dirty_final_audit_obeys_memory_and_active_worker_barriers', () => {
  const h = fixture({}, oneModule); h.run(); const c = h.context;
  h.memoryState = {totalMB: 31900, freeMB: 5119}; h.clock += 2100;
  const before = c.directLaunchCounts.lean;
  assert.throws(() => c.finalAudit(), /PARALLEL_RESOURCE_BLOCKED/);
  assert.strictEqual(c.stage, 'RESOURCE_ADMISSION:FINAL_AUDIT');
  assert.strictEqual(c.directLaunchCounts.lean, before); assert.strictEqual(c.moduleKeys.Audit, undefined);
  const active = fixture({}, oneModule); active.run();
  active.context.parallelRuntime.active = [{name: 'Review.Single', threads: 4, proc: {Status: 0}}];
  const beforeActive = active.context.directLaunchCounts.lean;
  assert.throws(() => active.context.finalAudit(), /FINAL_AUDIT_BARRIER_BROKEN/);
  assert.strictEqual(active.context.directLaunchCounts.lean, beforeActive);
  return {low_memory_dirty_final_blocked: true, ordinary_live_worker_dirty_final_blocked: true};
});

test('verified_cached_final_audit_skips_new_memory_admission', () => {
  const seed = fixture({}, oneModule); seed.run(); seed.context.finalAudit();
  const h = makeHost(paths, {memory: seed.memory, memoryState: {totalMB: 31900, freeMB: 1}}).startup();
  const c = h.context; h.run();
  const before = {queries: h.memoryQueries, lean: c.directLaunchCounts.lean};
  c.finalAudit();
  assert(c.moduleKeys.Audit); assert.strictEqual(c.compiled, 0);
  assert.strictEqual(c.directLaunchCounts.lean, before.lean); assert.strictEqual(h.memoryQueries, before.queries);
  assert.strictEqual(c.parallelRuntime.memoryPressureSeen, false);
  assert.strictEqual(c.parallelRuntime.memoryFallback, false);
  return {verified_reuse: true, added_compiler_calls: 0, added_memory_probes: 0, fallback_needed: false};
});

function relativeRecord(changes = {}) {
  return Object.assign({ProcessId: 8888, ParentProcessId: 55, CreationDate: '20261027095000.001234+000',
    Name: 'cscript.exe', CommandLine: '"C:\\Windows\\System32\\cscript.exe" //nologo tools\\native_runner.js'}, changes);
}
function acquireWithRelative(record = relativeRecord()) {
  const h = fixture(); h.extraInventory = [record]; h.context.acquireRunnerLock(); return h;
}

test('actual_fresh_acquisition_captures_exact_admitted_host_for_same_owner_shutdown', () => {
  const h = acquireWithRelative(), c = h.context;
  assert.strictEqual(c.lockHeld, true);
  assert.strictEqual(c.lockAdmittedRelativeHosts.length, 1);
  assert.strictEqual(c.lockAdmittedRelativeHosts[0].pid, 8888);
  assert.strictEqual(c.lockAdmittedRelativeHosts[0].created, '20261027095000.001234+000');
  assert.strictEqual(c.lockAdmittedRelativeHosts[0].command, h.extraInventory[0].CommandLine);
  assert.strictEqual(c.lockAdmittedRelativeOwner, c.lockOwnerText);
  assert.strictEqual(h.shutdownAndConditionalRelease(), true);
  assert.strictEqual(c.lockHeld, false); assert(!h.memory.directory(c.lockPath));
  assert(h.messages.some(x => x.includes('SHUTDOWN_PREEXISTING_ADMITTED_UNRESOLVED_HOST=PID:8888')));
  return {captured_count: 1, full_identity_bound: true, same_owner_shutdown_clean: true,
    workspace_classification: 'UNRESOLVED; no assertion of another workspace'};
});

test('capture_requires_actual_relative_script_and_preexisting_nonchild_identity', () => {
  const mutants = [
    ['later_argument_only', {CommandLine: '"C:\\Windows\\System32\\cscript.exe" tools\\other.js tools\\native_runner.js'}],
    ['created_after_owner', {CreationDate: '20261027100000.000000+000'}],
    ['direct_child_of_owner', {ParentProcessId: 1000}],
  ];
  for (const [name, change] of mutants) {
    const h = acquireWithRelative(relativeRecord(change));
    assert.strictEqual(h.context.lockAdmittedRelativeHosts.length, 0, name);
  }
  const bound = fixture(); bound.extraInventory = [relativeRecord({CommandLine:
    '"C:\\Windows\\System32\\cscript.exe" tools\\native_runner.js "' + bound.context.root + '\\input.txt"'})];
  assert.throws(() => bound.context.acquireRunnerLock(), /RUNNER_ACTIVE/);
  assert.strictEqual(bound.context.lockHeld, false);
  return {nonadmitted_variants: mutants.map(x => x[0]), root_bound_host_rejected_at_acquisition: true};
});

test('new_changed_unreadable_root_bound_and_owned_child_hosts_remain_guarded', () => {
  const variants = [
    ['new_pid', h => { h.extraInventory[0].ProcessId = 8889; }],
    ['same_pid_new_creation_microsecond', h => { h.extraInventory[0].CreationDate = '20261027095000.001235+000'; }],
    ['changed_exact_command', h => { h.extraInventory[0].CommandLine += ' --changed'; }],
    ['unreadable_command', h => { h.extraInventory[0].CommandLine = ''; }],
    ['absolute_current_root_binding', h => { h.extraInventory[0].CommandLine += ' "' + h.context.root + '\\input.txt"'; }],
    ['new_owned_relative_child', h => { h.extraInventory.push(relativeRecord({ProcessId: 8889, ParentProcessId: 1000, CreationDate: '20261027100000.000000+000'})); }],
    ['absolute_orphan_lean_for_current_root', h => { h.extraInventory.push({ProcessId: 8890, ParentProcessId: 55,
      CreationDate: '20261027100000.000000+000', Name: 'lean.exe', CommandLine: 'lean.exe "' + h.context.root + '\\Review\\Base.lean"'}); }],
  ];
  for (const [name, change] of variants) {
    const h = acquireWithRelative(); change(h);
    assert.strictEqual(h.shutdownAndConditionalRelease(), false, name);
    assert(h.context.lockHeld, name); assert(h.memory.directory(h.context.lockPath), name);
  }
  return {retained_lock_variants: variants.map(x => x[0])};
});

test('admitted_host_exception_does_not_transfer_to_a_different_owner', () => {
  const h = acquireWithRelative(), c = h.context;
  const old = c.lockOwnerText;
  c.lockOwnerText = old.replace('TOKEN=mock-owner-token-123456', 'TOKEN=mock-new-owner-654321');
  assert.notStrictEqual(c.lockOwnerText, old);
  const process = c.queryLockProcesses().find(p => p.pid === 8888);
  assert.strictEqual(c.parallelIsFreshAdmittedRelativeHost(process), false);
  assert.strictEqual(c.parallelShutdown(), false); assert(c.lockHeld);
  assert.strictEqual(h.memory.text(c.lockPath + '\\owner.txt'), old);
  return {changed_owner_exception: false, old_owner_record_preserved: true};
});

test('stale_lock_recovery_does_not_use_fresh_admission_exception', () => {
  const h = fixture(), c = h.context;
  const stale = c.formatLockOwner({ROOT: c.keyPath(c.root), SCRIPT: c.keyPath(c.root + '\\tools\\native_runner.js'),
    PID: '4321', CREATED: '20261027090000.000000+000', TOKEN: 'mock-stale-owner-12345', RUN_TAG: c.runTag});
  h.memory.put(c.lockPath + '\\owner.txt', stale);
  h.extraInventory = [relativeRecord()];
  assert.throws(() => c.acquireRunnerLock(), /legacy relative-path native_runner\.js/);
  assert.strictEqual(h.memory.text(c.lockPath + '\\owner.txt'), stale);
  assert.strictEqual(c.lockHeld, false); assert.strictEqual(c.lockAdmittedRelativeHosts.length, 0);
  assert.strictEqual(c.lockAdmittedRelativeOwner, '');
  assert.strictEqual(c.lockRecovered, 0);
  return {old_lock_preserved: true, stale_recovery_exception: false, lock_recovered: 0};
});

test('admitted_unresolved_host_does_not_hide_live_or_unknown_owned_process', () => {
  const outcomes = [];
  for (const kind of ['live', 'unknown']) {
    const h = acquireWithRelative(), c = h.context;
    const proc = {ProcessID: 7003};
    Object.defineProperty(proc, 'Status', {get() {
      if (kind === 'unknown') throw new Error('SIMULATED unknown owned process');
      return 0;
    }});
    c.parallelRuntime.active = [{name: 'Review.Base', phase: 'COMPILE', threads: 16, proc}];
    const before = h.clock;
    assert.strictEqual(h.shutdownAndConditionalRelease(), false);
    assert(c.lockHeld); assert.strictEqual(h.clock - before, 30000);
    assert.strictEqual(c.parallelRuntime.shutdownClean, false);
    outcomes.push({owned_process_state: kind, lock_retained: true, fake_drain_ms: 30000});
  }
  return {outcomes};
});

assert.strictEqual(sha256(fs.readFileSync(paths.runner)), runnerSHA, 'runner changed during review');
const report = {
  schema: 'RH_V0213_FOCUSED_NODE_VM_REVIEW_V1', status: results.every(x => x.outcome === 'PASS') ? 'PASS' : 'FAIL',
  scope: 'NODE_VM_SYNTHETIC_HOST_ONLY', runner_sha256: runnerSHA,
  memory_fallback_sha256: sha256(source.memory), admitted_relative_hosts_sha256: sha256(source.admitted),
  native_tail_sha256: observed.nativeTailSha256,
  passed: results.filter(x => x.outcome === 'PASS').length, failed: results.filter(x => x.outcome === 'FAIL').length,
  cases: results,
  host: {basis: 'Reused v0.2.12 in-memory host support; old22 cases were not rerun.',
    assembled_COM_setter_adaptations: setterCount, new_snippet_COM_setters: 0,
    entry_point_executed: false, exact_new_snippets_bound: true,
    fixture_warning: 'The native tail reports free5479/required10476. Synthetic total31900/reserve6380 is one consistent realization, not a native hardware observation.'},
  limitations: [
    'No native Windows, WSH/COM, WMI, process-tree, C#, Lean/Lake, CI, memory mapping, or performance execution.',
    'Compiler outputs, receipts, process identities, RAM readings, and time are simulated in memory.',
    'Actual runner functions are used for admission, scheduling, cache acceptance, acquisition, inventory guards and shutdown; WSH host boundaries are substituted.',
    'The fresh-admission exception records an unresolved previously admitted host; these tests do not establish a different workspace or a general ancestry proof.',
    'The native user run remains FAIL. These tests do not certify the mathematical endpoint or finite checker equivalence.',
  ],
  runner_sources_unmodified: true,
};
fs.mkdirSync(path.dirname(args.report), {recursive: true});
fs.writeFileSync(args.report, JSON.stringify(report, null, 2) + '\n');
console.log(JSON.stringify({runner_sha256: runnerSHA, status: report.status, passed: report.passed, failed: report.failed,
  failures: results.filter(x => x.outcome === 'FAIL').map(x => ({name: x.name, error: x.error})), report: args.report}, null, 2));
process.exitCode = report.failed ? 1 : 0;
