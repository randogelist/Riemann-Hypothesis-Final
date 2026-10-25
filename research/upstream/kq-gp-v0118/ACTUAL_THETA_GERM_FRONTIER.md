# v0.1.7 — Genuine Θ Taylor bridge: root-free all-depth reduction

**Status:** New source; Windows native Lean 4.33.0 compilation required. All original SOLOBOLO and v0.1.6 files are byte-preserved; only the root imports/Main and runner/build order change.

## New purely algebraic theorem

For `a>0`, `0≤r≤1` let `z₊,z₋` be SOLOBOLO's actual Cayley conjugate points, and put `u=z₊−a`, `v=z₋−a`. Inherited `CAYLEY_PAIR_SUM` and `CAYLEY_PAIR_PRODUCT` yield **exactly**

\[
\boxed{u+v=-4ar,\qquad uv=4a^2r.}
\]

Let `P_0=(0,1)` and `P_{n+1}=(P_n.2,(u+v)P_n.2-uvP_n.1)`.
Then by induction, for **all** `n`:

\[
\boxed{(u-v)P_n.2=u^{n+1}-v^{n+1}.}
\]

The right-hand side factors through the two symmetric invariants and therefore is a polynomial in `r`, with no `sqrt(r)` or division by `u-v`. A finite analytic Taylor jet of *any* germ `f(z)=Σ_{j=0}^N c_j(z-a)^j` now has a root-free Cayley divided-difference polynomial:

\[
\boxed{(z_+-z_-)\mathcal{J}_{N}(a,r) =4a \sum_{j=1}^N c_j ((z_+-a)^j-(z_--a)^j).}
\]

The Lean file `AllDepth/SymmetricCayleyGerm.lean` implements these identities using `symmetricPowerPair`, `shiftedCayleyDividedPower`, and `finiteShiftedCayleyJet`.

## Canonical actual-Θ specialization

`CenteredThetaData` is only an *abstract* data structure; it does **not** imply the theta field is the actual Mathlib `mathlibSlitTheta`. It is incorrect to claim B1 for all abstract data.

The module `AllDepth/ActualMathlibThetaInterface.lean` instead defines `actualMathlibXiCayleyEval`, from literal `mathlibSlitTheta` and `deriv mathlibSlitTheta`. It proves that this coincides definitionally with the inherited `actualThetaCayleyObservable (mathlibSlitThetaData X hzero)`. It also imports the already-proved complex analyticity at real positive anchors.

The remaining B1 theorem is **precisely** the predicate `ActualMathlibXiTaylorGermOnRegularAnchors`. Conditional transfer back to the original abstract interface is `actualMathlibXiTaylorGerm_to_original`; it also needs `AllPositiveXiRegular` to handle **all** positive anchors.

## Analytic obligation (not claimed as proved)

At any `a ∈ xiRegularAnchors`, let

\[
f(z)=z\frac{\Theta'(z)}{\Theta(z)},\qquad
\Theta(z)=\xi(\tfrac12+\sqrt z).
\]

The exact target is the local Cauchy integral identity:

\[
\mathcal C_{\Theta}^{\mathrm{reg}}(a,r)=
\frac{4a}{2\pi i}\oint_{|z-a|=\epsilon}
\frac{f(z)}{(z-a)^2+4arz}\,dz,
\]

then the uniformly convergent geometric expansion

\[
\frac1{(z-a)^2+4arz}=
\sum_{n\ge0}\frac{(-4ar z)^n}{(z-a)^{2n+2}}
\]

yields

\[
[r^n]\mathcal C_{\Theta}^{\mathrm{reg}}(a,r)=
\frac{(-1)^n(4a)^{n+1}}{(2n+1)!}
\left[\partial_z^{2n+1}(z^{n+1}R(z))\right]_{z=a}.
\]

To discharge B1 in Lean we **still** need (i) Cauchy two-point formula on a sufficiently small contour, (ii) uniform kernel-series interchange, (iii) complex-to-real iterated derivative comparison against `xiR`, and (iv) positive-anchor regularity if targeting all anchors rather than the regular ones.

**Independent RH obligations A, B2 and C remain untouched.** The new algebra does NOT itself prove the actual-germ equality or RH.
