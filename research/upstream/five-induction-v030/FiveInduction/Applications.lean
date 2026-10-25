import FiveInduction.Sturm
import FiveInduction.Differential
import FiveInduction.ActualXi
import FiveInduction.LimitTransfer

/-!
# An actual-xi endpoint of the Sturm induction

The remaining input is local uniform convergence of the explicitly generated
and scaled polynomial family to Mathlib-grounded xi. Preservation, the
nonzero-limit transfer, and the xi--zeta implication are proved elsewhere in
this package. This convergence is a global analytic input, not a finite seed.
-/

namespace FiveInduction.Applications

open Filter Set
open scoped Topology

noncomputable section

/-- Calibration multiplies a normalized generated polynomial by a fixed scalar. -/
def sturmApproximant (b : ℕ → ℝ) (c : ℂ) (n : ℕ) (z : ℂ) : ℂ :=
  c * Sturm.normalized b n z

/-- The complete conditional endpoint concludes Mathlib's literal RH. -/
theorem RH_OF_STURM_CONVERGENCE (b : ℕ → ℝ) (c : ℂ)
    (hb : ∀ n, 0 < b (n + 1))
    (hconv : TendstoLocallyUniformly (sturmApproximant b c) ActualXi.Xi atTop) :
    RiemannHypothesis := by
  have hc : c ≠ 0 := by
    intro hc
    obtain ⟨z, hz⟩ := ActualXi.Xi_nontrivial
    have hl := (hconv.tendstoLocallyUniformlyOn (s := univ)).tendsto_at (mem_univ z)
    have hzero : Tendsto (fun _ : ℕ => (0 : ℂ)) atTop (𝓝 (ActualXi.Xi z)) := by
      simpa [sturmApproximant, hc] using hl
    have heq : (0 : ℂ) = ActualXi.Xi z :=
      tendsto_nhds_unique tendsto_const_nhds hzero
    exact hz heq.symm
  apply ActualXi.rh_of_real_zeros
  apply LimitTransfer.real_zeros_of_locally_uniform_limit
    (F := sturmApproximant b c)
  · intro n
    have hp : Differentiable ℂ (Sturm.normalized b n) :=
      fun z => (Sturm.normalized_analytic b n z (mem_univ z)).differentiableAt
    exact hp.const_mul c
  · intro n z hz
    exact mul_ne_zero hc (Sturm.normalized_nonreal_nonzero b hb n z hz)
  · exact ActualXi.differentiable_Xi
  · exact ActualXi.Xi_nontrivial
  · exact hconv

/-- The convergence input forces the calibration; it is not a free normalization. -/
theorem sturm_calibration_forced (b : ℕ → ℝ) (c : ℂ)
    (hb : ∀ n, 0 < b (n + 1))
    (hconv : TendstoLocallyUniformly (sturmApproximant b c) ActualXi.Xi atTop) :
    c = ActualXi.Xi 0 := by
  have hl := (hconv.tendstoLocallyUniformlyOn (s := univ)).tendsto_at (mem_univ (0 : ℂ))
  have hconst : Tendsto (fun _ : ℕ => c) atTop (𝓝 (ActualXi.Xi 0)) := by
    simpa only [sturmApproximant, Sturm.normalized_zero b hb, mul_one] using hl
  exact tendsto_nhds_unique tendsto_const_nhds hconst

/-- The explicitly unproved analytic realization target. -/
def SturmXiRealization : Prop :=
  ∃ (b : ℕ → ℝ) (c : ℂ), (∀ n, 0 < b (n + 1)) ∧
    TendstoLocallyUniformly (sturmApproximant b c) ActualXi.Xi atTop

theorem RH_OF_STURM_REALIZATION (h : SturmXiRealization) : RiemannHypothesis := by
  obtain ⟨b, c, hb, hconv⟩ := h
  exact RH_OF_STURM_CONVERGENCE b c hb hconv

/-- The negative-root family is pulled back by z = -t^2 and calibrated. -/
def differentialApproximant (a τ : ℕ → ℝ) (c : ℂ) (n : ℕ) (z : ℂ) : ℂ :=
  c * Differential.normalizedPullback a τ n z

theorem RH_OF_DIFFERENTIAL_CONVERGENCE (a τ : ℕ → ℝ) (c : ℂ)
    (ha : ∀ n, 0 < a n) (hτ : ∀ n, 0 ≤ τ n)
    (hconv : TendstoLocallyUniformly (differentialApproximant a τ c)
      ActualXi.Xi atTop) : RiemannHypothesis := by
  have hc : c ≠ 0 := by
    intro hc
    obtain ⟨z, hz⟩ := ActualXi.Xi_nontrivial
    have hl := (hconv.tendstoLocallyUniformlyOn (s := univ)).tendsto_at (mem_univ z)
    have hzero : Tendsto (fun _ : ℕ => (0 : ℂ)) atTop (𝓝 (ActualXi.Xi z)) := by
      simpa [differentialApproximant, hc] using hl
    have heq : (0 : ℂ) = ActualXi.Xi z :=
      tendsto_nhds_unique tendsto_const_nhds hzero
    exact hz heq.symm
  apply ActualXi.rh_of_real_zeros
  apply LimitTransfer.real_zeros_of_locally_uniform_limit
    (F := differentialApproximant a τ c)
  · intro n
    exact (Differential.normalizedPullback_differentiable a τ n).const_mul c
  · intro n z hz
    exact mul_ne_zero hc
      (Differential.normalizedPullback_nonreal_nonzero a τ ha hτ n z hz)
  · exact ActualXi.differentiable_Xi
  · exact ActualXi.Xi_nontrivial
  · exact hconv

/-- A second explicit global analytic target; no witness is supplied. -/
def DifferentialXiRealization : Prop :=
  ∃ (a τ : ℕ → ℝ) (c : ℂ), (∀ n, 0 < a n) ∧ (∀ n, 0 ≤ τ n) ∧
    TendstoLocallyUniformly (differentialApproximant a τ c) ActualXi.Xi atTop

theorem RH_OF_DIFFERENTIAL_REALIZATION (h : DifferentialXiRealization) :
    RiemannHypothesis := by
  obtain ⟨a, τ, c, ha, hτ, hconv⟩ := h
  exact RH_OF_DIFFERENTIAL_CONVERGENCE a τ c ha hτ hconv

end
end FiveInduction.Applications
