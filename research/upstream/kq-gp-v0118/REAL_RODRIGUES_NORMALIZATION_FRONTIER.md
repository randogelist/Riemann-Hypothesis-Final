# v0.1.18 — actual-xi real Rodrigues normalization

## Proposed Lean theorems (native compilation pending)

For `j ≤ n`, the purely natural-number cancellation is

`choose (2*n+1) j * descFactorial n j * factorial (2*n+1-j)
 = choose n j * factorial (2*n+1)`.

After casting to real scalars and reversing `j=n-k`, the already verified
`actual_xi_widder_direct_finite_leibniz` yields

`xiWidderDirect a n = 4*a*(-4*a)^n * Σ(k=0..n)
  (choose n k) * a^k * (iteratedDeriv (n+k+1) (x ↦ x*xiR x) a / (n+k+1)!)`

The corresponding complex cast is exactly
`canonicalCayleyCoefficient a (actualXiRealTaylorInput a) n`.
Combining with `actual_xi_finite_interpolant_rodrigues` is designed to
prove `ActualXiRealRodriguesCompatibility` for every `xiRegularAnchors` anchor.
Finally `XI_WIDDER_DIRECT_EQ_RECURSIVE_ON_REGULAR_ANCHORS` gives the actual
recursive moment. No extra research axioms or assumptions are introduced.

## Existing open analytic frontiers

- Actual complex slit-Theta Taylor germ coefficient correspondence
- Pole crossing/meromorphic continuation for actual xi zeros
- Independent actual-xi all-depth subexponential rate bound
- Coverage of every nontrivial zeta zero

**Important:** A proof of the real Rodrigues lemma is not the actual-Theta
infinite Taylor-germ proof and is not RH. Lean compilation is unverified
until executed on the native Windows environment.
