import RHAdmission.Equivalence

/-!
# Full symmetric 2x2 positive metric

This is the faithful finite-channel quadratic-form statement
    H >= epsilon I,    U_s^T H U_s <= H.
The metric may have a nonzero off-diagonal entry.  One single H works for
all actual nontrivial zeta-zero channels. The underlying U_s is the concrete
algebraic Cayley-numerator channel, not the yet-unidentified Mellin trace U_xi.
-/

namespace RHAdmission

/-- A fixed coercive symmetric real 2x2 quadratic-form metric. -/
structure PositiveTwoModeMetric where
  eps : ℝ
  eps_pos : 0 < eps
  h11 : ℝ
  h12 : ℝ
  h22 : ℝ
  positive : ∀ v : ChannelVec,
    eps * (v.1 ^ 2 + v.2 ^ 2) ≤
      h11 * v.1 ^ 2 + 2 * h12 * v.1 * v.2 + h22 * v.2 ^ 2

/-- Full symmetric 2x2 energy (not restricted to diagonal H). -/
def fullMetricEnergy (H : PositiveTwoModeMetric) (v : ChannelVec) : ℝ :=
  H.h11 * v.1 ^ 2 + 2 * H.h12 * v.1 * v.2 + H.h22 * v.2 ^ 2

/-- Quadratic form Uᵀ H U ≤ H for a single channel. -/
def FullMetricPassivityAt (H : PositiveTwoModeMetric) (s : ℂ) : Prop :=
  ∀ v : ChannelVec,
    fullMetricEnergy H (channelStep s v) ≤ fullMetricEnergy H v

/-- Original-style positive-metric admission in the actual zero-indexed
    algebraic two-mode channel space; one fixed H for all zero labels. -/
def FullHypotheticalAdmission : Prop :=
  ∃ H : PositiveTwoModeMetric,
    ∀ s : ℂ, ActualNontrivialZero s → FullMetricPassivityAt H s

private theorem full_metric_expanding_mode_forces_critical
    (H : PositiveTwoModeMetric) (s : ℂ)
    (hpass : FullMetricPassivityAt H s) : s.re = 1 / 2 := by
  have hpositive := H.positive (1, 0)
  have h11_ge : H.eps ≤ H.h11 := by
    simpa using hpositive
  have h11_pos : 0 < H.h11 := lt_of_lt_of_le H.eps_pos h11_ge
  have hpass0 := hpass (1, 0)
  have hupper : H.h11 * channelGain s ^ 2 ≤ H.h11 := by
    simpa [fullMetricEnergy, channelStep] using hpass0
  have hupper' : channelGain s ^ 2 * H.h11 ≤ H.h11 := by
    calc
      channelGain s ^ 2 * H.h11 = H.h11 * channelGain s ^ 2 := mul_comm _ _
      _ ≤ H.h11 := hupper
  have hg : channelGain s ^ 2 ≤ 1 := by
    exact (mul_le_mul_right h11_pos).mp (by simpa using hupper')
  have hsq : criticalOffset s ^ 2 = 0 := by
    unfold channelGain cayleyNumerator at hg
    nlinarith [sq_nonneg (criticalOffset s), sq_nonneg ((criticalOffset s) ^ 2)]
  have hzero : criticalOffset s = 0 := by nlinarith [hsq]
  exact (criticalOffset_eq_zero_iff s).mp hzero

/-- Native RH supplies the identity metric, with lower bound epsilon=1. -/
theorem native_RH_implies_full_admission
    (hRH : _root_.RiemannHypothesis) : FullHypotheticalAdmission := by
  let H : PositiveTwoModeMetric :=
    { eps := 1
      eps_pos := by norm_num
      h11 := 1
      h12 := 0
      h22 := 1
      positive := by
        intro v
        simp }
  refine ⟨H, ?_⟩
  intro s hs v
  have hc : s.re = 1 / 2 := hRH s hs.1 hs.2.1 hs.2.2
  rw [channelStep_of_critical s hc]

/-- Positive-metric admission forces Mathlib's *actual* native RH. -/
theorem full_admission_implies_native_RH
    (hAdmission : FullHypotheticalAdmission) : _root_.RiemannHypothesis := by
  obtain ⟨H, hpass⟩ := hAdmission
  intro s hz htriv hne
  exact full_metric_expanding_mode_forces_critical H s
    (hpass s ⟨hz, htriv, hne⟩)

/-- Strongest theorem: arbitrary positive symmetric two-mode H is admitted
    exactly when the native Riemann hypothesis is true. -/
theorem FULL_HYPOTHETICAL_ADMISSION_IFF_NATIVE_RH :
    FullHypotheticalAdmission ↔ _root_.RiemannHypothesis :=
  ⟨full_admission_implies_native_RH, native_RH_implies_full_admission⟩

/-- One-step full passivity propagates to every depth. -/
theorem full_metric_all_depths
    (H : PositiveTwoModeMetric) (s : ℂ)
    (hpass : FullMetricPassivityAt H s) :
    ∀ n : ℕ, ∀ v : ChannelVec,
      fullMetricEnergy H (channelIterate s n v) ≤ fullMetricEnergy H v := by
  intro n
  induction n with
  | zero =>
      intro v
      simp [channelIterate]
  | succ n ih =>
      intro v
      calc
        fullMetricEnergy H (channelIterate s (n + 1) v)
            = fullMetricEnergy H (channelStep s (channelIterate s n v)) := rfl
        _ ≤ fullMetricEnergy H (channelIterate s n v) := hpass _
        _ ≤ fullMetricEnergy H v := ih v

/-- Full hypothetical admission yields all-depth positive-metric bounds,
    without supplying another induction hypothesis. -/
theorem full_admission_all_depths
    (hAdmission : FullHypotheticalAdmission) :
    ∃ H : PositiveTwoModeMetric,
      ∀ s : ℂ, ActualNontrivialZero s →
        ∀ n : ℕ, ∀ v : ChannelVec,
          fullMetricEnergy H (channelIterate s n v) ≤ fullMetricEnergy H v := by
  obtain ⟨H, hpass⟩ := hAdmission
  refine ⟨H, ?_⟩
  intro s hs n v
  exact full_metric_all_depths H s (hpass s hs) n v

end RHAdmission
