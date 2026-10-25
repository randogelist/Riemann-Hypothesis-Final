import Mathlib

/-!
# GP7.CoreAlgebra

Unconditional finite algebra for the explicit GP-7 contracting polynomial.
This module does not state that the logarithmic-moment integral equals ζ(7).
There are no axioms or sorry declarations in this module.
-/

namespace GP7

private def t (y : ℝ) : ℝ := y * (1 - y)
private def a (y : ℝ) : ℝ := t y * (8 * t y - 1)

/-- The common nonnegative contraction base. -/
noncomputable def base (y : ℝ) : ℝ :=
  (((1 - 2 * y) / 3) ^ 4) * ((a y / 34) ^ 2)

/-- The two-Gaussian GP-7 polynomial. -/
noncomputable def R (N : ℕ) (y : ℝ) : ℝ :=
  ((1 - 2 * y) / 3) * (base y) ^ N

theorem t_reflect (y : ℝ) : t (1 - y) = t y := by
  unfold t
  ring

theorem a_reflect (y : ℝ) : a (1 - y) = a y := by
  simp [a, t_reflect]

theorem base_reflect (y : ℝ) : base (1 - y) = base y := by
  unfold base
  rw [a_reflect]
  have h : (1 - 2 * (1 - y)) / (3 : ℝ) = -((1 - 2 * y) / 3) := by ring
  rw [h]
  ring

theorem R_reflect (N : ℕ) (y : ℝ) : R N (1 - y) = -R N y := by
  unfold R
  rw [base_reflect]
  ring

theorem R_at_neg_one (N : ℕ) : R N (-1) = 1 := by
  norm_num [R, base, a, t]

theorem base_nonneg (y : ℝ) : 0 ≤ base y := by
  unfold base
  positivity

/-- The contraction constant is exactly `1/161803008`. -/
theorem base_upper_on_unit (y : ℝ) (hy0 : 0 ≤ y) (hy1 : y ≤ 1) :
    base y ≤ (1 : ℝ) / 161803008 := by
  let s : ℝ := (1 - 2 * y) ^ 2
  let u : ℝ := s * (1 - s)
  have hprod : 0 ≤ y * (1 - y) :=
    mul_nonneg hy0 (sub_nonneg.mpr hy1)
  have hs0 : 0 ≤ s := sq_nonneg _
  have hs1 : s ≤ 1 := by
    dsimp [s]
    nlinarith [hprod]
  have hu0 : 0 ≤ u := mul_nonneg hs0 (sub_nonneg.mpr hs1)
  have hpos : 0 ≤ (1 - 6 * u) ^ 2 * (1 + 12 * u) :=
    mul_nonneg (sq_nonneg _) (by linarith)
  have hid :
      1 - 161803008 * base y = (1 - 6 * u) ^ 2 * (1 + 12 * u) := by
    dsimp [base, a, t, u, s]
    ring
  nlinarith [hpos]

/-- Uniform bound for the polynomial on the unit interval. -/
theorem R_abs_upper_on_unit (N : ℕ) (y : ℝ)
    (hy0 : 0 ≤ y) (hy1 : y ≤ 1) :
    |R N y| ≤ (1 : ℝ) / 3 * ((1 : ℝ) / 161803008) ^ N := by
  have hfactor : |(1 - 2 * y) / (3 : ℝ)| ≤ (1 : ℝ) / 3 := by
    apply abs_le.mpr
    constructor <;> linarith
  have hpow : (base y) ^ N ≤ ((1 : ℝ) / 161803008) ^ N :=
    pow_le_pow_left₀ (base_nonneg y) (base_upper_on_unit y hy0 hy1) N
  calc
    |R N y| = |(1 - 2 * y) / 3| * (base y) ^ N := by
      rw [R, abs_mul, abs_pow, abs_of_nonneg (base_nonneg y)]
    _ ≤ (1 / 3 : ℝ) * (base y) ^ N :=
      mul_le_mul_of_nonneg_right hfactor (pow_nonneg (base_nonneg y) N)
    _ ≤ (1 / 3 : ℝ) * ((1 : ℝ) / 161803008) ^ N :=
      mul_le_mul_of_nonneg_left hpow (by norm_num)

end GP7
