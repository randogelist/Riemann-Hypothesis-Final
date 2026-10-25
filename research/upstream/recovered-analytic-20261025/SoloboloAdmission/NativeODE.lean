import AngularMaster.ZeroGeometry
import AWPIRH.AnalyticODE
import Mathlib

/-!
# Native RH <-> slit-domain analytic ODE admission

A genuine *analytic* admission, not defined to be RH and not a free
propositional field. This theorem uses the actual Mathlib-backed entire
Riemann theta, and the original native zero-geometry equivalence.

The analytic coefficient is NOT assumed to have positive rational-resolvent
approximants. That stronger constructive property is separate.
-/
set_option autoImplicit false
noncomputable section
namespace SoloboloAdmission

open scoped Topology
open Filter

/-- The theta logarithmic derivative has a holomorphic, division-free ODE
coefficient on the entire cut plane. This is a genuine analytic predicate. -/
def SlitODEAdmission : Prop :=
  ∃ A : ℂ → ℂ,
    AnalyticOnNhd ℂ A Complex.slitPlane ∧
      ∀ z ∈ Complex.slitPlane,
        deriv AWPIRH.theta z + A z * AWPIRH.theta z = 0

/-- An entire function that is nonzero at 1 cannot acquire a zero at a point
where it locally satisfies a holomorphic first-order homogeneous ODE.
The proof uses *global finite analytic order of Y*, not a preconnectedness
hypothesis for the slit plane. -/
theorem entire_local_ode_nonvanishing
    {Y A : ℂ → ℂ}
    (hY : AnalyticOnNhd ℂ Y Set.univ)
    (hY1 : Y 1 ≠ 0)
    {z : ℂ} (hA : AnalyticAt ℂ A z)
    (hode : ∀ᶠ w in 𝓝 z, deriv Y w + A w * Y w = 0) :
    Y z ≠ 0 := by
  intro hzero
  have hYone : AnalyticAt ℂ Y 1 := hY 1 (Set.mem_univ _)
  have hoone : analyticOrderAt Y 1 = 0 :=
    hYone.analyticOrderAt_eq_zero.mpr hY1
  have hfinone : analyticOrderAt Y 1 ≠ ⊤ := by simp [hoone]
  have hfinite : analyticOrderAt Y z ≠ ⊤ :=
    hY.analyticOrderAt_ne_top_of_isPreconnected
      isPreconnected_univ (Set.mem_univ _) (Set.mem_univ _) hfinone
  have hd : analyticOrderAt (deriv Y) z + 1 = analyticOrderAt Y z := by
    simpa [hzero] using (hY z (Set.mem_univ _)).analyticOrderAt_deriv_add_one
  have hevent : deriv Y =ᶠ[𝓝 z] (fun w => (-A w) * Y w) := by
    filter_upwards [hode] with w hw
    change deriv Y w = -A w * Y w
    linear_combination hw
  have hm : analyticOrderAt (deriv Y) z =
      analyticOrderAt (fun w => -A w) z + analyticOrderAt Y z := by
    calc
      _ = analyticOrderAt (fun w => (-A w) * Y w) z :=
        analyticOrderAt_congr hevent
      _ = _ := analyticOrderAt_mul hA.neg (hY z (Set.mem_univ _))
  have hle : analyticOrderAt Y z ≤ analyticOrderAt (deriv Y) z := by
    rw [hm]
    simpa using add_le_add_right
      (show (0 : ℕ∞) ≤ analyticOrderAt (fun w => -A w) z from bot_le)
      (analyticOrderAt Y z)
  have hbad : analyticOrderAt Y z + 1 ≤ analyticOrderAt Y z := by
    calc
      _ ≤ analyticOrderAt (deriv Y) z + 1 := add_le_add_left hle 1
      _ = _ := hd
  generalize hq : analyticOrderAt Y z = q at hbad hfinite
  lift q to ℕ using hfinite with n hn
  norm_cast at hbad
  omega

/-- RH gives a holomorphic coefficient A=-Theta'/Theta on the slit plane. -/
theorem slitODE_of_rh (hRH : _root_.RiemannHypothesis) :
    SlitODEAdmission := by
  have hzero := (AngularMaster.native_RH_iff_theta_zeros_nonpositive.mp hRH)
  have hnv : ∀ z ∈ Complex.slitPlane, AWPIRH.theta z ≠ 0 := by
    intro z hz htheta
    obtain ⟨him, hre⟩ := hzero z htheta
    rcases Complex.mem_slitPlane_iff.mp hz with hp | hni
    · exact (not_le_of_gt hp) hre
    · exact hni him
  refine ⟨(fun z : ℂ => -(deriv AWPIRH.theta z / AWPIRH.theta z)), ?_, ?_⟩
  · intro z hz
    have htheta := AWPIRH.theta_analyticAt z
    exact (htheta.deriv.div htheta (hnv z hz)).neg
  · intro z hz
    dsimp
    have hden := hnv z hz
    field_simp [hden]
    ring

/-- ODE admission prevents theta zeros anywhere off the negative real axis. -/
theorem rh_of_slitODE (h : SlitODEAdmission) :
    _root_.RiemannHypothesis := by
  rcases h with ⟨A, hA, hode⟩
  have hnv : ∀ z ∈ Complex.slitPlane, AWPIRH.theta z ≠ 0 := by
    intro z hz
    have hlocal : ∀ᶠ w in 𝓝 z,
        deriv AWPIRH.theta w + A w * AWPIRH.theta w = 0 := by
      filter_upwards [Complex.isOpen_slitPlane.mem_nhds hz] with w hw
      exact hode w hw
    exact entire_local_ode_nonvanishing AWPIRH.theta_entire
      AWPIRH.theta_one_ne_zero (hA z hz) hlocal
  apply AngularMaster.native_RH_iff_theta_zeros_nonpositive.mpr
  intro z hz
  have hnot : z ∉ Complex.slitPlane := by
    intro hslit
    exact hnv z hslit hz
  have hre : z.re ≤ 0 := by
    by_contra hn
    have hp : 0 < z.re := lt_of_not_ge hn
    exact hnot (Complex.mem_slitPlane_iff.mpr (Or.inl hp))
  have him : z.im = 0 := by
    by_contra hn
    exact hnot (Complex.mem_slitPlane_iff.mpr (Or.inr hn))
  exact ⟨him, hre⟩

/-- Actual, unconditional, non-tautological RH-equivalence theorem.
The witness is a holomorphic logarithmic-derivative ODE on the cut. -/
theorem slitODEAdmission_iff_RH :
    SlitODEAdmission ↔ _root_.RiemannHypothesis :=
  ⟨rh_of_slitODE, slitODE_of_rh⟩

end SoloboloAdmission

#print axioms SoloboloAdmission.slitODEAdmission_iff_RH
