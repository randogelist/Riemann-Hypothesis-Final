# v0.1.12 — Unconditional top diagonal

The previous v0.1.11 Lean endpoint
`cayley_polynomial_binomial_of_top` required `CayleyTopDiagonal a`.

This patch aims to prove that condition directly from the already verified
root-free polynomial recurrence:

\[D_0(X)=1,\quad D_1(X)=-4aX,\quad
D_{n+2}(X)=X((-4a)D_{n+1}(X)-4a^2D_n(X)).\]

The paired induction proves simultaneously
\[[X^n]D_n(X)=(-4a)^n,\qquad [X^m]D_n(X)=0\quad(m>n).\]

The inherited Pascal theorem then immediately gives
\[[X^n]D_{n+k}(X)=(-4a)^na^k\binom nk\quad\text{for all }n,k.\]

### Status

- Existing v0.1.11 inherited sources unchanged.
- No new axioms, admits, sorries or special zero assumptions.
- Proposed new module has not been kernel-compiled in this environment.
- No claim of actual-Theta infinite Taylor convergence, xi coefficient
  calibration, subexponential envelope, zero coverage, or RH.
- After native Windows PASS the next target is the finite coefficient
  reindexing into `canonicalCayleyCoefficient`.
