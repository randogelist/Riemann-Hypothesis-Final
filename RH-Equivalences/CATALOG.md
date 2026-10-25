# Project RH equivalence catalogue

This folder makes the established project catalogue navigable: **41 source-reported native-target formulations in 22 criterion groups**, followed separately by **10 opaque-model formulations**. These are formulations, not 51 independent mathematical mechanisms. The original E01–E41, M01–M10 and D001–D115 identifiers are retained.

**Status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.** No Lean compilation or kernel axiom audit was run for this catalogue import. A declaration signature, preserved proof source, or historical audit note is not a fresh native Lean 4.33 receipt. No RH proof or complete accepted finite RH witness is claimed.

The [original catalogue](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt) is preserved byte-for-byte; its SHA-256 is `8316d28735a23aff004c1c9e2d30c7f601fecf379fe4990f5ded8dd0a0b527b6`. [catalog.json](catalog.json) contains exact criteria, hypotheses, declaration signatures, source paths/hashes, aliases, original evidence and all 115 definition excerpts.

The historical breakdown is **35 declarations reported without extra theorem hypotheses, 2 with positive parameter conditions, and 4 with analytic/model interfaces**. “No extra theorem hypotheses” describes the reported signature; it does not certify its transitive dependencies. All source paths and Lean-file hashes below are transcribed from the original catalogue. They refer to distinct snapshots of the original review bundle, not a combined import graph.

The exact review bundle has now been recovered. [source-map.json](source-map.json) maps all 97 referenced source paths, including aliases, definitions and related material, to preserved archival Lean bodies. The SHA-256 hashes of all 51 primary entry files match their catalogue hashes. Each entry links its recovered source; this byte-level check does not establish a compiled dependency closure.

## Reading the catalogue

- Browse the provenance split in [Identified by Literature](Identified-by-Literature/README.md) and [Potentially novel](Potentially-novel/README.md). These are literature assessments, separate from the verification status below; the original criteria and identifiers are unchanged.
- Native-target entries are E01–E41. The criterion and its extra hypotheses must be read together; an equivalence does not prove its criterion.
- M01–M10 target an opaque project RH proposition and retain literature axioms. They are kept outside the native-target count.
- Aliases and algebraic reformulations stay in their original groups. Same-named declarations across snapshots are not silently identified.
- Infinite functional data, all-order bounds and existential model structures do not become finite raw certificates because an entry uses “finite”, “constructor” or “witness”.

## Native criterion groups

| Group | Entries |
|---|---|
| Actual zero geometry | [E01](#e01), [E02](#e02), [E03](#e03), [E04](#e04) |
| Logarithmic-derivative signs | [E05](#e05), [E06](#e06) |
| Analytic continuation and the ODE germ | [E07](#e07), [E08](#e08) |
| Cayley loss, transmission and energy | [E09](#e09), [E10](#e10), [E11](#e11) |
| Angular derivative and regular logarithmic slope | [E12](#e12), [E13](#e13), [E14](#e14) |
| Angular endpoint minimum | [E15](#e15) |
| Regularized logarithmic flux | [E16](#e16), [E17](#e17) |
| Residual angular regions | [E18](#e18), [E19](#e19) |
| Wedge exhaustion | [E20](#e20), [E21](#e21) |
| Slope-dependent angular certificates | [E22](#e22) |
| Actual RR defect | [E23](#e23), [E24](#e24) |
| RR central-curvature identification | [E25](#e25), [E26](#e26) |
| Angular small-o asymptotic | [E27](#e27) |
| Relative derivative bound | [E28](#e28) |
| Finite-rate angular propagation | [E29](#e29) |
| Local first-order increments | [E30](#e30) |
| Dyadic contraction and passivity | [E31](#e31), [E32](#e32), [E33](#e33), [E34](#e34), [E35](#e35) |
| Exact defect controlled by KQ tails | [E36](#e36), [E37](#e37) |
| Finite-energy factorization | [E38](#e38) |
| Telescoping negative-square sources | [E39](#e39) |
| Calibrated two-sided constructor | [E40](#e40) |
| Cofinal uniform Widder positivity | [E41](#e41) |

## Native-target index

| ID | Criterion | Source-reported extra hypotheses |
|---|---|---|
| [E01](#e01) | Completed xi zeros lie on the critical line | No extra signature hypotheses |
| [E02](#e02) | Critical-line pullback has only real zeros | No extra signature hypotheses |
| [E03](#e03) | Theta zeros lie on the nonpositive real axis | No extra signature hypotheses |
| [E04](#e04) | Right-half-plane nonvanishing of the literal entire xi | No extra signature hypotheses |
| [E05](#e05) | Strict Lagarias logarithmic-derivative positivity | No extra signature hypotheses |
| [E06](#e06) | Strict anti-Herglotz sign of the xi pullback | No extra signature hypotheses |
| [E07](#e07) | Analytic extension of the actual logarithmic-derivative germ | No extra signature hypotheses |
| [E08](#e08) | Analytic first-order ODE coefficient matching the xi germ | No extra signature hypotheses |
| [E09](#e09) | Zero Cayley loss at every nontrivial zeta zero | No extra signature hypotheses |
| [E10](#e10) | Cayley transmission saturates at every nontrivial zero | No extra signature hypotheses |
| [E11](#e11) | Unit-state Cayley energy is preserved at every nontrivial zero | No extra signature hypotheses |
| [E12](#e12) | Nonnegative within-derivative on the closed angular interval | No extra signature hypotheses |
| [E13](#e13) | Nonnegative ordinary angular slope on every open semicircle | No extra signature hypotheses |
| [E14](#e14) | Nonnegative Euler logarithmic slope on the regular locus | No extra signature hypotheses |
| [E15](#e15) | Left endpoint minimizes the angular derivative and has nonnegative derivative | No extra signature hypotheses |
| [E16](#e16) | Positive-normalizer logarithmic flux master | Positive parameters |
| [E17](#e17) | Logarithmic flux master with the actual theta normalizer | Positive parameters |
| [E18](#e18) | Slope positivity on the remaining rectangular angular region | No extra signature hypotheses |
| [E19](#e19) | Slope positivity on the smaller curved residual region | No extra signature hypotheses |
| [E20](#e20) | Zero exclusion in every positive-slope wedge | No extra signature hypotheses |
| [E21](#e21) | Zero exclusion for a cofinal collection of slopes | No extra signature hypotheses |
| [E22](#e22) | Angular positivity certificates for every slope cutoff | No extra signature hypotheses |
| [E23](#e23) | Vanishing actual RR defect | No extra signature hypotheses |
| [E24](#e24) | All-height inverse-square upper bound on the full actual defect | No extra signature hypotheses |
| [E25](#e25) | Inverse-height mass equals actual central xi curvature | Explicit interfaces |
| [E26](#e26) | All-height decay of the central curvature defect | Explicit interfaces |
| [E27](#e27) | Angular integral remainder is little-o of radius | No extra signature hypotheses |
| [E28](#e28) | Finite radius-dependent relative derivative bound on the residual interval | No extra signature hypotheses |
| [E29](#e29) | Locally integrable finite-rate control along the angle | No extra signature hypotheses |
| [E30](#e30) | Arbitrarily small negative linear error in local forward increments | No extra signature hypotheses |
| [E31](#e31) | Canonical exact two-sided passivity | No extra signature hypotheses |
| [E32](#e32) | Literal reciprocal dyadic contraction | No extra signature hypotheses |
| [E33](#e33) | One-sided dyadic contraction, with reflection | No extra signature hypotheses |
| [E34](#e34) | Canonical exact one-sided passivity | No extra signature hypotheses |
| [E35](#e35) | Pointwise GP/BKQR one-sided passivity | No extra signature hypotheses |
| [E36](#e36) | Canonical exact-to-KQ-tail upper bounds | No extra signature hypotheses |
| [E37](#e37) | Raw terminal-Phi cell bound / actual KQ limit core | No extra signature hypotheses |
| [E38](#e38) | Existence of a one-sided finite-energy factorization | No extra signature hypotheses |
| [E39](#e39) | Existence of a telescoping negative-square source | No extra signature hypotheses |
| [E40](#e40) | Existential two-sided constructor under calibrated background | Explicit interfaces |
| [E41](#e41) | Cofinal uniform positivity of the frozen raw-xi Widder tower | Explicit interfaces |

## Native-target details

<a id="e01"></a>

### E01 — Completed xi zeros lie on the critical line

Group: **Actual zero geometry**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

∀s∈ℂ, ξ(s)=0 ⇒ Re(s)=1/2

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `AngularMaster.native_RH_iff_xi_zeros_critical`

```lean
theorem native_RH_iff_xi_zeros_critical :
    _root_.RiemannHypothesis ↔ XiZerosCritical
```

**Original source:** `snapshots/downloads/RH_NATIVE_CANDIDATES_v0_1_1_MELLIN/AngularMaster/ZeroGeometry.lean:97`.

**Reported source SHA-256:** `a2a155d8584f3682c4a48f4b8f0c9fdd1473c25ed4934c448f5015a4647361df`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/a2a155d8584f3682c4a48f4b8f0c9fdd1473c25ed4934c448f5015a4647361df.lean#L97) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L124); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Note: ξ(s)=(1+s(s−1)completedRiemannZeta₀(s))/2. EntireXi uses the algebraically equal normalization (s(s−1)completedRiemannZeta₀(s))/2+1/2. Θ(z)=ξ(1/2+Complex.sqrt(z)); evenness supplies the entire descent.
Aliases / closely matching source versions:
  OverflowResidueRH.riemannHypothesis_iff_entireRiemannXi_zeros_on_critical_line [snapshots/downloads/RH_NATIVE_CANDIDATES_v0_1_1_MELLIN/RiemannHypothesis/Xi/RiemannHypothesisBridge.lean:399]
    Same criterion in another algebraically identical normalization.
  CayleyGolPhi.GOLPHI_RH_IFF_MATHLIB_RH [snapshots/downloads/RH_MASTER_CLOSURE_ANGULAR_LEAN_v0_1_1_FIX1/CayleyGolPhi/ZeroEquivalence.lean:274]
    GolPhiRiemannHypothesis := ∀s, completedGolPhiS1(s)=0 ∧ 0<Re(s)<1 ⇒ Re(s)=1/2. completedGolPhiS1 is definitionally xi; grouping as normalization/zero-predicate alias.
  CayleyGolPhi.CENTERED_GOLPHI_RH_IFF_MATHLIB_RH [snapshots/downloads/RH_MASTER_CLOSURE_ANGULAR_LEAN_v0_1_1_FIX1/CayleyGolPhi/ZeroEquivalence.lean:294]
    CenteredGolPhiRiemannHypothesis := ∀s, NontrivialGolPhiZero(s) ⇒ Re(s−1/2)=0. Same criterion, not a separate analytic equivalence.
```

</details>

<a id="e02"></a>

### E02 — Critical-line pullback has only real zeros

Group: **Actual zero geometry**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

∀z∈ℂ, Ξ(z)=0 ⇒ Im(z)=0

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `OverflowResidueRH.riemannHypothesis_iff_entireXiPullback_zeros_real`

```lean
theorem riemannHypothesis_iff_entireXiPullback_zeros_real :
    RiemannHypothesis ↔
      ∀ z : ℂ, EntireXiPullback z = 0 → z.im = 0
```

**Original source:** `snapshots/downloads/RH_NATIVE_CANDIDATES_v0_1_1_MELLIN/RiemannHypothesis/Xi/RiemannHypothesisBridge.lean:416`.

**Reported source SHA-256:** `4dc024d08641c4e8f8da5da7ac6c67af29fae3ca2e74c249042bb5b5a0fa7c04`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/4dc024d08641c4e8f8da5da7ac6c67af29fae3ca2e74c249042bb5b5a0fa7c04.lean#L416) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L148); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Note: ξ(s)=(1+s(s−1)completedRiemannZeta₀(s))/2. EntireXi uses the algebraically equal normalization (s(s−1)completedRiemannZeta₀(s))/2+1/2. Θ(z)=ξ(1/2+Complex.sqrt(z)); evenness supplies the entire descent. Ξ(z)=ξ(1/2+i z).
Note: Exact change of variable; native RH endpoint, no auxiliary analytic assumptions.
```

</details>

<a id="e03"></a>

### E03 — Theta zeros lie on the nonpositive real axis

Group: **Actual zero geometry**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

∀z∈ℂ, Θ(z)=0 ⇒ Im(z)=0 ∧ Re(z)≤0

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `AngularMaster.native_RH_iff_theta_zeros_nonpositive`

```lean
theorem native_RH_iff_theta_zeros_nonpositive :
    _root_.RiemannHypothesis ↔ ThetaZerosNonpositive
```

**Original source:** `snapshots/downloads/RH_NATIVE_CANDIDATES_v0_1_1_MELLIN/AngularMaster/ZeroGeometry.lean:152`.

**Reported source SHA-256:** `a2a155d8584f3682c4a48f4b8f0c9fdd1473c25ed4934c448f5015a4647361df`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/a2a155d8584f3682c4a48f4b8f0c9fdd1473c25ed4934c448f5015a4647361df.lean#L152) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L167); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Note: ξ(s)=(1+s(s−1)completedRiemannZeta₀(s))/2. EntireXi uses the algebraically equal normalization (s(s−1)completedRiemannZeta₀(s))/2+1/2. Θ(z)=ξ(1/2+Complex.sqrt(z)); evenness supplies the entire descent.
Aliases / closely matching source versions:
  AngularMaster.xi_zeros_critical_iff_theta_zeros_nonpositive [snapshots/downloads/RH_NATIVE_CANDIDATES_v0_1_1_MELLIN/AngularMaster/ZeroGeometry.lean:129]
    Direct equivalence of two native zero-location predicates, then composed with native RH.
```

</details>

<a id="e04"></a>

### E04 — Right-half-plane nonvanishing of the literal entire xi

Group: **Actual zero geometry**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

For every complex z with Re(z)>1/2, xiEntire(z) != 0.

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `NativeSolobolo.SignedBernstein.AnalyticClosure.XI_RIGHT_NONVANISHING_IFF_NATIVE_RH`

```lean
theorem XI_RIGHT_NONVANISHING_IFF_NATIVE_RH :
    (∀ z ∈ xiRightHalfPlane, xiEntire z ≠ 0) ↔ _root_.RiemannHypothesis
```

**Original source:** `snapshots/downloads/RH_NATIVE_SOLOBOLO_SIGNED_BERNSTEIN_LEAN_MERGER_03_MAINLINE/Derivations/XiEndpointEquivalence.lean:71`.

**Reported source SHA-256:** `294372a1dc7f475a66ecc9a3e39ee0813a69cc08984b5f3d72ff414b8d913724`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/294372a1dc7f475a66ecc9a3e39ee0813a69cc08984b5f3d72ff414b8d913724.lean#L71) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L187); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D001](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1712), [D002](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1717).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D001, D002
```

</details>

<a id="e05"></a>

### E05 — Strict Lagarias logarithmic-derivative positivity

Group: **Logarithmic-derivative signs**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

∀s with Re(s)>1/2, ξ(s)≠0 and Re(ξ′(s)/ξ(s))>0

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `OverflowResidueRH.riemannHypothesis_iff_entireXi_lagariasPositivity_unconditional`

```lean
theorem riemannHypothesis_iff_entireXi_lagariasPositivity_unconditional :
    RiemannHypothesis ↔ EntireXi.LagariasPositivity
```

**Original source:** `snapshots/downloads/RH_NATIVE_CANDIDATES_v0_1_1_MELLIN/RiemannHypothesis/Xi/UnconditionalLagariasEquivalence.lean:82`.

**Reported source SHA-256:** `d1e3f6cb7a1a6f8200fe6cb53026b004855d4953272b2875de64c4d75a619275`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/d1e3f6cb7a1a6f8200fe6cb53026b004855d4953272b2875de64c4d75a619275.lean#L82) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L206); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Note: ξ(s)=(1+s(s−1)completedRiemannZeta₀(s))/2. EntireXi uses the algebraically equal normalization (s(s−1)completedRiemannZeta₀(s))/2+1/2. Θ(z)=ξ(1/2+Complex.sqrt(z)); evenness supplies the entire descent.
Note: Full locally supplied dependency closure: 55 source files, no missing local imports, no active custom axiom/sorry/admit tokens after comment stripping. This is a source audit, not a kernel axiom check.
Aliases / closely matching source versions:
  OverflowResidueRH.riemannHypothesis_iff_entireXi_rightHalfPlaneStrictLogDerivSign_unconditional [snapshots/downloads/RH_NATIVE_CANDIDATES_v0_1_1_MELLIN/RiemannHypothesis/Xi/UnconditionalLagariasEquivalence.lean:74]
    Totalized quotient version: strict positivity already forces denominator nonzero. Grouped instead of counted twice.
```

</details>

<a id="e06"></a>

### E06 — Strict anti-Herglotz sign of the xi pullback

Group: **Logarithmic-derivative signs**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

∀z with Im(z)>0, Im(Ξ′(z)/Ξ(z))<0

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `OverflowResidueRH.riemannHypothesis_iff_entireXiPullback_strictAntiHerglotz_unconditional`

```lean
theorem riemannHypothesis_iff_entireXiPullback_strictAntiHerglotz_unconditional :
    RiemannHypothesis ↔ EntireXiPullback.StrictAntiHerglotzSign
```

**Original source:** `snapshots/downloads/RH_NATIVE_CANDIDATES_v0_1_1_MELLIN/RiemannHypothesis/Xi/UnconditionalLagariasEquivalence.lean:67`.

**Reported source SHA-256:** `d1e3f6cb7a1a6f8200fe6cb53026b004855d4953272b2875de64c4d75a619275`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/d1e3f6cb7a1a6f8200fe6cb53026b004855d4953272b2875de64c4d75a619275.lean#L67) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L227); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Note: ξ(s)=(1+s(s−1)completedRiemannZeta₀(s))/2. EntireXi uses the algebraically equal normalization (s(s−1)completedRiemannZeta₀(s))/2+1/2. Θ(z)=ξ(1/2+Complex.sqrt(z)); evenness supplies the entire descent. Ξ(z)=ξ(1/2+i z). StrictAntiHerglotzUHP R := ∀z,0<Im(z)→Im(R(z))<0.
Note: Coordinate-transformed sign criterion; actual native entire xi, no supplied factorization or growth hypothesis remains in this declaration.
```

</details>

<a id="e07"></a>

### E07 — Analytic extension of the actual logarithmic-derivative germ

Group: **Analytic continuation and the ODE germ**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

There exists p analytic on Re(z)>1/2 whose germ at z=1 equals xiEntire'/xiEntire.

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `NativeSolobolo.SignedBernstein.AnalyticClosure.XI_LOG_DERIVATIVE_EXTENSION_IFF_NATIVE_RH`

```lean
theorem XI_LOG_DERIVATIVE_EXTENSION_IFF_NATIVE_RH :
    ActualXiLogDerivativeExtension ↔ _root_.RiemannHypothesis
```

**Original source:** `snapshots/downloads/RH_NATIVE_SOLOBOLO_SIGNED_BERNSTEIN_LEAN_MERGER_03_MAINLINE/Derivations/XiEndpointEquivalence.lean:91`.

**Reported source SHA-256:** `294372a1dc7f475a66ecc9a3e39ee0813a69cc08984b5f3d72ff414b8d913724`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/294372a1dc7f475a66ecc9a3e39ee0813a69cc08984b5f3d72ff414b8d913724.lean#L91) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L247); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D003](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1721).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D003
Note: The analytic extension is the criterion on one side of the iff, not an additional assumed bridge.
Note: Source explicitly says this is not the unfinished equivalence for ActualWeakEnergyBound.
```

</details>

<a id="e08"></a>

### E08 — Analytic first-order ODE coefficient matching the xi germ

Group: **Analytic continuation and the ODE germ**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

There exists p analytic on Re(z)>1/2 such that xiEntire'=p*xiEntire in a neighborhood of z=1.

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `NativeSolobolo.SignedBernstein.AnalyticClosure.XI_ODE_GERM_IFF_NATIVE_RH`

```lean
theorem XI_ODE_GERM_IFF_NATIVE_RH :
    (∃ p : ℂ → ℂ,
      AnalyticOnNhd ℂ p xiRightHalfPlane ∧
      deriv xiEntire =ᶠ[𝓝 (1 : ℂ)] (fun z : ℂ => p z * xiEntire z)) ↔
      _root_.RiemannHypothesis
```

**Original source:** `snapshots/downloads/RH_NATIVE_SOLOBOLO_SIGNED_BERNSTEIN_LEAN_MERGER_03_MAINLINE/Derivations/XiEndpointEquivalence.lean:111`.

**Reported source SHA-256:** `294372a1dc7f475a66ecc9a3e39ee0813a69cc08984b5f3d72ff414b8d913724`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/294372a1dc7f475a66ecc9a3e39ee0813a69cc08984b5f3d72ff414b8d913724.lean#L111) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L266); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Note: The local ODE identity concerns a whole germ, not equality at the single point 1.
Note: Closely related to logarithmic-derivative extension, but its denominator-free criterion is a distinct explicit declaration.
```

</details>

<a id="e09"></a>

### E09 — Zero Cayley loss at every nontrivial zeta zero

Group: **Cayley loss, transmission and energy**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

∀ρ, NontrivialZetaZero(ρ) ⇒ ((g(Reρ)−1)/(g(Reρ)+1))²=0

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `CayleyRHAClosure.ZETA_CAYLEY_ZERO_LOSS_IFF_MATHLIB_RH`

```lean
theorem ZETA_CAYLEY_ZERO_LOSS_IFF_MATHLIB_RH :
    ZetaCayleyZeroLoss ↔ _root_.RiemannHypothesis
```

**Original source:** `snapshots/downloads/GP_BKQR_CAYLEY_RH_A_TIER_CLOSURE_LEAN_v0_4_2_FIX2/CayleyRHClosure.lean:84`.

**Reported source SHA-256:** `518c59f5f83e026919d8bf926bdd7848ea800084e915750923d2aabba4599331`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/518c59f5f83e026919d8bf926bdd7848ea800084e915750923d2aabba4599331.lean#L84) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L289); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Note: g(σ)=exp(log(2)·(2σ−1)); q(σ)=(g(σ)−1)/(g(σ)+1); d(σ)=q(σ)^2; c(σ)=1−d(σ); scalarEnergy(x)=x²; cayleyStep(σ,x)=sqrt(c(σ))·x. This is a constructed scalar scale-gain model, not the theta logarithmic-derivative observable.
Note: Exact algebraic re-encoding of critical-line zero location. Nonnegativity of loss alone supplies no equality-to-zero.
Aliases / closely matching source versions:
  CayleyRHAClosure.GOLPHI_CAYLEY_ZERO_LOSS_IFF_MATHLIB_RH [snapshots/downloads/GP_BKQR_CAYLEY_RH_A_TIER_CLOSURE_LEAN_v0_4_2_FIX2/CayleyRHClosure.lean:78]
    Same zero-loss criterion using the equivalent completed-GolPhi zero predicate.
```

</details>

<a id="e10"></a>

### E10 — Cayley transmission saturates at every nontrivial zero

Group: **Cayley loss, transmission and energy**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

∀ρ, NontrivialGolPhiZero(ρ) ⇒ c(Reρ)=1

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `CayleyRHAClosure.GOLPHI_CAYLEY_SATURATION_IFF_MATHLIB_RH`

```lean
theorem GOLPHI_CAYLEY_SATURATION_IFF_MATHLIB_RH :
    GolPhiCayleySaturation ↔ _root_.RiemannHypothesis
```

**Original source:** `snapshots/downloads/GP_BKQR_CAYLEY_RH_A_TIER_CLOSURE_LEAN_v0_4_2_FIX2/CayleyRHClosure.lean:106`.

**Reported source SHA-256:** `518c59f5f83e026919d8bf926bdd7848ea800084e915750923d2aabba4599331`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/518c59f5f83e026919d8bf926bdd7848ea800084e915750923d2aabba4599331.lean#L106) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L310); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Note: g(σ)=exp(log(2)·(2σ−1)); q(σ)=(g(σ)−1)/(g(σ)+1); d(σ)=q(σ)^2; c(σ)=1−d(σ); scalarEnergy(x)=x²; cayleyStep(σ,x)=sqrt(c(σ))·x. This is a constructed scalar scale-gain model, not the theta logarithmic-derivative observable.
Note: Same algebraic family as zero Cayley loss; retained as a distinct source object/representation, not an independent analytic bridge.
```

</details>

<a id="e11"></a>

### E11 — Unit-state Cayley energy is preserved at every nontrivial zero

Group: **Cayley loss, transmission and energy**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

∀ρ, NontrivialGolPhiZero(ρ) ⇒ scalarEnergy(cayleyStep(Reρ,1))=scalarEnergy(1)

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `CayleyRHAClosure.GOLPHI_CAYLEY_UNIT_ENERGY_PRESERVATION_IFF_MATHLIB_RH`

```lean
theorem GOLPHI_CAYLEY_UNIT_ENERGY_PRESERVATION_IFF_MATHLIB_RH :
    GolPhiCayleyUnitEnergyPreservation ↔ _root_.RiemannHypothesis
```

**Original source:** `snapshots/downloads/GP_BKQR_CAYLEY_RH_A_TIER_CLOSURE_LEAN_v0_4_2_FIX2/CayleyRHClosure.lean:119`.

**Reported source SHA-256:** `518c59f5f83e026919d8bf926bdd7848ea800084e915750923d2aabba4599331`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/518c59f5f83e026919d8bf926bdd7848ea800084e915750923d2aabba4599331.lean#L119) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L328); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Note: g(σ)=exp(log(2)·(2σ−1)); q(σ)=(g(σ)−1)/(g(σ)+1); d(σ)=q(σ)^2; c(σ)=1−d(σ); scalarEnergy(x)=x²; cayleyStep(σ,x)=sqrt(c(σ))·x. This is a constructed scalar scale-gain model, not the theta logarithmic-derivative observable.
Note: Concrete scalar energy realization of the same saturation family. Does not assert a native GP Hilbert moment identification.
```

</details>

<a id="e12"></a>

### E12 — Nonnegative within-derivative on the closed angular interval

Group: **Angular derivative and regular logarithmic slope**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

∀r>0, ∀x∈[−1,1], derivWithin(P(r,·),[−1,1],x)≥0. z(r,x)=r(x+i√(1−x²)); P(r,x)=|AWPIRH.theta(z(r,x))|².

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `RHMaster.native_RH_iff_actualDerivativeNonnegative`

```lean
theorem native_RH_iff_actualDerivativeNonnegative :
    _root_.RiemannHypothesis ↔
      AngularMaster.DerivativeNonnegative AngularMaster.actualProfile
```

**Original source:** `snapshots/downloads/RH_MASTER_ANGULAR_CLOSURE_LEAN_v0_1_0_FIX2/RHMaster/CayleyBridge.lean:52`.

**Reported source SHA-256:** `46c2eaa4eec1b1fdd5aff6b3c7fe42394e641f33b59e23850d16e401ea7cc3aa`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/46c2eaa4eec1b1fdd5aff6b3c7fe42394e641f33b59e23850d16e401ea7cc3aa.lean#L52) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L348); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D004](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1728), [D005](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1733).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D004, D005
Note: Includes one-sided endpoint derivative convention; interior ordinary derivative is a separate equivalent criterion.
```

</details>

<a id="e13"></a>

### E13 — Nonnegative ordinary angular slope on every open semicircle

Group: **Angular derivative and regular logarithmic slope**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

∀r>0, ∀−1<x<1, ∂xP(r,x)≥0. z(r,x)=r(x+i√(1−x²)); P(r,x)=|AWPIRH.theta(z(r,x))|².

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `RHMaster.native_RH_iff_actualAngularSlope_nonnegative`

```lean
theorem native_RH_iff_actualAngularSlope_nonnegative :
    _root_.RiemannHypothesis ↔
      ∀ r : ℝ, 0 < r → ∀ x ∈ Ioo (-1 : ℝ) 1,
        0 ≤ AngularRegularity.actualAngularSlope r x
```

**Original source:** `snapshots/downloads/RH_NATIVE_CANDIDATES_v0_1_1_MELLIN/RHMaster/AngularBridge.lean:74`.

**Reported source SHA-256:** `8717021731d80d28c228fdda18b1217524c5406fc7d2d17eae02fb212dd05d58`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/8717021731d80d28c228fdda18b1217524c5406fc7d2d17eae02fb212dd05d58.lean#L74) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L367); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D006](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1738).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D006
Note: GlobalAngularNonnegative in the separate framework version is the same ordinary derivative criterion under the source identity between profiles; grouped as an alias.
Aliases / closely matching source versions:
  native_RH_iff_actualInteriorSlopeNonnegative [snapshots/downloads/RH_NATIVE_CANDIDATES_v0_1_1_MELLIN/RHMaster/AngularBridge.lean:68]
  native_RH_iff_globalAngularNonnegative [snapshots/downloads/RH_MASTER_ANGULAR_CLOSURE_LEAN_v0_1_0_FIX2/RHMaster/AngularClosure.lean:78]
```

</details>

<a id="e14"></a>

### E14 — Nonnegative Euler logarithmic slope on the regular locus

Group: **Angular derivative and regular logarithmic slope**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

∀r>0, −1<x<1, theta(z(r,x))≠0 ⇒ Im(z(r,x) theta′(z(r,x))/theta(z(r,x)))≥0.

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `RHMaster.native_RH_iff_globalRegularLogSlopeNonnegative`

```lean
theorem native_RH_iff_globalRegularLogSlopeNonnegative :
    _root_.RiemannHypothesis ↔ GlobalRegularLogSlopeNonnegative
```

**Original source:** `snapshots/downloads/RH_MASTER_ANGULAR_CLOSURE_LEAN_v0_1_0_FIX2/RHMaster/AngularClosure.lean:106`.

**Reported source SHA-256:** `877e893ae983415adba18934897fe2d6b06fb9b513f5bdaa816a83f86a2a8b2f`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/877e893ae983415adba18934897fe2d6b06fb9b513f5bdaa816a83f86a2a8b2f.lean#L106) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L390); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D007](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1744), [D008](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1751).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D007, D008
Note: Only the nonzero locus is quantified. The source proves the division-free angular slope vanishes at actual zeros.
```

</details>

<a id="e15"></a>

### E15 — Left endpoint minimizes the angular derivative and has nonnegative derivative

Group: **Angular endpoint minimum**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

∀r>0, ∀x∈[−1,1], D_xP(r,−1)≤D_xP(r,x), and ∀r>0, D_xP(r,−1)≥0. D is the within-derivative. z(r,x)=r(x+i√(1−x²)); P(r,x)=|AWPIRH.theta(z(r,x))|².

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `AngularMaster.native_RH_iff_actual_profileMaster`

```lean
theorem native_RH_iff_actual_profileMaster :
    _root_.RiemannHypothesis ↔ ProfileMaster actualProfile
```

**Original source:** `snapshots/downloads/RH_NATIVE_CANDIDATES_v0_1_1_MELLIN/AngularMaster/Chain.lean:38`.

**Reported source SHA-256:** `6a438ade860096372c31d9ea2656a10027e11eb65fc8e577379615b99b72dfa1`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/6a438ade860096372c31d9ea2656a10027e11eb65fc8e577379615b99b72dfa1.lean#L38) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L410); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D009](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1757), [D010](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1762), [D011](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1768).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D009, D010, D011
Note: v0_3_0 chain has no hproduct argument; older v0_2_0 proof required ActualProductBridge.
Aliases / closely matching source versions:
  RH_iff_Sub_1_and_Sub_2 [snapshots/downloads/RH_NATIVE_CANDIDATES_v0_1_1_MELLIN/AngularMaster/Chain.lean:108]
```

</details>

<a id="e16"></a>

### E16 — Positive-normalizer logarithmic flux master

Group: **Regularized logarithmic flux**. Original label: `NATIVE TARGET / POSITIVE PARAMETER CONDITIONS`.

**Criterion (verbatim from the catalogue):**

For fixed ε>0 and S(r)>0 at every r>0, set L=log(1+εP/S²), J=exp(L) D_xL. For all r>0,x∈[−1,1], J(r,−1)≤J(r,x) and J(r,−1)≥0.

**Additional hypotheses (verbatim):**

```text
  {ε : ℝ} {S : ℝ → ℝ}
  hε : 0 < ε
  hS : ∀ r, 0 < r → 0 < S r
```

**Lean declaration:** `AngularMaster.native_RH_iff_actual_logMaster`

```lean
theorem native_RH_iff_actual_logMaster
    {ε : ℝ} {S : ℝ → ℝ} (hε : 0 < ε) (hS : NormalizerPositive S) :
    _root_.RiemannHypothesis ↔ LogMaster ε S actualProfile
```

**Original source:** `snapshots/downloads/RH_NATIVE_CANDIDATES_v0_1_1_MELLIN/AngularMaster/Chain.lean:57`.

**Reported source SHA-256:** `6a438ade860096372c31d9ea2656a10027e11eb65fc8e577379615b99b72dfa1`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/6a438ade860096372c31d9ea2656a10027e11eb65fc8e577379615b99b72dfa1.lean#L57) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L432); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D012](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1773), [D013](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1780), [D014](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1785), [D015](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1791).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D012, D013, D014, D015
Note: The positive normalizer condition is explicit; no independent regularity hypothesis at the endpoint.
```

</details>

<a id="e17"></a>

### E17 — Logarithmic flux master with the actual theta normalizer

Group: **Regularized logarithmic flux**. Original label: `NATIVE TARGET / POSITIVE PARAMETER CONDITIONS`.

**Criterion (verbatim from the catalogue):**

Same logarithmic flux minimum/nonnegativity criterion with S(r)=|AWPIRH.theta(r)| and fixed ε>0.

**Additional hypotheses (verbatim):**

```text
  {ε : ℝ}
  hε : 0 < ε
```

**Lean declaration:** `AngularMaster.native_RH_iff_frozenLogMaster`

```lean
theorem native_RH_iff_frozenLogMaster
    {ε : ℝ} (hε : 0 < ε) :
    _root_.RiemannHypothesis ↔ frozenLogMaster ε
```

**Original source:** `snapshots/downloads/RH_NATIVE_CANDIDATES_v0_1_1_MELLIN/AngularMaster/Chain.lean:66`.

**Reported source SHA-256:** `6a438ade860096372c31d9ea2656a10027e11eb65fc8e577379615b99b72dfa1`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/6a438ade860096372c31d9ea2656a10027e11eb65fc8e577379615b99b72dfa1.lean#L66) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L453); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D016](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1796), [D017](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1800).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D016, D017
Note: No separate nonvanishing hypothesis on theta(r). ε=1/2 is a special case, not another distinct criterion. frozenLogMaster_epsilon_invariant identifies all positive ε.
Note: Uses the literal actual normalizer, whose positivity is not an external assumption in this theorem.
Aliases / closely matching source versions:
  FROZEN_RH_MASTER_EQUIVALENCE [snapshots/downloads/RH_NATIVE_CANDIDATES_v0_1_1_MELLIN/AngularMaster/Chain.lean:98]
  RH_iff_Master [snapshots/downloads/RH_NATIVE_CANDIDATES_v0_1_1_MELLIN/AngularMaster/Chain.lean:103]
```

</details>

<a id="e18"></a>

### E18 — Slope positivity on the remaining rectangular angular region

Group: **Residual angular regions**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

∀r>255/7, ∀−1<x≤−84/85, ∂xP(r,x)≥0.

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `RHMaster.native_RH_iff_angularResidualNonnegative`

```lean
theorem native_RH_iff_angularResidualNonnegative :
    _root_.RiemannHypothesis ↔ AngularResidualNonnegative
```

**Original source:** `snapshots/downloads/RH_NATIVE_CANDIDATES_v0_1_1_MELLIN/RHMaster/AngularCoverage.lean:90`.

**Reported source SHA-256:** `f0ea18f9520141e144c78e6fd0705891597cce9325c8367fafd996b16a26dcd9`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/f0ea18f9520141e144c78e6fd0705891597cce9325c8367fafd996b16a26dcd9.lean#L90) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L479); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D018](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1804).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D018
Note: The strict endpoint variant x<−84/85 is grouped here: endpoint positivity has separately been proved by continuity. Known radius slab and sector are already discharged.
Aliases / closely matching source versions:
  native_RH_iff_strictAngularResidual [snapshots/downloads/RH_NATIVE_CANDIDATES_v0_1_1_MELLIN/Develop/NativeAngularResidualDevelopment.lean:75]
  RH_MASTER_EQUIVALENCE [snapshots/downloads/RH_MASTER_CLOSURE_ANGULAR_LEAN_v0_1_1_FIX1/RHMaster/ClosureAtlas.lean:41]
```

</details>

<a id="e19"></a>

### E19 — Slope positivity on the smaller curved residual region

Group: **Residual angular regions**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

∀r>255/7, ∀x: −1<x<−84/85 and x≤−1+(84/167)/r ⇒ ∂xP(r,x)≥0.

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `NativeAngularResidualDevelopment.native_RH_iff_curvedAngularResidual`

```lean
theorem native_RH_iff_curvedAngularResidual :
    _root_.RiemannHypothesis ↔ CurvedAngularResidualNonnegative
```

**Original source:** `snapshots/downloads/RH_NATIVE_CANDIDATES_v0_1_1_MELLIN/Develop/NativeAngularResidualDevelopment.lean:320`.

**Reported source SHA-256:** `a8bf4702eebc50637f3d3da3923b0bc8f679c26e8b3ba5aa1c6f52d3afd18248`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/a8bf4702eebc50637f3d3da3923b0bc8f679c26e8b3ba5aa1c6f52d3afd18248.lean#L320) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L500); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D019](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1810), [D020](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1817).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D019, D020
Note: Accepted D155 audit log in focus_three_bridges_3595_19799_1630 lines27–30; source remains an equivalence, not a proof of the residual sign.
Note: The extra radius-dependent curved bound removes an additional proved angular region.
```

</details>

<a id="e20"></a>

### E20 — Zero exclusion in every positive-slope wedge

Group: **Wedge exhaustion**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

∀m>0, ∀s with 0<Re(s)<1 and |Im(s)|<m|Re(s)−1/2|, ζ(s)≠0.

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `RHMaster.rh_iff_allSlopeQQRH`

```lean
theorem rh_iff_allSlopeQQRH : _root_.RiemannHypothesis ↔ AllSlopeQQRH
```

**Original source:** `snapshots/downloads/RH_MASTER_CLOSURE_ANGULAR_LEAN_v0_1_1_FIX1/RHMaster/QQRHClosure.lean:71`.

**Reported source SHA-256:** `6af86a8b5a7f4b328726fa8cb72008e688fd563efc42d63261d2d8e0e294b3d1`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/6af86a8b5a7f4b328726fa8cb72008e688fd563efc42d63261d2d8e0e294b3d1.lean#L71) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L521); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D021](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1821), [D022](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1826), [D023](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1832).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D021, D022, D023
Note: Coverage is over every positive wedge slope; a fixed slope is insufficient.
```

</details>

<a id="e21"></a>

### E21 — Zero exclusion for a cofinal collection of slopes

Group: **Wedge exhaustion**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

∀M>0, ∃m≥M, QQRH(m).

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `RHMaster.rh_iff_cofinalSlopeQQRH`

```lean
theorem rh_iff_cofinalSlopeQQRH : _root_.RiemannHypothesis ↔ CofinalSlopeQQRH
```

**Original source:** `snapshots/downloads/RH_MASTER_CLOSURE_ANGULAR_LEAN_v0_1_1_FIX1/RHMaster/QQRHClosure.lean:74`.

**Reported source SHA-256:** `6af86a8b5a7f4b328726fa8cb72008e688fd563efc42d63261d2d8e0e294b3d1`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/6af86a8b5a7f4b328726fa8cb72008e688fd563efc42d63261d2d8e0e294b3d1.lean#L74) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L538); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D024](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1836).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D024
Note: Old CofinalQQRH uses ∀M∈ℝ,∃m>M. These two cofinal conventions are grouped; no duplicate count.
Note: Existential unbounded family rather than quantifying every slope.
Aliases / closely matching source versions:
  native_RH_iff_cofinal_QQRH [snapshots/downloads/RH_MASTER_ANGULAR_CLOSURE_LEAN_v0_1_0_FIX2/RHMaster/ClosureAtlas.lean:51]
```

</details>

<a id="e22"></a>

### E22 — Angular positivity certificates for every slope cutoff

Group: **Slope-dependent angular certificates**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

∀m>0, ∀r>0, ∀(1−m²)/(1+m²)<x<1, D_xP(r,x)≥0.

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `RHMaster.rh_iff_allSlopePositivity`

```lean
theorem rh_iff_allSlopePositivity :
    _root_.RiemannHypothesis ↔ AllSlopePositivity
```

**Original source:** `snapshots/downloads/RH_MASTER_CLOSURE_ANGULAR_LEAN_v0_1_1_FIX1/RHMaster/QQRHClosure.lean:93`.

**Reported source SHA-256:** `6af86a8b5a7f4b328726fa8cb72008e688fd563efc42d63261d2d8e0e294b3d1`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/6af86a8b5a7f4b328726fa8cb72008e688fd563efc42d63261d2d8e0e294b3d1.lean#L93) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L560); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D025](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1841), [D026](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1847).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D025, D026
Note: Positive-slope angular certificate family, before transferring to wedge zero exclusion.
```

</details>

<a id="e23"></a>

### E23 — Vanishing actual RR defect

Group: **Actual RR defect**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

C=Σ_occ δ²(3γ²+δ²)/(γ²(γ²+δ²)²)=0; positive-height canonical occurrences retain analytic multiplicity.

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `NativeRRBinding.actual_defect_zero_iff_nativeRH`

```lean
theorem actual_defect_zero_iff_nativeRH : actualData.C = 0 ↔ _root_.RiemannHypothesis
```

**Original source:** `snapshots/downloads/RH_NATIVE_CANDIDATES_v0_1_1_MELLIN/Develop/NativeRRBinding.lean:201`.

**Reported source SHA-256:** `9653ffc2a05cc7e4cbccbe3d138a9a859d2756a8a92cb83c15d5c77811e0ca63`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/9653ffc2a05cc7e4cbccbe3d138a9a859d2756a8a92cb83c15d5c77811e0ca63.lean#L201) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L580); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D027](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1853), [D028](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1859).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D027, D028
Note: ActualData and actualBinding are constructed, not theorem arguments. Accepted D156 native-equivalence dependency audit: focus_three_bridges_3595_19799_1630/D156.log lines23–26. Current source matches that session snapshot byte-for-byte.
```

</details>

<a id="e24"></a>

### E24 — All-height inverse-square upper bound on the full actual defect

Group: **Actual RR defect**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

∀T≥1, 0≤C and C≤3 c1/(4T²), with actualData and c1=Σ_occ 1/γ².

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `NativeRRBinding.actual_all_height_bound_iff_nativeRH`

```lean
theorem actual_all_height_bound_iff_nativeRH :
    PositivityPremise.PositivityPremise actualData.C actualData.c1 ↔
      _root_.RiemannHypothesis
```

**Original source:** `snapshots/downloads/RH_NATIVE_CANDIDATES_v0_1_1_MELLIN/Develop/NativeRRBinding.lean:204`.

**Reported source SHA-256:** `9653ffc2a05cc7e4cbccbe3d138a9a859d2756a8a92cb83c15d5c77811e0ca63`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/9653ffc2a05cc7e4cbccbe3d138a9a859d2756a8a92cb83c15d5c77811e0ca63.lean#L204) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L597); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D029](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1868), [D030](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1873).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D029, D030
Note: The source theorem is in the accepted D156 module. Tail≤bound alone is not this all-height bound on full C.
```

</details>

<a id="e25"></a>

### E25 — Inverse-height mass equals actual central xi curvature

Group: **RR central-curvature identification**. Original label: `NATIVE TARGET / ADDITIONAL INTERFACE HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

c1 = Re[canonicalXi″(1/2)/(2 canonicalXi(1/2))].

**Additional hypotheses (verbatim):**

```text
  {ι : Type*} {D : ZeroData ι}
  B : ZetaBinding D
  htrace : TraceIdentification D (centerCurvature = D.trace)
```

**Lean declaration:** `PositivityPremise.CENTRAL_CURVATURE_EQUALITY_IFF_RH`

```lean
theorem CENTRAL_CURVATURE_EQUALITY_IFF_RH {ι : Type*} {D : ZeroData ι}
    (B : ZetaBinding D) (htrace : TraceIdentification D) :
    D.c1 = centerCurvature ↔ RiemannHypothesis
```

**Original source:** `snapshots/downloads/RH_NATIVE_CANDIDATES_v0_1_1_MELLIN/PositivityPremise/LiteralZeta.lean:93`.

**Reported source SHA-256:** `14c9de048e3b7147dd7ae6a383e1f89986c65296b8ed3f8f47beb0ed34d33766`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/14c9de048e3b7147dd7ae6a383e1f89986c65296b8ed3f8f47beb0ed34d33766.lean#L93) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L618); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D031](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1883), [D032](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1888), [D033](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1893).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D031, D032, D033
Note: The trace identification is an explicit hypothesis; do not silently specialize it to actualData as an established theorem.
```

</details>

<a id="e26"></a>

### E26 — All-height decay of the central curvature defect

Group: **RR central-curvature identification**. Original label: `NATIVE TARGET / ADDITIONAL INTERFACE HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

∀T≥1, 0≤c1−centerCurvature≤3 c1/(4T²).

**Additional hypotheses (verbatim):**

```text
  {ι : Type*} {D : ZeroData ι}
  B : ZetaBinding D
  htrace : TraceIdentification D
```

**Lean declaration:** `PositivityPremise.CURVATURE_POSITIVITY_PREMISE_IFF_RH`

```lean
theorem CURVATURE_POSITIVITY_PREMISE_IFF_RH {ι : Type*} {D : ZeroData ι}
    (B : ZetaBinding D) (htrace : TraceIdentification D) :
    PositivityPremise (D.c1 - centerCurvature) D.c1 ↔ RiemannHypothesis
```

**Original source:** `snapshots/downloads/RH_NATIVE_CANDIDATES_v0_1_1_MELLIN/PositivityPremise/LiteralZeta.lean:86`.

**Reported source SHA-256:** `14c9de048e3b7147dd7ae6a383e1f89986c65296b8ed3f8f47beb0ed34d33766`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/14c9de048e3b7147dd7ae6a383e1f89986c65296b8ed3f8f47beb0ed34d33766.lean#L86) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L639); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D029](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1868).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D029
Note: CanonicalZetaBinding strengthens B with injectivity and exact multiplicity but does not create a different scalar criterion; recorded as an alias with stronger assumptions.
Aliases / closely matching source versions:
  CANONICAL_POSITIVITY_PREMISE_IFF_RH [snapshots/downloads/RH_NATIVE_CANDIDATES_v0_1_1_MELLIN/PositivityPremise/LiteralZeta.lean:101]
```

</details>

<a id="e27"></a>

### E27 — Angular integral remainder is little-o of radius

Group: **Angular small-o asymptotic**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

I(r)−πr S(r)=o(r) as r→0+, where I(r)=∫_{−1}^{1} (∂xP/P)√(1−x²) dx, and S(r) is the actual multiplicity-bearing critical-line cutoff at height 1/r.

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `RHSmallO.rh_iff_angular_integral_isLittleO`

```lean
theorem rh_iff_angular_integral_isLittleO :
    _root_.RiemannHypothesis ↔
      (fun r : ℝ => AngularMaster.angularI r - Real.pi * r * criticalLineCutoff r)
        =o[𝓝[>] 0] (fun r : ℝ => r)
```

**Original source:** `snapshots/downloads/RH_GIGGA_SMALL_O_EQUIVALENCE_LEAN_v0_2_0/RHSmallOEquivalence.lean:33`.

**Reported source SHA-256:** `58c678f9818d39b183b7bf3b2b7bec49c0b43b8766457e19dd09b93595ab7a1f`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/58c678f9818d39b183b7bf3b2b7bec49c0b43b8766457e19dd09b93595ab7a1f.lean#L33) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L664); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D034](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1898), [D035](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1904), [D036](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1910), [D037](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1917).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D034, D035, D036, D037
Note: No extra origin-trace or normalized-integral hypothesis in the final equivalence. The ordinary unnormalized limit I→0 is unconditional and is not this criterion.
Aliases / closely matching source versions:
  small_o_iff_RH [snapshots/downloads/RH_GIGGA_SMALL_O_EQUIVALENCE_LEAN_v0_2_0/RHSmallOEquivalence.lean:25]
  rh_iff_small_o [snapshots/downloads/RH_GIGGA_SMALL_O_EQUIVALENCE_LEAN_v0_2_0/RHSmallOEquivalence.lean:29]
```

</details>

<a id="e28"></a>

### E28 — Finite radius-dependent relative derivative bound on the residual interval

Group: **Relative derivative bound**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

∀r>255/7, ∃M>0, ∀−1<x≤−κ(r), A(r,x)>0 ⇒ (1+x)∂xA(r,x)≤M A(r,x); A=∂xP and κ(r)=inf_{R≥85/2} ((R−1/2)(R²+r²)/(2rR²)).

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `MisterPremise.MISTERPREMISE_iff_RiemannHypothesis`

```lean
theorem MISTERPREMISE_iff_RiemannHypothesis :
    MISTERPREMISE ↔ _root_.RiemannHypothesis
```

**Original source:** `snapshots/downloads/RH_MISTERPREMISE_LEAN_v0_1_0/MisterPremise/Equivalence.lean:135`.

**Reported source SHA-256:** `de152a63887d7c95ce8c05208e5a611648774b282cc11c3ea3fbc7e54b255b81`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/de152a63887d7c95ce8c05208e5a611648774b282cc11c3ea3fbc7e54b255b81.lean#L135) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L689); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D038](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1922), [D039](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1929), [D040](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1934), [D041](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1939).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D038, D039, D040, D041
Note: The finite constant may depend on r; it is uniform only in x on this interval. No global radius-independent constant or simple-zero assumption.
Aliases / closely matching source versions:
  RiemannHypothesis_iff_MISTERPREMISE [snapshots/downloads/RH_MISTERPREMISE_LEAN_v0_1_0/MisterPremise/Equivalence.lean:139]
```

</details>

<a id="e29"></a>

### E29 — Locally integrable finite-rate control along the angle

Group: **Finite-rate angular propagation**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

∀r>0, ∃rate:ℝ→ℝ, rate is interval-integrable on [0,b] for every 0<b<π, rate≥0 on (0,π), and F(r,θ)>0 ⇒ ∂θF(r,θ)≥−rate(θ)F(r,θ), where F(r,θ)=∂xP(r,cosθ).

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `TaylorsProdigy.TAYLORS_PRODIGY_PREMISE_iff_RH`

```lean
theorem TAYLORS_PRODIGY_PREMISE_iff_RH :
    TAYLORS_PRODIGY_PREMISE ↔ _root_.RiemannHypothesis
```

**Original source:** `snapshots/downloads/TAYLORS_PRODIGY_LEAN_v0_2_0/TaylorProdigy/Equivalence.lean:9`.

**Reported source SHA-256:** `12ec9f59b7445c05e8a57593d07ea98e28b04a910c1b9c120e401e3e812e319e`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/12ec9f59b7445c05e8a57593d07ea98e28b04a910c1b9c120e401e3e812e319e.lean#L9) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L711); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D042](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1943), [D043](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1952), [D044](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1956).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D042, D043, D044
Note: Namespace is TaylorsProdigy (plural), import module is TaylorProdigy.Equivalence (singular). v0_2_0 contains the converse for the unchanged premise.
```

</details>

<a id="e30"></a>

### E30 — Arbitrarily small negative linear error in local forward increments

Group: **Local first-order increments**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

∀r>0,−1<x<1,∀ε>0,∃η>0,∀0<h<η with x+h≤1: P(r,x+h)−P(r,x)≥−εh.

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `StirlingsProdigy.STIRLINGS_PRODIGY_LOCAL_IFF_RH`

```lean
theorem STIRLINGS_PRODIGY_LOCAL_IFF_RH :
    STIRLINGS_PRODIGY_LOCAL ↔ _root_.RiemannHypothesis
```

**Original source:** `snapshots/downloads/STIRLINGS_PRODIGY_LEAN_v0_2_0/StirlingsProdigy/Equivalence.lean:32`.

**Reported source SHA-256:** `2936d9b7c7b5bcc41ee50b608aff812b42b63fa163ea06f1e02a3336f82969e1`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/2936d9b7c7b5bcc41ee50b608aff812b42b63fa163ea06f1e02a3336f82969e1.lean#L32) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L731); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D045](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1960), [D046](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1966).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D045, D046
Note: Only the separately named LOCAL criterion has a converse. The original global affine STIRLINGS_PRODIGY remains sufficient only.
Aliases / closely matching source versions:
  RH_IFF_STIRLINGS_PRODIGY_LOCAL [snapshots/downloads/STIRLINGS_PRODIGY_LEAN_v0_2_0/StirlingsProdigy/Equivalence.lean:37]
```

</details>

<a id="e31"></a>

### E31 — Canonical exact two-sided passivity

Group: **Dyadic contraction and passivity**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

For every PhiZero phiEta rho, D_+(rho) ≤ 0 and D_-(rho) ≤ 0, where D_±=(g_±−1)E_±, g_+=scale2(2(Re rho−1/2)), g_−=scale2(−2(Re rho−1/2)), and E_± are canonicalModel exact energies.

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `AWPI.PhiRH.NativeRHExactWaist.CANONICAL_TWO_DEFECT_SIGNS_IFF_MATHLIB_RH`

```lean
theorem CANONICAL_TWO_DEFECT_SIGNS_IFF_MATHLIB_RH :
    CanonicalTwoDefectSigns ↔
      RiemannHypothesis
```

**Original source:** `snapshots/downloads/AWPI_PHI_RH_NATIVE_FINAL_FREEZE_20260918/AWPI/PhiRH/NativeRHExactWaist.lean:170`.

**Reported source SHA-256:** `b0b80b4872913e6da25b88146277f1216695987922b0c23be6940e7eb3ed7c1d`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/b0b80b4872913e6da25b88146277f1216695987922b0c23be6940e7eb3ed7c1d.lean#L170) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L753); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D047](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1973), [D048](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1981).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D047, D048
Note: Gain bounds g_±≤1 and centered bounds c≤0≤c are algebraic normal forms of this entry, not extra independent mechanisms.
Aliases / closely matching source versions:
  AWPI.PhiRH.NativeRHExactWaist.EXACT_TWO_SIDED_PASSIVITY_IFF_MATHLIB_RH [snapshots/downloads/AWPI_PHI_RH_NATIVE_FINAL_FREEZE_20260918/AWPI/PhiRH/NativeRHExactWaist.lean:148]
  AWPI.PhiRH.NativeRHFinal.RH_IFF_CANONICAL_GAIN_BOUNDS [snapshots/downloads/AWPI_PHI_RH_NATIVE_FINAL_FREEZE_20260918/AWPI/PhiRH/NativeRHFinal.lean:16]
  AWPI.PhiRH.NativeRHAlgebraicWaist.CENTERED_BOUNDS_IFF_MATHLIB_RH [snapshots/downloads/AWPI_PHI_RH_NATIVE_FINAL_FREEZE_20260918/AWPI/PhiRH/NativeRHAlgebraicWaist.lean:230]
```

</details>

<a id="e32"></a>

### E32 — Literal reciprocal dyadic contraction

Group: **Dyadic contraction and passivity**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

For every PhiZero phiEta rho, 2^{2(Re rho−1/2)}≤1 and 2^{−2(Re rho−1/2)}≤1.

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `AWPI.PhiRH.NativeRHGlobalNormalForm.GLOBAL_LITERAL_DYADIC_CONTRACTION_IFF_MATHLIB_RH`

```lean
theorem GLOBAL_LITERAL_DYADIC_CONTRACTION_IFF_MATHLIB_RH :
    GlobalLiteralDyadicContraction ↔
      RiemannHypothesis
```

**Original source:** `snapshots/downloads/awpi_phi_rh_lean_dyadic_scale_v0_1_8_run_20260918_182436_414/awpi_phi_rh_lean_dyadic_scale_v0_1_8/AWPI/PhiRH/NativeRHGlobalNormalForm.lean:34`.

**Reported source SHA-256:** `4f77a537f64cc04e72e137c86708a192d1f339b572984b574f97e027ae7fd17d`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/4f77a537f64cc04e72e137c86708a192d1f339b572984b574f97e027ae7fd17d.lean#L34) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L776); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D049](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1993), [D050](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2003).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D049, D050
Note: Fully expanded gain normal form of AWPI01; retain as a useful explicit formula but do not count as a separate research mechanism.
Note: dyadicScale a is defined as Real.exp(a * Real.log 2), the literal exponential representation of 2^a.
```

</details>

<a id="e33"></a>

### E33 — One-sided dyadic contraction, with reflection

Group: **Dyadic contraction and passivity**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

For every PhiZero phiEta rho, 2^{2(Re rho−1/2)}≤1. Equivalently the reverse-sign contraction holds at every zero. The equivalent native-zeta version is ScalarDyadicCore: every NontrivialZetaZero has the plus gain ≤1.

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `AWPI.PhiRH.NativeRHOneSidedReflection.GLOBAL_PLUS_DYADIC_CONTRACTION_IFF_MATHLIB_RH`

```lean
theorem GLOBAL_PLUS_DYADIC_CONTRACTION_IFF_MATHLIB_RH :
    GlobalPlusDyadicContraction ↔
      RiemannHypothesis
```

**Original source:** `snapshots/downloads/awpi_phi_rh_lean_dyadic_scale_v0_1_8_run_20260918_182436_414/awpi_phi_rh_lean_dyadic_scale_v0_1_8/AWPI/PhiRH/NativeRHOneSidedReflection.lean:154`.

**Reported source SHA-256:** `eefd03d3776ebc9fd7380566653003b1156ab69141f9a538368773338e778596`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/eefd03d3776ebc9fd7380566653003b1156ab69141f9a538368773338e778596.lean#L154) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L796); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Note: The one-sided reduction uses the genuine functional-equation reflection rho↦1−rho. MinimalRHFrontier is simply ∀ nontrivial zeros, Re rho≤1/2. Group plus/minus and scalar/minimal names together.
Aliases / closely matching source versions:
  AWPI.PhiRH.NativeRHOneSidedReflection.GLOBAL_MINUS_DYADIC_CONTRACTION_IFF_MATHLIB_RH [snapshots/downloads/awpi_phi_rh_lean_dyadic_scale_v0_1_8_run_20260918_182436_414/awpi_phi_rh_lean_dyadic_scale_v0_1_8/AWPI/PhiRH/NativeRHOneSidedReflection.lean:209]
  AWPI.PhiRH.ScalarConcreteFrontier.scalarDyadicCore_iff_mathlibRH [snapshots/downloads/awpi_phi_rh_lean_minimal_frontier_v0_2_17_native16_run_20260919_101403_208/awpi_phi_rh_lean_minimal_frontier_v0_2_17_native16/AWPI/PhiRH/ScalarConcreteFrontier.lean:87]
  AWPI.PhiRH.MinimalFrontier.minimalRHFrontier_iff_mathlibRH [snapshots/downloads/awpi_phi_rh_lean_minimal_frontier_v0_2_17_native16_run_20260919_101403_208/awpi_phi_rh_lean_minimal_frontier_v0_2_17_native16/AWPI/PhiRH/MinimalFrontier.lean:39]
```

</details>

<a id="e34"></a>

### E34 — Canonical exact one-sided passivity

Group: **Dyadic contraction and passivity**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

For every NontrivialZetaZero rho, canonicalPlusExactDefect rho≤0, with defect (2^{2(Re rho−1/2)}−1)·canonicalPlusJet(rho)^2.

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `AWPI.PhiRH.ScalarConcreteFrontier.plusPassivityCore_iff_RiemannHypothesis`

```lean
theorem plusPassivityCore_iff_RiemannHypothesis :
    PlusPassivityCore ↔ RiemannHypothesis
```

**Original source:** `snapshots/lean-native/awpi_phi_rh_lean_sieved_v0_1_1/AWPI/PhiRH/ScalarConcreteFrontier.lean:93`.

**Reported source SHA-256:** `caab68732cd28164148492b1fc68689e2761e886ddcf3ad6731399882735d44a`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/caab68732cd28164148492b1fc68689e2761e886ddcf3ad6731399882735d44a.lean#L93) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L818); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D051](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2008), [D052](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2014).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D051, D052
Note: Positive canonical jet square and reflection reduce this to AWPI03. A useful energy expression, not a separate mathematical mechanism.
```

</details>

<a id="e35"></a>

### E35 — Pointwise GP/BKQR one-sided passivity

Group: **Dyadic contraction and passivity**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

For every literal nontrivial zeta zero rho, there exists c>0 with (2^(2*(Re rho-1/2))-1)*c^2 <= 0. Reflection of zeta zeros yields the critical-line conclusion.

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `ConstructiveCriticalLine.actualPointwiseGPBKQRPlusPassivity_iff_riemannHypothesis`

```lean
theorem actualPointwiseGPBKQRPlusPassivity_iff_riemannHypothesis :
    ActualPointwiseGPBKQRPlusPassivity ↔ RiemannHypothesis
```

**Original source:** `snapshots/downloads/CONSTRUCTIVE_RH_ACTUAL_GP_BKQR_GAP_LEAN_v0_3_0/ActualGPBKQRGap.lean:44`.

**Reported source SHA-256:** `d114fd783095587758f66a29792af2f60e8ecb8ab91afbb382a4aa283099d3a0`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/d114fd783095587758f66a29792af2f60e8ecb8ab91afbb382a4aa283099d3a0.lean#L44) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L836); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D053](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2020), [D054](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2025), [D055](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2030), [D056](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2035), [D057](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2040), [D058](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2044).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D053, D054, D055, D056, D057, D058
Note: Proof of both directions is present. Project imports Mathlib.NumberTheory.LSeries.Nonvanishing and derives reflection; no project axiom/opaque/sorry/admit occurrences were found in this package by static search. This criterion is exactly the universal one-sided real-part inequality; the independent operator intertwining construction is a separate sufficient input.
```

</details>

<a id="e36"></a>

### E36 — Canonical exact-to-KQ-tail upper bounds

Group: **Exact defect controlled by KQ tails**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

For all n∈ℕ and all NontrivialZetaZero rho, canonicalPlusExactDefect(rho) ≤ canonicalKQPlusSource(n,Re rho,Im rho)^2.

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `AWPI.PhiRH.CanonicalOneSidedTail.canonicalPlusExactTailUpper_iff_RiemannHypothesis`

```lean
theorem canonicalPlusExactTailUpper_iff_RiemannHypothesis :
    CanonicalPlusExactTailUpper ↔ RiemannHypothesis
```

**Original source:** `snapshots/lean-native/awpi_phi_rh_lean_sieved_v0_1_1/AWPI/PhiRH/CanonicalOneSidedTail.lean:152`.

**Reported source SHA-256:** `f5e6948f3afef9d09d3316387ad111fa4edafe9e1389086a85981b5ba636aff3`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/f5e6948f3afef9d09d3316387ad111fa4edafe9e1389086a85981b5ba636aff3.lean#L152) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L856); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D059](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2051).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D059
Note: canonicalTransverseJet is defined to be rhoNorm2(rho)·shiftedPhiNorm2(canonicalPhiS1,rho); binding scales are defined to be 1. This is a concrete model choice, not an equality with an independently defined historical analytic jet.
Note: The source proves canonical KQ tail decay and jet activity; letting the squared tail become arbitrarily small gives passivity. Conversely RH makes the defect zero.
```

</details>

<a id="e37"></a>

### E37 — Raw terminal-Phi cell bound / actual KQ limit core

Group: **Exact defect controlled by KQ tails**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

For all n and nontrivial zeros rho=σ+iτ: (2^{2(σ−1/2)}−1)(σ²+τ²)² ≤ [cos(τ log 2)·phiCellRe(n,1,σ,τ)+sin(τ log 2)·phiCellIm(n,1,σ,τ)]². Here phiCellRe(n,u,σ,τ)=4(−1)^n(2n+u+1)^{−σ}cos(τ log(2n+u+1)), and phiCellIm has the corresponding negative sine.

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `AWPI.PhiRH.RawConcreteFrontier.rawActualPlusKQFrontier_iff_mathlibRH`

```lean
theorem rawActualPlusKQFrontier_iff_mathlibRH :
    RawActualPlusKQFrontier ↔ RiemannHypothesis
```

**Original source:** `snapshots/downloads/awpi_phi_rh_lean_scalar_frontier_v0_2_16_native16_run_20260919_100223_134/awpi_phi_rh_lean_scalar_frontier_v0_2_16_native16/AWPI/PhiRH/RawConcreteFrontier.lean:81`.

**Reported source SHA-256:** `0cf503df297a115c62b5fb274b4567b56ec93592f1c1e1b607b9ae23ae7b3a3f`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/0cf503df297a115c62b5fb274b4567b56ec93592f1c1e1b607b9ae23ae7b3a3f.lean#L81) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L875); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D060](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2059), [D061](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2068), [D062](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2076).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D060, D061, D062
Note: ActualPlusKQLimitCore and RawActualPlusKQFrontier are proved equivalent by exact source formula exposure. This is the explicit older audited normalization of the same tail-bound mechanism as AWPI05; do not silently identify their jets across snapshots.
Aliases / closely matching source versions:
  AWPI.PhiRH.SingleConcreteFrontier.actualPlusKQLimitCore_iff_mathlibRH [snapshots/downloads/awpi_phi_rh_lean_scalar_frontier_v0_2_16_native16_run_20260919_100223_134/awpi_phi_rh_lean_scalar_frontier_v0_2_16_native16/AWPI/PhiRH/SingleConcreteFrontier.lean:164]
```

</details>

<a id="e38"></a>

### E38 — Existence of a one-sided finite-energy factorization

Group: **Finite-energy factorization**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

There exist finite energies F_n(rho), tails T_n(rho), and a scalar remainder r_n such that at every nontrivial zero: E=F_n+T_n; (g−1)F_n≤0; (g−1)T_n≤r_n; and ∀ε>0 ∃n, r_n≤ε. Here E is the canonical plus-jet square and g=2^{2(Re rho−1/2)}.

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `AWPI.PhiRH.FactorizationFrontier.existsCanonicalPlusFactorization_iff_mathlibRH`

```lean
theorem existsCanonicalPlusFactorization_iff_mathlibRH :
    ExistsCanonicalPlusFactorization ↔ RiemannHypothesis
```

**Original source:** `snapshots/downloads/awpi_phi_rh_lean_factorization_frontier_v0_2_12_native16_run_20260918_204106_782/awpi_phi_rh_lean_factorization_frontier_v0_2_12_native16/AWPI/PhiRH/FactorizationFrontier.lean:138`.

**Reported source SHA-256:** `30bf20868e466c50fe22e5d59b57ec5d523898fe0857516fd43e096c0ade7781`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/30bf20868e466c50fe22e5d59b57ec5d523898fe0857516fd43e096c0ade7781.lean#L138) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L897); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D063](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2082).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D063
Note: No nonnegativity, prescribed approximation process, or Tendsto condition on F,T,r is included in this definition. The same r_n works at all zeros. Its arbitrarily-small-from-above condition is weaker than asserting convergence.
Note: Forward: exact defect splits into finite defect plus tail defect and is ≤r_n; force ≤0 then use reflection. Reverse: choose F_n=E,T_n=0,r_n=0 under RH.
```

</details>

<a id="e39"></a>

### E39 — Existence of a telescoping negative-square source

Group: **Telescoping negative-square sources**. Original label: `NATIVE TARGET / NO EXTRA THEOREM HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

There exist F_n(rho), T_n(rho), scalar r_n, and cells b_n(rho) with E=F_n+T_n, b_0=0, (g−1)F_n=∑_{k<n}(−b_{k+1}²+b_k²), (g−1)T_n≤r_n, and ∀ε>0 ∃n, r_n≤ε, at every nontrivial zero.

**Additional hypotheses (verbatim):**

```text
  None in this declaration.
```

**Lean declaration:** `AWPI.PhiRH.HistoricalSourceStandaloneClean.existsHistoricalPlusPointwiseSource_iff_mathlibRH`

```lean
theorem existsHistoricalPlusPointwiseSource_iff_mathlibRH :
    ExistsHistoricalPlusPointwiseSource ↔ RiemannHypothesis
```

**Original source:** `snapshots/downloads/awpi_phi_rh_lean_scalar_frontier_v0_2_16_native16_run_20260919_100223_134/awpi_phi_rh_lean_scalar_frontier_v0_2_16_native16/AWPI/PhiRH/HistoricalSourceStandaloneClean.lean:290`.

**Reported source SHA-256:** `655fff1004fdfd4fed378b41cd03fb2cf49758ea9657ace91062b751533a0c92`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/655fff1004fdfd4fed378b41cd03fb2cf49758ea9657ace91062b751533a0c92.lean#L290) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L918); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D064](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2092), [D065](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2106).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D064, D065
Note: Retain this as a structured certificate form of AWPI07; the extra source form supplies a mechanism for finite passivity, not an independent verification that the source exists.
Note: The source record has exactly five fields. Cells and finite/tail energies are existentially free; they are not fixed by a pre-existing analytic construction.
Note: Telescoping gives finite defect −b_n²≤0, then the tail argument gives passivity. Reverse RH uses zero finite energy, the whole energy as tail, zero cells and zero remainder.
```

</details>

<a id="e40"></a>

### E40 — Existential two-sided constructor under calibrated background

Group: **Calibrated two-sided constructor**. Original label: `NATIVE TARGET / ADDITIONAL INTERFACE HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

Constructor(literalZetaModel) ↔ native RH, for a model whose zero predicate and real part are literally those of zeta. Constructor asks for finite defects and square functions, negative-square identities, and exact-defect ≤ finite-defect + squared-tail bounds on both sides.

**Additional hypotheses (verbatim):**

```text
  Arbitrary Jet type; state : ℂ→Jet; energies : Jet→ℝ; scale2 : ℝ→ℝ; two tail sources : ℕ→ℂ→ℝ; sourceFormula : Prop.
  NormalizedDyadicMultiplierFacts: sourceFormula plus positive strip imply simultaneous arbitrarily small squared tails.
  Scale2Facts: scale2(0)=1 and StrictMono scale2.
  Background: sourceFormula holds; zeros lie in the positive strip; both exact energies are strictly positive at zeros; both critical-line gains equal 1.
```

**Lean declaration:** `AWPI.PhiRH.LiteralModel.literalModel_constructorIffMathlibRHUnderBackground`

```lean
theorem literalModel_constructorIffMathlibRHUnderBackground
    {Jet : Type v}
    (state : ℂ → Jet)
    (energyPlus energyMinus : Jet → ℝ)
    (scale2 : ℝ → ℝ)
    (plusTailSource minusTailSource : ℕ → ℂ → ℝ)
    (sourceFormula : Prop)
    (v23 : NormalizedDyadicMultiplierFacts
      (literalZetaModel Jet state energyPlus energyMinus scale2
        plusTailSource minusTailSource sourceFormula))
    (scaleFacts : Scale2Facts
      (literalZetaModel Jet state energyPlus energyMinus scale2
        plusTailSource minusTailSource sourceFormula))
    (hB : Background
      (literalZetaModel Jet state energyPlus energyMinus scale2
        plusTailSource minusTailSource sourceFormula)) :
    Constructor
      (literalZetaModel Jet state energyPlus energyMinus scale2
        plusTailSource minusTailSource sourceFormula) ↔
      RiemannHypothesis
```

**Original source:** `snapshots/lean-native/awpi_phi_rh_lean_sieved_v0_1_1/AWPI/PhiRH/LiteralModel.lean:166`.

**Reported source SHA-256:** `497d1eac96c9f33acb0867a0033e3e8bff5123162f7222bc4901549929b9bd7b`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/497d1eac96c9f33acb0867a0033e3e8bff5123162f7222bc4901549929b9bd7b.lean#L166) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L940); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D066](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2115), [D067](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2121), [D068](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2132), [D069](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2144), [D070](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2167).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D066, D067, D068, D069, D070
```

</details>

<a id="e41"></a>

### E41 — Cofinal uniform positivity of the frozen raw-xi Widder tower

Group: **Cofinal uniform Widder positivity**. Original label: `NATIVE TARGET / ADDITIONAL INTERFACE HYPOTHESES`.

**Criterion (verbatim from the catalogue):**

For every K there is N>=K such that actualWidderMoment(a,N)>=0 for every a>0.

**Additional hypotheses (verbatim):**

```text
  hDown : ActualWidderDownwardPositivity
    Uniform positivity at depth n+1 implies uniform positivity at n for every n.
  hStieltjes : ActualWidderStieltjesSlitExclusion
    All-depth positivity implies every nontrivial zeta-zero centered square lies outside the slit plane.
  hReverse : RHImpliesAllDepthWidderPositive
    Mathlib RH implies all-depth positivity of this actual tower.
```

**Lean declaration:** `NativeSoloboloContinuant.US_IFF_MATHLIB_RH_05`

```lean
theorem US_IFF_MATHLIB_RH_05
    (hDown : ActualWidderDownwardPositivity)
    (hStieltjes : ActualWidderStieltjesSlitExclusion)
    (hReverse : RHImpliesAllDepthWidderPositive) :
    US ↔ RiemannHypothesis
```

**Original source:** `snapshots/downloads/RH_NATIVE_SOLOBOLO_US_IFF_RH_MERGER_04_v0_2_1_FIX1/Bridge/USIffRH05.lean:32`.

**Reported source SHA-256:** `5d563869b07ce7e2d0f437c69330d7605dec3fe38c829e0c2a213d77b5c2629f`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/5d563869b07ce7e2d0f437c69330d7605dec3fe38c829e0c2a213d77b5c2629f.lean#L32) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L980); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D074](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2193), [D075](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2198), [D076](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2203), [D077](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2208).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D074, D075, D076, D077
Note: This theorem is an equivalence architecture with three unprovided analytic interfaces.
Note: The source tower uses the frozen literal rawXi=s(s-1)*completedRiemannZeta s, not the regularized entire xi at s=0,1.
Note: US_IFF_PPC_05 and US_RH_PPC_EQUIVALENCE_ATLAS_05 are aliases/combination statements and not counted as new criteria.
```

</details>

## Opaque-model index — excluded from native RH equivalences

These entries use the opaque `RHGPBKQR.RiemannHypothesis` and source literature axioms. Their mathematical descriptions are preserved as evidence of the project architecture. Neither an “ActualXi” name nor an implemented generic energy lattice identifies that target with Mathlib RH.

| ID | Model criterion |
|---|---|
| [M01](#m01) | Zhang-normalized Hausdorff finite-difference positivity |
| [M02](#m02) | Zhang complete-monotonicity hierarchy |
| [M03](#m03) | Wall continued-fraction admissibility |
| [M04](#m04) | Subnormality of the canonical weighted shift |
| [M05](#m05) | Complete hypercontractivity of the canonical shift |
| [M06](#m06) | Positive Pascal-Hopf realization |
| [M07](#m07) | Natural-valued BKQR energy lattice |
| [M08](#m08) | Positive-stage finite-jet approximation |
| [M09](#m09) | Commuting two-branch energy source |
| [M10](#m10) | Finite positive-kernel approximation of the abstract Xi coefficient sequence |

## Opaque-model details

<a id="m01"></a>

### M01 — Zhang-normalized Hausdorff finite-difference positivity

Group: **Opaque model / literature-axiom target**. Original label: `OPAQUE MODEL / LITERATURE-AXIOM TARGET`.

**Criterion (verbatim from the catalogue):**

For the abstract integer sequence c=ZhangNormalizedCoeff, every signed finite difference (-1)^k Delta^k c_n is nonnegative.

**Additional hypotheses (verbatim):**

```text
  RHGPBKQR.Literature.Zhang2023.ZHANG2023_FRONTIER_ANCHOR : Zhang2023LiteraturePackage (axiom), whose rhIffHausdorff field supplies the RH equivalence.
  RHGPBKQR.RiemannHypothesis is a bodyless opaque Prop, not Mathlib _root_.RiemannHypothesis. ZhangNormalizedCoeff is defined from opaque ZhangCenteredXiCoeff, ReducedXiLogJetOf and ZhangScaleNormalize. No source-level identification of these objects with the actual analytic Xi data is supplied by the declarations cited here.
```

**Lean declaration:** `RHGPBKQR.Derivations.RH_IFF_HAUSDORFF`

```lean
theorem RH_IFF_HAUSDORFF : RiemannHypothesis ↔ HausdorffPositive
```

**Original source:** `snapshots/downloads/RH_GP_BKQR_OPERATION_ZHANG_FIREWALL_LEAN_v0_4_3_FIX1/Derivations/LiteratureFrontierDerivation.lean:10`.

**Reported source SHA-256:** `c6f94965ddb1cf33e1e38273bbe3e51d36b036e26ef24cac0b41d6e9bc78d726`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/c6f94965ddb1cf33e1e38273bbe3e51d36b036e26ef24cac0b41d6e9bc78d726.lean#L10) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1013); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D078](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2213), [D079](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2218), [D080](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2223), [D081](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2229), [D082](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2234).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D078, D079, D080, D081, D082
```

</details>

<a id="m02"></a>

### M02 — Zhang complete-monotonicity hierarchy

Group: **Opaque model / literature-axiom target**. Original label: `OPAQUE MODEL / LITERATURE-AXIOM TARGET`.

**Criterion (verbatim from the catalogue):**

The source comments describe existence of a derivative order m such that all G_k^(m) are completely monotone on (0,infinity); formally the entire criterion is the opaque Prop Zhang2022CompleteMonotonicityHierarchy.

**Additional hypotheses (verbatim):**

```text
  RHGPBKQR.Literature.Zhang2022.ZHANG2022_FRONTIER_ANCHOR : Zhang2022LiteraturePackage (axiom); rhIffCompleteMonotonicity field.
  RHGPBKQR.RiemannHypothesis is a bodyless opaque Prop, not Mathlib _root_.RiemannHypothesis. ZhangNormalizedCoeff is defined from opaque ZhangCenteredXiCoeff, ReducedXiLogJetOf and ZhangScaleNormalize. No source-level identification of these objects with the actual analytic Xi data is supplied by the declarations cited here.
```

**Lean declaration:** `RHGPBKQR.Derivations.RH_IFF_ZHANG2022_COMPLETE_MONOTONICITY`

```lean
theorem RH_IFF_ZHANG2022_COMPLETE_MONOTONICITY :
    RiemannHypothesis ↔ Zhang2022CompleteMonotonicityHierarchy
```

**Original source:** `snapshots/downloads/RH_GP_BKQR_OPERATION_ZHANG_FIREWALL_LEAN_v0_4_3_FIX1/Derivations/LiteratureFrontierDerivation.lean:14`.

**Reported source SHA-256:** `c6f94965ddb1cf33e1e38273bbe3e51d36b036e26ef24cac0b41d6e9bc78d726`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/c6f94965ddb1cf33e1e38273bbe3e51d36b036e26ef24cac0b41d6e9bc78d726.lean#L14) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1030); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D083](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2239), [D084](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2243).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D083, D084
Note: No formula defining G_k^(m), complete monotonicity, or its link to actual Xi is encoded in this opaque criterion. Comment-only mathematical interpretation is not counted as a formal definition.
```

</details>

<a id="m03"></a>

### M03 — Wall continued-fraction admissibility

Group: **Opaque model / literature-axiom target**. Original label: `OPAQUE MODEL / LITERATURE-AXIOM TARGET`.

**Criterion (verbatim from the catalogue):**

Wall/Sokal admissibility of the normalized Hausdorff continued fraction; represented only by opaque WallAdmissible.

**Additional hypotheses (verbatim):**

```text
  RHGPBKQR.Literature.Zhang2023.ZHANG2023_FRONTIER_ANCHOR : Zhang2023LiteraturePackage (axiom), whose rhIffHausdorff field supplies the RH equivalence.
  RHGPBKQR.RiemannHypothesis is a bodyless opaque Prop, not Mathlib _root_.RiemannHypothesis. ZhangNormalizedCoeff is defined from opaque ZhangCenteredXiCoeff, ReducedXiLogJetOf and ZhangScaleNormalize. No source-level identification of these objects with the actual analytic Xi data is supplied by the declarations cited here.
  RHGPBKQR.Literature.Sokal2020.HAUSDORFF_IFF_WALL_ANCHOR : HausdorffPositive <-> WallAdmissible (axiom).
```

**Lean declaration:** `RHGPBKQR.Derivations.RH_IFF_WALL`

```lean
theorem RH_IFF_WALL : RiemannHypothesis ↔ WallAdmissible
```

**Original source:** `snapshots/downloads/RH_GP_BKQR_OPERATION_ZHANG_FIREWALL_LEAN_v0_4_3_FIX1/Derivations/LiteratureFrontierDerivation.lean:52`.

**Reported source SHA-256:** `c6f94965ddb1cf33e1e38273bbe3e51d36b036e26ef24cac0b41d6e9bc78d726`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/c6f94965ddb1cf33e1e38273bbe3e51d36b036e26ef24cac0b41d6e9bc78d726.lean#L52) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1049); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D085](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2252).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D085
Note: A named opaque literature node, not an implemented continued fraction.
```

</details>

<a id="m04"></a>

### M04 — Subnormality of the canonical weighted shift

Group: **Opaque model / literature-axiom target**. Original label: `OPAQUE MODEL / LITERATURE-AXIOM TARGET`.

**Criterion (verbatim from the catalogue):**

Subnormality of the canonical weighted shift; represented only by opaque WeightedShiftSubnormal.

**Additional hypotheses (verbatim):**

```text
  RHGPBKQR.Literature.Zhang2023.ZHANG2023_FRONTIER_ANCHOR : Zhang2023LiteraturePackage (axiom), whose rhIffHausdorff field supplies the RH equivalence.
  RHGPBKQR.RiemannHypothesis is a bodyless opaque Prop, not Mathlib _root_.RiemannHypothesis. ZhangNormalizedCoeff is defined from opaque ZhangCenteredXiCoeff, ReducedXiLogJetOf and ZhangScaleNormalize. No source-level identification of these objects with the actual analytic Xi data is supplied by the declarations cited here.
  RHGPBKQR.Literature.BergerGellarWallen.HAUSDORFF_IFF_WEIGHTED_SHIFT_SUBNORMAL_ANCHOR (axiom).
```

**Lean declaration:** `RHGPBKQR.Derivations.RH_IFF_WEIGHTED_SHIFT_SUBNORMAL`

```lean
theorem RH_IFF_WEIGHTED_SHIFT_SUBNORMAL :
    RiemannHypothesis ↔ WeightedShiftSubnormal
```

**Original source:** `snapshots/downloads/RH_GP_BKQR_OPERATION_ZHANG_FIREWALL_LEAN_v0_4_3_FIX1/Derivations/LiteratureFrontierDerivation.lean:62`.

**Reported source SHA-256:** `c6f94965ddb1cf33e1e38273bbe3e51d36b036e26ef24cac0b41d6e9bc78d726`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/c6f94965ddb1cf33e1e38273bbe3e51d36b036e26ef24cac0b41d6e9bc78d726.lean#L62) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1068); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D086](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2256).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D086
Note: No actual weighted shift or subnormality predicate is defined at this literature node.
```

</details>

<a id="m05"></a>

### M05 — Complete hypercontractivity of the canonical shift

Group: **Opaque model / literature-axiom target**. Original label: `OPAQUE MODEL / LITERATURE-AXIOM TARGET`.

**Criterion (verbatim from the catalogue):**

Complete hypercontractivity of the canonical weighted shift; represented only by opaque WeightedShiftCompletelyHypercontractive.

**Additional hypotheses (verbatim):**

```text
  RHGPBKQR.Literature.Zhang2023.ZHANG2023_FRONTIER_ANCHOR : Zhang2023LiteraturePackage (axiom), whose rhIffHausdorff field supplies the RH equivalence.
  RHGPBKQR.RiemannHypothesis is a bodyless opaque Prop, not Mathlib _root_.RiemannHypothesis. ZhangNormalizedCoeff is defined from opaque ZhangCenteredXiCoeff, ReducedXiLogJetOf and ZhangScaleNormalize. No source-level identification of these objects with the actual analytic Xi data is supplied by the declarations cited here.
  RHGPBKQR.Literature.BergerGellarWallen.HAUSDORFF_IFF_WEIGHTED_SHIFT_SUBNORMAL_ANCHOR (axiom).
  RHGPBKQR.Literature.Agler1985.COMPLETE_HYPERCONTRACTIVE_IFF_SUBNORMAL_ANCHOR (axiom).
```

**Lean declaration:** `RHGPBKQR.Derivations.RH_IFF_COMPLETE_HYPERCONTRACTIVITY`

```lean
theorem RH_IFF_COMPLETE_HYPERCONTRACTIVITY :
    RiemannHypothesis ↔ WeightedShiftCompletelyHypercontractive
```

**Original source:** `snapshots/downloads/RH_GP_BKQR_OPERATION_ZHANG_FIREWALL_LEAN_v0_4_3_FIX1/Derivations/LiteratureFrontierDerivation.lean:73`.

**Reported source SHA-256:** `c6f94965ddb1cf33e1e38273bbe3e51d36b036e26ef24cac0b41d6e9bc78d726`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/c6f94965ddb1cf33e1e38273bbe3e51d36b036e26ef24cac0b41d6e9bc78d726.lean#L73) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1088); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D087](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2260).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D087
Note: The full complete-hypercontractivity definition and operator hypotheses are not encoded at this opaque literature node.
```

</details>

<a id="m06"></a>

### M06 — Positive Pascal-Hopf realization

Group: **Opaque model / literature-axiom target**. Original label: `OPAQUE MODEL / LITERATURE-AXIOM TARGET`.

**Criterion (verbatim from the catalogue):**

There exists an integer lattice v(n,k)>=0 with v(n,0)=c_n and v(n,k)=v(n+1,k)+v(n,k+1), for the canonical GP/Zhang coefficient sequence.

**Additional hypotheses (verbatim):**

```text
  RHGPBKQR.Literature.Zhang2023.ZHANG2023_FRONTIER_ANCHOR : Zhang2023LiteraturePackage (axiom), whose rhIffHausdorff field supplies the RH equivalence.
  RHGPBKQR.RiemannHypothesis is a bodyless opaque Prop, not Mathlib _root_.RiemannHypothesis. ZhangNormalizedCoeff is defined from opaque ZhangCenteredXiCoeff, ReducedXiLogJetOf and ZhangScaleNormalize. No source-level identification of these objects with the actual analytic Xi data is supplied by the declarations cited here.
```

**Lean declaration:** `RHGPBKQR.RH_IFF_PASCAL_HOPF_ANCHOR`

```lean
theorem RH_IFF_PASCAL_HOPF_ANCHOR :
    RiemannHypothesis ↔ PascalHopfAnchor
```

**Original source:** `snapshots/downloads/RH_GP_BKQR_OPERATION_ZHANG_FIREWALL_LEAN_v0_4_3_FIX1/Main.lean:24`.

**Reported source SHA-256:** `89fbb7a57af8d022502e9cb479107ffc13503e004a085a6b75640f35218063fa`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/89fbb7a57af8d022502e9cb479107ffc13503e004a085a6b75640f35218063fa.lean#L24) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1109); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D088](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2264), [D089](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2269).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D088, D089
Note: The core equivalence with finite-difference positivity is proved constructively. Hopf here denotes this algebraic Pascal splitting; it does not assert a topological Hopf fibration or a Hilbert realization.
```

</details>

<a id="m07"></a>

### M07 — Natural-valued BKQR energy lattice

Group: **Opaque model / literature-axiom target**. Original label: `OPAQUE MODEL / LITERATURE-AXIOM TARGET`.

**Criterion (verbatim from the catalogue):**

There exists E:Nat x Nat -> Nat with Int.ofNat(E(n,0))=c_n and E(n,k)=E(n+1,k)+E(n,k+1).

**Additional hypotheses (verbatim):**

```text
  RHGPBKQR.Literature.Zhang2023.ZHANG2023_FRONTIER_ANCHOR : Zhang2023LiteraturePackage (axiom), whose rhIffHausdorff field supplies the RH equivalence.
  RHGPBKQR.RiemannHypothesis is a bodyless opaque Prop, not Mathlib _root_.RiemannHypothesis. ZhangNormalizedCoeff is defined from opaque ZhangCenteredXiCoeff, ReducedXiLogJetOf and ZhangScaleNormalize. No source-level identification of these objects with the actual analytic Xi data is supplied by the declarations cited here.
```

**Lean declaration:** `RHGPBKQR.RH_IFF_BKQR_ENERGY_ANCHOR`

```lean
theorem RH_IFF_BKQR_ENERGY_ANCHOR :
    RiemannHypothesis ↔ BKQREnergyAnchor
```

**Original source:** `snapshots/downloads/RH_GP_BKQR_OPERATION_ZHANG_FIREWALL_LEAN_v0_4_3_FIX1/Main.lean:33`.

**Reported source SHA-256:** `89fbb7a57af8d022502e9cb479107ffc13503e004a085a6b75640f35218063fa`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/89fbb7a57af8d022502e9cb479107ffc13503e004a085a6b75640f35218063fa.lean#L33) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1128); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D090](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2277), [D091](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2282).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D090, D091
Note: BKQRGramData and BKQRContractionData are merely abbreviations of this energy lattice. No genuine inner-product space, operator norm, or topological completeness is supplied by this criterion.
```

</details>

<a id="m08"></a>

### M08 — Positive-stage finite-jet approximation

Group: **Opaque model / literature-axiom target**. Original label: `OPAQUE MODEL / LITERATURE-AXIOM TARGET`.

**Criterion (verbatim from the catalogue):**

There are stage sequences c_Y and nonnegative integer energies for every signed difference, and for each finite cutoff the target coefficients agree EXACTLY with c_Y at every sufficiently large stage.

**Additional hypotheses (verbatim):**

```text
  RHGPBKQR.Literature.Zhang2023.ZHANG2023_FRONTIER_ANCHOR : Zhang2023LiteraturePackage (axiom), whose rhIffHausdorff field supplies the RH equivalence.
  RHGPBKQR.RiemannHypothesis is a bodyless opaque Prop, not Mathlib _root_.RiemannHypothesis. ZhangNormalizedCoeff is defined from opaque ZhangCenteredXiCoeff, ReducedXiLogJetOf and ZhangScaleNormalize. No source-level identification of these objects with the actual analytic Xi data is supplied by the declarations cited here.
```

**Lean declaration:** `RHGPBKQR.RH_IFF_BKQR_TRACE_RESOLVENT_APPROX_ANCHOR`

```lean
theorem RH_IFF_BKQR_TRACE_RESOLVENT_APPROX_ANCHOR :
    RiemannHypothesis ↔ BKQRTraceResolventApproxAnchor
```

**Original source:** `snapshots/downloads/RH_GP_BKQR_OPERATION_ZHANG_FIREWALL_LEAN_v0_4_3_FIX1/Main.lean:63`.

**Reported source SHA-256:** `89fbb7a57af8d022502e9cb479107ffc13503e004a085a6b75640f35218063fa`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/89fbb7a57af8d022502e9cb479107ffc13503e004a085a6b75640f35218063fa.lean#L63) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1147); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D092](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2290), [D093](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2295).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D092, D093
Note: Despite trace-resolvent wording, the formal statement contains no matrices, resolvents, finite rank, measures, or analytic convergence. finiteJet is eventual exact equality on finite coefficient windows. Reverse construction uses the constant stage sequence.
```

</details>

<a id="m09"></a>

### M09 — Commuting two-branch energy source

Group: **Opaque model / literature-axiom target**. Original label: `OPAQUE MODEL / LITERATURE-AXIOM TARGET`.

**Criterion (verbatim from the catalogue):**

There exists a type Q, energy e:Q->Nat, base state omega and commuting maps L,R, with e(x)=e(Lx)+e(Rx) and Int.ofNat(e(L^n omega))=c_n for every n.

**Additional hypotheses (verbatim):**

```text
  RHGPBKQR.Literature.Zhang2023.RH_IFF_HAUSDORFF_ANCHOR : RiemannHypothesis <-> HausdorffPositive (direct axiom in this version).
  RHGPBKQR.RiemannHypothesis is a bodyless opaque Prop, not Mathlib _root_.RiemannHypothesis. ZhangNormalizedCoeff is defined from opaque ZhangCenteredXiCoeff, ReducedXiLogJetOf and ZhangScaleNormalize. No source-level identification of these objects with the actual analytic Xi data is supplied by the declarations cited here.
```

**Lean declaration:** `RHGPBKQR.Derivations.Minimal.RH_IFF_MINIMAL_CONSTRUCTION_ANCHOR`

```lean
theorem RH_IFF_MINIMAL_CONSTRUCTION_ANCHOR :
    RiemannHypothesis ↔ MinimalConstructionAnchor
```

**Original source:** `snapshots/downloads/RH_GP_BKQR_MINIMAL_ANCHOR_CHAIN_LEAN_v0_5_2_FIX2/Derivations/Minimal/RHChain.lean:27`.

**Reported source SHA-256:** `7989ffd956953e41e47a71e2dc7ca69169613f2c23f4996576ad025815328495`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/7989ffd956953e41e47a71e2dc7ca69169613f2c23f4996576ad025815328495.lean#L27) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1166); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D094](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2305), [D095](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2320).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D094, D095
Note: The reverse construction takes Q=Nat x Nat and the signed Hausdorff cells as energy. The arbitrary energy named normSq has no asserted norm or scalar-product laws. This is stronger structural packaging of the lattice, not an analytically identified GP/BKQR space.
```

</details>

<a id="m10"></a>

### M10 — Finite positive-kernel approximation of the abstract Xi coefficient sequence

Group: **Opaque model / literature-axiom target**. Original label: `OPAQUE MODEL / LITERATURE-AXIOM TARGET`.

**Criterion (verbatim from the catalogue):**

For each cutoff, sufficiently late finite probability kernels with nodes in [0,1] and real feature vectors have weighted moments sum_i w_i*x_i^n*f_i^2 exactly equal to the target integer coefficients, for every n up to that cutoff.

**Additional hypotheses (verbatim):**

```text
  RHGPBKQR.Literature.Zhang2023.ZHANG2023_FRONTIER_ANCHOR : Zhang2023LiteraturePackage (axiom), whose rhIffHausdorff field supplies the RH equivalence.
  RHGPBKQR.RiemannHypothesis is a bodyless opaque Prop, not Mathlib _root_.RiemannHypothesis. ZhangNormalizedCoeff is defined from opaque ZhangCenteredXiCoeff, ReducedXiLogJetOf and ZhangScaleNormalize. No source-level identification of these objects with the actual analytic Xi data is supplied by the declarations cited here.
  Explicit binder hRealize : TruncatedHausdorffFiniteKernelRealization, defined as HausdorffPositive -> ActualXiFiniteKernelApproxAnchor; reverse finite realization is an input, not proved here.
```

**Lean declaration:** `GPBKQRAnchoring01.RH_IFF_ACTUAL_XI_CONCRETE_PACKAGE`

```lean
theorem RH_IFF_ACTUAL_XI_CONCRETE_PACKAGE
    (hRealize : TruncatedHausdorffFiniteKernelRealization) :
    RHGPBKQR.RiemannHypothesis ↔ ActualXiConcreteTierAPackage
```

**Original source:** `snapshots/downloads/GP_BKQR_A_TIER_ANCHORING_01_LEAN_v0_2_0_CONCRETE_CALIBRATION/Anchors/ConcreteXiKernelRH.lean:20`.

**Reported source SHA-256:** `a1f8c0b9a573e952495c1259d3ee2d5fbb3c6a477b2d8765cd4eae7bb7a434a4`.

[Recovered source at the cited line](../research/upstream/rh-equivalences-corpus/a1f8c0b9a573e952495c1259d3ee2d5fbb3c6a477b2d8765cd4eae7bb7a434a4.lean#L20) — SHA-256 matches; archival source, outside the active build.

[Original entry and evidence](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1185); current status: `CATALOGUED_SOURCE_NOT_NATIVE_VERIFIED`.

Definition evidence: [D096](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2325), [D097](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2335), [D098](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2340), [D099](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2347), [D100](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2352), [D101](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2360).

<details>
<summary>Original notes, aliases and historical evidence</summary>

```text
Definition evidence: D096, D097, D098, D099, D100, D101
Note: The concrete finite kernel itself is implemented, but target c remains abstract ZhangNormalizedCoeff and RH remains opaque RHGPBKQR.RiemannHypothesis. ActualCompletedGolPhiXiBinding is an additional unconditional field, not an identification of c with native Xi coefficients. Forward implication requires no hRealize; the iff does.
```

</details>

## Definition-evidence index

All 115 original definition IDs are preserved in `catalog.json`. Each row links both the exact catalogue excerpt and its recovered source file. Empty original labels remain unnamed here rather than receiving an invented formal name.

| ID | Original label | Recovered definition |
|---|---|---|
| [D001](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1712) | (unnamed in original) | [Source, line 6](../research/upstream/rh-equivalences-corpus/09295fc8280d1d7c21a4d7fdc84ad4a34aa1aaa032aa970f5ee03e564808f42c.lean#L6) |
| [D002](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1717) | (unnamed in original) | [Source, line 13](../research/upstream/rh-equivalences-corpus/2bab627060b6fc622829da5d6c39fc88011ff4fe0b60b36c9d179659477d6619.lean#L13) |
| [D003](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1721) | (unnamed in original) | [Source, line 110](../research/upstream/rh-equivalences-corpus/2bab627060b6fc622829da5d6c39fc88011ff4fe0b60b36c9d179659477d6619.lean#L110) |
| [D004](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1728) | DerivativeNonnegative | [Source, line 60](../research/upstream/rh-equivalences-corpus/4d11fcd650f279c484bc008e3540ac5909f37bbf119466150763db7f44289488.lean#L60) |
| [D005](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1733) | angularDerivative | [Source, line 35](../research/upstream/rh-equivalences-corpus/4d11fcd650f279c484bc008e3540ac5909f37bbf119466150763db7f44289488.lean#L35) |
| [D006](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1738) | ActualInteriorSlopeNonnegative | [Source, line 45](../research/upstream/rh-equivalences-corpus/8717021731d80d28c228fdda18b1217524c5406fc7d2d17eae02fb212dd05d58.lean#L45) |
| [D007](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1744) | GlobalRegularLogSlopeNonnegative | [Source, line 41](../research/upstream/rh-equivalences-corpus/877e893ae983415adba18934897fe2d6b06fb9b513f5bdaa816a83f86a2a8b2f.lean#L41) |
| [D008](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1751) | logSlope | [Source, line 20](../research/upstream/rh-equivalences-corpus/4d274dc7c574860910f4d1e7145657398f84a14d17a7c1a9a4d07b6c47cdd6db.lean#L20) |
| [D009](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1757) | ProfileMaster | [Source, line 73](../research/upstream/rh-equivalences-corpus/4d11fcd650f279c484bc008e3540ac5909f37bbf119466150763db7f44289488.lean#L73) |
| [D010](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1762) | AngularMinimum | [Source, line 64](../research/upstream/rh-equivalences-corpus/4d11fcd650f279c484bc008e3540ac5909f37bbf119466150763db7f44289488.lean#L64) |
| [D011](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1768) | BoundaryNonnegative | [Source, line 69](../research/upstream/rh-equivalences-corpus/4d11fcd650f279c484bc008e3540ac5909f37bbf119466150763db7f44289488.lean#L69) |
| [D012](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1773) | LogMaster | [Source, line 77](../research/upstream/rh-equivalences-corpus/4d11fcd650f279c484bc008e3540ac5909f37bbf119466150763db7f44289488.lean#L77) |
| [D013](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1780) | masterLog | [Source, line 39](../research/upstream/rh-equivalences-corpus/4d11fcd650f279c484bc008e3540ac5909f37bbf119466150763db7f44289488.lean#L39) |
| [D014](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1785) | masterFlux | [Source, line 43](../research/upstream/rh-equivalences-corpus/4d11fcd650f279c484bc008e3540ac5909f37bbf119466150763db7f44289488.lean#L43) |
| [D015](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1791) | NormalizerPositive | [Source, line 56](../research/upstream/rh-equivalences-corpus/4d11fcd650f279c484bc008e3540ac5909f37bbf119466150763db7f44289488.lean#L56) |
| [D016](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1796) | frozenNormalizer | [Source, line 17](../research/upstream/rh-equivalences-corpus/01f08b70a0f458d145ea73f24f41c2895746ec2a9d62cc43fca70e6d714317ff.lean#L17) |
| [D017](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1800) | frozenLogMaster | [Source, line 20](../research/upstream/rh-equivalences-corpus/01f08b70a0f458d145ea73f24f41c2895746ec2a9d62cc43fca70e6d714317ff.lean#L20) |
| [D018](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1804) | AngularResidualNonnegative | [Source, line 71](../research/upstream/rh-equivalences-corpus/f0ea18f9520141e144c78e6fd0705891597cce9325c8367fafd996b16a26dcd9.lean#L71) |
| [D019](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1810) | CurvedAngularResidualNonnegative | [Source, line 304](../research/upstream/rh-equivalences-corpus/a8bf4702eebc50637f3d3da3923b0bc8f679c26e8b3ba5aa1c6f52d3afd18248.lean#L304) |
| [D020](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1817) | curvedCutoff | [Source, line 180](../research/upstream/rh-equivalences-corpus/a8bf4702eebc50637f3d3da3923b0bc8f679c26e8b3ba5aa1c6f52d3afd18248.lean#L180) |
| [D021](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1821) | AllSlopeQQRH | [Source, line 14](../research/upstream/rh-equivalences-corpus/6af86a8b5a7f4b328726fa8cb72008e688fd563efc42d63261d2d8e0e294b3d1.lean#L14) |
| [D022](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1826) | QQRH | [Source, line 36](../research/upstream/rh-equivalences-corpus/13f82914e544300589b55a873c0a92a3afd64cf8333c138729a8aabec1cd8df8.lean#L36) |
| [D023](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1832) | slopeCutoff | [Source, line 19](../research/upstream/rh-equivalences-corpus/13f82914e544300589b55a873c0a92a3afd64cf8333c138729a8aabec1cd8df8.lean#L19) |
| [D024](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1836) | CofinalSlopeQQRH | [Source, line 17](../research/upstream/rh-equivalences-corpus/6af86a8b5a7f4b328726fa8cb72008e688fd563efc42d63261d2d8e0e294b3d1.lean#L17) |
| [D025](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1841) | AllSlopePositivity | [Source, line 20](../research/upstream/rh-equivalences-corpus/6af86a8b5a7f4b328726fa8cb72008e688fd563efc42d63261d2d8e0e294b3d1.lean#L20) |
| [D026](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1847) | CutoffDerivativeNonnegative | [Source, line 75](../research/upstream/rh-equivalences-corpus/91ed83bfc2e204fc353eed6eb8b38d307afea123bf9735432ebc0bbfefcacd20.lean#L75) |
| [D027](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1853) | defect | [Source, line 14](../research/upstream/rh-equivalences-corpus/97eb8b3f62900fa4f06360876aa1b6ad7ef3344c642eac12a99ae09a34a39fc6.lean#L14) |
| [D028](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1859) | C | [Source, line 36](../research/upstream/rh-equivalences-corpus/26c77c57da1af753186e8273e114073c97016e2430cd61df20282a4aca778801.lean#L36) |
| [D029](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1868) | PositivityPremise | [Source, line 15](../research/upstream/rh-equivalences-corpus/daa274755e6d185d18741404c897207202c6e986731e8f7c958c70d53170fcd0.lean#L15) |
| [D030](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1873) | c1 | [Source, line 35](../research/upstream/rh-equivalences-corpus/26c77c57da1af753186e8273e114073c97016e2430cd61df20282a4aca778801.lean#L35) |
| [D031](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1883) | canonicalXi | [Source, line 69](../research/upstream/rh-equivalences-corpus/14c9de048e3b7147dd7ae6a383e1f89986c65296b8ed3f8f47beb0ed34d33766.lean#L69) |
| [D032](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1888) | centerCurvature | [Source, line 73](../research/upstream/rh-equivalences-corpus/14c9de048e3b7147dd7ae6a383e1f89986c65296b8ed3f8f47beb0ed34d33766.lean#L73) |
| [D033](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1893) | TraceIdentification | [Source, line 77](../research/upstream/rh-equivalences-corpus/14c9de048e3b7147dd7ae6a383e1f89986c65296b8ed3f8f47beb0ed34d33766.lean#L77) |
| [D034](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1898) | SmallOPremise | [Source, line 28](../research/upstream/rh-equivalences-corpus/003da021c92bddd75d9da140e997c2a05b1dc0c8bd4273e142b5d8e42548ca27.lean#L28) |
| [D035](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1904) | angularI | [Source, line 25](../research/upstream/rh-equivalences-corpus/8b47ffabfa07d1e6346665c5aa1a3fa102be916a8338512383ebaa51a5bb19c7.lean#L25) |
| [D036](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1910) | criticalLineCutoffTerm | [Source, line 62](../research/upstream/rh-equivalences-corpus/2d0a232a00a60a203507e14230dd4db8430413e629cd0930dfe2e0d47a093883.lean#L62) |
| [D037](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1917) | criticalLineCutoff | [Source, line 67](../research/upstream/rh-equivalences-corpus/2d0a232a00a60a203507e14230dd4db8430413e629cd0930dfe2e0d47a093883.lean#L67) |
| [D038](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1922) | MISTERPREMISE | [Source, line 26](../research/upstream/rh-equivalences-corpus/8d7863859e67a4a6067cdd7e76583e5de18bfef82af47f44e2fbcedef3abbfa2.lean#L26) |
| [D039](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1929) | factorThreshold | [Source, line 10](../research/upstream/rh-equivalences-corpus/2a6b9f3b4f067a6fb93bfbb98d52e3afb2a7bb9b93f8a2ef874fa432cd293ced.lean#L10) |
| [D040](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1934) | thresholdValues | [Source, line 13](../research/upstream/rh-equivalences-corpus/2a6b9f3b4f067a6fb93bfbb98d52e3afb2a7bb9b93f8a2ef874fa432cd293ced.lean#L13) |
| [D041](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1939) | kappa | [Source, line 18](../research/upstream/rh-equivalences-corpus/2a6b9f3b4f067a6fb93bfbb98d52e3afb2a7bb9b93f8a2ef874fa432cd293ced.lean#L18) |
| [D042](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1943) | TAYLORS_PRODIGY_PREMISE | [Source, line 115](../research/upstream/rh-equivalences-corpus/17d16a624b3e1a90f1769c307fe95953c712cc57acf140d82d18c60582caa265.lean#L115) |
| [D043](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1952) | H | [Source, line 30](../research/upstream/rh-equivalences-corpus/17d16a624b3e1a90f1769c307fe95953c712cc57acf140d82d18c60582caa265.lean#L30) |
| [D044](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1956) | F | [Source, line 33](../research/upstream/rh-equivalences-corpus/17d16a624b3e1a90f1769c307fe95953c712cc57acf140d82d18c60582caa265.lean#L33) |
| [D045](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1960) | STIRLINGS_PRODIGY_LOCAL | [Source, line 19](../research/upstream/rh-equivalences-corpus/d96c3185b575b5a0a79e63fb0bf79b5f93ce57615c21b4b0dbf6bf1a06c8e95c.lean#L19) |
| [D046](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1966) | LocalFirstOrderAt | [Source, line 23](../research/upstream/rh-equivalences-corpus/8fe0a68690ac366178f671850c1592032e3ce1c571d3d21c5254ec808f7fb7b7.lean#L23) |
| [D047](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1973) | CanonicalTwoDefectSigns | [Source, line 159](../research/upstream/rh-equivalences-corpus/b0b80b4872913e6da25b88146277f1216695987922b0c23be6940e7eb3ed7c1d.lean#L159) |
| [D048](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1981) | canonicalModel | [Source, line 29](../research/upstream/rh-equivalences-corpus/e9dbacd7b75ea2fb2469f90503faa53f9608ba33984f2ec4a1120e08e1ba1d9d.lean#L29) |
| [D049](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1993) | GlobalLiteralDyadicContraction | [Source, line 21](../research/upstream/rh-equivalences-corpus/4f77a537f64cc04e72e137c86708a192d1f339b572984b574f97e027ae7fd17d.lean#L21) |
| [D050](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2003) | dyadicScale | [Source, line 13](../research/upstream/rh-equivalences-corpus/91b95fa61cb63cc1e218bf8f96e8e582f8aa8a7a8601510d6cf1749c07077495.lean#L13) |
| [D051](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2008) | PlusPassivityCore | [Source, line 11](../research/upstream/rh-equivalences-corpus/caab68732cd28164148492b1fc68689e2761e886ddcf3ad6731399882735d44a.lean#L11) |
| [D052](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2014) | canonicalPlusExactDefect | [Source, line 19](../research/upstream/rh-equivalences-corpus/f5e6948f3afef9d09d3316387ad111fa4edafe9e1389086a85981b5ba636aff3.lean#L19) |
| [D053](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2020) | ActualPointwiseGPBKQRPlusPassivity | [Source, line 105](../research/upstream/rh-equivalences-corpus/6ce0910b3ca287225054554dc55c4bd69df614bee6a71a204d0a75d6ed5a390a.lean#L105) |
| [D054](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2025) | PointwiseGPBKQRPlusPassivityAt | [Source, line 37](../research/upstream/rh-equivalences-corpus/6ce0910b3ca287225054554dc55c4bd69df614bee6a71a204d0a75d6ed5a390a.lean#L37) |
| [D055](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2030) | plusDefect | [Source, line 29](../research/upstream/rh-equivalences-corpus/6ce0910b3ca287225054554dc55c4bd69df614bee6a71a204d0a75d6ed5a390a.lean#L29) |
| [D056](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2035) | forwardGain | [Source, line 25](../research/upstream/rh-equivalences-corpus/6ce0910b3ca287225054554dc55c4bd69df614bee6a71a204d0a75d6ed5a390a.lean#L25) |
| [D057](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2040) | scale2 | [Source, line 8](../research/upstream/rh-equivalences-corpus/6ce0910b3ca287225054554dc55c4bd69df614bee6a71a204d0a75d6ed5a390a.lean#L8) |
| [D058](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2044) | NontrivialZetaZero | [Source, line 8](../research/upstream/rh-equivalences-corpus/b518a4d864e68ed137b733e0107f93450fe54face8553f8122e947515865920c.lean#L8) |
| [D059](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2051) | CanonicalPlusExactTailUpper | [Source, line 25](../research/upstream/rh-equivalences-corpus/f5e6948f3afef9d09d3316387ad111fa4edafe9e1389086a85981b5ba636aff3.lean#L25) |
| [D060](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2059) | RawActualPlusKQFrontier | [Source, line 59](../research/upstream/rh-equivalences-corpus/0cf503df297a115c62b5fb274b4567b56ec93592f1c1e1b607b9ae23ae7b3a3f.lean#L59) |
| [D061](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2068) | ActualPlusKQLimitCore | [Source, line 18](../research/upstream/rh-equivalences-corpus/f03f029e135258710e00b4f1ab7d9a8d397182827473dba770707d55496391e2.lean#L18) |
| [D062](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2076) | altSign, phiBase, phiKernelRe/Im, phiCellRe/Im | [Source, line 13](../research/upstream/rh-equivalences-corpus/6c3235a029582cb6d5bfbf6838cce889e8035ab400b703c5a29dcdef34455def.lean#L13) |
| [D063](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2082) | ExistsCanonicalPlusFactorization | [Source, line 94](../research/upstream/rh-equivalences-corpus/30bf20868e466c50fe22e5d59b57ec5d523898fe0857516fd43e096c0ade7781.lean#L94) |
| [D064](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2092) | HistoricalPlusPointwiseSource | [Source, line 70](../research/upstream/rh-equivalences-corpus/655fff1004fdfd4fed378b41cd03fb2cf49758ea9657ace91062b751533a0c92.lean#L70) |
| [D065](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2106) | ExistsHistoricalPlusPointwiseSource | [Source, line 205](../research/upstream/rh-equivalences-corpus/655fff1004fdfd4fed378b41cd03fb2cf49758ea9657ace91062b751533a0c92.lean#L205) |
| [D066](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2115) | Scale2Facts | [Source, line 60](../research/upstream/rh-equivalences-corpus/eeaf46a7f04b59b5a9144646f22b50003d1510f68436f942dce44556a937ac50.lean#L60) |
| [D067](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2121) | NormalizedDyadicMultiplierFacts | [Source, line 66](../research/upstream/rh-equivalences-corpus/eeaf46a7f04b59b5a9144646f22b50003d1510f68436f942dce44556a937ac50.lean#L66) |
| [D068](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2132) | Background | [Source, line 76](../research/upstream/rh-equivalences-corpus/eeaf46a7f04b59b5a9144646f22b50003d1510f68436f942dce44556a937ac50.lean#L76) |
| [D069](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2144) | SourceConstructor | [Source, line 87](../research/upstream/rh-equivalences-corpus/eeaf46a7f04b59b5a9144646f22b50003d1510f68436f942dce44556a937ac50.lean#L87) |
| [D070](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2167) | Constructor | [Source, line 131](../research/upstream/rh-equivalences-corpus/eeaf46a7f04b59b5a9144646f22b50003d1510f68436f942dce44556a937ac50.lean#L131) |
| [D071](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2176) | (unnamed in original) | [Source, line 16](../research/upstream/rh-equivalences-corpus/89163b5577d49679590850ad761a6b872615ab0b06ae99549a0091f05b1bf81d.lean#L16) |
| [D072](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2183) | (unnamed in original) | [Source, line 63](../research/upstream/rh-equivalences-corpus/21e3bbf74b68d0b6466b6453f1de8a39e60b40f1eccf5c92bbe7d0750476fb3c.lean#L63) |
| [D073](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2188) | (unnamed in original) | [Source, line 72](../research/upstream/rh-equivalences-corpus/21e3bbf74b68d0b6466b6453f1de8a39e60b40f1eccf5c92bbe7d0750476fb3c.lean#L72) |
| [D074](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2193) | (unnamed in original) | [Source, line 7](../research/upstream/rh-equivalences-corpus/a2cfd9d637fd2b5ba18a8f1f8b21792be610f54a8a454d3a33171f22a11ebfa1.lean#L7) |
| [D075](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2198) | (unnamed in original) | [Source, line 15](../research/upstream/rh-equivalences-corpus/a2cfd9d637fd2b5ba18a8f1f8b21792be610f54a8a454d3a33171f22a11ebfa1.lean#L15) |
| [D076](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2203) | (unnamed in original) | [Source, line 27](../research/upstream/rh-equivalences-corpus/a0db1f9d7126cd7e36c76ba457df7033e56243c0760702e0f33d5d4699ced4bb.lean#L27) |
| [D077](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2208) | (unnamed in original) | [Source, line 44](../research/upstream/rh-equivalences-corpus/a0db1f9d7126cd7e36c76ba457df7033e56243c0760702e0f33d5d4699ced4bb.lean#L44) |
| [D078](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2213) | HausdorffPositive | [Source, line 61](../research/upstream/rh-equivalences-corpus/4382041c3ff53a35f563a56c67c43f110e64866968a4d84776876e1584497656.lean#L61) |
| [D079](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2218) | SequenceHausdorffPositive | [Source, line 57](../research/upstream/rh-equivalences-corpus/4382041c3ff53a35f563a56c67c43f110e64866968a4d84776876e1584497656.lean#L57) |
| [D080](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2223) | HausdorffDiff | [Source, line 48](../research/upstream/rh-equivalences-corpus/4382041c3ff53a35f563a56c67c43f110e64866968a4d84776876e1584497656.lean#L48) |
| [D081](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2229) | IntNonnegative | [Source, line 53](../research/upstream/rh-equivalences-corpus/4382041c3ff53a35f563a56c67c43f110e64866968a4d84776876e1584497656.lean#L53) |
| [D082](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2234) | ZhangNormalizedCoeff | [Source, line 44](../research/upstream/rh-equivalences-corpus/4382041c3ff53a35f563a56c67c43f110e64866968a4d84776876e1584497656.lean#L44) |
| [D083](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2239) | Zhang2022CompleteMonotonicityHierarchy | [Source, line 28](../research/upstream/rh-equivalences-corpus/9183fc4417c7ec7792d8b470225483d5462f23286b655db812fe56fc32a52139.lean#L28) |
| [D084](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2243) | Zhang2022LiteraturePackage | [Source, line 31](../research/upstream/rh-equivalences-corpus/9183fc4417c7ec7792d8b470225483d5462f23286b655db812fe56fc32a52139.lean#L31) |
| [D085](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2252) | WallAdmissible | [Source, line 6](../research/upstream/rh-equivalences-corpus/d7e0411ca0b95f82777c66e280cb03c5112ca3320ee998b996e4b6a767e5fddf.lean#L6) |
| [D086](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2256) | WeightedShiftSubnormal | [Source, line 6](../research/upstream/rh-equivalences-corpus/5dd2785a9e40078fedf1879f5eb1d39f75d5341cfe7becd17735453402846d58.lean#L6) |
| [D087](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2260) | WeightedShiftCompletelyHypercontractive | [Source, line 6](../research/upstream/rh-equivalences-corpus/974ea3230e8316c7b34c962a132973fab2a4555267aa16603adfe57d6da758c9.lean#L6) |
| [D088](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2264) | PascalHopfAnchor | [Source, line 252](../research/upstream/rh-equivalences-corpus/4382041c3ff53a35f563a56c67c43f110e64866968a4d84776876e1584497656.lean#L252) |
| [D089](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2269) | PositivePascalHopfData | [Source, line 134](../research/upstream/rh-equivalences-corpus/4382041c3ff53a35f563a56c67c43f110e64866968a4d84776876e1584497656.lean#L134) |
| [D090](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2277) | BKQREnergyAnchor | [Source, line 256](../research/upstream/rh-equivalences-corpus/4382041c3ff53a35f563a56c67c43f110e64866968a4d84776876e1584497656.lean#L256) |
| [D091](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2282) | BKQREnergyData | [Source, line 155](../research/upstream/rh-equivalences-corpus/4382041c3ff53a35f563a56c67c43f110e64866968a4d84776876e1584497656.lean#L155) |
| [D092](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2290) | BKQRTraceResolventApproxAnchor | [Source, line 264](../research/upstream/rh-equivalences-corpus/4382041c3ff53a35f563a56c67c43f110e64866968a4d84776876e1584497656.lean#L264) |
| [D093](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2295) | BKQRTraceResolventApproxData | [Source, line 195](../research/upstream/rh-equivalences-corpus/4382041c3ff53a35f563a56c67c43f110e64866968a4d84776876e1584497656.lean#L195) |
| [D094](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2305) | MinimalConstructionSource | [Source, line 19](../research/upstream/rh-equivalences-corpus/3c902b3ff04f4651e0037ecbd65488b7ab127ed0e1db2256eb2ed7a71ac5d994.lean#L19) |
| [D095](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2320) | MinimalConstructionAnchor | [Source, line 72](../research/upstream/rh-equivalences-corpus/3c902b3ff04f4651e0037ecbd65488b7ab127ed0e1db2256eb2ed7a71ac5d994.lean#L72) |
| [D096](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2325) | XiFiniteKernelApproxData | [Source, line 25](../research/upstream/rh-equivalences-corpus/b7c72a78e0b17cbd4bda56bc85656f0f0da4ed3b3047bdd1efe3bd297d321446.lean#L25) |
| [D097](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2335) | ActualXiFiniteKernelApproxAnchor | [Source, line 94](../research/upstream/rh-equivalences-corpus/b7c72a78e0b17cbd4bda56bc85656f0f0da4ed3b3047bdd1efe3bd297d321446.lean#L94) |
| [D098](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2340) | ActualXiConcreteTierAPackage | [Source, line 99](../research/upstream/rh-equivalences-corpus/b7c72a78e0b17cbd4bda56bc85656f0f0da4ed3b3047bdd1efe3bd297d321446.lean#L99) |
| [D099](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2347) | TruncatedHausdorffFiniteKernelRealization | [Source, line 141](../research/upstream/rh-equivalences-corpus/b7c72a78e0b17cbd4bda56bc85656f0f0da4ed3b3047bdd1efe3bd297d321446.lean#L141) |
| [D100](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2352) | FiniteProbability | [Source, line 73](../research/upstream/rh-equivalences-corpus/31329943233cc07a1bf5653b263fa7225ca70528b2f70838ddbd70f3d133fe07.lean#L73) |
| [D101](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2360) | weightedMoment | [Source, line 96](../research/upstream/rh-equivalences-corpus/cbcd766321a9b084fdd2cc2ab35551b00ef502bf1a6ffb53891d4b98cf1543c4.lean#L96) |
| [D102](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2366) | PositivityPremise.ZeroData | [Source, line 19](../research/upstream/rh-equivalences-corpus/26c77c57da1af753186e8273e114073c97016e2430cd61df20282a4aca778801.lean#L19) |
| [D103](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2378) | PositivityPremise.ZetaBinding | [Source, line 29](../research/upstream/rh-equivalences-corpus/14c9de048e3b7147dd7ae6a383e1f89986c65296b8ed3f8f47beb0ed34d33766.lean#L29) |
| [D104](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2387) | PositivityPremise.CanonicalZetaBinding | [Source, line 39](../research/upstream/rh-equivalences-corpus/14c9de048e3b7147dd7ae6a383e1f89986c65296b8ed3f8f47beb0ed34d33766.lean#L39) |
| [D105](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2393) | ZHANG2023_FRONTIER_ANCHOR | [Source, line 34](../research/upstream/rh-equivalences-corpus/f7f3f30179925f2ce7f640020cc452cfb18b4e18e055f0641e647fba98ea0ee9.lean#L34) |
| [D106](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2397) | ZHANG2022_FRONTIER_ANCHOR | [Source, line 47](../research/upstream/rh-equivalences-corpus/9183fc4417c7ec7792d8b470225483d5462f23286b655db812fe56fc32a52139.lean#L47) |
| [D107](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2401) | HAUSDORFF_IFF_WALL_ANCHOR | [Source, line 18](../research/upstream/rh-equivalences-corpus/d7e0411ca0b95f82777c66e280cb03c5112ca3320ee998b996e4b6a767e5fddf.lean#L18) |
| [D108](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2406) | HAUSDORFF_IFF_WEIGHTED_SHIFT_SUBNORMAL_ANCHOR | [Source, line 18](../research/upstream/rh-equivalences-corpus/5dd2785a9e40078fedf1879f5eb1d39f75d5341cfe7becd17735453402846d58.lean#L18) |
| [D109](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2411) | COMPLETE_HYPERCONTRACTIVE_IFF_SUBNORMAL_ANCHOR | [Source, line 18](../research/upstream/rh-equivalences-corpus/974ea3230e8316c7b34c962a132973fab2a4555267aa16603adfe57d6da758c9.lean#L18) |
| [D110](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2416) | RH_IFF_HAUSDORFF_ANCHOR | [Source, line 69](../research/upstream/rh-equivalences-corpus/ef49e69d06211efb52b78b33ca632d056fbb139e378169a14bba81a67f387838.lean#L69) |
| [D111](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2421) | RiemannHypothesis | [Source, line 4](../research/upstream/rh-equivalences-corpus/4382041c3ff53a35f563a56c67c43f110e64866968a4d84776876e1584497656.lean#L4) |
| [D112](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2425) | ReducedXiLogJetOf | [Source, line 15](../research/upstream/rh-equivalences-corpus/4382041c3ff53a35f563a56c67c43f110e64866968a4d84776876e1584497656.lean#L15) |
| [D113](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2429) | ZhangCenteredXiCoeff | [Source, line 18](../research/upstream/rh-equivalences-corpus/4382041c3ff53a35f563a56c67c43f110e64866968a4d84776876e1584497656.lean#L18) |
| [D114](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2433) | ZhangScaleNormalize | [Source, line 41](../research/upstream/rh-equivalences-corpus/4382041c3ff53a35f563a56c67c43f110e64866968a4d84776876e1584497656.lean#L41) |
| [D115](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L2437) | CanonicalGPNormalizedCoeff | [Source, line 84](../research/upstream/rh-equivalences-corpus/4382041c3ff53a35f563a56c67c43f110e64866968a4d84776876e1584497656.lean#L84) |

## Related material preserved without increasing the iff count

| Original section | Scope |
|---|---|
| [Part III](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1206) | Local zero detectors, energy/duality/variation equivalences, generic Pascal and cofinality bridges. These do not independently supply an RH iff. |
| [Part IV](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1397) | One-way sufficient theorems with their explicit analytic, growth, calibration or model inputs. |
| [Part V](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1661) | RR defect as half an L² distance squared; the same E23/E24 zero-data mechanism, without a historical GP isometry or finite algorithm. |
| [Part VI](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt#L1687) | Aliases, normalizations and missing object identifications. |

## Normalization and finite-witness boundary

The native entire normalization is `ξ(s) = (1 + s(s−1)completedRiemannZeta₀(s))/2`. The critical-line pullback is `Ξ(z) = ξ(1/2 + i z)` and the theta descent is `Θ(z) = ξ(1/2 + sqrt(z))`. Raw `s(s−1)Λ(s)`, entire `2ξ(s)`, and `ξ(s)` must retain their endpoint conventions. E41 explicitly uses the frozen raw-xi tower and three additional interfaces.

For E27, the catalogue cutoff is exactly `‖actualPairZero i‖ ≤ 1/r` with real representatives; their norm is the critical-line ordinate. It must not be changed to `1/√r`. E25/E26 retain trace identification; E40 retains its calibrated background. The existential data in E38/E39 are infinite functional families, not serialized finite witnesses.

The repository’s next step remains deriving the actual induction BASE and analytic transfer from checkable finite data. The catalogue supplies candidate endpoints and their precise source obligations; it does not discharge that step. See [the finite-witness frontier](../docs/FRONTIER.md) and [the GP construction boundary](../docs/GP_CONSTRUCTION.md).
