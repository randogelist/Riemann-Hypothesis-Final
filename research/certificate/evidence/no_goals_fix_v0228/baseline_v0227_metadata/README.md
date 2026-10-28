# RH Hilbert Limit v0.2.27 construction — first-five compile repair

Mode: A_TIER_LEAN. Target: LOCAL_COMPILER. Lean 4.33.0 with compatible cached Mathlib.

Repairs the user-reported v0.2.26 failures in ZeroBudgetSecondSector and
ZeroBudgetFiveAlgebra, and the same IntegrableOn typing issue in the blocked
ZeroBudgetFiveSector. The reciprocal-power proof now normalizes one_div before
rewriting. The triangle inequality uses abs_add_le.

All theorem statements, assumptions, definitions and imports are unchanged.
103 of 106 Lean files are byte-preserved. All 463 selected audit targets and
the FiveRowsAudit source are unchanged. The six active modules in the dependency
cone require native compilation/audit; 94 others are eligible for frozen reuse
only when same-target fingerprints and prior PASS receipts validate.

The parent native run FAILED. This repair has not been compiled or audited.
The last supplied successful finite checkpoint remains v0.2.24, index 0.
Static archive checks do not constitute a native Lean PASS.

The unchanged proof-source endpoint is:

```lean
forall n : Nat, n < 5 -> rowCancellation actualNormalizedMoment n = 0
```

Indices 5..9 remain gated on the first batch's native build and axiom audit PASS.
Universal admissibility of (0,0), finite-checker soundness/equivalence, an accepted
finite witness and unconditional RH remain open.

The runner changes only its package/version identity. Cache, compilation, audit,
scheduling, memory, locking and shutdown logic are preserved. The sole run.cmd
uses the established Windows installation; no Lake setup, Python, PowerShell,
WSL, local Lean execution or CI execution was added or performed.

```cmd
cd /d "%USERPROFILE%\Downloads" && (if not exist "E:\RH-FAST\workspaces" mkdir "E:\RH-FAST\workspaces") && tar -xf "RH_HILBERT_LIMIT_LEAN_v0_2_27_construction.zip" -C "E:\RH-FAST\workspaces" && cmd /k call "E:\RH-FAST\workspaces\RH_HILBERT_LIMIT_LEAN_v0_2_27_construction\run.cmd"
```
