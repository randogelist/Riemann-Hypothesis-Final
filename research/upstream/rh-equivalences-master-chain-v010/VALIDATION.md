# Validation

The release's complete local source set was freshly compiled with Lean 4.33.0
(commit `d8b18978322de05a8f3dba51ef03cf5461676c17`) against Mathlib commit
`db584cd6d46c92f209a44c0f1c829460d327499d` on Linux x86_64.

Compilation uses `-Ddebug.skipKernelTC=false`. The mandatory `Audit.lean`
inspects every declaration in the `MasterChain` namespace and its transitive
axiom dependencies, allowing only `propext`, `Classical.choice`, and
`Quot.sound`. It also checks that the three master names are proposition
definitions, not supplied axioms or claimed theorem proofs.

Evidence is in `validation/build.log`, `validation/audit.log`, and
`validation/result.json`; the latter records SHA-256 hashes of the compiled
Lean source files.

The Windows `run.cmd` is included for native Lean 4.33.0 and the user's existing
Mathlib cache. It was reviewed but cannot be executed as a Windows process in
the Linux validation environment. It rebuilds every project source into a
fresh directory and reruns the axiom audit; no compiled project cache is
included in the archive.

Local Linux compiler self-location needed a compatibility shim for the hosted
runtime's `/proc` executable-path handling. The shim only repairs executable
path resolution and does not change the elaborator, kernel, or trust flags.
The Windows runner does not use it.

This validation certifies the submitted proof terms with their displayed
hypotheses. It does not discharge the three actual-xi analytic bridges or
`NativeIntegrability`, and does not establish MASTER_3 or a numerical value.
