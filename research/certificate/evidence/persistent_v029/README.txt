E:\RH-FAST STORAGE PROFILE — TARGETED NODE HOST REVIEW ONLY

From this evidence directory, with Node available:

  node profile_review.js PATH_TO_CANDIDATE_NATIVE_RUNNER_JS

Optional arguments after the candidate path are a baseline runner source
file and an output JSON report path. Defaults use the inert v0.2.8 runner
fixture and profile_results.json in this folder.

This review executes actual runner functions in Node's vm. It also executes
the actual main startup branches for a rejected package location and an
already active same-root owner. These branches return before compiler/cache
work. All filesystem, WMI, certutil, helper, and compiler responses are
synthetic and remain in memory. No native child process API is imported.

mock_host.js is the unchanged portable in-memory host from the prior review.
runtime_host.js reuses the prior synthetic helper/compiler response function;
its small module header supplies that function's dependencies. Virtual drives
C:, D:, E:, and F: are fixture directories, not probes of the user's machine.
The .cmd and C# text fixtures are never executed. The actual new extraction
launcher is outside this suite's scope.

Covered behavior:
- Proper normalized descendant boundaries and case-insensitive matching.
- Wrong-root rejection before environment, lock, log, or file writes.
- Preservation and read-only use of prior explicit/default import roots.
- Verified old-anchor migration to E:, corruption rejection, and warm reuse.
- Unchanged compilation/audit/helper identities, Mathlib location, and jobs.
- Independent per-version work, logs, and locks sharing verified E: anchors.
- Same-root live-owner protection and changed source/dependency invalidation.
- Exact comparison of unchanged validation/hash/lock/compiler function bodies
  against the v0.2.8 fixture.

Prior broad runtime/cache/helper/lock suites were not rerun. This report does
not relabel inherited results as fresh executions. Native E: availability,
permissions, ZIP extraction, CMD/WSH behavior, and native timings remain
unverified. Synthetic receipts and object bytes are not native PASS evidence
or Lean certification.

validation_summary.json gives the exact candidate/report/fixture hashes,
named scenario totals, and complete copy inventory for packaging.
