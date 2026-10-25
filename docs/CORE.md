# Local finite certificate kernel

These sources are newly written and await native Lean 4.33 compilation and
axiom audit. No A-Tier, closure, or RH-witness status is asserted.

`RHFinal.FiniteWitness` contains only
lists of integer polynomial coefficients. The fixed `LocalProblem` is supplied
separately. `checkLocal` terminates by finite polynomial arithmetic and checks
the exact coefficient identities

\[
B(X)=\sum_i f_i(X)^2,\qquad
N(X)=A(X)^2B(X)+\sum_j r_j(X)^2.
\]

Polynomial coefficients are stored in ascending order. `Polynomial.mul`
computes convolution; proof source establishes its evaluation rule. The local
soundness theorems conclude these identities at every integer argument. They
do not identify `B`, `A`, or `N` with actual xi-derived functions, and this
version does not export a real-variable nonnegativity theorem. Literal list
equality is deliberately conservative: trailing zeroes can cause rejection.

`searchLocal problem bound` enumerates a finite template: one linear base
factor and one linear remainder factor, each coefficient in `[-bound,bound]`.
It returns the first accepted packet, or `none`. A returned packet satisfies
`LocalIdentities` by `searchLocal_sound`. No completeness beyond the enumerated
template is claimed. At bound 1 there are 81 candidates. The diagnostic target
is `(1+X)^2` followed by `(1+X)^2+X^2`, with multiplier 1; the diagnostic is
explicitly unrelated to RH witness admission.

`RHFinal.Core.Induction` exposes the intended SOLOBOLO transfer exactly:
shared transition + functional base equality implies equality at every order.
For the intended differential recurrence, the state must be a whole function
on its required domain. Equality at a finite set of sampled points is not
functional base equality. The theorem `transfer_of_finite_base_soundness`
retains `baseSound` as an explicit hypothesis; constructing it for actual xi
from finite raw data remains an open research endpoint.

Core build order:

1. `RHFinal/Core/Polynomial`
2. `RHFinal/Core/LocalWitness`
3. `RHFinal/Core/Induction`
4. `RHFinal/Core/BoundedSearch`
5. `RHFinal/Search`
6. `RHFinal/Audit`

All exported theorem sources are listed in `RHFinal/Audit.lean`. They use no
custom axioms, `sorry`, or `native_decide` in source. Static source inspection
does not replace compiler and kernel verification.
