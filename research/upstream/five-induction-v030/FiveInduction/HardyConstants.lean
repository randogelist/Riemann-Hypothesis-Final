import FiveInduction.HardyActual
import FiveInduction.HardySeed

noncomputable section

namespace FiveInduction.HardyConstants

open HardyActual

theorem K_pos : 0 < K := by
  have hp : 0 < 2 * Real.pi := by positivity
  have hpi := Real.pi_gt_three
  have hinv : (2 * Real.pi)⁻¹ < (1 / 6 : ℝ) := by
    rw [inv_eq_one_div]
    apply (div_lt_div_iff₀ hp (by norm_num : (0 : ℝ) < 6)).mpr
    nlinarith
  have hlog := Real.one_sub_inv_le_log_of_pos hp
  have hgamma := Real.eulerMascheroniConstant_lt_two_thirds
  unfold K
  linarith

theorem K_lt_three : K < 3 := by
  have hpi := Real.pi_lt_four
  have hlog : Real.log (2 * Real.pi) < Real.log (2 ^ 3 : ℝ) := by
    apply Real.log_lt_log (by positivity)
    norm_num
    linarith
  rw [Real.log_pow] at hlog
  have htwo : Real.log (2 : ℝ) < 1 := by
    have h := Real.log_lt_sub_one_of_pos (by norm_num : (0 : ℝ) < 2)
      (by norm_num : (2 : ℝ) ≠ 1)
    norm_num at h
    exact h
  have hgamma := Real.one_half_lt_eulerMascheroniConstant
  unfold K
  norm_num at hlog
  linarith

theorem actual_seed_half (w : ℂ) (hw : ‖w‖ ≤ (1 / 2 : ℝ)) :
    0 < HardyDefect.defect coeff K 0 w := by
  apply HardySeed.seed_zero_pos coeff K (1 / 2) coeff_zero K_pos.le (by norm_num)
    _ w hw
  nlinarith [K_lt_three]

end FiveInduction.HardyConstants
