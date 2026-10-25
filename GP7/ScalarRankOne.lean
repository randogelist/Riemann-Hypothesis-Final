import Mathlib

/-!
# GP7.ScalarRankOne

Finite-dimensional rank-one threshold lemma. The infinite-dimensional GP-7
operator is defined in AnalyticObjects and remains a separate analytic
formalization target.
-/

namespace GP7

/-- Rank-one positivity and the critical scalar coupling, proved unconditionally. -/
theorem scalar_rank_one_threshold (a b τ : ℝ) (ha : 0 < a) (hb : b ≠ 0) :
    (∀ x : ℝ, 0 ≤ a * x ^ 2 - τ * (b * x) ^ 2) ↔ τ ≤ a / b ^ 2 := by
  have hb2 : 0 < b ^ 2 := sq_pos_of_ne_zero hb
  constructor
  · intro h
    have h1 := h 1
    have hcoef : τ * b ^ 2 ≤ a := by nlinarith [h1]
    exact (le_div_iff₀ hb2).2 hcoef
  · intro hτ x
    have hcoef : τ * b ^ 2 ≤ a := (le_div_iff₀ hb2).1 hτ
    have hprod : 0 ≤ (a - τ * b ^ 2) * x ^ 2 :=
      mul_nonneg (by linarith) (sq_nonneg _)
    nlinarith [hprod]

end GP7
