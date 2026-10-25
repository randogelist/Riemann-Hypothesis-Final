import RHAdmission.PositiveSeedDefect

/-!
# Concrete finite-checker soundness cannot be obtained from scalar metric
# positivity alone

The code explicitly connects any accepted finite gate and its independently
proved native soundness to *exclusion* of an actual off-line zero. A syntactic
checker with an unconditional accepted input cannot prove this by itself.
-/

namespace RHAdmission

/-- Soundness for the ACTUAL zero-indexed modes makes every off-line zero
incompatible with acceptance of even one finite Boolean certificate. -/
theorem actual_off_line_zero_rejects_finite_gate
    (rawCheck : FiniteMetricCode → Bool)
    (hsound : GatedActualSoundness rawCheck)
    (s : ℂ) (hz : ActualNontrivialZero s)
    (hoff : s.re ≠ 1 / 2) :
    ∀ W : FiniteMetricCode, gatedCheck rawCheck W ≠ true := by
  intro W hW
  have hw := gatedCheck_metric_positive rawCheck W hW
  have hmetric := positiveMetricFromCode W hw
  have hpass := hsound W hW s hz (1, 0)
  exact off_line_rejects_seed_passivity s hoff hmetric hpass

/-- The missing finite soundness bridge must preclude the concrete
positive algebraic expansion defect on every ACTUAL zeta-zero channel. -/
theorem accepted_native_gate_requires_zero_displacement
    (rawCheck : FiniteMetricCode → Bool)
    (hsound : GatedActualSoundness rawCheck)
    (W : FiniteMetricCode) (hW : gatedCheck rawCheck W = true)
    (s : ℂ) (hz : ActualNontrivialZero s) :
    criticalOffset s = 0 := by
  by_contra hne
  have hoff : s.re ≠ 1 / 2 := by
    intro hc
    exact hne ((criticalOffset_eq_zero_iff s).mpr hc)
  exact (actual_off_line_zero_rejects_finite_gate rawCheck
    hsound s hz hoff W) hW

end RHAdmission
