import Mathlib

noncomputable section

namespace FiveInduction.HardyDefect

def «partial» (c : ℕ → ℂ) (N : ℕ) (w : ℂ) : ℂ :=
  ∑ k ∈ Finset.range (N + 1), c k * w ^ k

def mass (c : ℕ → ℂ) (N : ℕ) : ℝ :=
  ∑ k ∈ Finset.range (N + 1), Complex.normSq (c k)

def tailMass (c : ℕ → ℂ) (K : ℝ) (N : ℕ) : ℝ :=
  K - mass c N

def defect (c : ℕ → ℂ) (K : ℝ) (N : ℕ) (w : ℂ) : ℝ :=
  (1 - Complex.normSq w) * Complex.normSq («partial» c N w) -
    tailMass c K N * (Complex.normSq w) ^ (N + 1)

theorem partial_succ (c : ℕ → ℂ) (N : ℕ) (w : ℂ) :
    «partial» c (N + 1) w = «partial» c N w + c (N + 1) * w ^ (N + 1) := by
  simp only [«partial», Finset.sum_range_succ]

theorem mass_succ (c : ℕ → ℂ) (N : ℕ) :
    mass c (N + 1) = mass c N + Complex.normSq (c (N + 1)) := by
  simp only [mass, Finset.sum_range_succ]

theorem tailMass_succ (c : ℕ → ℂ) (K : ℝ) (N : ℕ) :
    tailMass c K (N + 1) = tailMass c K N - Complex.normSq (c (N + 1)) := by
  rw [tailMass, mass_succ, tailMass]
  ring

theorem normSq_affine_identity (p z : ℂ) (q : ℝ) :
    (1 - q) * Complex.normSq (p + z) + q * Complex.normSq z =
      q * (1 - q) * Complex.normSq p +
        Complex.normSq (((1 - q : ℝ) : ℂ) * p + z) := by
  simp only [Complex.normSq_apply, Complex.add_re, Complex.add_im,
    Complex.mul_re, Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im]
  ring

theorem defect_succ (c : ℕ → ℂ) (K : ℝ) (N : ℕ) (w : ℂ) :
    defect c K (N + 1) w = Complex.normSq w * defect c K N w +
      Complex.normSq
        (((1 - Complex.normSq w : ℝ) : ℂ) * «partial» c N w +
          c (N + 1) * w ^ (N + 1)) := by
  have hz : Complex.normSq (c (N + 1) * w ^ (N + 1)) =
      Complex.normSq (c (N + 1)) * Complex.normSq w ^ (N + 1) := by
    simp only [map_mul, map_pow]
  have h := normSq_affine_identity («partial» c N w)
    (c (N + 1) * w ^ (N + 1)) (Complex.normSq w)
  rw [hz] at h
  rw [defect, partial_succ, tailMass_succ,
    pow_succ (Complex.normSq w) (N + 1)]
  unfold defect
  nlinarith only [h]

theorem defect_succ_squares (c : ℕ → ℂ) (K : ℝ) (N : ℕ) (w : ℂ) :
    let z := (((1 - Complex.normSq w : ℝ) : ℂ) * «partial» c N w +
      c (N + 1) * w ^ (N + 1))
    defect c K (N + 1) w =
      Complex.normSq w * defect c K N w + z.re ^ 2 + z.im ^ 2 := by
  dsimp only
  rw [defect_succ]
  simp only [Complex.normSq_apply, pow_two]
  ring

theorem partial_at_zero (c : ℕ → ℂ) (N : ℕ) :
    «partial» c N 0 = c 0 := by
  simp [«partial», Finset.sum_range_succ']

theorem defect_zero (c : ℕ → ℂ) (K : ℝ) (w : ℂ) (hc : c 0 = 1) :
    defect c K 0 w = 1 - K * Complex.normSq w := by
  simp [defect, «partial», tailMass, mass, hc]
  ring

theorem defect_at_zero (c : ℕ → ℂ) (K : ℝ) (N : ℕ) (hc : c 0 = 1) :
    defect c K N 0 = 1 := by
  simp [defect, partial_at_zero, hc]

theorem defect_succ_nonneg (c : ℕ → ℂ) (K : ℝ) (N : ℕ) (w : ℂ)
    (h : 0 ≤ defect c K N w) : 0 ≤ defect c K (N + 1) w := by
  rw [defect_succ]
  exact add_nonneg (mul_nonneg (Complex.normSq_nonneg w) h)
    (Complex.normSq_nonneg _)

theorem defect_succ_pos_of_ne_zero (c : ℕ → ℂ) (K : ℝ) (N : ℕ) (w : ℂ)
    (hw : w ≠ 0) (h : 0 < defect c K N w) : 0 < defect c K (N + 1) w := by
  rw [defect_succ]
  exact add_pos_of_pos_of_nonneg (mul_pos (Complex.normSq_pos.mpr hw) h)
    (Complex.normSq_nonneg _)

theorem defect_succ_pos (c : ℕ → ℂ) (K : ℝ) (N : ℕ) (w : ℂ)
    (hc : c 0 = 1) (h : 0 < defect c K N w) : 0 < defect c K (N + 1) w := by
  by_cases hw : w = 0
  · subst w
    rw [defect_at_zero c K (N + 1) hc]
    norm_num
  · exact defect_succ_pos_of_ne_zero c K N w hw h

theorem defect_nonneg_of_le (c : ℕ → ℂ) (K : ℝ) (w : ℂ) {N M : ℕ}
    (hNM : N ≤ M) (h : 0 ≤ defect c K N w) : 0 ≤ defect c K M w := by
  induction M, hNM using Nat.le_induction with
  | base => exact h
  | succ M _ ih => exact defect_succ_nonneg c K M w ih

theorem defect_pos_of_le (c : ℕ → ℂ) (K : ℝ) (w : ℂ) (hc : c 0 = 1)
    {N M : ℕ} (hNM : N ≤ M) (h : 0 < defect c K N w) :
    0 < defect c K M w := by
  induction M, hNM using Nat.le_induction with
  | base => exact h
  | succ M _ ih => exact defect_succ_pos c K M w hc ih

end FiveInduction.HardyDefect
