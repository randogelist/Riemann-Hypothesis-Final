# RH Hilbert Limit v0.2.21 — reported native semantic-equivalence checkpoint

Mode **A_TIER_LEAN**. Target **LOCAL_COMPILER**, native Windows Lean **4.33.0**.
This is an evidence-only checkpoint of the supplied successful v0.2.20 run.
All **96 Lean files** are byte-identical. No proof or definition was changed.

## What the supplied run establishes

The user-supplied output reports `PROJECT_BUILD=PASS`, `RUN=PASS`,
`AXIOM_AUDIT=PASS_STANDARD_LOGICAL_AXIOMS_ONLY`, `SORRYAX=NONE`,
2 compiled modules, 91 frozen reused modules, and 394 selected audit targets.
The exact endpoint declarations and their axiom lists are explicitly printed:

```lean
theorem nativeRH_of_exists_admissible_cancellationBudget
    (hWitness : ∃ W : CancellationBudget, W.Admissible) :
    _root_.RiemannHypothesis

theorem exists_admissible_cancellationBudget_iff_nativeRH :
    (∃ W : CancellationBudget, W.Admissible) ↔ _root_.RiemannHypothesis
```

Both printed axiom lists contain only `propext`, `Classical.choice` and
`Quot.sound`. The selected aggregate `CancellationAudit` reports its own
compilation-and-audit PASS, and the shutdown inventory clears.

## Exact meaning of the hypothetical witness

`CancellationBudget` has two natural-number fields: `cutoff` and `coefficient`.
Its required property is explicit:

```lean
def CancellationBudget.Admissible (W : CancellationBudget) : Prop :=
  ∀ n : ℕ, W.cutoff ≤ n →
    rowCancellation actualNormalizedMoment n ≤
      (W.coefficient : ℝ) * actualVariation n
```

Thus the assumed existence includes the inequality at every order after the
cutoff. From this hypothesis, the audited forward declaration concludes actual
Mathlib RH. Conversely, under RH the budget with cutoff zero and coefficient
zero is admissible. There are no extra spectral-calibration or dominant-
extraction hypotheses in the endpoint signatures.

The pair of natural numbers alone is not the full hypothesis. The universal
admissibility predicate has not been replaced by a terminating finite Bool
checker. Consequently, finite-checker soundness, completeness and the requested
finite-checker equivalence remain **OPEN**. The package retains
`FORMAL_CLOSURE=OPEN`. No unconditional admissible budget, accepted finite
checker witness, actual subexponential bound or unconditional RH is obtained.

## Frozen reuse

The active graph remains 92 ordinary modules plus `CancellationAudit`, with
394 audit targets. All compile/audit manifests and every Lean source remain
unchanged. The native runner differs only in package/version constants; its
cache, hashing, parallel/RAM admission, worker ownership and shutdown logic
are unchanged.

If all matching same-target source, dependency, toolchain, artifact and audit
identities validate, all **93 active modules are eligible for reuse**, with
**zero source-driven compilation tasks**. These are conditional expectations
for this version, separate from the observed 2 compiled / 91 reused counts
of v0.2.20. Missing or invalid cache evidence still causes a rebuild or failure.

## Run

Save the ZIP in Downloads and run:

```cmd
cd /d "%USERPROFILE%\Downloads" && (if not exist "E:\RH-FAST\workspaces" mkdir "E:\RH-FAST\workspaces") && tar -xf "RH_HILBERT_LIMIT_LEAN_v0_2_21_construction.zip" -C "E:\RH-FAST\workspaces" && cmd /k call "E:\RH-FAST\workspaces\RH_HILBERT_LIMIT_LEAN_v0_2_21_construction\run.cmd"
```

The command leaves CMD open and uses a new workspace under
`E:\RH-FAST\workspaces`, sharing the established `E:\RH-FAST\anchors` cache.
The runner uses installed native Lean and compatible cached Mathlib. No Lake,
Python, PowerShell, WSL or network setup is added to the runner.

## Evidence boundaries

The supplied message is preserved as a UTF-8/LF transcription of the log tail.
It includes explicit axiom output for **14 declarations**, including all
12 public declarations in `ActualCancellationWitness`; the reported aggregate
audit covers the selected **394 targets**. The declaration inventory has
1129 records: only those 394 selected records receive this new audit status;
the other 735 records retain their previous metadata.

Native receipt contents and source/dependency/toolchain/artifact fingerprints
were not supplied for independent inspection. The native runner must validate
them before cache reuse. No Lean, native runner/compiler, Lake, C# compiler or
CI was executed here, and no compiled artifacts or PASS receipts were created.
This checkpoint is not an Init and does not change the goal, mode or target.

Prior evidence is preserved. `SHA256SUMS.txt` covers every other payload file.
