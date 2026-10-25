# Actual positive-product bridge: enumeration and derivative evidence

Source-only focused review; native compilation and kernel axiom audit **NOT_RUN**. No repository changes. The exact declaration excerpts, lines and hashes are in `strategy_deep/product-enumeration-evidence.json`.

The recovered source is closer to the desired positive diagonal resolvent than an unnormalized theta factorization alone suggests. **The origin monomial is already proved absent** in a later recovered module. The multiplicity-bearing index is already countable. The missing pieces identified here are a Nat-index transport and the positive-ray differentiated product wrapper; neither appears to require a new RH hypothesis beyond the one already present in the proposed forward bridge.

## Countable enumeration with multiplicity

`RiemannHypothesis/Xi/CanonicalDivisor.lean` in the inspected angular-v0.1.1-FIX1 package defines

```lean
noncomputable def EntireXiPullbackZeroOccurrence : Type :=
  Sigma fun z : EntireXiPullbackNonzeroZero =>
    Fin (analyticOrderNatAt EntireXiPullback z.1)
```

Its `entireXiPullbackZeroOccurrence_fiber_natCard` identifies the fiber's natural cardinality with the analytic order, and `entireXiPullbackZeroOccurrence_countable` / `_countable_holds` prove countability. No simple-zero assumption is present. Exact negation acts on this occurrence type, retaining multiplicity.

`AngularMaster/ActualHadamard.lean` defines `ActualPairIndex := entireXiPullbackZeroOccurrenceNegationPairingData.half`. The generic structure's `pairEquiv : half × Bool ≃ ι` makes `i ↦ pairEquiv (i,false)` injective. The proof of `actualZeroScale_inv_summable` already writes out precisely this injection. Consequently countability transfers to `ActualPairIndex`; this is not a missing zero-distribution theorem.

No explicit `ActualPairIndex → ℕ`/Nat enumeration wrapper was found in the inspected package or shared Lean corpus. To produce a diagonal `d : ℕ → ℝ`, encode the countable half-index injectively and put zero on unused codes. This preserves each occurrence exactly once and handles finite or empty indices without a new infinitude premise. Prove the sum/tsum transport for this encoding. Do not enumerate distinct zero locations without their finite multiplicity fibers.

Existing positive input:

```lean
theorem actualZeroScale_positive (i : ActualPairIndex) :
  0 < actualZeroScale i

theorem actualZeroScale_inv_summable :
  Summable (fun i : ActualPairIndex => (actualZeroScale i)⁻¹)

theorem actualPairZero_sq_of_RH (hRH : RiemannHypothesis)
    (i : ActualPairIndex) :
  (actualPairZero i)^2 = (actualZeroScale i : ℂ)
```

## The origin factor is already eliminated in recovered source

The later `OriginTrace.lean` occurs in `RH_GIGGA_SMALL_O_EQUIVALENCE_LEAN_v0_2_0` and its earlier closure package with the identical SHA-256 `01c0d483964ef1b3cff5883267eec10ad65830ac2251d8db206434e85c73bedf`. It is available at the matching `reinference/corpus/<sha>.lean`.

This source imports `AngularMaster.ComplexScaleProduct` and `AngularMaster.ZeroFreeSeed`, then proves:

```lean
theorem actual_theta_zero_ne_zero : AWPIRH.theta 0 ≠ 0

theorem actual_originMultiplicity_eq_zero :
  entireXiPullbackOriginMultiplicity = 0

theorem actual_theta_normalized_complex_factorization (z : ℂ) :
  AWPIRH.theta z = AWPIRH.theta 0 *
    ∏' i : ActualPairIndex, (1 + z / actualComplexScale i)
```

The first theorem uses `actual_xi_ne_zero_of_low_height` at s=1/2. The second combines it with the canonical divisor's exact zero/multiplicity iff. The third evaluates the established product at zero to identify its constant as Θ(0). No RH assumption or new product hypothesis occurs in these three declarations. Thus the possible origin monomial in the earlier angular product theorem should not remain listed as an unresolved analytic obstruction once this source is imported coherently.

## Differentiation: implemented at zero, generic tool available, positive-ray wrapper still missing

The same `OriginTrace.lean` proves local uniform convergence of a reciprocal-summable affine product and then, using Mathlib's `logDeriv_tprod_eq_tsum`, proves:

```lean
theorem logDeriv_affineProduct_zero
    {ι : Type*} {b : ι → ℂ} (hb : Summable (fun i => ‖b i‖)) :
  logDeriv (fun z : ℂ => ∏' i, (1 + z * b i)) 0 = ∑' i, b i

theorem actual_theta_origin_logDeriv_eq_tsum :
  deriv AWPIRH.theta 0 / AWPIRH.theta 0 =
    ∑' i : ActualPairIndex, (actualComplexScale i)⁻¹
```

I found no recovered theorem directly asserting the actual positive-ray formula

\[
\Theta'(t)/\Theta(t)
 = \sum_i b_i/(1+t b_i),\quad b_i=1/\mathrm{actualZeroScale}(i),\quad t>0,
\]

or its Nat-reindexed version. The source has the components to derive it under RH: replace complex scales using `actualPairZero_sq_of_RH`, extend the same affine-product local uniform convergence estimate from the unit ball to an arbitrary bounded ball, and apply `logDeriv_tprod_eq_tsum` at t. Each denominator is positive and `0 ≤ b_i/(1+t b_i) ≤ b_i`, giving summability from the already proved reciprocal-scale sum. The normalized actual product supplies the left side and the nonzero constant cancels. This is a proposed formal derivation, not an already checked theorem.

There is also a more indirect existing derivative route: `OverflowResidueRH.entireXiPullback_logDerivative_canonicalExpansion_unconditional` in `RiemannHypothesis/Xi/UnconditionalLagariasEquivalence.lean` gives the full nonzero-point genus-one regularized log-derivative expansion with exact multiplicities and no extra global hypothesis. Transport through square descent and pair the opposite terms to obtain the theta resolvent. The direct affine-product theorem above appears shorter and avoids repeating the derivative/square-root pairing algebra.

These observations support an assembly task with identifiable missing Lean glue, rather than treating the product/zero index as a wholly absent mathematical construction. They do not verify compatibility of every imported version, compile the imported analytic closure, or prove a finite raw certificate. The parent review must still check the target's exact diagonal normalization and all quantifiers against these statements.
