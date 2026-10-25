import AllDepth.FiniteHausdorff
import Derivations.Geometry.InteriorPole
import KQGPBKQRHilbert.TargetInterfaces

/-!
# SOLOBOLO actual Cayley observable ↔ all-depth subexponential moments

The inherited theorem proves that a generic Theta zero at an off-line
coordinate makes the *actual Option-valued observable* undefined at an
interior Cayley radius.  The missing analytical bridge is that the actual
xi-Widder Taylor coefficients, when subexponential, define the same analytic
function through the whole open Cayley disk.  We expose that bridge as a
Prop to prove, NEVER as an axiom.
-/
namespace KQGPBKQRHilbert.AllDepth

/-- Analytic bridge to prove: convergence of actual-ξ all-depth Widder
    power series excludes internal `none` values of the actual Θ'/Θ
    Cayley observable.  Requires genuine actual-Θ identification when used. -/
def ActualThetaSubexpRegularity
    (T : NativeSolobolo.CenteredThetaData) : Prop :=
  ∀ (a : ℝ), 0 < a →
    SubexponentialAt NativeSoloboloNegativity.xiWidderMoment a →
    ∀ (r : ℝ), NativeSolobolo.InteriorRadius r →
      (NativeSolobolo.actualThetaCayleyObservable T).eval a r ≠ none

/-- Fully proved deduction from the existing generic *actual observable*
    interior-pole theorem and the explicitly required analytic bridge. -/
theorem actual_observable_subexp_implies_centered_RH
    (T : NativeSolobolo.CenteredThetaData)
    (hbridge : ActualThetaSubexpRegularity T)
    (hsub : ActualXiSubexponential) :
    NativeSolobolo.RiemannHypothesis T.geometry := by
  by_contra hnot
  obtain ⟨a, r, ha, hr, hpole⟩ :=
    NativeSolobolo.Derivations.Geometry.NOT_RH_IMPLIES_INTERIOR_CAYLEY_POLE
      T hnot
  exact (hbridge a ha (hsub a ha) r hr) hpole

/-- Independent route to the literal Mathlib RH statement: `T.geometry`
    must actually capture all nontrivial zeta zeros. -/
theorem actual_observable_subexp_implies_Mathlib_RH
    (T : NativeSolobolo.CenteredThetaData)
    (hactual : ActualXiZeroCoverage T.geometry)
    (hbridge : ActualThetaSubexpRegularity T)
    (hsub : ActualXiSubexponential) :
    _root_.RiemannHypothesis :=
  hactual (actual_observable_subexp_implies_centered_RH T hbridge hsub)

/-- A second *all-depth* closure route preserving SOLOBOLO's older channel
    analysis.  This one requires nonnegativity at every actual-ξ depth. -/
def ActualXiAllDepthNonnegative : Prop :=
  ∀ (a : ℝ), 0 < a → ∀ (n : ℕ),
    0 ≤ NativeSoloboloNegativity.xiWidderMoment a n

theorem all_depth_nonnegative_implies_cofinal
    (h : ActualXiAllDepthNonnegative) :
    NativeSoloboloNegativity.CofinalUniformDepthPositive := by
  intro K
  refine ⟨K, le_refl K, ?_⟩
  intro a ha
  exact h a ha K

theorem all_depth_nonnegative_and_channel_imply_RH
    (h : ActualXiAllDepthNonnegative)
    (hchannel : NativeSoloboloNegativity.ActualOffLineChannelAnalysis) :
    _root_.RiemannHypothesis :=
  NativeSoloboloNegativity.COFINAL_POSITIVITY_AND_CHANNEL_ANALYSIS_IMPLY_RH
    hchannel (all_depth_nonnegative_implies_cofinal h)

/-- The GP/BKQR full-depth norm-square equation, if proved for the actual
    Xi moments *and* for a genuinely ordered scalar product, gives all-depth
    positivity. The existing generic ScalarProductGeometry's `nonnegative`
    predicate is NOT assumed to be ordinary real `≤`. -/
theorem gp_bkqr_calibration_implies_all_depth_nonnegative
    {Vec : Type}
    {G : NativeSolobolo.GPObservable ℂ}
    {C : NativeSolobolo.CayleyMomentCodec ℝ ℂ}
    {Q : NativeSolobolo.Derivations.BKQR.ScalarProductGeometry ℝ Vec}
    (A : NativeSolobolo.GPTransferMomentModel G C)
    (M : NativeSolobolo.BKQRCayleyModel ℝ Vec ℂ Q C)
    (H : NativeSolobolo.GPBKQRCommonMomentIdentity A M)
    (hcal : KQGPBKQRHilbert.GPToXiDirectCalibration A.moment)
    (hreg : NativeSoloboloNegativity.AllPositiveXiRegular)
    (hnonneg : ∀ v : Vec, 0 ≤ Q.normSq v) :
    ActualXiAllDepthNonnegative := by
  intro a ha n
  have hsq := KQGPBKQRHilbert.common_moments_calibrated_actual_square
    A M H hcal a (hreg a ha) n
  rw [hsq]
  exact hnonneg (M.widderVector a n)

end KQGPBKQRHilbert.AllDepth
