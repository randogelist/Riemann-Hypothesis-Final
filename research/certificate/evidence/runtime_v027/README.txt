SCOPED FRESH HASH REVIEW — NODE HOST SIMULATION ONLY

This folder contains a portable developer review harness. It does not run
Windows Script Host, CMD, Lean, Lake, C#, or any native child process. It
executes the actual runner helper definitions in Node's vm, with all Windows
filesystem and process responses simulated in memory. The runner main entry
point is never executed.

Usage, from any directory with Node available:

  node fresh_hash_review.js PATH_TO_CANDIDATE_NATIVE_RUNNER_JS

Optional positional arguments:

  3: baseline runner source file
  4: pinned v0.1.0 legacy runner source file
  5: pinned v0.1.0 legacy run.cmd fixture text
  6: output JSON report path

The inherited compatibility suites can also be run from this folder:

  node inherited/cache_mock_tests.js PATH_TO_CANDIDATE_NATIVE_RUNNER_JS inherited_cache_results.json
  node inherited/helper_cache_mock_tests.js PATH_TO_CANDIDATE_NATIVE_RUNNER_JS inherited_helper_results.json
  node inherited/lock_mock_tests.js PATH_TO_CANDIDATE_NATIVE_RUNNER_JS inherited_lock_results.json

Their scenario assertions are unchanged. inherited_adaptations.json records
the two host-only compatibility changes: a synthetic certutil Exec response,
and an identical C# source-text fallback fixture when the candidate runner has
no sibling NativeSha256.cs. The lock harness is byte-preserved.

The default baseline and legacy inputs are the inert .txt files under
fixtures/. The .cmd text fixtures are not launchers. The C# fixture is never
compiled or executed. Synthetic object bytes and cache receipts exist only
inside the in-memory host and are not native PASS evidence.

mock_host.js is a byte-preserved copy of the previously used in-memory host.
The focused harness preserves the actual fileHash, freshHashSet, batch
transport/parser, and cache control flow. Only external host responses are
simulated. Counts refer to requested synthetic process operations, not native
elapsed times or benchmark results.

The JSON report records candidate/baseline/legacy/helper/host source hashes
and exact scenario outcomes. The payload file fault injections occur at
explicit phase boundaries; no atomic filesystem snapshot or comprehensive
concurrent-writer protection is claimed.

The package's run.cmd remains the sole native user launcher. This review
folder is never called by it.

validation_summary.json lists the exact report, harness and inert fixture
files for packaging, their hashes, final scenario totals and limitations.
