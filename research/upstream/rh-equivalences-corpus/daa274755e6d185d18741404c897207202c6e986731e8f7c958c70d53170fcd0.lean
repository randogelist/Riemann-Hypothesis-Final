import Mathlib.Data.Real.Basic
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Positivity

/-!
The quantified inverse-square bound is an exact zero criterion.
The proof chooses a finite height explicitly; no limiting theorem is used.
-/

namespace PositivityPremise

/-- A nonnegative scalar has the stated inverse-square bound at every height. -/
def PositivityPremise (C c1 : ℝ) : Prop :=
  ∀ T : ℝ, 1 ≤ T → 0 ≤ C ∧ C ≤ 3 * c1 / (4 * T ^ 2)

/-- For nonnegative `c1`, the all-height bound holds exactly when `C = 0`. -/
theorem positivityPremise_iff_eq_zero {C c1 : ℝ} (hc1 : 0 ≤ c1) :
    PositivityPremise C c1 ↔ C = 0 := by
  constructor
  · intro h
    have hCnonneg : 0 ≤ C := (h 1 (by norm_num)).1
    by_contra hCne
    have hCpos : 0 < C := lt_of_le_of_ne hCnonneg (Ne.symm hCne)
    let T : ℝ := 1 + 3 * c1 / C
    have hT : 1 ≤ T := by
      dsimp [T]
      have : 0 ≤ 3 * c1 / C := div_nonneg (by positivity) hCnonneg
      linarith
    have hTpos : 0 < T := lt_of_lt_of_le zero_lt_one hT
    have hden : 0 < 4 * T ^ 2 := by positivity
    have hbound : C * (4 * T ^ 2) ≤ 3 * c1 :=
      (le_div_iff₀ hden).mp (h T hT).2
    have hCT : C * T = C + 3 * c1 := by
      dsimp [T]
      field_simp
    have hsquare : 0 ≤ T ^ 2 - T := by nlinarith
    have hmul : 0 ≤ C * (T ^ 2 - T) := mul_nonneg hCnonneg hsquare
    nlinarith
  · rintro rfl T hT
    constructor
    · exact le_rfl
    · positivity

/-- A valid positive-height bound alone does not force its scalar to vanish. -/
theorem fixed_height_counterexample :
    (0 : ℝ) ≤ 1 / 8 ∧
      (1 / 8 : ℝ) ≤ 3 * (1 : ℝ) / (4 * (1 : ℝ) ^ 2) ∧
      (1 / 8 : ℝ) ≠ 0 := by
  norm_num

end PositivityPremise
