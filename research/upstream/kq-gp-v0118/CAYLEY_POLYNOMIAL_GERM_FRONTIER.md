# v0.1.8 — finite Cayley polynomial germ (all depths)

**Scope:** From the previously compiled `AllDepth/SymmetricCayleyGerm.lean`,
prove that *each finite* Cayley difference quotient admits a polynomial
representation in `r`. All inherited source endpoints are unchanged.

Let `s=-4ar`, `p=4a²r` and recursively define `D₀=1`, `D₁=s`,
`Dₙ₊₂=sDₙ₊₁-pDₙ`. The polynomial `Pₙ(r)` constructed in Lean obeys

```
Pₙ(r) = Dₙ(-4ar, 4a²r).
```

For `F(z)= Σ_k c_k (z-a)^k`, every finite Cayley quotient satisfies

```
  4a · Σ_{j<N} c_{j+1} D_j(-4ar, 4a²r)
     = eval_r (finiteCayleyJetPolynomial a c N)
```

and for **all N ≥ 1**:

```
finiteCayleyJetPolynomial(a,c,N)(0) = 4a c_1.
```

For the literal real SOLOBOLO function `xiR`, this matches `W₀(a)` once
`c₁` is identified with `d/da(a xiR(a))`.

### Algebraic coefficient formula (mathematically derived; next Lean target)

The polynomial recurrence has the explicit identity

\[
D_j(a,r)=a^j\sum_{n=0}^{j}\binom{n}{j-n}(-4r)^n,
\]

where the usual convention is that out-of-range binomial coefficients vanish.
Consequently, for any `N ≥ 2n+1`,

\[
[r^n]J_N(a,r)=4a(-4)^n\sum_{j=n}^{2n}
\binom{n}{j-n}a^j c_{j+1}.
\]

For a holomorphic `f(z)=\sum c_j(z-a)^j` this equals

\[
\frac{(-1)^n(4a)^{n+1}}{(2n+1)!}
\left[\frac{d^{2n+1}}{dz^{2n+1}}(z^n f(z))\right]_{z=a}.
\]

Taking `f(z)=z\Theta'(z)/\Theta(z)` gives the correct complex Rodrigues
jet for the actual Theta. **The closed binomial form and its derivative
identification are an analytic calculation in this note; they are not
new Lean theorems in v0.1.8.** The existing Lean module proves the
polynomial realization and the constant coefficient only.

### What is *not* proved

- The actual entire-Theta logarithmic derivative has a compatible complex
  Taylor series on an analytic neighborhood of each positive anchor.
- The real-vs-complex derivative matching `c₁ = d/da(a xiR(a))`, and its
  all-depth Cauchy/Rodrigues generalization.
- Uniform convergence of the finite polynomial jets on a nonzero radius
  disk and identification with the actual Cayley observable.
- The all-depth subexponential bound, actual off-line pole continuation and
  zero coverage.

The package has been statically audited, **not native Lean compiled** here.
Use `run.cmd` for native Windows proof checking. No new `axiom`, `sorry` or
research assumptions are declared.
