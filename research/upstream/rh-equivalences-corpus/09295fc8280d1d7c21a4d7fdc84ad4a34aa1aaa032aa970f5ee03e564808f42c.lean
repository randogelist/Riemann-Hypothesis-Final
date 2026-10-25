import Mathlib

namespace NativeSolobolo.SignedBernstein

/-- Literal entire completed zeta expression, including the pole-removal correction. -/
noncomputable def xiEntire (s : ℂ) : ℂ :=
  (1 + s * (s - 1) * completedRiemannZeta₀ s) / 2

@[simp] theorem xiEntire_zero : xiEntire 0 = (1 / 2 : ℂ) := by
  simp [xiEntire]

@[simp] theorem xiEntire_one : xiEntire 1 = (1 / 2 : ℂ) := by
  simp [xiEntire]

theorem XI_REFLECTION (s : ℂ) : xiEntire (1 - s) = xiEntire s := by
  unfold xiEntire
  rw [completedRiemannZeta₀_one_sub]
  ring

/-- Binding to the usual s(s-1)Lambda(s)/2 away from the removable endpoints. -/
theorem XI_COMPLETED_BINDING (s : ℂ) (h0 : s ≠ 0) (h1 : s ≠ 1) :
    xiEntire s = (s * (s - 1) / 2) * completedRiemannZeta s := by
  have hm : 1 - s ≠ 0 := sub_ne_zero.mpr (Ne.symm h1)
  rw [completedRiemannZeta_eq]
  unfold xiEntire
  field_simp [h0, hm] <;> ring

theorem XI_ENTIRE : Differentiable ℂ xiEntire := by
  have hid : Differentiable ℂ (fun z : ℂ => z) := differentiable_id
  have hone : Differentiable ℂ (fun _ : ℂ => (1 : ℂ)) :=
    differentiable_const (1 : ℂ)
  have hsub : Differentiable ℂ (fun z : ℂ => z - (1 : ℂ)) :=
    hid.sub hone
  have hprod : Differentiable ℂ
      (fun z : ℂ => z * (z - (1 : ℂ)) * completedRiemannZeta₀ z) :=
    (hid.mul hsub).mul differentiable_completedZeta₀
  have hsum : Differentiable ℂ
      (fun z : ℂ => (1 : ℂ) + z * (z - (1 : ℂ)) * completedRiemannZeta₀ z) :=
    hone.add hprod
  have hinvTwo : Differentiable ℂ (fun _ : ℂ => (2 : ℂ)⁻¹) :=
    differentiable_const ((2 : ℂ)⁻¹)
  have hmul : Differentiable ℂ
      (fun z : ℂ =>
        ((1 : ℂ) + z * (z - (1 : ℂ)) * completedRiemannZeta₀ z) * (2 : ℂ)⁻¹) :=
    hsum.mul hinvTwo
  have hxi : xiEntire =
      (fun z : ℂ =>
        ((1 : ℂ) + z * (z - (1 : ℂ)) * completedRiemannZeta₀ z) * (2 : ℂ)⁻¹) := by
    funext z
    unfold xiEntire
    exact div_eq_mul_inv _ _
  rw [hxi]
  exact hmul

/-- The literal real centered xi slice. Only its germ at a=1 is needed here. -/
noncomputable def realXiSlice (a : ℝ) : ℝ :=
  (xiEntire ((1 / 2 : ℂ) + (Real.sqrt a : ℂ))).re

noncomputable def realXiLogDerivative (a : ℝ) : ℝ :=
  deriv realXiSlice a / realXiSlice a

noncomputable def actualCurvatureKernel (a : ℝ) : ℝ :=
  deriv (fun t : ℝ => t * realXiLogDerivative t) a

/-- Iterated genuine real differentiation, not a declared derivative surrogate. -/
noncomputable def realJet : ℕ → (ℝ → ℝ) → ℝ → ℝ
  | 0, f => f
  | n + 1, f => deriv (realJet n f)

/-- Actual signed fixed-anchor xi jet used in every final specialization. -/
noncomputable def xiJet (n : ℕ) : ℝ :=
  ((-1 : ℝ) ^ n * realJet n actualCurvatureKernel 1) /
    ((n + 1).factorial : ℝ)

@[simp] theorem XI_JET_ZERO : xiJet 0 = actualCurvatureKernel 1 := by
  simp [xiJet, realJet]

theorem XI_JET_ONE : xiJet 1 = -deriv actualCurvatureKernel 1 / 2 := by
  norm_num [xiJet, realJet]

end NativeSolobolo.SignedBernstein
