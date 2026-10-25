# v0.1.9 — ALL-DEPTH FINITE CAYLEY COEFFICIENT ATLAS

## Mathematical derivation (independent symbolic check)

Let `D_0=1`, `D_1=-4 a r`, `D_{j+2}=-4 a r D_{j+1}-4 a²r D_j`.
The exact combinatorial identity, for every n,j≥0, is

\[ [r^n]D_j = \begin{cases}(-4)^n a^j\binom{n}{j-n}, & n\le j\le 2n,\\ 0,&\text{otherwise}.\end{cases}\]

Consequently, for N≥2n+1,

\[
[r^n]J_N(a,r)=4a(-4a)^n\sum_{k=0}^n {n\choose k}a^k c_{n+k+1}.
\]

The formula was checked by independent exact symbolic expansion for n=0..7, j=0..19.
The full closed binomial coefficient theorem remains a **formalization target**.

If f(z)=z Θ'(z)/Θ(z) is holomorphic near a and c_j=f^{(j)}(a)/j!, then Leibniz's
rule gives

\[
4a(-4a)^n\sum_{k=0}^n {n\choose k}a^k c_{n+k+1}
=\frac{(-1)^n(4a)^{n+1}}{(2n+1)!}
 \frac{d^{2n+1}}{da^{2n+1}}\bigl(a^n f(a)\bigr).
\]

The actual SOLOBOLO Widder derivative is REAL. Formal B1 needs the
complex-to-real derivative compatibility as well as local convergence of the
analytic Taylor expansion. Neither is silently assumed in the new `.lean` module.

## Proven in new Lean source, pending native compile

- `finite_cayley_coefficient_exact`: arbitrary-order coefficient is an exact finite sum.
- `canonical_cayley_coefficient_zero`: normalization of the binomial candidate.
- `zeroth_cayley_coefficient_matches_canonical`: connects to v0.1.8.
- `complex_finite_cayley_jet_differentiable`: each finite jet entire in complex radius.
- `complex_finite_cayley_jet_real`: recovers the real Cayley divided-power endpoint.
- `finite_cayley_coefficients_congr`: dependence only on retained Taylor inputs.

## Still open

1. Closed `Polynomial.coeff` binomial identity, arbitrary n,j.
2. Passage from finite polynomial jets to actual `mathlibSlitTheta` Taylor germ.
3. Compatibility of complex analytic derivatives with real `xiR`/`xiWidderDirect`.
4. The RH-independent all-depth subexponential bound and actual-pole/zero coverage.

The inherited SOLOBOLO endpoint proofs remain byte-identical to the previous
successful Windows package. Compilation of the new module is not performed in
this artifact environment, so Lean proof status is **PENDING USER RUN**.
