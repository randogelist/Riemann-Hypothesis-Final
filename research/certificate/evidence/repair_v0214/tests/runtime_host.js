'use strict';

// In-memory Windows/WSH boundary for source-level Node VM tests only.
// No child_process import, no compiler, COM, WMI, or native command execution.
const fs = require('fs');
const vm = require('vm');
const path = require('path');
const assert = require('assert');
const {createHost, populateFixture, startup, buildAll, sha256} = require('./mock_host');
const frozenSources = require('./candidate_sources');
const win = path.win32;

function adaptComSetters(source, expected) {
  const assignments = [];
  const pattern = /env\("([A-Z_]+)"\)\s*=(?!=)/g;
  let match;
  while ((match = pattern.exec(source))) {
    const begin = pattern.lastIndex;
    let end = begin, quote = '', escaped = false;
    for (; end < source.length; end++) {
      const ch = source[end];
      if (quote) {
        if (escaped) escaped = false;
        else if (ch === '\\') escaped = true;
        else if (ch === quote) quote = '';
      } else if (ch === '"' || ch === "'") quote = ch;
      else if (ch === ';') break;
    }
    assert(end < source.length, 'unterminated COM setter');
    assignments.push({start: match.index, end: end + 1,
      text: '__setEnv(' + JSON.stringify(match[1]) + ', ' + source.slice(begin, end) + ');'});
    pattern.lastIndex = end + 1;
  }
  assert.strictEqual(assignments.length, expected, 'COM setter adaptation count changed');
  let adapted = source;
  for (const item of assignments.reverse()) adapted = adapted.slice(0, item.start) + item.text + adapted.slice(item.end);
  return adapted;
}

function makeHost(paths, options = {}) {
  const host = createHost(paths.runner || paths.baseline, {
    root: 'E:\\RH-FAST\\workspaces\\SIMULATED_RAM_PARALLEL',
    memory: options.memory,
    env: Object.assign({RH_RAM_WARM: 'OFF', RH_MODULE_WORKERS: '4'}, options.env),
  });
  const c = host.context, memory = host.memory;
  host.clock = 1793095200000;
  host.epoch = host.clock;
  host.sleeps = [];
  host.events = [];
  host.processes = [];
  host.memoryQueries = 0;
  host.inventoryQueries = 0;
  host.memoryState = options.memoryState === undefined ? {totalMB: 65536, freeMB: 60000} : options.memoryState;
  host.extraInventory = [];
  host.inventoryError = false;
  host.failures = options.failures || {};
  host.durations = options.durations || {};
  host.failNextExec = false;
  host.onSleep = null;
  let pid = 5000;
  const NativeDate = Date;
  function ClockDate(...args) { return new NativeDate(...(args.length ? args : [host.clock])); }
  ClockDate.now = () => host.clock;
  ClockDate.UTC = NativeDate.UTC;
  ClockDate.parse = NativeDate.parse;
  c.Date = ClockDate;
  c.WScript.Sleep = milliseconds => {
    assert(milliseconds >= 0 && milliseconds <= 1000, 'unexpected mock sleep');
    host.clock += Number(milliseconds);
    host.sleeps.push(Number(milliseconds));
    assert(host.clock - host.epoch <= 120000, 'bounded mock clock exceeded');
    if (host.onSleep) host.onSleep(host);
  };
  const priorGetFolder = c.fso.GetFolder;
  c.fso.GetFolder = p => Object.assign(priorGetFolder(p), {DateCreated: new NativeDate(host.epoch - 1000)});

  assert(host.fullSource.includes(frozenSources.memory), 'assembled runner does not contain exact frozen memory repair');
  assert(host.fullSource.includes(frozenSources.admitted), 'assembled runner does not contain exact frozen lock repair');
  assert.strictEqual(adaptComSetters(frozenSources.memory, 0), frozenSources.memory);
  assert.strictEqual(adaptComSetters(frozenSources.admitted, 0), frozenSources.admitted);
  host.bindingMode = 'EXACT_ASSEMBLED_FUNCTION_DEFINITIONS';
  host.extensionHashes = {memory_fallback_js: sha256(frozenSources.memory), admitted_relative_hosts_js: sha256(frozenSources.admitted)};

  c.lockSelf = {pid: 1000, parent: 900, created: '20261027095959.000000+000',
    name: 'cscript.exe', script: c.root + '\\tools\\native_runner.js', token: 'mock-owner-token-123456',
    command: '"C:\\Windows\\System32\\cscript.exe" "' + c.root + '\\tools\\native_runner.js" --runner-token=mock-owner-token-123456'};
  c.WScript.ScriptFullName = c.lockSelf.script;
  c.WScript.Arguments = {length: 1, Item: () => '--runner-token=mock-owner-token-123456'};

  function liveNative() {
    return host.processes.filter(p => !p.completed && host.clock < p.deadline && p.kind === 'lean');
  }
  host.liveNative = liveNative;
  c.GetObject = () => ({ExecQuery(query) {
    if (/FROM Win32_OperatingSystem/.test(query)) {
      host.memoryQueries++;
      const state = typeof host.memoryState === 'function' ? host.memoryState(host) : host.memoryState;
      if (!state) throw new Error('SIMULATED unavailable WMI memory');
      return [{TotalVisibleMemorySize: state.totalMB * 1024, FreePhysicalMemory: state.freeMB * 1024}];
    }
    if (/FROM Win32_Process/.test(query)) {
      host.inventoryQueries++;
      if (host.inventoryError) throw new Error('SIMULATED unavailable process inventory');
      const own = {ProcessId: c.lockSelf.pid, ParentProcessId: c.lockSelf.parent,
        CreationDate: c.lockSelf.created, Name: c.lockSelf.name, CommandLine: c.lockSelf.command};
      const active = host.processes.filter(p => p.Status === 0).map(p => ({ProcessId: p.ProcessID,
        ParentProcessId: c.lockSelf.pid, CreationDate: '20261027100000.000000+000',
        Name: 'cmd.exe', CommandLine: p.command}));
      return [own].concat(active, host.extraInventory);
    }
    throw new Error('unexpected simulated WMI query: ' + query);
  }});

  const originalExec = c.shell.Exec;
  c.shell.Exec = command => {
    if (!/ \/d \/v:off \/s \/c /.test(command)) {
      // Existing certutil protocol and actual SHA256 of in-memory file bytes.
      const live = liveNative();
      host.events.push({kind: 'hash_launch', at: host.clock, live_lean_threads: live.reduce((a, p) => a + p.threads, 0)});
      return originalExec(command);
    }
    if (host.failNextExec) { host.failNextExec = false; throw new Error('SIMULATED Exec failure'); }
    const wrapped = /^"[^"]+" \/d \/v:off \/s \/c "([\s\S]*)"$/.exec(command);
    assert(wrapped, 'unexpected command wrapper');
    const quoted = [...wrapped[1].matchAll(/"([^"]*)"/g)].map(m => m[1]);
    assert(quoted.length >= 3, 'unexpected async command tokens');
    const exe = quoted[0], output = quoted[quoted.length - 1], args = quoted.slice(1, -1);
    const isLean = /\\lean\.exe$/i.test(exe), kind = isLean ? 'lean' : 'ram_warm';
    const source = args[args.length - 1];
    let module = '', phase = '';
    if (isLean) {
      phase = args.indexOf('-o') >= 0 ? 'COMPILE' : 'AUDIT';
      module = phase === 'COMPILE'
        ? Object.keys(c.modules).find(n => c.modules[n].source === source)
        : Object.keys(c.parallelRuntime.tasks).find(n => c.parallelRuntime.tasks[n].auditSource === source);
      assert(module, 'unknown simulated compiler source');
    }
    const match = args.find(a => /^-j\d+$/.test(a));
    const threads = match ? Number(match.slice(2)) : 0;
    if (isLean) assert.strictEqual(host.values.LEAN_NUM_THREADS, String(threads), 'per-launch environment mismatch');
    const duration = host.durations[module] && host.durations[module][phase] !== undefined
      ? host.durations[module][phase] : phase === 'AUDIT' ? 300 : 200;
    const process = {ProcessID: ++pid, kind, command, exe, args, output, module, phase, threads,
      deadline: host.clock + duration, completed: false, code: null};
    function finish() {
      if (process.completed || host.clock < process.deadline) return;
      process.completed = true;
      if (!isLean) { process.code = 0; return; }
      const fail = host.failures[module] || {};
      const before = {compilerFailure: host.compilerFailure, auditFailure: host.auditFailure,
        auditAxiom: host.auditAxiom, auditDrop: host.auditDrop};
      host.compilerFailure = phase === 'COMPILE' && fail.compile === true;
      host.auditFailure = phase === 'AUDIT' && fail.auditExit === true;
      host.auditAxiom = phase === 'AUDIT' && fail.badAxiom ? fail.badAxiom : null;
      host.auditDrop = phase === 'AUDIT' && fail.dropTarget ? c.auditTargets[module][0] : null;
      try { process.code = c.runToFile(exe, args, output); }
      finally { Object.assign(host, before); }
      if (phase === 'COMPILE' && fail.missingArtifact) {
        const index = args.indexOf('-o');
        if (memory.exists(args[index + 1])) memory.removeFile(args[index + 1]);
      }
      host.events.push({kind: 'process_exit', at: host.clock, module, phase, code: process.code});
    }
    Object.defineProperty(process, 'Status', {get() { finish(); return process.completed ? 1 : 0; }});
    Object.defineProperty(process, 'ExitCode', {get() { finish(); assert(process.completed, 'exit code before completion'); return process.code; }});
    host.processes.push(process);
    const live = liveNative();
    host.events.push({kind: 'process_launch', at: host.clock, module, phase, threads, process_kind: kind,
      live_lean_threads: live.reduce((a, p) => a + p.threads, 0),
      live_lean_count: live.length,
      coordinator_reserve: c.parallelRuntime.workers > 1 ? 1 : 0,
      dependency_states: isLean ? c.modules[module].imports.filter(d => c.modules[d].local)
        .map(d => ({module: d, state: c.parallelRuntime.states[d], key: c.moduleKeys[d] || '', artifact: c.artifactHashes[d] || ''})) : [],
    });
    return process;
  };
  const save = c.saveAnchor;
  c.saveAnchor = (...args) => {
    const value = save(...args);
    host.events.push({kind: 'accepted', at: host.clock, module: args[0], input: c.moduleKeys[args[0]], artifact: c.artifactHashes[args[0]]});
    return value;
  };

  host.installFixture = (graph = {"Review.Base": [], "Review.Leaf": ["Review.Base"], "Review.Independent": []}) => {
    populateFixture(host);
    const names = Object.keys(graph), root = c.root;
    memory.put(root + '\\compile-order.txt', names.map(n => n.replace(/\./g, '/') + '.lean').join('\n') + '\n');
    memory.put(root + '\\audit-targets.tsv', names.map(n => n + '|' + n + '.checked').join('\n') + '\n');
    for (const name of names) {
      const imports = graph[name].length ? graph[name] : ['Mathlib.Review'];
      memory.put(root + '\\' + name.replace(/\./g, '\\') + '.lean', imports.map(n => 'import ' + n).join('\n') +
        '\ntheorem ' + name + '.checked : True := True.intro\n');
    }
    memory.put(root + '\\Audit.lean', names.map(n => 'import ' + n).join('\n') + '\n' +
      names.map(n => '#check ' + n + '.checked\n#print axioms ' + n + '.checked').join('\n') + '\n');
    return host;
  };
  host.startup = () => { startup(host); return host; };
  host.seedAnchors = () => { buildAll(host); return host; };
  host.run = () => vm.runInContext('processModulesParallel()', c, {timeout: 10000, filename: 'SIMULATED_scheduler_call.js'});
  host.installLock = () => {
    c.lockHeld = true; c.lockEverHeld = true;
    c.lockOwnerText = c.formatLockOwner({ROOT: c.keyPath(c.root), SCRIPT: c.keyPath(c.root + '\\tools\\native_runner.js'),
      PID: String(c.lockSelf.pid), CREATED: c.lockSelf.created, TOKEN: c.lockSelf.token, RUN_TAG: c.runTag});
    memory.put(c.lockPath + '\\owner.txt', c.lockOwnerText);
  };
  host.shutdownAndConditionalRelease = () => {
    const clean = c.parallelShutdown();
    if (clean) c.releaseRunnerLock();
    return clean;
  };
  return host;
}

module.exports = {makeHost, adaptComSetters, sha256, win};
