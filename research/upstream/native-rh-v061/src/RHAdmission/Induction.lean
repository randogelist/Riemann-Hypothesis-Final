import RHAdmission.Equivalence

/-!
# The full n -> n+1 transition is already ordinary induction.

This theorem concerns the explicit positive two-mode Hilbert metric.  It
must NOT be interpreted as positivity of the actual xi Widder derivatives
without proving the corresponding independent identification.
-/

namespace RHAdmission

/-- One-step passivity lifts to all finite powers with NO further assumptions. -/
theorem metric_passivity_all_depths
    (H : PositiveDiagonalMetric) (s : ℂ)
    (hpass : MetricPassivityAt H s) :
    ∀ n : ℕ, ∀ v : ChannelVec,
      metricEnergy H (channelIterate s n v) ≤ metricEnergy H v := by
  intro n
  induction n with
  | zero =>
      intro v
      simp [channelIterate]
  | succ n ih =>
      intro v
      calc
        metricEnergy H (channelIterate s (n + 1) v)
            = metricEnergy H (channelStep s (channelIterate s n v)) := rfl
        _ ≤ metricEnergy H (channelIterate s n v) := hpass _
        _ ≤ metricEnergy H v := ih v

/-- All actual nontrivial zeta-zero modes are power-contractive under the
    single hypothetical admission. -/
theorem admitted_all_depths (hAdmission : HypotheticalAdmission) :
    ∃ H : PositiveDiagonalMetric,
      ∀ s : ℂ, ActualNontrivialZero s →
        ∀ n : ℕ, ∀ v : ChannelVec,
          metricEnergy H (channelIterate s n v) ≤ metricEnergy H v := by
  obtain ⟨H, hpass⟩ := hAdmission
  refine ⟨H, ?_⟩
  intro s hs n v
  exact metric_passivity_all_depths H s (hpass s hs) n v

/-- Equivalent endpoint: after admission, every admitted channel is in fact
    an ordinary isometry, not merely a nonexpanding map. -/
theorem admitted_isometry_all_depths (hAdmission : HypotheticalAdmission) :
    ∀ s : ℂ, ActualNontrivialZero s →
      ∀ n : ℕ, ∀ v : ChannelVec, channelIterate s n v = v := by
  have hRH := admission_implies_native_RH hAdmission
  intro s hs n v
  have hc : s.re = 1 / 2 := hRH s hs.1 hs.2.1 hs.2.2
  induction n with
  | zero => rfl
  | succ n ih =>
      change channelStep s (channelIterate s n v) = v
      rw [ih, channelStep_of_critical s hc]

end RHAdmission
