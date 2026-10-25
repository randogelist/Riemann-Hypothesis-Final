import RHAdmission.GatedVerifierBarrier

/-!
# Exact positive seed defect for the native-zero-indexed Cayley numerator model

The one-step algebraic mode is a proxy: the separate actual GP/Mellin
operator identification is NOT asserted. This proof identifies the exact
finite obstruction that any sound native finite verifier must exclude.
-/

namespace RHAdmission

/-- Exact algebraic energy defect at the expanding seed `e₁`. -/
theorem positive_metric_seed_defect_formula
    (H : PositiveTwoModeMetric) (s : ℂ) :
    fullMetricEnergy H (channelStep s (1, 0)) -
      fullMetricEnergy H (1, 0) =
        H.h11 * (8 * criticalOffset s ^ 2 +
          16 * (criticalOffset s ^ 2) ^ 2) := by
  simp [fullMetricEnergy, channelStep, channelGain, cayleyNumerator]
  ring

/-- A strictly off-line label expands the *same* seed under every
coercive positive metric. No universal vector quantifier is necessary. -/
theorem positive_metric_seed_defect_strict
    (H : PositiveTwoModeMetric) (s : ℂ)
    (hoff : s.re ≠ 1 / 2) :
    fullMetricEnergy H (1, 0) <
      fullMetricEnergy H (channelStep s (1, 0)) := by
  have hcoercive : H.eps ≤ H.h11 := by
    simpa using H.positive (1, 0)
  have h11 : 0 < H.h11 := lt_of_lt_of_le H.eps_pos hcoercive
  have hdelta : criticalOffset s ≠ 0 := by
    intro hz
    exact hoff ((criticalOffset_eq_zero_iff s).mp hz)
  have hdelta2 : 0 < criticalOffset s ^ 2 := by
    by_contra hn
    have hzero : criticalOffset s ^ 2 = 0 :=
      le_antisymm (le_of_not_gt hn) (sq_nonneg _)
    have hz : criticalOffset s = 0 := by nlinarith [hzero]
    exact hdelta hz
  have hsq : 0 ≤ (criticalOffset s ^ 2) ^ 2 := sq_nonneg _
  have hterm : 0 < (8 : ℝ) * criticalOffset s ^ 2 +
      16 * (criticalOffset s ^ 2) ^ 2 := by
    nlinarith
  have hgain : 0 < H.h11 *
      (8 * criticalOffset s ^ 2 + 16 * (criticalOffset s ^ 2) ^ 2) :=
    mul_pos h11 hterm
  rw [← positive_metric_seed_defect_formula H s] at hgain
  linarith

/-- Off-line channels refute even the single-seed version of positive passivity. -/
theorem off_line_rejects_seed_passivity (s : ℂ)
    (hoff : s.re ≠ 1 / 2) (H : PositiveTwoModeMetric) :
    ¬ (fullMetricEnergy H (channelStep s (1, 0)) ≤
      fullMetricEnergy H (1, 0)) := by
  intro hpass
  exact (not_le.mpr (positive_metric_seed_defect_strict H s hoff)) hpass

end RHAdmission
