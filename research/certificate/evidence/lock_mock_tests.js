'use strict';
// Synthetic WSH/WMI/filesystem scenarios only. No Lean, Windows or native
// compiler executes. This harness never grants proof certification.
const fs = require('fs');
const path = require('path');
const vm = require('vm');
const Module = require('module');
const crypto = require('crypto');
const assert = require('assert');
const runnerPath = process.argv[2];
if (!runnerPath) throw new Error('Usage: node lock_mock_tests.js RUNNER.js [REPORT.json]');
const runnerText = fs.readFileSync(runnerPath, 'utf8');
const hostPath = path.join(__dirname, 'cache_mock_tests.js');
const hostSource = fs.readFileSync(hostPath, 'utf8');
const hostCut = hostSource.indexOf("scenario('save_restore_same_target_content_verified'");
if (hostCut < 0) throw new Error('Cannot locate synthetic-host declarations');
const hostModule = new Module(hostPath, module);
hostModule.filename = hostPath;
hostModule.paths = module.paths;
hostModule._compile(hostSource.slice(0, hostCut) + '\nmodule.exports = { setup, VirtualFiles };\n', hostPath);
const setupHost = hostModule.exports.setup;
const win = path.win32;
const sha = s => crypto.createHash('sha256').update(s).digest('hex');
const results = [];

function argumentCollection(values) {
  function args(i) { return values[i]; }
  Object.defineProperty(args, 'length', { value: values.length });
  args.Count = values.length;
  args.Item = i => values[i];
  return args;
}

function scenario(name, action) {
  try {
    const detail = action() || {};
    results.push({ name, outcome: 'PASS_MOCK_HOST', ...detail });
    console.log('PASS ' + name);
  } catch (e) {
    results.push({ name, outcome: 'FAIL', error: e.stack || String(e) });
    console.log('FAIL ' + name + ': ' + e.message);
  }
}

function rawProcess(pid, token, script, created, name) {
  return { ProcessId: pid, ParentProcessId: 0,
    CreationDate: created || '20261027170000.000000+000', Name: name || 'cscript.exe',
    CommandLine: '"C:\\Windows\\System32\\cscript.exe" //nologo //E:JScript "' + script + '" "--runner-token=' + token + '"' };
}

function fixture(options = {}) {
  const f = setupHost(), c = f.c;
  const shared = options.shared || { vfs: f.vfs, dates: new Map(), nextDate: Date.UTC(2026, 9, 27, 16, 0, 0) };
  f.shared = shared; f.vfs = shared.vfs;
  c.fso = f.vfs.fso();
  c.read = p => f.vfs.get(p).toString('utf8').replace(/^\uFEFF/, '');
  c.write = (p, s) => f.vfs.put(p, s);
  c.fileHash = p => sha(f.vfs.get(p));
  c.log = s => { f.logs.push(String(s)); c.append(c.logPath, String(s) + '\r\n'); };
  const originalGetFolder = c.fso.GetFolder;
  c.fso.GetFolder = p => {
    const folder = originalGetFolder(p), k = f.vfs.key(p);
    if (!shared.dates.has(k)) shared.dates.set(k, shared.nextDate++);
    folder.DateCreated = new Date(shared.dates.get(k));
    return folder;
  };
  c.fso.CreateFolder = p => {
    if (f.vfs.dirs.has(f.vfs.key(p)) || f.vfs.files.has(f.vfs.key(p))) throw new Error('MOCK_ALREADY_EXISTS=' + p);
    f.vfs.mkdir(p); shared.dates.set(f.vfs.key(p), shared.nextDate++);
  };
  c.fso.MoveFolder = (src, dest) => {
    if (f.beforeMove) f.beforeMove(src, dest);
    const sk = f.vfs.key(src), moved = [...shared.dates].filter(([k]) => k === sk || k.startsWith(sk + '\\'));
    f.vfs.moveFolder(src, dest);
    for (const [k] of moved) shared.dates.delete(k);
    for (const [k, d] of moved) shared.dates.set(f.vfs.key(dest) + k.slice(sk.length), d);
    if (f.afterMove) f.afterMove(src, dest);
  };
  c.fso.DeleteFolder = p => {
    const k = f.vfs.key(p);
    f.vfs.removeFolder(p);
    for (const q of [...shared.dates.keys()]) if (q === k || q.startsWith(k + '\\')) shared.dates.delete(q);
  };
  const pid = options.pid || 1001, token = options.token || ('12345-67890-12345-' + pid);
  f.self = rawProcess(pid, token, c.root + '\\tools\\native_runner.js', options.created);
  f.rows = [f.self]; f.wmiUnavailable = false;
  c.GetObject = () => {
    if (f.wmiUnavailable) throw new Error('SYNTHETIC_WMI_UNAVAILABLE');
    return { ExecQuery: () => {
      if (f.beforeQuery) f.beforeQuery();
      return f.rows.slice();
    } };
  };
  c.WScript.ScriptFullName = c.root + '\\tools\\native_runner.js';
  c.WScript.FullName = 'C:\\Windows\\System32\\cscript.exe';
  c.WScript.Arguments = argumentCollection(['--runner-token=' + token]);
  c.WScript.Quit = n => { f.exitCode = n; };
  f.token = token;
  f.ownerText = (owner = {}) => c.formatLockOwner({
    ROOT: c.keyPath(c.root), SCRIPT: c.keyPath(c.root + '\\tools\\native_runner.js'),
    PID: String(owner.pid || 999), CREATED: owner.created || '20261027160000.000000+000',
    TOKEN: owner.token || 'old-owner-token-999', RUN_TAG: owner.runTag || '20261027T160000Z-123456789'
  });
  f.seed = (text = f.ownerText()) => {
    if (!c.directory(c.lockPath)) c.fso.CreateFolder(c.lockPath);
    if (text !== null) c.write(c.lockPath + '\\owner.txt', text);
    return c.lockSnapshot();
  };
  f.currentOwner = () => c.read(c.lockPath + '\\owner.txt');
  f.acquire = () => c.acquireRunnerLock();
  f.release = () => c.releaseRunnerLock();
  f.sentinelLogs = () => {
    const sentinels = {};
    for (const leaf of ['run-build.log', 'run-audit.log', 'run-result.json', 'lean_version.log']) {
      const p = c.root + '\\' + leaf, content = 'SENTINEL:' + leaf + '\r\n';
      c.write(p, content); sentinels[p] = content;
    }
    return () => { for (const [p, text] of Object.entries(sentinels)) assert.equal(c.read(p), text); };
  };
  return f;
}

function expectBlocked(f, pattern) {
  const before = f.c.directory(f.c.lockPath) ? f.currentOwner() : null;
  const unchangedLogs = f.sentinelLogs();
  assert.throws(() => f.acquire(), pattern || /LOCK|RUNNER_ACTIVE/);
  assert.equal(f.c.lockHeld, false);
  if (before !== null) assert.equal(f.currentOwner(), before);
  unchangedLogs();
}

scenario('fresh_lock_publishes_complete_owner_and_releases_own_token', () => {
  const f = fixture(); f.acquire();
  assert.equal(f.c.lockHeld, true);
  const snap = f.c.lockSnapshot();
  assert.equal(snap.kind, 'OWNED_V1');
  assert.equal(snap.owner.PID, String(f.self.ProcessId));
  assert.equal(snap.owner.TOKEN, f.token);
  assert.equal(f.release(), true);
  assert(!f.c.directory(f.c.lockPath));
});

scenario('active_matching_pid_and_creation_blocks_without_touching_logs', () => {
  const f = fixture(); f.seed();
  f.rows.push(rawProcess(999, 'old-owner-token-999', f.c.root + '\\tools\\native_runner.js', '20261027160000.000000+000'));
  const owner = f.currentOwner(), unchanged = f.sentinelLogs();
  let nativeReached = false;
  f.c.selectCompiler = () => { nativeReached = true; throw new Error('Native compiler must not be reached'); };
  const start = runnerText.indexOf('\nvar exitCode=1;');
  vm.runInContext(runnerText.slice(start), f.c, { filename: runnerPath });
  assert.equal(f.exitCode, 1); assert.equal(nativeReached, false);
  assert.equal(f.currentOwner(), owner); unchanged();
  assert.equal(f.c.lockHeld, false);
});

scenario('dead_owner_recovered_with_retained_generation_record', () => {
  const f = fixture(), old = f.seed();
  f.acquire();
  assert.equal(f.c.lockHeld, true);
  assert.equal(f.c.lockRecovered, 1);
  const retired = f.c.root + '\\.native-stale-locks\\' + old.generation;
  assert.equal(f.c.read(retired + '\\owner.txt'), old.text);
  assert.notEqual(f.currentOwner(), old.text);
  f.release(); assert(f.c.directory(retired));
});

scenario('pid_reuse_with_different_creation_and_unrelated_process_allows_recovery', () => {
  const f = fixture(); f.seed();
  f.rows.push({ ProcessId: 999, ParentProcessId: 0, CreationDate: '20261027165000.000000+000', Name: 'notepad.exe', CommandLine: 'notepad.exe notes.txt' });
  f.acquire(); assert.equal(f.c.lockHeld, true); assert.equal(f.c.lockRecovered, 1);
});

scenario('pid_reuse_does_not_hide_a_related_active_worker', () => {
  const f = fixture(); f.seed();
  f.rows.push({ ProcessId: 999, ParentProcessId: 0, CreationDate: '20261027165000.000000+000', Name: 'lean.exe', CommandLine: 'lean.exe "' + f.c.root + '\\Audit.lean"' });
  expectBlocked(f, /RUNNER_ACTIVE/);
});

scenario('owner_pid_with_unknown_creation_identity_blocks', () => {
  const f = fixture(); f.seed();
  f.rows.push({ ProcessId: 999, ParentProcessId: 0, CreationDate: null, Name: 'notepad.exe', CommandLine: 'notepad.exe' });
  expectBlocked(f, /LOCK_STATE_UNKNOWN/);
});

scenario('wmi_unavailable_preserves_existing_lock_and_logs', () => {
  const f = fixture(); f.seed(); f.wmiUnavailable = true;
  expectBlocked(f, /LOCK_STATE_UNKNOWN/);
});

scenario('unreadable_relevant_process_commandline_blocks_recovery', () => {
  const f = fixture(); f.seed();
  f.rows.push({ ProcessId: 302, ParentProcessId: 0, CreationDate: '20261027165000.000000+000', Name: 'lean.exe', CommandLine: null });
  expectBlocked(f, /LOCK_STATE_UNKNOWN/);
});

scenario('blank_process_name_makes_inventory_unknown_and_blocks_recovery', () => {
  const f = fixture(); f.seed();
  f.rows.push({ ProcessId: 302, ParentProcessId: 0, CreationDate: '20261027165000.000000+000', Name: null, CommandLine: null });
  expectBlocked(f, /LOCK_STATE_UNKNOWN/);
});

scenario('malformed_owner_metadata_is_preserved', () => {
  const f = fixture(); f.c.mkdir(f.c.lockPath);
  f.c.write(f.c.lockPath + '\\owner.txt', 'SCHEMA=RH_HILBERT_RUN_LOCK_V1\nPID=999\n');
  expectBlocked(f, /LOCK_STATE_UNKNOWN/);
});

scenario('recognized_legacy_marker_recovers_only_when_no_workers_remain', () => {
  const f = fixture(); f.seed('20261027T153044Z-105463766\n');
  f.acquire(); assert.equal(f.c.lockRecovered, 1);
  assert(f.c.lockEvents.some(x => x === 'STALE_LOCK_RECOVERED=LEGACY_RUN_TAG'));
});

scenario('empty_legacy_lock_recovers_with_complete_absence_evidence', () => {
  const f = fixture(); f.seed(''); f.acquire();
  assert.equal(f.c.lockRecovered, 1);
  assert(f.c.lockEvents.some(x => x === 'STALE_LOCK_RECOVERED=LEGACY_EMPTY'));
});

scenario('initializing_legacy_owner_with_active_relative_script_is_not_reclaimed', () => {
  const f = fixture(); f.seed('');
  f.rows.push({ ProcessId: 302, ParentProcessId: 0, CreationDate: '20261027165000.000000+000', Name: 'cscript.exe', CommandLine: 'cscript.exe //nologo tools\\native_runner.js' });
  expectBlocked(f, /LOCK_STATE_UNKNOWN/);
});

scenario('ambiguous_relative_legacy_runner_blocks_recovery', () => {
  const f = fixture(); f.seed();
  f.rows.push({ ProcessId: 302, ParentProcessId: 0, CreationDate: '20261027165000.000000+000', Name: 'cscript.exe', CommandLine: 'cscript.exe //nologo "tools\\native_runner.js"' });
  expectBlocked(f, /LOCK_STATE_UNKNOWN/);
});

scenario('absolute_runner_in_other_package_does_not_block_recovery', () => {
  const f = fixture(); f.seed();
  f.rows.push(rawProcess(302, 'different-branch-token', 'C:\\OtherPackage\\tools\\native_runner.js'));
  f.acquire(); assert.equal(f.c.lockHeld, true);
});

scenario('later_parent_pid_reuse_within_same_millisecond_is_not_excluded', () => {
  const f = fixture({ created: '20261027170000.000100+000' }); f.seed();
  f.self.ParentProcessId = 302;
  f.rows.push({ ProcessId: 302, ParentProcessId: 0, CreationDate: '20261027170000.000900+000',
    Name: 'lean.exe', CommandLine: 'lean.exe "' + f.c.root + '\\Audit.lean"' });
  expectBlocked(f, /RUNNER_ACTIVE/);
});

scenario('idle_persistent_cmd_k_shell_does_not_block_recovery', () => {
  const f = fixture(); f.seed();
  f.rows.push({ ProcessId: 302, ParentProcessId: 0, CreationDate: '20261027165000.000000+000', Name: 'cmd.exe', CommandLine: 'cmd.exe /k call "' + f.c.root + '\\run.cmd"' });
  f.acquire(); assert.equal(f.c.lockHeld, true);
});

scenario('existing_deterministic_tombstone_prevents_second_reclamation', () => {
  const f = fixture(), snapshot = f.seed();
  f.c.mkdir(f.c.root + '\\.native-stale-locks\\' + snapshot.generation);
  expectBlocked(f, /RUNNER_LOCK_RECOVERY_RACE/);
});

scenario('post_rename_generation_mismatch_preserves_quarantine_without_ownership', () => {
  const f = fixture(), snapshot = f.seed();
  const foreign = f.ownerText({ pid: 701, token: 'foreign-owner-701' });
  f.beforeMove = (src, dst) => {
    if (src === f.c.lockPath && dst.includes('\\.native-stale-locks\\')) {
      f.beforeMove = null; f.c.write(src + '\\owner.txt', foreign);
    }
  };
  assert.throws(() => f.acquire(), /LOCK_STATE_UNKNOWN/);
  assert.equal(f.c.lockHeld, false); assert(!f.c.directory(f.c.lockPath));
  const retired = f.c.root + '\\.native-stale-locks\\' + snapshot.generation;
  assert.equal(f.c.read(retired + '\\owner.txt'), foreign);
});

scenario('post_rename_mismatch_does_not_delete_newly_published_foreign_lock', () => {
  const f = fixture(); f.seed();
  const foreign = f.ownerText({ pid: 701, token: 'foreign-owner-701' });
  f.afterMove = (src, dst) => {
    if (src === f.c.lockPath && dst.includes('\\.native-stale-locks\\')) {
      f.afterMove = null;
      f.c.write(dst + '\\owner.txt', f.ownerText({ pid: 702, token: 'moved-owner-702' }));
      f.c.mkdir(f.c.lockPath); f.c.write(f.c.lockPath + '\\owner.txt', foreign);
    }
  };
  assert.throws(() => f.acquire(), /LOCK_STATE_UNKNOWN/);
  assert.equal(f.c.lockHeld, false); assert.equal(f.currentOwner(), foreign);
});

scenario('two_validated_reclaimers_cannot_remove_winners_replacement_lock', () => {
  const a = fixture({ pid: 1001 });
  // Rebind B to the same filesystem while retaining an independent VM/global state.
  const second = fixture({ pid: 1002, shared: a.shared });
  a.seed();
  // Each synthetic inventory represents its completed validation snapshot;
  // force the delayed filesystem interleaving independently of WMI timing.
  a.beforeMove = (src, dst) => {
    if (src === a.c.lockPath && dst.includes('\\.native-stale-locks\\')) {
      a.beforeMove = null; second.acquire();
    }
  };
  assert.throws(() => a.acquire(), /RUNNER_LOCK_RECOVERY_RACE/);
  assert.equal(a.c.lockHeld, false); assert.equal(second.c.lockHeld, true);
  assert.equal(a.currentOwner(), second.c.lockOwnerText);
  assert.equal(a.release(), false); assert.equal(a.currentOwner(), second.c.lockOwnerText);
});

scenario('fresh_contender_winning_publication_gap_keeps_its_lock', () => {
  const a = fixture({ pid: 1001 }), b = fixture({ pid: 1002, shared: a.shared });
  a.seed();
  a.afterMove = (src, dst) => {
    if (src === a.c.lockPath && dst.includes('\\.native-stale-locks\\')) {
      a.afterMove = null; b.acquire();
    }
  };
  assert.throws(() => a.acquire(), /RUNNER_LOCK_BUSY/);
  assert.equal(a.c.lockHeld, false); assert.equal(b.c.lockHeld, true);
  assert.equal(a.currentOwner(), b.c.lockOwnerText);
});

scenario('cleanup_refuses_to_delete_a_changed_owner_token', () => {
  const f = fixture(); f.acquire();
  const foreign = f.ownerText({ pid: 701, token: 'foreign-owner-701' });
  f.c.write(f.c.lockPath + '\\owner.txt', foreign);
  assert.equal(f.release(), false); assert.equal(f.currentOwner(), foreign);
  assert.equal(f.c.lockHeld, false);
});

scenario('duplicate_self_token_process_identity_is_ambiguous', () => {
  const f = fixture(); f.seed();
  f.rows.push(rawProcess(1002, f.token, f.c.root + '\\tools\\native_runner.js'));
  expectBlocked(f, /LOCK_STATE_UNKNOWN/);
});

scenario('missing_launch_token_is_rejected_without_lock_change', () => {
  const f = fixture(); f.seed(); f.c.WScript.Arguments = argumentCollection([]);
  expectBlocked(f, /LOCK_STATE_UNKNOWN/);
});

const report = {
  harness: 'RH_HILBERT_LOCK_MOCK_HOST_QA_V1', runner: runnerPath, runner_sha256: sha(runnerText),
  native_windows_execution: false, lean_execution: false, process_inventory: 'SYNTHETIC_WMI_ONLY',
  proof_certification: 'NONE', passed: results.filter(x => x.outcome === 'PASS_MOCK_HOST').length,
  failed: results.filter(x => x.outcome === 'FAIL').length, results
};
if (process.argv[3]) fs.writeFileSync(process.argv[3], JSON.stringify(report, null, 2) + '\n');
console.log(JSON.stringify({ passed: report.passed, failed: report.failed, native_windows_execution: false, lean_execution: false }));
if (report.failed) process.exitCode = 1;
