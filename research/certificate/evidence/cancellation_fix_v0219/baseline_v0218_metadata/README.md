# RH Hilbert Limit v0.2.18 — hypothetical cancellation witness

Mode **A_TIER_LEAN**. Target **LOCAL_COMPILER**, native Windows Lean **4.33.0**.
This is a source package prepared for your compiler. The four new Lean files
have not been compiled or axiom-audited here. The last supplied v0.2.17 run
reported PASS with 90 frozen reused modules and no sorryAx.

## Exact new forward statement

```lean
theorem nativeRH_of_exists_admissible_cancellationBudget
    (hWitness : ∃ W : CancellationBudget, W.Admissible) :
    _root_.RiemannHypothesis
```

`CancellationBudget` contains only `cutoff : Nat` and `coefficient : Nat`.
Its validity is separate and explicit:

```lean
def CancellationBudget.Admissible (W : CancellationBudget) : Prop :=
  ∀ n : ℕ, W.cutoff ≤ n →
    rowCancellation actualNormalizedMoment n ≤
      (W.coefficient : ℝ) * actualVariation n
```

The assumed existence includes this all-order property. The source supplies
the cancellation identity, the eventual subexponential growth argument, and
the transfer to actual Mathlib RH. The imported spectral calibration and
dominant extraction are already constructed; neither is an extra endpoint
hypothesis. No particular admissible budget is obtained.

The module also supplies the reverse implication from RH, giving an analytic
equivalence with semantic admissibility. It does **not** supply a terminating
finite Bool checker or prove `(exists W, check W = true) -> RH`. The finite
checker soundness and full finite-witness equivalence remain **OPEN**.

## What is formalized in the new source

* `Cancellation.lean`: literal finite adjacent triangle defects, their exact
  row sum `(n+1) * (V(n+1)-V(n))`, nonnegativity, and the local telescoping bound.
* `EventualGrowth.lean`: a nonnegative sequence whose inverse-linear growth
  step holds after a finite cutoff is subexponential. This proof uses the
  existing exponential-step theorem and does not require a finite-prefix bound
  as an additional hypothesis.
* `ActualCancellationWitness.lean`: the semantic budget, explicit forward and
  reverse actual-RH transfers, and the local-flux adapter. The auxiliary
  function in `LocalFlux` is unrestricted; it is not asserted to be finite data.
* `CancellationAudit.lean`: all 370 prior selected declarations plus 24 new
  public declarations. It prints the witness data and admissibility definitions
  so the universal hypotheses remain visible in the native audit log.

The paper's explicit binomial-product upper bound is not claimed as a new
Lean declaration in this release. The eventual exponential-step proof already
gives the precise Subexponential predicate needed for the RH endpoint.

## Run

Save the ZIP in Downloads and run:

```cmd
cd /d "%USERPROFILE%\Downloads" && (if not exist "E:\RH-FAST\workspaces" mkdir "E:\RH-FAST\workspaces") && tar -xf "RH_HILBERT_LIMIT_LEAN_v0_2_18_construction.zip" -C "E:\RH-FAST\workspaces" && cmd /k call "E:\RH-FAST\workspaces\RH_HILBERT_LIMIT_LEAN_v0_2_18_construction\run.cmd"
```

The command leaves CMD open. The existing fast native runner, cache validation,
parallel scheduling, RAM admission and shutdown logic are preserved. Only its
package identity and mathematical status reporting change. The runner uses
the shared `E:\RH-FAST\anchors` store and already installed cached Mathlib.
It performs no Lake setup and uses no Python, PowerShell, WSL or network setup.

All 92 inherited Lean files are byte-preserved. The old AnalyticAudit source
and cache remain preserved but are no longer selected. The active graph has
92 ordinary modules plus CancellationAudit. If all baseline identities validate,
89 ordinary modules are eligible for reuse and four new modules need compilation
and audit. Actual counts depend on source, dependency, toolchain, artifact and
same-target receipt validation; the runner rebuilds or fails on invalid evidence.

## Reading a successful native run

`SEMANTIC_CANCELLATION_WITNESS_FORWARD=DECLARATION_AUDITED` means the displayed
conditional declaration passed its native audit. Its hypothesis still contains
the universal admissibility predicate. A successful build keeps these separate:

```text
FINITE_CHECKER_SOUNDNESS=OPEN
FINITE_CHECKER_EQUIVALENCE=OPEN
FORMAL_CLOSURE=OPEN
FINITE_ACCEPTED_WITNESS=NOT_ESTABLISHED
UNCONDITIONAL_RH=NOT_ESTABLISHED
```

No concrete witness, native receipts, compiled artifacts, or compiler PASS were
fabricated during preparation. STATUS.json, CHECKPOINT.json and the evidence
directory distinguish user-reported historical PASS from pending new source.
SHA256SUMS.txt covers every other delivered payload file.
