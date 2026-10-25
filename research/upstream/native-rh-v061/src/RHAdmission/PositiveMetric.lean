import RHAdmission.KreinChannel

/-!
# Hypothetical positive-metric admission

The certificate here is a single, globally fixed positive diagonal metric
on every actual nontrivial zeta-zero two-mode channel.  No finite witness
constructor or analytic Mellin trace calibration is claimed.
-/

namespace RHAdmission

/-- One fixed (not depth- or zero-dependent) strictly positive diagonal metric. -/
structure PositiveDiagonalMetric where
  plus : ℝ
  minus : ℝ
  plus_pos : 0 < plus
  minus_pos : 0 < minus

/-- Squared norm in the positive metric. -/
def metricEnergy (H : PositiveDiagonalMetric) (v : ChannelVec) : ℝ :=
  H.plus * v.1 ^ 2 + H.minus * v.2 ^ 2

/-- One-step Hilbert contraction, uniformly in the two-mode input state. -/
def MetricPassivityAt (H : PositiveDiagonalMetric) (s : ℂ) : Prop :=
  ∀ v : ChannelVec, metricEnergy H (channelStep s v) ≤ metricEnergy H v

/-- THE hypothetical admission, with the native actual zeta-zero predicate.
    It is an infinite mathematical assertion, NOT a terminating checker. -/
def HypotheticalAdmission : Prop :=
  ∃ H : PositiveDiagonalMetric,
    ∀ s : ℂ, ActualNontrivialZero s → MetricPassivityAt H s

/-- A single expanding positive eigenmode forbids Hilbert contractivity. -/
theorem metric_passivity_forces_critical
    (H : PositiveDiagonalMetric) (s : ℂ)
    (hpass : MetricPassivityAt H s) : s.re = 1 / 2 := by
  have h := hpass (1, 0)
  have h0 : H.plus * channelGain s ^ 2 ≤ H.plus := by
    simpa [metricEnergy, channelStep] using h
  have hplus : channelGain s ^ 2 * H.plus ≤ H.plus := by
    calc
      channelGain s ^ 2 * H.plus = H.plus * channelGain s ^ 2 := mul_comm _ _
      _ ≤ H.plus := h0
  have hgain : channelGain s ^ 2 ≤ 1 := by
    exact (mul_le_mul_right H.plus_pos).mp (by simpa using hplus)
  have hsq : criticalOffset s ^ 2 = 0 := by
    unfold channelGain cayleyNumerator at hgain
    nlinarith [sq_nonneg (criticalOffset s),
      sq_nonneg ((criticalOffset s) ^ 2)]
  have hoff : criticalOffset s = 0 := by nlinarith [hsq]
  exact (criticalOffset_eq_zero_iff s).mp hoff

/-- Every critical-line channel is an isometry in every positive diagonal metric. -/
theorem critical_implies_metric_passivity
    (H : PositiveDiagonalMetric) (s : ℂ) (hs : s.re = 1 / 2) :
    MetricPassivityAt H s := by
  intro v
  rw [channelStep_of_critical s hs]

/-- The exact pointwise mathematical theorem, with no hypothetical premise. -/
theorem metric_passivity_iff_critical
    (H : PositiveDiagonalMetric) (s : ℂ) :
    MetricPassivityAt H s ↔ s.re = 1 / 2 :=
  ⟨metric_passivity_forces_critical H s,
   critical_implies_metric_passivity H s⟩

end RHAdmission
