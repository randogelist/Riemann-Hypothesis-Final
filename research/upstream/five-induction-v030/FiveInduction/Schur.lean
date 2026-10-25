import Mathlib.Analysis.Complex.Norm
import Mathlib.Algebra.Polynomial.Reverse
import Mathlib.Tactic

/-!
# A paired Schur induction on the closed unit disk

This module proves the preservation mechanism directly from a norm-square
identity. It does not assume Rouche's theorem or a zero-free preservation law.

For real parameters `a n`, the two generated polynomial functions obey
`p' = p + a*z*q` and `q' = a*p + z*q`, starting from `p = q = 1`.
The joint invariant is `p != 0` and `norm q <= norm p` on `norm z <= 1`.
The module also constructs the underlying complex polynomials, identifies
their evaluations, and proves reciprocal identities with the formal degree
bound `n` (the natural degree can drop when a parameter is zero).
The module does not identify this generated sequence with the actual xi/theta
function, and makes no RH claim.
-/

set_option autoImplicit false

noncomputable section

namespace FiveInduction.Schur

open scoped ComplexConjugate

/-- The exact elementary identity underlying the paired update. -/
theorem normSq_gap (a : ℝ) (p w : ℂ) :
    Complex.normSq (p + (a : ℂ) * w) -
      Complex.normSq ((a : ℂ) * p + w) =
        (1 - a ^ 2) * (Complex.normSq p - Complex.normSq w) := by
  simp only [Complex.normSq_apply, Complex.add_re, Complex.add_im,
    Complex.mul_re, Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im]
  ring

/-- A norm bound after multiplication by a point in the closed unit disk. -/
theorem disk_mul_norm_le {p q z : ℂ}
    (hz : ‖z‖ ≤ 1) (hqp : ‖q‖ ≤ ‖p‖) : ‖z * q‖ ≤ ‖p‖ := by
  calc
    ‖z * q‖ = ‖z‖ * ‖q‖ := norm_mul z q
    _ ≤ 1 * ‖q‖ := mul_le_mul_of_nonneg_right hz (norm_nonneg q)
    _ ≤ ‖p‖ := by simpa using hqp

/-- The explicit multiplicative margin of the first component. -/
theorem step_margin (a : ℝ) {p w : ℂ} (hwp : ‖w‖ ≤ ‖p‖) :
    (1 - |a|) * ‖p‖ ≤ ‖p + (a : ℂ) * w‖ := by
  have haw : ‖(a : ℂ) * w‖ ≤ |a| * ‖p‖ := by
    rw [norm_mul, Complex.norm_real, Real.norm_eq_abs]
    exact mul_le_mul_of_nonneg_left hwp (abs_nonneg a)
  have ht : ‖p‖ ≤ ‖p + (a : ℂ) * w‖ + ‖(a : ℂ) * w‖ := by
    simpa only [add_neg_cancel_right, norm_neg] using
      (norm_add_le (p + (a : ℂ) * w) (-((a : ℂ) * w)))
  nlinarith

/-- Norm dominance is preserved by the paired real-parameter update. -/
theorem step_dominance {a : ℝ} (ha : |a| < 1) {p w : ℂ}
    (hwp : ‖w‖ ≤ ‖p‖) :
    ‖(a : ℂ) * p + w‖ ≤ ‖p + (a : ℂ) * w‖ := by
  have ha2 : a ^ 2 < 1 := (sq_lt_one_iff_abs_lt_one a).mpr ha
  have hsq : Complex.normSq w ≤ Complex.normSq p := by
    rw [Complex.normSq_eq_norm_sq, Complex.normSq_eq_norm_sq]
    exact (sq_le_sq₀ (norm_nonneg w) (norm_nonneg p)).mpr hwp
  have hprod : 0 ≤ (1 - a ^ 2) * (Complex.normSq p - Complex.normSq w) :=
    mul_nonneg (by linarith) (sub_nonneg.mpr hsq)
  have hgap := normSq_gap a p w
  have hnew : Complex.normSq ((a : ℂ) * p + w) ≤
      Complex.normSq (p + (a : ℂ) * w) := by linarith
  rw [Complex.normSq_eq_norm_sq, Complex.normSq_eq_norm_sq] at hnew
  exact (sq_le_sq₀ (norm_nonneg _) (norm_nonneg _)).mp hnew

/-- The entire one-step preservation proof, including nonvanishing. -/
theorem step_preserves {a : ℝ} (ha : |a| < 1) {p q z : ℂ}
    (hz : ‖z‖ ≤ 1) (hp : p ≠ 0) (hqp : ‖q‖ ≤ ‖p‖) :
    p + (a : ℂ) * (z * q) ≠ 0 ∧
      ‖(a : ℂ) * p + z * q‖ ≤ ‖p + (a : ℂ) * (z * q)‖ := by
  have hwp := disk_mul_norm_le hz hqp
  have hpositive : 0 < (1 - |a|) * ‖p‖ :=
    mul_pos (sub_pos.mpr ha) (norm_pos_iff.mpr hp)
  constructor
  · exact norm_pos_iff.mp (lt_of_lt_of_le hpositive (step_margin a hwp))
  · exact step_dominance ha hwp

/-- The actual coupled recurrence, rather than an assumed invariant. -/
def pair (a : ℕ → ℝ) (z : ℂ) : ℕ → ℂ × ℂ
  | 0 => (1, 1)
  | n + 1 =>
    let v := pair a z n
    (v.1 + (a n : ℂ) * (z * v.2), (a n : ℂ) * v.1 + z * v.2)

def p (a : ℕ → ℝ) (n : ℕ) (z : ℂ) : ℂ := (pair a z n).1

def q (a : ℕ → ℝ) (n : ℕ) (z : ℂ) : ℂ := (pair a z n).2

@[simp] theorem p_zero (a : ℕ → ℝ) (z : ℂ) : p a 0 z = 1 := rfl

@[simp] theorem q_zero (a : ℕ → ℝ) (z : ℂ) : q a 0 z = 1 := rfl

theorem p_succ (a : ℕ → ℝ) (n : ℕ) (z : ℂ) :
    p a (n + 1) z = p a n z + (a n : ℂ) * (z * q a n z) := rfl

theorem q_succ (a : ℕ → ℝ) (n : ℕ) (z : ℂ) :
    q a (n + 1) z = (a n : ℂ) * p a n z + z * q a n z := rfl

/-- The two components are reciprocal with the formal degree bound `n`.
This statement remains correct when the natural degree drops. -/
theorem reciprocal_pair (a : ℕ → ℝ) (n : ℕ) (z : ℂ) (hz : z ≠ 0) :
    q a n z = z ^ n * p a n (1 / z) ∧
      p a n z = z ^ n * q a n (1 / z) := by
  induction n with
  | zero => simp
  | succ n ih =>
      simp only [p_succ, q_succ, pow_succ]
      constructor
      · rw [ih.1, ih.2]
        field_simp
        ring
      · rw [ih.1, ih.2]
        field_simp
        ring

/-- The first update is exactly the reciprocal-polynomial Schur update. -/
theorem p_succ_reciprocal (a : ℕ → ℝ) (n : ℕ) (z : ℂ) (hz : z ≠ 0) :
    p a (n + 1) z = p a n z + (a n : ℂ) * z ^ (n + 1) * p a n (1 / z) := by
  rw [p_succ, (reciprocal_pair a n z hz).1, pow_succ]
  ring

/-- Real parameters give conjugation-symmetric polynomial functions. -/
theorem conjugate_pair (a : ℕ → ℝ) (n : ℕ) (z : ℂ) :
    conj (p a n z) = p a n (conj z) ∧
      conj (q a n z) = q a n (conj z) := by
  induction n with
  | zero => simp
  | succ n ih =>
      simp only [p_succ, q_succ, map_add, map_mul, Complex.conj_ofReal,
        ih.1, ih.2, and_self]

/-- This is exactly the usual conjugate reverse with formal degree bound `n`. -/
theorem q_eq_conjugate_reverse (a : ℕ → ℝ) (n : ℕ) (z : ℂ) (hz : z ≠ 0) :
    q a n z = z ^ n * conj (p a n (1 / conj z)) := by
  have hc : conj (p a n (1 / conj z)) = p a n (1 / z) := by
    simpa using (conjugate_pair a n (1 / conj z)).1
  rw [hc]
  exact (reciprocal_pair a n z hz).1

/-- Polynomial objects whose evaluation gives the paired recurrence. -/
def polyPair (a : ℕ → ℝ) : ℕ → Polynomial ℂ × Polynomial ℂ
  | 0 => (1, 1)
  | n + 1 =>
    let v := polyPair a n
    (v.1 + Polynomial.C (a n : ℂ) * (Polynomial.X * v.2),
      Polynomial.C (a n : ℂ) * v.1 + Polynomial.X * v.2)

def pPoly (a : ℕ → ℝ) (n : ℕ) : Polynomial ℂ := (polyPair a n).1

def qPoly (a : ℕ → ℝ) (n : ℕ) : Polynomial ℂ := (polyPair a n).2

theorem pPoly_succ (a : ℕ → ℝ) (n : ℕ) :
    pPoly a (n + 1) = pPoly a n + Polynomial.C (a n : ℂ) *
      (Polynomial.X * qPoly a n) := rfl

theorem qPoly_succ (a : ℕ → ℝ) (n : ℕ) :
    qPoly a (n + 1) = Polynomial.C (a n : ℂ) * pPoly a n +
      Polynomial.X * qPoly a n := rfl

theorem poly_eval_pair (a : ℕ → ℝ) (n : ℕ) (z : ℂ) :
    (pPoly a n).eval z = p a n z ∧ (qPoly a n).eval z = q a n z := by
  induction n with
  | zero => simp [pPoly, qPoly, polyPair]
  | succ n ih =>
      simp only [pPoly_succ, qPoly_succ, p_succ, q_succ,
        Polynomial.eval_add, Polynomial.eval_mul, Polynomial.eval_C,
        Polynomial.eval_X, ih.1, ih.2, and_self]

@[simp] theorem pPoly_eval (a : ℕ → ℝ) (n : ℕ) (z : ℂ) :
    (pPoly a n).eval z = p a n z := (poly_eval_pair a n z).1

@[simp] theorem qPoly_eval (a : ℕ → ℝ) (n : ℕ) (z : ℂ) :
    (qPoly a n).eval z = q a n z := (poly_eval_pair a n z).2

/-- The formal reciprocal exponent is an actual bound on both polynomial degrees. -/
theorem poly_natDegree_le (a : ℕ → ℝ) (n : ℕ) :
    (pPoly a n).natDegree ≤ n ∧ (qPoly a n).natDegree ≤ n := by
  induction n with
  | zero => simp [pPoly, qPoly, polyPair]
  | succ n ih =>
      have hxq : (Polynomial.X * qPoly a n).natDegree ≤ n + 1 := by
        calc
          (Polynomial.X * qPoly a n).natDegree ≤
              (Polynomial.X : Polynomial ℂ).natDegree + (qPoly a n).natDegree :=
            Polynomial.natDegree_mul_le
          _ ≤ n + 1 := by simp only [Polynomial.natDegree_X]; omega
      have hcp : (Polynomial.C (a n : ℂ) * pPoly a n).natDegree ≤ n :=
        (Polynomial.natDegree_C_mul_le _ _).trans ih.1
      constructor
      · rw [pPoly_succ]
        exact Polynomial.natDegree_add_le_of_degree_le (Nat.le_succ_of_le ih.1)
          ((Polynomial.natDegree_C_mul_le _ _).trans hxq)
      · rw [qPoly_succ]
        exact Polynomial.natDegree_add_le_of_degree_le (Nat.le_succ_of_le hcp) hxq

/-- Only the finite parameter prefix is required for a finite-stage certificate. -/
theorem closedDisk_invariant (a : ℕ → ℝ) (n : ℕ) :
    (∀ k < n, |a k| < 1) → ∀ z : ℂ, ‖z‖ ≤ 1 →
      p a n z ≠ 0 ∧ ‖q a n z‖ ≤ ‖p a n z‖ := by
  induction n with
  | zero =>
      intro ha z hz
      simp
  | succ n ih =>
      intro ha z hz
      have hprev := ih (fun k hk => ha k (Nat.lt_succ_of_lt hk)) z hz
      simpa only [p_succ, q_succ] using
        step_preserves (ha n (Nat.lt_succ_self n)) hz hprev.1 hprev.2

/-- Every generated stage is zero-free on the closed unit disk. -/
theorem closedDisk_nonzero (a : ℕ → ℝ) (ha : ∀ n, |a n| < 1)
    (n : ℕ) (z : ℂ) (hz : ‖z‖ ≤ 1) : p a n z ≠ 0 :=
  (closedDisk_invariant a n (fun k _ => ha k) z hz).1

/-- The normalization is preserved without restrictions on the parameters. -/
@[simp] theorem p_at_zero (a : ℕ → ℝ) (n : ℕ) : p a n 0 = 1 := by
  cases n with
  | zero => rfl
  | succ n => simpa only [p_succ, zero_mul, mul_zero, add_zero] using p_at_zero a n

/-- A computable finite product margin, written recursively. -/
def margin (a : ℕ → ℝ) : ℕ → ℝ
  | 0 => 1
  | n + 1 => (1 - |a n|) * margin a n

theorem margin_pos (a : ℕ → ℝ) (n : ℕ) :
    (∀ k < n, |a k| < 1) → 0 < margin a n := by
  induction n with
  | zero => intro ha; norm_num [margin]
  | succ n ih =>
      intro ha
      exact mul_pos (sub_pos.mpr (ha n (Nat.lt_succ_self n)))
        (ih (fun k hk => ha k (Nat.lt_succ_of_lt hk)))

/-- The margin holds on the whole closed disk, including its boundary. -/
theorem closedDisk_margin (a : ℕ → ℝ) (n : ℕ) :
    (∀ k < n, |a k| < 1) → ∀ z : ℂ, ‖z‖ ≤ 1 →
      margin a n ≤ ‖p a n z‖ := by
  induction n with
  | zero => intro ha z hz; simp [margin]
  | succ n ih =>
      intro ha z hz
      have hprefix : ∀ k < n, |a k| < 1 := fun k hk => ha k (Nat.lt_succ_of_lt hk)
      have hdom := (closedDisk_invariant a n hprefix z hz).2
      have hbound := step_margin (a n) (disk_mul_norm_le hz hdom)
      rw [p_succ]
      exact le_trans
        (mul_le_mul_of_nonneg_left (ih hprefix z hz)
          (le_of_lt (sub_pos.mpr (ha n (Nat.lt_succ_self n))))) hbound

/-- A fully specified admissible parameter sequence and its exact margin. -/
theorem half_parameter_margin (n : ℕ) :
    margin (fun _ => (1 / 2 : ℝ)) n = (1 / 2 : ℝ) ^ n := by
  induction n with
  | zero => norm_num [margin]
  | succ n ih =>
      rw [margin, ih, pow_succ]
      norm_num
      ring

/-- A concrete all-stage lower bound, independent of any analytic bridge. -/
theorem half_parameter_closedDisk_bound (n : ℕ) (z : ℂ) (hz : ‖z‖ ≤ 1) :
    (1 / 2 : ℝ) ^ n ≤ ‖p (fun _ => (1 / 2 : ℝ)) n z‖ := by
  rw [← half_parameter_margin]
  exact closedDisk_margin _ n (by intro k hk; norm_num) z hz

end FiveInduction.Schur
