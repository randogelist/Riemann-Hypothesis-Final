import Mathlib.Data.Real.Basic
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Ring

/-! The exact nonnegative contribution of one positive-height zero. -/

set_option autoImplicit false

noncomputable section
namespace PositivityPremise

def defect (m delta gamma : ℝ) : ℝ :=
  m * delta ^ 2 * (3 * gamma ^ 2 + delta ^ 2) /
    (gamma ^ 2 * (gamma ^ 2 + delta ^ 2) ^ 2)

theorem defect_nonneg {m delta gamma : ℝ} (hm : 0 ≤ m) (hg : 0 < gamma) :
    0 ≤ defect m delta gamma := by
  unfold defect
  positivity

theorem defect_eq_zero_iff {m delta gamma : ℝ} (hm : 0 < m) (hg : 0 < gamma) :
    defect m delta gamma = 0 ↔ delta = 0 := by
  constructor
  · intro hzero
    by_contra hd
    have hd2 : 0 < delta ^ 2 := sq_pos_of_ne_zero hd
    have hpos : 0 < defect m delta gamma := by
      unfold defect
      positivity
    linarith
  · rintro rfl
    simp [defect]

theorem defect_identity {m delta gamma : ℝ} (hg : 0 < gamma) :
    m / gamma ^ 2 - m * (gamma ^ 2 - delta ^ 2) / (gamma ^ 2 + delta ^ 2) ^ 2 =
      defect m delta gamma := by
  have hg0 : gamma ≠ 0 := ne_of_gt hg
  have hs0 : gamma ^ 2 + delta ^ 2 ≠ 0 := by positivity
  unfold defect
  field_simp
  ring

theorem defect_upper_weighted {m delta gamma : ℝ}
    (hm : 0 ≤ m) (hg : 0 < gamma) :
    defect m delta gamma ≤ 3 * m * delta ^ 2 / gamma ^ 4 := by
  have hden : 0 < gamma ^ 2 * (gamma ^ 2 + delta ^ 2) ^ 2 := by positivity
  have hg4 : 0 < gamma ^ 4 := by positivity
  unfold defect
  apply (div_le_div_iff₀ hden hg4).2
  nlinarith [show 0 ≤ m * delta ^ 4 * gamma ^ 2 * (5 * gamma ^ 2 + 3 * delta ^ 2)
    by positivity]

theorem defect_upper_bound {m delta gamma : ℝ}
    (hm : 0 ≤ m) (hg : 0 < gamma) (hd : delta ^ 2 ≤ 1 / 4) :
    defect m delta gamma ≤ 3 * m / (4 * gamma ^ 4) := by
  calc
    defect m delta gamma ≤ 3 * m * delta ^ 2 / gamma ^ 4 :=
      defect_upper_weighted hm hg
    _ ≤ (3 * m * (1 / 4)) / gamma ^ 4 := by
      apply div_le_div_of_nonneg_right _ (by positivity)
      exact mul_le_mul_of_nonneg_left hd (by positivity)
    _ = 3 * m / (4 * gamma ^ 4) := by ring

theorem defect_lower_bound {m delta gamma : ℝ}
    (hm : 0 ≤ m) (hg : 0 < gamma) (hd : delta ^ 2 ≤ 1 / 4) :
    3 * m * delta ^ 2 / (gamma ^ 2 + 1 / 4) ^ 2 ≤ defect m delta gamma := by
  have hs : 0 < (gamma ^ 2 + delta ^ 2) ^ 2 := by positivity
  have hden : 0 < gamma ^ 2 * (gamma ^ 2 + delta ^ 2) ^ 2 := by positivity
  have hsle : (gamma ^ 2 + delta ^ 2) ^ 2 ≤ (gamma ^ 2 + 1 / 4) ^ 2 := by
    nlinarith [mul_nonneg (show 0 ≤ (1 : ℝ) / 4 - delta ^ 2 by linarith)
      (show 0 ≤ 2 * gamma ^ 2 + 1 / 4 + delta ^ 2 by positivity)]
  calc
    3 * m * delta ^ 2 / (gamma ^ 2 + 1 / 4) ^ 2 ≤
        3 * m * delta ^ 2 / (gamma ^ 2 + delta ^ 2) ^ 2 :=
      div_le_div_of_nonneg_left (by positivity) hs hsle
    _ ≤ defect m delta gamma := by
      unfold defect
      apply (div_le_div_iff₀ hs hden).2
      nlinarith [show 0 ≤ m * delta ^ 4 * (gamma ^ 2 + delta ^ 2) ^ 2 by positivity]

end PositivityPremise
