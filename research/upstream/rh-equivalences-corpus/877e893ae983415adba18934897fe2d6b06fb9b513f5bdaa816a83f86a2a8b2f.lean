import AngularIntegration
import AngularMaster.Chain
import AngularMaster.AngularCutoff

/-!
# Native RH and the measured interior angular derivative

The master-chain profile is exactly the profile in the regularity framework.
Its interval-restricted derivative agrees with the ordinary derivative only at
interior angles.  The closure below uses no endpoint derivative assumption:
interior nonnegativity gives monotonicity on the closed interval by continuity.

These are equivalences and implications.  Global angular nonnegativity and
global regular logarithmic-slope nonnegativity remain research inputs.
`NoRegularAngularStationary` is neither assumed nor proved in this module.
-/

set_option autoImplicit false
noncomputable section

namespace RHMaster

theorem master_actualProfile_eq_regularity (r x : ℝ) :
    AngularMaster.actualProfile r x = AngularRegularity.actualProfile r x := rfl

/-- Exact ordinary/within derivative bridge on the open angular interval. -/
theorem masterAngularDerivative_eq_actualSlope {r x : ℝ}
    (hx : x ∈ Set.Ioo (-1 : ℝ) 1) :
    AngularMaster.angularDerivative AngularMaster.actualProfile r x =
      AngularRegularity.actualSlope (r, x) := by
  change derivWithin (AngularMaster.actualProfile r) (Set.Icc (-1 : ℝ) 1) x = _
  rw [derivWithin_of_mem_nhds (Icc_mem_nhds hx.1 hx.2)]
  rfl

/-- The sole sign condition in the interior angular closure. -/
def GlobalAngularNonnegative : Prop :=
  ∀ r : ℝ, 0 < r → ∀ x ∈ Set.Ioo (-1 : ℝ) 1,
    0 ≤ AngularRegularity.actualSlope (r, x)

/-- The quotient formulation is required only where theta is nonzero. -/
def GlobalRegularLogSlopeNonnegative : Prop :=
  ∀ r : ℝ, 0 < r → ∀ x ∈ Set.Ioo (-1 : ℝ) 1,
    AWPIRH.theta (AngularRegularity.circlePoint r x) ≠ 0 →
      0 ≤ AngularRegularity.logSlope AWPIRH.theta r x

theorem globalAngularNonnegative_iff_cutoff :
    GlobalAngularNonnegative ↔ AngularMaster.CutoffDerivativeNonnegative (-1) := by
  constructor
  · intro h r hr x hx
    rw [masterAngularDerivative_eq_actualSlope hx]
    exact h r hr x hx
  · intro h r hr x hx
    have hd := h r hr x hx
    rw [masterAngularDerivative_eq_actualSlope hx] at hd
    exact hd

/-- RH supplies the sign property through the imported actual master chain. -/
theorem globalAngularNonnegative_of_native_RH
    (hRH : _root_.RiemannHypothesis) : GlobalAngularNonnegative := by
  have hfull : AngularMaster.DerivativeNonnegative AngularMaster.actualProfile :=
    AngularMaster.derivativeNonnegative_of_profileMaster
      (AngularMaster.native_RH_iff_actual_profileMaster.mp hRH)
  intro r hr x hx
  have hd := hfull r hr x ⟨hx.1.le, hx.2.le⟩
  rw [masterAngularDerivative_eq_actualSlope hx] at hd
  exact hd

/-- The reverse implication uses continuity and interior derivatives only. -/
theorem native_RH_of_globalAngularNonnegative
    (h : GlobalAngularNonnegative) : _root_.RiemannHypothesis := by
  have hcut : AngularMaster.CutoffDerivativeNonnegative (-1) :=
    globalAngularNonnegative_iff_cutoff.mp h
  apply AngularMaster.native_RH_of_actual_angular_monotone
  intro r hr
  exact AngularMaster.actualProfile_monotoneOn_cutoff
    (a := (-1 : ℝ)) le_rfl hcut r hr

theorem native_RH_iff_globalAngularNonnegative :
    _root_.RiemannHypothesis ↔ GlobalAngularNonnegative :=
  ⟨globalAngularNonnegative_of_native_RH, native_RH_of_globalAngularNonnegative⟩

/-- At zeros the division-free angular derivative vanishes.  At every regular
point the previously proved strictly positive factor transfers the sign. -/
theorem globalAngularNonnegative_iff_regularLogSlopeNonnegative :
    GlobalAngularNonnegative ↔ GlobalRegularLogSlopeNonnegative := by
  constructor
  · intro h r hr x hx hv
    apply le_of_not_gt
    intro hneg
    have hslope : AngularRegularity.angularDerivative AWPIRH.theta r x < 0 :=
      (AngularRegularity.angularDerivative_neg_iff_logSlope_neg
        (AWPIRH.theta_differentiable (AngularRegularity.circlePoint r x)) hx hv).mpr hneg
    exact (not_lt_of_ge (h r hr x hx)) hslope
  · intro h r hr x hx
    change 0 ≤ AngularRegularity.angularDerivative AWPIRH.theta r x
    by_cases hv : AWPIRH.theta (AngularRegularity.circlePoint r x) = 0
    · rw [AngularRegularity.angularDerivative_eq_zero_of_value_eq_zero
        (AWPIRH.theta_differentiable (AngularRegularity.circlePoint r x)) hx hv]
    · apply le_of_not_gt
      intro hneg
      have hlog : AngularRegularity.logSlope AWPIRH.theta r x < 0 :=
        (AngularRegularity.angularDerivative_neg_iff_logSlope_neg
          (AWPIRH.theta_differentiable (AngularRegularity.circlePoint r x)) hx hv).mp hneg
      exact (not_lt_of_ge (h r hr x hx hv)) hlog

theorem native_RH_iff_globalRegularLogSlopeNonnegative :
    _root_.RiemannHypothesis ↔ GlobalRegularLogSlopeNonnegative :=
  native_RH_iff_globalAngularNonnegative.trans
    globalAngularNonnegative_iff_regularLogSlopeNonnegative

end RHMaster
