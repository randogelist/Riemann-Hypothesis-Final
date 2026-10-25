import FiniteWitness.UniversalRecurrence

/-!
# Correct analytic target: complex Taylor coefficients, not just their real parts

The v0.1 `actualCoefficient` was the REAL PART of the actual complex Taylor
coefficient. A real-part approximation alone loses imaginary information.
This stronger target compares COMPLEX numbers in the actual Mathlib norm.
Its universal verification is NOT supplied by any finite algebraic checker.
-/

noncomputable section

namespace WitnessSolobolo

/-- Every finite rational symmetric coefficient is compared to the full,
complex-valued actual-xi Taylor jet at the quarter anchor. -/
def AllDepthComplexCalibration (w : FiniteWitness) : Prop :=
  ∀ N j : ℕ, j ≤ N →
    (Nat.factorial j : ℝ) *
      ‖(elementary w N j : ℂ) - actualComplexCoefficient j‖ ≤
      (1 / 2 : ℝ) ^ N

/-- The true analytic target, without suppressing imaginary parts. -/
def AllDepthComplexLayer (w : FiniteWitness) : Prop :=
  AllLevelContractive w ∧ AllDepthComplexCalibration w

/-- Full complex calibration implies the old real-part calibration. -/
theorem complexCalibration_implies_real
    (w : FiniteWitness) (h : AllDepthComplexCalibration w) :
    AllDepthCalibration w := by
  intro N j hj
  have hc := h N j hj
  have hre := Complex.abs_re_le_norm
    ((elementary w N j : ℂ) - actualComplexCoefficient j)
  have hf : 0 ≤ (Nat.factorial j : ℝ) := by positivity
  calc
    (Nat.factorial j : ℝ) *
      |(elementary w N j : ℝ) - actualCoefficient j| =
        (Nat.factorial j : ℝ) *
        |(((elementary w N j : ℂ) - actualComplexCoefficient j).re)| := by
          simp [actualCoefficient]
    _ ≤ (Nat.factorial j : ℝ) *
        ‖(elementary w N j : ℂ) - actualComplexCoefficient j‖ :=
          mul_le_mul_of_nonneg_left hre hf
    _ ≤ (1 / 2 : ℝ) ^ N := hc

/-- A full complex layer also proves the older layer premise. -/
theorem complexLayer_implies_oldLayer
    (w : FiniteWitness) (h : AllDepthComplexLayer w) :
    AllDepthActualLayer w := by
  exact ⟨h.1, complexCalibration_implies_real w h.2⟩

end WitnessSolobolo
