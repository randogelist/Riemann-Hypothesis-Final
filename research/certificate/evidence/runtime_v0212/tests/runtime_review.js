'use strict';

// Portable source-level regression suite. Native responses and time are simulated.
// Usage: node runtime_review.js --package-root DIRECTORY --report FILE
// Optional explicit inputs: --runner FILE --parallel FILE --ram FILE --report FILE
const fs = require('fs');
const path = require('path');
const assert = require('assert');
const {makeHost, sha256} = require('./runtime_host');
const frozenSources = require('./draft_sources');

const flags = {};
for (let i = 2; i < process.argv.length; i += 2) {
  assert(/^--(?:package-root|runner|parallel|ram|report)$/.test(process.argv[i]), 'unknown argument');
  assert(process.argv[i + 1], 'missing argument value');
  flags[process.argv[i].slice(2)] = path.resolve(process.argv[i + 1]);
}
if (flags['package-root']) {
  assert(!flags.runner, 'choose --package-root or --runner');
  flags.runner = path.join(flags['package-root'], 'tools', 'native_runner.js');
}
for (const key of ['runner', 'report']) assert(flags[key], 'missing --' + key);
const inputBytes = key => flags[key] ? fs.readFileSync(flags[key]) : Buffer.from(frozenSources[key], 'utf8');
const initialHashes = Object.fromEntries(['runner', 'parallel', 'ram'].map(k => [k, sha256(inputBytes(k))]));
const runnerComSetters = [...inputBytes('runner').toString('utf8').matchAll(/env\("([A-Z_]+)"\)\s*=(?!=)/g)].length;
assert.strictEqual(runnerComSetters, 7, 'assembled COM setter count changed');
const results = [];
function test(name, body) {
  try { const evidence = body() || {}; results.push({name, outcome: 'PASS', evidence}); }
  catch (error) { results.push({name, outcome: 'FAIL', error: error.message, stack: error.stack}); }
}
const launched = host => host.events.filter(e => e.kind === 'process_launch');
const leanLaunches = host => launched(host).filter(e => e.process_kind === 'lean');
const states = host => JSON.parse(JSON.stringify(host.context.parallelRuntime.states));
const graph = {
  'Review.A': [], 'Review.B': [], 'Review.Join': ['Review.A', 'Review.B'],
  'Review.Descendant': ['Review.Join'], 'Review.Independent': [],
};

function fixture(options = {}, selectedGraph) {
  return makeHost(flags, options).installFixture(selectedGraph).startup();
}

test('dag_requires_all_audits_and_verified_keys_before_dependency_release', () => {
  const h = fixture({durations: {'Review.A': {COMPILE: 100, AUDIT: 700}, 'Review.B': {COMPILE: 200, AUDIT: 300}}}, graph);
  const barrierSnapshots = [];
  h.onSleep = () => {
    const c = h.context;
    if (c.parallelRuntime.tasks['Review.A'] && c.parallelRuntime.tasks['Review.A'].phase === 'AUDIT')
      barrierSnapshots.push({join: c.parallelRuntime.states['Review.Join'], aKey: !!c.moduleKeys['Review.A']});
  };
  h.run();
  assert(barrierSnapshots.some(x => x.join === 'PENDING' && !x.aKey));
  const events = h.events, acceptIndex = name => events.findIndex(e => e.kind === 'accepted' && e.module === name);
  const joinIndex = events.findIndex(e => e.kind === 'process_launch' && e.module === 'Review.Join');
  assert(joinIndex > acceptIndex('Review.A') && joinIndex > acceptIndex('Review.B'));
  for (const launch of leanLaunches(h)) for (const dep of launch.dependency_states) {
    assert.strictEqual(dep.state, 'DONE'); assert(dep.key); assert(dep.artifact);
  }
  assert(Object.values(states(h)).every(x => x === 'DONE'));
  return {compiled: h.context.compiled, async_lean_calls: leanLaunches(h).length, observed_pending_during_parent_audit: true};
});

test('fully_cached_graph_and_aggregate_launch_no_compile_audit_or_ram_process', () => {
  const seed = fixture(); seed.seedAnchors(); seed.context.finalAudit();
  const h = makeHost(flags, {memory: seed.memory, env: {RH_RAM_WARM: 'ON'}}).startup();
  const before = {...h.context.directLaunchCounts};
  h.run(); h.context.finalAudit();
  assert.strictEqual(launched(h).length, 0);
  assert.strictEqual(h.context.directLaunchCounts.lean, before.lean);
  assert.strictEqual(h.context.directLaunchCounts.ram_warm, before.ram_warm);
  assert.strictEqual(h.context.parallelRuntime.ramAttempted, false);
  assert.strictEqual(h.context.compiled, 0);
  assert.strictEqual(h.context.reused, 4);
  return {ordinary_reused: 3, aggregate_reused: 1, scheduler_native_launches: 0,
    limitation: 'Startup version/prefix queries are excluded from this scheduler assertion.'};
});

test('audit_only_cache_refresh_holds_descendants_until_new_target_acceptance', () => {
  const seed = makeHost(flags).installFixture();
  const src = seed.context.root + '\\Review\\Base.lean';
  seed.memory.put(src, seed.memory.text(src) + 'theorem Review.Base.extra : True := True.intro\n');
  seed.startup().seedAnchors();
  const targets = seed.context.root + '\\audit-targets.tsv';
  seed.memory.put(targets, seed.memory.text(targets) + 'Review.Base|Review.Base.extra\n');
  const h = makeHost(flags, {memory: seed.memory}).startup();
  let sawBarrier = false;
  h.onSleep = () => {
    if (h.context.parallelRuntime.states['Review.Base'] === 'RUNNING') {
      assert.strictEqual(h.context.parallelRuntime.states['Review.Leaf'], 'PENDING');
      assert.strictEqual(h.context.moduleKeys['Review.Base'], undefined); sawBarrier = true;
    }
  };
  h.run();
  assert(sawBarrier);
  assert.deepStrictEqual(leanLaunches(h).map(x => [x.module, x.phase]), [['Review.Base', 'AUDIT']]);
  assert.strictEqual(h.context.auditOnly, 1); assert.strictEqual(h.context.compiled, 0);
  assert.strictEqual(h.context.parallelRuntime.states['Review.Leaf'], 'DONE');
  return {audit_only_calls: 1, new_compiles: 0, descendant_wait_observed: true};
});

for (const spec of [
  {name: 'compile_exit_failure_blocks_descendants_but_independent_finishes', failure: {compile: true}, state: 'COMPILE_FAILED'},
  {name: 'audit_exit_failure_blocks_descendants_but_independent_finishes', failure: {auditExit: true}, state: 'AUDIT_COMPILE_FAILED'},
  {name: 'missing_exact_axiom_target_blocks_descendants_but_independent_finishes', failure: {dropTarget: true}, state: 'AUDIT_FAILED'},
  {name: 'unapproved_axiom_blocks_descendants_but_independent_finishes', failure: {badAxiom: 'SIMULATED_BAD_AXIOM'}, state: 'AUDIT_FAILED'},
]) test(spec.name, () => {
  const h = fixture({failures: {'Review.Base': spec.failure}}); h.run();
  assert.strictEqual(h.context.buildStates['Review.Base'], spec.state);
  assert.strictEqual(h.context.parallelRuntime.states['Review.Leaf'], 'BLOCKED');
  assert.strictEqual(h.context.parallelRuntime.states['Review.Independent'], 'DONE');
  assert(!leanLaunches(h).some(x => x.module === 'Review.Leaf'));
  assert.strictEqual(h.context.moduleKeys['Review.Base'], undefined);
  assert.strictEqual(h.context.artifactHashes['Review.Base'], undefined);
  assert.strictEqual(h.context.failed, 1); assert.strictEqual(h.context.blocked, 1);
  return {failed: 1, blocked: 1, independent_accepted: true};
});

test('live_thread_sum_including_coordinator_reserve_stays_within_budget', () => {
  const g = Object.fromEntries(Array.from({length: 7}, (_, i) => ['Review.Root' + i, []]));
  const summaries = [];
  for (const budget of [1, 2, 4, 16]) {
    const h = fixture({durations: {'Review.Root0': {COMPILE: 700, AUDIT: 400}, 'Review.Root1': {COMPILE: 100, AUDIT: 200}}}, g);
    h.context.jobs = budget;
    h.run();
    for (const e of leanLaunches(h)) {
      assert(e.live_lean_threads + e.coordinator_reserve <= budget, JSON.stringify(e));
      assert(e.live_lean_count <= h.context.parallelRuntime.workers);
    }
    for (const e of h.events.filter(x => x.kind === 'hash_launch')) assert(e.live_lean_threads + 1 <= budget);
    assert.strictEqual(h.values.LEAN_NUM_THREADS, '16', 'coordinator environment not restored');
    summaries.push({budget, worker_cap: h.context.parallelRuntime.workers,
      peak_live_workers: Math.max(...leanLaunches(h).map(x => x.live_lean_count)),
      peak_threads_plus_reserve: Math.max(...leanLaunches(h).map(x => x.live_lean_threads + x.coordinator_reserve))});
  }
  return {budgets: summaries};
});

test('unknown_memory_falls_back_to_serial_with_ram_warming_disabled', () => {
  const h = fixture({memoryState: null, env: {RH_RAM_WARM: 'ON'}}); h.run();
  assert.strictEqual(h.context.parallelRuntime.workers, 1);
  assert.strictEqual(h.context.parallelRuntime.ramCapMB, 0);
  assert.strictEqual(h.context.parallelRuntime.ramAttempted, false);
  assert(leanLaunches(h).every(x => x.live_lean_count === 1));
  assert(h.messages.some(x => x.includes('UNKNOWN_SERIAL_FALLBACK')));
  return {worker_cap: 1, peak_live_workers: 1, ram_budget_mb: 0};
});

test('known_low_memory_fails_boundedly_without_first_worker_bypass', () => {
  const h = fixture({memoryState: {totalMB: 8192, freeMB: 3000}, env: {RH_RAM_WARM: 'ON'}});
  assert.throws(() => h.run(), /PARALLEL_RESOURCE_BLOCKED/);
  assert.strictEqual(launched(h).length, 0);
  assert.strictEqual(h.sleeps.length, 0);
  assert.strictEqual(h.context.compiled, 0);
  return {native_launches: 0, fake_wait_ms: 0, error_kind: 'PARALLEL_RESOURCE_BLOCKED'};
});

test('live_sidecar_budget_and_worker_reservations_gate_further_admission', () => {
  const h = fixture({memoryState: {totalMB: 16384, freeMB: 14336}, env: {RH_RAM_WARM: 'ON', RH_RAM_WARM_MB: '2048'}});
  const c = h.context; c.configureParallelRuntime();
  c.parallelRuntime.active = [{threads: 4, proc: {Status: 0}}];
  c.parallelRuntime.ram = {proc: {Status: 0}};
  assert.strictEqual(c.parallelMemoryAllowsLaunch(), true);
  c.parallelRuntime.active.push({threads: 4, proc: {Status: 0}});
  assert.strictEqual(c.parallelMemoryAllowsLaunch(), false);
  assert(c.parallelRuntime.memoryDenial.includes('LIVE_WORKERS=2'));
  // The same two-worker state becomes admissible with a larger fresh reading.
  h.clock += 2100; h.memoryState = {totalMB: 32768, freeMB: 24576};
  assert.strictEqual(c.parallelMemoryAllowsLaunch(), true);
  return {denial_with_two_live_workers: true, new_snapshot_reopens_admission: true};
});

test('LEAN_NUM_THREADS_restored_when_Exec_throws', () => {
  const h = fixture(); const original = h.values.LEAN_NUM_THREADS;
  h.failNextExec = true;
  assert.throws(() => h.context.startNativeAsync(h.context.compiler, ['-j3'], h.context.helpers + '\\failed.log', 3, 'lean'), /SIMULATED Exec failure/);
  assert.strictEqual(h.values.LEAN_NUM_THREADS, original);
  assert.strictEqual(launched(h).length, 0);
  return {original_env_value: original, env_restored: true, launched_processes: 0};
});

test('ram_candidate_plan_excludes_pending_running_unverified_and_ready_outputs', () => {
  const h = fixture(); const c = h.context;
  c.parallelRuntime.ramCapMB = 1;
  const names = ['Done', 'Pending', 'Running', 'NoKey', 'UseA', 'UseB'];
  const ext = 'Mathlib.Review';
  for (const short of names) {
    const name = 'Review.' + short;
    c.modules[name] = {name, local: true, imports: [ext]};
    h.memory.put(c.work + '\\Review\\' + short + '.olean', 'MOCK local ' + short);
    h.memory.put(c.work + '\\Review\\' + short + '.olean.private', 'MOCK companion ' + short);
    c.moduleKeys[name] = 'key-' + short; c.artifactHashes[name] = 'artifact-' + short;
  }
  c.parallelRuntime.states['Review.Done'] = 'DONE';
  c.parallelRuntime.states['Review.Pending'] = 'PENDING';
  c.parallelRuntime.states['Review.Running'] = 'RUNNING';
  c.parallelRuntime.states['Review.NoKey'] = 'DONE'; delete c.moduleKeys['Review.NoKey'];
  for (const short of ['UseA', 'UseB']) {
    c.parallelRuntime.states['Review.' + short] = 'READY';
    c.modules['Review.' + short].imports = ['Review.Done', 'Review.Pending', 'Review.Running', 'Review.NoKey', ext];
  }
  const picked = Array.from(c.ramCandidatePlan([{name: 'Review.UseA'}, {name: 'Review.UseB'}]));
  assert(picked.some(x => x.module === 'Review.Done'));
  assert(picked.some(x => x.module === ext));
  assert(picked.every(x => !x.local || x.module === 'Review.Done'));
  assert(picked.every(x => x.frequency === 2));
  assert(new Set(picked.map(x => c.keyPath(x.path))).size === picked.length);
  assert(picked.reduce((a, x) => a + Math.ceil(x.bytes / 4096) * 4096, 0) <= 1048576);
  return {selected_files: picked.length, permitted_local_module: 'Review.Done', excluded_local_states: ['PENDING', 'RUNNING', 'READY', 'DONE_WITHOUT_KEY']};
});

function statusFixture(h) {
  const c = h.context;
  const ram = {token: 'mock-exact-request-token', requestSHA: 'a'.repeat(64), requestCount: 2,
    budgetBytes: 1048576, status: c.helpers + '\\mock.status.txt', stop: c.helpers + '\\mock.stop'};
  const status = {SCHEMA: 'RH_HILBERT_RAM_STATUS_V1', TOKEN: ram.token, REQUEST_SHA256: ram.requestSHA,
    OWNER_PID: String(c.lockSelf.pid), OWNER_START_UNIX_MS: String(c.processCreationMillis(c.lockSelf.created)),
    STATE: 'READY', TERMINAL: '0', REQUEST_FILES: '2', PROCESSED_FILES: '2', MAPPED_FILES: '2',
    WARMED_FILES: '2', SKIPPED_FILES: '0', HELD_FILES: '2', BUDGET_BYTES: '1048576',
    CHARGED_BYTES: '8192', MAPPED_BYTES: '6000', HELD_BYTES: '6000',
    MODE: 'WARM_MAPPED_FILE_CACHE', RESIDENCY: 'NOT_GUARANTEED', LEAN_ENVIRONMENT: 'NOT_SHARED'};
  const put = fields => h.memory.put(ram.status, Object.entries(fields).map(([k, v]) => k + '=' + v).join('\n') + '\n');
  return {ram, status, put};
}

test('ram_status_binds_exact_token_hash_pid_and_creation_time', () => {
  const h = fixture(); const {ram, status, put} = statusFixture(h); put(status);
  assert.strictEqual(h.context.readRamWarmStatus(ram).STATE, 'READY');
  const rejected = [];
  for (const field of ['TOKEN', 'REQUEST_SHA256', 'OWNER_PID', 'OWNER_START_UNIX_MS']) {
    put({...status, [field]: status[field] + '-wrong'});
    assert.throws(() => h.context.readRamWarmStatus(ram), /exact request and owner/); rejected.push(field);
  }
  return {valid_status_accepted: true, rejected_identity_fields: rejected};
});

test('ram_status_rejects_impossible_counts_bounds_and_residency_claims', () => {
  const h = fixture(); const {ram, status, put} = statusFixture(h);
  const mutants = [
    ['request_count', {REQUEST_FILES: '3'}], ['negative_count', {HELD_FILES: '-1'}],
    ['fractional_count', {PROCESSED_FILES: '1.5'}], ['too_many_files', {MAPPED_FILES: '3'}],
    ['oversized_budget', {BUDGET_BYTES: '1048577'}], ['charge_exceeds_budget', {CHARGED_BYTES: '1048577'}],
    ['held_exceeds_mapped', {HELD_BYTES: '6001'}], ['warm_exceeds_mapped_files', {MAPPED_FILES: '1'}],
    ['stopped_nonterminal', {STATE: 'STOPPED'}], ['terminal_holds_pages', {TERMINAL: '1'}],
    ['residency_claim', {RESIDENCY: 'GUARANTEED'}], ['shared_environment_claim', {LEAN_ENVIRONMENT: 'SHARED'}],
  ];
  for (const [name, change] of mutants) {
    put({...status, ...change}); assert.throws(() => h.context.readRamWarmStatus(ram), undefined, name);
  }
  put({...status, STATE: 'STOPPED', TERMINAL: '1', HELD_BYTES: '0', HELD_FILES: '0'});
  assert.strictEqual(h.context.readRamWarmStatus(ram).STATE, 'STOPPED');
  return {rejected_mutants: mutants.map(x => x[0]), released_terminal_status_accepted: true};
});

test('bounded_shutdown_retains_lock_for_live_worker_and_reports_unclean', () => {
  const h = fixture(); h.installLock(); const c = h.context;
  c.parallelRuntime.active = [{name: 'Review.Base', phase: 'COMPILE', proc: {Status: 0, ProcessID: 7777}}];
  const began = h.clock;
  assert.strictEqual(h.shutdownAndConditionalRelease(), false);
  assert.strictEqual(h.clock - began, 30000);
  assert(c.lockHeld); assert(h.memory.directory(c.lockPath));
  assert.strictEqual(c.parallelRuntime.shutdownComplete, true);
  assert.strictEqual(c.parallelRuntime.shutdownClean, false);
  const sleeps = h.sleeps.length;
  assert.strictEqual(c.parallelShutdown(), false); assert.strictEqual(h.sleeps.length, sleeps);
  c.result(false, 'SIMULATED retained worker');
  const result = JSON.parse(h.memory.text(c.root + '\\run-result.json'));
  assert.strictEqual(result.owned_worker_shutdown_complete, false);
  return {fake_wait_ms: 30000, lock_retained: true, repeated_shutdown_waits: 0, json_shutdown_complete: false};
});

test('unknown_worker_status_retains_lock_without_unsafe_cleanup', () => {
  const h = fixture(); h.installLock(); const c = h.context;
  const unknown = {}; Object.defineProperty(unknown, 'Status', {get() { throw new Error('SIMULATED inaccessible process'); }});
  c.parallelRuntime.active = [{name: 'Review.Base', phase: 'AUDIT', proc: unknown}];
  const output = c.work + '\\Review\\Base.olean'; h.memory.put(output, 'MOCK still-protected output');
  assert.strictEqual(h.shutdownAndConditionalRelease(), false);
  assert(c.lockHeld); assert(h.memory.exists(output));
  assert(h.messages.some(x => x.includes('STATUS_UNKNOWN')));
  return {lock_retained: true, output_preserved: true, fake_wait_ms: h.sleeps.reduce((a, b) => a + b, 0)};
});

test('finished_workers_need_safe_inventory_before_lock_release', () => {
  const unavailable = fixture(); unavailable.installLock(); unavailable.inventoryError = true;
  assert.strictEqual(unavailable.shutdownAndConditionalRelease(), false);
  assert(unavailable.context.lockHeld);
  const unreadable = fixture(); unreadable.installLock();
  unreadable.extraInventory = [{ProcessId: 8888, ParentProcessId: 55, CreationDate: '20261027095000.000000+000', Name: 'lean.exe', CommandLine: ''}];
  assert.strictEqual(unreadable.shutdownAndConditionalRelease(), false);
  assert(unreadable.context.lockHeld);
  const safe = fixture(); safe.installLock();
  safe.context.parallelRuntime.active = [{name: 'Review.Base', phase: 'AUDIT', proc: {Status: 1, ExitCode: 0, ProcessID: 7777}}];
  assert.strictEqual(safe.shutdownAndConditionalRelease(), true);
  assert.strictEqual(safe.context.lockHeld, false); assert(!safe.memory.directory(safe.context.lockPath));
  return {unavailable_inventory_retained: true, unreadable_worker_retained: true, safe_inventory_released: true};
});

test('only_exact_read_only_follower_script_is_excluded_from_shutdown_guard', () => {
  const h = fixture(); h.installLock(); const c = h.context;
  h.extraInventory = [{ProcessId: 8888, ParentProcessId: 55, CreationDate: '20261027095000.000000+000', Name: 'cscript.exe',
    CommandLine: '"C:\\Windows\\System32\\cscript.exe" //nologo "' + c.root + '\\tools\\follow_active.js" "' + c.root + '"'}];
  assert.strictEqual(h.shutdownAndConditionalRelease(), true);
  const bad = fixture(); bad.installLock();
  bad.extraInventory = [{ProcessId: 8888, ParentProcessId: 55, CreationDate: '20261027095000.000000+000', Name: 'cscript.exe',
    CommandLine: '"C:\\Windows\\System32\\cscript.exe" "' + bad.context.root + '\\tools\\native_runner.js" "' + bad.context.root + '\\tools\\follow_active.js"'}];
  assert.strictEqual(bad.shutdownAndConditionalRelease(), false);
  assert(bad.context.lockHeld);
  return {exact_follower_allowed: true, observer_path_in_later_argument_not_trusted: true};
});

test('fatal_save_hash_failure_stops_admission_and_protects_remaining_worker', () => {
  const h = fixture({durations: {'Review.Independent': {COMPILE: 90000, AUDIT: 100}}}); h.installLock();
  const c = h.context, fresh = c.freshHashSet;
  let injected = false;
  c.freshHashSet = (paths, purpose, forced) => {
    if (String(purpose).startsWith('SAVE_') && String(purpose).includes('Review.Base')) {
      injected = true; return c.fatalHashError('SIMULATED hash transport failure during acceptance');
    }
    return fresh(paths, purpose, forced);
  };
  assert.throws(() => h.run(), /HASH_INFRASTRUCTURE_FATAL/);
  assert(injected);
  assert(!leanLaunches(h).some(e => e.module === 'Review.Leaf'));
  assert.strictEqual(c.moduleKeys['Review.Base'], undefined);
  assert.strictEqual(h.shutdownAndConditionalRelease(), false);
  assert(c.lockHeld);
  return {fatal_error_propagated: true, failed_parent_not_published: true, descendant_not_launched: true, live_independent_worker_protected: true};
});

test('generated_audit_path_collision_rejected_before_native_launch', () => {
  const h = fixture({}, {'Review.A_B': [], 'Review.A.B': []});
  assert.throws(() => h.run(), /PARALLEL_OUTPUT_PATH_COLLISION/);
  assert.strictEqual(launched(h).length, 0);
  return {colliding_generated_names_rejected: true, native_launches: 0};
});

test('ram_selftest_and_async_launch_counters_produce_valid_JSON', () => {
  const h = fixture(); const c = h.context, prior = c.runToFile;
  c.runToFile = (exe, args, output) => {
    if (/\\ramwarm\.exe$/i.test(exe) && args.length === 1 && args[0] === '--self-test') {
      h.memory.put(output, 'RAM_WARM_SELF_TEST=PASS\n'); return 0;
    }
    return prior(exe, args, output);
  };
  const exe = c.helpers + '\\ramwarm.exe', output = c.helpers + '\\ram-selftest.log';
  c.ramSelfTest(exe, output);
  c.startNativeAsync(exe, ['--warm', c.helpers + '\\request.tsv'], c.helpers + '\\ram.log', 0, 'ram_warm');
  assert.strictEqual(c.directLaunchCounts.ram_warm, 2);
  c.parallelRuntime.shutdownComplete = true; c.parallelRuntime.shutdownClean = false;
  c.result(false, 'SIMULATED reporting regression');
  const report = JSON.parse(h.memory.text(c.root + '\\run-result.json'));
  assert.strictEqual(report.logical_tool_launches.ram_warm, 2);
  assert(Object.values(report.logical_tool_launches).every(Number.isFinite));
  assert.strictEqual(report.owned_worker_shutdown_complete, false);
  assert.strictEqual(report.finite_checker_equivalence, 'OPEN');
  return {ram_warm_launch_counter: 2, JSON_parse: 'SUCCESS', finite_checker_equivalence: 'OPEN', shutdown_complete: false};
});

for (const key of ['runner', 'parallel', 'ram']) assert.strictEqual(sha256(inputBytes(key)), initialHashes[key], key + ' changed during review');
const report = {
  schema: 'RH_RAM_PARALLEL_NODE_VM_REVIEW_V1',
  scope: 'Node VM with in-memory files, simulated WMI/process responses, and a fake clock; no native execution.',
  runner_sha256: initialHashes.runner,
  parallel_runtime_sha256: initialHashes.parallel,
  ram_runtime_sha256: initialHashes.ram,
  binding: 'Exact function definitions from the assembled runner, with frozen draft byte equality asserted.',
  runner_COM_setter_adaptations: runnerComSetters,
  host_adaptations: [
    'Only WSH COM env("NAME") property-put syntax becomes __setEnv in Node; frozen parallel draft has exactly two setters and RAM draft zero.',
    'The inherited mock host accepts the new entry marker but evaluates definitions only, never the WSH entry point.',
    'FSO/ADODB, WMI, shell.Exec/Run, native stdout/artifacts, and time are simulated boundaries.',
    'One fatal transport scenario injects rhFatalHash through freshHashSet; cache acceptance and propagation code remain actual.',
    'Shutdown release tests invoke the actual release function only when actual parallelShutdown returns true; package entry-point execution is excluded.',
  ],
  passed: results.filter(r => r.outcome === 'PASS').length,
  failed: results.filter(r => r.outcome === 'FAIL').length,
  cases: results,
  limitations: [
    'No Lean proof compilation or axiom certification; simulated compiler outputs and receipts exist only in memory.',
    'No Windows, WSH/COM, WMI, process-tree, real shell quoting, C#, memory mapping, RAM-residency, or native performance validation.',
    'The whole WSH runner entry point, sidecar native implementation, helper build/cache lifecycle, and unrelated inherited cache suites were not executed.',
    'Memory and fake-clock observations establish control-flow properties only, not a physical RAM ceiling or elapsed-time improvement.',
  ],
  source_files_unchanged: true,
};
fs.mkdirSync(path.dirname(flags.report), {recursive: true});
fs.writeFileSync(flags.report, JSON.stringify(report, null, 2) + '\n');
console.log(JSON.stringify({runner_sha256: report.runner_sha256, passed: report.passed, failed: report.failed,
  failures: results.filter(r => r.outcome === 'FAIL').map(r => ({name: r.name, error: r.error})), report: flags.report}, null, 2));
process.exitCode = report.failed ? 1 : 0;
