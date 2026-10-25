# v0.1.17 — actual xi real Leibniz frontier

## Mathematically proved by the new source (pending native Lean compilation)

For any real analytic f at a, and m=2n+1:

D^m (x^n f(x))|_{a} = Σ_{j=0}^n C(m,j) n^{\underline j} a^{n-j} D^{m-j} f(a).

The module specializes to f(x)=x*xiR(x), on exactly `xiRegularAnchors`,
and identifies the literal `xiWidderDirect` with its finite Leibniz sum.
Mathlib `iteratedDeriv_fun_mul` and `iteratedDeriv_pow` furnish the analytic
core; the finite-sum tail vanishes because `descFactorial n j=0` for j>n.

## Remaining purely combinatorial normalization

For j <= n, m=2n+1:

C(m,j)*n.descFactorial(j)/m! = C(n,j)/(m-j)!.

Reflect j=n-k, and the sum becomes the already compiled canonical Cayley
coefficient of the actual normalized real derivatives. Then the
`ActualXiRealRodriguesCompatibility` predicate can be proved instead of
passed as an assumption.

## Other open frontiers

- Actual complex slit-Theta Taylor germ and real/complex derivative matching
- Genuine off-line zero pole transfer/noncancellation
- Independent xi all-depth subexponential bound
- Actual nontrivial-zero coverage

No unconditional RH claim. No sorry, admits, or research axiom declarations.
