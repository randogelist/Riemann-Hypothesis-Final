# The single actual-calibration condition

The next target is one explicit condition on one fixed finite rational program G:

> **Its division-free residual against the actual theta function tends locally uniformly to zero on the slit plane.**

The condition and endpoint are in [FiniteProgramEndpoint.lean](../SoloboloAdmission/FiniteProgramEndpoint.lean). The condition is named `SoloboloAdmission.ActualUniformResidualCondition G`; the source endpoint derives native Mathlib RH from it. The program is finite raw syntax; the condition is an infinite analytic statement. **No program satisfying it, finite checker recognizing it, or native Lean build is claimed.**

The condition and its transfer belong to the full build. Native compilation and kernel axiom audits are `NOT_RUN`. The full finite-witness iff remains open.

## Exact statement

Let Θ be the actual entire square descent

\[
\Theta(z)=\xi(1/2+\sqrt z),\qquad
\xi(s)=\frac{1+s(s-1)\operatorname{completedRiemannZeta}_0(s)}2.
\]

At stage n, G emits a finite rational packet. Its coefficient is

\[
A_n(z)=-\sum_i
 \frac{m_{n,i}}{x_{n,i}z+\tfrac94(1-x_{n,i})}.
\]

The emitted nodes satisfy 0≤x≤1 and masses satisfy m≥0. Each coefficient is holomorphic on `Complex.slitPlane`, the complex plane with the nonpositive real axis removed. `rationalNode_denominator_ne_zero`, `rationalODECoefficient_analytic` and `FiniteProgram.coefficient_analytic` derive this stagewise analyticity from the packet data; it is not an extra certificate field.

Define the actual residual

\[
E_n(z)=\Theta'(z)+A_n(z)\Theta(z).
\]

The single condition is exactly

```lean
def ActualUniformResidualCondition (G : FiniteProgram) : Prop :=
  TendstoLocallyUniformlyOn G.actualResidual (fun _ : ℂ => 0)
    atTop Complex.slitPlane
```

Thus for every point in the slit plane and every positive error tolerance, a neighborhood and a stage cutoff exist such that all later residuals stay below that tolerance throughout the neighborhood. Pointwise convergence, a bounded finite list of stages, or evaluation on a finite grid is weaker than this condition.

The source endpoint is

```lean
theorem SoloboloAdmission.FiniteProgram.nativeRH_of_uniformResidual
    (G : FiniteProgram)
    (hActual : ActualUniformResidualCondition G) :
    _root_.RiemannHypothesis
```

The only research-strength input in that endpoint is `hActual`. It does **not** assume the existence, convergence or holomorphy of a limiting coefficient A. It also does not assume positivity of actual xi moments, a product calibration, an all-order energy estimate, or a hidden RH field.

## What is already derived from finite data

[FiniteProgram.lean](../SoloboloAdmission/FiniteProgram.lean) defines a finite record with `additionalRank : ℕ` and two finite rational syntax trees, `nodeExpr` and `massExpr`. Evaluation terminates by structural recursion. Stage n has `n + additionalRank + 1` entries; the same finite formulas determine every stage. The syntax is fixed rational arithmetic, fixed natural powers and rational branch tests, not a general algorithm language. No source theorem shows that RH admits a calibrated generator in this exact language; proving completeness may require a richer finite syntax.

The generated node and mass are

\[
x=\frac{q^2}{1+q^2},\qquad m=r^2.
\]

`FiniteProgram.emit_valid` and `emit_check` prove validity and rational-check acceptance at every stage. `modelMoment_nonneg` and `modelMoment_succ_le` derive nonnegativity and monotonicity for each emitted model's moment tower. These source proofs discharge the model side of the induction input; they do not identify that model with actual xi.

The terminating `FiniteProgram.smoke G K` checks a finite prefix of packet validity. `FiniteProgram.smoke_true` proves it succeeds for every G and K. Consequently it provides **no actual-calibration test**. It cannot be advertised as the final RH checker.

## Why the single residual condition implies RH

The generic source theorem is [entire_nonvanishing_of_locallyUniform_residual](../SoloboloAdmission/ResidualNonvanishing.lean). Suppose an entire function Y, nonzero at an anchor, vanished at a point with finite order k+1. Every holomorphic coefficient Aₙ then gives

\[
\left(Y'+A_nY\right)^{(k)}(z)=Y^{(k+1)}(z)\ne0.
\]

The product AₙY still vanishes through derivative order k, independently of n. Locally uniform convergence of holomorphic residuals to zero forces convergence of every fixed-order derivative to zero. The displayed constant nonzero value is a contradiction. The source proves this derivative convergence by induction in `locallyUniform_zero_iteratedDeriv`.

For actual Θ, entire analyticity and Θ(1)≠0 are already supplied by the recovered source chain. Finite-program rational coefficients supply the required stagewise analyticity. Therefore `hActual` excludes all theta zeros on the slit plane. [The actual zero-geometry theorem](../AngularMaster/ZeroGeometry.lean) then gives `_root_.RiemannHypothesis`.

The recovered [slit-ODE iff](../SoloboloAdmission/NativeODE.lean) provides a related analytic criterion: a holomorphic A satisfying Θ′+AΘ=0 on the slit plane is equivalent to RH. The new residual argument reaches zero exclusion without first constructing the limit A. The [actual-J reciprocal iff](../SoloAdmission/AnalyticInverse.lean) is a second source-complete analytic criterion; neither theorem supplies a finite program satisfying this residual condition.

## What “one condition” does and does not mean

The condition is one visible, literal actual-function convergence premise. It replaces a larger proof-bearing package of a coefficient limit, its holomorphy and residual convergence in this forward argument. It is **not** a conjunction of checker soundness, checker completeness and an accepted witness renamed as one proposition.

To obtain a genuine finite-checker theorem, the remaining tasks are separate:

| Task | Required result | Current status |
|---|---|---|
| Derive the condition from finite checks | A concrete terminating checker and a proof that acceptance implies `ActualUniformResidualCondition G` | Open |
| Construct a successful code | Explicit finite G/certificate whose actual-calibration check accepts | Not supplied |
| Prove completeness for the same checker | RH implies an accepted code in the chosen finite syntax | Open |
| Verify the Lean statements | Native Lean 4.33 build and exact endpoint axiom reports | `NOT_RUN` |

The first task would make acceptance sound for RH. The third is additionally needed for

```lean
(∃ W, check W = true) ↔ _root_.RiemannHypothesis
```

RH supplies an analytic ODE coefficient by the recovered iff, but that does not automatically produce a finite program in this restricted rational language or a finite proof accepted by a concrete checker. Likewise an infinite positive summable spectrum is not finite code.

A useful next checker design would certify finitely described estimates that hold for all stages on a proved compact exhaustion of the slit plane. A universally valid error bound tending to zero on each compact set can establish the named condition. Finite sampling or an unexplained all-orders proof field cannot do so. The checker language, exact actual-function bounds and completeness theorem remain implementation/research work.

## Product and coefficient work that can support the condition

The [recovered actual product assessment](research/2026-10-25/rh-positive-product-assessment.md) identifies source results stronger than a placeholder Hadamard assumption. They already contain multiplicity-bearing zero occurrences, inverse-square summability, a normalized theta product, Θ(0)≠0 and zero origin multiplicity. Under RH, its complex squared-zero scales become positive real scales. The remaining positive-resolvent assembly is to recenter the affine product, identify the real and complex carriers, and reindex the countable half-pair spectrum into a nonnegative Nat diagonal. It introduces no new exponential-factor or simple-zero premise, but it has not yet been connected to this finite program or checker.

The [central product-log coefficient bridge](research/2026-10-25/coefficient-bridge-strategy.md) has a separate written finite-jet derivation using a rational Cayley parameter and existing finite coefficient algebra. Its analytic Lean passage is still open. The anchor-1 direct-jet row strategy and the central Widder coefficient formula have different derivative orders and normalizations; neither can be substituted for the other without proof. [FRONTIER.md](FRONTIER.md) records these distinctions and the remaining tasks.

## Execution status

Use the existing native Windows [build workflow](BUILD.md): `run.cmd full` with compatible cached Mathlib. The finite program evaluator and local packet checks are executable definitions. `ActualUniformResidualCondition` is an analytic proposition, not an executable decision procedure. The native runner must elaborate the new proof modules and reject unexpected endpoint axioms before a verified-build claim is made.

Publication of these sources makes the mathematical contract reviewable. It does not establish actual calibration, a passing RH witness, RH, or RH→GRH.
