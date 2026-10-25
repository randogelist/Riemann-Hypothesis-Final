import Mathlib.Algebra.Polynomial.Eval.Defs
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Tactic

/-!
# Design 1: an actual sum-of-squares polynomial orbit

The update and its invariant are proved here. No application to the angular
derivative of xi is assumed or claimed by these theorems.
-/

namespace FiveInduction.SOS

open Polynomial

set_option autoImplicit false

noncomputable section

def sequence (δ : ℝ) (κ : ℕ → ℝ) (A B : ℕ → Polynomial ℝ) :
    ℕ → Polynomial ℝ
  | 0 => C δ
  | n + 1 => C (κ n) * sequence δ κ A B n + (A n) ^ 2 +
      (1 - X ^ 2) * (B n) ^ 2

theorem eval_succ (δ : ℝ) (κ : ℕ → ℝ) (A B : ℕ → Polynomial ℝ)
    (n : ℕ) (x : ℝ) :
    (sequence δ κ A B (n + 1)).eval x =
      κ n * (sequence δ κ A B n).eval x + (A n |>.eval x) ^ 2 +
      (1 - x ^ 2) * (B n |>.eval x) ^ 2 := by
  simp [sequence]

theorem one_sub_sq_nonneg (x : ℝ) (hx : x ∈ Set.Icc (-1 : ℝ) 1) :
    0 ≤ 1 - x ^ 2 := by
  have h : 0 ≤ (1 - x) * (1 + x) :=
    mul_nonneg (by linarith [hx.2]) (by linarith [hx.1])
  nlinarith

theorem step_lower_bound (δ : ℝ) (κ : ℕ → ℝ) (A B : ℕ → Polynomial ℝ)
    (n : ℕ) (x : ℝ) (hx : x ∈ Set.Icc (-1 : ℝ) 1) :
    κ n * (sequence δ κ A B n).eval x ≤
      (sequence δ κ A B (n + 1)).eval x := by
  rw [eval_succ]
  have h := mul_nonneg (one_sub_sq_nonneg x hx) (sq_nonneg ((B n).eval x))
  nlinarith [sq_nonneg ((A n).eval x)]

theorem lower_bound (δ : ℝ) (κ : ℕ → ℝ) (A B : ℕ → Polynomial ℝ)
    (hκ : ∀ n, 0 ≤ κ n) (n : ℕ) (x : ℝ)
    (hx : x ∈ Set.Icc (-1 : ℝ) 1) :
    δ * ∏ j ∈ Finset.range n, κ j ≤ (sequence δ κ A B n).eval x := by
  induction n with
  | zero => simp [sequence]
  | succ n ih =>
      calc
        δ * ∏ j ∈ Finset.range (n + 1), κ j =
            κ n * (δ * ∏ j ∈ Finset.range n, κ j) := by
              rw [Finset.prod_range_succ]
              ring
        _ ≤ κ n * (sequence δ κ A B n).eval x :=
          mul_le_mul_of_nonneg_left ih (hκ n)
        _ ≤ (sequence δ κ A B (n + 1)).eval x :=
          step_lower_bound δ κ A B n x hx

theorem all_positive (δ : ℝ) (κ : ℕ → ℝ) (A B : ℕ → Polynomial ℝ)
    (hδ : 0 < δ) (hκ : ∀ n, 0 < κ n) (n : ℕ) (x : ℝ)
    (hx : x ∈ Set.Icc (-1 : ℝ) 1) :
    0 < (sequence δ κ A B n).eval x := by
  have hp : 0 < ∏ j ∈ Finset.range n, κ j :=
    Finset.prod_pos (fun j _ => hκ j)
  exact lt_of_lt_of_le (mul_pos hδ hp)
    (lower_bound δ κ A B (fun j => le_of_lt (hκ j)) n x hx)

end

end FiveInduction.SOS
