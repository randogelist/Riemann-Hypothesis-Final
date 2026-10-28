'use strict';
// Independent read-only observer QA. WSH, WMI, ADODB, filesystem and time are
// synthetic. No native executable, Windows CMD or Lean compiler executes.
const fs = require('fs');
const path = require('path');
const vm = require('vm');
const crypto = require('crypto');
const assert = require('assert');
const win = path.win32;
const sourcePath = process.argv[2], reportPath = process.argv[3];
if (!sourcePath) throw new Error('Usage: node follow_mock_tests.js FOLLOW.js [REPORT.json]');
const source = fs.readFileSync(sourcePath, 'utf8');
const marker = source.indexOf('// FOLLOW_MAIN_ENTRY');
assert(marker >= 0, 'Missing safe definition/main boundary');
const sha = x => crypto.createHash('sha256').update(x).digest('hex');
const target = 'C:\\Users\\Simon\\Downloads\\RH_HILBERT_LIMIT_LEAN_v0_2_5_construction';
const targetScript = target + '\\tools\\native_runner.js';
const logFile = target + '\\run-build.log';
const ownerFile = target + '\\.native-run.lock\\owner.txt';
const token = '11111-22222-33333-44444';
const created = '20261027170000.000123+000';
const results = [];
const normalize = p => win.normalize(p).toLowerCase().replace(/\\+$/, '');
function argsCollection(values) {
  function args(i) { return values[i]; }
  Object.defineProperty(args, 'length', { value: values.length });
  args.Item = i => values[i]; args.Count = values.length; return args;
}
function ownerText(fields = {}) {
  const o = { ROOT: normalize(target), SCRIPT: normalize(targetScript), PID: '24284', CREATED: created, TOKEN: token, RUN_TAG: '20261027T170000Z-123456789', ...fields };
  return 'SCHEMA=RH_HILBERT_RUN_LOCK_V1\nROOT=' + o.ROOT + '\nSCRIPT=' + o.SCRIPT + '\nPID=' + o.PID + '\nCREATED=' + o.CREATED + '\nTOKEN=' + o.TOKEN + '\nRUN_TAG=' + o.RUN_TAG + '\n';
}
function ownerProcess(fields = {}) {
  return { ProcessId: 24284, ParentProcessId: 100, CreationDate: created, Name: 'cscript.exe',
    CommandLine: '"C:\\Windows\\System32\\cscript.exe" //nologo //E:JScript "' + targetScript + '" "--runner-token=' + token + '"', ...fields };
}

function fixture(options = {}) {
  const f = { files: new Map(), folders: new Map(), reads: [], mutations: [], nativeCalls: [], outputs: [], processes: [ownerProcess()], ticks: 0,
    queries: 0, maxSleeps: 12, wmiUnavailable: false, readErrors: new Map(), transitions: {}, initialLog: 'RUNNER_LOCK=OWNED_PID_24284\r\nCOMPILE_START=Fixture.One\r\n' };
  f.mkdir = p => { const q = win.normalize(p), parent = win.dirname(q); if (parent !== q && !f.folders.has(normalize(parent))) f.mkdir(parent); f.folders.set(normalize(q), q); };
  f.put = (p, text) => { f.mkdir(win.dirname(p)); f.files.set(normalize(p), { path: win.normalize(p), text }); };
  f.removeLock = () => { f.files.delete(normalize(ownerFile)); f.folders.delete(normalize(win.dirname(ownerFile))); };
  f.read = p => {
    const k = normalize(p); f.reads.push(win.normalize(p));
    if (f.onRead) f.onRead(p);
    const failures = f.readErrors.get(k) || 0;
    if (failures > 0) { f.readErrors.set(k, failures - 1); throw new Error('SYNTHETIC_SHARING_OR_REWRITE_RACE'); }
    const file = f.files.get(k); if (!file) throw new Error('SYNTHETIC_FILE_MISSING=' + p);
    return file.text;
  };
  f.put(targetScript, 'SYNTHETIC_SOURCE_NOT_EXECUTED');
  f.put(ownerFile, ownerText());
  f.put(logFile, f.initialLog);
  f.put(target + '\\run-result.json', '{"package":"older-run","build":"PASS","axiom_audit":"PASS","time_utc":"old"}');
  const denyMutation = name => function () { f.mutations.push(name); throw new Error('READ_ONLY_VIOLATION=' + name); };
  const fso = {
    GetAbsolutePathName: p => win.resolve('C:\\Observer', String(p)),
    GetParentFolderName: p => win.dirname(p), GetFileName: p => win.basename(p),
    FileExists: p => f.files.has(normalize(p)), FolderExists: p => f.folders.has(normalize(p)),
    GetFile: p => ({ Path: p, Size: Buffer.byteLength(f.read(p), 'utf8'), DateCreated: new Date('2026-10-27T17:00:00Z'), DateLastModified: new Date('2026-10-27T17:00:01Z') }),
    GetFolder: p => {
      if (f.beforeGetFolder) f.beforeGetFolder(p);
      const k = normalize(p); if (!f.folders.has(k)) throw new Error('SYNTHETIC_FOLDER_MISSING');
      return { Path: p, DateCreated: new Date('2026-10-27T17:00:00Z'),
        Files: [...f.files.values()].filter(v => normalize(win.dirname(v.path)) === k).map(v => ({ Path: v.path })),
        SubFolders: [...f.folders.values()].filter(v => normalize(v) !== k && normalize(win.dirname(v)) === k).map(v => ({ Path: v })) };
    },
    OpenTextFile: (p, mode) => {
      if (mode !== 1) return denyMutation('OpenTextFile_WRITE')();
      const text = f.read(p); return { ReadAll: () => text, Close: () => {} };
    }
  };
  for (const name of ['CreateFolder', 'DeleteFolder', 'MoveFolder', 'CopyFolder', 'CreateTextFile', 'DeleteFile', 'MoveFile', 'CopyFile']) fso[name] = denyMutation(name);
  const shell = { Run: (...args) => { f.nativeCalls.push(args); throw new Error('NATIVE_RUN_FORBIDDEN'); }, Exec: (...args) => { f.nativeCalls.push(args); throw new Error('NATIVE_EXEC_FORBIDDEN'); } };
  function Stream() {
    let text = '', offset = 0;
    this.Open = () => {}; this.Close = () => {};
    this.LoadFromFile = p => { text = f.read(p); offset = 0; };
    this.ReadText = count => {
      const out = count === undefined || count < 0 ? text.slice(offset) : text.slice(offset, offset + count);
      offset += out.length; return out;
    };
    this.WriteText = denyMutation('ADODB.WriteText'); this.SaveToFile = denyMutation('ADODB.SaveToFile');
  }
  const sandbox = {
    ActiveXObject: function (name) {
      if (name === 'Scripting.FileSystemObject') return fso;
      if (name === 'ADODB.Stream') return new Stream();
      if (name === 'WScript.Shell') return shell;
      throw new Error('UNEXPECTED_ACTIVEX=' + name);
    },
    GetObject: () => {
      if (f.wmiUnavailable) throw new Error('SYNTHETIC_WMI_UNAVAILABLE');
      return { ExecQuery: query => {
        if (++f.queries > 100) throw new Error('SYNTHETIC_QUERY_LIMIT');
        const match = /WHERE\s+ProcessId\s*=\s*'?([0-9]+)'?/i.exec(query);
        return match ? f.processes.filter(p => Number(p.ProcessId) === Number(match[1])) : f.processes.slice();
      } };
    },
    Enumerator: function (items) { let i = 0; this.atEnd = () => i >= items.length; this.item = () => items[i]; this.moveNext = () => { i++; }; },
    WScript: {
      Arguments: argsCollection(options.args || [target]),
      ScriptFullName: 'C:\\Observer\\tools\\follow_active.js',
      FullName: 'C:\\Windows\\System32\\cscript.exe',
      Echo: s => f.outputs.push(String(s)),
      Sleep: ms => {
        assert(ms > 0 && ms <= 10000, 'Observer must use bounded polling intervals');
        if (++f.ticks > f.maxSleeps) throw new Error('SYNTHETIC_SLEEP_LIMIT');
        if (f.transitions[f.ticks]) f.transitions[f.ticks](f);
      },
      Quit: n => { f.code = n; }
    }
  };
  f.context = vm.createContext(sandbox);
  vm.runInContext(source.slice(0, marker), f.context, { filename: sourcePath });
  f.run = () => { vm.runInContext(source.slice(marker), f.context, { filename: sourcePath }); return f.code; };
  f.noSideEffects = () => {
    assert.equal(f.mutations.length, 0); assert.equal(f.nativeCalls.length, 0);
    assert(!f.reads.some(p => /run-result\.json$/i.test(p)), 'Unbound legacy result must not be consumed');
    assert(!f.outputs.some(s => /^(?:RUN|PROJECT_BUILD|AXIOM_AUDIT)=PASS(?:\s|$)/m.test(s)), 'Observer must not emit a worker PASS as its own status');
  };
  return f;
}

function status(f, value) { assert(f.outputs.some(s => s === 'FOLLOW_STATUS=' + value), 'Missing FOLLOW_STATUS=' + value + ': ' + f.outputs.join('\n')); }
function scenario(name, action) {
  try { const detail = action() || {}; results.push({ name, outcome: 'PASS_SYNTHETIC_OBSERVER', ...detail }); console.log('PASS ' + name); }
  catch (e) { results.push({ name, outcome: 'FAIL', error: e.stack || String(e) }); console.log('FAIL ' + name + ': ' + e.message); }
}

scenario('live_owner_log_growth_is_displayed_without_build_or_mutation', () => {
  const f = fixture();
  f.transitions[1] = () => f.put(logFile, f.initialLog + 'AXIOM_AUDIT_START=Fixture.One\r\n');
  f.transitions[2] = () => f.put(logFile, f.initialLog + 'AXIOM_AUDIT_START=Fixture.One\r\nCOMPILE_AND_AXIOM_AUDIT_PASS=Fixture.One\r\n');
  f.transitions[3] = () => { f.processes = []; };
  assert.equal(f.run(), 0); status(f, 'ATTACHED'); status(f, 'OWNER_EXITED');
  assert(f.outputs.some(s => s === '[FOLLOW_LOG_NEW] AXIOM_AUDIT_START=Fixture.One'));
  assert(f.outputs.some(s => s === '[FOLLOW_LOG_NEW] COMPILE_AND_AXIOM_AUDIT_PASS=Fixture.One'));
  assert(f.outputs.includes('FOLLOW_BUILD_RESULT=NOT_CERTIFIED')); f.noSideEffects();
});

scenario('old_pass_text_and_result_never_become_observer_certification', () => {
  const f = fixture(); f.put(logFile, 'RUNNER_LOCK=OWNED_PID_24284\r\nPROJECT_BUILD=PASS\r\nRUN=PASS\r\n');
  f.transitions[1] = () => { f.processes = []; };
  assert.equal(f.run(), 0); status(f, 'OWNER_EXITED'); f.noSideEffects();
  assert(f.outputs.some(s => s === '[FOLLOW_LOG_SNAPSHOT] RUN=PASS'));
});

scenario('no_existing_owner_returns_without_starting_any_worker', () => {
  const f = fixture(); f.removeLock();
  assert.equal(f.run(), 0); status(f, 'NO_ACTIVE_OWNER'); assert.equal(f.ticks, 0); f.noSideEffects();
});

scenario('pid_reuse_stops_observing_the_original_owner', () => {
  const f = fixture();
  f.transitions[1] = () => { f.processes = [ownerProcess({ CreationDate: '20261027180000.000123+000', Name: 'notepad.exe', CommandLine: 'notepad.exe' })]; };
  assert.equal(f.run(), 0); status(f, 'OWNER_PID_REUSED'); assert.equal(f.ticks, 1); f.noSideEffects();
});

scenario('replacement_owner_is_not_automatically_followed', () => {
  const f = fixture();
  f.transitions[1] = () => f.put(ownerFile, ownerText({ PID: '25285', TOKEN: 'another-worker-token' }));
  assert.equal(f.run(), 0); status(f, 'OWNER_CHANGED'); assert.equal(f.ticks, 1); f.noSideEffects();
});

scenario('wmi_failure_is_uncertain_and_read_only', () => {
  const f = fixture(); f.wmiUnavailable = true;
  assert.equal(f.run(), 2); status(f, 'UNCERTAIN'); f.noSideEffects();
});

scenario('malformed_owner_metadata_is_not_followed_or_recovered', () => {
  const f = fixture(); f.put(ownerFile, 'SCHEMA=UNKNOWN\nPID=24284\n');
  assert.equal(f.run(), 2); status(f, 'UNCERTAIN'); f.noSideEffects();
});

scenario('transient_read_error_and_partial_line_retry_preserve_complete_output', () => {
  const f = fixture(); f.put(logFile, f.initialLog + 'COMPILE_START=Part');
  f.transitions[1] = () => { f.readErrors.set(normalize(logFile), 1); };
  f.transitions[2] = () => f.put(logFile, f.initialLog + 'COMPILE_START=Partial\r\n');
  f.transitions[3] = () => { f.processes = []; };
  assert.equal(f.run(), 0); status(f, 'OWNER_EXITED'); f.noSideEffects();
  assert(!f.outputs.some(s => /\] COMPILE_START=Part$/.test(s)));
  assert(f.outputs.some(s => s === '[FOLLOW_LOG_NEW] COMPILE_START=Partial'));
});

scenario('shrinking_mismatched_log_sample_is_not_treated_as_completion', () => {
  const f = fixture();
  f.transitions[1] = () => f.put(logFile, 'RUN=PASS\r\n');
  f.transitions[2] = () => f.put(logFile, f.initialLog + 'AXIOM_AUDIT_START=Fixture.One\r\n');
  f.transitions[3] = () => { f.processes = []; };
  assert.equal(f.run(), 0); status(f, 'OWNER_EXITED'); f.noSideEffects();
  assert(!f.outputs.some(s => /\] RUN=PASS$/.test(s)));
  assert(f.outputs.some(s => s === '[FOLLOW_LOG_NEW] AXIOM_AUDIT_START=Fixture.One'));
});

scenario('removed_owner_lock_ends_observation_without_reacquiring', () => {
  const f = fixture(); f.transitions[1] = () => f.removeLock();
  assert.equal(f.run(), 0); status(f, 'OWNER_LOCK_REMOVED'); f.noSideEffects();
});

scenario('relative_target_is_rejected_without_process_or_file_changes', () => {
  const f = fixture({ args: ['relative\\package'] });
  assert.equal(f.run(), 2); status(f, 'INVALID_ARGUMENTS'); f.noSideEffects();
});

scenario('missing_target_directory_is_reported_without_starting_a_worker', () => {
  const f = fixture({ args: ['C:\\MissingPackage'] });
  assert.equal(f.run(), 2); status(f, 'TARGET_NOT_FOUND'); f.noSideEffects();
});

scenario('active_pid_with_unreadable_creation_is_uncertain', () => {
  const f = fixture(); f.processes[0].CreationDate = null;
  assert.equal(f.run(), 2); status(f, 'UNCERTAIN'); f.noSideEffects();
});

scenario('final_error_appended_before_owner_exit_is_still_displayed', () => {
  const f = fixture();
  f.transitions[1] = () => {
    f.put(logFile, f.initialLog + 'COMPILE_FAIL=Fixture.One\r\nPROJECT_BUILD=FAIL\r\nRUN=FAIL\r\n');
    f.processes = [];
  };
  assert.equal(f.run(), 0); status(f, 'OWNER_EXITED'); f.noSideEffects();
  assert(f.outputs.some(s => s === '[FOLLOW_LOG_NEW] COMPILE_FAIL=Fixture.One'));
  assert(f.outputs.some(s => s === '[FOLLOW_LOG_NEW] RUN=FAIL'));
});

scenario('final_pass_appended_before_lock_release_remains_prefixed_observation', () => {
  const f = fixture();
  f.transitions[1] = () => {
    f.put(logFile, f.initialLog + 'PROJECT_BUILD=PASS\r\nRUN=PASS\r\n');
    f.removeLock();
  };
  assert.equal(f.run(), 0); status(f, 'OWNER_LOCK_REMOVED'); f.noSideEffects();
  assert(f.outputs.some(s => s === '[FOLLOW_LOG_NEW] RUN=PASS'));
  assert(f.outputs.includes('FOLLOW_BUILD_RESULT=NOT_CERTIFIED'));
});

scenario('initial_finished_state_displays_historical_tail_as_explicitly_unbound', () => {
  const f = fixture(); f.removeLock();
  const lines = Array.from({ length: 30 }, (_, i) => 'HISTORICAL_LINE_' + i).concat(['RUN=PASS']);
  f.put(logFile, lines.join('\r\n') + '\r\n');
  assert.equal(f.run(), 0); status(f, 'NO_ACTIVE_OWNER'); f.noSideEffects();
  const historical = f.outputs.filter(s => s.startsWith('[EXISTING_LOG_UNBOUND] '));
  assert.equal(historical.length, 25);
  assert.equal(historical.at(-1), '[EXISTING_LOG_UNBOUND] RUN=PASS');
  assert(!historical.some(s => s === '[EXISTING_LOG_UNBOUND] HISTORICAL_LINE_0'));
  assert(f.outputs.includes('FOLLOW_BUILD_RESULT=NOT_CERTIFIED'));
});

scenario('lock_disappearing_between_folder_exists_and_getfolder_is_not_false_uncertainty', () => {
  const f = fixture();
  f.beforeGetFolder = p => {
    if (normalize(p) === normalize(win.dirname(ownerFile))) {
      f.beforeGetFolder = null; f.removeLock();
    }
  };
  assert.equal(f.run(), 0); status(f, 'NO_ACTIVE_OWNER'); f.noSideEffects();
  assert(!f.outputs.includes('FOLLOW_STATUS=UNCERTAIN'));
});

scenario('terminal_log_sample_is_not_emitted_if_a_successor_takes_ownership_during_read', () => {
  const f = fixture();
  f.transitions[1] = () => {
    f.processes = [];
    f.put(logFile, f.initialLog + 'SUCCESSOR_ONLY_TEXT\r\n');
    f.onRead = p => {
      if (normalize(p) === normalize(logFile)) {
        f.onRead = null; f.put(ownerFile, ownerText({ PID: '25285', TOKEN: 'successor-worker-token' }));
      }
    };
  };
  assert.equal(f.run(), 0); f.noSideEffects();
  assert(!f.outputs.some(s => s.includes('SUCCESSOR_ONLY_TEXT')));
  assert.equal(f.files.get(normalize(ownerFile)).text, ownerText({ PID: '25285', TOKEN: 'successor-worker-token' }));
});

// Static control-flow review of the sole CMD dispatcher: follow and usage
// terminate explicitly; the default native body retains its published bytes.
let wrapperReview = null;
const wrapperPath = path.resolve(path.dirname(sourcePath), '..', 'run.cmd');
if (fs.existsSync(wrapperPath)) {
  const wrapper = fs.readFileSync(wrapperPath, 'utf8');
  scenario('wrapper_follow_dispatch_has_no_fallthrough_into_native_build', () => {
    const lines = wrapper.replace(/\r\n/g, '\n').split('\n');
    const dispatch = lines.indexOf('if /i "%~1"=="--follow-root" goto follow_existing');
    const native = lines.findIndex(s => /cscript\.exe.*native_runner\.js/.test(s));
    const label = lines.indexOf(':follow_existing'), usage = lines.indexOf(':usage');
    assert(dispatch >= 0 && dispatch < native && native < label && label < usage);
    const defaultBody = lines.slice(0, label).filter(s => s !== 'if /i "%~1"=="--follow-root" goto follow_existing' && s !== 'if not "%~1"=="" goto usage').join('\n').trim();
    const baselinePath = path.resolve('hilbert_current_v025/extracted/RH_HILBERT_LIMIT_LEAN_v0_2_5_construction/run.cmd');
    const baseline = fs.readFileSync(baselinePath, 'utf8').replace(/\r\n/g, '\n').trim();
    assert.equal(defaultBody, baseline);
    const follow = lines.slice(label + 1, usage).join('\n');
    assert(/follow_active\.js" "%~f2"/.test(follow));
    assert(!/native_runner\.js|pushd|taskkill|del\s|rmdir/i.test(follow));
    assert(follow.trim().endsWith('endlocal & exit /b %RH_HILBERT_RUN_EXIT%'));
    assert(lines.slice(usage + 1).join('\n').trim().endsWith('exit /b 64'));
    wrapperReview = { wrapper: wrapperPath, wrapper_sha256: sha(wrapper), default_native_body_byte_equivalent_after_line_ending_normalization: true, follow_dispatch_returns_before_native_path: true };
  });
}

const report = {
  harness: 'RH_HILBERT_READ_ONLY_FOLLOW_MOCK_QA_V1', follower: sourcePath, follower_sha256: sha(source),
  native_windows_execution: false, lean_execution: false, proof_certification: 'NONE',
  filesystem_process_time: 'SYNTHETIC_READ_ONLY_WSH_WMI_ADODB', wrapper_review: wrapperReview,
  passed: results.filter(x => x.outcome === 'PASS_SYNTHETIC_OBSERVER').length,
  failed: results.filter(x => x.outcome === 'FAIL').length, results
};
if (reportPath) fs.writeFileSync(reportPath, JSON.stringify(report, null, 2) + '\n');
console.log(JSON.stringify({ passed: report.passed, failed: report.failed, native_windows_execution: false, lean_execution: false }));
if (report.failed) process.exitCode = 1;
