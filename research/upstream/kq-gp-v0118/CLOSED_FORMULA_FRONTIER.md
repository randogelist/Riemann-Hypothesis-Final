# v0.1.13 finite all-depth coefficient bridge

All-depth finite proof target (no RH or xi spectral input):

\[
[r^n] J_N(a,r) = 4a(-4a)^n\sum_{k=0}^{n}\binom nk a^k c_{n+k+1}
\qquad (N\ge 2n+1).
\]

The source `AllDepth/CayleyFiniteClosedFormula.lean` is designed to prove this by:

1. `cayley_coeff_above_diagonal_zero`: discard j < n;
2. `Finset.sum_range_add`: reindex the remaining j=n+k;
3. `cayley_polynomial_binomial_unconditional`: evaluate coefficient of D_(n+k);
4. `finite_cayley_coefficient_stable_of_le`: propagate to every N ≥ 2n+1.

No axiom, sorry or new conditional mathematical premise is introduced.
The added proofs have **not** been Lean-compiled in this artifact environment.

Remaining B1 work (not covered here): analytic infinite Taylor convergence and the exact
complex-to-real Rodrigues derivative compatibility for the actual Mathlib xi function.
Also open: the independent subexponential estimate and actual off-line pole/zero coverage.
