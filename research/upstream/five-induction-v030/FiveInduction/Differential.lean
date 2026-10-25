import Mathlib

set_option autoImplicit false
set_option maxHeartbeats 1600000

/-!
Actual preservation of strictly negative real polynomial zeros under
`p ↦ r + τ r'`, where `r = (X + a) p`, `a > 0`, and `τ ≥ 0`.
The logarithmic derivative proof is supplied here; preservation is not a premise.
-/
namespace FiveInduction.Differential

noncomputable section

open Polynomial
open scoped Polynomial

/-- Every complex zero is real and strictly negative; the polynomial is nonzero. -/
def NegativeRealRoots (p : ℂ[X]) : Prop :=
  p ≠ 0 ∧ ∀ z : ℂ, p.eval z = 0 → z.im = 0 ∧ z.re < 0

private def rootSum (s : Multiset ℂ) (z : ℂ) : ℂ :=
  (s.map (fun w => 1 / (z - w))).sum

private theorem rootSum_im (s : Multiset ℂ) (z : ℂ)
    (hs : ∀ w ∈ s, w.im = 0) :
    (rootSum s z).im =
      -z.im * (s.map (fun w => (Complex.normSq (z - w))⁻¹)).sum := by
  induction s using Multiset.induction_on with
  | empty => simp [rootSum]
  | @cons w s ih =>
    have hw : w.im = 0 := hs w (by simp)
    have ht : ∀ v ∈ s, v.im = 0 := fun v hv => hs v (by simp [hv])
    simp only [rootSum, Multiset.map_cons, Multiset.sum_cons, Complex.add_im]
    rw [show ((s.map (fun v => 1 / (z - v))).sum).im =
        -z.im * (s.map (fun v => (Complex.normSq (z - v))⁻¹)).sum from ih ht]
    simp only [one_div, Complex.inv_im, Complex.sub_im, hw, sub_zero]
    simp only [div_eq_mul_inv]
    ring

private theorem rootSum_re_nonneg (s : Multiset ℂ) (z : ℂ)
    (hz : 0 ≤ z.re) (hs : ∀ w ∈ s, w.re < 0) :
    0 ≤ (rootSum s z).re := by
  induction s using Multiset.induction_on with
  | empty => simp [rootSum]
  | @cons w s ih =>
    have hw : w.re < 0 := hs w (by simp)
    have ht : ∀ v ∈ s, v.re < 0 := fun v hv => hs v (by simp [hv])
    have hhead : 0 ≤ (1 / (z - w)).re := by
      simp only [one_div, Complex.inv_re, Complex.sub_re]
      exact div_nonneg (by linarith) (Complex.normSq_nonneg _)
    have htail := ih ht
    simpa [rootSum] using add_nonneg hhead htail

private theorem reciprocalNormSum_pos (s : Multiset ℂ) (z : ℂ)
    (hs : s ≠ 0) (hz : ∀ w ∈ s, z - w ≠ 0) :
    0 < (s.map (fun w => (Complex.normSq (z - w))⁻¹)).sum := by
  have h := Multiset.sum_lt_sum_of_nonempty
    (s := s) (f := fun _ : ℂ => (0 : ℝ))
    (g := fun w => (Complex.normSq (z - w))⁻¹) hs
    (fun w hw => inv_pos.mpr (Complex.normSq_pos.mpr (hz w hw)))
  simpa using h

/-- The elementary differential perturbation of a complex polynomial. -/
def differentialStep (p : ℂ[X]) (τ : ℝ) : ℂ[X] :=
  p + Polynomial.C (τ : ℂ) * p.derivative

private theorem root_of_differentialStep (p : ℂ[X]) (τ : ℝ)
    (hp : NegativeRealRoots p) (hτ : 0 ≤ τ)
    (z : ℂ) (hz : (differentialStep p τ).eval z = 0) :
    z.im = 0 ∧ z.re < 0 := by
  by_cases hpz : p.eval z = 0
  · exact hp.2 z hpz
  have heval : p.eval z + (τ : ℂ) * p.derivative.eval z = 0 := by
    simpa [differentialStep] using hz
  have hquot : 1 + (τ : ℂ) * (p.derivative.eval z / p.eval z) = 0 := by
    apply (mul_eq_zero.mp (show p.eval z *
      (1 + (τ : ℂ) * (p.derivative.eval z / p.eval z)) = 0 from ?_)).resolve_left hpz
    calc
      _ = p.eval z + (τ : ℂ) * p.derivative.eval z := by
        field_simp
      _ = 0 := heval
  rw [(IsAlgClosed.splits p).eval_derivative_div_eval_of_ne_zero hpz] at hquot
  change 1 + (τ : ℂ) * rootSum p.roots z = 0 at hquot
  have hτne : τ ≠ 0 := by
    intro h
    simp [h] at hquot
  have hroots : ∀ w ∈ p.roots, w.im = 0 ∧ w.re < 0 := by
    intro w hw
    exact hp.2 w ((Polynomial.mem_roots hp.1).mp hw)
  have hsne : p.roots ≠ 0 := by
    intro h
    simp [rootSum, h] at hquot
  have hdiff : ∀ w ∈ p.roots, z - w ≠ 0 := by
    intro w hw hzero
    have hzw : z = w := sub_eq_zero.mp hzero
    apply hpz
    rw [hzw]
    exact (Polynomial.mem_roots hp.1).mp hw
  have hweight := reciprocalNormSum_pos p.roots z hsne hdiff
  have him : τ * (rootSum p.roots z).im = 0 := by
    simpa using congrArg Complex.im hquot
  have hsim : (rootSum p.roots z).im = 0 :=
    (mul_eq_zero.mp him).resolve_left hτne
  have hzIm : z.im = 0 := by
    rw [rootSum_im p.roots z (fun w hw => (hroots w hw).1)] at hsim
    have : -z.im = 0 := (mul_eq_zero.mp hsim).resolve_right (ne_of_gt hweight)
    linarith
  refine ⟨hzIm, ?_⟩
  by_contra hnot
  have hzr : 0 ≤ z.re := le_of_not_gt hnot
  have hsr := rootSum_re_nonneg p.roots z hzr (fun w hw => (hroots w hw).2)
  have hre : 1 + τ * (rootSum p.roots z).re = 0 := by
    simpa using congrArg Complex.re hquot
  nlinarith [mul_nonneg hτ hsr]

/-- Actual preservation theorem: no real-rootedness preservation premise is assumed. -/
theorem differentialStep_preserves (p : ℂ[X]) (τ : ℝ)
    (hp : NegativeRealRoots p) (hτ : 0 ≤ τ) :
    NegativeRealRoots (differentialStep p τ) := by
  have hroots := root_of_differentialStep p τ hp hτ
  constructor
  · intro hzero
    have h := (hroots 1 (by simp [hzero])).2
    norm_num at h
  · exact hroots

/-- Inserting a strictly negative real zero preserves the invariant. -/
theorem insert_preserves (p : ℂ[X]) (a : ℝ)
    (hp : NegativeRealRoots p) (ha : 0 < a) :
    NegativeRealRoots ((Polynomial.X + Polynomial.C (a : ℂ)) * p) := by
  constructor
  · exact mul_ne_zero (Polynomial.X_add_C_ne_zero _) hp.1
  · intro z hz
    have hprod : (z + (a : ℂ)) * p.eval z = 0 := by simpa using hz
    rcases mul_eq_zero.mp hprod with hza | hpz
    · have hz' : z = -(a : ℂ) := eq_neg_of_add_eq_zero_left hza
      rw [hz']
      simp only [Complex.neg_im, Complex.ofReal_im, neg_zero, Complex.neg_re,
        Complex.ofReal_re, true_and]
      linarith
    · exact hp.2 z hpz

/-- The concrete successor, with both insertion and differentiation implemented. -/
def successor (p : ℂ[X]) (a τ : ℝ) : ℂ[X] :=
  differentialStep ((Polynomial.X + Polynomial.C (a : ℂ)) * p) τ

theorem successor_preserves (p : ℂ[X]) (a τ : ℝ)
    (hp : NegativeRealRoots p) (ha : 0 < a) (hτ : 0 ≤ τ) :
    NegativeRealRoots (successor p a τ) :=
  differentialStep_preserves _ τ (insert_preserves p a hp ha) hτ

/-- An actual polynomial family, initialized at one. -/
def family (a τ : ℕ → ℝ) : ℕ → ℂ[X]
  | 0 => 1
  | n + 1 => successor (family a τ n) (a n) (τ n)

theorem family_negative_real_roots (a τ : ℕ → ℝ)
    (ha : ∀ n, 0 < a n) (hτ : ∀ n, 0 ≤ τ n) (n : ℕ) :
    NegativeRealRoots (family a τ n) := by
  induction n with
  | zero =>
    constructor
    · simp [family]
    · intro z hz
      simp [family] at hz
  | succ n ih =>
    exact successor_preserves _ _ _ ih (ha n) (hτ n)

/-- Every member has a nonzero constant term. -/
theorem family_constant_ne_zero (a τ : ℕ → ℝ)
    (ha : ∀ n, 0 < a n) (hτ : ∀ n, 0 ≤ τ n) (n : ℕ) :
    (family a τ n).coeff 0 ≠ 0 := by
  rw [Polynomial.coeff_zero_eq_eval_zero]
  intro hz
  have h := ((family_negative_real_roots a τ ha hτ n).2 0 hz).2
  norm_num at h

/-- The square pullback has real zeros and is normalized to one at the origin. -/
def normalizedPullback (a τ : ℕ → ℝ) (n : ℕ) (t : ℂ) : ℂ :=
  (family a τ n).eval (-t ^ 2) / (family a τ n).eval 0

theorem family_eval_zero_ne_zero (a τ : ℕ → ℝ)
    (ha : ∀ n, 0 < a n) (hτ : ∀ n, 0 ≤ τ n) (n : ℕ) :
    (family a τ n).eval 0 ≠ 0 := by
  simpa only [Polynomial.coeff_zero_eq_eval_zero] using
    family_constant_ne_zero a τ ha hτ n

@[simp] theorem normalizedPullback_zero (a τ : ℕ → ℝ)
    (ha : ∀ n, 0 < a n) (hτ : ∀ n, 0 ≤ τ n) (n : ℕ) :
    normalizedPullback a τ n 0 = 1 := by
  simp only [normalizedPullback, zero_pow (by decide : 2 ≠ 0), neg_zero]
  exact div_self (family_eval_zero_ne_zero a τ ha hτ n)

/-- A strictly negative real value of `-t²` forces `t` to be real. -/
theorem real_of_negative_square (t : ℂ)
    (him : (-t ^ 2).im = 0) (hre : (-t ^ 2).re < 0) : t.im = 0 := by
  have hprod : t.re * t.im = 0 := by
    simp only [Complex.neg_im, pow_two, Complex.mul_im] at him
    nlinarith
  by_contra ht
  have htr : t.re = 0 := (mul_eq_zero.mp hprod).resolve_right ht
  simp only [Complex.neg_re, pow_two, Complex.mul_re, htr, zero_mul, zero_sub,
    neg_neg] at hre
  nlinarith [sq_nonneg t.im]

theorem normalizedPullback_nonreal_nonzero (a τ : ℕ → ℝ)
    (ha : ∀ n, 0 < a n) (hτ : ∀ n, 0 ≤ τ n)
    (n : ℕ) (t : ℂ) (ht : t.im ≠ 0) :
    normalizedPullback a τ n t ≠ 0 := by
  apply div_ne_zero ?_ (family_eval_zero_ne_zero a τ ha hτ n)
  intro hz
  have h := (family_negative_real_roots a τ ha hτ n).2 (-t ^ 2) hz
  exact ht (real_of_negative_square t h.1 h.2)

theorem normalizedPullback_even (a τ : ℕ → ℝ) (n : ℕ) (t : ℂ) :
    normalizedPullback a τ n (-t) = normalizedPullback a τ n t := by
  simp [normalizedPullback]

theorem normalizedPullback_analytic (a τ : ℕ → ℝ) (n : ℕ) :
    AnalyticOnNhd ℂ (normalizedPullback a τ n) Set.univ := by
  intro t ht
  have hp : AnalyticAt ℂ (fun z : ℂ => (family a τ n).eval z) (-t ^ 2) :=
    AnalyticOnNhd.eval_polynomial (family a τ n) _ (Set.mem_univ _)
  have hi : AnalyticAt ℂ (fun z : ℂ => -z ^ 2) t := by fun_prop
  exact (hp.fun_comp_of_eq hi rfl).div_const

theorem normalizedPullback_differentiable (a τ : ℕ → ℝ) (n : ℕ) :
    Differentiable ℂ (normalizedPullback a τ n) := by
  intro t
  exact (normalizedPullback_analytic a τ n t (Set.mem_univ t)).differentiableAt

#print axioms successor_preserves
#print axioms family_negative_real_roots
#print axioms family_constant_ne_zero
#print axioms normalizedPullback_nonreal_nonzero
#print axioms normalizedPullback_analytic

end
end FiveInduction.Differential
