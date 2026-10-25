import RHAdmission.Main

/-!
# Actual SOLOBOLO shifted-axis geometry

The shifted coordinate s(s-1) is an algebraic coordinate of an ACTUAL
Mathlib zeta-zero label. This file does not assume or prove analytic
identification of the zero set of a separately constructed Theta function.
-/

namespace RHAdmission

/-- Sharp shifted-coordinate condition, with the quarter-shift included. -/
def SoloboloShiftedAxis (s : ℂ) : Prop :=
  (shiftedCoordinate s).im = 0 ∧
  (shiftedCoordinate s).re ≤ -(1 / 4 : ℝ)

/-- Pure real algebra; neither RH nor an analytic zero correspondence is used. -/
theorem solobolo_shifted_axis_iff_critical (s : ℂ) :
    SoloboloShiftedAxis s ↔ s.re = 1 / 2 := by
  constructor
  · intro h
    rcases h with ⟨hi, hr⟩
    rw [shifted_coordinate_im] at hi
    rw [shifted_coordinate_re] at hr
    rcases mul_eq_zero.mp hi with hx | hy
    · linarith
    · rw [hy] at hr
      nlinarith [sq_nonneg (s.re - (1 / 2 : ℝ))]
  · intro hc
    constructor
    · rw [shifted_coordinate_im, hc]
      ring
    · rw [shifted_coordinate_re, hc]
      nlinarith [sq_nonneg s.im]

/-- The actual zero-indexed shifted-axis criterion is literally RH. -/
theorem native_RH_iff_solobolo_shifted_axis :
    _root_.RiemannHypothesis ↔
      (∀ s : ℂ, ActualNontrivialZero s → SoloboloShiftedAxis s) := by
  constructor
  · intro hRH s hz
    exact (solobolo_shifted_axis_iff_critical s).mpr
      (hRH s hz.1 hz.2.1 hz.2.2)
  · intro h s hz htriv hne
    exact (solobolo_shifted_axis_iff_critical s).mp
      (h s ⟨hz, htriv, hne⟩)

/-- Full hypothetical metric admission is equivalent to actual shifted-axis
    rigidity (both are independently equivalent to native RH). -/
theorem full_admission_iff_solobolo_shifted_axis :
    FullHypotheticalAdmission ↔
      (∀ s : ℂ, ActualNontrivialZero s → SoloboloShiftedAxis s) := by
  exact FULL_HYPOTHETICAL_ADMISSION_IFF_NATIVE_RH.trans
    native_RH_iff_solobolo_shifted_axis

end RHAdmission
