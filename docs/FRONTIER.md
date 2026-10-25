# SOLOBOLO finite-witness frontier

The final research target is a finite raw-data type, one concrete terminating checker, and independently proved soundness and completeness:

```lean
(∃ W : FiniteWitness, check W = true) ↔ _root_.RiemannHypothesis
```

This finite-checker iff is **open**. The repository is `v0_1_0_construction`; native compilation and kernel axiom audits remain `NOT_RUN`. No accepted actual-RH witness or proof tier is assigned.

The recovered **analytic** endpoint is more complete: [slit-plane ODE admission](../SoloboloAdmission/NativeODE.lean) and [actual-J analytic reciprocal admission](../SoloAdmission/AnalyticInverse.lean) each have a source proof of equivalence with literal native RH. Their full project import chains are included in the full build. [RECOVERED_EQUIVALENCES.md](RECOVERED_EQUIVALENCES.md) records their exact statements and verification boundary.

## One explicit analytic condition, separate finite obligations

[ACTUAL_CONDITION.md](ACTUAL_CONDITION.md) states the single actual-calibration condition chosen for the next implementation step. Its purpose is to derive actual slit-plane zero exclusion from a fixed finite rational program and universal analytic estimates. Calling this one condition does not make its all-domain content a finite Boolean check.

Three distinct claims must stay visible:

1. **Analytic transfer:** the stated residual condition excludes actual theta zeros on the slit plane and gives native RH. The generic residual proof derives this without assuming a limiting coefficient; the recovered zero-geometry endpoint completes the source argument.
2. **Checker soundness:** a concrete terminating checker on finite raw data derives that condition. Universal convergence and actual-function equality cannot be appended to the certificate as unverified proof fields.
3. **Finite completeness:** RH produces an accepted code for the same checker. An arbitrary analytic function or countable spectrum supplied under RH does not yet have a finite representation in the chosen language.

An accepted code would prove RH only after soundness is established. Completeness is additionally required for the iff. No conjunction of these unfinished tasks is presented as a derived “single condition.”

## Two routes for constructing the analytic input

The direct residual route fixes a rational program and requires only that `Theta′ + A_n*Theta` tend locally uniformly to zero on the slit plane. Coefficient-limit existence and holomorphy are not assumed. Stagewise coefficient analyticity is derived from the emitted packets; the new generic source proof excludes finite-order zeros by convergence of residual derivatives. A finite prefix or pointwise numerical agreement cannot prove that global result. The exact condition is `SoloboloAdmission.ActualUniformResidualCondition G`, documented in [ACTUAL_CONDITION.md](ACTUAL_CONDITION.md).

The positive-spectrum route targets an actual resolvent identity

\[
\frac{\Theta'(u)}{\Theta(u)}
 = \sum_n\frac{\lambda_n}{1+u\lambda_n},\qquad
u>0,\quad\lambda_n\ge0,\quad\sum_n\lambda_n<\infty.
\]

The recovered product sources already provide actual multiplicity-bearing zero occurrences, inverse-square summability and normalized theta factorization. Later `OriginTrace` source proves Θ(0)≠0 and removes the origin monomial. Under RH the complex zero scales become positive real scales αᵢ. The proposed spectrum is λᵢ=1/αᵢ, with countable zero-padding to a Nat sequence; no simple-zero or infinitude assumption is needed for a nonnegative diagonal.

The [detailed product assessment](research/2026-10-25/rh-positive-product-assessment.md) identifies the remaining assembly: recenter the known affine product at each u>0, reuse its zero-centered logarithmic-derivative theorem, identify complex theta with the literal real-sqrt carrier and transport the sums to the Nat diagonal. The product support is retained as research evidence/strategy in this publication, not added wholesale to the active build. The positive-ray trace calibration adapter is not yet a completed Lean theorem. Even its completion would give RH→positive **infinite** actual realization, not RH→accepted finite code.

## Derived induction and the central coefficient bridge

For the direct jet, let R=Θ′/Θ and

\[
d_n(a)=\frac{(-1)^n a^{n+1}}{n!}R^{(n)}(a).
\]

Product differentiation yields `d_(n+1)=d_n−a*d_n′/(n+1)` under the stated regularity assumptions. [RHFinal.Actual.Successor](../RHFinal/Actual/Successor.lean) exposes that calculation. The recovered [direct/recursive Widder identification](../Bridge/XiWidderIdentification.lean) and [finite Cayley coefficient formula](../AllDepth/ActualXiRealRodriguesNormalization.lean) supply further all-depth identities on their stated actual regular domains. They do not establish positivity or the induction base merely by sharing a recurrence.

For the exact base-function induction route, finite data must derive equality of actual and model **base functions on an open domain**. Equality at a point, a finite Taylor jet or sampled anchors is insufficient for all-order equality induction. Approximate transfer additionally needs an error estimate preserved by differentiation; uniform value error alone provides no such bound.

The deeper central-coefficient strategy concerns a different object. For the normalized symmetric product Pₐ(r) with paired roots of sum `2a(1−2r)` and product `a²`, put hₐ=−Pₐ′/Pₐ. Its proposed coefficient identity is

\[
\frac{h_a^{(n)}(0)}{n!}
 =\frac{(-1)^n(4a)^{n+1}}{(2n+1)!}
   \left.\frac{d^{2n+1}}{dz^{2n+1}}
     \bigl(z^{n+1}R(z)\bigr)\right|_{z=a}.
\]

The finite Cayley/binomial coefficient algebra is already implemented in source. The [written derivation](research/2026-10-25/coefficient-bridge-strategy.md) uses `r=t²/(1+t²)` and rational Cayley roots to avoid differentiating square-root branches. Finite Taylor factorization, the divided-power identity and an order-two analytic composition then give equality of the required coefficient. Exact arithmetic checks support its signs and constants; **the generic analytic coefficient passage and final actual Lean identity remain open**.

This central product-log coefficient has derivative order 2n+1 and its displayed factorial normalization. The separate [anchor-1 direct-jet Bernstein-row strategy](research/2026-10-25/endpoint-strategy.md) uses derivatives of `g(u)=uΘ′/Θ` of order n+1. The two are not interchangeable. Proving the direct-row generating identity would not by itself prove the central product coefficient identity or its energy estimate.

Likewise the remembered central BASE `4D² log Θ`, with D=a∂ₐ, differs from the direct BASE `aΘ′/Θ`. Equality of the central bases needs a normalization value to recover equality of the direct bases. A common name, recurrence, or finite coefficient example does not discharge this normalization step.

## What the active sources contribute

| Area | Source contribution | Remaining scope |
|---|---|---|
| `RHFinal/Core/` and `RHFinal/Search.lean` | Exact finite SOS checks, generic induction equality, terminating bounded local search | Search is a local algebraic diagnostic, not actual-RH admission |
| `FiniteWitness/` | Rational syntax, checked finite spectral layers and shared-spectrum contraction | Model positivity does not imply actual calibration |
| `RHFinal/Actual/` | Literal native target, derived successor and named actual-input contracts | Concrete finite-checker reduction remains open |
| `AWPIRH/`, `AngularMaster/`, `SoloboloAdmission/` | Actual entire theta, native zero geometry and analytic slit-ODE iff | Must construct the admission and run native audits |
| `FiveInduction/`, `SoloAdmission/` | Regularized actual J and analytic reciprocal iff | No reciprocal constructed without RH; no finite code extracted |
| `RHFinal/GP/` and recovered KQ sources | Literal Mellin–Hilbert objects, actual ξ calculus, finite Cayley identities, GP7 and generic master induction | Integral/operator laws, actual calibration and analytic transfers retain their explicit obligations |

[GP_CONSTRUCTION.md](GP_CONSTRUCTION.md) and [GP_MATH_REVIEW.md](GP_MATH_REVIEW.md) distinguish the continuous Mellin measure, finite rational GP models, GP7 weight-seven normalization and central/direct moment towers. The historical opaque-RH/literature-axiom master source stays archival.

## Execution subchapters

| ID | Required result | Current source boundary / exit evidence |
|---|---|---|
| S01 | Actual theta regularity and native zero correspondence | Recovered complete source chain; native build and axiom audit pending |
| S02 | Actual/model derivative successors | Source calculations available with explicit regularity; transport exact carriers/domains |
| A01 | Fixed-program actual analytic calibration | Prove the exact condition in [ACTUAL_CONDITION.md](ACTUAL_CONDITION.md) |
| B01 | Finite certificates imply A01 | Concrete executable checker and independently proved soundness |
| G01 | Literal GP integral, moment and completion-gauge laws | Integrability, differentiation, nonvanishing and removable-value proofs |
| G02 | Actual Hilbert/operator realization | L² membership, operator domains and calibration to the same xi |
| G03 | Actual central product-log coefficient identity | Implement the local rational-parameter finite-jet derivation and normalization transport |
| P01 | RH gives calibrated positive summable actual spectrum | Assemble the recovered product, recentering, real-carrier and Nat-index adapters |
| T01 | Functional BASE gives all actual moments their positive representation | Induction with domain closure and every regularity premise discharged |
| R01 | Actual analytic admission gives native RH | Slit-ODE source endpoint available; alternative pole/Hurwitz routes retain their own inputs |
| C01 | RH gives accepted finite code for the same checker | Finite-language completeness, not just an analytic existence theorem |
| W01 | Concrete finite admission | Kernel-verified `check W=true` and all transfer theorems |

## Rejected shortcuts

An always-accepting positivity checker, a finite-spectrum model, a zero-spectrum sample or a certificate carrying an unverified all-order calibration theorem does not establish the requested finite equivalence. Neither a same-radius coefficient induction nor finitely many positive moments proves radius exhaustion. Do not identify the proxy channel `1+4δ²` with a GP/Mellin channel without its analytic identification.

The executable, source and verification layers are tracked separately. `run.cmd full` is the intended native verification entry point; it has not been run for this integration. Source publication does not establish a successful Lean build, actual calibration, an accepted witness, RH or RH→GRH.
