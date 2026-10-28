# RH Hilbert Limit v0.2.19 — Cancellation proof repair

Mode **A_TIER_LEAN**. Target **LOCAL_COMPILER**, native Windows Lean **4.33.0**.
The supplied v0.2.18 log reports a compilation failure in `Cancellation` and a
compilation-and-axiom-audit PASS for `EventualGrowth`. This package repairs the
displayed goal. The repaired source has not been compiled here.

## Exact repair

The remaining equality contains the finite sum on one side and its definition
`rowVariation u n` on the other. The last equality in
`rowCancellation_le_of_local_flux` now unfolds that definition explicitly:

```lean
    _ = K * rowVariation u n + (H (n + 1) - H 0) := by
      rw [rowVariation, Finset.sum_add_distrib, ← Finset.mul_sum,
        sum_forward_differences]
```

This is the only Lean source edit. All 95 other Lean files are byte-identical,
including the now PASS-reported `EventualGrowth`. Definitions, theorem
statements, hypotheses, selected audit targets, and compile order are unchanged.
The `FAILED_STAGE=...EventualGrowth` line names the last attempted module;
the explicit failure is `Cancellation`, while `EventualGrowth` has its own PASS.

## Witness-to-RH endpoint retained

```lean
theorem nativeRH_of_exists_admissible_cancellationBudget
    (hWitness : ∃ W : CancellationBudget, W.Admissible) :
    _root_.RiemannHypothesis
```

`CancellationBudget` contains `cutoff : Nat` and `coefficient : Nat`.
Its admissibility is the explicit all-order condition:

```lean
def CancellationBudget.Admissible (W : CancellationBudget) : Prop :=
  ∀ n : ℕ, W.cutoff ≤ n →
    rowCancellation actualNormalizedMoment n ≤
      (W.coefficient : ℝ) * actualVariation n
```

The source derives the actual RH endpoint from this hypothesis through the
cancellation identity and eventual subexponential growth. The reverse semantic
implication is also present. `ActualCancellationWitness` was blocked by the
failed dependency, so these declarations still await the native compiler and
axiom audit. No particular admissible witness is obtained.

The source does not supply a terminating finite Bool checker for this universal
predicate. Finite-checker soundness, completeness and formal closure remain
**OPEN**. No concrete accepted finite witness or unconditional RH is established.

## Run

Save the ZIP in Downloads and run:

```cmd
cd /d "%USERPROFILE%\Downloads" && (if not exist "E:\RH-FAST\workspaces" mkdir "E:\RH-FAST\workspaces") && tar -xf "RH_HILBERT_LIMIT_LEAN_v0_2_19_construction.zip" -C "E:\RH-FAST\workspaces" && cmd /k call "E:\RH-FAST\workspaces\RH_HILBERT_LIMIT_LEAN_v0_2_19_construction\run.cmd"
```

The command extracts into a new workspace under `E:\RH-FAST\workspaces` and
leaves CMD open. The existing native cached runner, RAM admission, parallel
scheduling, hashing, anchor validation and worker-lock policy are preserved.
Its only edits are package/version constants. It uses installed Lean and cached
Mathlib, with shared anchors under `E:\RH-FAST\anchors`.

The active graph remains 92 ordinary modules plus `CancellationAudit`, with
394 selected declarations. If all matching same-target source, dependency,
toolchain, artifact and audit identities validate, 90 modules are eligible for
reuse; `Cancellation`, `ActualCancellationWitness` and `CancellationAudit` need
compilation and audit. These are expected counts, not observed results. Missing
or invalid cache evidence can require further work.

## Evidence and status

The supplied failure tail is preserved with its clipped opening. It contains an
EventualGrowth receipt path but not the receipt contents or per-declaration
axiom output; the native runner must revalidate that evidence before reuse.
The last supplied successful whole-package run remains v0.2.17.

No Lean, Lake, Windows compiler, C# compiler, native runner or CI execution was
performed here. Static source, manifest and archive checks do not establish a
native proof PASS. The previous package's evidence is preserved, and the
current evidence distinguishes that history from this pending repair.
`SHA256SUMS.txt` covers every other payload file in this archive.
