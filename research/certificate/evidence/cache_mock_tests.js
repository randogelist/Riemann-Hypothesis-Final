'use strict';
// Focused behavioral QA for the Windows runner. All files, compilers and audit
// responses in this harness are synthetic. This is NOT Lean/build evidence.
const fs = require('fs');
const path = require('path');
const vm = require('vm');
const crypto = require('crypto');
const assert = require('assert');

const runnerPath = process.argv[2];
if (!runnerPath) throw new Error('Usage: node cache_mock_tests.js RUNNER.js [REPORT.json]');
const runnerText = fs.readFileSync(runnerPath, 'utf8');
const cut = runnerText.indexOf('\nvar exitCode=1;');
if (cut < 0) throw new Error('Refusing to evaluate runner without locating its native startup boundary');
const definitions = runnerText.slice(0, cut);
const sha = value => crypto.createHash('sha256').update(value).digest('hex');
const win = path.win32;
const userRoot = 'C:\\Users\\Simon\\Downloads\\RH_HILBERT_LIMIT_LEAN_v0_2_1_construction';
const userAnchors = 'C:\\Users\\Simon\\AppData\\Local\\LEAN_ANCHORINGS\\RH_HILBERT_LIMIT\\LOCAL_COMPILER\\lean-4.33.0';
const results = [];

class VirtualFiles {
  constructor(cwd) {
    this.cwd = cwd;
    this.files = new Map();
    this.dirs = new Map();
    this.writes = [];
    this.copies = [];
    this.copyHook = null;
    this.mkdir(cwd);
  }
  abs(p) { return win.resolve(this.cwd, String(p)); }
  key(p) { return this.abs(p).toLowerCase(); }
  check(p) {
    const q = this.abs(p);
    if (q.length >= 260) throw new Error('MOCK_WINDOWS_MAX_PATH=' + q.length + ':' + q);
    this.writes.push(q);
    return q;
  }
  mkdir(p) {
    const q = this.abs(p), k = this.key(q);
    if (this.dirs.has(k)) return;
    const parent = win.dirname(q);
    if (parent !== q) this.mkdir(parent);
    this.check(q);
    this.dirs.set(k, q);
  }
  put(p, bytes) {
    const q = this.check(p);
    this.mkdir(win.dirname(q));
    this.files.set(this.key(q), { path: q, bytes: Buffer.from(bytes) });
  }
  get(p) {
    const file = this.files.get(this.key(p));
    if (!file) throw new Error('MOCK_FILE_NOT_FOUND=' + this.abs(p));
    return file.bytes;
  }
  copy(src, dst, overwrite) {
    if (this.files.has(this.key(dst)) && !overwrite) throw new Error('Mock copy target exists');
    this.copies.push({ source: this.abs(src), destination: this.abs(dst) });
    this.put(dst, this.get(src));
    if (this.copyHook) this.copyHook(this.abs(src), this.abs(dst));
  }
  moveFolder(src, dst) {
    src = this.abs(src); dst = this.abs(dst);
    const s = this.key(src), d = this.key(dst);
    if (!this.dirs.has(s)) throw new Error('Mock missing source folder');
    if (this.dirs.has(d)) throw new Error('Mock folder destination exists');
    const dirs = [...this.dirs].filter(([k]) => k === s || k.startsWith(s + '\\'));
    const files = [...this.files].filter(([k]) => k.startsWith(s + '\\'));
    for (const [k] of files) this.files.delete(k);
    for (const [k] of dirs) this.dirs.delete(k);
    for (const [, q] of dirs) this.mkdir(dst + q.slice(src.length));
    for (const [, file] of files) this.put(dst + file.path.slice(src.length), file.bytes);
  }
  removeFolder(p) {
    const q = this.key(p);
    for (const k of [...this.files.keys()]) if (k.startsWith(q + '\\')) this.files.delete(k);
    for (const k of [...this.dirs.keys()]) if (k === q || k.startsWith(q + '\\')) this.dirs.delete(k);
  }
  fso() {
    return {
      GetAbsolutePathName: p => this.abs(p),
      GetParentFolderName: p => win.dirname(this.abs(p)),
      GetBaseName: p => win.basename(p, win.extname(p)),
      GetFileName: p => win.basename(p),
      FileExists: p => this.files.has(this.key(p)),
      FolderExists: p => this.dirs.has(this.key(p)),
      CreateFolder: p => this.mkdir(p),
      CopyFile: (s, d, o) => this.copy(s, d, o),
      MoveFolder: (s, d) => this.moveFolder(s, d),
      DeleteFile: p => this.files.delete(this.key(p)),
      DeleteFolder: p => this.removeFolder(p),
      GetFile: p => ({ Path: this.abs(p), Size: this.get(p).length }),
      CreateTextFile: (p, overwrite, unicode) => {
        if (unicode) throw new Error('Unexpected Unicode audit writer');
        let text = '';
        return { Write: s => { text += s; }, Close: () => this.put(p, text) };
      },
      GetFolder: p => {
        const q = this.key(p);
        if (!this.dirs.has(q)) throw new Error('Mock folder not found');
        return {
          Files: [...this.files.values()].filter(f => this.key(win.dirname(f.path)) === q).map(f => ({ Path: f.path })),
          SubFolders: [...this.dirs].filter(([k, f]) => k !== q && this.key(win.dirname(f)) === q).map(([, f]) => ({ Path: f }))
        };
      }
    };
  }
}

function setup(name = 'RiemannHypothesis.ComplexAnalysis.GrowthRigidity') {
  const vfs = new VirtualFiles(userRoot);
  const logs = [], invoked = [];
  const environment = { SystemRoot: 'C:\\Windows', LOCALAPPDATA: 'C:\\Users\\Simon\\AppData\\Local', USERPROFILE: 'C:\\Users\\Simon' };
  const fso = vfs.fso();
  const shell = { Environment: () => (n => environment[n] || '') };
  const sandbox = {
    ActiveXObject: function (kind) {
      if (kind === 'Scripting.FileSystemObject') return fso;
      if (kind === 'WScript.Shell') return shell;
      throw new Error('Unexpected ActiveX=' + kind);
    },
    Enumerator: function (items) {
      let i = 0;
      this.atEnd = () => i >= items.length;
      this.item = () => items[i];
      this.moveNext = () => { i++; };
    },
    WScript: { Echo: s => logs.push(String(s)), Sleep: () => {}, Quit: () => { throw new Error('Native entrypoint was executed'); } }
  };
  const c = vm.createContext(sandbox);
  vm.runInContext(definitions, c, { filename: runnerPath });
  c.read = p => vfs.get(p).toString('utf8').replace(/^\uFEFF/, '');
  c.write = (p, s) => vfs.put(p, s);
  c.fileHash = p => sha(vfs.get(p));
  c.log = s => logs.push(String(s));
  c.externalKey = module => {
    assert.equal(module, 'Init');
    return c.fixtureExternalKey;
  };
  c.fixtureExternalKey = sha('external dependency baseline');
  c.compiler = 'C:\\NativeLean433\\bin\\lean.exe';
  c.leanVersion = 'Lean (version 4.33.0, x86_64-w64-windows-gnu, commit MOCK, Release)';
  c.anchorRoot = userAnchors;
  c.anchorRoots = [userAnchors];
  c.runTag = '20261027T170000Z-123456789';
  vfs.mkdir(c.anchorRoot);
  vfs.mkdir(c.helpers);
  vfs.put(c.compiler, 'native compiler fixture');
  vfs.put(c.root + '\\tools\\native_runner.js', runnerText);
  vfs.put(c.root + '\\run.cmd', '@echo off\r\nfixture\r\n');
  for (const file of [c.compiler, c.root + '\\tools\\native_runner.js', c.root + '\\run.cmd']) {
    c.requestHash(file);
    c.fileHashes[c.keyPath(file)] = c.fileHash(file);
  }
  c.makeGlobalKey();
  const source = c.root + '\\' + name.replace(/\./g, '\\') + '.lean';
  const output = c.work + '\\' + name.replace(/\./g, '\\') + '.olean';
  const auditLog = c.helpers + '\\fixture.audit.log';
  const theorem = 'Fixture.theorem';
  const auditText = theorem + ' : True\n\'' + theorem + '\' does not depend on any axioms\n';
  vfs.put(source, 'import Init\n-- Synthetic fixture; never passed to Lean.\n');
  c.modules[name] = { name, local: true, source, relative: name.replace(/\./g, '\\') + '.lean', imports: ['Init'] };
  c.modules.Init = { name: 'Init', local: false };
  c.fileHashes[c.keyPath(source)] = c.fileHash(source);
  c.auditTargets[name] = [theorem];
  vfs.put(output, 'synthetic olean bytes');
  vfs.put(output + '.private', 'synthetic auxiliary bytes');
  vfs.put(auditLog, auditText);
  c.runToFile = (exe, args, logFile) => {
    invoked.push({ exe, args: Array.from(args), logFile });
    if (exe !== c.compiler) throw new Error('Unexpected native executable invocation in mock');
    if (Array.from(args).includes('-o')) {
      const dest = args[Array.from(args).indexOf('-o') + 1];
      vfs.put(dest, 'synthetic olean bytes');
      vfs.put(dest + '.private', 'synthetic auxiliary bytes');
    }
    const all = c.auditTargets[name].map(t => t + ' : True\n\'' + t + '\' does not depend on any axioms\n').join('');
    vfs.put(logFile, all);
    return 0;
  };
  const f = { c, vfs, logs, invoked, name, source, output, auditLog };
  f.input = () => c.moduleInput(name);
  f.save = () => {
    const input = f.input();
    c.saveAnchor(name, input, auditLog, output, '');
    const receipt = [...vfs.files.values()].filter(x => x.path.endsWith('\\receipt.txt')).at(-1).path;
    return { input, receipt, folder: win.dirname(receipt) };
  };
  f.clear = () => c.clearOutputs(name);
  f.restore = () => c.restoreAnchor(name, f.input());
  return f;
}

function scenario(name, run) {
  try {
    const detail = run() || {};
    results.push({ name, outcome: 'PASS_MOCK_HOST', ...detail });
    console.log('PASS ' + name);
  } catch (e) {
    results.push({ name, outcome: 'FAIL', error: e.stack || String(e) });
    console.log('FAIL ' + name + ': ' + e.message);
  }
}

scenario('save_restore_same_target_content_verified', () => {
  const f = setup(), saved = f.save();
  const expected = Buffer.from(f.vfs.get(f.output));
  f.clear();
  const restored = f.restore();
  assert(restored && !restored.needsAudit);
  assert.deepEqual(f.vfs.get(f.output), expected);
  f.c.acceptRestored(f.name, saved.input, restored);
  assert.equal(f.c.reused, 1);
  assert.equal(f.invoked.length, 0);
  return { cache_save_path_length: saved.folder.length, max_generated_path: Math.max(...f.vfs.writes.map(p => p.length)) };
});

scenario('legacy_v2_directory_layout_remains_reusable', () => {
  const f = setup('Short.Core'), saved = f.save();
  const oldFolder = f.c.anchorRoot + '\\' + f.name + '\\' + saved.input.key + '\\old-run';
  f.vfs.moveFolder(saved.folder, oldFolder);
  const oldReceipt = oldFolder + '\\receipt.txt';
  f.vfs.put(oldReceipt, f.vfs.get(oldReceipt).toString().replace(/^CACHE_LAYOUT=.*\r?\n/gm, ''));
  f.clear();
  const restored = f.restore();
  assert(restored && !restored.needsAudit);
  assert.equal(restored.receipt, oldReceipt);
});

scenario('changed_source_never_reuses_prior_pass', () => {
  const f = setup(); f.save(); f.clear();
  f.vfs.put(f.source, 'import Init\n-- modified source\n');
  f.c.fileHashes[f.c.keyPath(f.source)] = f.c.fileHash(f.source);
  assert.equal(f.restore(), null);
});

scenario('changed_dependency_never_reuses_prior_pass', () => {
  const f = setup(); f.save(); f.clear();
  f.c.fixtureExternalKey = sha('changed transitive dependency');
  assert.equal(f.restore(), null);
});

scenario('changed_native_compiler_never_reuses_prior_pass', () => {
  const f = setup(); f.save(); f.clear();
  f.vfs.put(f.c.compiler, 'changed native compiler fixture');
  f.c.fileHashes[f.c.keyPath(f.c.compiler)] = f.c.fileHash(f.c.compiler);
  f.c.makeGlobalKey();
  assert.equal(f.restore(), null);
});

scenario('changed_launcher_provenance_does_not_invalidate_build', () => {
  const f = setup(), saved = f.save(); f.clear();
  const launcher = f.c.root + '\\run.cmd';
  f.vfs.put(launcher, '@echo off\r\nrem Display-only launcher change\r\n');
  f.c.fileHashes[f.c.keyPath(launcher)] = f.c.fileHash(launcher);
  f.c.makeGlobalKey();
  assert.equal(f.input().key, saved.input.key);
  assert(f.restore());
});

scenario('unchanged_module_reused_from_a_different_package_directory', () => {
  const f = setup(), saved = f.save(); f.clear();
  const newRoot = 'C:\\Users\\Simon\\Downloads\\RH_HILBERT_LIMIT_LEAN_v0_2_2_construction';
  const sameSource = Buffer.from(f.vfs.get(f.source));
  f.c.root = newRoot;
  f.c.work = newRoot + '\\.native-build';
  f.c.helpers = f.c.work + '\\runner';
  const newSource = newRoot + '\\' + f.name.replace(/\./g, '\\') + '.lean';
  f.vfs.put(newSource, sameSource);
  f.c.modules[f.name].source = newSource;
  f.c.fileHashes[f.c.keyPath(newSource)] = f.c.fileHash(newSource);
  for (const rel of ['tools\\native_runner.js', 'run.cmd']) {
    const p = newRoot + '\\' + rel;
    f.vfs.put(p, 'new presentation-only release');
    f.c.requestHash(p);
    f.c.fileHashes[f.c.keyPath(p)] = f.c.fileHash(p);
  }
  f.c.makeGlobalKey();
  assert.equal(f.input().key, saved.input.key);
  const restored = f.restore();
  assert(restored && !restored.needsAudit);
  assert(restored.output.startsWith(newRoot));
  assert.equal(f.invoked.length, 0);
});

scenario('changed_compile_policy_never_reuses_prior_pass', () => {
  const f = setup(); f.save(); f.clear();
  f.c.COMPILE_POLICY += '_changed';
  f.c.makeGlobalKey();
  assert.equal(f.restore(), null);
});

scenario('wrong_target_receipt_rejected', () => {
  const f = setup(), saved = f.save(); f.clear();
  f.vfs.put(saved.receipt, f.vfs.get(saved.receipt).toString().replace('TARGET=LOCAL_COMPILER', 'TARGET=GITHUB_CI'));
  assert.equal(f.restore(), null);
});

scenario('nonpassing_receipt_rejected', () => {
  const f = setup(), saved = f.save(); f.clear();
  f.vfs.put(saved.receipt, f.vfs.get(saved.receipt).toString().replace('AUDIT_PASS=1', 'AUDIT_PASS=0'));
  assert.equal(f.restore(), null);
});

scenario('corrupt_cached_artifact_rejected', () => {
  const f = setup(), saved = f.save(); f.clear();
  f.vfs.put(saved.folder + '\\artifacts\\GrowthRigidity.olean', 'corrupt cached bytes');
  assert.equal(f.restore(), null);
  assert(!f.c.exists(f.output));
});

scenario('corrupt_cached_audit_log_rejected', () => {
  const f = setup(), saved = f.save(); f.clear();
  f.vfs.put(saved.folder + '\\audit.log', 'replaced audit evidence');
  assert.equal(f.restore(), null);
});

scenario('copied_artifact_corruption_rejected_and_removed', () => {
  const f = setup(); f.save(); f.clear();
  f.vfs.copyHook = (src, dst) => {
    if (f.vfs.key(dst) === f.vfs.key(f.output)) f.vfs.put(dst, 'corrupt bytes introduced after copy');
  };
  assert.equal(f.restore(), null);
  assert(!f.c.exists(f.output));
});

scenario('expanded_audit_runs_audit_without_recompiling', () => {
  const f = setup(); f.save(); f.clear();
  f.c.auditTargets[f.name].push('Fixture.second');
  const restored = f.restore();
  assert(restored && restored.needsAudit);
  f.c.processModule(f.name, false);
  assert.equal(f.c.auditOnly, 1);
  assert.equal(f.c.compiled, 0);
  assert.equal(f.invoked.length, 1);
  assert(!f.invoked[0].args.includes('-o'));
  assert.equal(f.c.buildStates[f.name], 'FROZEN_REUSED_REAUDITED');
});

scenario('uncommitted_pending_entry_is_never_reused', () => {
  const f = setup(), saved = f.save(); f.clear();
  f.vfs.moveFolder(saved.folder, saved.folder + '.pending');
  assert.equal(f.restore(), null);
});

scenario('missing_receipt_is_never_reused', () => {
  const f = setup(), saved = f.save(); f.clear();
  f.vfs.files.delete(f.vfs.key(saved.receipt));
  assert.equal(f.restore(), null);
});

scenario('missing_cached_artifact_is_safe_miss', () => {
  const f = setup(), saved = f.save(); f.clear();
  f.vfs.files.delete(f.vfs.key(saved.folder + '\\artifacts\\GrowthRigidity.olean'));
  assert.equal(f.restore(), null);
});

scenario('final_audit_module_is_persisted_and_reused', () => {
  const f = setup('EquivalenceAudit'); f.clear();
  f.c.processModule(f.name, true);
  assert.equal(f.c.compiled, 1);
  assert.equal(f.invoked.length, 1);
  f.c.processModule(f.name, true);
  assert.equal(f.invoked.length, 1);
  assert.equal(f.c.reused, 1);
});

scenario('longest_package_leaf_and_private_object_fit_windows_path', () => {
  const f = setup('RiemannHypothesis.Xi.CanonicalQuotientThetaCharacteristicGrowth');
  const saved = f.save();
  const maxPath = Math.max(...f.vfs.writes.map(p => p.length));
  assert(maxPath < 260);
  f.clear();
  assert(f.restore());
  return { maximum_path_length: maxPath, cache_directory_length: saved.folder.length };
});

scenario('verified_unchanged_working_objects_are_retained_without_copy', () => {
  const f = setup(); f.save();
  const copyCount = f.vfs.copies.length;
  const restored = f.restore();
  assert(restored && restored.retained && !restored.needsAudit);
  assert.equal(f.vfs.copies.length, copyCount);
  assert.equal(f.c.workingRetained, 1);
  assert.equal(f.c.restoredArtifactFiles, 0);
  assert.equal(f.invoked.length, 0);
});

scenario('changed_working_objects_are_repaired_from_verified_cache', () => {
  const f = setup(); f.save();
  const original = Buffer.from(f.vfs.get(f.output));
  const copyCount = f.vfs.copies.length;
  f.vfs.put(f.output, 'modified working object');
  const restored = f.restore();
  assert(restored && restored.retained === false);
  assert.deepEqual(f.vfs.get(f.output), original);
  assert.equal(f.vfs.copies.length - copyCount, 2);
  assert.equal(f.c.workingRetained, 0);
  assert.equal(f.c.restoredArtifactFiles, 2);
  assert.equal(f.invoked.length, 0);
});

scenario('exact_cache_hit_avoids_scanning_historical_inputs', () => {
  const f = setup(); f.save(); f.clear();
  f.c.historicalAnchorCandidates = () => { throw new Error('Unexpected historical cache scan for exact hit'); };
  assert(f.restore());
  assert.equal(f.c.anchorHistoryScans, 0);
});

scenario('compact_input_prefix_collision_does_not_authorize_reuse', () => {
  const f = setup(), saved = f.save(); f.clear();
  const wrongKey = saved.input.key.slice(0, 32) + (saved.input.key.slice(32) === '0'.repeat(32) ? '1' : '0').repeat(32);
  assert.notEqual(wrongKey, saved.input.key);
  assert.equal(f.c.compactInputRoot(f.c.anchorRoot, f.name, wrongKey), f.c.compactInputRoot(f.c.anchorRoot, f.name, saved.input.key));
  assert.equal(f.c.restoreAnchor(f.name, { key: wrongKey, manifest: saved.input.manifest }), null);
});

scenario('working_objects_without_receipt_are_not_trusted', () => {
  const f = setup();
  assert(f.c.exists(f.output));
  assert.equal(f.restore(), null);
  assert.equal(f.c.workingRetained, 0);
  assert.equal(f.c.reused, 0);
});

scenario('valid_working_object_cannot_bypass_corrupt_anchor_evidence', () => {
  const f = setup(), saved = f.save();
  assert(f.c.exists(f.output));
  f.vfs.put(saved.folder + '\\audit.log', 'corrupt cache audit with valid working object');
  assert.equal(f.restore(), null);
  assert.equal(f.c.workingRetained, 0);
  assert.equal(f.c.reused, 0);
});

const report = {
  harness: 'RH_HILBERT_CACHE_MOCK_HOST_QA_V1',
  runner: runnerPath,
  runner_sha256: sha(runnerText),
  native_windows_execution: false,
  lean_execution: false,
  compiler_invocations: 'SYNTHETIC_JS_MOCK_ONLY',
  proof_certification: 'NONE',
  passed: results.filter(r => r.outcome === 'PASS_MOCK_HOST').length,
  failed: results.filter(r => r.outcome === 'FAIL').length,
  results
};
if (process.argv[3]) fs.writeFileSync(process.argv[3], JSON.stringify(report, null, 2) + '\n');
console.log(JSON.stringify({ passed: report.passed, failed: report.failed, native_windows_execution: false, lean_execution: false }));
if (report.failed) process.exitCode = 1;
