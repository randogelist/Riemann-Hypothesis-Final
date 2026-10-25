# v0.1.10 — stable Cayley coefficients at every depth

**New result to kernel-check in Lean:**

Let \(D_0=1\), \(D_1=-4ar\), \(D_{j+2}=-4arD_{j+1}-4a^2rD_j\), and
\(J_N(a,r)=4a\sum_{j=0}^{N-1}c_{j+1}D_j(a,r)\). Then

\[
oxed{[r^n]D_j=0\quad(j>2n)}.
\]

In particular, for every \(n\ge0\) and every \(N\ge2n+1\),

\[
oxed{[r^n]J_N(a,r)=[r^n]J_{2n+1}(a,r).}
\]

The latter coefficient is defined as `stableCayleyCoefficient a c n`.
No positivity or actual-theta hypothesis occurs in these statements.

## Proof plan encoded

1. An exact polynomial `X`-factor recurrence for each `D_j`.
2. Coefficient recursion for the pair `(j,n)`.
3. Induction on `n`: coefficients vanish for `j>2n`.
4. A finite-sum stabilization lemma and a `2n+1`-input endpoint.
5. Compatibility at `n=0` with v0.1.8 and the v0.1.9 candidate.

**Not proved:**
- The binomial closed formula at every `n` (only the `n=0` case is proved here).
- Equality with the actual real `xiWidderDirect` for `n>0`.
- Convergence of the actual Mathlib theta Cayley Taylor germ.
- The independent subexponential bound, actual pole transfer or zero coverage.

This is an incremental project patch. The 187 existing theorem declarations were
compiled in the user's native Windows v0.1.9 run. There are **10 new theorem
declarations and 1 new definition** in the v0.1.10 source (Lean compilation
pending). It has no `sorry`/research axioms.
