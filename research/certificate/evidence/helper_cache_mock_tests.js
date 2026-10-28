'use strict';
// Synthetic-host tests only. No Windows, C# or Lean compiler is executed.
const fs = require('fs');
const path = require('path');
const Module = require('module');
const assert = require('assert');
const crypto = require('crypto');
const runnerPath = process.argv[2];
if (!runnerPath) throw new Error('Usage: node helper_cache_mock_tests.js RUNNER.js [REPORT.json]');
const hostPath = path.join(__dirname, 'cache_mock_tests.js');
const hostSource = fs.readFileSync(hostPath, 'utf8');
const cut = hostSource.indexOf("scenario('save_restore_same_target_content_verified'");
if (cut < 0) throw new Error('Cannot locate synthetic-host declarations');
const hostModule = new Module(hostPath, module);
hostModule.filename = hostPath;
hostModule.paths = module.paths;
hostModule._compile(hostSource.slice(0, cut) + '\nmodule.exports = { setup };\n', hostPath);
const setupHost = hostModule.exports.setup;
const win = path.win32;
const sha = value => crypto.createHash('sha256').update(value).digest('hex');
const report = [];

function setup() {
  const f = setupHost();
  const c = f.c;
  f.csc = 'C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319\\csc.exe';
  f.framework = win.dirname(f.csc);
  f.hasherSource = c.root + '\\tools\\NativeSha256.cs';
  f.vfs.put(f.hasherSource, fs.readFileSync(path.join(path.dirname(runnerPath), 'NativeSha256.cs')));
  for (const leaf of ['csc.exe', 'mscorlib.dll', 'System.dll', 'System.Core.dll', 'clr.dll']) {
    f.vfs.put(f.framework + '\\' + leaf, 'synthetic installed input ' + leaf);
  }
  f.cscCalls = 0;
  f.selftestCalls = 0;
  f.failBuild = false;
  f.failSelfTest = false;
  c.runToFile = (exe, args, output) => {
    args = Array.from(args);
    if (exe === f.csc) {
      f.cscCalls++;
      const dest = args.find(a => a.startsWith('/out:')).slice(5);
      if (f.failBuild) {
        f.vfs.put(output, 'SYNTHETIC_CSC_FAILURE\n');
        return 1;
      }
      f.vfs.put(dest, 'SYNTHETIC_HELPER_EXE:' + sha(f.vfs.get(args.at(-1))) + ':' + sha(f.vfs.get(f.csc)));
      f.vfs.put(output, 'SYNTHETIC_CSC_SUCCESS\n');
      return 0;
    }
    assert.deepEqual(args, ['--self-test']);
    assert(f.vfs.get(exe).toString().startsWith('SYNTHETIC_HELPER_EXE:'), 'unexpected synthetic executable');
    f.selftestCalls++;
    f.vfs.put(output, f.failSelfTest ? 'SYNTHETIC_SELF_TEST_FAILURE\n' : 'BATCH_SHA256_SELF_TEST=PASS\r\n');
    return f.failSelfTest ? 1 : 0;
  };
  f.prepare = strict => c.prepareBatchHasher(strict === undefined ? true : strict);
  f.receipts = () => [...f.vfs.files.values()].filter(x => x.path.includes('\\hashers\\') && x.path.endsWith('\\receipt.txt') && !x.path.includes('.pending\\'));
  return f;
}

function scenario(name, action) {
  try {
    const detail = action() || {};
    report.push({ name, outcome: 'PASS_MOCK_HOST', ...detail });
    console.log('PASS ' + name);
  } catch (e) {
    report.push({ name, outcome: 'FAIL', error: e.stack || String(e) });
    console.log('FAIL ' + name + ': ' + e.message);
  }
}

scenario('cold_build_then_warm_hit_avoids_second_csc', () => {
  const f = setup(), first = f.prepare();
  assert(first && f.c.helperCacheState === 'BUILT_AND_SAVED');
  assert.equal(f.cscCalls, 1);
  assert.equal(f.receipts().length, 1);
  const second = f.prepare();
  assert(second && f.c.helperCacheState === 'HIT');
  assert.equal(second.exe, first.exe);
  assert.equal(f.cscCalls, 1);
  assert.equal(f.selftestCalls, 2);
  return { mock_csc_calls: f.cscCalls, mock_selftest_calls: f.selftestCalls };
});

scenario('same_source_in_new_package_reuses_helper', () => {
  const f = setup(), first = f.prepare(), oldSource = Buffer.from(f.vfs.get(f.hasherSource));
  f.c.root = 'C:\\Downloads\\FutureHilbertPackage';
  f.c.work = f.c.root + '\\.native-build';
  f.c.helpers = f.c.work + '\\runner';
  f.vfs.mkdir(f.c.helpers);
  f.vfs.put(f.c.root + '\\tools\\NativeSha256.cs', oldSource);
  const second = f.prepare();
  assert.equal(f.c.helperCacheState, 'HIT');
  assert.equal(second.exe, first.exe);
  assert.equal(f.cscCalls, 1);
});

for (const [label, mutate] of [
  ['source', f => f.vfs.put(f.hasherSource, f.vfs.get(f.hasherSource).toString() + '\n// source changed\n')],
  ['csc', f => f.vfs.put(f.csc, 'changed synthetic C# compiler')],
  ['reference', f => f.vfs.put(f.framework + '\\System.Core.dll', 'changed synthetic reference')],
  ['runtime', f => f.vfs.put(f.framework + '\\clr.dll', 'changed synthetic runtime')],
  ['new_optional_config', f => f.vfs.put(f.framework + '\\csc.exe.config', '<synthetic-config/>')]
]) {
  scenario('changed_' + label + '_forces_new_helper_build', () => {
    const f = setup(), first = f.prepare();
    mutate(f);
    const second = f.prepare();
    assert.equal(f.c.helperCacheState, 'BUILT_AND_SAVED');
    assert.notEqual(second.exe, first.exe);
    assert.equal(f.cscCalls, 2);
    assert.equal(f.receipts().length, 2);
  });
}

for (const leaf of ['helper.exe', 'source.cs', 'build.log', 'selftest.log']) {
  scenario('corrupt_' + leaf.replace(/\./g, '_') + '_rejected_and_rebuilt', () => {
    const f = setup(), first = f.prepare(), folder = win.dirname(first.exe);
    f.vfs.put(folder + '\\' + leaf, 'CORRUPTED_SYNTHETIC_CONTENT');
    const second = f.prepare();
    assert.equal(f.c.helperCacheState, 'BUILT_AND_SAVED');
    assert.notEqual(second.exe, first.exe);
    assert.equal(f.cscCalls, 2);
    assert(f.logs.some(x => x.startsWith('BATCH_HASH_HELPER_REJECTED=')));
  });
}

scenario('selftest_failure_publishes_no_entry_auto_falls_back', () => {
  const f = setup();
  f.failSelfTest = true;
  assert.equal(f.prepare(false), null);
  assert.equal(f.receipts().length, 0);
  assert(![...f.vfs.dirs.values()].some(p => p.endsWith('.pending')));
  assert(f.logs.some(x => x.startsWith('BATCH_HASH_FALLBACK=')));
});

scenario('selftest_failure_strict_mode_throws_without_entry', () => {
  const f = setup();
  f.failSelfTest = true;
  assert.throws(() => f.prepare(true), /self-test failed/);
  assert.equal(f.receipts().length, 0);
});

scenario('failed_csc_build_publishes_no_cache_entry', () => {
  const f = setup();
  f.failBuild = true;
  assert.equal(f.prepare(false), null);
  assert.equal(f.receipts().length, 0);
});

scenario('pending_helper_entry_is_ignored', () => {
  const f = setup(), first = f.prepare(), folder = win.dirname(first.exe);
  f.vfs.moveFolder(folder, folder + '.pending');
  const second = f.prepare();
  assert.equal(f.c.helperCacheState, 'BUILT_AND_SAVED');
  assert.notEqual(second.exe, first.exe);
  assert.equal(f.cscCalls, 2);
});

scenario('truncated_group_collision_requires_full_input_key', () => {
  const f = setup(), first = f.prepare(), realInput = f.c.hasherInput;
  f.c.hasherInput = (source, csc) => {
    const input = realInput(source, csc);
    // Force a synthetic same-prefix/different-full-key collision.
    input.key = input.key.slice(0, 24) + (input.key.slice(24) === '0'.repeat(40) ? '1' : '0').repeat(40);
    return input;
  };
  const second = f.prepare();
  assert.equal(f.c.helperCacheState, 'BUILT_AND_SAVED');
  assert.notEqual(second.exe, first.exe);
  assert.equal(f.cscCalls, 2);
  assert(f.logs.some(x => x.includes('receipt identity or success fields do not match')));
});

scenario('wrong_target_and_missing_build_pass_are_not_reused', () => {
  const f = setup(), first = f.prepare(), receipt = win.dirname(first.exe) + '\\receipt.txt';
  f.vfs.put(receipt, f.vfs.get(receipt).toString().replace('TARGET=LOCAL_COMPILER', 'TARGET=GITHUB_CI').replace('BUILD_PASS=1', 'BUILD_PASS=0'));
  const second = f.prepare();
  assert.notEqual(second.exe, first.exe);
  assert.equal(f.cscCalls, 2);
});

const summary = {
  kind: 'SYNTHETIC_WINDOWS_HOST_HELPER_CACHE_TESTS',
  native_windows_execution: false,
  actual_csharp_compilation: false,
  lean_compilation: false,
  runner: path.resolve(runnerPath),
  runner_sha256: sha(fs.readFileSync(runnerPath)),
  scenarios: report,
  passed: report.filter(x => x.outcome === 'PASS_MOCK_HOST').length,
  failed: report.filter(x => x.outcome === 'FAIL').length
};
if (process.argv[3]) fs.writeFileSync(process.argv[3], JSON.stringify(summary, null, 2) + '\n');
console.log(JSON.stringify({ passed: summary.passed, failed: summary.failed, native_compilers_executed: 0 }));
if (summary.failed) process.exitCode = 1;
