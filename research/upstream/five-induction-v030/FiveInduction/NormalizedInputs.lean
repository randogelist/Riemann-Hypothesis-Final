import FiveInduction.Applications

/-!
The two entire-function inputs, with the calibration fixed to actual Xi(0).
These propositions are equivalent to the original existentially calibrated
inputs. No realization witness is supplied by this module.
-/

namespace FiveInduction.NormalizedInputs

open Filter
open scoped Topology

noncomputable section

theorem differential_calibration_forced (a τ : ℕ → ℝ) (c : ℂ)
    (ha : ∀ n, 0 < a n) (hτ : ∀ n, 0 ≤ τ n)
    (hconv : TendstoLocallyUniformly
      (Applications.differentialApproximant a τ c) ActualXi.Xi atTop) :
    c = ActualXi.Xi 0 := by
  have hl := (hconv.tendstoLocallyUniformlyOn (s := Set.univ)).tendsto_at
    (Set.mem_univ (0 : ℂ))
  have hconst : Tendsto (fun _ : ℕ => c) atTop (𝓝 (ActualXi.Xi 0)) := by
    simpa only [Applications.differentialApproximant,
      Differential.normalizedPullback_zero a τ ha hτ, mul_one] using hl
  exact tendsto_nhds_unique tendsto_const_nhds hconst

def SturmInput : Prop :=
  ∃ b : ℕ → ℝ, (∀ n, 0 < b (n + 1)) ∧
    TendstoLocallyUniformly
      (Applications.sturmApproximant b (ActualXi.Xi 0)) ActualXi.Xi atTop

def DifferentialInput : Prop :=
  ∃ a τ : ℕ → ℝ, (∀ n, 0 < a n) ∧ (∀ n, 0 ≤ τ n) ∧
    TendstoLocallyUniformly
      (Applications.differentialApproximant a τ (ActualXi.Xi 0)) ActualXi.Xi atTop

theorem sturm_input_iff_realization : SturmInput ↔ Applications.SturmXiRealization := by
  constructor
  · rintro ⟨b, hb, hconv⟩
    exact ⟨b, ActualXi.Xi 0, hb, hconv⟩
  · rintro ⟨b, c, hb, hconv⟩
    have hc := Applications.sturm_calibration_forced b c hb hconv
    subst c
    exact ⟨b, hb, hconv⟩

theorem differential_input_iff_realization :
    DifferentialInput ↔ Applications.DifferentialXiRealization := by
  constructor
  · rintro ⟨a, τ, ha, hτ, hconv⟩
    exact ⟨a, τ, ActualXi.Xi 0, ha, hτ, hconv⟩
  · rintro ⟨a, τ, c, ha, hτ, hconv⟩
    have hc := differential_calibration_forced a τ c ha hτ hconv
    subst c
    exact ⟨a, τ, ha, hτ, hconv⟩

theorem RH_OF_STURM_INPUT (h : SturmInput) : RiemannHypothesis :=
  Applications.RH_OF_STURM_REALIZATION (sturm_input_iff_realization.mp h)

theorem RH_OF_DIFFERENTIAL_INPUT (h : DifferentialInput) : RiemannHypothesis :=
  Applications.RH_OF_DIFFERENTIAL_REALIZATION (differential_input_iff_realization.mp h)

end

end FiveInduction.NormalizedInputs
