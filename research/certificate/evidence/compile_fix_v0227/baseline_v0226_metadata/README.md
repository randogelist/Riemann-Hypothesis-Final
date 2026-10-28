# RH Hilbert Limit v0.2.26 construction — first five cancellation checks

This package prepares the exact finite endpoint, with no RH hypothesis:

```lean
forall n : Nat, n < 5 -> rowCancellation actualNormalizedMoment n = 0
```

The first five terms mean cancellation indices 0,1,2,3,4. They require
Bernstein row degrees through 5 and normalized moments through u_5.
The requested next batch is indices 5,6,7,8,9. That batch is not included
or verified and is gated on the first batch passing the user's native
compiler and axiom audit. It is not started merely by source packaging.

## Proof construction and status

The stronger theta-kernel bound prepares a zero-free strip through height
17/4, and hence the canonical-node inequality 4*abs(im node) <= re node.
Unit complex mass gives the complementary inequality
4*abs(im node) <= 1-re node. Exact rational cone multiplication handles
products of at most six factors. The canonical power sums identify these
products with the actual Bernstein weights; nonnegative weights give row
variation one and zero cancellation at indices below five.

No Lean, Lake, native Windows runner, or CI was run while preparing this
archive. All new proof claims remain pending native compilation and audit.
The latest supplied native PASS is v0.2.24 (index 0); no v0.2.25 PASS was
provided in this turn. Historical evidence and all prior sources remain.

## Preserved project and native run

All 102 previous Lean source files and 448 audit
targets are preserved. There are 15 new public declarations,
463 selected audit targets, and 100 active modules.
With valid v0.2.25 anchors, 96 ordinary modules may be reused
and the three added modules plus the final audit need compilation. With
only valid v0.2.24 ordinary anchors, 94 may be reused and six tasks need
compilation. These are eligibility estimates, not observed results.
Every reuse still requires exact same-target source/dependency/toolchain/
artifact fingerprints and a prior validated native audit PASS.

Compiler, cache, audit, scheduling, memory, lock, and shutdown behavior
are byte-preserved after normalizing package identity and result reporting.
The single run.cmd uses the established native Windows Lean 4.33.0 and
compatible cached Mathlib. It adds no Lake setup, Python, PowerShell or WSL.

## Open endpoint

Full admissibility of (0,0) still requires zero cancellation for EVERY
natural index. No universal propagation, accepted finite RH witness,
terminating finite-checker equivalence, or unconditional RH is established.
Even a successful first-five audit proves only the stated finite range.

```cmd
cd /d "%USERPROFILE%\Downloads" && (if not exist "E:\RH-FAST\workspaces" mkdir "E:\RH-FAST\workspaces") && tar -xf "RH_HILBERT_LIMIT_LEAN_v0_2_26_construction.zip" -C "E:\RH-FAST\workspaces" && cmd /k call "E:\RH-FAST\workspaces\RH_HILBERT_LIMIT_LEAN_v0_2_26_construction\run.cmd"
```
