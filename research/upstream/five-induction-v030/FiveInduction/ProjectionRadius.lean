import Mathlib.Analysis.Analytic.OfScalars
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic

namespace FiveInduction.ProjectionInput

open FormalMultilinearSeries

/-- Subexponential scalar coefficients give a power-series radius at least one. -/
theorem radius_ge_one_of_subexp (c : ℕ → ℂ)
    (h : ∀ ε : ℝ, 0 < ε → ∃ C : ℝ, 0 < C ∧
      ∀ n : ℕ, ‖c n‖ ≤ C * Real.exp (ε * n)) :
    1 ≤ (FormalMultilinearSeries.ofScalars ℂ c).radius := by
  apply ENNReal.le_of_forall_nnreal_lt
  intro r hr
  by_cases hr0 : r = 0
  · simp [hr0]
  have hrpos : 0 < (r : ℝ) := by exact_mod_cast (pos_iff_ne_zero.mpr hr0)
  have hrlt : (r : ℝ) < 1 := by exact_mod_cast hr
  have he : 0 < -Real.log (r : ℝ) := neg_pos.mpr (Real.log_neg hrpos hrlt)
  obtain ⟨C, hC, hc⟩ := h (-Real.log (r : ℝ)) he
  apply (FormalMultilinearSeries.ofScalars ℂ c).le_radius_of_bound C
  intro n
  rw [FormalMultilinearSeries.ofScalars_norm]
  calc
    ‖c n‖ * (r : ℝ) ^ n ≤
        (C * Real.exp (-Real.log (r : ℝ) * n)) * (r : ℝ) ^ n :=
      mul_le_mul_of_nonneg_right (hc n) (pow_nonneg r.coe_nonneg n)
    _ = C := by
      rw [mul_comm (-Real.log (r : ℝ)) (n : ℝ), Real.exp_nat_mul,
        Real.exp_neg, Real.exp_log hrpos]
      rw [mul_assoc, ← mul_pow, inv_mul_cancel₀ hrpos.ne', one_pow, mul_one]

end FiveInduction.ProjectionInput
