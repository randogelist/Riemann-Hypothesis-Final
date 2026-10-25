import FiveInduction.HardyDefect

noncomputable section

namespace FiveInduction.HardySeed

open HardyDefect

theorem partial_one (c : ℕ → ℂ) (u : ℝ) (w : ℂ)
    (h0 : c 0 = 1) (h1 : c 1 = -(u : ℂ)) :
    HardyDefect.partial c 1 w = 1 - (u : ℂ) * w := by
  simp [HardyDefect.partial, Finset.sum_range_succ, h0, h1, sub_eq_add_neg]

theorem mass_one (c : ℕ → ℂ) (u : ℝ)
    (h0 : c 0 = 1) (h1 : c 1 = -(u : ℂ)) :
    mass c 1 = 1 + u ^ 2 := by
  simp [mass, Finset.sum_range_succ, h0, h1, Complex.normSq_ofReal, pow_two]

theorem defect_one (c : ℕ → ℂ) (K u : ℝ) (w : ℂ)
    (h0 : c 0 = 1) (h1 : c 1 = -(u : ℂ)) :
    defect c K 1 w =
      (1 - Complex.normSq w) * Complex.normSq (1 - (u : ℂ) * w) -
        (K - 1 - u ^ 2) * Complex.normSq w ^ 2 := by
  rw [defect, partial_one c u w h0 h1, tailMass, mass_one c u h0 h1]
  ring

theorem seed_zero_pos (c : ℕ → ℂ) (K r : ℝ)
    (h0 : c 0 = 1) (hK : 0 ≤ K) (hr : 0 ≤ r)
    (hmargin : K * r ^ 2 < 1) (w : ℂ) (hw : ‖w‖ ≤ r) :
    0 < defect c K 0 w := by
  rw [defect_zero c K w h0]
  have hq : Complex.normSq w ≤ r ^ 2 := by
    rw [Complex.normSq_eq_norm_sq]
    nlinarith [norm_nonneg w]
  have hmul := mul_le_mul_of_nonneg_left hq hK
  linarith

theorem affine_norm_lower (u r : ℝ) (hu : 0 ≤ u)
    (w : ℂ) (hw : ‖w‖ ≤ r) :
    1 - u * r ≤ ‖(1 : ℂ) - (u : ℂ) * w‖ := by
  have h := norm_sub_norm_le (1 : ℂ) ((u : ℂ) * w)
  have hnorm : ‖(u : ℂ) * w‖ = u * ‖w‖ := by
    rw [norm_mul, Complex.norm_real, Real.norm_eq_abs, abs_of_nonneg hu]
  rw [norm_one, hnorm] at h
  have hmul := mul_le_mul_of_nonneg_left hw hu
  linarith

theorem first_disk_pos (c : ℕ → ℂ) (K u r : ℝ)
    (h0 : c 0 = 1) (h1 : c 1 = -(u : ℂ))
    (hu : 0 ≤ u) (hr : 0 ≤ r) (hr1 : r < 1) (hur : u * r ≤ 1)
    (hT : 0 ≤ K - 1 - u ^ 2)
    (hmargin : 0 < (1 - r ^ 2) * (1 - u * r) ^ 2 -
      (K - 1 - u ^ 2) * r ^ 4)
    (w : ℂ) (hw : ‖w‖ ≤ r) :
    0 < defect c K 1 w := by
  rw [defect_one c K u w h0 h1]
  have hq0 : 0 ≤ Complex.normSq w := Complex.normSq_nonneg w
  have hq : Complex.normSq w ≤ r ^ 2 := by
    rw [Complex.normSq_eq_norm_sq]
    nlinarith [norm_nonneg w]
  have hr2 : r ^ 2 < 1 := by nlinarith
  have hnorm := affine_norm_lower u r hu w hw
  have hnormsq : (1 - u * r) ^ 2 ≤ Complex.normSq (1 - (u : ℂ) * w) := by
    rw [Complex.normSq_eq_norm_sq]
    nlinarith [norm_nonneg ((1 : ℂ) - (u : ℂ) * w)]
  have hprod : (1 - r ^ 2) * (1 - u * r) ^ 2 ≤
      (1 - Complex.normSq w) * Complex.normSq (1 - (u : ℂ) * w) := by
    apply mul_le_mul
    · linarith
    · exact hnormsq
    · positivity
    · linarith
  have hq2 : Complex.normSq w ^ 2 ≤ r ^ 4 := by
    nlinarith [sq_nonneg (Complex.normSq w - r ^ 2)]
  have htail := mul_le_mul_of_nonneg_left hq2 hT
  linarith

end FiveInduction.HardySeed
