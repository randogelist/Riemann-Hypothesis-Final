'use strict';
// Targeted Node VM / synthetic-host review. No native child process API.
const fs = require('fs');
const path = require('path');
const vm = require('vm');
const assert = require('assert');
const {MemoryWindowsFS, createHost, populateFixture, startup, buildAll, sha256} = require('./mock_host');
const {instrument} = require('./runtime_host');
const win = path.win32;
const candidate = path.resolve(process.argv[2] || path.join(__dirname, '../native_runner.js'));
const baseline = path.resolve(process.argv[3] || path.join(__dirname, 'fixtures/baseline_native_runner.js.txt'));
const reportPath = path.resolve(process.argv[4] || path.join(__dirname, 'profile_results.json'));
const fixtureDir = path.join(__dirname, 'fixtures');
const helperBytes = fs.readFileSync(path.join(fixtureDir, 'NativeSha256.cs.txt'));
const launcherBytes = fs.readFileSync(path.join(fixtureDir, 'baseline_run.cmd.txt'));
const candidateSHA = sha256(fs.readFileSync(candidate));
const storage = 'E:\\RH-FAST', workspaces = storage + '\\workspaces', cacheBase = storage + '\\anchors';
const suffix = '\\RH_HILBERT_LIMIT\\LOCAL_COMPILER\\lean-4.33.0';
const activeAnchors = cacheBase + suffix;
const versionRoot = workspaces + '\\RH_HILBERT_LIMIT_LEAN_v0_2_9_construction';
const previousRoot = 'C:\\Users\\Review\\Downloads\\RH_HILBERT_LIMIT_LEAN_v0_2_8_construction';
const results = [];

function test(name, action) {
  try {
    results.push({name, status: 'PASS', details: action() || null});
    process.stdout.write('PASS ' + name + '\n');
  } catch (e) {
    results.push({name, status: 'FAIL', error: e.message, stack: e.stack});
    process.stdout.write('FAIL ' + name + ': ' + e.message + '\n');
  }
}
function sharedStore() { return {entries: new Map(), dates: new Map(), nextDate: Date.UTC(2026, 9, 27, 19, 0), processes: []}; }
function setup(which = 'candidate', options = {}) {
  const root = options.root || (which === 'candidate' ? versionRoot : previousRoot);
  const shared = options.shared || sharedStore(), memory = new MemoryWindowsFS(root);
  memory.entries = shared.entries; memory.mkdir(root);
  // These fixtures name existing virtual drives; this does not probe real drives.
  for (const drive of ['C:\\', 'D:\\', 'E:\\', 'F:\\']) memory.mkdir(drive);
  const h = instrument(createHost(which === 'candidate' ? candidate : baseline, {memory,
    env: Object.assign({RH_HASH_MODE: 'AUTO', LEAN_JOBS: '7'}, options.env)}), {});
  h.shared = shared; h.which = which;
  if (which === 'candidate') assert.strictEqual(sha256(h.fullSource), candidateSHA);
  if (options.populate !== false) populateFixture(h);
  memory.put(root + '\\tools\\native_runner.js', h.fullSource);
  memory.put(root + '\\tools\\NativeSha256.cs', helperBytes);
  memory.put(root + '\\run.cmd', launcherBytes);
  for (const leaf of ['csc.exe', 'mscorlib.dll', 'System.dll', 'System.Core.dll', 'clr.dll']) {
    const file = win.dirname(h.csc) + '\\' + leaf;
    if (!memory.exists(file)) memory.put(file, 'MOCK installed framework ' + leaf);
  }
  if (options.start !== false) start(h);
  return h;
}
function start(h) {
  if (h.which === 'candidate') h.context.configurePersistentProfile();
  startup(h); return h;
}
function seed(which = 'baseline', options = {}) {
  const h = setup(which, options); buildAll(h);
  assert.strictEqual(h.context.failed, 0); assert.strictEqual(h.context.blocked, 0); return h;
}
function snapshot(memory, prefix) {
  const key = prefix ? memory.key(prefix) : null;
  return [...memory.entries].filter(([p]) => !key || p === key || p.startsWith(key + '\\'))
    .map(([p, entry]) => [p, entry.directory ? 'DIRECTORY' : sha256(entry.data)])
    .sort((a, b) => a[0].localeCompare(b[0]));
}
function receiptFiles(h, anchorRoot = h.context.anchorRoot, name) {
  const prefix = h.memory.key(anchorRoot) + '\\';
  return [...h.memory.entries.values()].filter(e => !e.directory && h.memory.key(e.path).startsWith(prefix) &&
    e.path.endsWith('\\receipt.txt') && /^MODULE=/m.test(h.memory.text(e.path)) &&
    (!name || /^MODULE=(.*)$/m.exec(h.memory.text(e.path))[1].trim() === name)).map(e => e.path).sort();
}
function output(h, name = 'Review.Base') { return h.context.work + '\\' + name.replace(/\./g, '\\') + '.olean'; }
function counts(h) {
  return {compiles: h.calls.filter(x => x.args.includes('-o')).length,
    audits: h.calls.filter(x => !x.args.includes('-o') && !x.args.some(y => /^--/.test(y))).length,
    copies: h.io.copies.length, csc: h.io.cscCalls};
}
function delta(after, before) { return Object.fromEntries(Object.keys(after).map(k => [k, after[k] - before[k]])); }
function samePath(h, a, b) { return h.memory.key(a) === h.memory.key(b); }
function identities(h) {
  const c = h.context;
  return {global: c.globalKey, legacy: c.legacyGlobalKey,
    helperInput: c.hasherInput(c.root + '\\tools\\NativeSha256.cs', h.csc).key,
    modules: Object.fromEntries(Array.from(c.ordered).map(name => [name, {
      input: c.moduleInput(name).key, artifact: c.artifactHashes[name],
      audit: c.auditKey(c.moduleKeys[name], c.artifactHashes[name], c.auditTargets[name], c.AUDIT_POLICY)
    }]))};
}
function argumentCollection(values) {
  function args(i) { return values[i]; }
  Object.defineProperty(args, 'length', {value: values.length});
  args.Count = values.length; args.Item = i => values[i]; return args;
}
function attachLockHost(h, pid) {
  const c = h.context, memory = h.memory, shared = h.shared;
  const getFolder = c.fso.GetFolder;
  c.fso.GetFolder = p => {
    const folder = getFolder(p), key = memory.key(p);
    if (!shared.dates.has(key)) shared.dates.set(key, shared.nextDate++);
    folder.DateCreated = new Date(shared.dates.get(key)); return folder;
  };
  c.fso.CreateFolder = p => {
    if (memory.directory(p) || memory.exists(p)) throw new Error('MOCK_ALREADY_EXISTS=' + p);
    memory.mkdir(p); shared.dates.set(memory.key(p), shared.nextDate++);
  };
  c.fso.MoveFolder = (src, dst) => {
    const key = memory.key(src), moved = [...shared.dates].filter(([p]) => p === key || p.startsWith(key + '\\'));
    memory.moveTree(src, dst);
    for (const [p, date] of moved) { shared.dates.delete(p); shared.dates.set(memory.key(dst) + p.slice(key.length), date); }
  };
  c.fso.DeleteFolder = p => {
    const key = memory.key(p); memory.removeFolder(p);
    for (const q of [...shared.dates.keys()]) if (q === key || q.startsWith(key + '\\')) shared.dates.delete(q);
  };
  const token = '12345-67890-12345-' + pid, script = c.root + '\\tools\\native_runner.js';
  const process = {ProcessId: pid, ParentProcessId: 0, Name: 'cscript.exe',
    CreationDate: '20261027190000.000000+000',
    CommandLine: '"C:\\Windows\\System32\\cscript.exe" //nologo //E:JScript "' + script + '" "--runner-token=' + token + '"'};
  shared.processes.push(process); h.self = process;
  c.GetObject = () => ({ExecQuery: () => shared.processes.slice()});
  c.WScript.ScriptFullName = script; c.WScript.FullName = 'C:\\Windows\\System32\\cscript.exe';
  c.WScript.Arguments = argumentCollection(['--runner-token=' + token]);
  c.WScript.Quit = code => { h.exitCode = code; };
  return h;
}
function executeMain(h) {
  const index = h.fullSource.indexOf('\nvar exitCode=1;'); assert(index >= 0);
  h.context.WScript.Quit = code => { h.exitCode = code; };
  vm.runInContext(h.fullSource.slice(index), h.context, {filename: candidate});
}

test('profile_accepts_only_proper_normalized_workspace_descendants', () => {
  const accepted = [versionRoot, 'e:\\rh-fast\\WORKSPACES\\MixedCase',
    workspaces + '\\nested\\version', workspaces + '\\space ! version',
    workspaces + '\\temporary\\..\\normalized', versionRoot + '\\'];
  const rejected = [workspaces, workspaces + '\\.', storage, 'E:\\',
    storage + '\\workspaces-old\\version', storage + '\\workspaces2\\version',
    storage + '\\workspace\\version', 'C:\\RH-FAST\\workspaces\\version',
    workspaces + '\\..\\outside', '\\\\server\\share\\RH-FAST\\workspaces\\version'];
  for (const root of accepted) {
    const h = setup('candidate', {root, start: false}), before = snapshot(h.memory);
    h.context.configurePersistentProfile();
    assert.strictEqual(h.values.LEAN_ANCHORINGS_ROOT, cacheBase);
    assert.strictEqual(h.context.persistentWorkspace, h.context.norm(h.context.root));
    assert.deepStrictEqual(snapshot(h.memory), before, 'configuration must not write files');
  }
  for (const root of rejected) {
    const h = setup('candidate', {root, start: false, env: {LEAN_ANCHORINGS_ROOT: 'D:\\PREVIOUS'}});
    const before = snapshot(h.memory), envBefore = JSON.stringify(h.values);
    assert.throws(() => h.context.configurePersistentProfile(), /PERSISTENT_WORKSPACE_REQUIRED/);
    assert.deepStrictEqual(snapshot(h.memory), before);
    assert.strictEqual(JSON.stringify(h.values), envBefore);
    assert.strictEqual(h.context.persistentProfileConfigured, false);
  }
  return {accepted, rejected, rejection_has_no_filesystem_or_environment_writes: true};
});

test('actual_main_rejects_wrong_location_before_lock_logs_or_native_host_calls', () => {
  const h = setup('candidate', {root: previousRoot, start: false, env: {LEAN_ANCHORINGS_ROOT: 'D:\\PREVIOUS'}}), c = h.context;
  for (const name of ['run-build.log', 'run-audit.log', 'run-result.json']) h.memory.put(c.root + '\\' + name, 'EXISTING ' + name);
  h.memory.put(c.lockPath + '\\owner.txt', 'EXISTING_LOCK_MUST_NOT_BE_TOUCHED');
  const before = snapshot(h.memory), envBefore = JSON.stringify(h.values);
  executeMain(h);
  assert.strictEqual(h.exitCode, 1); assert.strictEqual(c.lockHeld, false);
  assert(h.messages.some(x => x.includes('PERSISTENT_WORKSPACE_REQUIRED') && x.includes(workspaces)));
  assert.deepStrictEqual(snapshot(h.memory), before); assert.strictEqual(JSON.stringify(h.values), envBefore);
  assert.strictEqual(h.calls.length, 0); assert.strictEqual(h.hashes.length, 0); assert.strictEqual(h.io.batches.length, 0);
  return {actual_main_guard_exercised: true, files_logs_lock_environment_unchanged: true};
});

test('prior_override_and_existing_imports_are_retained_read_only_with_default_localappdata', () => {
  const prior = 'D:\\PreviousVerifiedAnchors', single = 'C:\\ImportedOne', multiple = 'F:\\ImportedTwo';
  const h = setup('candidate', {start: false, env: {
    LEAN_ANCHORINGS_ROOT: prior, LEAN_ANCHORINGS_IMPORT_ROOT: single,
    LEAN_ANCHORINGS_IMPORT_ROOTS: multiple + ';' + single
  }}), c = h.context;
  const oldDefault = h.values.LOCALAPPDATA + '\\LEAN_ANCHORINGS';
  for (const base of [prior, oldDefault, single, multiple]) h.memory.put(base + suffix + '\\READ_ONLY_SENTINEL.txt', 'OLD_ANCHOR_CONTENT');
  const before = Object.fromEntries([prior, oldDefault, single, multiple].map(p => [p, snapshot(h.memory, p)]));
  c.configurePersistentProfile();
  assert.strictEqual(c.persistentPriorAnchorRoot, prior);
  c.configurePersistentProfile(); assert.strictEqual(c.persistentPriorAnchorRoot, prior);
  start(h);
  const roots = Array.from(c.anchorRoots).map(p => h.memory.key(p));
  const expected = [activeAnchors, prior + suffix, oldDefault + suffix, single + suffix, multiple + suffix].map(p => h.memory.key(p));
  assert.deepStrictEqual(roots, expected);
  for (const p of Object.keys(before)) assert.deepStrictEqual(snapshot(h.memory, p), before[p]);
  assert.strictEqual(h.values.LEAN_ANCHORINGS_IMPORT_ROOT, single);
  assert.strictEqual(h.values.LEAN_ANCHORINGS_IMPORT_ROOTS, multiple + ';' + single);
  assert.strictEqual(h.values.LEAN_ANCHORINGS_ROOT, cacheBase);
  return {roots: Array.from(c.anchorRoots), prior_roots_unchanged: true, repeated_configuration_preserves_original_override: true};
});

test('existing_E_override_case_aliases_do_not_duplicate_active_anchor_root', () => {
  const h = setup('candidate', {start: false, env: {LEAN_ANCHORINGS_ROOT: 'e:\\rh-fast\\anchors\\.',
    LEAN_ANCHORINGS_IMPORT_ROOT: cacheBase, LEAN_ANCHORINGS_IMPORT_ROOTS: 'E:\\RH-FAST\\ANCHORS;'+cacheBase}});
  h.memory.mkdir(h.values.LOCALAPPDATA + '\\LEAN_ANCHORINGS' + suffix);
  start(h);
  const roots = Array.from(h.context.anchorRoots).map(p => h.memory.key(p));
  assert.strictEqual(new Set(roots).size, roots.length);
  assert.strictEqual(roots.filter(p => p === h.memory.key(activeAnchors)).length, 1);
  assert(roots.includes(h.memory.key(h.values.LOCALAPPDATA + '\\LEAN_ANCHORINGS' + suffix)));
  return {active_E_root_occurrences: 1, roots: Array.from(h.context.anchorRoots)};
});

test('profile_preserves_compiler_mathlib_jobs_and_all_compilation_audit_helper_identities', () => {
  const old = seed('baseline'), fresh = seed('candidate');
  assert.deepStrictEqual(identities(fresh), identities(old));
  for (const h of [old, fresh]) {
    assert.strictEqual(h.context.compiler, 'C:\\toolchain\\bin\\lean.exe');
    assert.strictEqual(h.values.MATHLIB_CACHE_ROOT, 'C:\\cache');
    assert.strictEqual(h.context.cacheRoot, 'C:\\cache');
    assert.strictEqual(h.values.LEAN_JOBS, '7'); assert.strictEqual(h.context.jobs, 7);
    assert.strictEqual(h.values.LEAN_NUM_THREADS, '7');
  }
  fresh.context.result(true, 'Synthetic profile integration only');
  const result = JSON.parse(fresh.memory.text(fresh.context.root + '\\run-result.json'));
  assert.strictEqual(result.persistent_storage_root, storage);
  assert.strictEqual(result.persistent_workspace, fresh.context.root);
  assert.strictEqual(result.persistent_project_cache, cacheBase);
  assert(samePath(fresh, fresh.context.work, versionRoot + '\\.native-build'));
  assert(fresh.context.activeHasher.exe.startsWith(activeAnchors + '\\hashers\\'));
  return {identities: identities(fresh), compiler_and_mathlib_remain_in_place: true,
    jobs: 7, helper_cached_under_E: true, actual_result_json_checked: true};
});

test('old_verified_anchors_migrate_to_E_without_compiling_then_warm_retains_work', () => {
  const outcomes = [];
  for (const prior of ['', 'D:\\PreviousExplicitAnchors']) {
    const env = prior ? {LEAN_ANCHORINGS_ROOT: prior} : {};
    const old = seed('baseline', {env}), oldAnchors = old.context.anchorRoot;
    const oldSnapshot = snapshot(old.memory, oldAnchors);
    const h = setup('candidate', {shared: old.shared, env}), before = counts(h);
    buildAll(h);
    assert.strictEqual(h.context.compiled, 0); assert.strictEqual(h.context.reused, 3);
    assert.strictEqual(receiptFiles(h).length, 3);
    assert.deepStrictEqual(snapshot(h.memory, oldAnchors), oldSnapshot);
    for (const p of receiptFiles(h)) {
      const r = h.context.parseReceipt(h.memory.text(p));
      assert(r.ORIGIN_RECEIPT.startsWith(oldAnchors + '\\'));
      h.context.verifyCurrent(r.MODULE, win.dirname(p), h.context.moduleInput(r.MODULE));
    }
    const warm = setup('candidate', {shared: old.shared, env, populate: false}), warmBefore = counts(warm);
    buildAll(warm);
    const warmCounts = delta(counts(warm), warmBefore);
    assert.strictEqual(warmCounts.compiles, 0); assert.strictEqual(warmCounts.audits, 0);
    assert.strictEqual(warmCounts.copies, 0); assert.strictEqual(warm.context.workingRetained, 3);
    assert.strictEqual(warm.context.helperCacheState, 'HIT');
    outcomes.push({prior: prior || 'default LOCALAPPDATA', migration: delta(counts(h), before),
      repeated_warm: warmCounts, old_anchor_bytes_preserved: true});
  }
  return outcomes;
});

test('corrupt_imported_anchor_is_rejected_before_migration_and_source_is_left_untouched', () => {
  const old = seed('baseline'), oldRoot = old.context.anchorRoot;
  const receipt = receiptFiles(old, oldRoot, 'Review.Base')[0], cached = win.dirname(receipt) + '\\artifacts\\Base.olean';
  old.memory.put(cached, 'CORRUPTED_OLD_ANCHOR');
  const prior = snapshot(old.memory, oldRoot), h = setup('candidate', {shared: old.shared}); buildAll(h);
  assert.strictEqual(h.context.buildStates['Review.Base'], 'COMPILED_AUDITED');
  assert.strictEqual(h.context.compiled, 1); assert(h.memory.text(output(h)).startsWith('MOCK_OLEAN'));
  assert.deepStrictEqual(snapshot(h.memory, oldRoot), prior);
  return {corrupt_old_anchor_rejected: true, fresh_mock_compile_for_base: 1, old_anchor_not_modified: true};
});

test('changed_source_and_transitive_dependency_invalidate_across_storage_migration', () => {
  const outcomes = [];
  for (const change of ['source', 'dependency']) {
    const old = seed('baseline'), h = setup('candidate', {shared: old.shared, start: false});
    if (change === 'source') {
      const p = h.context.root + '\\Review\\Base.lean'; h.memory.put(p, h.memory.text(p) + '\n-- source changed\n');
    } else h.memory.put('C:\\cache\\.lake\\packages\\mathlib\\.lake\\build\\lib\\lean\\Mathlib\\ReviewBase.olean', 'CHANGED_EXTERNAL_DEPENDENCY');
    start(h); buildAll(h);
    assert.strictEqual(h.context.compiled, change === 'source' ? 2 : 3);
    assert.strictEqual(h.context.failed, 0); assert.strictEqual(h.context.blocked, 0);
    outcomes.push({change, fresh_mock_compiles: h.context.compiled, frozen_reused: h.context.reused});
  }
  return outcomes;
});

test('different_E_workspaces_have_independent_work_locks_and_logs_with_shared_verified_anchors', () => {
  const shared = sharedStore(), first = setup('candidate', {shared, root: workspaces + '\\VersionA', start: false});
  first.context.configurePersistentProfile(); attachLockHost(first, 1001); first.context.acquireRunnerLock(); start(first); buildAll(first);
  const firstWork = snapshot(first.memory, first.context.work), firstOwner = first.memory.text(first.context.lockPath + '\\owner.txt');
  const second = setup('candidate', {shared, root: workspaces + '\\VersionB', start: false});
  second.context.configurePersistentProfile(); attachLockHost(second, 1002); second.context.acquireRunnerLock(); start(second); buildAll(second);
  assert.strictEqual(second.context.compiled, 0); assert.strictEqual(second.context.reused, 3);
  assert.notStrictEqual(first.context.work, second.context.work); assert.notStrictEqual(first.context.lockPath, second.context.lockPath);
  assert.notStrictEqual(first.context.logPath, second.context.logPath); assert.strictEqual(first.context.anchorRoot, second.context.anchorRoot);
  assert.deepStrictEqual(snapshot(first.memory, first.context.work), firstWork);
  assert.strictEqual(first.memory.text(first.context.lockPath + '\\owner.txt'), firstOwner);
  second.context.clearOutputs('Review.Base'); assert(first.memory.exists(output(first)));
  assert(!second.memory.exists(output(second)));
  first.context.releaseRunnerLock(); assert(second.memory.directory(second.context.lockPath));
  second.context.releaseRunnerLock();
  return {workspace_A: first.context.root, workspace_B: second.context.root,
    independent_work_lock_and_log_paths: true, shared_anchor_root: second.context.anchorRoot,
    second_workspace_mock_compiles: 0};
});

test('same_E_workspace_live_owner_and_existing_logs_survive_actual_main_attempt', () => {
  const shared = sharedStore(), owner = setup('candidate', {shared, start: false});
  owner.context.configurePersistentProfile(); attachLockHost(owner, 1001); owner.context.acquireRunnerLock();
  for (const leaf of ['run-build.log', 'run-audit.log', 'run-result.json']) owner.memory.put(owner.context.root + '\\' + leaf, 'LIVE_OWNER_' + leaf);
  const contender = setup('candidate', {shared, start: false, populate: false}); attachLockHost(contender, 1002);
  const before = snapshot(contender.memory); executeMain(contender);
  assert.strictEqual(contender.exitCode, 1); assert.strictEqual(contender.context.lockHeld, false);
  assert(contender.messages.some(x => /RUNNER_ACTIVE/.test(x)));
  assert.deepStrictEqual(snapshot(contender.memory), before);
  assert.strictEqual(contender.calls.length, 0); assert.strictEqual(contender.hashes.length, 0);
  owner.context.releaseRunnerLock();
  return {live_owner_preserved: true, original_logs_preserved: true, actual_main_guard_exercised: true};
});

test('unchanged_validation_hashing_lock_and_compiler_functions_match_v028_exactly', () => {
  const old = setup('baseline', {start: false}), fresh = setup('candidate', {start: false});
  const names = ['selectCompiler', 'makeGlobalKey', 'moduleInput', 'auditKey', 'readAnchorCore', 'verifyCurrent',
    'verifyLegacy', 'workingArtifactsMatch', 'restoreAnchor', 'saveAnchor', 'acceptRestored', 'processModuleBody',
    'processModule', 'freshHashSet', 'fileHash', 'certutilHashSet', 'batchHashes', 'parseBatchHashes',
    'hasherInput', 'prepareBatchHasher', 'recheckHasherInput', 'acquireRunnerLock', 'releaseRunnerLock',
    'lockSnapshot', 'lockLaunchToken', 'identifyLockSelf'];
  for (const name of names) assert.strictEqual(fresh.context[name].toString(), old.context[name].toString(), name + ' changed unexpectedly');
  return {functions_byte_equal_after_identical_COM_host_adaptation: names,
    prior_86_scenario_suites_not_rerun: true, targeted_profile_integration_executed: true};
});

assert.strictEqual(sha256(fs.readFileSync(candidate)), candidateSHA, 'candidate changed during profile review');
const report = {
  schema: 'RH_HILBERT_PERSISTENT_E_PROFILE_NODE_REVIEW_V029', runner_sha256: candidateSHA,
  baseline_runner_sha256: sha256(fs.readFileSync(baseline)), helper_source_sha256: sha256(helperBytes),
  launcher_fixture_sha256: sha256(launcherBytes), node_version: process.version,
  method: 'Actual runner functions and selected actual main guard paths in Node VM; Windows filesystem, WMI, certutil, helper and compiler responses are synthetic',
  native_windows_execution: false, lean_execution: false, lake_execution: false,
  csharp_compilation_or_execution: false, wine_execution: false, ci_execution: false, native_child_processes: 0,
  prior_unchanged_suites: 'Not rerun; listed validation/hash/lock/compiler functions compared exactly to v0.2.8 and profile integration tested directly.',
  limitations: ['No native E: drive, extraction, CMD/WSH, filesystem permissions or native timing validation.',
    'Synthetic artifacts and receipts are not proof certification or native PASS evidence.',
    'Wrong-root and same-root-owner main branches execute only against synthetic APIs and return before any simulated compiler operation.'],
  passed: results.filter(x => x.status === 'PASS').length, failed: results.filter(x => x.status === 'FAIL').length, results
};
fs.writeFileSync(reportPath, JSON.stringify(report, null, 2) + '\n');
process.stdout.write(JSON.stringify({passed: report.passed, failed: report.failed, runner_sha256: candidateSHA}) + '\n');
process.exitCode = report.failed ? 1 : 0;
