'use strict';

// Source-bound Node VM scenarios for shutdown only. The actual assembled
// runner functions execute against in-memory WSH/WMI/files/shell boundaries.
// This script has no child-process API and does not execute Windows or Lean.
const fs = require('fs'), path = require('path'), assert = require('assert');
const {makeHost, sha256} = require('./runtime_host');
const args = {};
for (let i = 2; i < process.argv.length; i += 2) {
  assert(['--package-root', '--report', '--expected-runner-sha256'].includes(process.argv[i]), 'unknown argument');
  assert(process.argv[i + 1], 'missing argument');
  args[process.argv[i].slice(2)] = process.argv[i + 1];
}
assert(args['package-root'] && args.report && /^[a-f0-9]{64}$/.test(args['expected-runner-sha256'] || ''), 'missing required arguments');
const runner = path.join(path.resolve(args['package-root']), 'tools', 'native_runner.js');
const runnerBytes = fs.readFileSync(runner), runnerSHA = sha256(runnerBytes);
assert.strictEqual(runnerSHA, args['expected-runner-sha256'], 'unexpected candidate bytes');
const setterCount = [...runnerBytes.toString('utf8').matchAll(/env\("([A-Z_]+)"\)\s*=(?!=)/g)].length;
assert.strictEqual(setterCount, 7, 'COM setter adaptation count changed');
const results = [];
function test(name, action) {
  try { results.push({name, outcome: 'PASS', evidence: action() || {}}); }
  catch (e) { results.push({name, outcome: 'FAIL', error: e.message, stack: e.stack}); }
}
const graph = {'Review.Single': []};
const freshCreated = '20261027100000.123456+000';
function relative(changes = {}) {
  return Object.assign({ProcessId: 8001, ParentProcessId: 55, CreationDate: freshCreated,
    Name: 'cscript.exe', CommandLine: '"C:\\Windows\\System32\\cscript.exe" //nologo tools\\native_runner.js'}, changes);
}
function admitted(changes = {}) {
  return relative(Object.assign({ProcessId: 34008, CreationDate: '20261027095000.001234+000'}, changes));
}
function unreadable(changes = {}) { return relative(Object.assign({CommandLine: ''}, changes)); }
function fixture(preexisting = []) {
  const h = makeHost({runner}).installFixture(graph);
  h.extraInventory = preexisting.slice();
  h.context.acquireRunnerLock(); h.startup();
  assert.strictEqual(h.context.runToFile, h.actualRunToFile, 'actual runToFile must remain bound');
  return h;
}
function owner(h) { return h.memory.text(h.context.lockPath + '\\owner.txt'); }
function query(h, pid, action) {
  h.inventoryProvider = event => event.pid === pid ? action(event) : event.rows;
}
function shutdown(h) {
  const c = h.context, before = {launches: c.directLaunchCounts.total, records: c.ownedNativeLaunches.length};
  const result = h.shutdownAndConditionalRelease();
  assert.strictEqual(c.directLaunchCounts.total, before.launches, 'shutdown made an additional native launch');
  assert.strictEqual(c.ownedNativeLaunches.length, before.records, 'shutdown created a native launch record');
  return result;
}
function retained(h, originalOwner) {
  assert.strictEqual(h.context.lockHeld, true, 'lock must remain held');
  assert.strictEqual(h.memory.directory(h.context.lockPath), true, 'lock directory must be retained');
  if (originalOwner !== undefined) assert.strictEqual(owner(h), originalOwner, 'lock owner bytes changed');
}

test('new_relative_host_confirmed_absent_from_exact_query_clears', () => {
  const h = fixture(), c = h.context; h.extraInventory = [relative()];
  const start = {clock: h.clock, full: h.fullInventoryQueries};
  query(h, 8001, () => { h.extraInventory = []; return []; });
  assert.strictEqual(shutdown(h), true);
  assert.strictEqual(h.fullInventoryQueries - start.full, 2);
  assert.strictEqual(c.parallelRuntime.shutdownTargetedWorkerQueries, 1);
  assert.strictEqual(c.parallelRuntime.shutdownExpiredRows, 1);
  assert.strictEqual(h.clock - start.clock, 0);
  assert.strictEqual(c.lockHeld, false);
  return {full_inventories: 2, exact_worker_queries: 1, scheduled_sleep_ms: 0, lock_released_after_verified_absence_and_fresh_barrier: true};
});

test('persistent_new_relative_host_retains_lock_after_six_exact_checks', () => {
  const h = fixture(), c = h.context; h.extraInventory = [relative()];
  const text = owner(h), start = {clock: h.clock, full: h.fullInventoryQueries};
  assert.strictEqual(shutdown(h), false); retained(h, text);
  assert.strictEqual(h.fullInventoryQueries - start.full, 1);
  assert.strictEqual(c.parallelRuntime.shutdownInventoryAttempts, 6);
  assert.strictEqual(c.parallelRuntime.shutdownTargetedWorkerQueries, 6);
  assert.strictEqual(c.parallelRuntime.shutdownTargetedSelfQueries, 12);
  assert.strictEqual(c.parallelRuntime.shutdownExpiredRows, 0);
  assert.strictEqual(h.clock - start.clock, 1000);
  return {full_inventories: 1, exact_worker_queries: 6, exact_self_queries: 12, scheduled_sleep_ms: 1000, persistent_host_not_exempted: true};
});

test('relative_row_command_changes_do_not_become_foreign_process_exemptions', () => {
  const variants = [
    ['different_relative_script', h => '"C:\\Windows\\System32\\cscript.exe" .\\tools\\native_runner.js'],
    ['absolute_other_workspace', h => '"C:\\Windows\\System32\\cscript.exe" "E:\\OTHER\\tools\\native_runner.js"'],
    ['absolute_current_workspace', h => '"C:\\Windows\\System32\\cscript.exe" "' + h.context.root + '\\tools\\native_runner.js"'],
    ['became_unreadable', h => ''],
  ];
  for (const [name, command] of variants) {
    const h = fixture(), c = h.context; h.extraInventory = [relative()]; const text = owner(h);
    query(h, 8001, () => [relative({CommandLine: command(h)})]);
    assert.strictEqual(shutdown(h), false, name); retained(h, text);
    assert.strictEqual(c.parallelRuntime.shutdownExpiredRows, 0, name);
    assert.strictEqual(c.parallelRuntime.shutdownTargetedWorkerQueries, 1, name);
    assert.strictEqual(h.sleeps.length, 0, name);
  }
  return {retained_command_change_variants: variants.map(x => x[0]), assumed_absences: 0};
});

test('relative_row_identity_reuse_or_incomplete_exact_queries_fail_closed', () => {
  const variants = [
    ['query_throws', () => { throw new Error('SIMULATED exact WMI failure'); }],
    ['duplicate_rows', () => [relative(), relative()]],
    ['partial_enumeration_throws', () => { const rows = [relative(), relative()]; Object.defineProperty(rows, 1, {get() { throw new Error('SIMULATED partial enumeration'); }}); return rows; }],
    ['wrong_pid', () => [relative({ProcessId: 8002})]],
    ['pid_recycled_new_creation', () => [relative({CreationDate: '20261027100000.123457+000'})]],
    ['changed_name', () => [relative({Name: 'wscript.exe'})]],
    ['changed_parent', () => [relative({ParentProcessId: 56})]],
    ['missing_creation', () => [relative({CreationDate: ''})]],
    ['invalid_parent', () => [relative({ParentProcessId: -1})]],
  ];
  for (const [name, response] of variants) {
    const h = fixture(), c = h.context; h.extraInventory = [relative()]; const text = owner(h);
    query(h, 8001, response);
    assert.strictEqual(shutdown(h), false, name); retained(h, text);
    assert.strictEqual(c.parallelRuntime.shutdownExpiredRows, 0, name);
    assert.strictEqual(h.sleeps.length, 0, name);
  }
  return {retained_variants: variants.map(x => x[0]), incomplete_query_is_never_absence: true};
});

test('readable_current_root_workers_are_never_expired_by_relative_host_recheck', () => {
  const variants = [
    ['relative_runner_with_current_root_argument', h => relative({CommandLine: relative().CommandLine + ' --workspace="' + h.context.root + '\\"'})],
    ['absolute_current_root_runner', h => relative({CommandLine: '"C:\\Windows\\System32\\cscript.exe" "' + h.context.root + '\\tools\\native_runner.js"'})],
    ['readable_current_root_lean', h => relative({Name: 'lean.exe', CommandLine: 'lean.exe "' + h.context.root + '\\Review\\Single.lean"'})],
  ];
  for (const [name, row] of variants) {
    const h = fixture(), c = h.context; h.extraInventory = [row(h)]; const text = owner(h);
    query(h, 8001, () => []);
    assert.strictEqual(shutdown(h), false, name); retained(h, text);
    assert.strictEqual(c.parallelRuntime.shutdownTargetedWorkerQueries, 0, name);
    assert.strictEqual(c.parallelRuntime.shutdownExpiredRows, 0, name);
    assert.strictEqual(h.sleeps.length, 0, name);
  }
  return {retained_current_root_variants: variants.map(x => x[0]), absence_query_cannot_bypass_initial_current_root_guard: true};
});

test('unreadable_to_relative_to_absent_continues_original_row_recheck', () => {
  const h = fixture(), c = h.context; h.extraInventory = [unreadable()]; let calls = 0;
  query(h, 8001, () => {
    if (++calls === 1) return [relative()];
    h.extraInventory = []; return [];
  });
  const start = h.clock;
  assert.strictEqual(shutdown(h), true);
  assert.strictEqual(c.parallelRuntime.shutdownFullInventoryQueries, 2);
  assert.strictEqual(c.parallelRuntime.shutdownTargetedWorkerQueries, 2);
  assert.strictEqual(c.parallelRuntime.shutdownExpiredRows, 1);
  assert.strictEqual(h.clock - start, 200);
  assert.strictEqual(c.lockHeld, false);
  return {full_inventories: 2, worker_queries: 2, scheduled_sleep_ms: 200, transition_remained_pending_until_confirmed_absence_and_barrier: true};
});

test('unreadable_to_persistent_relative_is_not_treated_as_resolved', () => {
  const h = fixture(), c = h.context; h.extraInventory = [unreadable()]; const text = owner(h);
  query(h, 8001, () => [relative()]);
  assert.strictEqual(shutdown(h), false); retained(h, text);
  assert.strictEqual(c.parallelRuntime.shutdownInventoryAttempts, 6);
  assert.strictEqual(c.parallelRuntime.shutdownTargetedWorkerQueries, 6);
  assert.strictEqual(c.parallelRuntime.shutdownExpiredRows, 0);
  assert.strictEqual(h.sleeps.reduce((a, b) => a + b, 0), 1000);
  return {worker_queries: 6, persistent_relative_transition_still_blocks: true};
});

test('unreadable_to_relative_then_command_change_retains_lock', () => {
  const h = fixture(), c = h.context; h.extraInventory = [unreadable()]; const text = owner(h); let calls = 0;
  query(h, 8001, () => [++calls === 1 ? relative() : relative({CommandLine: '"C:\\Windows\\System32\\cscript.exe" "E:\\OTHER\\tools\\native_runner.js"'})]);
  assert.strictEqual(shutdown(h), false); retained(h, text);
  assert.strictEqual(c.parallelRuntime.shutdownTargetedWorkerQueries, 2);
  assert.strictEqual(c.parallelRuntime.shutdownExpiredRows, 0);
  return {worker_queries: 2, newly_observed_relative_command_bound_for_later_rechecks: true};
});

test('fresh_lock_preexisting_admitted_host_exemption_remains_exact', () => {
  const h = fixture([admitted()]), c = h.context;
  assert.strictEqual(c.lockAdmittedRelativeHosts.length, 1);
  assert.strictEqual(shutdown(h), true);
  assert.strictEqual(c.parallelRuntime.shutdownTargetedWorkerQueries, 0);
  assert.strictEqual(c.lockHeld, false);
  const changed = fixture([admitted()]), cc = changed.context;
  changed.extraInventory = [admitted({CommandLine: admitted().CommandLine + ' --workspace="' + cc.root + '\\"'})];
  const text = owner(changed);
  assert.strictEqual(shutdown(changed), false); retained(changed, text);
  assert.strictEqual(cc.parallelRuntime.shutdownTargetedWorkerQueries, 0);
  return {unchanged_admitted_host_queries: 0, current_root_command_change_not_exempt: true};
});

test('stale_and_legacy_acquisition_do_not_use_shutdown_relative_rechecks', () => {
  for (const schema of ['owned', 'legacy_empty']) {
    const h = makeHost({runner}).installFixture(graph), c = h.context;
    const text = schema === 'owned' ? c.formatLockOwner({ROOT: c.keyPath(c.root), SCRIPT: c.keyPath(c.root + '\\tools\\native_runner.js'), PID: '4321', CREATED: '20261027090000.000000+000', TOKEN: 'mock-stale-owner-12345', RUN_TAG: c.runTag}) : '';
    if (schema === 'owned') h.memory.put(c.lockPath + '\\owner.txt', text); else h.memory.mkdir(c.lockPath);
    h.extraInventory = [relative()]; query(h, 8001, () => []);
    assert.throws(() => c.acquireRunnerLock(), /legacy relative-path native_runner\.js|relative.*native_runner\.js/i);
    assert.strictEqual(h.targetInventoryQueries.length, 0, schema);
    assert.strictEqual(c.lockRecovered, 0, schema);
    assert.strictEqual(c.lockHeld, false, schema);
    assert(h.memory.directory(c.lockPath), schema);
    if (schema === 'owned') assert.strictEqual(owner(h), text);
  }
  return {stale_recovery_exact_queries: 0, prior_locks_preserved: true};
});

test('fresh_barrier_rejects_a_new_relative_host_without_a_second_relative_wait', () => {
  const h = fixture(), c = h.context;
  h.extraInventory = [relative(), unreadable({ProcessId: 8002, Name: 'certutil.exe'})];
  h.inventoryProvider = event => {
    if (event.pid === 8001 || event.pid === 8002) {
      h.extraInventory = [relative({ProcessId: 9001, CreationDate: '20261027100001.123456+000'})];
      return [];
    }
    return event.rows;
  };
  const text = owner(h);
  assert.strictEqual(shutdown(h), false); retained(h, text);
  assert.strictEqual(c.parallelRuntime.shutdownFullInventoryQueries, 2);
  assert.strictEqual(c.parallelRuntime.shutdownTargetedWorkerQueries, 2);
  assert.strictEqual(c.parallelRuntime.shutdownExpiredRows, 2);
  assert(!h.targetInventoryQueries.includes(9001));
  assert.strictEqual(h.sleeps.length, 0);
  return {full_inventories: 2, initial_rows_queried: 2, later_relative_pid_rejected_without_exact_wait: true};
});

test('fresh_barrier_rejects_a_current_root_child_created_before_relative_parent_exit', () => {
  const h = fixture(), c = h.context; h.extraInventory = [relative()]; const text = owner(h);
  query(h, 8001, () => {
    h.extraInventory = [relative({ProcessId: 9001, ParentProcessId: 8001,
      CreationDate: '20261027100001.123456+000', Name: 'lean.exe',
      CommandLine: 'lean.exe "' + c.root + '\\Review\\Single.lean"'})];
    return [];
  });
  assert.strictEqual(shutdown(h), false); retained(h, text);
  assert.strictEqual(c.parallelRuntime.shutdownFullInventoryQueries, 2);
  assert.strictEqual(c.parallelRuntime.shutdownTargetedWorkerQueries, 1);
  assert(!h.targetInventoryQueries.includes(9001));
  assert.strictEqual(h.sleeps.length, 0);
  return {full_inventories: 2, vanished_parent_worker_queries: 1, late_current_root_child_blocked: true};
});

test('fresh_barrier_unreadable_worker_uses_bounded_exact_query_without_third_census', () => {
  const h = fixture(), c = h.context; h.extraInventory = [relative()];
  h.inventoryProvider = event => {
    if (event.pid === 8001) {
      h.extraInventory = [unreadable({ProcessId: 9001, ParentProcessId: 8001,
        CreationDate: '20261027100001.123456+000', Name: 'certutil.exe'})];
      return [];
    }
    if (event.pid === 9001) return [];
    return event.rows;
  };
  assert.strictEqual(shutdown(h), true);
  assert.strictEqual(c.parallelRuntime.shutdownFullInventoryQueries, 2);
  assert.strictEqual(c.parallelRuntime.shutdownTargetedWorkerQueries, 2);
  assert.strictEqual(c.parallelRuntime.shutdownExpiredRows, 2);
  assert(c.parallelRuntime.shutdownInventoryAttempts <= 6);
  return {full_inventories: 2, exact_worker_queries: 2, shared_attempt_budget_preserved: true};
});

test('fresh_barrier_reappearance_of_previously_absent_identity_retains_lock', () => {
  const h = fixture(), c = h.context;
  const hashRow = unreadable({ProcessId: 8002, Name: 'certutil.exe'});
  h.extraInventory = [relative(), hashRow]; const text = owner(h);
  h.inventoryProvider = event => {
    if (event.pid === 8001 || event.pid === 8002) { h.extraInventory = [hashRow]; return []; }
    return event.rows;
  };
  assert.strictEqual(shutdown(h), false); retained(h, text);
  assert.strictEqual(c.parallelRuntime.shutdownFullInventoryQueries, 2);
  assert.strictEqual(c.parallelRuntime.shutdownTargetedWorkerQueries, 2);
  assert.strictEqual(h.targetInventoryQueries.filter(pid => pid === 8002).length, 1);
  assert.strictEqual(h.sleeps.length, 0);
  return {full_inventories: 2, reappeared_identity_not_reclassified_as_new_safe_row: true};
});

test('shared_64_row_budget_is_not_reset_for_fresh_barrier_unreadable_rows', () => {
  const h = fixture(), c = h.context;
  h.extraInventory = [relative()].concat(Array.from({length: 63}, (_, i) => unreadable({ProcessId: 8002 + i, Name: 'certutil.exe'})));
  const text = owner(h);
  h.inventoryProvider = event => {
    if (event.pid >= 8001 && event.pid <= 8064) {
      h.extraInventory = [unreadable({ProcessId: 9001, Name: 'certutil.exe'})];
      return [];
    }
    if (event.pid === 9001) return [];
    return event.rows;
  };
  assert.strictEqual(shutdown(h), false); retained(h, text);
  assert.strictEqual(c.parallelRuntime.shutdownFullInventoryQueries, 2);
  assert.strictEqual(c.parallelRuntime.shutdownTargetedWorkerQueries, 64);
  assert(!h.targetInventoryQueries.includes(9001));
  assert.strictEqual(h.sleeps.length, 0);
  return {initial_rows: 64, additional_barrier_row_rejected_before_query: true, full_inventories: 2};
});

test('simple_script_parser_distinguishes_actual_script_from_later_argument_text', () => {
  const h = fixture(), c = h.context;
  assert.strictEqual(typeof c.lockSimpleWshScriptArgument, 'function');
  const parse = command => c.lockSimpleWshScriptArgument({name: 'cscript.exe', command});
  const normal = parse(relative().CommandLine);
  assert(normal && normal.script === 'tools\\native_runner.js');
  const other = '"C:\\Windows\\System32\\cscript.exe" //nologo "E:\\OTHER\\tool.vbs" "tools\\native_runner.js"';
  const parsed = parse(other);
  assert(parsed && parsed.script === 'E:\\OTHER\\tool.vbs');
  h.extraInventory = [relative({CommandLine: other})];
  assert.strictEqual(shutdown(h), true);
  assert.strictEqual(c.parallelRuntime.shutdownTargetedWorkerQueries, 0);
  assert.strictEqual(c.parallelRuntime.shutdownFullInventoryQueries, 1);
  return {actual_script_token_used: true, later_runner_text_not_misclassified: true, no_unverified_relative_discharge: true};
});

test('unsupported_or_malformed_script_syntax_preserves_conservative_legacy_guard', () => {
  const variants = [
    ['unsupported_switch', '"C:\\Windows\\System32\\cscript.exe" //unknown "E:\\OTHER\\tool.vbs" tools\\native_runner.js'],
    ['mixed_quoted_token', '"C:\\Windows\\System32\\cscript.exe" "E:\\OTHER\\tool.vbs"suffix tools\\native_runner.js'],
    ['mismatched_host_name', '"C:\\Windows\\System32\\wscript.exe" "E:\\OTHER\\tool.vbs" tools\\native_runner.js'],
  ];
  for (const [name, command] of variants) {
    const h = fixture(), c = h.context; h.extraInventory = [relative({CommandLine: command})]; const text = owner(h);
    assert.strictEqual(c.lockSimpleWshScriptArgument({name: 'cscript.exe', command}), null, name);
    assert.strictEqual(shutdown(h), false, name); retained(h, text);
    assert.strictEqual(c.parallelRuntime.shutdownExpiredRows, 0, name);
    assert(c.parallelRuntime.shutdownFullInventoryQueries <= 2, name);
  }
  return {conservative_fallback_cases: variants.map(x => x[0]), malformed_tokens_never_assumed_foreign: true};
});

test('drive_relative_native_runner_script_remains_ambiguous', () => {
  const scripts = ['C:native_runner.js', 'c:NATIVE_RUNNER.JS'];
  for (const script of scripts) {
    const h = fixture(), c = h.context;
    const command = '"C:\\Windows\\System32\\cscript.exe" //nologo ' + script;
    h.extraInventory = [relative({CommandLine: command})]; const text = owner(h);
    const parsed = c.lockSimpleWshScriptArgument({name: 'cscript.exe', command});
    assert(parsed && parsed.script === script, script);
    assert.strictEqual(shutdown(h), false, script); retained(h, text);
    assert.strictEqual(c.parallelRuntime.shutdownInventoryAttempts, 6, script);
    assert.strictEqual(c.parallelRuntime.shutdownTargetedWorkerQueries, 6, script);
    assert.strictEqual(c.parallelRuntime.shutdownExpiredRows, 0, script);
  }
  return {drive_relative_scripts: scripts, no_absolute_or_foreign_workspace_assumption: true};
});

test('lock_owner_change_during_relative_absence_query_blocks_cleanup', () => {
  const h = fixture(), c = h.context; h.extraInventory = [relative()];
  const changedOwner = owner(h).replace('TOKEN=mock-owner-token-123456', 'TOKEN=mock-new-owner-654321');
  query(h, 8001, () => { h.memory.put(c.lockPath + '\\owner.txt', changedOwner); return []; });
  assert.strictEqual(shutdown(h), false); retained(h, changedOwner);
  assert.strictEqual(h.sleeps.length, 0);
  return {post_query_exact_owner_guard_preserved: true, changed_owner_lock_not_deleted: true};
});

test('combined_relative_and_unreadable_row_budget_is_bounded', () => {
  const h = fixture(), c = h.context;
  h.extraInventory = Array.from({length: 65}, (_, i) => i % 2 ? unreadable({ProcessId: 8001 + i}) : relative({ProcessId: 8001 + i}));
  const text = owner(h); assert.strictEqual(shutdown(h), false); retained(h, text);
  assert.strictEqual(c.parallelRuntime.shutdownTargetedWorkerQueries, 0);
  assert.strictEqual(h.sleeps.length, 0);
  return {initial_ambiguous_rows: 65, row_budget_rejected_before_worker_queries: true};
});

assert.strictEqual(sha256(fs.readFileSync(runner)), runnerSHA, 'candidate changed during test execution');
const report = {schema: 'RH_V0222_RELATIVE_SHUTDOWN_NODE_VM_REVIEW_V1', status: results.every(x => x.outcome === 'PASS') ? 'PASS' : 'FAIL',
  scope: 'NODE_VM_SYNTHETIC_HOST_ONLY', runner_sha256: runnerSHA,
  passed: results.filter(x => x.outcome === 'PASS').length, failed: results.filter(x => x.outcome === 'FAIL').length, cases: results,
  binding: {actual_assembled_runner_function_definitions: true, actual_runToFile_preserved: true, raw_shell_and_WMI_boundaries_simulated: true, whole_WSH_entry_point_executed: false, COM_setter_adaptations: setterCount},
  limitations: ['No Lean, Lake, Windows, WSH/COM, native WMI, C#, Wine or CI execution occurred.',
    'All process rows, native command outcomes, locks, clocks, receipts and compiler files are synthetic in memory.',
    'A vanished unresolved relative host requires one fresh barrier inventory; new unresolved relative hosts at that barrier do not get another relative-host wait.',
    'The at-most-two inventories are not an atomic Windows process census; no global process stability is asserted.',
    'Bounded attempts and scheduled sleeps do not impose a hard wall-clock limit on real WMI calls.',
    'The scenarios provide runtime-logic regression evidence, not a native runner PASS or mathematical proof certification.']};
fs.mkdirSync(path.dirname(path.resolve(args.report)), {recursive: true});
fs.writeFileSync(path.resolve(args.report), JSON.stringify(report, null, 2) + '\n');
console.log(JSON.stringify({status: report.status, passed: report.passed, failed: report.failed, runner_sha256: runnerSHA,
  failures: results.filter(x => x.outcome === 'FAIL').map(x => ({name: x.name, error: x.error})), report: path.resolve(args.report)}, null, 2));
process.exitCode = report.failed ? 1 : 0;
