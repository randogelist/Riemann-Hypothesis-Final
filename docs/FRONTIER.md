# SOLOBOLO finite-witness frontier

Target: a finite raw-data type `FiniteWitness`, one terminating concrete
`check`, and independently proved theorems yielding

```lean
(∃ W : FiniteWitness, check W = true) ↔ _root_.RiemannHypothesis
```

This is the research objective, not an established theorem in this repository.
The current package is `v0_1_0_construction`. No new Lean compilation has been
run, no complete RH witness exists here, and no proof tier is assigned.

## Route and order of work

1. **Literal source.** Use `WitnessSolobolo.actualXi` and `actualTheta`, formed
   from Mathlib's `completedRiemannZeta₀`. Prove regularity, square-descent and
   real/complex compatibility in the required domains. Totalized division and
   `Complex.sqrt` definitions are not proofs of these facts.
2. **Derived successor.** For `R = Θ′/Θ`, use
   `dₙ(a) = (-1)ⁿ aⁿ⁺¹ R⁽ⁿ⁾(a)/n!`. Product differentiation gives
   `dₙ₊₁ = dₙ - a dₙ′/(n+1)` under the stated differentiability hypotheses.
   Derive the GP successor from a fixed GP realization, with differentiation
   under its integral justified. The operator alone does not preserve positivity.
3. **Finite induction input.** Produce a finite rational program/certificate
   whose acceptance proves equality of the actual and GP base FUNCTIONS on
   an open domain. An equality of values, finite jets or sampled points is
   insufficient. The two sequences must use the same successor on that domain.
4. **All-order transfer.** Functional base equality and the common derived
   successor yield equality at every order. Then use the fixed positive GP
   realization for positivity and shared-spectrum Cayley contraction.
5. **Actual RH endpoint.** Prove either the actual Widder off-line-pole
   explosion/divisor theorem and contradiction with uniform bounds, or the
   actual complex-jet/Hurwitz route. Import its complete native Mathlib bridge.
6. **Completeness.** For the iff target, additionally derive an accepted code
   from RH. Soundness alone gives only the forward implication.

## What the current code contributes

- `FiniteWitness/`: ten unchanged SOLOBOLO modules, including raw rational
  syntax, checked finite spectral layers, shared-spectrum contraction for all
  power orders, and an all-layer telescoping model. These are source imports,
  with native compilation pending. The telescope is a model, not actual ξ.
- `RHFinal/Core/`: exact finite symbolic SOS checks and generic induction
  equality. `RHFinal/Search.lean` performs bounded local candidate search.
- `RHFinal/Actual/`: literal native RH target, source-derived differential
  successor with explicit regularity premises, and named open analytic inputs.

Local SOS acceptance is useful algebraic evidence. It does not certify the
unbounded actual ξ residual or discharge any open analytic input below.

## Execution subchapters

| ID | Required result | Exit evidence |
|---|---|---|
| S01 | Actual Θ regularity/nonvanishing on the chosen anchor domain | Native Lean proof and exact axiom audit |
| S02 | Actual and GP derivative successors from their literal definitions | Both proof chains; no successor assumed as a certificate field |
| B01 | Finite certificates imply a universal actual residual estimate | A concrete executable checker and proved actual-data soundness |
| B02 | Residual contraction/limit implies functional BASE | Uniform/cofinal limit, normalization and uniqueness proofs |
| T01 | BASE gives every actual moment the positive GP representation | Induction, domain closure and all regularity premises discharged |
| R01 | Actual moment control implies native Mathlib RH | Actual divisor/pole or Hurwitz proof, with no proxy channel substitution |
| C01 | RH implies an accepted finite certificate | Completeness for the same checker |
| W01 | Concrete finite admission | Kernel-verified `check W = true` plus all preceding transfer theorems |

The proposed STURMION residual approach is a candidate for B01/B02: finite
rational GP resolvents and a symbolic all-level contraction certificate may
yield a positive limiting representation. Existence, actual-ξ binding, and the
contraction theorem are research obligations. The repository does not assume
them. A finite prefix cannot stand in for them.

The remembered identity involving `4D² log Θ` is a central-moment BASE; the
direct-jet recurrence begins with `a Θ′/Θ`. These are distinct normalizations.
Their relation and any change of moment tower must be proved explicitly before
connecting the remembered central BASE to the direct-jet successor.

## Rejected shortcuts

Do not use an always-accepting positivity checker, a checker calling RH,
a zero-spectrum sample, or `∃ W, check W ∧ ∀ n, calibration W n` as the requested
finite-checker equivalence. Do not derive radius exhaustion from a same-radius
coefficient induction. Do not identify the proxy channel `1 + 4δ²` with a
GP/Mellin channel without proving the analytic identification.
