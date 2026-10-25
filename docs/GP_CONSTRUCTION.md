# GP construction and the actual SOLOBOLO boundary

This integration adds the recovered GP construction to the repository's
active source graph. It remains **source-only**: no new native Lean 4.33
compilation or axiom audit has been run. `v0_1_0_construction` is unchanged;
Git history identifies this integration. Proof status is governed by native
receipts and exact hypotheses, not by the package title or a successful upload.

## The distinct GP layers

| Layer | Source and content | Current boundary |
|---|---|---|
| Literal Mellin–Hilbert realization | `RHFinal/GP/Literal.lean`: density, measure, complex L² space, multiplication generator, Mellin/log moments, completion gauge and pointwise heat multipliers | Density law, integrability, moment differentiation, operator lifting and native ξ factorization remain open |
| Recovered KQ/GP/BKQR/SOLOBOLO construction | 48 unchanged v0.1.18 modules plus `KQEndpoints.lean` and `KQAudit.lean`: actual ξ calculus, GP model transfer, Widder/Cayley formulas and conditional RH endpoints | Actual GP realization/calibration, complex infinite germ and analytic growth inputs are not constructed by importing the source |
| Finite rational GP model | `FiniteWitness/GPMoments.lean`: rational Hankel data from `gpMoment Y k = 4/(k+1)^Y`; shared finite-spectrum trace induction | These rational models are not identified with the literal actual-ξ moments |
| GP7 weight-seven construction | Eight unchanged `GP7/` modules plus `GP7Endpoints.lean` and `GP7Audit.lean`: exact polynomial Laplace integration, finite spectral monotonicity, rank-one threshold and finite dyadic identities | Weight-seven moment identities do not provide actual-ξ calibration, an infinite resolvent or an RH implication |
| Generic master energy model | Four `RHFinal/GP/Master*` modules: binary energy splitting, Pascal recurrence and Hausdorff differences | The infinite model and its all-order boundary laws remain hypotheses; it is not a finite witness |

`RHFinal/GP/KQEndpoints.lean` identifies the recovered native ξ and slit Θ
with the same literal definitions used by the new repository, and transfers
the source theorem for Θ analyticity at positive anchors.
`RHFinal/GP/NativeBinding.lean` proves the literal logarithmic-derivative
quotient equality and the cleared H3 Cayley-kernel polynomial identity. The
latter is algebra only; it does not establish an actual-observable PDE. These
bindings do not prove Mellin factorization or positivity of actual SOLOBOLO
moments.

## Literal Mellin–Hilbert normalization

The continuous GP construction uses

\[
d(r)=\frac{(r-1)e^r+1}{(e^r-1)^2},\qquad
 d\mu(r,y)=2d(r)\,dr\,\frac{dy}{y},\qquad L(r,y)=ry,
\]

on \((0,\infty)\times[1/4,1/2]\), with intended complex Hilbert space
\(L^2(\mu)\), vector representative \(L^{(s-1)/2}\), and heat multiplier
\(e^{-hL}\). The archived analytic note uses an open y interval; transporting
its formulas to the closed-interval implementation uses the null endpoint
sets. The literal Lean definitions do not themselves supply this transport.

The implementation has source proofs for the pointwise laws
`heatMultiplier_zero`, `heatMultiplier_add`, `heatMultiplier_pos`, and
`heatMultiplier_le_one`. The last requires `h ≥ 0` and `L ≥ 0`. These are
pointwise scalar facts, not yet a bounded-operator construction on L².
Likewise, defining a vector representative does not prove its L² membership.

The intended integral evaluation and native completion are

\[
 I_0(s)=2^{2-s}\Gamma(s)(1-2^{1-s})\zeta(s),\qquad
 \xi(s)=A(s)I_0(s),
\]

\[
 A(s)=\frac{s(s-1)2^{s-3}\pi^{-s/2}\Gamma(s/2)}
 {\Gamma(s)(1-2^{1-s})}.
\]

In `Literal.lean`, `DensityLaw`, `MellinEvaluation`,
`LogMomentDifferentiation`, and `NativeXiFactorization` record the missing
proofs as propositions. They are not axioms, admitted theorems or witness
fields. In particular, `ENNReal.ofReal` in `gpMeasure` does not prove the
intended density is positive; it truncates negative inputs.

The on-paper removable values are \(I_0(1)=2\log2\) and
\(A(1)=1/(4\log2)\). The raw, totalized `completionGauge` expression is not
that removable extension at one. The current factorization obligation
explicitly excludes one and zeros of the displayed denominator. Domain,
normalization and removable-value lemmas must accompany every use of the gauge.

The separate finite rational model has moments \(4/(k+1)^Y\). GP7 uses
\(1/(k+1)^7\). Even at weight seven these differ by a factor of four; neither
normalization may silently replace the Mellin–Hilbert family above.

## Actual ξ / Widder / Cayley endpoints

`KQEndpoints.lean` exposes the following source results, with their original
mathematical hypotheses retained:

- `actualXi_eq_kqXi` and `actualTheta_eq_kqSlitTheta`: definitional equality of
  the completed-zeta ξ and principal-square-root descent.
- `actualTheta_analyticAt_positive`: actual Θ is analytic at positive anchors;
  this does not assert nonvanishing there.
- `actualWidder_direct_eq_recursive`: equality on `xiRegularAnchors` of the
  derivative-defined and recursively defined actual Widder quantities.
- `actualWidder_finite_cayley_coefficient`: the all-depth **finite real**
  Taylor/Rodrigues coefficient formula on that regular-anchor domain.

Selected inherited audit targets include
`FREE_ENERGY_CURVATURE_IMPLIES_COMMON_MOMENTS`,
`COMMON_MOMENTS_IMPLIES_TRANSFER_MATCH`,
`gp_bkqr_calibration_implies_all_depth_nonnegative`, and
`actual_observable_subexp_implies_Mathlib_RH`. Their names are implications:
the required curvature/base calibration, model realization, germ compatibility
and/or growth assumptions still have to be supplied for actual data.
`GPBKQRFreeEnergyWitness` and `FiniteCayleyDefectSystem` contain infinite
functions or universal proof fields; neither is a finite raw-data witness.

The literal quotient identity in `NativeBinding.lean` does not identify the
real derivative tower with every complex derivative representation. Any such
compatibility required by the final chain remains an explicit proof obligation.

## The completion gauge and regularization matter

The preserved [analytic bridge note](../research/upstream/gp-analytic-note/KQ_GP_BKQR_Hilbert_Theta_Cayley_Analytic_Bridge.md)
is an on-paper derivation, not a Lean receipt. It separates the logarithmic
Mellin-moment contribution from the completion-gauge correction. A positive
variance or positive heat semigroup does not imply positivity after that
correction and the actual logarithmic-derivative/Cayley operations.

The note also identifies an endpoint distinction: the raw divided-difference
observable uses totalized division at `r = 0` and returns zero at regular
values; at a zero of Θ its option-valued definition returns `none`. The
nontrivial Cayley Taylor constant belongs to a separately regularized
extension. The infinite analytic germ must be identified with that extension;
a finite coefficient formula alone does not prove this identification.

There are two different induction bases in the current routes. The direct
jet begins with \(d_0(a)=a\Theta'(a)/\Theta(a)\); the central Cayley constant
is \(4a\,\partial_a d_0(a)=4D^2\log\Theta(a)\), where
\(D=a\partial_a\), on the regular domain. A formal change of tower and its
regularity are required before transferring a BASE certificate between them.
Equality of the central bases determines the direct bases only up to a
constant; a normalization value is also needed.

## Master extraction and archival limits

The active master model takes a boundary sequence `c : Nat → Int` explicitly.
Its `binaryIsometry` and `momentBoundary` are universal model hypotheses.
`pascal_hopf`, `energy_hausdorff`, `master_hausdorff_positive`, and
`master_nonnegative_differences` derive the generic consequences of those
hypotheses. No actual GP instance or finite reduction is asserted.

The 29 original master sources are preserved unchanged under
`research/upstream/gp-master-v050`. Their opaque custom RH and four literature
axioms are excluded from the active extraction. The original `MASTER_TO_RH`
therefore supplies no native Mathlib RH endpoint for this repository. The
historical H3 PDE patch under `research/upstream/gp-h3-pde-v051` is likewise
reference material outside the active build.

## Finite-witness work still required

1. Prove the literal density/integral/gauge laws and construct the Hilbert
   vectors and operators with the required domains and regularity.
2. Establish the functional actual-ξ BASE and actual/GP successor from those
   definitions, including the central/direct normalization bridge.
3. Give a finite raw certificate language and a terminating checker whose
   acceptance derives that functional BASE or a sufficient universal residual
   estimate. A finite list of sampled values or model Gram matrices is not enough.
4. Discharge the actual complex germ, pole/channel coverage and all-depth
   growth or cofinal-calibration hypotheses needed by the chosen native RH
   endpoint.
5. Prove completeness for the same checker and verify a concrete accepted
   packet when claiming the full finite-witness iff or a completed RH proof.

See [GP_MATH_REVIEW.md](GP_MATH_REVIEW.md) for the normalization review and
[GP7_SOURCE_AUDIT.md](GP7_SOURCE_AUDIT.md) for the exact GP7 import scope.

The bounded SOS search in `RHFinal/Search.lean` remains a local diagnostic.
This GP integration broadens the available mathematical source and isolates
the actual-data inputs; it does not turn that diagnostic into an RH checker.
