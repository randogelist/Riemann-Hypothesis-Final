import Bridge.ExplicitMersenneReadout
import Derivations.Geometry.CayleyChannelKernel
import Derivations.GP.WidderRecursion

/-! Frozen SOLOBOLO v0.23.0 inputs + GP/BKQR v0.18.3.
    All analytical research hypotheses remain explicit. -/
namespace KQGPBKQRHilbert.Input
noncomputable section

abbrev thetaCayley (T : NativeSolobolo.CenteredThetaData) :
    NativeSolobolo.GPObservable ℂ :=
  NativeSolobolo.actualThetaCayleyObservable T

abbrev xiR : ℝ → ℝ := NativeSoloboloNegativity.xiR

abbrev directXiMoment (a : ℝ) (n : ℕ) : ℝ :=
  NativeSoloboloNegativity.xiWidderDirect a n

abbrev recursiveXiMoment (a : ℝ) (n : ℕ) : ℝ :=
  NativeSoloboloNegativity.xiWidderMoment a n

abbrev centralXiMoment (a : ℝ) (n : ℕ) : ℝ :=
  NativeSoloboloNegativity.centralWidderMoment NativeSoloboloNegativity.xiR n a

abbrev tracePower (S : NativeSoloboloNegativity.FiniteCayleyDefectSystem)
    (k M : ℕ) (a : ℝ) : ℝ :=
  NativeSoloboloNegativity.cayleyTracePower S k M a

theorem direct_eq_recursive
    (a : ℝ) (ha : a ∈ NativeSoloboloNegativity.xiRegularAnchors)
    (n : ℕ) : directXiMoment a n = recursiveXiMoment a n :=
  NativeSoloboloNegativity.XI_WIDDER_DIRECT_EQ_RECURSIVE_ON_REGULAR_ANCHORS
    a ha n

theorem recursive_eq_central
    (a : ℝ) (ha : a ∈ NativeSoloboloNegativity.xiRegularAnchors)
    (n : ℕ) : recursiveXiMoment a n = centralXiMoment a n :=
  NativeSoloboloNegativity.XI_RECURSIVE_EQ_CENTRAL_HAUSDORFF_ON_REGULAR_ANCHORS
    a ha n

theorem finite_trace_nonnegative
    (S : NativeSoloboloNegativity.FiniteCayleyDefectSystem)
    (k M : ℕ) (a : ℝ) : 0 ≤ tracePower S k M a :=
  NativeSoloboloNegativity.CAYLEY_TRACE_POWER_NONNEG S k M a

theorem xi_trace_conditional_RH
    (S : NativeSoloboloNegativity.FiniteCayleyDefectSystem)
    (hchannel : NativeSoloboloNegativity.ActualOffLineChannelAnalysis)
    (hconv : NativeSoloboloNegativity.CofinalMersenneXiCayleyTraceConvergence S) :
    _root_.RiemannHypothesis :=
  NativeSoloboloNegativity.MERSENNE_XI_CAYLEY_TRACE_AND_CHANNEL_ANALYSIS_IMPLY_RH
    S hchannel hconv
end
end KQGPBKQRHilbert.Input
