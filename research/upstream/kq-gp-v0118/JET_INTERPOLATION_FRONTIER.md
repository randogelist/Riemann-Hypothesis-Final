# v0.1.16 — Finite Taylor-jet interpolation, all depths

**Inherited Lean-compiled base:** v0.1.15 FIX1 PASS supplied by user (46 compiled modules).

## Exact newly submitted theorem

For every anchor a, sequence c : ℕ → ℂ, depth n, let

Q_N(X) = Σ_{j<N} c_j X^j,     P_N(X) = Q_N(X-a).

Then, as POLYNOMIALS,

Taylor_a(P_N)(X) = Q_N(X),
[Taylor_a(P_N)]_j = c_j  for j<N,

and for N=2n+2,

canonicalCayleyCoefficient(a,c,n)
  = polynomialRodriguesCoefficient(a,P_{2n+2},n).

Proof: `Polynomial.ofFn`, `Polynomial.taylor_taylor`, and already Lean-verified
`polynomial_rodrigues_convolution_all_depth` together with jet congruence.
No xi positivity, zero coverage, or spectral hypothesis is assumed.

## Actual ξ specialization

Let f(x)=x*xiR(x) (REAL) and

c_j(a) = (iteratedDeriv j f a)/j!  coerced ℝ→ℂ.

The new module constructs its finite interpolating polynomial P_{a,n} at
all anchors and depths. **This is not yet the actual analytic Theta germ.**

The precise remaining differentiation theorem is:

  polynomialRodriguesCoefficient(a,P_{a,n},n)
    = (xiWidderDirect(a,n):ℂ)

at positive regular anchors. It is named
`ActualXiRealRodriguesCompatibility : Prop` and is **not proved**.
It should follow from the real generalized Leibniz formula using
`iteratedDeriv_mul`, `iteratedDeriv_pow` and factorial/binomial arithmetic.

When that real derivative compatibility is proved, the existing
`XI_WIDDER_DIRECT_EQ_RECURSIVE_ON_REGULAR_ANCHORS` immediately supplies
canonical Cayley coefficient = actual xi Widder moment.

Still separate: actual complex Theta analytic Taylor germ (B1); genuine
noncancellation/pole transfer (B2); independent subexponential estimates (A);
zero coverage (C). No unconditional RH conclusion.

**Verification:** source/import order/ZIP checked; no Lean 4 binary in the
packaging runtime. User's native Lean 4.33.0 build must verify this new patch.
