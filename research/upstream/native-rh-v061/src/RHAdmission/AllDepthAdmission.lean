import RHAdmission.ShiftedAxis

/-!
# Single-step metric admission iff all-depth metric admission

No new induction premise is inserted: the all-depth theorem is derived from
one-step passivity. The native zeta-zero predicate is unchanged.
-/

namespace RHAdmission

/-- Hypothetical all-depth positive-metric admission. -/
def AllDepthMetricAdmission : Prop :=
  ∃ H : PositiveTwoModeMetric,
    ∀ s : ℂ, ActualNontrivialZero s →
      ∀ n : ℕ, ∀ v : ChannelVec,
        fullMetricEnergy H (channelIterate s n v) ≤ fullMetricEnergy H v

/-- All depths are equivalent to the SAME metric's one-step inequality. -/
theorem full_admission_iff_all_depth :
    FullHypotheticalAdmission ↔ AllDepthMetricAdmission := by
  constructor
  · intro h
    exact full_admission_all_depths h
  · rintro ⟨H, hpower⟩
    refine ⟨H, ?_⟩
    intro s hz v
    have h := hpower s hz 1 v
    simpa [channelIterate] using h

/-- Mathematical closure: all-depth admission iff native Mathlib RH. -/
theorem ALL_DEPTH_ADMISSION_IFF_NATIVE_RH :
    AllDepthMetricAdmission ↔ _root_.RiemannHypothesis := by
  constructor
  · intro h
    exact full_admission_implies_native_RH (full_admission_iff_all_depth.mpr h)
  · intro h
    exact full_admission_iff_all_depth.mp (native_RH_implies_full_admission h)

/-- Coercivity supplies a genuine nonnegative Hilbert energy at each depth. -/
theorem metric_energy_coercive (H : PositiveTwoModeMetric) (v : ChannelVec) :
    H.eps * (v.1 ^ 2 + v.2 ^ 2) ≤ fullMetricEnergy H v := by
  exact H.positive v

/-- Both the coercive lower bound and the initial upper bound hold at EVERY n,
    once one-step passivity is known. -/
theorem full_metric_induction_sandwich
    (H : PositiveTwoModeMetric) (s : ℂ)
    (hpass : FullMetricPassivityAt H s) (n : ℕ) (v : ChannelVec) :
    H.eps * ((channelIterate s n v).1 ^ 2 +
             (channelIterate s n v).2 ^ 2) ≤
       fullMetricEnergy H (channelIterate s n v) ∧
    fullMetricEnergy H (channelIterate s n v) ≤ fullMetricEnergy H v := by
  exact ⟨H.positive _, full_metric_all_depths H s hpass n v⟩

/-- One globally admitted positive metric bounds every mode and depth. -/
theorem all_depth_admission_coercive
    (h : FullHypotheticalAdmission) :
    ∃ H : PositiveTwoModeMetric,
      ∀ s : ℂ, ActualNontrivialZero s →
        ∀ n : ℕ, ∀ v : ChannelVec,
          H.eps * ((channelIterate s n v).1 ^ 2 +
                   (channelIterate s n v).2 ^ 2) ≤
            fullMetricEnergy H (channelIterate s n v) ∧
          fullMetricEnergy H (channelIterate s n v) ≤ fullMetricEnergy H v := by
  obtain ⟨H, hpass⟩ := h
  refine ⟨H, ?_⟩
  intro s hz n v
  exact full_metric_induction_sandwich H s (hpass s hz) n v

end RHAdmission
