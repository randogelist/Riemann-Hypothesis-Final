# Supplied-source audit for Riemann-Hypothesis-Final

Static source inspection only, 2026-10-25. No Lean compilation was run. Existing receipts below are inherited evidence, not fresh passes.

## Main finding

The supplied packages contain useful actual-xi bridges, concrete positivity-preserving model inductions, and finite arithmetic admission examples. They do **not** contain a complete terminating finite raw-data checker whose acceptance derives an actual-xi SOLOBOLO input uniformly over all orders. No `SOLOBOLO`, `STURMION`, or Cayley–Sturm-named declaration was found in the extracted top-level Lean sources. The separate SOLOBOLO sources were subsequently recovered; see SOLOBOLO_AUDIT.md.

## RH_FIVE_INDUCTION_LEAN_v0_3_0

Root: `inspected_sources/16-RH_FIVE_INDUCTION_LEAN_v0_3_0-1-/RH_FIVE_INDUCTION_LEAN_v0_3_0/`.

- `FiveInduction/ActualXi.lean`: `FiveInduction.ActualXi.xi` is `(1/2)*s*(s-1)*completedRiemannZeta₀ s + 1/2`, and `Xi z = xi (1/2 + I*z)`. `xi_zero_of_nontrivial_zeta_zero`, `rh_of_real_zeros`, and `rh_of_nonreal_nonzero` link to Mathlib's actual `RiemannHypothesis`; they do not use a surrogate RH proposition.
- `FiveInduction/Sturm.lean`: `J`, `value_step`, `wronskian_step`, `imaginary_wronskian_pos`, `all_nonreal_nonzero`, and `normalized_nonreal_nonzero` supply a concrete polynomial recurrence. They require positivity of the Jacobi parameters at every order. Their root-location conclusion concerns the generated family.
- `FiveInduction/Applications.lean`: `RH_OF_STURM_CONVERGENCE` requires `hb : ∀ n, 0 < b (n+1)` and `TendstoLocallyUniformly (sturmApproximant b c) ActualXi.Xi atTop`. `sturm_calibration_forced` derives `c = ActualXi.Xi 0`. `SturmXiRealization` explicitly packages these infinite analytic inputs; no witness is constructed.
- `FiveInduction/NormalizedInputs.lean:28`: `SturmInput` fixes the calibration but still quantifies an infinite sequence and locally uniform convergence. `RH_OF_STURM_INPUT` is conditional on it.
- `FiveInduction/MainChain.lean:22`: `DesignData` contains infinite sequences and universally quantified elementary guards. `FIVE_INDUCTION_CHAIN`, `BASE_CERTIFICATE`, and `PROVED_SUCCESSOR` derive invariants for those generated recurrences. `exampleData` is explicitly unrelated to actual xi. These are useful models, not raw finite witnesses.
- `FiveInduction/ProjectionInput.lean`: `reciprocalCoeff_succ` and `reciprocalFromTaylor_eq` genuinely bind a finite convolution recurrence to the actual local reciprocal germ. `ProjectionXiRealization` still assumes all-order readout identity and subexponential bounds. This is an important actual-data recurrence reference.
- `FiveInduction/HardyActual.lean`: actual analytic `J`, Taylor coefficients and actual zeta identification are supplied. `ActualHardyEnergy` is an unproved `HasSum` proposition, explicitly marked as an analytic formalization input.
- `FiveInduction/HardyEndpoint.lean`: `actual_defect_succ` gives the exact actual coefficient defect SOS identity. `ACTUAL_BASE_CERTIFICATE` is radius 1/2. `actual_positive_persists` propagates in coefficient index at a **fixed point/radius**. `RH_OF_ACTUAL_HARDY_EXHAUSTION` still requires both `ActualHardyEnergy` and `ActualDiskExhaustion`.
- `FiveInduction/HardyInduction.lean`: `PrescribedRadiusStep` advances radii `1 - (1/2)^(n+1)`. This is a theorem hypothesis, not derived from the fixed-radius SOS recurrence. `prescribed_step_iff_exhaustion` makes the gap explicit; `RH_IFF_PRESCRIBED_RADIUS_STEP` also requires `ActualHardyEnergy`.
- `FiniteDiskCertificate r` is `∃ N, ∀ w : ℂ, ‖w‖ ≤ r → 0 < D N w`. Despite its name, this is not a raw finite rational packet with a terminating Boolean checker. A finite index and universally quantified complex inequality are not a finite arithmetic admission procedure.

Verification evidence: `validation/BUILD_STATUS.json` pins Mathlib commit `db584cd6d46c92f209a44c0f1c829460d327499d` and Lean 4.33.0. Eight new modules have individual inherited Linux compilation receipts; 19 unchanged earlier modules are described as previously validated. The combined v0.3.0 Main/Audit run was **not completed**. The file explicitly says `Windows_v0_3_0_replay = NOT_RUN_HERE`. Do not promote this to a new complete native pass.

## WITNESS_FRONTIER_HANDOFF_20261022

Root: `inspected_sources/03-WITNESS_FRONTIER_HANDOFF_20261022/WITNESS_FRONTIER_HANDOFF_20261022/`.

- Nested archive `ZETA3_WITNESS_TRUST_BOUNDARY_v0_1_6_FIX6.zip`, member `ZETA3_WITNESS_TRUST_BOUNDARY_v0_1_6_FIX6/Zeta3Witness/Core.lean`, has genuinely data-only `RieszPacket` and `AperyPacket` and executable `checkRiesz` / `checkApery`. Every claimed coordinate is recomputed over rationals; bounded `List.all` verifies orthogonality. `checkRiesz_iff`, `checkRiesz_sound`, `checkApery_iff`, `checkApery_sound` are the reusable admission pattern.
- `README_FOR_NEXT_LLM.md` and `USER_REPORTED_LEAN_PASS.txt` report the user's native pass for finite positive/mutated packet tests, while explicitly denying native r=2 admission and zeta(3) irrationality. A model packet acceptance is not an RH admission.
- `GP7_WitnessCoordinateJunction.lean`: `Coordinates n` contains proof fields (monic, orthogonality, endpoint nonzero, positive energy), so it is not a raw external packet. `check` checks only `IsWitness` once those proof fields already exist. `canonical_witness_iff_packet` additionally assumes uniqueness. The file says it was not compiler-validated.
- `WitnessCondition` is `∀ K ≥ 1, ∃ n, ∃ d : Coordinates n, IsWitness d K`; no finite collection establishes it. The analytic Padé remainder is also still missing in Lean.

## GP7_UNIFIED_LEAN_BASE_v1_0_1_IMPORT_FIX

Root: `inspected_sources/10-GP7_UNIFIED_LEAN_BASE_v1_0_1_IMPORT_FIX-2-/GP7_UNIFIED_LEAN_BASE_v1_0_1_IMPORT_FIX/`.

`GP7/PolynomialLaplace.lean`, `PolynomialLaplaceBridge.lean`, `ExpDefectBridge.lean`, and `AnalyticObjects.lean` provide finite integral, Laplace, rational approximation, finite spectral and dyadic identities. Useful declarations include `finiteLaplaceKernel_integral_rational`, `rationalApprox_eq_expDefect_integral`, `finiteSpectral_difference`, `finiteSpectral_antitone`, `finite_dyadic_at_exp`. `docs/PROOF_STATUS.md` expressly leaves actual native zeta binding, infinite-dimensional resolvent construction and infinite jet identities open. The eight old sources are user-reported frozen; four new wrappers had no local compiler run. This is supporting material, not an actual-xi calibration proof.

## MAIN_CHAIN_LEAN_ONLY

Root: `inspected_sources/13-MAIN_CHAIN_LEAN_ONLY-4-/MAIN_CHAIN_LEAN_ONLY/`.

`MAIN_CHAIN.lean` is an irrationality-of-zeta(5) endpoint, not RH. `MAIN_CHAIN_MATHLIB_ZETA` binds to `(riemannZeta 5).re`. `MAIN_CHAIN_PRIMITIVE_FROM_GRAM` constructs normalization but still requires four all-order hypotheses: positive actual Gram matrices, multiplier upper bounds, Archimedean upper bounds and quantitative spectral bounds. `MAIN_EXTENSION_POSITIVITY` requires both finite sign certificate and analytic `WeightSevenTailBound`. Titles saying “unconditional” do not remove the scope statements in the module headers.

## Recommended repository import boundary

1. Vendor the complete `FiveInduction` source namespace unchanged, plus inherited validation receipts and provenance. Keep its original `run.cmd` only in an archival source bundle if a single canonical repository runner is required. Avoid copying old compiled objects without matching dependency/toolchain receipts.
2. Vendor the trust-boundary `Zeta3Witness/Core.lean` as an explicitly separate calibration reference, with samples/mutations and their historical receipt. Do not rename it into an RH checker or count its accepted samples as RH candidates.
3. Keep GP7 and the manuscript chain in a reference/vendor area with source hashes, rather than importing them into every core module. Promote only specific lemmas needed for the actual SOLOBOLO proof.
4. The first substantive new obligations are (a) an executable raw rational certificate schema, (b) exact check-to-valid soundness, (c) **actual-data** base identity/analytic calibration from that finite certificate, (d) a derived all-order transition valid for the actual data, and (e) the exact actual-xi-to-Mathlib-RH transfer. The attached packages discharge useful portions of (d)/(e), not (c).
5. A proposed `check W = true → BaseIdentity` theorem must be proved independently. Encoding `BaseIdentity`, all-order convergence, or RH as a witness proof field would leave the requested finite reduction undone.
