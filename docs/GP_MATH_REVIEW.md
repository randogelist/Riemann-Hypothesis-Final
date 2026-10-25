# GP mathematical integration review — 2026-10-25

Read-only source review apart from the explicitly assigned
`RHFinal/GP/NativeBinding.lean` and `NativeBindingAudit.lean`. No Lean compiler
was run. Mathematical reasoning and exact coefficient arithmetic below are
not native compilation or axiom-audit receipts.

## Continuous GP normalization

The analytic note's measure is
`dμ(r,y) = 2 d(r) dr dy/y`, with `d(r) = -d/dr[r/(exp r-1)]`,
`r>0`, and `1/4<y<1/2`. Under `t=ry` its pushforward density is

`(2/t) [B(2t)-B(4t)] = 4/(exp(2t)+1) = 2 exp(-t) sech(t)`.

Consequently its formulas for `I(u,s)=Γ(s)G(u,s)` and
`I₀(s)=2^(2-s)Γ(s)(1-2^(1-s))ζ(s)` have consistent constants.
In particular `I₀(1)=2 log 2`, `P(1)=1/(4 log 2)`, and their product is
the native ξ normalization `ξ(1)=1/2`. These integral evaluations, derivative
interchanges and removable extensions still require Lean proofs.

`RHFinal/GP/Literal.lean` uses this measure, not an abstract replacement.
Its use of closed y endpoints changes only a Lebesgue-null set. `ofReal`
produces a nonnegative measure by definition; it does not prove strict
positivity of the intended density. The file correctly leaves `DensityLaw`,
`MellinEvaluation`, `LogMomentDifferentiation` and `NativeXiFactorization`
as open propositions. L² membership of the vector representative and lifting
the heat multiplier to an operator remain open. No mathematical/domain error
was found in its definitions or four pointwise heat-multiplier lemmas by
inspection; their Lean elaboration has not been checked.

The separate finite formula `gpMoment Y k = 4/(k+1)^Y` is a unit-interval
log-weight moment model, not this continuous Mellin–Hilbert measure. GP7's
weight-seven construction is another separately indexed source model.
Names shared between these constructions do not supply an identification.

## Direct, central, and recursive normalizations

The new direct jet is
`dₙ(a)=(-1)^n a^(n+1) R^(n)(a)/n!`, where `R=Θ′/Θ`. Its formula-derived
successor is `dₙ₊₁=dₙ-a dₙ′/(n+1)` under the explicit regularity premise.
Its base is `d₀=aR`.

The central expression in `RHFinal/Actual/Frontier.lean` uses
`Wₙ=4^(n+1) Σ_{j=0}^{n+1} (-1)^j choose(n+1,j) dₙ₊ⱼ`.
At depth zero this gives `W₀=4(d₀-d₁)=4a ∂a(aR)=4D²log Θ`, for
`D=a∂a`. This is the central BASE of the analytic GP note and the recovered
KQ `xiWidderBase`; it is not the direct-jet base `aR`.

The analytic note's first central coefficient is correspondingly
`sqrt(a) [E_s(log L)+g(s)] + a [Var_s(log L)+g′(s)]`, with
`s=1/2+sqrt(a)` and `g=P′/P`. The positive variance does not supply a sign
for the gauge-corrected total or its higher Widder transforms.

Central BASE equality determines direct bases only up to a constant on each
connected positive-anchor interval. A normalization value is additionally
required to infer direct BASE equality. Alternatively, stay wholly in the
central Widder tower and use its correctly derived second-order successor.
Domain-aware induction uniqueness on `(0,∞)` should use local derivative
congruence; whole-real-line equality is stronger than the analytic source
provides and unnecessarily introduces nonpositive-anchor behavior.

The general finite Leibniz identity converts the direct-jet binomial sum to
the Rodrigues expression in the note. The recovered v0.1.18 sources contain
the real finite-coefficient/Rodrigues normalization. Transfer to the new
complex-derivative definition still needs the explicit real/complex derivative
compatibility theorem on positive regular anchors; it is not just a change
of notation.

## Literal native-source bridge added

KQEndpoints already proves `actualXi_eq_kqXi` and
`actualTheta_eq_kqSlitTheta` by `rfl`, correctly matching the exact entire
completion and principal square-root descent. It transports positive-anchor
analyticity without asserting nonvanishing.

The added `RHFinal.GP.NativeBinding.actualLogDerivative_eq_native` is also
`rfl`: both sides use literal `deriv` of the identical theta function.
It introduces no analytic calibration assumption and no abstract derivative.

`NativeBinding.cayley_widder_pde_cleared` adapts the recovered H3 polynomial
identity into a self-contained namespace, without unavailable patch imports.
For `Q=(z-a)^2+4arz`, `N=4az`, and `Qa=2(a-z)+4rz`, this is the
cleared-Q-cubed form of the universal kernel PDE. The supplied proof source
uses `ring`. An independent exact integer-polynomial expansion produced zero
residual coefficients. This arithmetic check is not Lean verification.

These two new declarations have matching `#print axioms` targets in
`NativeBindingAudit.lean`.

## H3 and finite-input status

The H3 patch's polynomial identity does not yet show that the actual theta
Cayley observable satisfies a PDE. Required bridges remain: nonzero kernel
denominator, rational differentiation, analytic transport under the contour
integral, regularized germ at radius zero, coefficient/PDE interchange, and
actual off-line-pole growth. Its recurrence uniqueness theorem assumes the
base and recurrence for an arbitrary coefficient family; it does not derive
those premises for actual data.

At `r=0` the old quotient-valued observable evaluates to zero when theta is
nonzero (and `none` at a theta zero), because its numerator and denominator
coincide at zero. The intended regularized value is `4a∂a(aR)`. Therefore
Taylor formulas and analytic-germ claims must use a separately defined
regularized observable, not the totalized quotient's raw value at zero.

The integral identity represents the same actual ξ through a completion
gauge; it does not produce a positive ξ spectral measure. GP heat-semigroup
positivity applies to the linear Mellin readout. Taking logarithmic derivatives,
changing parameters, and adding the gauge correction do not preserve this
positivity automatically. The inherited abstract `ScalarProductGeometry`
also has its own `nonnegative` relation; it must be tied to the ordinary real
order by a concrete Hilbert realization.

Thus no finite raw checker has acquired actual-data soundness here. Finite
quadrature/SOS packets can verify finite rational identities or enclosures,
but the functional BASE, uniform all-order calibration/convergence, and actual
RH transfer must be independently derived. No formal closure, accepted RH
witness, or Lean-ready status follows from these integrations.
