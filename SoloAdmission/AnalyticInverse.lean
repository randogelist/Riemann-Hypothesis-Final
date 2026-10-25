import FiveInduction.HardyActual

set_option autoImplicit false

/-!
# Actual Riemann zeta: hypothetical analytic reciprocal admission iff native RH

This is a FULLY NATIVE theorem: the admitted analytic function must be a
holomorphic reciprocal of the ACTUAL Cayley-normalized zeta J, not an arbitrary
positive GP function.  The witness that might construct the reciprocal is NOT
assumed and NOT supplied by this file.
-/

namespace SoloAdmission
open FiveInduction

noncomputable section

/-- Actual analytic admission: a holomorphic multiplier is a genuine
multiplicative inverse of the actual `J` on the open Cayley unit disk. -/
def AnalyticReciprocalAdmission : Prop :=
  ∃ u : ℂ → ℂ,
    DifferentiableOn ℂ u CayleyBridge.unitDisk ∧
    ∀ w : ℂ, w ∈ CayleyBridge.unitDisk → HardyActual.J w * u w = 1

/-- One actual analytic inverse excludes all nontrivial off-critical zeta zeros. -/
theorem ANALYTIC_ADMISSION_IMPLIES_RH
    (h : AnalyticReciprocalAdmission) : RiemannHypothesis := by
  obtain ⟨u, _, hu⟩ := h
  apply HardyActual.RH_OF_J_NONZERO
  intro w hw hz
  have hid := hu w hw
  rw [hz, zero_mul] at hid
  exact zero_ne_one hid

/-- RH constructs the analytic reciprocal of the actual J, not only an
algebraic pointwise inverse. -/
theorem RH_IMPLIES_ANALYTIC_ADMISSION
    (hRH : RiemannHypothesis) : AnalyticReciprocalAdmission := by
  have hJ := HardyActual.J_NONZERO_OF_RH hRH
  refine ⟨(fun w : ℂ => (HardyActual.J w)⁻¹), ?_, ?_⟩
  · intro w hw
    exact ((HardyActual.differentiableAt_J hw).inv (hJ w hw)).differentiableWithinAt
  · intro w hw
    exact mul_inv_cancel₀ (hJ w hw)

/-- Genuine analytic admission equivalence with native Mathlib RH.
No research axiom, no hypothetical GP calibration, and no finite witness. -/
theorem ANALYTIC_ADMISSION_IFF_RH :
    AnalyticReciprocalAdmission ↔ RiemannHypothesis :=
  ⟨ANALYTIC_ADMISSION_IMPLIES_RH, RH_IMPLIES_ANALYTIC_ADMISSION⟩

/-- The exact remaining GP/solo analytic-calibration interface:
a supplied holomorphic function must invert the ACTUAL J. -/
theorem ACTUAL_GP_CALIBRATION_IMP_RH
    (u : ℂ → ℂ)
    (hu : DifferentiableOn ℂ u CayleyBridge.unitDisk)
    (hcal : ∀ w : ℂ, w ∈ CayleyBridge.unitDisk →
      HardyActual.J w * u w = 1) : RiemannHypothesis :=
  ANALYTIC_ADMISSION_IMPLIES_RH ⟨u, hu, hcal⟩

end
end SoloAdmission
