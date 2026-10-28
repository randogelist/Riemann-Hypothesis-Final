# Archived-source review: finite witnesses and actual ξ calibration

Date: 2026-10-27. Status: **source inspection only; no Lean, Lake, CI, or archived script was executed.** The original archive review did not change `output/`; its reviewed sources were subsequently assembled into the v0.2.0 construction package.

## Current composition update

After the initial archive review, `ActualMomentReality.lean` supplied a candidate proof of unconditional all-order reality of the exact current moments. `CanonicalBridge.lean` then supplied canonical normalized mass one and the normalized zeroth power sum, and filled the reality argument of the intermediate adapter. The current composite constructor therefore has only `CanonicalPowerSums` as its remaining calibration input. Its positive-order cases remain open. The ordinary-limit and semantic RH criteria additionally retain `DominantExtraction (canonicalCalibration hpower)`. All these new sources are uncompiled candidates; no finite raw format, terminating checker, checker soundness, or checker completeness has been constructed.

## Findings

1. **No genuine finite raw witness plus terminating acceptance checker with actual-RH soundness and RH-to-accepted-witness completeness was found in the bounded archive scan.** Several genuine RH equivalences were found, but their other sides are universal analytic propositions. Several objects named “witness” or “finite certificate” contain infinite functions or proof fields.
2. **There is substantial reusable actual-ξ calibration source.** The GIGGA archive contains an unconditional complex-scale product for the exact `AWPIRH.theta` used by the current Hilbert branch, absolute summability, actual-zero soundness and divisor exhaustion, origin nonvanishing, and the exact first logarithmic trace. The sources also support an unconditional proof that the current `actualKappa` is positive.
3. **This does not yet construct `ActualSpectralCalibration` unconditionally.** The initial adapter takes two explicit moment hypotheses. The subsequent `CanonicalBridge` fills all-order reality and leaves only the all-order power-sum identities as a calibration input; its zeroth case is supplied independently. Neither the positive-order identities, `DominantExtraction`, nor finite-checker completeness has been supplied.

## Scope and method

The priority archives were inspected at declaration, definition, and proof-body level. A bounded index scan of the Lean and Rocq source members in the available ZIPs deduplicated 435 distinct source bodies. It identified 31 declaration-name candidates involving witness/certificate/packet/checker/accept/verify/raw; inspection found no accepted finite packet mechanism. An additional `Bool`/`bool` source search found 11 non-comment hits, all involving a two-element opposite-pair index, not a checker return type. These searches support the negative retrieval finding; they are not a proof that no conceivable encoding could be hidden under unrelated names. The `.rar` archive was outside this ZIP scan.

No success label or package filename was treated as proof. Archived native receipts have not been independently reconstructed or verified in this review.

## Priority sources and exact boundaries

### A-TIER-RH-EQUIVALENCE

Archive: `project_sources/14-A-TIER-RH-EQUIVALENCE.zip`.

SHA256: `30ff368e1a2ac7865d6687d4ee09224d4bef8dcf7a545397af34651a01d25d6e`.

Root: `GP_BKQR_CAYLEY_RH_A_TIER_CLOSURE_LEAN_v0_4_2_FIX2`.

The strongest directly reusable literal-RH equivalence reviewed is:

```lean
CayleyRHAClosure.ZETA_CAYLEY_ZERO_LOSS_IFF_MATHLIB_RH :
  ZetaCayleyZeroLoss ↔ _root_.RiemannHypothesis
```

`CayleyRHClosure.lean:54–55` defines:

```lean
def ZetaCayleyZeroLoss : Prop :=
  ∀ s : ℂ, CayleyGolPhi.NontrivialZetaZero s → spectralCayleyLoss s = 0
```

The proof at lines 84–94 transfers the literal native zero predicate and applies the pointwise theorem `spectralCayleyLoss s = 0 ↔ s.re = 1/2`. `spectralCayleyLoss` is a noncomputable real square of the constructed Cayley coordinate. Nonnegativity of this square at arbitrary points does not establish that it vanishes at zeta zeros.

`CayleyGolPhi/ZeroEquivalence.lean` also contains actual completed-function/ζ zero transfer, including `NONTRIVIAL_GOLPHI_ZERO_IFF_NONTRIVIAL_ZETA_ZERO` and `GOLPHI_RH_IFF_MATHLIB_RH`.

**Boundary:** the equivalence is genuine as a source theorem with no displayed extra premise, but its left side universally quantifies all complex nontrivial zeros. It is not an existential over finite raw data and not a terminating checker.

### SOLOBOLO v0.18.3

Archive: `project_sources/02-RH_NATIVE_SOLOBOLO_LEAN_v0_18_3_EXPLICIT_ANALYTIC_COMP_ARGS-1-.zip`.

SHA256: `d6e4813d83ed681d2263448d6222a3903a60e46e19a6219ccff8f1bad17621f4`.

`Core/Observable.lean` defines `CenteredXiGeometry` with an arbitrary `Zero : Type`, real coordinate functions, and a nonzero-height proof. Its `NativeSolobolo.RiemannHypothesis X` is `∀ z, X.beta z = 0`, not the root Mathlib predicate.

`Core/MathlibXiSlitTheta.lean` defines literal native completed ξ and its square descent, but `mathlibSlitThetaData` still takes a geometry `X` and a proof that each of its designated zeros is an actual descended-ξ zero.

`Frontier/OurFrontier.lean` uses:

- `CayleyMomentCodec`: a decoder accepting a whole `Nat → Scalar` stream;
- `GPTransferMomentModel`: an infinite moment function and a reconstruction proof;
- `BKQRCayleyModel`: infinite Widder coefficient/vector functions and reconstruction/square proofs;
- `GPBKQRCommonMomentIdentity`: equality of all moments;
- `GPBKQRCommonMomentFrontier`: existential quantification over these objects.

`ACTUAL_CAYLEY_AND_COMMON_MOMENT_FRONTIER_IMPLIES_RH` consumes that frontier and yields the geometry-relative RH. The contractive-orbit and cofinal-energy branches likewise carry infinite functions and universal bounds. No finite raw serialization, terminating validation function, or literal-RH completeness theorem was located.

### Native zero binding

Archive: `project_sources/20-awpi_phi_rh_native_zero_binding_v0_24_0-1-.zip`.

SHA256: `47944fa7674382dce1f68560cad543cf8132c2e9e210820e8b0dd0d2904a0465`.

This archive contains Rocq `.v` files, not Lean source. `AWPI_RH/RH66_ConcreteZetaZeroInterface.v:23–25` defines:

```coq
Record CPairZetaModel : Type := {
  zeta_cpair_value : R -> R -> CPair
}.
```

`PHIRH244_NATIVE_SPECTRAL_RH_IFF_CONCRETE_INTERFACE_RH` is quantified over arbitrary `M : CPairZetaModel`. Its proof transports coordinates between two interfaces to the same supplied predicate. The source does not identify `zeta_cpair_value` with Mathlib's literal ζ. It supplies neither a Lean import nor a raw checker.

### Positivity premise

Archive: `project_sources/39-RH_POSITIVITY_PREMISE_LEAN_v0_1_1_FASTSTART.zip`.

SHA256: `fe7dfa8e6553c26faff3bcbe104575d832ac0abfdffe223c8f7886fda16bfbfe`.

`Scalar.lean` defines

```lean
PositivityPremise C c1 :=
  ∀ T : ℝ, 1 ≤ T → 0 ≤ C ∧ C ≤ 3*c1/(4*T^2)
```

and proves its equivalence to `C = 0` when `0 ≤ c1`. The hypothesis concerns all heights. A fixed-height counterexample in the same source shows why a single finite bound does not imply zero defect.

`Series.lean`'s `ZeroData` includes infinite multiplicity/location functions and summability proofs. `LiteralZeta.lean`'s `ZetaBinding D` includes actual-zero soundness, coordinate identification, and exhaustive coverage; `CanonicalZetaBinding` additionally includes injectivity and multiplicity identification. These bindings are not constructed in this package. `TraceIdentification D` is also an explicit input.

Accordingly:

```lean
POSITIVITY_PREMISE_IFF_RH (B : ZetaBinding D) :
  PositivityPremise D.C D.c1 ↔ RiemannHypothesis
```

and the curvature variants are conditional on the displayed binding/trace inputs. They do not supply the requested finite witness or completeness.

### Other nominal certificates found by the bounded scan

`08-RH_GP_EXACT_LEDGER_ADAPTER_LEAN_v0_1_0-1-.zip`, `RHGPNativeM7PaymentCertificate.lean:1495–1507`, defines `M7BKQROneStepPaymentCertificate` with `storage payment : ℕ → ℝ` and inequalities for every `n`. Its package requires such a certificate for every putative collision opening. It is an infinite function/proof structure, not a finite raw packet.

`22-awpi_phi_rh_shifted_slice_transversality_v0_18_1-2-.zip` contains `awpi_phi_rh_reverse_closure_v0_12_1.v`. Lines 192–201 define `ExistsFiniteEnergyTailCertificate` by existentially quantifying five real-valued functions, four of type `nat → SpectralPoint → R`, and then requiring a factorization proposition. Lines 233–245 prove:

```coq
ActualPhiKQActivity ->
  (RH_critical_line <-> ExistsFiniteEnergyTailCertificate).
```

The section also has arbitrary `is_zero`, `JetState`, and energy maps. The reverse construction sets “finite energy” equal to the whole actual energy and tail/remainder equal to zero. This is an exact abstract equivalence under activity, but not finite data, not a terminating checker, and not a literal-Mathlib-RH theorem.

## Actual ξ calibration source

### Provenance and compatibility

Primary archive: `project_sources/36-RH_GIGGA_SMALL_O_EQUIVALENCE_LEAN_v0_2_0-1-1-.zip`.

SHA256: `8fac3ebc0d2509622b88501ff77a6c6d0bcb6055508dfadcc035dcc4090e6fa5`.

The earlier `31-RH_ANGULAR_MASTER_CHAIN_v0_3_0-2-.zip` contains the same core complex-scale source. Its archive SHA256 is `f6f5df99cc77321ae04cfe3e7e8a7d176f3ed2d5999af87e31636233a93c552b`.

Both archive 36 and current v0.1.4 specify `leanprover/lean4:v4.33.0`. The following files are byte-identical between archive 36 and the current branch:

| Module | SHA256 |
|---|---|
| `AWPIRH.XiCore` | `6bda1a14b59a508811b9f9a8bff400ed824d86f366b2ddeecd728571be7fd9db` |
| `AWPIRH.ThetaEntire` | `cb1f0838f2d90a1ba30e696afd05337e721ee7cc7e021a30ec28cdf2f810533b` |

Thus the retrieved product and trace statements address the same source functions, with no normalization conversion needed. No hidden RH parameter occurs in `actualPairZero` or `actualComplexScale`: the former is an actual canonical opposite-pair divisor representative, and the latter is its complex square. The separate theorem replacing this complex square by its positive real norm square explicitly requires RH and is not used in the unconditional route.

### Exact relevant source statements

Let `I := AngularMaster.ActualPairIndex`, and `a i := AngularMaster.actualComplexScale i`.

| Source | Declaration and content |
|---|---|
| `AngularMaster/ActualHadamard.lean:58–74` | Defines `ActualPairIndex`, `actualPairZero`; proves nonzero locations and summability of inverse squared norms from constructed actual zero distribution. These line numbers refer to the trimmed copy in archive 36. |
| `AngularMaster/ComplexScaleProduct.lean:19–35` | `a i = (actualPairZero i)^2`, `a i ≠ 0`, and `Summable (fun i => ‖(a i)⁻¹‖)`. |
| Same, 44–61 | `actual_theta_complex_factorization`: unconditional actual θ factorization, initially including the possible origin monomial. |
| Same, 64–68 | `actual_theta_neg_complexScale_zero`: `AWPIRH.theta (-a i) = 0`. |
| Same, 77–86 | `actual_theta_conj`: Schwarz reflection for the exact θ. |
| `OriginTrace.lean:61–74` | `actual_theta_zero_ne_zero` and `actual_originMultiplicity_eq_zero`. |
| Same, 77–87 | `actual_theta_normalized_complex_factorization`: `θ z = θ 0 * ∏' i, (1 + z/a i)`. |
| Same, 90–99 | `actual_theta_origin_logDeriv_eq_tsum`: `deriv θ 0 / θ 0 = ∑' i, (a i)⁻¹`. |
| Same, 102–112 | Absolute real trace summability and `actual_theta_origin_real_trace`. |
| `CanonicalDivisor.lean:263–271` | `entireXiPullbackZeroOccurrenceLoc_exhaustive`: every nonzero actual pullback zero occurs in the multiplicity index. |
| `CanonicalProductPairedGrowth.lean:55–62` | Constructs the opposite-pair equivalence from the actual zero-negation involution, with no RH input. |
| `UnconditionalLagariasEquivalence.lean:27–40` | Constructs the canonical quotient-growth and Hadamard log-derivative data from actual θ/Jensen growth results. |
| `HadamardLogDerivativeCriterion.lean:400–403` | For that data, origin multiplicity is nonzero or the occurrence index is nonempty. Combined with `actual_originMultiplicity_eq_zero`, this yields a nonempty pair index. |
| `AngularMaster/LowHeightGeometry.lean:51–58` | A bound `1 < |s.im|` at every actual ξ zero gives `-Re(a i)/‖a i‖ ≤ -3/5`. |
| `AngularMaster/ZeroFreeSeed.lean:117–127` | Supplies that low-height exclusion unconditionally. |
| `NativeClosure.lean:26–34` | `RHSmallO.spectralWeight_pos` derives `0 < Re((a i)⁻¹)` from these last two results. |

The inverse-scale summability, paired divisor construction, and normalized product are complex-valued. They do not silently replace the actual off-line zero geometry by real scales.

### Effect on the current calibration fields

The natural node is `q i = ((actualKappa : ℂ) * a i)⁻¹`, and then `rootOfNode actualKappa (q i) = -a i` once κ is known positive.

| Current field | Retrieved evidence / remaining work |
|---|---|
| `kappa_pos` | The exact first real trace, nonempty actual divisor, and positive summable reciprocal real parts give the no-extra-hypothesis candidate `actualKappa_pos` in the adapter. |
| `node_ne_zero` | Candidate `canonicalNode_ne_zero` uses κ positivity and `actualComplexScale_ne_zero`. |
| `norm_summable` | Candidate `canonicalNode_norm_summable` scales `actualComplexScale_norm_inv_summable` by the constant norm of κ's complex inverse. |
| `root_zero` | Candidate `canonicalNode_root_zero` uses existing `actual_theta_neg_complexScale_zero` and the exact candidate normalization `canonicalNode_root_eq`. |
| `covers` | Candidates `actualTheta_zero_has_canonical_scale` and `canonicalNode_covers` use exhaustive actual occurrence indexing, opposite pairing, square descent, and the same normalization. |
| `moment_real` for every n | Subsequently supplied in candidate `ActualMomentReality.lean`, using Schwarz reflection transported through total iterated derivatives. No RH, calibration, or power-sum premise is used. |
| `power_sums` for every n | The archive supplies the unnormalized first trace; `CanonicalBridge.lean` subsequently proves normalized node mass one and the normalized n=0 case. The positive-order differentiated-product/power-series identities for the current factorial/sign convention remain open. |

The equality needed for all orders is

`actualComplexMoment n = ∑' i, (a i)⁻¹ ^ (n+1)`.

Its local-uniform differentiation justification and the exact `(-1)^n / n!` normalization are substantive remaining tasks. The first-trace theorem alone does not imply these identities in Lean. The Taylor/Stirling archive frontends do not supply a matching all-order logarithmic-moment theorem.

### Materialized minimal existing-module closure

Directory: `tmp/witness_equivalence_review/calibration_source/`.

Roots: `OriginTrace` and `AngularMaster.LowHeightGeometry`.

- **71 local modules**, 812,866 source bytes.
- **74 distinct direct Mathlib imports at the external boundary**; this is not a count of Mathlib's fully resolved transitive closure.
- No missing non-Mathlib import.
- All extracted source bytes are unchanged archive members.
- `source_manifest.json` records the archive SHA256, every member SHA256 and size, and the complete local import graph.
- The closure contains the two current byte-identical AWPIRH modules, so reuse would add 69 archived modules rather than replacing those existing source bytes.
- Importing `OriginTrace` and the whole `NativeClosure` instead would require 79 local modules / 845,560 bytes. The smaller closure already suffices to repeat the short positive-reciprocal proof.

A lexer-style source scan removed nested Lean block comments, line comments, and double-quoted strings, then checked `sorry`, `admit`, `sorryAx`, `axiom`, `unsafe`, `native_decide`, and `constant`/`opaque` declarations. **No hits were found in the 71-module closure.** This is a bounded lexical result, not elaboration, kernel checking, or an imported-axiom audit.

### Draft adapter

File: `tmp/witness_equivalence_review/ActualCalibrationProgress.lean`.

It imports current `RH_HilbertLimit.ActualXi`, archived `OriginTrace`, and archived `AngularMaster.LowHeightGeometry`. It contains twelve candidate theorems, all with no new analytic hypotheses:

1. `actualComplexMoment_zero_eq_canonical_trace`;
2. `actualKappa_eq_canonical_trace`;
3. `actualPairIndex_nonempty`;
4. `actualInverseScale_re_pos`;
5. `actualKappa_pos`;
6. `actualTheta_zero_has_canonical_scale`;
7. `canonicalNode_ne_zero`;
8. `canonicalNode_eq_inverseScale_mul`;
9. `canonicalNode_norm_summable`;
10. `canonicalNode_root_eq`;
11. `canonicalNode_root_zero`;
12. `canonicalNode_covers`.

It defines the literal `canonicalNode i := ((actualKappa : ℂ) * actualComplexScale i)⁻¹` and the following explicitly conditional analytic constructor:

```lean
def canonicalCalibration_of_moment_identities
    (hmoment_real : ∀ n, (actualComplexMoment n).im = 0)
    (hpower_sums : ∀ n, HasSum
      (fun i : AngularMaster.ActualPairIndex => canonicalNode i ^ (n + 1))
      (actualNormalizedMoment n : ℂ)) :
    ActualSpectralCalibration AngularMaster.ActualPairIndex
```

All other fields are filled by the no-extra-hypothesis candidate proofs above. The constructor is not advertised as a finite witness or as a proof of its two inputs.

The positivity proof bounds the full nonnegative summable real trace below by one strictly positive actual zero contribution. The coverage proof lifts a θ zero through `-I * sqrt z`, uses canonical occurrence exhaustion, and removes the sign of the opposite-pair representative by squaring. Both routes use literal actual ξ data.

### Build ordering and audit preparation

`calibration_order.txt` contains a checked topological order of the 69 new archived `.lean` files, excluding the two duplicate baseline AWPIRH files. It does not include the new adapter: the adapter must be compiled after both this closure and current `RH_HilbertLimit.ActualXi`.

`calibration_audit_targets.tsv` uses the runner's existing `module|fully.qualified.declaration` format. It contains 129 targets: 115 archived declarations, with at least one public theorem per new archived module, plus all 14 public declarations of the new adapter (12 theorems and 2 definitions). The selected archived extras prioritize actual divisor exhaustion, summability, constructed unconditional analytic data, factorization, first trace, and low-height exclusion. Adapter entries use the intended installed module name `RH_HilbertLimit.ActualCalibrationProgress`.

`calibration_audit_provenance.json` records each selected declaration's source line, module, member identity, and SHA256. `calibration_declarations.json` records the broader exact-name namespace index used to make the selection. Namespace tracking reported no mismatched scopes; anonymous `noncomputable section` scopes correctly extend to end of file. This is static name extraction, not verification that Lean elaborates every declaration.

**Validation boundary:** these are source-reviewed, uncompiled candidates. They must not be labeled native PASS. The two-input adapter is an intermediate interface; the subsequent composite constructor fills reality and retains only `CanonicalPowerSums`. Dominant extraction remains the other analytic input to the composite limit and criteria. No finite raw witness, terminating checker, RH-to-accepted-witness completeness, or unconditional RH is delivered by this review.
