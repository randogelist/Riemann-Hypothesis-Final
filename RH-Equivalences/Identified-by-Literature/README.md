# Identified by Literature

**23 catalogue formulations: 18 native-target entries and 5 opaque-model entries.** Reviewed 25 October 2026.

[Collection overview](../README.md) · [Full catalogue](../CATALOG.md) · [Literature and review policy](../LITERATURE.md) · [Machine-readable classification](../literature-classification.json)

This group includes direct literature criteria and standard reformulations whose classical basis is identified below. **An identified basis is not necessarily an exact published formula:** coordinate changes, scalar encodings and project terminology are labelled as such. The mathematical reductions are this review’s assessment.

The opaque-model rows identify intended literature families. Their unimplemented analytic objects and assumed bridge axioms are not validated by finding the cited paper.

Literature provenance is separate from proof status. All catalogue entries retain their original hypotheses and source links; new native Lean compilation and kernel axiom audit remain **NOT_RUN**. Neither group establishes RH or a complete finite witness.

## Native-target formulations

| ID and full statement | Relationship | Basis and primary references |
|---|---|---|
| [E01](../CATALOG.md#e01) — Completed xi zeros lie on the critical line | classical completed xi zero formulation | The completed-xi zero formulation of classical RH, with modern notation. [RIEMANN1859](../LITERATURE.md#riemann1859) |
| [E02](../CATALOG.md#e02) — Critical-line pullback has only real zeros | direct classical centered zero formulation | Riemann uses s=1/2+it and the real-zero formulation of the centered xi function. [RIEMANN1859](../LITERATURE.md#riemann1859) |
| [E03](../CATALOG.md#e03) — Theta zeros lie on the nonpositive real axis | elementary coordinate reformulation | Squaring s−1/2 maps critical-line zeros to the nonpositive real axis; evenness makes the square descent well-defined. [RIEMANN1859](../LITERATURE.md#riemann1859) |
| [E04](../CATALOG.md#e04) — Right-half-plane nonvanishing of the literal entire xi | functional equation reformulation | Reflection s↦1−s turns exclusion of all xi zeros in Re(s)>1/2 into the critical-line assertion. [RIEMANN1859](../LITERATURE.md#riemann1859) |
| [E05](../CATALOG.md#e05) — Strict Lagarias logarithmic-derivative positivity | direct published logarithmic derivative criterion | Lagarias §1 equation (1.5) states this strict positivity equivalence; the conventional quotient requires nonvanishing. [LAGARIAS1999](../LITERATURE.md#lagarias1999) [LAGARIAS_PUBLICATIONS](../LITERATURE.md#lagarias_publications) |
| [E06](../CATALOG.md#e06) — Strict anti-Herglotz sign of the xi pullback | coordinate and reflection reformulation of E05 | Set s=1/2+iz and use ξ(s)=ξ(1−s); the chain rule converts E05 to the negative imaginary-part sign. [LAGARIAS1999](../LITERATURE.md#lagarias1999) [RIEMANN1859](../LITERATURE.md#riemann1859) |
| [E07](../CATALOG.md#e07) — Analytic extension of the actual logarithmic-derivative germ | standard holomorphic reformulation of E04 | A holomorphic extension of the logarithmic-derivative germ cannot retain a pole at a xi zero. The converse uses ξ′/ξ itself. The input requires equality of analytic germs and a coefficient analytic on the connected half-plane; a finite value or finite Taylor jet does not supply it. [LAGARIAS1999](../LITERATURE.md#lagarias1999) [RIEMANN1859](../LITERATURE.md#riemann1859) |
| [E08](../CATALOG.md#e08) — Analytic first-order ODE coefficient matching the xi germ | standard ODE reformulation of E04 | The identity theorem extends ξ′=pξ from the germ; a finite-order zero contradicts that equation by comparing vanishing orders. The input requires equality of analytic germs and a coefficient analytic on the connected half-plane; a finite value or finite Taylor jet does not supply it. [LAGARIAS1999](../LITERATURE.md#lagarias1999) [RIEMANN1859](../LITERATURE.md#riemann1859) |
| [E09](../CATALOG.md#e09) — Zero Cayley loss at every nontrivial zeta zero | elementary scalar reformulation | For positive g=2^(2σ−1), ((g−1)/(g+1))²=0 exactly when σ=1/2. [RIEMANN1859](../LITERATURE.md#riemann1859) |
| [E10](../CATALOG.md#e10) — Cayley transmission saturates at every nontrivial zero | elementary scalar reformulation of E09 | Since c=1−q², transmission saturation c=1 is exactly zero loss q²=0. [RIEMANN1859](../LITERATURE.md#riemann1859) |
| [E11](../CATALOG.md#e11) — Unit-state Cayley energy is preserved at every nontrivial zero | elementary energy reformulation of E10 | For g>0 the transmission c is positive, and the unit-state squared energy after the sqrt(c) step equals c. [RIEMANN1859](../LITERATURE.md#riemann1859) |
| [E20](../CATALOG.md#e20) — Zero exclusion in every positive-slope wedge | elementary wedge exhaustion reformulation | Every off-line zero lies in a wedge with slope m>\|Imρ\|/\|Reρ−1/2\|; all slopes exhaust the off-line strip. [RIEMANN1859](../LITERATURE.md#riemann1859) |
| [E21](../CATALOG.md#e21) — Zero exclusion for a cofinal collection of slopes | elementary cofinal exhaustion reformulation | An unbounded set of slopes already supplies a wedge containing each fixed off-line zero. [RIEMANN1859](../LITERATURE.md#riemann1859) |
| [E31](../CATALOG.md#e31) — Canonical exact two-sided passivity | elementary positive factor reformulation | Cancel the strictly positive canonical energies in D±=(g±−1)E±; reciprocal gain bounds force Reρ=1/2. Strict positivity/nonvanishing of the energy or square factor must remain justified; nonnegativity alone does not permit cancellation. [RIEMANN1859](../LITERATURE.md#riemann1859) |
| [E32](../CATALOG.md#e32) — Literal reciprocal dyadic contraction | elementary exponential reformulation | For real c, both 2^(2c)≤1 and 2^(−2c)≤1 hold exactly when c=0. [RIEMANN1859](../LITERATURE.md#riemann1859) |
| [E33](../CATALOG.md#e33) — One-sided dyadic contraction, with reflection | elementary one sided reflection reformulation | One-sided dyadic contraction means Reρ≤1/2; applying it to 1−ρ gives the reverse inequality. [RIEMANN1859](../LITERATURE.md#riemann1859) |
| [E34](../CATALOG.md#e34) — Canonical exact one-sided passivity | elementary positive factor reformulation of E33 | Cancel the strictly positive canonical jet square, then use E33 and the functional equation. Strict positivity/nonvanishing of the energy or square factor must remain justified; nonnegativity alone does not permit cancellation. [RIEMANN1859](../LITERATURE.md#riemann1859) |
| [E35](../CATALOG.md#e35) — Pointwise GP/BKQR one-sided passivity | elementary existential scalar reformulation of E33 | Existence of c>0 with (g−1)c²≤0 is equivalent to g≤1; the reverse implication takes c=1. The existential scalar formulation does not itself construct a GP/BKQR Hilbert operator or intertwining map. [RIEMANN1859](../LITERATURE.md#riemann1859) |

## Opaque-model formulations

These target the project’s opaque RH proposition and retain literature/model axioms. They are outside the native Mathlib RH count.

| ID and full statement | Relationship | Basis and primary references |
|---|---|---|
| [M01](../CATALOG.md#m01) — Zhang-normalized Hausdorff finite-difference positivity | Identifiable Zhang/Hausdorff criterion family; exact formal match unverified. | Zhang’s Corollary 6 gives actual Xi-derived real moments and finite-difference RH conditions. Here the coefficient sequence has integer type and opaque origins, and RH is an opaque Prop; ZHANG2023_FRONTIER_ANCHOR supplies the iff as an axiom. Literature attribution is provenance, not verification of this normalization or native RH. [ZHANG2023](../LITERATURE.md#zhang2023) |
| [M02](../CATALOG.md#m02) — Zhang complete-monotonicity hierarchy | Identifiable Zhang complete-monotonicity hierarchy; comment-level match only. | Zhang’s Corollary 4 matches the stated intended hierarchy. The local criterion itself is opaque, with no encoded G_k^(m) or complete-monotonicity definition, and the iff comes from ZHANG2022_FRONTIER_ANCHOR. Classify as literature-inspired model provenance, not a new theorem or verified native match. [ZHANG2022](../LITERATURE.md#zhang2022) |
| [M03](../CATALOG.md#m03) — Wall continued-fraction admissibility | Classical Wall–Sokal Hausdorff continued-fraction mechanism; opaque application. | Sokal gives the explicit g_i∈[0,1] continued-fraction characterization. Local WallAdmissible is opaque and the Hausdorff-to-Wall bridge is axiomatized, in addition to the Zhang RH anchor. The canonical coefficients and exact admissibility definition are not verified against the paper. [SOKAL2020](../LITERATURE.md#sokal2020) [ZHANG2023](../LITERATURE.md#zhang2023) |
| [M04](../CATALOG.md#m04) — Subnormality of the canonical weighted shift | Classical Berger/Gellar–Wallen moment/subnormality mechanism; exact shift unspecified. | A properly normalized contractive weighted shift has a Hausdorff moment description. The project supplies no concrete shift or subnormality definition, and assumes its Hausdorff bridge as an axiom. Weight positivity, normalization and support/boundedness must be matched before asserting exact literature correspondence. [GELLAR_WALLEN1970](../LITERATURE.md#gellar_wallen1970) [ZHANG2023](../LITERATURE.md#zhang2023) |
| [M05](../CATALOG.md#m05) — Complete hypercontractivity of the canonical shift | Classical Agler complete-hypercontractivity mechanism; convention and model match unresolved. | The local bridge is an axiom between opaque propositions. Agler’s `T*^k T^k` convention concerns subnormal contractions of the same T; formulations using `T^k T*^k` concern the adjoint. Since the project defines neither, an exact operator-orientation claim is unsupported. Mark as literature-inspired provenance, not validated equivalence and not a definitive adjoint error. [AGLER1985](../LITERATURE.md#agler1985) |

## Additional selected criteria

These L-identifiers refer to the twelve numbered summaries in [LOCAL_CRITERIA.md](../LOCAL_CRITERIA.md). They are not added to the 51-entry count and include aliases, conditional implications and custom predicates.

| Local item | Assessment |
|---|---|
| L01 — item 1: Native zero rigidity | Direct normalization of classical RH using actual nontrivial zeta zeros. [RIEMANN1859](../LITERATURE.md#riemann1859) |
| L02 — item 2: SOLOBOLO shifted-axis geometry | An algebraic coordinate change: s(s−1) lies on the stated real ray exactly for a critical-line zero. The SOLOBOLO name is project-specific. [RIEMANN1859](../LITERATURE.md#riemann1859) |
| L03 — item 3: Actual regularized Cayley function nonvanishing | Disk coordinates and nonvanishing factors re-express right-half-plane zero exclusion. This identifies the classical mechanism, not an exact published theorem using this J. [RIEMANN1859](../LITERATURE.md#riemann1859) |
| L04 — item 4: Scalar and positive-metric passivity | The gain 1+4(Re(s)−1/2)²≤1 is elementary zero rigidity; the admitted metric variants encode it. No actual GP/Mellin operator identification follows. [RIEMANN1859](../LITERATURE.md#riemann1859) |
| L05 — item 5: One fixed seed and all depths | The scalar proxy criterion is classical zero rigidity with a seed test and ordinary induction. The globally admitted metric remains the substantive input. [RIEMANN1859](../LITERATURE.md#riemann1859) |

## Recovered analytic supplement

[A01 and A02](../RECOVERED_ANALYTIC.md) are standard analytic reciprocal and
linear-ODE reformulations. They are indexed separately from this historical
23-entry partition. Exact published wording was not located; no novelty claim
or new native verification is implied.
