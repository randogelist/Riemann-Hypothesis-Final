import Mathlib.Analysis.Complex.Polynomial.Basic
import Mathlib.Analysis.Analytic.Polynomial
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.NormNum

/-!
# The symmetric Jacobi / Sturm induction

The polynomial family is constructed, rather than supplied through a
root-preservation interface.  Its nonreal nonvanishing is proved directly
from a conjugate-product imaginary-part identity.  No assertion identifying
these polynomials or their limits with Riemann xi is made here.
-/

noncomputable section

namespace FiveInduction.Sturm

open Polynomial
open scoped BigOperators ComplexConjugate

/-- Symmetric three-term Jacobi polynomials.  The entry `b 0` is unused. -/
def J (b : ℕ → ℝ) : ℕ → ℝ[X]
  | 0 => 1
  | 1 => X
  | n + 2 => X * J b (n + 1) - C (b (n + 1)) * J b n

@[simp] theorem J_zero (b : ℕ → ℝ) : J b 0 = 1 := rfl
@[simp] theorem J_one (b : ℕ → ℝ) : J b 1 = X := rfl
theorem J_step (b : ℕ → ℝ) (n : ℕ) :
    J b (n + 2) = X * J b (n + 1) - C (b (n + 1)) * J b n := rfl

/-- Evaluation in the actual complex numbers, via the real coefficient map. -/
def value (b : ℕ → ℝ) (n : ℕ) (z : ℂ) : ℂ :=
  (J b n).eval₂ Complex.ofRealHom z

@[simp] theorem value_zero (b : ℕ → ℝ) (z : ℂ) : value b 0 z = 1 := by
  simp [value]

@[simp] theorem value_one (b : ℕ → ℝ) (z : ℂ) : value b 1 z = z := by
  simp [value]

theorem value_step (b : ℕ → ℝ) (n : ℕ) (z : ℂ) :
    value b (n + 2) z = z * value b (n + 1) z -
      (b (n + 1) : ℂ) * value b n z := by
  simp [value, J_step]

/-- The elementary identity behind the Sturm sign induction. -/
theorem imaginary_step (z u v : ℂ) (c : ℝ) :
    ((z * u - (c : ℂ) * v) * conj u).im =
      z.im * Complex.normSq u + c * (u * conj v).im := by
  simp only [Complex.mul_im, Complex.mul_re, Complex.sub_re, Complex.sub_im,
    Complex.conj_re, Complex.conj_im, Complex.ofReal_re, Complex.ofReal_im,
    Complex.normSq_apply]
  ring

def wronskian (b : ℕ → ℝ) (n : ℕ) (z : ℂ) : ℝ :=
  (value b (n + 1) z * conj (value b n z)).im

@[simp] theorem wronskian_zero (b : ℕ → ℝ) (z : ℂ) :
    wronskian b 0 z = z.im := by
  simp [wronskian]

theorem wronskian_step (b : ℕ → ℝ) (n : ℕ) (z : ℂ) :
    wronskian b (n + 1) z =
      z.im * Complex.normSq (value b (n + 1) z) +
        b (n + 1) * wronskian b n z := by
  change (value b (n + 2) z * conj (value b (n + 1) z)).im = _
  rw [value_step, imaginary_step]
  rfl

/-- One induction treats the upper and lower half-planes simultaneously. -/
theorem imaginary_wronskian_pos (b : ℕ → ℝ)
    (hb : ∀ n, 0 < b (n + 1)) (z : ℂ) (hz : z.im ≠ 0) (n : ℕ) :
    0 < z.im * wronskian b n z := by
  induction n with
  | zero =>
      simpa only [wronskian_zero, ← pow_two] using sq_pos_of_ne_zero hz
  | succ n ih =>
      rw [wronskian_step]
      have hfirst : 0 ≤ z.im ^ 2 * Complex.normSq (value b (n + 1) z) :=
        mul_nonneg (sq_nonneg _) (Complex.normSq_nonneg _)
      have hsecond : 0 < b (n + 1) * (z.im * wronskian b n z) :=
        mul_pos (hb n) ih
      nlinarith

/-- Every actual complex zero of every constructed polynomial is real. -/
theorem all_nonreal_nonzero (b : ℕ → ℝ)
    (hb : ∀ n, 0 < b (n + 1)) (n : ℕ) (z : ℂ) (hz : z.im ≠ 0) :
    value b n z ≠ 0 := by
  cases n with
  | zero => simp
  | succ n =>
      intro hzero
      have hp := imaginary_wronskian_pos b hb z hz n
      simp [wronskian, hzero] at hp

theorem zero_im_eq_zero (b : ℕ → ℝ)
    (hb : ∀ n, 0 < b (n + 1)) (n : ℕ) (z : ℂ)
    (hz : value b n z = 0) : z.im = 0 := by
  by_contra h
  exact all_nonreal_nonzero b hb n z h hz

/-- Exact parity of the evaluated polynomial family. -/
theorem parity (b : ℕ → ℝ) (n : ℕ) (z : ℂ) :
    value b n (-z) = (-1 : ℂ) ^ n * value b n z := by
  induction n using Nat.twoStepInduction with
  | zero => simp
  | one => simp
  | more n ih0 ih1 =>
      rw [value_step, value_step, ih0, ih1]
      simp only [pow_succ]
      ring

theorem eval_zero_step (b : ℕ → ℝ) (n : ℕ) :
    (J b (n + 2)).eval 0 = -b (n + 1) * (J b n).eval 0 := by
  simp [J_step]

theorem odd_zero (b : ℕ → ℝ) (n : ℕ) :
    (J b (2 * n + 1)).eval 0 = 0 := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [show 2 * (n + 1) + 1 = (2 * n + 1) + 2 by omega,
        eval_zero_step, ih, mul_zero]

/-- The even constant term is an explicit nonempty-product-free formula. -/
theorem even_zero_formula (b : ℕ → ℝ) (n : ℕ) :
    (J b (2 * n)).eval 0 =
      (-1 : ℝ) ^ n * ∏ k ∈ Finset.range n, b (2 * k + 1) := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [show 2 * (n + 1) = 2 * n + 2 by omega,
        eval_zero_step, ih, Finset.prod_range_succ, pow_succ]
      ring

/-- Thus every even polynomial can be normalized at the origin. -/
theorem even_zero_ne (b : ℕ → ℝ)
    (hb : ∀ n, 0 < b (n + 1)) (n : ℕ) :
    (J b (2 * n)).eval 0 ≠ 0 := by
  rw [even_zero_formula]
  apply mul_ne_zero (pow_ne_zero _ (by norm_num))
  apply Finset.prod_ne_zero_iff.mpr
  intro k hk
  exact ne_of_gt (hb (2 * k))

theorem value_at_zero (b : ℕ → ℝ) (n : ℕ) :
    value b n 0 = Complex.ofReal ((J b n).eval (0 : ℝ)) := by
  simpa [value] using
    (Polynomial.eval₂_at_apply (p := J b n) Complex.ofRealHom (0 : ℝ))

/-- The even Jacobi polynomial, normalized to have value one at the origin. -/
def normalized (b : ℕ → ℝ) (n : ℕ) (z : ℂ) : ℂ :=
  value b (2 * n) z / Complex.ofReal ((J b (2 * n)).eval (0 : ℝ))

@[simp] theorem normalized_zero (b : ℕ → ℝ)
    (hb : ∀ n, 0 < b (n + 1)) (n : ℕ) :
    normalized b n 0 = 1 := by
  unfold normalized
  rw [value_at_zero]
  exact div_self (Complex.ofReal_ne_zero.mpr (even_zero_ne b hb n))

theorem normalized_nonreal_nonzero (b : ℕ → ℝ)
    (hb : ∀ n, 0 < b (n + 1)) (n : ℕ) (z : ℂ) (hz : z.im ≠ 0) :
    normalized b n z ≠ 0 := by
  exact div_ne_zero (all_nonreal_nonzero b hb (2 * n) z hz)
    (Complex.ofReal_ne_zero.mpr (even_zero_ne b hb n))

theorem normalized_parity (b : ℕ → ℝ) (n : ℕ) (z : ℂ) :
    normalized b n (-z) = normalized b n z := by
  unfold normalized
  rw [parity]
  simp [pow_mul]

theorem value_analytic (b : ℕ → ℝ) (n : ℕ) :
    AnalyticOnNhd ℂ (value b n) Set.univ := by
  change AnalyticOnNhd ℂ (fun z => (J b n).eval₂ Complex.ofRealHom z) Set.univ
  simpa only [value, Polynomial.eval₂_eq_eval_map] using
    (AnalyticOnNhd.eval_polynomial (𝕜 := ℂ) ((J b n).map Complex.ofRealHom))

theorem normalized_analytic (b : ℕ → ℝ) (n : ℕ) :
    AnalyticOnNhd ℂ (normalized b n) Set.univ := by
  exact (value_analytic b (2 * n)).div_const

end FiveInduction.Sturm
