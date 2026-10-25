import Mathlib.NumberTheory.LSeries.RiemannZeta
import Mathlib.Analysis.SpecialFunctions.Gamma.Deligne
import Mathlib.Tactic

/-!
# The actual entire xi function and the literal Riemann hypothesis

This module uses Mathlib's pole-subtracted completed zeta.  The direction
from nontrivial zeta zeros to xi zeros is proved here, rather than supplied
as a hypothesis of the induction endpoints.
-/

namespace FiveInduction.ActualXi

open Complex

noncomputable def xi (s : ℂ) : ℂ :=
  (1 / 2 : ℂ) * s * (s - 1) * completedRiemannZeta₀ s + (1 / 2 : ℂ)

noncomputable def Xi (z : ℂ) : ℂ :=
  xi ((1 / 2 : ℂ) + Complex.I * z)

theorem differentiable_xi : Differentiable ℂ xi := by
  unfold xi
  have hc := differentiable_completedZeta₀
  fun_prop

theorem differentiable_Xi : Differentiable ℂ Xi := by
  unfold Xi
  have hc := differentiable_xi
  fun_prop

@[simp] theorem xi_zero : xi 0 = 1 / 2 := by
  norm_num [xi]

@[simp] theorem xi_one : xi 1 = 1 / 2 := by
  norm_num [xi]

theorem xi_eq_completed {s : ℂ} (hs0 : s ≠ 0) (hs1 : s ≠ 1) :
    xi s = (1 / 2 : ℂ) * s * (s - 1) * completedRiemannZeta s := by
  rw [xi, completedRiemannZeta_eq]
  have h1s : 1 - s ≠ 0 := sub_ne_zero.mpr (Ne.symm hs1)
  field_simp [hs0, h1s]
  ring

theorem xi_zero_of_nontrivial_zeta_zero {s : ℂ}
    (hz : riemannZeta s = 0)
    (htrivial : ¬ ∃ n : ℕ, s = -2 * (n + 1))
    (hs1 : s ≠ 1) : xi s = 0 := by
  have hs0 : s ≠ 0 := by
    intro hs
    subst s
    norm_num [riemannZeta_zero] at hz
  have hgamma : Complex.Gammaℝ s ≠ 0 := by
    intro hg
    obtain ⟨n, hn⟩ := Complex.Gammaℝ_eq_zero_iff.mp hg
    cases n with
    | zero =>
        apply hs0
        simpa using hn
    | succ n =>
        apply htrivial
        refine ⟨n, ?_⟩
        rw [hn]
        push_cast
        ring
  have hc : completedRiemannZeta s = 0 := by
    rw [riemannZeta_def_of_ne_zero hs0] at hz
    exact (div_eq_zero_iff.mp hz).resolve_right hgamma
  rw [xi_eq_completed hs0 hs1, hc, mul_zero]

theorem critical_shift_re (z : ℂ) :
    ((1 / 2 : ℂ) + Complex.I * z).re = 1 / 2 - z.im := by
  norm_num [Complex.mul_re]
  ring

theorem rh_of_real_zeros
    (hreal : ∀ z : ℂ, Xi z = 0 → z.im = 0) : RiemannHypothesis := by
  intro s hz htrivial hs1
  have hxi := xi_zero_of_nontrivial_zeta_zero hz htrivial hs1
  let z : ℂ := -Complex.I * (s - (1 / 2 : ℂ))
  have hshift : (1 / 2 : ℂ) + Complex.I * z = s := by
    dsimp [z]
    ring_nf
    simp [Complex.I_sq]
  have hzxi : Xi z = 0 := by
    unfold Xi
    rw [hshift]
    exact hxi
  have hzreal := hreal z hzxi
  have hre := critical_shift_re z
  rw [hshift, hzreal] at hre
  simpa using hre

theorem rh_of_nonreal_nonzero
    (hnonzero : ∀ z : ℂ, z.im ≠ 0 → Xi z ≠ 0) : RiemannHypothesis := by
  apply rh_of_real_zeros
  intro z hz
  by_contra him
  exact hnonzero z him hz

theorem Xi_nontrivial : ∃ z : ℂ, Xi z ≠ 0 := by
  refine ⟨Complex.I / 2, ?_⟩
  have hshift : (1 / 2 : ℂ) + Complex.I * (Complex.I / 2) = 0 := by
    ring_nf
    simp [Complex.I_sq]
  rw [Xi, hshift, xi_zero]
  norm_num

end FiveInduction.ActualXi
