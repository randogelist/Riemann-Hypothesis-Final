Focused graph-startup and empty-file hashing review
==================================================

Scope: Node VM and an in-memory Windows host. No Lean, Lake, native Windows,
C# compiler/runtime, Wine, CI, or native child process was executed. Simulated
compiler responses exercise runner control flow only; they are not proof,
compiler, or native PASS receipts.

Candidate SHA256:
eaf8ebc221f08607bd2256827e8bbafb5e5b2e2509e3e71513fe994db2d9eb97

Results: graph review 12/12; empty-file hash review 16/16; total 28/28.
The graph suite includes 34 parser fixtures, byte-hash checks and header
comparisons for all 86 supplied Lean files, exact artifact companions/order,
cache shadowing and source-missing behavior, manifest/key equivalence, fresh
source/artifact visibility, and 17 unchanged profile/lock/identity functions.
The empty-file suite includes real runner hash transport/parser calls, binary
Size/Position/EOS probes, negative and mutation cases, first helper-cache save,
warm helper-cache reuse, and reproduction of the baseline empty-log failure.

From this evidence directory, with Node available, replace <package-root>
with the extracted package directory. The package must contain the frozen
86 Lean sources named in fixtures/project_sources.json. Commands below use
new report names to preserve the packaged review records:

  node graph_review.js "<package-root>/tools/native_runner.js" fixtures/baseline_native_runner.js.txt "<package-root>" graph_results.rerun.json
  node empty_file_review.js "<package-root>/tools/native_runner.js" fixtures/baseline_native_runner.js.txt empty_file_results.rerun.json

All runner, baseline, project-root, and report paths are explicit CLI inputs.
The default baseline and all host/fixture dependencies live in this directory.
The baseline runner, CMD, and C# source are inert .txt fixtures; only Node
scripts are used by this review. mock_host.js loads actual runner helper
bodies before the main-entry marker and adapts only WSH COM environment
property-put syntax for the Node VM. Native responses are supplied by the
host. The binary adapter loads Buffer bytes and never treats decoded empty
text as evidence of a zero-byte file.

operation_counts.json reports counts for the same synthetic graph before and
after. GetAbsolutePathName calls: 867 -> 364; GetFileName: 13,829 -> 291;
Lean source reads: 59 -> 55; GetFolder: 5 -> 5. FileExists: 112 -> 114,
FolderExists: 7 -> 9, reflecting added diagnostics. Full/strict-plus-header
scan characters: 594,931 -> 3,744. Actual external source bytes still have
to be read and fingerprinted. These counts are not a Windows timing claim.

Global, legacy, external, module-input, artifact, and audit keys agree on the
synthetic fixture. Requested hash paths agree; content digests agree except
for the expected runner-source provenance digest. No mathematical source,
compiler policy, audit policy, launcher, or C# source was changed by these
tests. The real native run remains pending.

Prior runtime/cache 86 cases, observer 19 cases, and storage-profile 11 cases
were not rerun. This review is restricted to the changed graph/header/hash
paths and directly relevant helper-cache integration. A first static-test
inventory mistakenly named a nonexistent baseline helper legacyModuleInput;
that harness-only name was corrected to the actual verifyLegacy helper.
No runner change was needed after these tests.
