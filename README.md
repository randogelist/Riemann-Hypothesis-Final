# Riemann-Hypothesis-Final

Lean 4.33 research toward a finite-witness reduction of the **actual Mathlib
Riemann hypothesis**, using SOLOBOLO, shared-spectrum Cayley–Sturm induction,
and work to derive the induction input from finite data.

**Status: `v0_1_0_construction`; native compilation and axiom audits `NOT_RUN`.**
The full build now includes source-complete analytic equivalences with native
RH: an actual theta ODE on the slit plane and an analytic reciprocal of the
actual regularized Cayley zeta function. See
[recovered equivalences](docs/RECOVERED_EQUIVALENCES.md).

The next construction is organized around **one explicit actual-calibration
condition**, `ActualUniformResidualCondition G`, stated in
[ACTUAL_CONDITION.md](docs/ACTUAL_CONDITION.md). It requires the actual theta
residual of one fixed finite program to tend locally uniformly to zero. It is an infinite analytic condition,
not a finite witness or a checker result. A concrete finite reduction still
needs independently proved checker soundness and RH-to-code completeness.
No accepted actual-RH witness or proof of RH is claimed.

The intended finite-input route is: finite program and checked estimates →
locally uniform vanishing of the actual theta residual → zero exclusion →
native RH.
The recovered analytic endpoint is implemented in source; deriving its input
from a concrete finite check remains open. The shared-spectrum induction
and GP constructions supply useful algebra and candidate representations,
with their actual-function bindings kept explicit.

## Hilbert-vector anchor paper

[Read the revised paper (PDF)](RH_Hilbert_Vector_Anchor_v1_2_construction.pdf) · [Editable LaTeX source](docs/papers/RH_Hilbert_Vector_Anchor_v1_2_construction.tex)

**Hilbert-Vector Resolvents and the Riemann Hypothesis: A detailed analytic seed criterion** (version 1.2, 27 October 2026, 41 pages).

The paper derives the fixed positive-operator norm and Gram identities, the exact analytic seed equivalence with actual RH, the converse zero-product construction, and the all-order moment criterion. Hyperbolic Zeta identities supply both positive comparison models and the exact actual ξ coefficients.

**New in version 1.2:** Sections 11–13 construct canonical Jensen polynomials directly from the actual coefficients and prove their entire convergence with an explicit error bound. Their hyperbolicity at unbounded degrees is equivalent to RH; a finite Hermite-matrix criterion expresses the same condition in the coefficients. The paper derives the exact next-degree critical-value interval, canonical Bernstein grid seeds with a resolvent error bound, and the Schur intervals for extending actual moments. Appendix C classifies the possible limits of the original squared pencils and excludes a flat normalized spectrum.

**The remaining assertion is all-order actual positivity.** The canonical polynomial convergence is proved on paper, but hyperbolicity at unbounded degrees and positivity of all Bernstein levels remain open. The separate coefficient limits and completeness of the original Hyperbolic Zeta pencil family also remain open. The quoted low-degree Jensen base is a published literature result, not a new native verification.

This is **B-Tier derivation**: no unconditional calibrated seed, accepted finite RH witness, or proof of RH is claimed. Native Lean compilation and axiom audits remain `NOT_RUN`.

[Previous version 1.1 (PDF)](RH_Hilbert_Vector_Anchor_v1_1_construction.pdf) · [Version 1.0 (PDF)](RH_Hilbert_Vector_Anchor_v1_0_construction.pdf)

## Contents

| Location | Purpose |
|---|---|
| `RHFinal/Core/` | Raw finite SOS certificates, exact local checks, induction transfer |
| `RHFinal/Search.lean` | Terminating bounded local search; no RH admission |
| `FiniteWitness/` | Ten unchanged SOLOBOLO finite-spectrum and trace modules |
| `RHFinal/Actual/` | Actual ξ/native RH definitions, differential successor and explicit calibration frontier |
| `RHFinal/GP/` | Literal Mellin–Hilbert objects, native ξ binding, KQ/GP/BKQR endpoints, GP7 and generic master extraction |
| `docs/GP_CONSTRUCTION.md` | GP layers, exact normalizations, source scope and remaining finite-input obligations |
| [`RH-Equivalences/`](RH-Equivalences/README.md) | 41 native-target and 10 model formulations, split by literature provenance and provisional novelty; exact sources and newer local criteria |
| [`docs/ACTUAL_CONDITION.md`](docs/ACTUAL_CONDITION.md) | Exact remaining calibration condition and separate finite-checker obligations |
| [`docs/RECOVERED_EQUIVALENCES.md`](docs/RECOVERED_EQUIVALENCES.md) | Two actual analytic RH iff endpoints, exact imports and native audit status |
| `AWPIRH/`, `AngularMaster/`, `SoloboloAdmission/` | Recovered actual theta/slit-ODE proof chain |
| `FiveInduction/`, `SoloAdmission/` | Recovered actual-J analytic reciprocal proof chain |
| `docs/FRONTIER.md` | Ordered analytic and finite-reduction work plan |
| `docs/SOURCE_AUDIT.md`, `docs/SOLOBOLO_AUDIT.md` | Source scope and unresolved assumptions |
| `provenance/` | SHA-256 input inventory and unchanged-import manifests |
| `research/upstream/` | Preserved historical sources, outside the default build |

## Native Windows workflow

Use the installed native Windows Lean 4.33.0. The runner makes no downloads
and does not invoke Python, PowerShell, WSL or Lake setup.

```cmd
run.cmd core
```

To include the Mathlib-dependent SOLOBOLO sources, integrated GP construction,
recovered analytic RH equivalences and actual-data interfaces:

```cmd
set "RH_MATHLIB_ROOT=C:\path\to\cached\mathlib"
run.cmd full
```

The runner hashes inputs, compiles changed/invalidated modules, checks printed
axiom dependencies, and writes native pass receipts. Cached project objects
are reused only when their provenance matches. See [build details](docs/BUILD.md).
No imported historical object is admitted as a verified `LEAN_ANCHORINGS`
checkpoint. The first native run is required.

Run the bounded local search after compiling/auditing its imports:

```cmd
run.cmd search
```

Follow [core details](docs/CORE.md) for its limited template and exact scope.
An accepted local diagnostic is never labelled an RH witness.

## GP integration

The recovered KQ/GP/BKQR construction is included with actual ξ calculus and
Widder/Cayley interfaces, together with the literal Mellin–Hilbert definitions,
the separate GP7 weight-seven module family, and the generic master energy
induction. [GP construction details](docs/GP_CONSTRUCTION.md) distinguish these
normalizations and their remaining hypotheses. No imported model or finite
local diagnostic is claimed to be an actual-ξ witness. This integration is
tracked by Git revision; `v0_1_0_construction` remains unchanged.

## Proof discipline

Witnesses contain finite raw data. Global analytic hypotheses remain named,
visible open propositions outside the witnesses. Each theorem's scope and its
compilation/axiom status are tracked separately. In particular, a derived
algebraic successor does not establish positivity or the induction BASE.

The workflow definition is [YOU_ARE_GOODWORKFLOWFRONTIER
v1_0_15](docs/YOU_ARE_GOODWORKFLOWFRONTIER_v1_0_15.txt). Construction follows
`A_TIER_PLANNING` and `A_TIER_EXECUTION`, with proof tiers awarded only after
their stated gates. The exact final goal includes both checker soundness and
RH-to-witness completeness. A single named analytic condition does not combine
those two open theorems into an established finite equivalence.

Source imports retain provenance. No license grant has been added.

The user-created public repository is
[`randogelist/Riemann-Hypothesis-Final`](https://github.com/randogelist/Riemann-Hypothesis-Final).
These research sources include the GP construction and recovered analytic
equivalence chains. See
[clone and update instructions](docs/PUBLISH.md); repository publication does
not certify a native Lean build.

