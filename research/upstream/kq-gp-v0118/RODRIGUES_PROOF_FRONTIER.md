# v0.1.14 — Exact polynomial Hasse/Rodrigues bridge

## Native-build frontier

`AllDepth/CayleyPolynomialRodrigues.lean` imports the existing compiled v0.1.13
finite coefficient atlas unchanged. It supplies seven new `theorem` declarations
and two definitions without `axiom`/`sorry`/`admit`.

### Normalization

Write `f(x) = x R(x)` and `c_j = f^(j)(a)/j!`. Then

\[
4a(-4a)^n \sum_{k=0}^{n} \binom{n}{k}a^k c_{n+k+1}
= \frac{(-1)^n(4a)^{n+1}}{(2n+1)!}
  \frac{d^{2n+1}}{dx^{2n+1}}(x^n f(x))\big|_{x=a}.
\]

**Proof (ordinary generalized Leibniz rule):** Put `m=n-k` among the
`n+1` nonzero terms of the product derivative:

\[
\frac{1}{(2n+1)!}\binom{2n+1}{n-k}
  \frac{n!}{k!}
=\frac{\binom nk}{(n+k+1)!}.
\]

Mathlib represents the finite polynomial version by the Hasse derivative:

\[
\mathcal R_n(P;a)=4a(-4a)^n
  [X^{2n+1}]\operatorname{Taylor}_a(X^n P)
=4a(-4a)^n\,\operatorname{eval}_a
  (\operatorname{hasseDeriv}_{2n+1}(X^nP)).
\]

And `Taylor_a(X^nP)=(X+a)^n Taylor_a(P)`.

The module targets these two identities and the zeroth-order equality with
the canonical Cayley coefficient. The unrestricted polynomial **convolution**
identity is currently a *predicate to prove* (`PolynomialRodriguesConvolution`),
not a theorem. The transfer to the **actual** `xiR` remains separate:

- Prove polynomial convolution (pure algebra).
- Prove analytic Taylor approximation/derivative comparison for
  `f(z)=z theta'(z)/theta(z)` on a nonzero neighborhood.
- Prove restriction of the complex jet to the real `xiR` derivative.
- Then B1: `ActualMathlibXiTaylorGermOnRegularAnchors`.

No RH, no positivity or complete xi spectral representation assumed.

## Windows incremental command

Put the patch ZIP in Downloads, apply it to the already compiled project:

```bat
cd /d "%USERPROFILE%\Downloads" && tar -xf "KQ_GP_BKQR_HILBERT_SOLOBOLO_POLY_RODRIGUES_v0_1_14_PATCH.zip" -C "KQ_GP_BKQR_HILBERT_SOLOBOLO_ENDPOINTS_v0_1_3_FASTCORE_FIX1" && call "KQ_GP_BKQR_HILBERT_SOLOBOLO_ENDPOINTS_v0_1_3_FASTCORE_FIX1\run.cmd"
```

Expected incremental work: 42 earlier modules reused, 3 compiled.

**Compiling the new module requires user-native Lean 4.33.0 and the existing
Mathlib cache. Static packaging does not establish Lean compilation.**
