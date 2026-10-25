# Assessment of RHPositiveProductBridge against recovered actual product sources

**The mathematical product input is substantially already present.** The v1.0.2 forward bridge is not yet a recovered finished Lean theorem, but it appears reducible to a specific assembly of the existing actual-theta product, a positive-ray logarithmic-derivative adapter, real-carrier identification, and countable reindexing. No new Hadamard factorization hypothesis, origin normalization hypothesis, simple-zero assumption or exponential-factor assumption should be introduced.

This is a read-only source assessment. No proposed adapter was implemented or compiled, and no native axiom audit was run. The distinction is between existing proved-as-source components and the remaining Lean assembly—not a claim that `RHPositiveProductBridge` has been discharged already.

## 1. Exact v1.0.2 target

In `SOLOBOLO_FINITE_WITNESS_IFF_RH_GOODWORKFLOWFRONTIER_v1_0_2_REINFERRED_FASTCORE`:

```lean
-- Admission/Iff.lean
def RHPositiveProductBridge : Prop :=
  _root_.RiemannHypothesis →
    ∃ D : SoloboloTrace.PositiveTraceData,
      SoloboloTrace.ActualResolventCalibration D

-- TraceClass/ActualInterface.lean
structure PositiveTraceData where
  atom : ℕ → ℝ
  nonneg : ∀ i, 0 ≤ atom i
  summable : Summable atom

-- TraceClass/ScalarKernel.lean
def scalarResolvent (a u : ℝ) : ℝ := a / (1 + u * a)
```

Calibration is exactly

\[
\forall u>0,\qquad
\operatorname{actualG}(u)
 = u\sum_{n\in\mathbb N}\frac{D.atom(n)}{1+uD.atom(n)}.
\]

`actualG` is `u * deriv actualThetaPos u / actualThetaPos u`, with

```lean
actualThetaPos u =
  (actualXi (((1 / 2 : ℝ) + Real.sqrt u : ℝ) : ℂ)).re
```

and `actualXi(s)=(1+s(s−1)completedRiemannZeta₀(s))/2`. This target is the unshifted positive-real theta logarithmic derivative. It is **not** the normalized Taylor germ at anchor 1/4, the central Widder observable, a factor-4 GP moment, a shifted 9/4 resolvent, or a statement that the entire trace sequence is rational/computable. In particular the intended atom is **λᵢ=1/αᵢ**, where αᵢ is the positive squared-zero scale. It is not αᵢ itself.

For u>0,

\[
\frac{\lambda_i}{1+u\lambda_i}=
\frac{1}{\alpha_i+u},\qquad
0\le\frac{1}{\alpha_i+u}\le\frac1{\alpha_i}.
\]

Thus the already available inverse-scale summability has exactly the required trace-class normalization.

## 2. Existing source eliminates the suspected analytic obstructions

| Requirement | Existing declaration or construction | Remaining status |
|---|---|---|
| Actual ξ/Θ identification | `AngularMaster.external_entireRiemannXi_eq_actual_xi`, `actual_theta_eq_external_pullback` | Implemented source |
| Exact multiplicities | `EntireXiPullbackZeroOccurrence := Sigma z, Fin (analyticOrderNatAt EntireXiPullback z.1)` and its fiber-cardinality theorem | Implemented source; no simplicity assumption |
| Opposite-zero pairing | `entireXiPullbackZeroOccurrenceNegationPairingData`, with `half × Bool ≃ occurrence` | Implemented source |
| Positive scales under RH | `actualPairZero_sq_of_RH`; `actualZeroScale_positive` | Implemented source |
| Summable inverse scales | `actualZeroScale_inv_summable` | Implemented source |
| No variable exponential factor | `entireXiPullback_exists_constant_factorization_unconditional` | Implemented source, constant-times-product |
| No origin monomial | `actual_theta_zero_ne_zero`; `actual_originMultiplicity_eq_zero` in recovered `OriginTrace.lean` | Implemented source |
| Exact product constant | `actual_theta_normalized_complex_factorization` | Constant is Θ(0), implemented source |
| Differentiated infinite product | `logDeriv_affineProduct_zero` and `actual_theta_origin_logDeriv_eq_tsum` | Implemented at zero; positive-ray adapter missing |
| Nat-indexed diagonal | Countable occurrence type plus injection of half-pairs | Countability implemented; zero-padding adapter missing |
| Literal real carrier | Formula uses real sqrt and real derivative; product uses complex theta | Pointwise/local real-restriction adapter missing |

The key later recovered module is `OriginTrace.lean`, SHA-256 `01c0d483964ef1b3cff5883267eec10ad65830ac2251d8db206434e85c73bedf`, from `RH_GIGGA_SMALL_O_EQUIVALENCE_LEAN_v0_2_0` (also present identically in the earlier closure package). It proves:

```lean
theorem actual_theta_zero_ne_zero : AWPIRH.theta 0 ≠ 0

theorem actual_originMultiplicity_eq_zero :
  entireXiPullbackOriginMultiplicity = 0

theorem actual_theta_normalized_complex_factorization (z : ℂ) :
  AWPIRH.theta z = AWPIRH.theta 0 *
    ∏' i : ActualPairIndex, (1 + z / actualComplexScale i)
```

It derives nonvanishing at zero from the already proved low-height zero-free theorem, then removes the monomial by the canonical multiplicity/zero equivalence. Therefore neither `Θ(0)≠0` nor elimination of the origin term remains a new mathematical assumption. This matters: leaving an origin multiplicity m would produce an extra m/2 in uΘ′/Θ, which a summable positive resolvent tends to zero at u=0 and could not absorb.

The earlier unconditional canonical expansion also explicitly removes its affine logarithmic-derivative constant. The normalized theta product above is stronger and more direct evidence for this target: there is no unresolved term `e^(az+b)`, and its constant Θ(0) cancels in the logarithmic derivative.

Under RH, `actualPairZero_sq_of_RH` changes `actualComplexScale i` to `(actualZeroScale i : ℂ)`. Consequently the available sources yield the normalized product

\[
\Theta(z)=\Theta(0)\prod_i\left(1+\frac z{\alpha_i}\right),
\qquad \alpha_i>0,\quad\sum_i\alpha_i^{-1}<\infty.
\]

This last displayed substitution is an assembly of existing named source lemmas, not a separately recovered final theorem binding the v1.0.2 trace interface.

## 3. A short route to the missing positive-ray formula

The recovered generic lemma is

```lean
theorem logDeriv_affineProduct_zero
    {ι : Type*} {b : ι → ℂ} (hb : Summable (fun i => ‖b i‖)) :
  logDeriv (fun z : ℂ => ∏' i, (1 + z * b i)) 0 = ∑' i, b i
```

It already proves the necessary local uniform convergence and uses Mathlib's `logDeriv_tprod_eq_tsum`. There is no need to rebuild general Hadamard differentiation from scratch.

A particularly direct proposed adapter **recenters the product**, reusing that exact zero-centered lemma. For fixed u>0 set bᵢ=1/(αᵢ+u). The bound bᵢ≤1/αᵢ gives absolute summability. Use the pointwise factor identity

\[
1+\frac{u+z}{\alpha_i}
=\left(1+\frac u{\alpha_i}\right)
 \left(1+\frac z{\alpha_i+u}\right)
\]

and multiplication of multipliable families to obtain

\[
\Theta(u+z)=\Theta(u)\prod_i\left(1+\frac z{\alpha_i+u}\right).
\]

RH and the native theta zero-location equivalence give Θ(u)≠0. Apply `logDeriv_affineProduct_zero` to the shifted product and cancel the constant Θ(u). The translation has derivative one, so this yields

\[
\frac{\Theta'(u)}{\Theta(u)}
=\sum_i\frac1{\alpha_i+u}.
\]

This proposed proof needs explicit Lean lemmas for shifted-product multipliability, `tprod` multiplication/reassociation, the nonzero positive-ray value, and translation of `logDeriv`/`deriv`. All are concrete analytic/algebraic adapters of existing inputs. The positive-ray identity itself was not found as an already declared theorem in the inspected/recovered corpus.

An alternative is to extend the affine-product local-uniform estimate from the unit ball to a bounded ball about u and invoke the same `logDeriv_tprod_eq_tsum` directly at u. The recentering route appears smaller because it reuses the already implemented generic zero-centered theorem unchanged.

The existing `entireXiPullback_logDerivative_canonicalExpansion_unconditional` provides a third route: pair its regularized genus-one terms, transport through w=−i√u, remove the origin multiplicity, and simplify. This is mathematically sufficient but introduces more sign, factor-two and chain-rule bookkeeping than the affine-product adapter.

## 4. Match the actual real carrier, not merely a similar logarithmic derivative

The v1.0.2 carrier is real-valued and uses `Real.sqrt`; the product source uses complex `AWPIRH.theta` with `Complex.sqrt`. The exact remaining bindings should be proved locally on u>0:

1. `actualThetaPos u = (AWPIRH.theta (u : ℂ)).re`, using agreement of real and complex square root on the nonnegative real axis and the literal xi formulas.
2. Theta's Schwarz identity makes Θ(u) real for real u. Its positive-ray nonvanishing follows under RH; no separate positivity-of-Θ theorem is needed merely to divide.
3. Transfer the complex derivative to the real restriction and the real-part map. Local agreement on a neighborhood of the positive point is enough for `deriv`; an equality only at one point would not suffice.
4. Take real parts of the absolutely summable complex series. The denominator Θ(u) is real, so the result is exactly `deriv actualThetaPos u / actualThetaPos u`.
5. Multiply by u and rewrite `1/(αᵢ+u)=λᵢ/(1+uλᵢ)`.

There is no residual factor 2 or 4 in this route: the square descent is already part of Θ, and the target is uΘ′/Θ. Any use of the separate central Widder/readout formulas must redo their derivative normalization explicitly; they are unnecessary for this particular forward bridge.

## 5. Nat reindexing preserves multiplicity and requires no infinitude theorem

The canonical occurrence index is countable and carries analytic multiplicity in its finite fibers. The half-pair index injects into it by

```lean
i ↦ entireXiPullbackZeroOccurrenceNegationPairingData.pairEquiv (i, false)
```

The existing summability proof already writes out this injection. Thus a countable encoding of `ActualPairIndex` into ℕ is available. Define `D.atom n` to be `1/αᵢ` when n codes i, and zero otherwise. Its nonnegativity and summability follow by transport; zero codes contribute zero to every `scalarResolvent` sum. An explicit summable/tsum reindexing lemma finishes the calibration.

The candidate diagonal itself can be defined **without RH**: `actualZeroScale` is a positive norm-square and its inverse sum is already unconditional. RH is needed to identify those norm-squares with the literal complex product scales and hence prove calibration. A useful implementation split is therefore an unconditional `actualPositiveTraceData`, followed by `actualPositiveTraceData_calibrated_of_RH`.

This works even if the index is finite or empty: **v1.0.2 asks for nonnegative atoms, not strictly positive atoms**. There is no need to add a hypothesis that there are infinitely many zeros or to force a bijection with ℕ. The corresponding STURMION interface with strict positivity and all-depth Widder calibration is a different, stronger target; the same zero-padding argument does not automatically close that statement.

Use one atom for each **opposite pair of occurrences**, retaining the multiplicity repeated in the occurrence index. Using all ± occurrences with the same inverse-square weight would double the trace. Enumerating only distinct zero locations would instead lose multiplicity. Both errors are avoided by the existing `ActualPairIndex` product.

E23's `NativeRRBinding` independently supplies actual multiplicity-bearing positive-height occurrences, summable inverse-height mass, and a native zero-support binding. That confirms the source already treats these support questions concretely. Its scalar mass `c1` or defect C alone does not give the entire u-dependent resolvent. Building the diagonal directly from `ActualPairIndex` avoids proving an additional bijection between the E23 upper-occurrence index and the product's chosen half-pair index.

## 6. Version assembly and verification scope

There is a real version detail. The v0.2.0 small-o package replaces `AngularMaster/ActualHadamard.lean` with a smaller foundation module (SHA `99f424e8e0e87247c76b9f638850de67dcaaf7a5559e7158eeb1883efcee3664`). It retains the common actual zero definitions and inverse-scale summability, but omits `actualZeroScale_positive` and `actualPairZero_sq_of_RH`. The full angular-v0.1.1-FIX1 body (SHA `0f5bac2eeac91ce9a44f6e1eed7afbe8caead36cca0b95fad34efae714bd72e3`) contains those needed source lemmas.

A concrete candidate support assembly is the full angular-v0.1.1-FIX1 project closure plus the exact recovered `OriginTrace.lean`. The directly imported `ComplexScaleProduct` and `ZeroFreeSeed` bytes agree with those in the small-o package. The full `ActualHadamard` keeps the common declarations with the same definitions and supplies the additional RH-positive-scale lemmas. Do not put both `ActualHadamard` versions on the import path.

The import-only manifest `strategy_deep/positive-product-support-closure.json` resolves **76 project modules, with zero missing project imports**, for `OriginTrace` plus native zero geometry using that selection. Four exact bodies are already tracked in the local RH repository; 72 are absent by tracked hash. This is the existing-source support graph before adding the v1.0.2 target-side imports and new adapter lemmas. It is larger than the short mathematical bridge, and has not been compiled or audited as an assembled graph. Mathlib remains an external dependency.

Exact declaration evidence is in `strategy_deep/product-enumeration-evidence.json`; the independent enumeration/origin/differentiation review is `strategy_deep/product-enumeration-findings.md`.

## Conclusion for strategy

Replace “formalize the actual Hadamard product” as the generic next task with this narrower implementation milestone:

> Assemble the recovered normalized actual-theta product under RH; prove its positive-ray resolvent formula by recentering the existing affine-product theorem; bind it to `SoloBoloWitness.actualThetaPos`; and transport its multiplicity-bearing half-pair spectrum to a nonnegative summable Nat diagonal.

If those adapters compile and pass the endpoint axiom audit, they should discharge **this one** v1.0.2 `RHPositiveProductBridge` without a new research assumption. The strongest missing declaration to aim at is directly

```lean
theorem rhPositiveProductBridge_derived :
  SoloboloTrace.RHPositiveProductBridge
```

rather than another record that assumes the same calibration. This remains a proposed source assembly, not a completed proof. It would establish RH→positive infinite actual resolvent admission. It would not construct a finite rational generator, prove finite-code compression or checker completeness, discharge the reverse Fredholm bridge automatically, or prove RH.
