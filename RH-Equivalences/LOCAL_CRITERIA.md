# Current repository RH criteria

This index supplements the 21 October catalogue with **115 declaration records**
from the currently recovered SOLOBOLO, Cayley–Sturm, five-induction and KQ
packages. It counts aliases, implications and diagnostic statements separately;
it is **not** a count of 115 independent RH equivalences.

Every record is **SOURCE_ONLY; native verification NOT_RUN**. The
[local machine-readable index](local-criteria.json) preserves the exact Lean
signature, enclosing variables, source path, line and SHA-256, with 125 supporting
predicate definitions and 27 additional directly linked auxiliary results.
The original archive files remain outside the active build.

The twelve selected items below also appear in the supplementary sections of
[Identified by Literature](Identified-by-Literature/README.md) and
[Potentially novel](Potentially-novel/README.md). That split concerns mathematical
provenance, not whether an implication is an equivalence or has been compiled.

## Literal native RH equivalences

These targets are Mathlib's actual `RiemannHypothesis`. An equivalence supplies
neither a proof of RH nor an accepted finite witness.

1. **Native zero rigidity.**
   [`RHFinal.Actual.nativeRH_iff_zero_rigidity`](../RHFinal/Actual/NativeRH.lean)
   states
   `RiemannHypothesis ↔ ∀ s, NontrivialZero s → s.re = 1/2`.
   `NontrivialZero` uses actual `riemannZeta`, excludes its negative even trivial
   zeros, and excludes `s = 1`. This is an active logical normalization with no
   additional theorem hypothesis.

2. **SOLOBOLO shifted-axis geometry.**
   [`RHAdmission.native_RH_iff_solobolo_shifted_axis`](../research/upstream/native-rh-v061/src/RHAdmission/ShiftedAxis.lean)
   states native RH iff every actual nontrivial zero satisfies
   `(s*(s-1)).im = 0` and `(s*(s-1)).re ≤ -1/4`.
   This is an algebraic zero-location equivalence, without an extra analytic
   hypothesis. It does not construct an operator or a witness.

3. **Actual regularized Cayley function nonvanishing.**
   [`FiveInduction.HardyActual.J_NONZERO_IFF_RH`](../research/upstream/five-induction-v030/FiveInduction/HardyActual.lean)
   states `(∀ w ∈ unitDisk, J w ≠ 0) ↔ RiemannHypothesis`, with no extra theorem
   hypothesis. Here `F w = 2*xi(1/(1-w))` uses the actual pole-subtracted completed
   xi, and `J w = F w*(1-w)^2*(Gammaℝ(1/(1-w)))⁻¹`.
   The archived source provides the literal analytic function; nonvanishing on
   the entire open disk is still the criterion.

## Native RH through an algebraic channel model

These are genuine native-RH-target statements. Their criterion is an explicitly
constructed algebraic model indexed by actual zeros; it has not been identified
with the actual GP/Mellin operator.

4. **Scalar and positive-metric passivity.**
   [`SCALAR_CHANNEL_ADMISSION_IFF_NATIVE_RH`](../research/upstream/native-rh-v061/src/RHAdmission/ScalarCriterion.lean)
   requires `channelGain s ≤ 1` at every actual nontrivial zero, where
   `channelGain s = 1 + 4*(s.re-1/2)^2`.
   The [diagonal](../research/upstream/native-rh-v061/src/RHAdmission/Equivalence.lean)
   and [full positive two-mode metric](../research/upstream/native-rh-v061/src/RHAdmission/GeneralMetric.lean)
   admissions are also native-RH equivalent. Their existential metric must be
   passive at **all** actual zero channels.

5. **One fixed seed and all depths.**
   [`SEED_METRIC_ADMISSION_IFF_NATIVE_RH`](../research/upstream/native-rh-v061/src/RHAdmission/SeedAdmission.lean)
   only tests the vector `(1,0)`, still at every actual nontrivial zero.
   [`SEED_ALL_DEPTH_ADMISSION_IFF_NATIVE_RH`](../research/upstream/native-rh-v061/src/RHAdmission/SeedAllDepth.lean)
   and [`ALL_DEPTH_ADMISSION_IFF_NATIVE_RH`](../research/upstream/native-rh-v061/src/RHAdmission/AllDepthAdmission.lean)
   follow from one-step passivity by induction. The model successor is derived;
   existence of the globally admitted metric is not.

6. **Finite metric code plus global calibration.**
   [`FINITELY_CODED_ADMISSION_IFF_NATIVE_RH`](../research/upstream/native-rh-v061/src/RHAdmission/FiniteNativePort.lean)
   states that a rational metric code passing its finite positivity check,
   **together with `NativeCalibrated`**, is equivalent to native RH.
   `NativeCalibrated` universally quantifies over actual zeros and input vectors;
   it is not checked by rational positivity. The
   [positivity-checker soundness barrier](../research/upstream/native-rh-v061/src/RHAdmission/FiniteVerifierBarrier.lean)
   proves that soundness of this already-accepting local checker would itself be
   RH-equivalent. A [genuine Boolean-checker iff](../research/upstream/native-rh-v061/src/RHAdmission/FiniteVerifierContract.lean)
   remains conditional on both independent native soundness and completeness.

## Conditional native criteria

7. **Actual Hardy disk exhaustion.**
   [`RH_IFF_ACTUAL_DISK_EXHAUSTION`](../research/upstream/five-induction-v030/FiveInduction/HardyEndpoint.lean)
   assumes `ActualHardyEnergy`, the exact identity
   `HasSum (fun n => Complex.normSq (coeff n)) K`, where `coeff` are the actual
   Taylor coefficients of `J` and `K = log(2*pi) - EulerGamma`.
   Under that hypothesis, native RH is equivalent to positive-defect certificates
   on every compact subdisk. `FiniteDiskCertificate r` means
   `∃ N, ∀ w, ‖w‖ ≤ r → 0 < D N w`: the integer is finite, but the disk-wide
   assertion is not a terminating finite test.

8. **Prescribed-radius successor.**
   [`RH_IFF_PRESCRIBED_RADIUS_STEP`](../research/upstream/five-induction-v030/FiveInduction/HardyInduction.lean)
   also assumes `ActualHardyEnergy` and equates native RH with
   `∀ n, FiniteDiskCertificate (radius n) → FiniteDiskCertificate (radius (n+1))`,
   for `radius n = 1 - (1/2)^(n+1)`.
   A radius-`1/2` base is provided in the source. The coefficient-index recurrence
   preserves positivity at a fixed point/radius; enlargement to the next radius
   remains the substantive step premise.

9. **Actual Widder control versus off-line explosion.**
   [`NATIVE_RH_OF_ACTUAL_WIDDER_CALIBRATION`](../research/upstream/cayley-sturm-v010/Bridge/ActualTraceEndpoint.lean)
   requires a finite spectrum witness, `AllLevelContractive`,
   `AllRealAnchorActualWidderCalibration`, and the open implication
   `¬RH → ∃ b>0, ∀ C, ∃ p, C < actualCentralWidder b p`.
   It is a one-way criterion. The active
   [`nativeRH_of_momentControl`](../RHFinal/Actual/Frontier.lean)
   similarly assumes both all-order actual moment control and actual off-line
   explosion. Neither version derives calibration from finite local acceptance.
   The required base calibration is a **functional identity on a domain**,
   not one scalar value or a finite Taylor jet.

10. **Cofinal actual moments, central cells and finite trace limits.**
    [`COFINAL_POSITIVITY_AND_CHANNEL_ANALYSIS_IMPLY_RH`](../Bridge/XiChannelNegativity.lean)
    assumes `ActualOffLineChannelAnalysis` and `CofinalUniformDepthPositive`.
    Channel analysis means `¬RH → Nonempty ActualXiPeakData`, including exact
    actual moment reconstruction, tuned finite-cluster phases and a summable
    infinite-tail envelope. Cofinal positivity means
    `∀ K, ∃ N≥K, ∀ a>0, 0≤xiWidderMoment a N`.
    The [Mersenne central-cell criteria](../Bridge/MersenneCentralCriterion.lean)
    add `AllPositiveXiRegular` when transporting from the central Hausdorff cells.
    The strongest direct
    [`MERSENNE_XI_CAYLEY_TRACE_AND_CHANNEL_ANALYSIS_IMPLY_RH`](../Bridge/ExplicitMersenneReadout.lean)
    instead assumes direct convergence of finite Cayley trace powers to actual
    recursive moments, and needs no regular-anchor transport premise.
    These are one-way conditional results. `FiniteCayleyDefectSystem` includes
    infinite families and proof fields; the complete object is not finite raw
    certificate data.

## Custom RH predicates and model criteria

11. **Finite-rate semantic admissions.**
    [`v13_semanticRatePacket_iff_actualRH`](../research/upstream/finite-rate-v041/Solobolo/MainChainV13.lean)
    assumes `hsource : ActualRiemannHypothesis ↔ NoOffLineMass p` and
    `hrate : ActualRiemannHypothesis → TailQuarterRate p`.
    It equates this package's custom critical-strip RH with a finite rational
    rate packet **plus an all-index semantic bound**. The budget check alone
    does not establish that bound. The
    [custom target](../research/upstream/finite-rate-v041/Solobolo/ActualRHInterface.lean)
    quantifies only zeros with `0 < s.re < 1`; no bridge to Mathlib's native RH
    was located in this package. Epsilon/eventual-epsilon, quarter, geometric,
    finite-start and Boolean-checker variants retain their own source/rate/
    soundness/completeness hypotheses in the machine index. The two statements
    named `v9_abstract_admission_iff_RH` and `v9_quarter_admission_iff_RH_of_rate`
    concern only `NoOffLineMass p` despite their names.

12. **Centered zero geometry and subexponential moments.**
    [`subexponential_excludes_offline_zero`](../AllDepth/SubexpEnvelope.lean)
    assumes `Subexponential W` and `CanonicalPoleGrowth X W`, and concludes
    `NativeSolobolo.RiemannHypothesis X`, the custom assertion
    `∀ z : X.Zero, X.beta z = 0`. Its native counterpart additionally requires
    `ActualXiZeroCoverage X`. The
    [observable regularity route](../AllDepth/ActualPoleClosure.lean) and
    [positive-pole-crossing route](../AllDepth/CayleyTaylorAndPole.lean)
    likewise separate the analytic bridge and actual-zero coverage.
    These are sufficient implications, not proved equivalences or a construction
    of the actual subexponential bound.

Other indexed native one-way criteria include the five actual SOS, projection,
Schur, Sturm and differential realizations, and RH-to-finite-packet Hausdorff,
Gram, Sturm and Mersenne consequences. Their complete hypotheses are preserved
in the machine index; none is promoted here to an unconditional finite-witness
criterion.
