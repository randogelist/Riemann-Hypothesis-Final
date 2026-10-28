# RH Hilbert Limit v0.2.24 construction — explicit (0,0) candidate

This package instantiates `zeroBudgetCandidate : CancellationBudget := ⟨0,0⟩`
and prepares an independent proof of its **first cancellation check**:

```lean
rowCancellation actualNormalizedMoment 0 = 0
```

The new sources have not been compiled here. They contain no proof holes,
extra axioms, or RH hypotheses in the first-check proof. Run the package with
the user's native Windows Lean 4.33.0 and cached compatible Mathlib.
**A passing build of this package does not establish universal admissibility
of (0,0), an accepted RH witness, or unconditional RH.**

## What is actually tested

Writing `W = (0,0)` fixes the cutoff and cancellation coefficient. Its
admissibility still means `∀ n, rowCancellation actualNormalizedMoment n ≤ 0`.
Each row cancellation is already nonnegative, so every such row must vanish.
The zero in the pair does not limit the check to index zero.

The new candidate module derives the exact first-row condition. With
`u₁ = actualNormalizedMoment 1`,

    C₀ = |1 − u₁| + |u₁| − 1,
    C₀ = 0 iff 0 ≤ u₁ and u₁ ≤ 1.

The first-moment module supplies these inequalities from the actual analytic
data, independently of RH. Its argument uses the existing theta-kernel bound
`‖completedRiemannZeta₀ s‖ ≤ 3/8` on the critical strip. At height at most 5/4,
the xi correction has norm at most `(41/16)*(3/8)=123/128<1`, excluding zeros.
That stronger height bound places each complex zero scale in the sector
`Re(a)/‖a‖ ≥ 21/29`. Because `2*(21/29)^2>1`, the real part of its square is
positive. Inversion and the positive normalization preserve this sign.
The exact canonical power sums then give `0 < u₁`; positive real canonical
masses of total one give `u₁ ≤ 1`. Consequently `C₀=0` and `actualVariation 1=1`.

These are source arguments awaiting the native compiler and axiom audit.
They use exact rational inequalities and analytic theorems, not a numerical
sample or a call that assumes an RH conclusion.

## What remains open

The candidate module also exposes the next row and the universal induction
obligation. Once the first check is supplied, the missing propagation is:

```lean
∀ n : ℕ,
  rowCancellation actualNormalizedMoment n = 0 →
  rowCancellation actualNormalizedMoment (n + 1) = 0
```

This universal step is **not proved** by this package. No `sorry`, `admit`,
axiom, or finite sample is used to substitute for it. The preserved audited
transfer gives RH if universal admissibility is eventually established.
The complete finite raw-data / terminating-checker equivalence also remains
open. Finite witness existence and semantic admissibility remain distinct.

## Files and native audit

- `RH_HilbertLimit/ZeroBudgetCandidate.lean`: explicit data, exact finite-row
  formulas and candidate criteria, and the displayed induction obligation.
- `RH_HilbertLimit/ZeroBudgetFirstMoment.lean`: the independent analytic first
  moment bounds and the first cancellation check.
- `ZeroBudgetAudit.lean`: every previous selected target plus every new
  public declaration, with exact type and axiom prints.

All 96 previous Lean files and all 1129 prior declaration records are
preserved. The active build has 94 ordinary modules plus the new final audit.
If the matching native anchors validate, 92 old ordinary modules are reused
and only the two new source modules and final audit compile. The old
CancellationAudit source and its history remain preserved but are inactive
as this version's selected audit. Missing or invalid anchors rebuild or fail.

The latest recorded historical user run is v0.2.23: 0 compiled, 93 reused,
394 selected declarations, standard logical axioms only, no sorryAx, and
RUN PASS. Its excerpt reports reused audit coverage rather than new explicit
per-declaration axiom output. The earlier v0.2.20 explicit endpoint evidence
is retained separately. Native receipts themselves were not supplied.

This v0.2.24 package remains **NATIVE AUDIT PENDING**. A successful run reports
`ZERO_BUDGET_VERIFIED_REFINEMENT_SCOPE=INDEX_0_ONLY` together with
`ZERO_BUDGET_ADMISSIBILITY=OPEN` and `UNCONDITIONAL_RH=NOT_ESTABLISHED`.

## Run

Use the existing offline Windows Lean and compatible Mathlib cache. The
runner retains E:\RH-FAST workspaces and verified LEAN_ANCHORINGS. Its cache,
thread/memory admission, lock, and shutdown decisions are unchanged. Only
package identity and explicit mathematical result reporting change.
No Lake setup, Python, PowerShell, WSL, network setup, or CI is used by the
runner. The command window stays open for inspection.

```cmd
cd /d "%USERPROFILE%\Downloads" && (if not exist "E:\RH-FAST\workspaces" mkdir "E:\RH-FAST\workspaces") && tar -xf "RH_HILBERT_LIMIT_LEAN_v0_2_24_construction.zip" -C "E:\RH-FAST\workspaces" && cmd /k call "E:\RH-FAST\workspaces\RH_HILBERT_LIMIT_LEAN_v0_2_24_construction\run.cmd"
```
