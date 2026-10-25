import Mathlib

/-!
# Universal residual-contraction arithmetic (witness independent)

This lemma carries the n -> n+1 residual budget to every natural number.
No actual xi error estimate or candidate generator is asserted here.
-/
set_option autoImplicit false
noncomputable section
namespace SoloboloAdmission

structure ResidualBudget (e : ℕ → ℝ) where
  base : e 0 ≤ 1
  successor : ∀ n : ℕ,
    e (n + 1) ≤ (1 / 2 : ℝ) * e n + (1 / 2 : ℝ) ^ (n + 1)

theorem ResidualBudget.upper {e : ℕ → ℝ} (C : ResidualBudget e) :
    ∀ n : ℕ, e n ≤ ((n + 1 : ℕ) : ℝ) * (1 / 2 : ℝ) ^ n := by
  intro n
  induction n with
  | zero =>
      simpa using C.base
  | succ n ih =>
      calc
        e (n + 1) ≤ (1 / 2 : ℝ) * e n + (1 / 2 : ℝ) ^ (n + 1) :=
          C.successor n
        _ ≤ (1 / 2 : ℝ) * ((n + 1 : ℕ) : ℝ) *
              (1 / 2 : ℝ) ^ n + (1 / 2 : ℝ) ^ (n + 1) := by
                have h := mul_le_mul_of_nonneg_left ih
                  (show (0 : ℝ) ≤ 1 / 2 by norm_num)
                nlinarith
        _ = (((n + 1 + 1 : ℕ) : ℝ)) * (1 / 2 : ℝ) ^ (n + 1) := by
          simp only [pow_succ, Nat.cast_add, Nat.cast_one]
          ring

end SoloboloAdmission
