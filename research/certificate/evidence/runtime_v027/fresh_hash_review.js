'use strict';

// Node VM and in-memory host responses only. No native process API is imported.
// The real runner hash transport, parser, fileHash and cache functions execute.
const fs = require('fs');
const path = require('path');
const assert = require('assert');
const {MemoryWindowsFS, createHost, populateFixture, startup, buildAll, sha256} =
  require('./mock_host');
const win = path.win32;
const fixtures = path.join(__dirname, 'fixtures');
const candidate = path.resolve(process.argv[2] || path.join(__dirname, '../native_runner.js'));
const runners = {candidate,
  baseline: path.resolve(process.argv[3] || path.join(fixtures, 'baseline_native_runner.js.txt')),
  legacy: path.resolve(process.argv[4] || path.join(fixtures, 'legacy_native_runner.js.txt'))};
const legacyCmd = path.resolve(process.argv[5] || path.join(fixtures, 'legacy_run.cmd.txt'));
const reportPath = path.resolve(process.argv[6] || path.join(__dirname, 'fresh_hash_results.json'));
const helperBytes = fs.readFileSync(path.join(fixtures, 'NativeSha256.cs.txt'));
const candidateInitialSHA = sha256(fs.readFileSync(candidate));
const ordinarySuffixes = ['.olean', '.olean.private', '.olean.server', '.ir', '.dll'];
const largeSuffixes = ['.olean', '.olean.private', '.olean.server', '.olean.extra1',
  '.olean.extra2', '.ir', '.dll'];
const results = [];
let serial = 0;

function test(name, run) {
  try {
    results.push({name, status: 'PASS', details: run() || null});
    process.stdout.write('PASS ' + name + '\n');
  } catch (e) {
    results.push({name, status: 'FAIL', error: e.message, stack: e.stack});
    process.stdout.write('FAIL ' + name + ': ' + e.message + '\n');
  }
}
function instrument(h, options) {
  const c = h.context, m = h.memory;
  h.suffixes = options.large ? largeSuffixes : ordinarySuffixes;
  h.io = {copies: [], deletes: [], batches: [], cscCalls: 0, selftestCalls: 0,
    beforeBatch: null, afterBatchDigests: null, alterResult: null, afterBatch: null,
    copyHook: null, serialHashHook: null, helperExit: 0, omitResult: false};
  const oldCopy = c.fso.CopyFile, oldDelete = c.fso.DeleteFile,
    oldRun = c.runToFile, oldExec = c.shell.Exec;
  c.fso.CopyFile = (src, dst, overwrite) => {
    h.io.copies.push({src, dst}); oldCopy(src, dst, overwrite);
    if (h.io.copyHook) h.io.copyHook(src, dst);
  };
  c.fso.DeleteFile = (p, force) => { h.io.deletes.push(p); return oldDelete(p, force); };
  c.shell.Exec = command => {
    if (h.io.serialHashHook) h.io.serialHashHook(command);
    return oldExec(command);
  };
  h.csc = 'C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319\\csc.exe';
  c.runToFile = (exe, args, output) => {
    args = Array.from(args);
    if (exe === h.csc) {
      h.io.cscCalls++;
      const destination = args.find(a => String(a).startsWith('/out:')).slice(5);
      m.put(destination, 'SYNTHETIC_HELPER_EXE\n' + sha256(m.read(args[args.length - 1])));
      m.put(output, 'SYNTHETIC_CSC_SUCCESS\n'); return 0;
    }
    if (args.length === 1 && args[0] === '--self-test') {
      h.io.selftestCalls++;
      assert(m.text(exe).startsWith('SYNTHETIC_HELPER_EXE'));
      m.put(output, 'BATCH_SHA256_SELF_TEST=PASS\r\n'); return 0;
    }
    if (args.length === 4 && /^\d+$/.test(String(args[2]))) {
      const [requestPath, resultPath, workers, token] = args;
      const requestBytes = m.read(requestPath);
      const lines = requestBytes.toString('utf8').replace(/^\uFEFF/, '').trimEnd().split(/\r?\n/);
      const header = lines.shift().split('|');
      assert.strictEqual(header[0], 'RH_HILBERT_SHA256_REQUEST_V1');
      assert.strictEqual(header[1], token); assert.strictEqual(Number(header[2]), lines.length);
      assert(Number(workers) >= 1 && Number(workers) <= 16);
      const files = lines.map((line, i) => {
        const fields = line.split('|'); assert.strictEqual(fields.length, 2);
        assert.strictEqual(fields[0], String(i));
        assert.strictEqual(m.absolute(fields[1]), fields[1]); return fields[1];
      });
      assert.strictEqual(new Set(files.map(p => m.key(p))).size, files.length);
      const batch = {exe, requestPath, resultPath, workers: Number(workers), token,
        requestSHA: sha256(requestBytes), files, digests: []};
      h.io.batches.push(batch);
      if (h.io.beforeBatch) h.io.beforeBatch(batch);
      try {
        for (const file of files) batch.digests.push(sha256(m.read(file)));
      } catch (e) {
        m.put(output, 'SYNTHETIC_BATCH_FAILURE: ' + e.message); return 1;
      }
      if (h.io.afterBatchDigests) h.io.afterBatchDigests(batch);
      let response = ['RH_HILBERT_SHA256_RESULT_V1|' + token + '|' + files.length + '|' + batch.requestSHA];
      for (let i = 0; i < files.length; i++) response.push(i + '|' + batch.digests[i]);
      response.push('COMPLETE|' + token + '|' + files.length);
      if (h.io.alterResult) response = h.io.alterResult(response, batch) || response;
      m.put(output, 'SYNTHETIC_BATCH_SUCCESS; NO C# EXECUTION\n');
      if (!h.io.omitResult) m.put(resultPath, response.join('\r\n') + '\r\n');
      if (h.io.afterBatch) h.io.afterBatch(batch);
      return h.io.helperExit;
    }
    const rc = oldRun(exe, args, output), outIndex = args.indexOf('-o');
    if (rc === 0 && outIndex >= 0) {
      const stem = String(args[outIndex + 1]).replace(/\.olean$/, '');
      const source = String(args[args.length - 1]);
      for (const suffix of h.suffixes.slice(1)) m.put(stem + suffix,
        'MOCK_ARTIFACT ' + suffix + '\n' + sha256(m.read(source)));
    }
    return rc;
  };
  const instant = 1800000000000 + (++serial) * 1000;
  c.Date = class SimulatedDate extends Date {
    constructor(...args) { super(...(args.length ? args : [instant])); }
    static now() { return instant; }
  };
  c.runTag = '20261027T180000Z-' + serial;
  return h;
}
function setup(which = 'candidate', options = {}) {
  const h = instrument(createHost(runners[which], {memory: options.memory,
    root: options.root, env: Object.assign({RH_HASH_MODE: 'AUTO'}, options.env)}), options);
  if (which === 'candidate') assert.strictEqual(sha256(h.fullSource), candidateInitialSHA,
    'Candidate changed while the focused suite was running');
  if (!options.memory) h.layout = populateFixture(h);
  h.memory.put(h.memory.cwd + '\\tools\\native_runner.js', h.fullSource);
  h.memory.put(h.memory.cwd + '\\tools\\NativeSha256.cs', helperBytes);
  h.memory.put(h.memory.cwd + '\\run.cmd', fs.readFileSync(which === 'legacy' ?
    legacyCmd : path.join(fixtures, 'baseline_run.cmd.txt')));
  if (options.withCsc !== false) for (const leaf of ['csc.exe', 'mscorlib.dll',
    'System.dll', 'System.Core.dll', 'clr.dll']) {
    const target = win.dirname(h.csc) + '\\' + leaf;
    if (!h.memory.exists(target)) h.memory.put(target, 'MOCK installed framework ' + leaf);
  }
  if (options.start !== false) startup(h);
  return h;
}
function seed(which = 'candidate', options = {}) {
  const h = setup(which, options); buildAll(h);
  assert.strictEqual(h.context.failed, 0); assert.strictEqual(h.context.blocked, 0);
  return h;
}
function next(old, which = 'candidate', options = {}) {
  return setup(which, Object.assign({memory: old.memory, large: old.suffixes.length > 5,
    env: old.values}, options));
}
function copyMemory(memory) {
  const copy = new MemoryWindowsFS(memory.cwd);
  for (const entry of memory.entries.values()) {
    if (entry.directory) copy.mkdir(entry.path); else copy.put(entry.path, entry.data);
  }
  return copy;
}
function output(h, name = 'Review.Base') { return h.context.work + '\\' + name.replace(/\./g, '\\') + '.olean'; }
function family(h, name = 'Review.Base') { return Array.from(h.context.artifactFamily(output(h, name))); }
function receiptFiles(h, name = 'Review.Base') {
  return [...h.memory.entries.values()].filter(e => !e.directory && /\\receipt\.txt$/.test(e.path) &&
    /^MODULE=(.*)$/m.exec(h.memory.text(e.path))?.[1].trim() === name).map(e => e.path).sort();
}
function onlyReceipt(h, name = 'Review.Base') {
  const files = receiptFiles(h, name); assert.strictEqual(files.length, 1); return files[0];
}
function field(h, p, key, value) {
  const text = h.memory.text(p), re = new RegExp('^' + key + '=.*$', 'm');
  assert(re.test(text)); h.memory.put(p, text.replace(re, key + '=' + value));
}
function counts(h) {
  return {certutil: h.hashes.length, helper: h.io.batches.length,
    compiles: h.calls.filter(c => c.args.includes('-o')).length,
    audits: h.calls.filter(c => !c.args.includes('-o') && !c.args.some(x => /^--/.test(x))).length,
    copies: h.io.copies.length};
}
function delta(after, before) { return Object.fromEntries(Object.keys(after).map(k => [k, after[k] - before[k]])); }
function sampleFiles(h, count = 8) {
  return Array.from({length: count}, (_, i) => {
    const p = h.memory.cwd + '\\sample\\item-' + i + '.bin';
    h.memory.put(p, 'sample bytes ' + i); return p;
  });
}
function isFatal(h, e) { return typeof h.context.isFatalHashError === 'function' && h.context.isFatalHashError(e); }
function assertFreshMap(h, map, files) {
  assert.deepStrictEqual(Object.keys(map).sort(), files.map(p => h.context.keyPath(p)).sort());
  for (const p of files) assert.strictEqual(map[h.context.keyPath(p)], sha256(h.memory.read(p)));
}

test('fresh_batch_transport_returns_complete_isolated_map_and_unique_operations', () => {
  const h = setup(), c = h.context, files = sampleFiles(h), before = JSON.stringify(c.fileHashes);
  const beforeRequests = JSON.stringify(c.hashFiles);
  for (const p of files) c.fileHashes[c.keyPath(p)] = 'STALE_SENTINEL';
  const poisoned = JSON.stringify(c.fileHashes), start = counts(h);
  const first = c.freshHashSet(files, 'review-first'); assertFreshMap(h, first, files);
  h.memory.put(files[0], 'changed between fresh operations');
  const second = c.freshHashSet(files, 'review-second'); assertFreshMap(h, second, files);
  assert.notStrictEqual(first[c.keyPath(files[0])], second[c.keyPath(files[0])]);
  assert.strictEqual(JSON.stringify(c.fileHashes), poisoned);
  assert.strictEqual(JSON.stringify(c.hashFiles), beforeRequests);
  const recent = h.io.batches.slice(start.helper);
  assert.strictEqual(recent.length, 2);
  assert.notStrictEqual(recent[0].token, recent[1].token);
  assert.notStrictEqual(recent[0].requestPath, recent[1].requestPath);
  assert.notStrictEqual(recent[0].resultPath, recent[1].resultPath);
  return {operations: 2, startup_map_unchanged: true, counts: delta(counts(h), start),
    real_transport_parser_and_fileHash_executed: true};
});

test('batch_and_forced_certutil_return_identical_fresh_hashes', () => {
  const h = setup(), files = sampleFiles(h), start = counts(h);
  const batch = h.context.freshHashSet(files, 'review-batch');
  const serial = h.context.freshHashSet(files, 'review-serial', true);
  assert.deepStrictEqual(JSON.parse(JSON.stringify(batch)), JSON.parse(JSON.stringify(serial)));
  assertFreshMap(h, serial, files);
  return delta(counts(h), start);
});

test('auto_without_csc_uses_fresh_certutil_and_strict_batch_refuses_unavailable_helper', () => {
  const h = setup('candidate', {withCsc: false}), files = sampleFiles(h), start = counts(h);
  const hashes = h.context.freshHashSet(files, 'review-no-helper'); assertFreshMap(h, hashes, files);
  assert.strictEqual(h.io.batches.length - start.helper, 0);
  const strict = setup('candidate', {withCsc: false, start: false, env: {RH_HASH_MODE: 'BATCH'}});
  assert.throws(() => startup(strict), /csc|Framework|BATCH/i);
  return {fallback_counts: delta(counts(h), start), strict_unavailable_rejected: true};
});

test('helper_protocol_or_integrity_failure_is_fatal_and_never_publishes_partial_hashes', () => {
  const variants = ['nonzero', 'missing_result', 'missing_footer', 'wrong_token', 'duplicate_id',
    'unknown_id', 'malformed_digest', 'wrong_request_sha', 'extra_row', 'changed_request',
    'changed_helper', 'changed_source', 'file_disappears_after_launch'];
  const outcomes = [];
  for (const variant of variants) {
    const h = setup(), c = h.context, files = sampleFiles(h), before = JSON.stringify(c.fileHashes), start = counts(h);
    if (variant === 'nonzero') h.io.helperExit = 9;
    if (variant === 'missing_result') h.io.omitResult = true;
    h.io.alterResult = (rows, b) => {
      if (variant === 'missing_footer') rows.pop();
      if (variant === 'wrong_token') rows[0] = rows[0].replace(b.token, 'WRONG_TOKEN');
      if (variant === 'duplicate_id') rows[2] = rows[1];
      if (variant === 'unknown_id') rows[1] = '99|' + b.digests[0];
      if (variant === 'malformed_digest') rows[1] = '0|not-a-sha256';
      if (variant === 'wrong_request_sha') rows[0] = rows[0].replace(b.requestSHA, '0'.repeat(64));
      if (variant === 'extra_row') rows.splice(1, 0, rows[1]);
      return rows;
    };
    h.io.afterBatch = b => {
      if (variant === 'changed_request') h.memory.put(b.requestPath, h.memory.text(b.requestPath) + '\nCHANGED');
      if (variant === 'changed_helper') h.memory.put(b.exe, 'CHANGED_HELPER');
      if (variant === 'changed_source') h.memory.put(c.root + '\\tools\\NativeSha256.cs', 'CHANGED_SOURCE');
    };
    if (variant === 'file_disappears_after_launch') h.io.beforeBatch = () => h.memory.removeFile(files[0]);
    let caught; try { c.freshHashSet(files, 'review-failure-' + variant); } catch (e) { caught = e; }
    assert(caught && isFatal(h, caught), variant + ' must be fatal');
    assert.strictEqual(JSON.stringify(c.fileHashes), before);
    const payloadSerialHashes = h.hashes.slice(start.certutil).filter(p => files.some(f => h.memory.key(p) === h.memory.key(f)));
    assert.strictEqual(payloadSerialHashes.length, 0, 'no payload fallback after helper execution');
    outcomes.push({variant, fatal: true, no_partial_or_fallback: true});
  }
  return outcomes;
});

test('warm_reuse_operation_counts_improve_on_same_five_artifact_fixture', () => {
  const all = {};
  for (const which of ['baseline', 'candidate']) {
    const first = seed(which), h = next(first, which), start = counts(h);
    const requestedBefore = JSON.stringify(h.context.hashFiles);
    const working = Array.from(h.context.ordered).flatMap(name => family(h, name));
    for (const p of working) h.context.fileHashes[h.context.keyPath(p)] = 'STALE_WORKING_SENTINEL';
    buildAll(h); const observed = delta(counts(h), start);
    assert.strictEqual(observed.compiles, 0); assert.strictEqual(observed.audits, 0);
    assert.strictEqual(observed.copies, 0); assert.strictEqual(h.context.workingRetained, 3);
    assert.strictEqual(JSON.stringify(h.context.hashFiles), requestedBefore);
    if (which === 'candidate') {
      const batches = h.io.batches.slice(start.helper);
      for (const name of h.context.ordered) {
        const dir = win.dirname(onlyReceipt(h, name)), local = family(h, name);
        const required = local.concat(local.map(p => dir + '\\artifacts\\' + win.basename(p)),
          [dir + '\\source.lean', dir + '\\audit.log']);
        assert(batches.some(b => required.every(p => b.files.some(f => h.memory.key(f) === h.memory.key(p)))),
          'one fresh current-candidate batch must cover anchor and exact working family');
      }
    }
    all[which] = observed;
  }
  assert(all.candidate.certutil < all.baseline.certutil);
  assert(all.candidate.certutil + all.candidate.helper < all.baseline.certutil + all.baseline.helper);
  return {synthetic_modules: 3, artifact_files_per_module: 5, observed: all, native_timing_claim: false};
});

test('current_legacy_audit_and_helper_identities_are_unchanged_without_global_pollution', () => {
  const identities = {};
  for (const which of ['baseline', 'candidate']) {
    const h = seed(which), c = h.context;
    const beforeKeys = Object.keys(c.hashFiles).sort();
    const helperInput = c.hasherInput(c.root + '\\tools\\NativeSha256.cs', h.csc);
    assert.deepStrictEqual(Object.keys(c.hashFiles).sort(), beforeKeys);
    assert(!beforeKeys.some(k => k.includes('\\microsoft.net\\') || k.endsWith('\\nativesha256.cs')),
      'helper bootstrap paths entered project dependency hashFiles');
    identities[which] = {
      globalKey: c.globalKey, legacyGlobalKey: c.legacyGlobalKey, helperInputKey: helperInput.key,
      modules: Object.fromEntries(Array.from(c.ordered).map(name => [name, {
        input: c.moduleInput(name).key, artifact: c.artifactHashes[name],
        audit: c.auditKey(c.moduleKeys[name], c.artifactHashes[name], c.auditTargets[name], c.AUDIT_POLICY)
      }]))
    };
  }
  assert.deepStrictEqual(identities.candidate, identities.baseline);
  const legacy = seed('legacy', {large: true}), verified = {};
  for (const which of ['baseline', 'candidate']) {
    const h = setup(which, {memory: copyMemory(legacy.memory), large: true}); buildAll(h);
    assert.strictEqual(h.context.migrated, 3);
    verified[which] = Object.values(h.context.legacyVerified).map(value => ({
      module: value.r.MODULE, input: value.r.INPUT_SHA256, artifact: value.artifactKey,
      targets: Array.from(value.targets)
    })).sort((a, b) => a.module.localeCompare(b.module));
  }
  assert.deepStrictEqual(verified.candidate, verified.baseline);
  return {identities: identities.candidate, legacy_receipt_identities: verified.candidate,
    helper_paths_absent_from_global_hashFiles: true};
});

test('corrupt_missing_or_tampered_anchor_cannot_be_bypassed_by_valid_work_or_stale_hashes', () => {
  const variants = ['artifact', 'missing_artifact', 'source', 'audit', 'unclean_rehashed_audit',
    'wrong_target', 'wrong_module', 'build_pass', 'audit_pass', 'audit_key'];
  const outcomes = [];
  for (const variant of variants) {
    const first = seed(), receipt = onlyReceipt(first), dir = win.dirname(receipt), h = next(first), c = h.context;
    const artifact = dir + '\\artifacts\\Base.olean';
    c.fileHashes[c.keyPath(artifact)] = sha256(h.memory.read(artifact));
    if (variant === 'artifact') h.memory.put(artifact, 'CORRUPT');
    if (variant === 'missing_artifact') h.memory.removeFile(artifact);
    if (variant === 'source') h.memory.put(dir + '\\source.lean', 'CORRUPT');
    if (variant === 'audit') h.memory.put(dir + '\\audit.log', 'CORRUPT');
    if (variant === 'unclean_rehashed_audit') {
      h.memory.put(dir + '\\audit.log', "'Review.base' depends on axioms: [sorryAx]\n");
      field(h, receipt, 'AUDIT_LOG_SHA256', sha256(h.memory.read(dir + '\\audit.log')));
    }
    if (variant === 'wrong_target') field(h, receipt, 'TARGET', 'OTHER_TARGET');
    if (variant === 'wrong_module') field(h, receipt, 'MODULE', 'Review.Other');
    if (variant === 'build_pass') field(h, receipt, 'BUILD_PASS', '0');
    if (variant === 'audit_pass') field(h, receipt, 'AUDIT_PASS', '0');
    if (variant === 'audit_key') field(h, receipt, 'AUDIT_KEY', '0'.repeat(64));
    assert.strictEqual(c.restoreAnchor('Review.Base', c.moduleInput('Review.Base')), null, variant);
    assert.strictEqual(c.workingRetained, 0); assert(!c.moduleKeys['Review.Base']);
    outcomes.push({variant, rejected: true});
  }
  return outcomes;
});

test('working_snapshot_is_one_use_then_changed_bytes_are_freshly_rechecked', () => {
  const first = seed('candidate', {large: true}), h = next(first), c = h.context;
  const dir = win.dirname(onlyReceipt(h)), out = output(h);
  const scope = {active: true, module: 'Review.Base', outputKey: c.keyPath(out)};
  const checked = c.readAnchorCore('Review.Base', dir, out, scope);
  assert(checked.workingDigest, 'current candidate should carry one-use working snapshot');
  assert.strictEqual(c.workingArtifactsMatch('Review.Base', out, checked, scope), true);
  h.memory.put(out, 'CHANGED_AFTER_FIRST_CONSUMPTION');
  const before = counts(h);
  assert.strictEqual(c.workingArtifactsMatch('Review.Base', out, checked, scope), false);
  assert(counts(h).helper > before.helper, 'second check must execute a new batch');
  return {second_consumption_fresh: true, counts: delta(counts(h), before)};
});

test('different_scope_identity_cannot_consume_a_prior_working_snapshot', () => {
  const first = seed('candidate', {large: true}), h = next(first), c = h.context;
  const out = output(h), scope = {active: true, module: 'Review.Base', outputKey: c.keyPath(out)};
  const checked = c.readAnchorCore('Review.Base', win.dirname(onlyReceipt(h)), out, scope);
  assert(checked.workingDigest);
  h.memory.put(out, 'CHANGED_BEFORE_DIFFERENT_SCOPE');
  const otherScope = {active: true, module: 'Review.Base', outputKey: c.keyPath(out)};
  const before = counts(h);
  assert.strictEqual(c.workingArtifactsMatch('Review.Base', out, checked, otherScope), false);
  assert(counts(h).helper > before.helper, 'equal fields do not establish scope object identity');
  assert(!checked.workingDigest, 'rejected snapshot must also be discarded');
  return {different_object_identity_forces_fresh_hashes: true};
});

test('missing_changed_extra_and_renamed_working_files_restore_exact_fresh_family', () => {
  const outcomes = [];
  for (const variant of ['missing', 'changed', 'extra', 'renamed']) {
    const first = seed('candidate', {large: true}), expected = Object.fromEntries(family(first).map(p => [win.basename(p), sha256(first.memory.read(p))]));
    const h = next(first), c = h.context, out = output(h), before = counts(h);
    if (variant === 'missing') h.memory.removeFile(out + '.private');
    if (variant === 'changed') h.memory.put(out + '.private', 'CHANGED_WORK');
    if (variant === 'extra') h.memory.put(out + '.unexpected', 'EXTRA_WORK');
    if (variant === 'renamed') { const b = h.memory.read(out + '.private'); h.memory.removeFile(out + '.private'); h.memory.put(out + '.renamed', b); }
    const restored = c.restoreAnchor('Review.Base', c.moduleInput('Review.Base'));
    assert(restored && !restored.retained);
    const actual = Object.fromEntries(family(h).map(p => [win.basename(p), sha256(h.memory.read(p))]));
    assert.deepStrictEqual(actual, expected);
    const batches = h.io.batches.slice(before.helper);
    assert(batches.some(b => b.files.every(p => h.memory.key(p).startsWith(h.memory.key(c.work) + '\\'))), 'fresh post-copy family batch');
    outcomes.push({variant, exact_restored_family: true, counts: delta(counts(h), before)});
  }
  return outcomes;
});

test('changed_anchor_between_validation_and_copy_and_corrupt_destination_are_rejected', () => {
  const outcomes = [];
  for (const variant of ['anchor_changed_before_copy', 'destination_corrupted']) {
    const first = seed('candidate', {large: true}), h = next(first), c = h.context;
    const dir = win.dirname(onlyReceipt(h)), anchor = dir + '\\artifacts\\Base.olean';
    c.clearOutputs('Review.Base'); let injected = false;
    if (variant === 'anchor_changed_before_copy') h.io.afterBatch = b => {
      if (!injected && b.files.includes(anchor)) { h.memory.put(anchor, 'CHANGED_AFTER_ANCHOR_HASH'); injected = true; }
    };
    if (variant === 'destination_corrupted') h.io.copyHook = (src, dst) => {
      if (!injected && h.memory.key(dst) === h.memory.key(output(h))) { h.memory.put(dst, 'CORRUPTED_COPY'); injected = true; }
    };
    assert.strictEqual(c.restoreAnchor('Review.Base', c.moduleInput('Review.Base')), null);
    assert(injected); assert.strictEqual(family(h).length, 0); assert(!c.moduleKeys['Review.Base']);
    outcomes.push({variant, rejected_and_partial_work_cleared: true});
  }
  return outcomes;
});

test('rejected_candidate_does_not_leak_working_hashes_into_next_candidate', () => {
  const first = seed('candidate', {large: true}), fc = first.context;
  fc.saveAnchor('Review.Base', fc.moduleInput('Review.Base'), fc.helpers + '\\Review.Base.audit.log', output(first), '');
  const receipts = receiptFiles(first); assert.strictEqual(receipts.length, 2);
  const newest = receipts[1], newestDir = win.dirname(newest); field(first, newest, 'AUDIT_KEY', '0'.repeat(64));
  const h = next(first), c = h.context; let injected = false;
  h.io.afterBatch = b => {
    if (!injected && b.files.some(p => p.startsWith(newestDir + '\\'))) {
      h.memory.put(output(h), 'CHANGED_BETWEEN_CANDIDATES'); injected = true;
    }
  };
  const restored = c.restoreAnchor('Review.Base', c.moduleInput('Review.Base'));
  assert(injected); assert(restored && !restored.retained);
  assert.strictEqual(restored.receipt, receipts[0]); assert(h.memory.text(output(h)).startsWith('MOCK_OLEAN'));
  return {rejected_candidate_snapshot_discarded: true, second_candidate_restored: true};
});

test('staged_copy_change_never_commits_anchor_or_module_key', () => {
  const h = setup('candidate', {large: true}), c = h.context, name = 'Review.Base';
  // Obtain a clean synthetic compile/audit, then delete its anchor and acceptance.
  c.processModule(name); const receipt = onlyReceipt(h); h.memory.removeFolder(win.dirname(receipt));
  delete c.moduleKeys[name]; delete c.artifactHashes[name];
  let injected = false;
  h.io.afterBatch = b => {
    if (!injected && b.files.some(p => h.memory.key(p) === h.memory.key(output(h)))) {
      h.memory.put(output(h), 'CHANGED_AFTER_PRECOPY_HASH'); injected = true;
    }
  };
  assert.throws(() => c.saveAnchor(name, c.moduleInput(name), c.helpers + '\\Review.Base.audit.log', output(h), ''), /copy|hash|changed/i);
  assert(injected); assert(!c.moduleKeys[name]);
  assert.strictEqual(receiptFiles(h).filter(p => !p.includes('.pending\\')).length, 0);
  return {staged_copy_mismatch_rejected: true, no_committed_receipt: true};
});

test('operational_helper_failure_escapes_restore_and_working_broad_catches', () => {
  const outcomes = [];
  for (const where of ['restore', 'working']) {
    const first = seed('candidate', {large: true}), h = next(first), c = h.context;
    let checked;
    if (where === 'working') checked = c.readAnchorCore('Review.Base', win.dirname(onlyReceipt(h)));
    h.io.helperExit = 23;
    let caught;
    try {
      if (where === 'restore') c.restoreAnchor('Review.Base', c.moduleInput('Review.Base'));
      else c.workingArtifactsMatch('Review.Base', output(h), checked);
    } catch (e) { caught = e; }
    assert(caught && isFatal(h, caught), where + ' swallowed an operational helper failure');
    assert(!c.moduleKeys['Review.Base']); assert.strictEqual(c.workingRetained, 0);
    outcomes.push({where, fatal_propagated: true});
  }
  return outcomes;
});

test('operational_helper_failure_escapes_legacy_restore_and_recursive_dependency_catches', () => {
  const outcomes = [];
  for (const where of ['legacy_restore', 'legacy_dependency_recursion']) {
    const first = seed('legacy', {large: true}), h = next(first), c = h.context;
    const baseReceipt = onlyReceipt(h), baseDir = win.dirname(baseReceipt);
    if (where === 'legacy_dependency_recursion') {
      const receipt = c.parseReceipt(h.memory.text(baseReceipt));
      c.artifactHashes['Review.Base'] = receipt.ARTIFACTS_SHA256;
      h.io.beforeBatch = batch => {
        if (batch.files.some(p => p.startsWith(baseDir + '\\'))) h.io.helperExit = 31;
      };
    } else h.io.helperExit = 31;
    let caught;
    try {
      if (where === 'legacy_restore') c.restoreAnchor('Review.Base', c.moduleInput('Review.Base'));
      else c.verifyLegacy('Review.Leaf', win.dirname(onlyReceipt(h, 'Review.Leaf')), {});
    } catch (e) { caught = e; }
    assert(caught && isFatal(h, caught), where + ' swallowed operational hashing failure');
    assert(!c.moduleKeys['Review.Base']); assert(!c.moduleKeys['Review.Leaf']);
    outcomes.push({where, fatal_propagated: true});
  }
  return outcomes;
});

test('audit_only_refresh_still_reuses_objects_then_reuses_refreshed_receipt', () => {
  const first = seed(), targets = first.memory.cwd + '\\audit-targets.tsv';
  first.memory.put(targets, first.memory.text(targets) + 'Review.Base|Review.extra\n');
  const second = next(first), before = counts(second); buildAll(second);
  const refresh = delta(counts(second), before);
  assert.strictEqual(refresh.compiles, 0); assert.strictEqual(refresh.audits, 1);
  const third = next(second), beforeThird = counts(third); buildAll(third);
  const warm = delta(counts(third), beforeThird);
  assert.strictEqual(warm.compiles, 0); assert.strictEqual(warm.audits, 0); assert.strictEqual(warm.copies, 0);
  return {refresh, subsequent_warm: warm};
});

test('next_run_never_reuses_previous_working_hash_snapshot', () => {
  const first = seed(), warm = next(first); buildAll(warm);
  warm.memory.put(output(warm), 'CHANGED_BETWEEN_RUNS');
  const nextRun = next(warm), before = counts(nextRun); nextRun.context.processModule('Review.Base');
  assert.strictEqual(nextRun.context.workingRetained, 0);
  assert(nextRun.memory.text(output(nextRun)).startsWith('MOCK_OLEAN'));
  assert.strictEqual(delta(counts(nextRun), before).compiles, 0);
  assert(delta(counts(nextRun), before).copies > 0);
  return {previous_run_snapshot_not_used: true, counts: delta(counts(nextRun), before)};
});

test('legacy_migration_does_not_cache_working_snapshots_in_legacyVerified', () => {
  const first = seed('legacy', {large: true}), h = next(first), c = h.context;
  buildAll(h);
  assert.strictEqual(c.failed, 0); assert.strictEqual(c.blocked, 0);
  assert.strictEqual(c.migrated, 3);
  for (const value of Object.values(c.legacyVerified)) assert(!value.workingDigest, 'legacy memo retained a working snapshot');
  const out = output(h), receipt = receiptFiles(h).filter(p => /^SCHEMA=RH_HILBERT_LOCAL_ANCHOR_V2$/m.test(h.memory.text(p))).pop();
  assert(receipt);
  h.memory.put(out, 'CHANGED_AFTER_LEGACY_MIGRATION');
  const restored = c.restoreAnchor('Review.Base', c.moduleInput('Review.Base'));
  assert(restored && !restored.retained); assert(h.memory.text(out).startsWith('MOCK_OLEAN'));
  return {legacy_modules_migrated: c.migrated, no_legacy_working_snapshot: true};
});

test('timed_result_json_preserves_success_failure_error_stage_and_compilation_identity', () => {
  const h = setup(), c = h.context;
  c.timedStage('REVIEW_SUCCESS', () => c.processModule('Review.Base'));
  const before = {global: c.globalKey, legacy: c.legacyGlobalKey,
    input: c.moduleInput('Review.Base').key,
    audit: c.auditKey(c.moduleKeys['Review.Base'], c.artifactHashes['Review.Base'], c.auditTargets['Review.Base'], c.AUDIT_POLICY)};
  c.result(true, 'Synthetic successful integration only');
  const good = JSON.parse(h.memory.text(c.root + '\\run-result.json'));
  assert.strictEqual(good.build, 'PASS');
  assert(good.stage_timings.some(x => x.name === 'REVIEW_SUCCESS' && x.outcome === 'RETURNED'));
  assert(good.module_timings.some(x => x.name === 'Review.Base' && x.outcome === 'COMPILED_AUDITED'));
  assert(good.hash_timings.length > 0);
  assert.strictEqual(good.logical_tool_launches.certutil, h.hashes.length);
  assert.strictEqual(good.logical_tool_launches.helper, h.io.batches.length + h.io.selftestCalls);
  assert.strictEqual(good.logical_tool_launches.csc, h.io.cscCalls);
  const original = new Error('Original synthetic phase failure: "quoted"\nsecond line');
  let caught;
  try { c.timedStage('REVIEW_FAILED_STAGE', () => { throw original; }); } catch (e) { caught = e; }
  assert.strictEqual(caught, original); assert.strictEqual(c.stage, 'REVIEW_FAILED_STAGE');
  c.result(false, caught.message);
  const failed = JSON.parse(h.memory.text(c.root + '\\run-result.json'));
  assert.strictEqual(failed.build, 'FAIL'); assert.strictEqual(failed.message, original.message);
  assert(failed.stage_timings.some(x => x.name === 'REVIEW_FAILED_STAGE' && x.outcome === 'ERROR'));
  for (const records of [failed.stage_timings, failed.module_timings, failed.hash_timings])
    for (const record of records) assert(Number.isFinite(record.elapsed_ms) && record.elapsed_ms >= 0);
  c.directLaunchCounts.other += 17; c.directLaunchCounts.total += 17;
  c.hashPhaseTotals.files += 19; c.makeGlobalKey();
  const after = {global: c.globalKey, legacy: c.legacyGlobalKey,
    input: c.moduleInput('Review.Base').key,
    audit: c.auditKey(c.moduleKeys['Review.Base'], c.artifactHashes['Review.Base'], c.auditTargets['Review.Base'], c.AUDIT_POLICY)};
  assert.deepStrictEqual(after, before);
  return {success_and_failure_json_parse: true, original_error_object_preserved: true,
    failed_stage_preserved: true, counters_not_in_compilation_identity: true};
});

assert.strictEqual(sha256(fs.readFileSync(candidate)), candidateInitialSHA,
  'Candidate changed during the focused suite');
const report = {
  schema: 'RH_HILBERT_SCOPED_FRESH_HASH_NODE_REVIEW_V026',
  runner_sha256: candidateInitialSHA,
  baseline_runner_sha256: sha256(fs.readFileSync(runners.baseline)),
  legacy_runner_sha256: sha256(fs.readFileSync(runners.legacy)),
  legacy_cmd_sha256: sha256(fs.readFileSync(legacyCmd)),
  mock_host_sha256: sha256(fs.readFileSync(path.join(__dirname, 'mock_host.js'))),
  helper_source_sha256: sha256(helperBytes),
  method: 'Node VM runs actual runner functions; in-memory filesystem and synthetic certutil/C#/compiler responses only',
  node_version: process.version,
  native_windows_execution: false, lean_execution: false, lake_execution: false,
  csharp_compilation_or_execution: false, ci_execution: false, native_child_processes: 0,
  source_edits: 'Only this temporary review harness; no runner, helper, output package or Lean source edits',
  limitations: ['No Windows Script Host, CMD quoting, native filesystem locking or native timing validation',
    'Fault injection occurs at explicit operation boundaries; no atomic filesystem snapshot is claimed',
    'Synthetic receipts and compiled bytes are not native PASS or Lean proof evidence'],
  passed: results.filter(x => x.status === 'PASS').length,
  failed: results.filter(x => x.status === 'FAIL').length,
  results
};
fs.writeFileSync(reportPath, JSON.stringify(report, null, 2) + '\n');
process.stdout.write(JSON.stringify({passed: report.passed, failed: report.failed, runner_sha256: report.runner_sha256}) + '\n');
process.exitCode = report.failed ? 1 : 0;
