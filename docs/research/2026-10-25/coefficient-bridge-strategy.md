# A finite-jet route to the actual product-log coefficient identity

25 October 2026. This is a mathematical derivation and implementation strategy, not a compiled Lean theorem. No Lean, Lake or native runner was executed, and no repository files were changed. Exact integer/rational polynomial checks are recorded separately in `coefficient_checks.py` and `coefficient_checks.json`.

## Main result of the deeper review

No inspected existing declaration closes the actual product-log coefficient identity by composition alone. However, **the required finite coefficient algebra is already in the active repository**. The remaining analytic step can be reduced to a generic local finite-jet theorem. A rational Cayley parameter eliminates square-root differentiation, global determinant limits, contour integration, infinite-sum interchange and fractional-power remainder estimates.

The proposed theorem uses only local analyticity and nonvanishing at the chosen anchor. Those properties are already available for the actual functions. Thus the coefficient bridge is a local formalization task with an explicit proof below; it does not require a new positivity, energy-growth, RH or spectral assumption. Completing it would remove the product-coefficient input from the N01 endpoint, while leaving its energy estimate open.

## 1. Fix the literal normalization

For a nonzero real anchor a, let Θ be complex analytic near a with Θ(a)≠0. Put

F(z)=Θ′(z)/Θ(z),   G(z)=zF(z).

Let z±(r) have sum 2a(1−2r) and product a². Define the normalized symmetric product

P_a(r)=Θ(z+(r))Θ(z−(r))/Θ(a)²,

and its local logarithmic derivative h_a(r)=−P_a′(r)/P_a(r). Assume P_a is analytic at zero; P_a(0)=1. The root labels do not matter. In the actual N01 source, a=1, P_a is `AWPIRH.symmetricProduct`, h_a is `AWPIRH.productLogDerivative`, and

`productLogCoefficients n = iteratedDeriv n productLogDerivative 0 / n!`.

The desired all-order identity is

\[
\frac{h_a^{(n)}(0)}{n!}
=\frac{(-1)^n(4a)^{n+1}}{(2n+1)!}
  \left.\frac{d^{2n+1}}{dz^{2n+1}}\bigl(z^{n+1}F(z)\bigr)\right|_{z=a}.
\]

At a=1 the right side is exactly D154's `complexRodrigues 1 n`. This concerns coefficients of **−P′/P**, not coefficients of P or log P. The normalization by Θ(a)² cancels from h but is useful for P(0)=1.

## 2. Reuse the finite algebra already proved

Write

\[
c_j=G^{(j)}(a)/j!,\qquad b_j=F^{(j)}(a)/j!.
\]

Then c₀=ab₀ and, for j≥1, c_j=ab_j+b_(j−1).

For shifted roots u=z+−a and v=z−−a,

u+v=−4ar,   uv=4a²r.

The divided-power polynomials D_j satisfy

D₀=1, D₁=−4ar, D_(j+2)=−4arD_(j+1)−4a²rD_j,

and `(u−v)D_j(r)=u^(j+1)−v^(j+1)`, including coalesced roots as a cleared identity. Define

\[
Q_n(r)=4a\sum_{j=0}^{2n}c_{j+1}D_j(r).
\]

This is precisely `finiteCayleyJetPolynomial a c (2*n+1)`. The active theorem `finite_cayley_coefficient_closed_minimal` already gives

\[
[r^n]Q_n
=4a(-4a)^n\sum_{k=0}^{n}\binom nk a^k c_{n+k+1}
=\operatorname{canonicalCayleyCoefficient}(a,c,n). \tag{1}
\]

Substituting c_j=ab_j+b_(j−1) and using Pascal's identity gives

\[
[r^n]Q_n
=(-1)^n(4a)^{n+1}
 \sum_{k=0}^{n+1}\binom{n+1}{k}a^k b_{n+k}. \tag{2}
\]

Leibniz identifies (2) with the desired Rodrigues expression. Alternatively, retain G and reuse the existing polynomial Rodrigues/interpolation theorems. The active `actual_xi_all_depth_finite_cayley_coefficients` already identifies (1), for the real actual-xi Taylor input, with the actual recursive Widder tower. D154 supplies another route to the same normalized complex Rodrigues expression.

**Do not redo the Pascal triangle or introduce a new all-depth combinatorial hypothesis.** They were closed by the existing v0.1.13–v0.1.18 source sequence. Earlier comments describing intermediate targets as open are superseded by downstream theorems.

One small algebra adapter is needed: the existing `cayleyPolynomialPair_eval` is stated for real r. Prove its identical recurrence/evaluation statement for complex r, keeping the real anchor cast. Its proof is the same induction/ring calculation; the coefficient theorem (1) is unchanged. `symmetricPowerPair_identity` already accepts arbitrary complex u,v.

## 3. Remove the square roots with a rational parameter

Use a new local complex parameter t and the rational maps

\[
r(t)=\frac{t^2}{1+t^2},\quad
z_+(t)=a\frac{1+it}{1-it},\quad
z_-(t)=a\frac{1-it}{1+it}.
\]

All denominators are nonzero near t=0. These maps are analytic there, and finite algebra gives

\[
z_++z_-=2a(1-2r(t)),\qquad z_+z_-=a^2,
\]

\[
u_+(t)=z_+(t)-a=t\frac{2ia}{1-it},\quad
u_-(t)=z_-(t)-a=t\frac{-2ia}{1+it},
\]

\[
z_+(t)-z_-(t)=t\frac{4ia}{1+t^2}. \tag{3}
\]

Thus the pair is exactly the unordered root pair used by P_a. A root-swapping argument gives the **eventual exact identity**

\[
P_a(r(t))=\Theta(z_+(t))\Theta(z_-(t))/\Theta(a)^2. \tag{4}
\]

For a=1, existing `AWPIRH.quadratic_factorization` is enough for the root-swapping lemma: either z+ is the named plus root or the named minus root; equality of root sums identifies the other root. No chosen branch needs to be analytic. At t=0 both roots coincide, and the product identity still holds.

Differentiate (4) once. The needed rational derivative identities are

\[
r'(t)=\frac{2t}{(1+t^2)^2},\qquad
\frac{z_+'(t)}{z_+(t)}=\frac{2i}{1+t^2},\qquad
\frac{z_-'(t)}{z_-(t)}=-\frac{2i}{1+t^2}.
\]

For sufficiently small t≠0, Θ at both points and P_a(r(t)) are nonzero. The chain and product rules therefore yield

\[
h_a(r(t))
=-\frac{i(1+t^2)}{t}\bigl(G(z_+(t))-G(z_-(t))\bigr)
=4a\frac{G(z_+(t))-G(z_-(t))}{z_+(t)-z_-(t)}. \tag{5}
\]

The sign in (5) is essential: it comes from the definition h=−P′/P. One differentiates the **holomorphic rationally parameterized product**, not a principal square root on its branch cut.

## 4. Exact Taylor factorization replaces all limiting estimates

Fix n and let M=2n+2. Local analytic Taylor factorization gives an analytic germ A at zero such that

\[
G(a+u)=\sum_{j=0}^{M-1}c_j u^j+u^M A(u). \tag{6}
\]

Only this finite Taylor polynomial is used. Let k±(t)=u±(t)/t and d(t)=4ia/(1+t²). Both k± and d are analytic near zero, d(0)=4ia≠0, and u+−u−=t d(t).

Insert (6) into (5). The constant Taylor term cancels. The polynomial terms give exactly Q_n(r(t)) by the divided-power identity. The remaining terms are

\[
h_a(r(t))-Q_n(r(t))=t^{2n+1}B_n(t), \tag{7}
\]

where a concrete analytic remainder is

\[
B_n(t)=\frac{4a}{d(t)}
\left(k_+(t)^M A(u_+(t))-k_-(t)^M A(u_-(t))\right).
\]

Initially (7) follows for small nonzero t. Both sides are analytic, hence continuous, at zero; extend the equality there by continuity. This uses no derivative of a little-o term and no exchange of infinite series. It also avoids estimating root separation: the separation's factorization (3) is exact.

Let E_n(r)=h_a(r)−Q_n(r). It is analytic at zero. Since r(t)=t²/(1+t²), its analytic vanishing order is exactly two. Composition of analytic orders gives

\[
\operatorname{ord}_0(E_n\circ r)=2\operatorname{ord}_0(E_n).
\]

Equation (7) implies the left side is at least 2n+1. Therefore ord₀(E_n)≥n+1, including the case of an identically zero germ. Every derivative of E_n through order n vanishes. In particular,

\[
\frac{h_a^{(n)}(0)}{n!}=[r^n]Q_n.
\]

Combining with (1)–(2) finishes the coefficient identity for every n.

This is the key new reduction: **a finite jet in the rational parameter plus the order-two composition law proves the desired coefficient passage**. It is substantially smaller than constructing a global product representation or proving derivative convergence of infinite determinant approximants.

## 5. Existing Mathlib 4.33 APIs support the exact route

The following names and signatures were read directly from local source, not guessed or tested by compilation:

`/workspace/toolchains/mathlib4-4.33.0/Mathlib/Analysis/Analytic/Order.lean`:

- `AnalyticAt.exists_eventuallyEq_sum_add_pow_mul`: finite Taylor expansion at zero with error `z^M • A z`, where A is analytic at zero. This gives (6) after translation by a.
- `natCast_le_analyticOrderAt`: divisibility by a power of the centered variable is equivalent to the corresponding lower bound on analytic order. This applies directly to (7).
- `AnalyticAt.analyticOrderAt_comp`: the analytic order of a composition is the outer order multiplied by the inner centered order.
- `analyticOrderAt_mul`, `analyticOrderAt_pow`, and the nonzero-value order-zero result compute the order of t²/(1+t²).
- `natCast_le_analyticOrderAt_iff_iteratedDeriv_eq_zero`: turns order≥n+1 into vanishing derivatives through n.

`Mathlib/Analysis/Calculus/IteratedDeriv/Lemmas.lean` has `iteratedDeriv_comp_add_const`, for translating G(a+u)'s Taylor coefficients. The finite-sum/polynomial derivative normalization can be read from the existing polynomial Taylor/Hasse source or derived with the ordinary polynomial derivative evaluation API. The extended-natural arithmetic `2m≥2n+1 ⇒ m≥n+1` should be isolated in a short helper covering m=top explicitly if automation does not handle it.

No exact generic product-coefficient bridge with these conclusions was found in the inspected project sources. The above are the minimal new pieces, not declarations already present:

1. **Unordered roots preserve the product** and the rational parameter identities (finite algebra).
2. **Parameterized product logarithmic derivative** (one local chain-rule calculation).
3. **Complex-radius finite divided-power evaluation** (small adapter to existing recurrence).
4. **Finite-jet agreement through an order-two parameter** (Taylor factorization plus existing analytic-order APIs).
5. **Actual endpoint wiring** to D154, or to actual real Taylor calibration and the active canonical coefficient theorem.

For the first implementation, specialize a=1 and use the existing AWPIRH P/h definitions. This avoids introducing a new family of products and uses the already proved `productLogDerivative_analyticAt_zero`. A later generalized positive-anchor theorem can reuse RI01 determinant holomorphy and then discharge the local B1 actual Taylor-germ interface after real/complex jet transport.

## 6. Constant and sign checks

With F and its derivatives evaluated at a:

\[
p_0=4a(F+aF'),
\]

\[
p_1=-16a^2(F'+aF''+a^2F'''/6),
\]

\[
p_2=64a^3(F''/2+aF'''/2+a^2F^{(4)}/8+a^3F^{(5)}/120).
\]

At a=1 these agree with `Candidate_Derivations_Rounds_1_3.txt`. Independent review reproduced the general formula using symmetric power sums and a local logarithm. Two simple exact examples provide separate checks:

- Θ(z)=exp(cz): P_a(r)=exp(−4acr), so h_a=4ac; only p₀ is nonzero. The Rodrigues formula gives the same result.
- Θ(z)=1+tz with 1+at≠0: P_a(r)=1−qr, q=4at/(1+at)². Hence h_a=q/(1−qr), p_n=q^(n+1), agreeing with Rodrigues.

The attached dependency-free exact arithmetic script verifies the divided-power coefficient formula, the c-to-b substitution and Rodrigues factorial normalization for n=0,…,8. It also verifies the symmetric power-sum coefficient formula over a finite grid. These checks catch constants and indexing errors; they are not a substitute for the all-n proof or Lean verification.

## 7. Exact source dependencies and endpoint impact

| Source | What is reused |
|---|---|
| `Riemann-Hypothesis-Final/AllDepth/SymmetricCayleyGerm.lean` | `symmetricPowerPair_identity`; root-free divided-power recurrence. |
| `AllDepth/CayleyPolynomialGerm.lean`, `CayleyStableCoefficients.lean`, `CayleyFiniteClosedFormula.lean` | Finite polynomial Q_n, stabilization, `finite_cayley_coefficient_closed_minimal`. |
| `AllDepth/CayleyRodriguesConvolution.lean`, `CayleyJetInterpolation.lean` | Existing finite Rodrigues/Hasse/interpolation route, if preferred to the direct binomial sum. |
| `AllDepth/ActualXiRealRodriguesNormalization.lean` | `actual_xi_all_depth_finite_cayley_coefficients`; no remaining polynomial-normalization hypothesis. |
| `AWPIRH/ProductGeometry.lean`, corpus `6fbe01c2b9302346a2e0cbd6cb90e607e9f6ea54c1f5ff8562738b2ea7286e06.lean` | Literal P, root quadratic factorization, P(0)=1. |
| `AWPIRH/ProductLogGerm.lean`, corpus `777d5222b01386ed00a52db7df138dd8a81d8977894e9dfd886b1896c1e068e4.lean` | Actual h and coefficients, local analyticity/nonvanishing, positive-radius series. Use its coherent `ProductEntire` dependency closure. |
| D154 `Develop/NativeCoefficientCoordinates.lean`, hash `efba47147dbf09a883e7155787e281edf5565aae11505ed0b27dd8d6beaa7178` | `nativeCoefficients_eq_complexRodrigues`, real/complex iterated-derivative transport, precise residual iff. |
| RI01 v0.16.1 `RI01NativeHolomorphicBall.lean`, hash `8c9556a592a301b3090ad5f6e4bd017c132ac9613a9669a9cff31a53eda16b3d` | Local determinant holomorphy for arbitrary positive anchor; optional for a=1 AWPIRH implementation. |
| `RI01NativeSlitDerivative.lean`, hash `73a12fddd779b02194b907f7839c12cb5fc015fe95c1b4845ebbfc68417ec753` | Real xiR equals literal complex theta logarithmic derivative at regular positive anchors; useful for general B1 wiring. |
| `RHFinal/GP/NativeBinding.lean` | Cleared H3 kernel PDE is compatible but **unnecessary** for this proof. It supplies no analytic coefficient transfer by itself. |

The rational-parameter proof uses only local holomorphy. For a=1 it does not need RI01's finite determinant convergence or a new all-depth induction transition. Generalizing to all positive regular anchors would establish the missing analytic interpretation of the already proved canonical Cayley/Widder coefficients; the positive radius of the analytic h series then supplies the local generating-series equality.

At a=1, compose the proved coefficient formula with D154:

`nativeCoefficients n = complexRodrigues 1 n = productLogCoefficients n`.

This would discharge `NativeProductCoefficientIdentity`, and equivalently `XiWidderProductCoefficientIdentity`, as an actual theorem without research assumptions. `ACTUAL_LOCAL_ROW_ODE_OF_COEFFICIENT_IDENTITY` and the existing N01 terminal implication could then be invoked with the coefficient hypothesis supplied rather than left open.

It would **not** prove `US_AWPI`, the subexponential Bernstein-energy/variation estimate, positive moment representation, actual finite witness admission, a global GP/H_a isometry, or RH. Those estimates concern the sizes/signs of the now-identified coefficients. The present derivation fixes their identity; it does not bound them.
