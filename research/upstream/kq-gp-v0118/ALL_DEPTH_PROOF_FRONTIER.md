# ALL-DEPTH SUBEXPONENTIAL CAYLEY FRONTIER — research audit

**Date:** 2026-10-14  
**Lean:** native Windows 4.33.0; retained SOLOB​OLO v0.23.0 and GP/BKQR v0.18.3 inputs.

## Theorem schema

For the literal `NativeSoloboloNegativity.xiWidderMoment a n`, set

\[
\mathcal E_\xi:\quad
\forall a>0\;\forall b>1\;\exists C_{a,b}\ge0\;\forall n\ge0,\quad
|W_n(a)|\le C_{a,b}b^n.
\]

No exponent `2^k` occurs.

For a centered zero with `beta != 0`, `gamma != 0`, the **already proved (abstract-geometry) SOLOBOLO** endpoint is

\[
a_\rho=\beta^2+\gamma^2>0,\qquad
q_\rho=a_\rho/\gamma^2>1,\qquad
r_\rho=1/q_\rho\in(0,1).
\]

The original v0.18.3 `CayleyRadius.lean` and `ActualCayleyObservable.lean` prove that the generic actual-Theta observable is `none` at `(a_rho,r_rho)` for any suitably instantiated `CenteredThetaData`. `InteriorPole.lean` proves a not-centered-RH ⇒ interior-pole theorem. **The original theorems remain unchanged.**

### Newly coded theorem (conditional, exact)

`KQGPBKQRHilbert.AllDepth.subexponential_excludes_offline_zero` takes

1. `Subexponential W`, and
2. `CanonicalPoleGrowth X W`:
   \[
   \forall z\ (\beta_z\ne0)\;\forall b\in(1,q_z)\;\forall C\ge0\;\exists n,\quad Cb^n<|W_n(a_z)|.
   \]

It proves `NativeSolobolo.RiemannHypothesis X` by choosing `b=(1+q_z)/2`. The kernel proof is pure scalar contradiction; **the analytic pole-growth input is not constructed**.

`actual_subexponential_and_pole_growth_imply_RH` also requires `ActualXiZeroCoverage X`, identifying the chosen abstract centered geometry with all actual nontrivial zeros.

An alternative newly coded theorem, `actual_observable_subexp_implies_centered_RH`, combines the **existing actual observable interior-pole endpoint** and the explicitly unproved `ActualThetaSubexpRegularity T`, saying subexponential xi moments prevent poles in the actual Theta Cayley observable.

## Analytic theorem still to formalize

Write

\[
\Theta(z)=\xi\bigl(\tfrac12+\sqrt z\bigr),\quad
R(z)=\Theta'(z)/\Theta(z),\quad
W_n(a)=\operatorname{xiWidderMoment}(a,n).
\]

The correct candidate for the regularized Cayley generating function is

\[
C_a(r)=\sum_{n\ge0}W_n(a)r^n
=\sum_{\rho}m_\rho\frac{q(a,t_\rho)}{1-rq(a,t_\rho)},
\qquad t_\rho=-(\rho-\tfrac12)^2,
\qquad q(a,t)=\frac{4at}{(a+t)^2}.
\]

**Neither the global infinite zero expansion nor its equality with the actual option-valued `actualThetaCayleyObservable` is newly proved in this package.** The existing actual observable is unregularized at `r=0`; a separate analytic continuous/Taylor extension is required.

If a genuine off-line zero yields `q(a_rho,t_rho)=q_rho>1`, then the generating function has an interior pole at `r_rho=1/q_rho` of strictly positive zero multiplicity. Proving no cancellation and locally normal convergence of all other zero terms would imply

\[
\forall 1<b<q_\rho\;\forall C\ge0\;\exists n:\quad
|W_n(a_\rho)|>C b^n,
\]

by Cauchy–Hadamard. **This is the open `CanonicalPoleGrowth` / `ActualThetaSubexpRegularity` interface.**

Conversely, under RH all zero channels satisfy `0≤q≤1` and the genus-zero xi product would yield bounded moments and hence the subexponential envelope. This converse is not formalized in Lean here.

## Distinct all-depth Hausdorff route

`AllDepth/FiniteHausdorff.lean` constructs finite nonnegative channel moments

\[
\mu_n=\sum_i w_i q_i^{n+1},\quad w_i\ge0,\quad 0\le q_i\le1,
\]

and proves the all-depth difference identity

\[
(-\Delta)^k\mu_n=\sum_i w_iq_i^{n+1}(1-q_i)^k\ge0.
\]

These are **finite BKQR model facts**, not actual-ξ calibration. The separate GP–BKQR norm-square transport remains conditional on a concrete actual-ξ calibration. A second all-depth RH closure imports SOLOBOLO's original channel-analysis hypothesis.

## Current proof obligations

- `ActualXiZeroCoverage` or an actual-ξ-zero instantiation for `CenteredXiGeometry`.
- All-depth generating-function identification and regularization at radius zero, including multiplicities and normal convergence.
- Interior-pole ⇒ violation of every weaker exponential envelope, without cancellation.
- Independently establish `ActualXiSubexponential` from KQ/GP/BKQR Hilbert + Cayley/Hausdorff/Zhang/RIEMANCURVE information, without presupposing actual-ξ positivity or RH.

**No RH theorem without explicit analytic inputs is claimed.** `#print axioms` only checks logical axiom dependencies; it never proves a theorem's hypotheses.
