import FiveInduction.ActualXi
import Mathlib.Analysis.Complex.CauchyIntegral

/-!
# The actual xi function on the Cayley disk

The disk model is fixed by an explicit formula.  Its zero-exclusion implication
to literal Mathlib RH is proved using the actual xi functional equation.
-/

namespace FiveInduction.CayleyBridge

open Complex Set Metric

noncomputable section

def unitDisk : Set ℂ := Metric.ball 0 1

def F (w : ℂ) : ℂ := 2 * ActualXi.xi (1 / (1 - w))

@[simp] theorem mem_unitDisk (w : ℂ) : w ∈ unitDisk ↔ ‖w‖ < 1 := by
  simp [unitDisk, Metric.mem_ball, dist_zero_right]

@[simp] theorem zero_mem_unitDisk : (0 : ℂ) ∈ unitDisk := by simp

@[simp] theorem F_zero : F 0 = 1 := by
  norm_num [F, ActualXi.xi_one]

theorem xi_one_sub (s : ℂ) : ActualXi.xi (1 - s) = ActualXi.xi s := by
  unfold ActualXi.xi
  rw [completedRiemannZeta₀_one_sub]
  ring

theorem one_sub_ne_zero {w : ℂ} (hw : w ∈ unitDisk) : 1 - w ≠ 0 := by
  intro h
  have heq : w = 1 := (sub_eq_zero.mp h).symm
  subst w
  simp at hw

theorem differentiableAt_F {w : ℂ} (hw : w ∈ unitDisk) :
    DifferentiableAt ℂ F w := by
  have hden : 1 - w ≠ 0 := one_sub_ne_zero hw
  have hmap : DifferentiableAt ℂ (fun z : ℂ => 1 / (1 - z)) w := by
    fun_prop
  exact ((ActualXi.differentiable_xi _).comp w hmap).const_mul 2

theorem differentiableOn_F : DifferentiableOn ℂ F unitDisk := by
  intro w hw
  exact (differentiableAt_F hw).differentiableWithinAt

theorem analyticOnNhd_F : AnalyticOnNhd ℂ F unitDisk :=
  differentiableOn_F.analyticOnNhd isOpen_ball

theorem cayley_inverse_mem_disk {s : ℂ} (hs : 1 / 2 < s.re) :
    1 - 1 / s ∈ unitDisk := by
  have hs0 : s ≠ 0 := by
    intro h
    subst s
    norm_num at hs
  have hnorm : ‖s - 1‖ < ‖s‖ := by
    have hsq : ‖s - 1‖ ^ 2 < ‖s‖ ^ 2 := by
      simp only [Complex.sq_norm, Complex.normSq_apply, Complex.sub_re,
        Complex.one_re, Complex.sub_im, Complex.one_im, sub_zero]
      nlinarith
    nlinarith [norm_nonneg (s - 1), norm_nonneg s]
  rw [mem_unitDisk]
  have heq : (1 : ℂ) - 1 / s = (s - 1) / s := by field_simp
  rw [heq, norm_div]
  exact (div_lt_one (norm_pos_iff.mpr hs0)).mpr hnorm

theorem cayley_inverse_identity {s : ℂ} (hs : s ≠ 0) :
    1 / (1 - (1 - 1 / s)) = s := by
  field_simp
  ring

theorem xi_nonzero_right_of_cayley
    (hF : ∀ w ∈ unitDisk, F w ≠ 0) {s : ℂ} (hs : 1 / 2 < s.re) :
    ActualXi.xi s ≠ 0 := by
  have hs0 : s ≠ 0 := by
    intro h
    subst s
    norm_num at hs
  have h := hF (1 - 1 / s) (cayley_inverse_mem_disk hs)
  rw [F, cayley_inverse_identity hs0] at h
  exact (mul_ne_zero_iff.mp h).2

theorem RH_OF_CAYLEY_NONZERO
    (hF : ∀ w ∈ unitDisk, F w ≠ 0) : RiemannHypothesis := by
  intro s hz htrivial hs1
  have hxi := ActualXi.xi_zero_of_nontrivial_zeta_zero hz htrivial hs1
  by_contra hline
  rcases lt_or_gt_of_ne hline with hleft | hright
  · have hreflect : (1 / 2 : ℝ) < (1 - s).re := by
      simp only [Complex.sub_re, Complex.one_re]
      linarith
    apply xi_nonzero_right_of_cayley hF hreflect
    rw [xi_one_sub]
    exact hxi
  · exact xi_nonzero_right_of_cayley hF hright hxi

end
end FiveInduction.CayleyBridge
