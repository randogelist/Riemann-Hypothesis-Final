'use strict';
// Reused Node-only synthetic process responses; no native process API.
const {sha256} = require('./mock_host');
const assert = require('assert');
const ordinarySuffixes = ['.olean', '.olean.private', '.olean.server', '.ir', '.dll'];
const largeSuffixes = ['.olean', '.olean.private', '.olean.server', '.olean.extra1', '.olean.extra2', '.ir', '.dll'];
let serial = 0;

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

module.exports = {instrument};
