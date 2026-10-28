'use strict';

// Node-only host simulation for the WSH runner. No child process API is imported.
// Every Windows path, compiler output, and receipt in this host is in memory.
const fs = require('fs');
const path = require('path');
const vm = require('vm');
const crypto = require('crypto');
const win = path.win32;

const sha256 = value => crypto.createHash('sha256').update(value).digest('hex');

class MemoryWindowsFS {
  constructor(cwd = 'C:\\review\\package') {
    this.cwd = cwd;
    this.entries = new Map();
    this.mkdir(cwd);
  }
  absolute(p) {
    const absolute = win.normalize(win.resolve(this.cwd, String(p)));
    return absolute.length > 3 ? absolute.replace(/\\+$/, '') : absolute;
  }
  key(p) { return this.absolute(p).toLowerCase(); }
  entry(p) { return this.entries.get(this.key(p)); }
  exists(p) { const e = this.entry(p); return !!e && !e.directory; }
  directory(p) { const e = this.entry(p); return !!e && e.directory; }
  mkdir(p) {
    const absolute = this.absolute(p);
    if (this.directory(absolute)) return;
    const parent = win.dirname(absolute);
    if (parent && parent !== absolute && this.key(parent) !== this.key(absolute)) this.mkdir(parent);
    this.entries.set(this.key(absolute), {path: absolute, directory: true});
  }
  put(p, data) {
    const absolute = this.absolute(p);
    this.mkdir(win.dirname(absolute));
    this.entries.set(this.key(absolute), {path: absolute, directory: false,
      data: Buffer.isBuffer(data) ? Buffer.from(data) : Buffer.from(String(data), 'utf8')});
  }
  read(p) {
    const e = this.entry(p);
    if (!e || e.directory) throw new Error('MOCK missing file: ' + p);
    return Buffer.from(e.data);
  }
  text(p) { return this.read(p).toString('utf8').replace(/^\uFEFF/, ''); }
  removeFile(p) {
    if (!this.exists(p)) throw new Error('MOCK missing file to delete: ' + p);
    this.entries.delete(this.key(p));
  }
  removeFolder(p) {
    const key = this.key(p);
    for (const k of [...this.entries.keys()]) if (k === key || k.startsWith(key + '\\')) this.entries.delete(k);
  }
  copyFile(source, destination, overwrite) {
    if (overwrite === false && this.exists(destination)) throw new Error('MOCK refusing overwrite: ' + destination);
    this.put(destination, this.read(source));
  }
  copyTree(source, destination) {
    const key = this.key(source);
    const entries = [...this.entries.values()].filter(e => this.key(e.path) === key || this.key(e.path).startsWith(key + '\\'));
    if (!entries.length) throw new Error('MOCK missing tree: ' + source);
    for (const e of entries) {
      const dest = this.absolute(destination) + e.path.slice(this.absolute(source).length);
      if (e.directory) this.mkdir(dest); else this.put(dest, e.data);
    }
  }
  moveTree(source, destination) { this.copyTree(source, destination); this.removeFolder(source); }
  children(p, directories) {
    const key = this.key(p);
    return [...this.entries.values()].filter(e => e.directory === directories && this.key(win.dirname(e.path)) === key)
      .map(e => ({Path: e.path, Name: win.basename(e.path), Size: e.directory ? 0 : e.data.length}))
      .sort((a, b) => a.Path.localeCompare(b.Path));
  }
}

function createHost(sourcePath, options = {}) {
  const memory = options.memory || new MemoryWindowsFS(options.root);
  const root = memory.cwd;
  const values = Object.assign({SystemRoot: 'C:\\Windows', USERPROFILE: 'C:\\Users\\Review',
    LOCALAPPDATA: 'C:\\Users\\Review\\AppData\\Local', PATH: 'C:\\Windows\\System32',
    AWPIRH_LEAN_EXE: 'C:\\toolchain\\bin\\lean.exe', MATHLIB_CACHE_ROOT: 'C:\\cache'}, options.env);
  const messages = [], calls = [], hashes = [], textFileWrites = [];
  const fso = {
    GetAbsolutePathName: p => memory.absolute(p),
    GetParentFolderName: p => win.dirname(memory.absolute(p)),
    GetBaseName: p => win.basename(String(p), win.extname(String(p))),
    GetFileName: p => win.basename(String(p)),
    FileExists: p => memory.exists(p), FolderExists: p => memory.directory(p),
    CreateFolder: p => memory.mkdir(p),
    DeleteFile: p => memory.removeFile(p), DeleteFolder: p => memory.removeFolder(p),
    CopyFile: (s, d, o) => memory.copyFile(s, d, o),
    MoveFolder: (s, d) => memory.moveTree(s, d),
    GetFolder: p => ({Files: memory.children(p, false), SubFolders: memory.children(p, true)}),
    GetFile: p => ({Path: memory.absolute(p), Size: memory.read(p).length}),
    CreateTextFile(p, overwrite, unicode) {
      if (overwrite === false && memory.exists(p)) throw new Error('MOCK refusing text overwrite: ' + p);
      let contents = '';
      memory.put(p, '');
      textFileWrites.push({path: memory.absolute(p), overwrite, unicode});
      return {
        Write(value) { contents += String(value); },
        WriteLine(value) { contents += String(value) + '\r\n'; },
        Close() {
          memory.put(p, unicode ? Buffer.concat([Buffer.from([0xff, 0xfe]), Buffer.from(contents, 'utf16le')]) : Buffer.from(contents, 'latin1'));
        }
      };
    }
  };
  function makeStream() {
    let contents = '';
    return {Type: 2, Charset: 'utf-8', Open() {}, Close() {},
      LoadFromFile(p) { contents = memory.read(p).toString('utf8'); },
      ReadText() { return contents; },
      WriteText(s) { contents += String(s); },
      SaveToFile(p) { memory.put(p, '\uFEFF' + contents); }};
  }
  const shell = {
    Environment() { return name => values[name] || ''; },
    Exec(command) {
      const match = /^"[^"]+certutil\.exe"\s+-hashfile\s+"([^"]+)"\s+SHA256$/i.exec(command);
      if (!match) throw new Error('MOCK forbids unexpected process command: ' + command);
      hashes.push(match[1]);
      let output, code = 0;
      try { output = 'SHA256 hash of file:\r\n' + sha256(memory.read(match[1])) + '\r\nCertUtil: complete.\r\n'; }
      catch (e) { output = e.message; code = 1; }
      return {Status: 1, ExitCode: code, StdOut: {ReadAll() { return output; }}, StdErr: {ReadAll() { return ''; }}};
    },
    Run(command) { throw new Error('MOCK forbids unhandled shell.Run: ' + command); }
  };
  function ActiveXObject(name) {
    if (name === 'Scripting.FileSystemObject') return fso;
    if (name === 'WScript.Shell') return shell;
    if (name === 'ADODB.Stream') return makeStream();
    throw new Error('MOCK unknown ActiveX object: ' + name);
  }
  function Enumerator(values) {
    this.values = values; this.position = 0;
    this.atEnd = () => this.position >= values.length;
    this.moveNext = () => { this.position++; };
    this.item = () => values[this.position];
  }
  const context = vm.createContext({ActiveXObject, Enumerator,
    WScript: {Echo: value => messages.push(String(value)), Sleep() {}, Quit(code) { throw new Error('MOCK Quit ' + code); }},
    __setEnv: (name, value) => { values[name] = String(value); },
    console: {log: () => {}},
  });
  const fullSource = fs.readFileSync(sourcePath, 'utf8');
  const marker = 'var exitCode=1;';
  const index = fullSource.indexOf(marker);
  if (index < 0) throw new Error('Runner entry marker missing; update harness deliberately.');
  // WSH COM property-put syntax is the sole syntax adaptation. All tested
  // runner helper bodies otherwise remain byte-for-byte as supplied.
  let definitions = fullSource.slice(0, index);
  const assignments = [], pattern = /env\("([A-Z_]+)"\)\s*=(?!=)/g;
  let match;
  while ((match = pattern.exec(definitions))) {
    const expressionStart = pattern.lastIndex;
    let quote = '', escaped = false, end = expressionStart;
    for (; end < definitions.length; end++) {
      const ch = definitions[end];
      if (quote) {
        if (escaped) escaped = false;
        else if (ch === '\\') escaped = true;
        else if (ch === quote) quote = '';
      } else if (ch === '"' || ch === "'") quote = ch;
      else if (ch === ';') break;
    }
    if (end === definitions.length) throw new Error('Unterminated COM property-put assignment');
    assignments.push({start: match.index, end: end + 1,
      replacement: '__setEnv(' + JSON.stringify(match[1]) + ', ' + definitions.slice(expressionStart, end) + ');'});
    pattern.lastIndex = end + 1;
  }
  for (const a of assignments.reverse()) definitions = definitions.slice(0, a.start) + a.replacement + definitions.slice(a.end);
  vm.runInContext(definitions, context, {filename: sourcePath, timeout: 10000});
  const host = {context, memory, values, messages, calls, hashes, textFileWrites, sourcePath, fullSource,
    sourceHash: sha256(Buffer.from(fullSource)),
    compilerFailure: false, auditFailure: false, auditAxiom: null, auditDrop: null,
    version: 'Lean (version 4.33.0, x86_64-pc-windows-msvc, commit MOCK_ONLY, Release)',
    prefix: 'C:\\toolchain'};
  // No native program is executed: this stub supplies explicitly simulated
  // version/prefix/compiler/audit responses to the actual runner control flow.
  context.runToFile = function (exe, args, output) {
    calls.push({exe: String(exe), args: Array.from(args), output: String(output)});
    if (args.length === 1 && args[0] === '--version') { memory.put(output, host.version); return 0; }
    if (args.length === 1 && args[0] === '--print-prefix') { memory.put(output, host.prefix); return 0; }
    const source = String(args[args.length - 1]);
    const outIndex = args.indexOf('-o');
    if (outIndex >= 0 && host.compilerFailure) { memory.put(output, 'MOCK compiler failure'); return 1; }
    if (outIndex >= 0) memory.put(args[outIndex + 1], 'MOCK_OLEAN\n' + sha256(memory.read(source)) + '\n');
    const text = memory.text(source), expected = [...text.matchAll(/#print\s+axioms\s+([A-Za-z0-9_'.]+)/g)].map(m => m[1]);
    if (expected.length && host.auditFailure) { memory.put(output, 'MOCK audit failure'); return 1; }
    const actual = expected.filter(name => name !== host.auditDrop);
    const audit = actual.map(name => "'" + name + "' depends on axioms: [" + (host.auditAxiom || 'propext, Classical.choice, Quot.sound') + ']\n').join('');
    memory.put(output, audit);
    return 0;
  };
  return host;
}

function populateFixture(host, options = {}) {
  const m = host.memory, root = m.cwd, cache = options.cache || 'C:\\cache',
    mathlib = options.directMathlib ? cache : cache + '\\.lake\\packages\\mathlib';
  m.put('C:\\Windows\\System32\\certutil.exe', 'MOCK certutil; never executed');
  m.put('C:\\toolchain\\bin\\lean.exe', 'MOCK compiler v1; never executed');
  m.put('C:\\toolchain\\bin\\Lean.dll', 'MOCK Lean DLL v1');
  m.put('C:\\toolchain\\lib\\lean\\Init.olean', 'MOCK Init artifact v1');
  m.put('C:\\toolchain\\src\\lean\\Init.lean', 'prelude\n');
  m.put(mathlib + '\\lean-toolchain', 'leanprover/lean4:v4.33.0\n');
  m.put(mathlib + '\\lake-manifest.json', '{"MOCK":1}\n');
  m.put(mathlib + '\\Mathlib\\ReviewBase.lean', 'prelude\n');
  m.put(mathlib + '\\Mathlib\\Review.lean', 'import Mathlib.ReviewBase\n');
  m.put(mathlib + '\\.lake\\build\\lib\\lean\\Mathlib\\ReviewBase.olean', 'MOCK external base artifact v1');
  m.put(mathlib + '\\.lake\\build\\lib\\lean\\Mathlib\\Review.olean', 'MOCK external artifact v1');
  if (!options.noUmbrella) m.put(mathlib + '\\.lake\\build\\lib\\lean\\Mathlib.olean', 'MOCK umbrella artifact');
  m.put(root + '\\compile-order.txt', 'Review/Base.lean\nReview/Leaf.lean\nReview/Independent.lean\n');
  m.put(root + '\\audit-targets.tsv', 'Review.Base|Review.base\nReview.Leaf|Review.leaf\nReview.Independent|Review.independent\n');
  m.put(root + '\\Review\\Base.lean', 'import Mathlib.Review\ntheorem Review.base : True := True.intro\ntheorem Review.extra : True := True.intro\n');
  m.put(root + '\\Review\\Leaf.lean', 'import Review.Base\ntheorem Review.leaf : True := True.intro\n');
  m.put(root + '\\Review\\Independent.lean', 'import Mathlib.Review\ntheorem Review.independent : True := True.intro\n');
  m.put(root + '\\Audit.lean', 'import Review.Leaf\nimport Review.Independent\n#print axioms Review.base\n#print axioms Review.leaf\n#print axioms Review.independent\n');
  m.put(root + '\\tools\\native_runner.js', host.fullSource);
  const batchHelper = path.join(path.dirname(host.sourcePath), 'NativeSha256.cs');
  if (fs.existsSync(batchHelper)) m.put(root + '\\tools\\NativeSha256.cs', fs.readFileSync(batchHelper));
  m.put(root + '\\run.cmd', '@echo off\r\nREM MOCK launcher for host simulation\r\n');
  m.put(root + '\\mathlib-imports.txt', 'Mathlib.Review\n');
  return {root, cache, mathlib};
}

function startup(host) {
  const c = host.context;
  c.mkdir(c.helpers); c.write(c.logPath, ''); c.write(c.auditLogPath, '');
  c.selectCompiler();
  if (typeof c.loadMathlibRequirements === 'function') c.loadMathlibRequirements();
  c.selectCache(); c.loadPlan(); c.parallelHashes(); c.makeGlobalKey();
  return host;
}

function buildAll(host, final = false) {
  for (const name of host.context.ordered) host.context.processModule(name);
  if (final && !host.context.failed && !host.context.blocked) host.context.finalAudit();
  return host;
}

function restart(host, sourcePath = host.sourcePath, options = {}) {
  const next = createHost(sourcePath, {memory: host.memory, env: Object.assign({}, host.values, options.env)});
  next.memory.put(next.memory.cwd + '\\tools\\native_runner.js', next.fullSource);
  next.context.runTag = host.context.runTag + '-next-' + Math.random().toString(16).slice(2);
  return startup(next);
}

module.exports = {MemoryWindowsFS, createHost, populateFixture, startup, buildAll, restart, sha256};
