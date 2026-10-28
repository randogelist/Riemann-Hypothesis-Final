# RH Hilbert Limit v0.2.20 — zero-budget cast repair

Mode **A_TIER_LEAN**. Target **LOCAL_COMPILER**, native Windows Lean **4.33.0**.
The uploaded v0.2.19 tail reports compilation and axiom-audit PASS for
`Cancellation`, followed by a compilation failure in `ActualCancellationWitness`.
This package repairs that displayed failure. Native validation remains pending.

## Exact repair

In `zero_cancellationBudget_admissible_of_nativeRH`, the `change` target now
retains the cast of the natural-number coefficient:

```lean
  rw [rowCancellation_eq]
  change ((n : ℝ) + 1) * (actualVariation (n + 1) - actualVariation n) ≤
    ((0 : ℕ) : ℝ) * actualVariation n
  rw [hv (n + 1), hv n]
  simp
```

Only `(0 : ℝ)` was replaced with `((0 : ℕ) : ℝ)`. The record coefficient has
type Nat. `change` requires definitional equality and does not supply the
propositional cast-zero simplification; the final `simp` performs that step.
All definitions, theorem statements, quantifiers and hypotheses are unchanged.
All other 95 Lean sources are byte-identical, including the newly passed
`Cancellation` and the previously passed and now reused `EventualGrowth`.
The harmless unused-simp warning in the frozen Cancellation source is retained.

## Witness-to-RH endpoint retained

```lean
theorem nativeRH_of_exists_admissible_cancellationBudget
    (hWitness : ∃ W : CancellationBudget, W.Admissible) :
    _root_.RiemannHypothesis
```

The witness data are `cutoff : Nat` and `coefficient : Nat`, with explicit
all-order admissibility:

```lean
def CancellationBudget.Admissible (W : CancellationBudget) : Prop :=
  ∀ n : ℕ, W.cutoff ≤ n →
    rowCancellation actualNormalizedMoment n ≤
      (W.coefficient : ℝ) * actualVariation n
```

The forward proof and the semantic reverse implication remain in the source.
The entire module and selected aggregate still need successful native
compilation and axiom audit. The reported failure occurred in the reverse
zero-budget lemma; earlier declaration positions are not counted as an audited
module PASS.

Admissibility has not been reduced to a terminating finite Bool checker.
Finite-checker soundness, completeness and formal closure remain **OPEN**.
No particular admissible witness, accepted finite witness, actual
subexponential bound or unconditional RH is established.

## Run

Save the ZIP in Downloads and run:

```cmd
cd /d "%USERPROFILE%\Downloads" && (if not exist "E:\RH-FAST\workspaces" mkdir "E:\RH-FAST\workspaces") && tar -xf "RH_HILBERT_LIMIT_LEAN_v0_2_20_construction.zip" -C "E:\RH-FAST\workspaces" && cmd /k call "E:\RH-FAST\workspaces\RH_HILBERT_LIMIT_LEAN_v0_2_20_construction\run.cmd"
```

The command extracts into a new workspace under `E:\RH-FAST\workspaces` and
leaves CMD open. The existing native runner uses the shared
`E:\RH-FAST\anchors` cache and installed compatible Mathlib. Its only changes
are package/version constants. Cache validation, hashing, RAM admission,
parallel scheduling and worker-lock handling remain byte-for-byte the same
after those two constants are normalized.

The active graph remains 92 ordinary modules plus `CancellationAudit`, with
394 selected audit declarations. If all matching same-target source,
dependency, toolchain, artifact and audit identities validate, 91 modules are
eligible for reuse and only `ActualCancellationWitness` and `CancellationAudit`
need compilation and audit. These counts are conditional expectations;
missing or invalid anchors can require additional work.

## Evidence

The uploaded log tail is preserved byte-for-byte, including its clipped first
line. It supplies module PASS/reuse markers and receipt paths, but no receipt
contents or individual printed axiom lists. Reuse requires native revalidation.
The overall v0.2.19 run failed; the final aggregate was not reached. Its shutdown
inventory cleared. The last supplied whole-package PASS remains v0.2.17.

No Lean, Lake, Windows runner/compiler, C# compiler or CI was run here. Static
source and archive verification do not establish native proof PASS.
All prior evidence is preserved. Current metadata records the narrower
module evidence and leaves the repaired source pending. `SHA256SUMS.txt`
covers every other delivered payload file.
