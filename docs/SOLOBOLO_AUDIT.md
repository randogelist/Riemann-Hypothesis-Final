# SOLOBOLO source audit — 2026-10-25

Scope: the three recovered ZIPs in `solobolo_sources/`, inspected as source only. No Lean compiler was run. Source proof terms and static scans are not compiler or axiom-audit receipts.

## Foundation decision

Use `SOLOBOLO_CAYLEY_STURM_RH_FORWARD_v0_1_0` as the primary mathematical source: it contains literal completed-zeta/xi definitions, finite rational expression programs, shared-spectrum trace induction, all-anchor bounds, and explicit actual-xi calibration frontiers. Keep `RH_SOLOBOLO_FINITE_WITNESS_IFF_RH_LEAN_v0_6_1_GOODWORKFLOW_CACHED_MATHLIB_FIX1` as the native-RH normal-form and anti-circularity reference. The latter's two-mode channel is an explicitly declared algebraic proxy; it is not an actual GP/Mellin realization.

No recovered package establishes a complete terminating finite witness checker sound for actual xi. None contains the remembered STURMION functional BASE theorem or a derivation identifying its GP and actual-xi towers.

## Exact reusable declarations

All paths below are relative to their ZIP's package root.

| Package / path | Declaration or content | Exact scope |
|---|---|---|
| Cayley-Sturm `FiniteWitness/NativeXi.lean` | `actualXi`, `actualTheta`, `actualGerm`, `actualComplexCoefficient` | Literal `completedRiemannZeta₀`; square-descent uses `Complex.sqrt`; global entireness and zero correspondence remain open. |
| Cayley-Sturm `FiniteWitness/NativeXiNormalization.lean` | `actualXi_at_zero`, `actualXi_at_one`, `actualXi_one_sub`, `actualXi_centered_even` | Explicit proof terms for normalization/reflection; not compilation verified here. |
| Cayley-Sturm `FiniteWitness/FiniteSpectrum.lean` | `RatTerm`, `FiniteWitness`, `RatTerm.eval`, `checkSeed`, `checkSeed_sound` | Finite AST and finite rational seed check. `checkSeed` checks only levels up to `baseDepth`. |
| Cayley-Sturm `FiniteWitness/TraceInduction.lean` | `scalar_mersenne_step`, `trace_mersenne_step`, `checked_seed_cayley_induction` | Powers share the same spectrum. Arbitrary power depth follows for each checked spectral layer; it does not certify all spectral layers. |
| Cayley-Sturm `FiniteWitness/PositiveSyntax.lean` | `PosTerm.check_sound`, `checkAlgebra_sound` | Finite positivity syntax yields an inequality for every natural level/slot. No actual-xi identification. |
| Cayley-Sturm `FiniteWitness/TelescopicSpectrum.lean` | `telescopicWitness_allLevelContractive` | A finite scale certificate proves all-layer contractivity for a concrete telescoping model. The source explicitly calls it a toy model. |
| Cayley-Sturm `FiniteWitness/RationalJetEnclosure.lean` | `RatProgram`, `JetBoxProgram`, `checkGeneratedJetLayer` | Finite AST includes bounded sums and checked nonzero denominators. Analytic `ActualXiJetInside` remains an extra input. |
| Cayley-Sturm `Bridge/NativeWidderTrace.lean` | `actualThetaR`, `actualDirectJet`, `actualCentralWidder` | Literal actual-xi logarithmic derivative jets. Real-valuedness, regularity and divisor formulas are not proved by these definitions. |
| v0.6.1 `src/RHAdmission/NativeZeros.lean` | `ActualNontrivialZero`, `native_RH_iff_actual_zero_rigidity` | Exact `_root_.RiemannHypothesis` interface, including excluded trivial zeros and `s ≠ 1`. |
| v0.6.1 `src/RHAdmission/FiniteVerifierBarrier.lean` | `POSITIVE_ONLY_CHECKER_SOUNDNESS_IFF_NATIVE_RH` | Diagnostic: soundness of the already-accepting positivity-only checker is itself RH-equivalent. |
| v0.6.1 `src/RHAdmission/FiniteVerifierContract.lean` | `FINITE_WITNESS_IFF_NATIVE_RH_OF_SOUND_COMPLETE` | Explicit conditional composition, with soundness and completeness as substantive premises. |

The v0.6.1 native predicate is:

```lean
def ActualNontrivialZero (s : ℂ) : Prop :=
  riemannZeta s = 0 ∧
  (¬ ∃ n : ℕ, s = -2 * (n + 1)) ∧ s ≠ 1

theorem native_RH_iff_actual_zero_rigidity :
    _root_.RiemannHypothesis ↔
      (∀ s : ℂ, ActualNontrivialZero s → s.re = 1 / 2)
```

By contrast, v0.4.1 `Solobolo/ActualRHInterface.lean` defines its own `ActualRiemannHypothesis` over `0 < s.re < 1`. Its `ActualRHNormalForm.lean` proves only a logical restatement of that custom predicate. No bridge to `_root_.RiemannHypothesis` was located there. Do not silently replace the requested native target with this custom definition.

## Remaining induction-input reduction

The Cayley-Sturm branch exposes two distinct routes:

1. Actual Widder trace route (`Bridge/ActualTraceEndpoint.lean`). One concrete terminating checker must imply `AllLevelContractive w ∧ AllRealAnchorActualWidderCalibration w`. Calibration quantifies over every positive real anchor, every moment order, and every positive error tolerance. Separately prove `OFFLINE_WIDDER_EXPLOSION_FRONTIER` for the literal `actualCentralWidder`. Only then does `CONDITIONAL_RH_OF_SOLOBOLO_WITNESS` close its forward implication.
2. Complex-jet route (`Bridge/CofinalEndpoint.lean`). A finite program must yield arbitrarily large accepted layers with `ActualXiJetInside` for full complex coefficients, and prove `COFINAL_COMPLEX_HURWITZ_FRONTIER`. A finite test of rational rectangles alone does not establish either analytic assertion.

For the remembered STURMION approach, write new actual-data lemmas: derive the actual differential successor from the literal logarithmic derivative, derive the GP successor from its fixed realization, and prove that one functional base identity transfers through that common successor. Equality at finitely many sample points or positivity of a model is insufficient for equality of functions on an interval. The finite certificate needs a proved universal residual/identity principle, with all regularity and limit hypotheses discharged for actual xi. Neither the all-level transition nor the analytic BASE should be stored as a proof field inside `FiniteWitness`.

Completeness remains distinct: for the requested iff, prove native RH implies existence of a code accepted by the same concrete checker. A checker with no accepted code can have vacuous soundness; an always-accepting positivity checker already has a model witness but lacks actual-data soundness.

The v0.6.1 input is `NativeCalibrated W hw`, quantifying over all actual nontrivial zeta zeros. `FinitelyCodedAdmission` includes that infinite proposition. Its equivalence with native RH is not a finite-checker result. `channelGain s = 1 + 4 * (s.re - 1/2)^2` builds the desired expansion into a proxy channel and does not derive the actual SOLOBOLO transition.

## Receipt assessment

- Cayley-Sturm `BUILD_STATUS_PREVIEW.json`: 42 sources (34 inherited, eight new); `assistant_compilation=NOT_RUN`; `finite_native_zero_consequences=SOURCE_WRITTEN_PASSES_PENDING`; actual infinite divisor bridge and full finite-witness RH open.
- Its `STATUS.md` is inherited v0.5.0 metadata for 34 sources, not a receipt for the new 42-module package. It says compilation not run and witness-ready no.
- v0.4.1 `PROOF_LEDGER.md`: source proofs pending the user's Lean 4.33 PASS. `STATIC_AUDIT.txt` records an acyclic graph and no source admission tokens; it explicitly says no compiler executed.
- v0.6.1 `CHECKPOINT.txt`: 30 unchanged source modules, no local compilation; checker soundness/completeness and finite-witness iff RH open. “Frozen sources” does not provide an `.olean` + environment + audited native PASS receipt.
- No `.olean`, native build logs, or audited native PASS receipts were present in these three recovered trees. All imported sources must retain **source-only/unverified** status until the user's matching native environment verifies them.

## Repository import recommendation

Preserve all three source packages byte-for-byte under provenance/reference directories, excluding their nested `run.cmd` from the runnable repository layout if the repository promises one runner; preserve ZIP hashes and provenance instead. Do not put every historical branch into the default build.

For a small actual-data build, adapt the native predicate/normal form from v0.6.1 and actual xi definitions/normalizations from Cayley-Sturm into new `RHFinal.Actual` modules, retaining origin and modification notes. If keeping original names, the minimal shared-spectrum algebra import chain is `NativeXi → GPMoments → FiniteSpectrum → TraceInduction`; its model-only status must remain explicit. Positive syntax additionally requires `FiniteLayers → FiniteDebit → PositiveSyntax`; telescopic all-level contractivity additionally requires `TelescopicSpectrum`.

Use the exact native target:

```lean
(∃ W : FiniteWitness, check W = true) ↔ _root_.RiemannHypothesis
```

Keep it an open target until both directions have independently proved source binding and all-level transfer. No `🟢 LEAN-READY`, formal-closure, or S-Tier status follows from the recovered files.
