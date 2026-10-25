import FiveInduction.CayleyBridge
import Mathlib.Analysis.Complex.TaylorSeries
import Mathlib.NumberTheory.Harmonic.EulerMascheroni
import Mathlib.NumberTheory.Harmonic.ZetaAsymp

/-!
# The actual Hardy normalization of zeta

The formula through entire xi and reciprocal Gamma removes the singularity at
the origin. Its Taylor series is identified on the full open unit disk.
-/

namespace FiveInduction.HardyActual

open Complex Set Metric Filter
open scoped Topology

noncomputable section

/-- The regularized function `w * zeta (1 / (1 - w))`. -/
def J (w : ℂ) : ℂ :=
  CayleyBridge.F w * (1 - w) ^ 2 * (Gammaℝ (1 / (1 - w)))⁻¹

@[simp] theorem J_zero : J 0 = 1 := by
  simp [J, CayleyBridge.F_zero]

theorem differentiableAt_J {w : ℂ} (hw : w ∈ CayleyBridge.unitDisk) :
    DifferentiableAt ℂ J w := by
  have hden : 1 - w ≠ 0 := CayleyBridge.one_sub_ne_zero hw
  have hmap : DifferentiableAt ℂ (fun z : ℂ => 1 / (1 - z)) w := by
    fun_prop
  have hgamma := differentiable_Gammaℝ_inv.differentiableAt.comp w hmap
  exact ((CayleyBridge.differentiableAt_F hw).mul
    (by fun_prop : DifferentiableAt ℂ (fun z : ℂ => (1 - z) ^ 2) w)).mul hgamma

theorem differentiableOn_J : DifferentiableOn ℂ J CayleyBridge.unitDisk := by
  intro w hw
  exact (differentiableAt_J hw).differentiableWithinAt

theorem analyticOnNhd_J : AnalyticOnNhd ℂ J CayleyBridge.unitDisk :=
  differentiableOn_J.analyticOnNhd isOpen_ball

theorem cayley_re_gt_half {w : ℂ} (hw : w ∈ CayleyBridge.unitDisk) :
    (1 / 2 : ℝ) < (1 / (1 - w) : ℂ).re := by
  have hden : 1 - w ≠ 0 := CayleyBridge.one_sub_ne_zero hw
  have hpos : 0 < Complex.normSq (1 - w) := Complex.normSq_pos.mpr hden
  have hn : ‖w‖ < 1 := CayleyBridge.mem_unitDisk w |>.mp hw
  have hq : Complex.normSq w < 1 := by
    rw [← Complex.sq_norm]
    nlinarith [norm_nonneg w]
  simp only [one_div, Complex.inv_re]
  apply (lt_div_iff₀ hpos).mpr
  simp only [Complex.normSq_apply, Complex.sub_re, Complex.one_re,
    Complex.sub_im, Complex.one_im] at hq ⊢
  nlinarith

theorem J_eq_zeta {w : ℂ} (hw : w ∈ CayleyBridge.unitDisk) (hw0 : w ≠ 0) :
    J w = w * riemannZeta (1 / (1 - w)) := by
  have hden : 1 - w ≠ 0 := CayleyBridge.one_sub_ne_zero hw
  have hs0 : (1 : ℂ) / (1 - w) ≠ 0 := div_ne_zero one_ne_zero hden
  have hs1 : (1 : ℂ) / (1 - w) ≠ 1 := by
    intro h
    have : (1 : ℂ) = 1 - w := (div_eq_one_iff_eq hden).mp h
    exact hw0 (by linear_combination this)
  rw [J, CayleyBridge.F, ActualXi.xi_eq_completed hs0 hs1,
    riemannZeta_def_of_ne_zero hs0]
  field_simp [hden]
  ring

theorem J_eq_regularized {w : ℂ} (hw : w ∈ CayleyBridge.unitDisk) :
    J w = 1 - w + w * riemannZeta₀ (1 / (1 - w)) := by
  by_cases hw0 : w = 0
  · subst w
    simp
  have hden : 1 - w ≠ 0 := CayleyBridge.one_sub_ne_zero hw
  have hs1 : (1 : ℂ) / (1 - w) ≠ 1 := by
    intro h
    have : (1 : ℂ) = 1 - w := (div_eq_one_iff_eq hden).mp h
    exact hw0 (by linear_combination this)
  rw [J_eq_zeta hw hw0, riemannZeta_eq_inv_sub_add hs1]
  have hsub : (1 : ℂ) / (1 - w) - 1 = w / (1 - w) := by
    field_simp [hden]
    ring
  rw [hsub]
  field_simp [hden, hw0]

theorem hasDerivAt_J_zero :
    HasDerivAt J ((Real.eulerMascheroniConstant : ℂ) - 1) 0 := by
  have hcomp : DifferentiableAt ℂ
      (fun z : ℂ => riemannZeta₀ (1 / (1 - z))) 0 := by
    have hmap : DifferentiableAt ℂ (fun z : ℂ => 1 / (1 - z)) 0 := by
      fun_prop (disch := norm_num)
    exact differentiable_riemannZeta₀.differentiableAt.comp 0 hmap
  have hreg := ((hasDerivAt_const (0 : ℂ) 1).sub (hasDerivAt_id 0)).add
    ((hasDerivAt_id 0).mul hcomp.hasDerivAt)
  have hreg' : HasDerivAt
      (fun z : ℂ => 1 - z + z * riemannZeta₀ (1 / (1 - z)))
      ((Real.eulerMascheroniConstant : ℂ) - 1) 0 := by
    convert! hreg using 1
    simp
    ring
  apply hreg'.congr_of_eventuallyEq
  filter_upwards [Metric.ball_mem_nhds (0 : ℂ) (by norm_num : (0 : ℝ) < 1)] with w hw
  exact J_eq_regularized hw

/-- Zero exclusion for this actual normalization implies literal Mathlib RH. -/
theorem RH_OF_J_NONZERO
    (hJ : ∀ w ∈ CayleyBridge.unitDisk, J w ≠ 0) : RiemannHypothesis := by
  apply CayleyBridge.RH_OF_CAYLEY_NONZERO
  intro w hw hF
  apply hJ w hw
  simp [J, hF]

theorem J_NONZERO_OF_RH (hRH : RiemannHypothesis) :
    ∀ w ∈ CayleyBridge.unitDisk, J w ≠ 0 := by
  intro w hw hJ
  by_cases hw0 : w = 0
  · subst w
    simp at hJ
  have hsre := cayley_re_gt_half hw
  have hs1 : (1 : ℂ) / (1 - w) ≠ 1 := by
    intro hs
    have : (1 : ℂ) = 1 - w :=
      (div_eq_one_iff_eq (CayleyBridge.one_sub_ne_zero hw)).mp hs
    exact hw0 (by linear_combination this)
  have hz : riemannZeta (1 / (1 - w)) = 0 := by
    rw [J_eq_zeta hw hw0] at hJ
    exact (mul_eq_zero.mp hJ).resolve_left hw0
  have htrivial : ¬ ∃ n : ℕ, (1 : ℂ) / (1 - w) = -2 * (n + 1) := by
    rintro ⟨n, hn⟩
    rw [hn] at hsre
    norm_num at hsre
    nlinarith [Nat.cast_nonneg (α := ℝ) n]
  have hline := hRH _ hz htrivial hs1
  linarith

theorem J_NONZERO_IFF_RH :
    (∀ w ∈ CayleyBridge.unitDisk, J w ≠ 0) ↔ RiemannHypothesis :=
  ⟨RH_OF_J_NONZERO, J_NONZERO_OF_RH⟩

/-- Canonical Taylor coefficients of the actual normalized zeta function. -/
def coeff (n : ℕ) : ℂ := iteratedDeriv n J 0 / n.factorial

@[simp] theorem coeff_zero : coeff 0 = 1 := by
  simp [coeff]

@[simp] theorem coeff_one : coeff 1 = (Real.eulerMascheroniConstant : ℂ) - 1 := by
  simp [coeff, hasDerivAt_J_zero.deriv]

theorem hasSum_coeff {w : ℂ} (hw : w ∈ CayleyBridge.unitDisk) :
    HasSum (fun n : ℕ => coeff n * w ^ n) (J w) := by
  have h := Complex.hasSum_taylorSeries_on_ball differentiableOn_J hw
  convert! h using 1
  simp only [coeff, sub_zero, smul_eq_mul, div_eq_mul_inv, mul_comm, mul_left_comm]

/-- The expected exact squared Hardy norm from the fractional-part integral. -/
def K : ℝ := Real.log (2 * Real.pi) - Real.eulerMascheroniConstant

/-- Analytic input: the exact coefficient energy identity for the actual J. -/
def ActualHardyEnergy : Prop := HasSum (fun n => Complex.normSq (coeff n)) K

end
end FiveInduction.HardyActual
