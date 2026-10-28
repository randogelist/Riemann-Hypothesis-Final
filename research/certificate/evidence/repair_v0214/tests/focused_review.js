'use strict';

// Node-only, in-memory regression of actual runner functions.
// No whole WSH entry point, native process, Lean/Lake, C# or CI is executed.
const fs = require('fs');
const path = require('path');
const assert = require('assert');
const {makeHost, sha256} = require('./runtime_host');
const oldSources = require('./candidate_sources');
const shutdownSource = require('./shutdown_retry_source');

const args = {};
for (let i = 2; i < process.argv.length; i += 2) {
  assert(['--package-root', '--report'].includes(process.argv[i]), 'unknown argument');
  assert(process.argv[i + 1], 'missing argument');
  args[process.argv[i].slice(2)] = path.resolve(process.argv[i + 1]);
}
assert(args['package-root'] && args.report, 'Use --package-root DIRECTORY --report FILE');
const paths = {runner: path.join(args['package-root'], 'tools', 'native_runner.js')};
const runnerBytes = fs.readFileSync(paths.runner), runnerSHA = sha256(runnerBytes);
assert(runnerBytes.toString('utf8').includes(shutdownSource), 'assembled runner does not contain the exact reviewed retry source');
assert.strictEqual(sha256(shutdownSource), '32dd483658af0764a1e123973e4a2928eeb50bee2fb3f2e6e86230bf43eee925');
const setterCount = [...runnerBytes.toString('utf8').matchAll(/env\("([A-Z_]+)"\)\s*=(?!=)/g)].length;
assert.strictEqual(setterCount, 7, 'unexpected WSH COM setter adaptation count');
const results = [];
const oneModule = {'Review.Single': []};
function fixture(options = {}, graph) { return makeHost(paths, options).installFixture(graph).startup(); }
function test(name, action) {
  try { results.push({name, outcome: 'PASS', evidence: action() || {}}); }
  catch (e) { results.push({name, outcome: 'FAIL', error: e.message, stack: e.stack}); }
}
function record(changes = {}) {
  return Object.assign({ProcessId: 7200, ParentProcessId: 4000, CreationDate: '20261027100000.123456+000',
    Name: 'certutil.exe', CommandLine: ''}, changes);
}
function installed(options = {}, graph) { const h = fixture(options, graph); h.installLock(); return h; }
function ownText(h) { return h.memory.text(h.context.lockPath + '\\owner.txt'); }
function guardQueryOverride(h, change) {
  const prior = h.context.GetObject;
  h.context.GetObject = (...args) => {
    const service = prior(...args);
    return {ExecQuery(query, ...rest) {
      const result = service.ExecQuery(query, ...rest);
      return /FROM Win32_Process/.test(query) ? change(result) : result;
    }};
  };
}
function relativeRecord() {
  return {ProcessId: 8888, ParentProcessId: 55, CreationDate: '20261027095000.001234+000', Name: 'cscript.exe',
    CommandLine: '"C:\\Windows\\System32\\cscript.exe" //nologo tools\\native_runner.js'};
}

test('already_clear_owned_shutdown_uses_one_inventory_without_waiting', () => {
  const h = installed(), c = h.context;
  const before = h.clock, inventories = h.inventoryQueries;
  assert.strictEqual(h.shutdownAndConditionalRelease(), true);
  assert.strictEqual(h.clock - before, 0);
  assert.strictEqual(h.inventoryQueries - inventories, 1);
  assert.strictEqual(c.parallelRuntime.shutdownInventoryAttempts, 1);
  assert.strictEqual(c.lockHeld, false);
  return {inventory_queries:1,fake_wait_ms:0,lock_released:true};
});

test('transient_unreadable_certutil_requires_fresh_guard_success_before_release', () => {
  const h = installed(), c = h.context;
  c.failed = 1; // A clean shutdown must not change the simulated proof/build failure.
  h.extraInventory = [record()];
  const before = h.clock, inventoryBefore = h.inventoryQueries;
  h.onSleep = () => { h.extraInventory = []; };
  assert.strictEqual(h.shutdownAndConditionalRelease(), true);
  assert.strictEqual(h.clock - before, 200);
  assert.strictEqual(h.inventoryQueries - inventoryBefore, 2);
  assert.strictEqual(c.lockHeld, false); assert(!h.memory.directory(c.lockPath));
  assert.strictEqual(c.failed, 1);
  assert.strictEqual(c.parallelRuntime.shutdownClean, true);
  return {fresh_inventory_queries: 2, fake_wait_ms: 200, lock_released_after_guard_pass: true, build_failure_preserved: true};
});

test('persistent_unreadable_certutil_retains_lock_after_six_attempts', () => {
  const h = installed(), c = h.context, owner = ownText(h);
  h.extraInventory = [record()];
  const before = h.clock, inventoryBefore = h.inventoryQueries;
  assert.strictEqual(h.shutdownAndConditionalRelease(), false);
  assert.strictEqual(h.clock - before, 1000);
  assert.strictEqual(h.inventoryQueries - inventoryBefore, 6);
  assert.deepStrictEqual(h.sleeps, [200,200,200,200,200]);
  assert(c.lockHeld); assert.strictEqual(ownText(h), owner);
  assert.strictEqual(c.parallelRuntime.shutdownKeepLock, true);
  assert(h.messages.some(x => x.includes('certutil.exe') && x.includes('7200')));
  return {fresh_inventory_queries: 6, fake_wait_ms: 1000, lock_retained: true, same_owner_record: true};
});

test('readable_current_root_worker_after_uncertainty_blocks_immediately', () => {
  const h = installed(), c = h.context;
  h.extraInventory = [record()];
  h.onSleep = () => { h.extraInventory[0].CommandLine = 'certutil.exe -hashfile "' + c.root + '\\input.bin" SHA256'; };
  const before = h.clock;
  assert.strictEqual(h.shutdownAndConditionalRelease(), false);
  assert.strictEqual(h.clock - before, 200);
  assert(c.lockHeld);
  assert(h.messages.some(x => x.includes('RUNNER_ACTIVE') && x.includes('7200')));
  return {fake_wait_ms: 200, current_root_worker_retained: true, untagged_active_error_retried: false};
});

test('whole_fresh_inventory_catches_new_blocker_after_old_pid_disappears', () => {
  const h = installed(), c = h.context;
  h.extraInventory = [record()];
  h.onSleep = () => { h.extraInventory = [record({ProcessId: 7300, Name: 'lean.exe', CommandLine:
    'lean.exe "' + c.root + '\\Review\\Single.lean"'})]; };
  const before = h.clock;
  assert.strictEqual(h.shutdownAndConditionalRelease(), false);
  assert.strictEqual(h.clock - before, 200); assert(c.lockHeld);
  assert(h.messages.some(x => x.includes('RUNNER_ACTIVE') && x.includes('7300')));
  return {old_pid_disappeared: true, new_pid: 7300, new_current_root_worker_blocks: true};
});

test('pid_reuse_with_new_creation_and_unreadable_command_remains_unknown', () => {
  const h = installed(), c = h.context;
  h.extraInventory = [record()];
  h.onSleep = () => { h.extraInventory = [record({CreationDate: '20261027100000.123457+000'})]; };
  const before = h.clock;
  assert.strictEqual(h.shutdownAndConditionalRelease(), false);
  assert.strictEqual(h.clock - before, 1000); assert(c.lockHeld);
  assert(h.messages.some(x => x.includes('20261027100000.123457+000')));
  return {same_pid_new_creation_remains_guarded: true, fake_wait_ms: 1000};
});

test('inventory_failure_is_not_retryable_or_a_clean_shutdown', () => {
  const cases = [];
  for (const timing of ['initial', 'after_unreadable']) {
    const h = installed(), c = h.context, owner = ownText(h);
    if (timing === 'initial') h.inventoryError = true;
    else { h.extraInventory = [record()]; h.onSleep = () => { h.inventoryError = true; }; }
    const before = h.clock;
    assert.strictEqual(h.shutdownAndConditionalRelease(), false);
    assert.strictEqual(h.clock - before, timing === 'initial' ? 0 : 200);
    assert(c.lockHeld); assert.strictEqual(ownText(h), owner);
    cases.push({failure_timing: timing, fake_wait_ms: h.clock - before, lock_retained: true});
  }
  return {cases};
});

test('changed_lock_owner_during_retry_is_preserved_and_stops_immediately', () => {
  const h = installed(), c = h.context;
  const replacement = ownText(h).replace('TOKEN=mock-owner-token-123456', 'TOKEN=mock-new-owner-654321');
  h.extraInventory = [record()];
  h.onSleep = () => { h.memory.put(c.lockPath + '\\owner.txt', replacement); h.extraInventory = []; };
  const before = h.clock;
  assert.strictEqual(h.shutdownAndConditionalRelease(), false);
  assert.strictEqual(h.clock - before, 200); assert(c.lockHeld);
  assert.strictEqual(ownText(h), replacement);
  return {changed_owner_preserved: true, fake_wait_ms: 200, clean_snapshot_did_not_override_owner_guard: true};
});

test('missing_or_changed_self_identity_prevents_shutdown_release', () => {
  const cases = [];
  for (const mode of ['missing', 'changed_creation']) {
    const h = installed(), c = h.context, owner = ownText(h);
    guardQueryOverride(h, rows => mode === 'missing' ? rows.filter(p => p.ProcessId !== c.lockSelf.pid) :
      rows.map(p => p.ProcessId === c.lockSelf.pid ? Object.assign({}, p, {CreationDate:'20261027095959.000001+000'}) : p));
    const before = h.clock;
    assert.strictEqual(h.shutdownAndConditionalRelease(), false);
    assert.strictEqual(h.clock - before, 0); assert(c.lockHeld); assert.strictEqual(ownText(h), owner);
    cases.push({self_identity: mode, fake_wait_ms: 0, lock_retained: true});
  }
  return {cases};
});

test('existing_admitted_relative_host_and_transient_certutil_are_checked_together', () => {
  const h = fixture(), c = h.context;
  h.extraInventory = [relativeRecord()]; c.acquireRunnerLock();
  assert.strictEqual(c.lockAdmittedRelativeHosts.length, 1);
  h.extraInventory.push(record());
  h.onSleep = () => { h.extraInventory = [relativeRecord()]; };
  assert.strictEqual(h.shutdownAndConditionalRelease(), true);
  assert.strictEqual(c.lockHeld, false);
  assert(h.messages.some(x => x.includes('SHUTDOWN_PREEXISTING_ADMITTED_UNRESOLVED_HOST=PID:8888')));
  return {same_owner_exact_relative_host_preserved: true, transient_worker_still_required_recheck: true};
});

test('stale_and_legacy_recovery_never_use_shutdown_retry', () => {
  const cases = [];
  for (const schema of ['owned', 'legacy_empty']) {
    const h = fixture(), c = h.context;
    const text = schema === 'owned' ? c.formatLockOwner({ROOT: c.keyPath(c.root), SCRIPT: c.keyPath(c.root + '\\tools\\native_runner.js'),
      PID: '4321', CREATED: '20261027090000.000000+000', TOKEN: 'mock-stale-owner-12345', RUN_TAG: c.runTag}) : '';
    if (schema === 'owned') h.memory.put(c.lockPath + '\\owner.txt', text); else h.memory.mkdir(c.lockPath);
    h.extraInventory = [record()];
    assert.throws(() => c.acquireRunnerLock(), /unreadable command line/);
    assert(h.memory.directory(c.lockPath)); assert.strictEqual(c.lockHeld, false);
    if (schema === 'owned') assert.strictEqual(ownText(h), text);
    assert.strictEqual(c.lockRecovered, 0); assert.strictEqual(h.sleeps.length, 0);
    cases.push({lock_schema: schema, immediate_rejection: true, recovery_count: 0});
  }
  return {cases};
});

test('live_or_unknown_owned_process_still_uses_original_drain_and_retains_lock', () => {
  const cases = [];
  for (const state of ['live', 'unknown']) {
    const h = installed(), c = h.context;
    const proc = {ProcessID: 7003};
    Object.defineProperty(proc, 'Status', {get() { if (state === 'unknown') throw new Error('SIMULATED unknown status'); return 0; }});
    c.parallelRuntime.active = [{name:'Review.Single',phase:'COMPILE',threads:16,proc}];
    const before = h.clock, inventories = h.inventoryQueries;
    assert.strictEqual(h.shutdownAndConditionalRelease(), false);
    assert.strictEqual(h.clock - before, 30000);
    assert.strictEqual(h.inventoryQueries, inventories); assert(c.lockHeld);
    cases.push({owned_state:state,fake_drain_ms:30000,shutdown_inventory_not_reached:true,lock_retained:true});
  }
  return {cases};
});

test('owned_worker_appearing_during_inventory_prevents_release', () => {
  const h = installed(), c = h.context;
  guardQueryOverride(h, rows => {
    c.parallelRuntime.active = [{name:'Review.Single',phase:'COMPILE',threads:16,proc:{ProcessID:7004,Status:0}}];
    return rows;
  });
  const before = h.clock;
  assert.strictEqual(h.shutdownAndConditionalRelease(), false);
  assert.strictEqual(h.clock - before, 0); assert(c.lockHeld);
  return {post_inventory_owned_worker_check: true, clean_external_inventory_not_sufficient: true};
});

test('memory_serial_fallback_and_final_audit_barriers_remain_effective', () => {
  const h = fixture({memoryState:{totalMB:31900,freeMB:5479}}, oneModule), c = h.context;
  h.run();
  assert.strictEqual(c.parallelRuntime.memoryFallback, true);
  assert.strictEqual(c.parallelRuntime.workers, 1);
  assert.strictEqual(c.parallelRuntime.minimumReserveMB, 1024);
  assert.strictEqual(c.parallelRuntime.workerMemoryMB, 4096);
  assert.strictEqual(c.parallelRuntime.ramCapMB, 0);
  const before = c.directLaunchCounts.lean;
  h.memoryState = {totalMB:31900,freeMB:5119}; h.clock += 2100;
  assert.throws(() => c.finalAudit(), /PARALLEL_RESOURCE_BLOCKED/);
  assert.strictEqual(c.directLaunchCounts.lean, before); assert.strictEqual(c.moduleKeys.Audit, undefined);
  return {idle_fallback_workers:1,serial_required_mib:5120,dirty_final_denied_at_5119:true};
});

test('verified_final_cache_reuse_does_not_require_new_memory_or_compile', () => {
  const seed = fixture({}, oneModule); seed.run(); seed.context.finalAudit();
  const h = makeHost(paths, {memory:seed.memory,memoryState:{totalMB:31900,freeMB:1}}).startup();
  h.run(); const c = h.context, before = {queries:h.memoryQueries,lean:c.directLaunchCounts.lean};
  c.finalAudit();
  assert(c.moduleKeys.Audit); assert.strictEqual(c.compiled,0);
  assert.strictEqual(h.memoryQueries,before.queries);
  assert.strictEqual(c.directLaunchCounts.lean,before.lean);
  assert.strictEqual(c.parallelRuntime.memoryFallback,false);
  return {verified_final_reused:true,added_compiler_calls:0,added_memory_queries:0};
});

assert.strictEqual(sha256(fs.readFileSync(paths.runner)), runnerSHA, 'runner changed during review');
const report = {
  schema: 'RH_V0214_FOCUSED_NODE_VM_REVIEW_V1', status: results.every(x => x.outcome === 'PASS') ? 'PASS' : 'FAIL',
  scope: 'NODE_VM_SYNTHETIC_HOST_ONLY', runner_sha256: runnerSHA,
  shutdown_retry_sha256: sha256(shutdownSource),
  native_tail_sha256: '867466f9b20067e9abb5a9a4c1f3f8458d6fad0a95387ab859f0a189749e5c1b',
  unchanged_memory_fallback_sha256: sha256(oldSources.memory), unchanged_admitted_relative_hosts_sha256: sha256(oldSources.admitted),
  passed: results.filter(x => x.outcome === 'PASS').length, failed: results.filter(x => x.outcome === 'FAIL').length,
  cases: results,
  host: {basis:'Reused v0.2.13 in-memory host support; prior 15-case suite was not rerun.',
    assembled_COM_setter_adaptations:setterCount,entry_point_executed:false,actual_runner_function_definitions:true},
  limitations:[
    'No native Windows, WSH/COM, WMI, process tree, C#, Lean/Lake, CI, memory mapping, or performance execution.',
    'Compiler outputs, receipts, process identities, RAM readings, and time are simulated in memory.',
    'WMI API calls have no real-time completion guarantee; 1000 ms refers to bounded scheduled mock sleeps only.',
    'The supplied native user run remains FAIL. These tests do not certify the Lean repair, mathematical endpoint or finite checker equivalence.',
    'A persistent unreadable worker is retained as unknown; no test treats it as known unrelated or as a safe hash-only command.',
  ],
  runner_sources_unmodified:true,
};
fs.mkdirSync(path.dirname(args.report), {recursive:true});
fs.writeFileSync(args.report, JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({runner_sha256:runnerSHA,status:report.status,passed:report.passed,failed:report.failed,
  failures:results.filter(x => x.outcome==='FAIL').map(x => ({name:x.name,error:x.error})),report:args.report},null,2));
process.exitCode=report.failed?1:0;
