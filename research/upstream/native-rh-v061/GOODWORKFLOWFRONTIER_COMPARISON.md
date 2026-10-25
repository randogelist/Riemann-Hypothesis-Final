# GoodWorkflowFrontier comparison — cached Mathlib re-inference

Current RH branch: 30 source modules frozen, v0.6.0 -> FIX1 0 Lean source edits.
GOODWORKFLOWFRONTIER user policy: existing cached Mathlib .olean, one ZIP,
standalone run.cmd inside ZIP, native Windows Lean 4.33, 16 elaboration threads,
no Lake/network/PowerShell/Python/WSL, dependency graph replay, freeze-on-PASS.

The earlier branch reported Mathlib NOT_READY and 0/64 modules for v0.13.1.
That was environment discovery failure, not a theorem failure. The path
`...\.lake\packages\mathlib\.lake\build\lib\lean` was missed by
older runners. This FIX1 now checks that nested path and adds companion .olean
roots before compiling any source. A non-existing cache stops early with
MATHLIB_CACHE_NOT_FOUND, never requests Mathlib compilation.

Do not conflate this branch's 30 modules with the separate 64-module historical
GOODWORKFLOWFRONTIER source archive. Its exact reference source was not present
in this runtime; comparison is to user-confirmed workflow, not bytewise sources.

Mathematical scope is unchanged. Existence of an accepted finite RH witness is
NOT established: soundness and completeness still require actual theorems.
