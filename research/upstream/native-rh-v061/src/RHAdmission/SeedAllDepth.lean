import RHAdmission.SeedAdmission

/-!
# Cross-inference 3: a single metric and seed suffice at ALL depths

A one-step estimate and ordinary induction imply power passivity.
Conversely the n=1 case of all-depth passivity recovers the seed.
-/

namespace RHAdmission

/-- Only the ONE seed vector is bounded for every positive integer depth. -/
def SeedAllDepthAdmission : Prop :=
  ∃ H : PositiveTwoModeMetric,
    ∀ s : ℂ, ActualNontrivialZero s →
      ∀ n : ℕ,
        fullMetricEnergy H (channelIterate s n (1, 0)) ≤
          fullMetricEnergy H (1, 0)

/-- A proved one-step bound gives the SAME positive metric at every depth. -/
theorem seed_metric_implies_all_depth (h : SeedMetricAdmission) :
    SeedAllDepthAdmission := by
  have hfull := seed_metric_iff_full_admission.mp h
  obtain ⟨H, hpass⟩ := hfull
  refine ⟨H, ?_⟩
  intro s hz n
  exact full_metric_all_depths H s (hpass s hz) n (1, 0)

/-- Depth 1 of a seed-power bound already supplies one-step passivity. -/
theorem seed_all_depth_implies_seed_metric
    (h : SeedAllDepthAdmission) : SeedMetricAdmission := by
  obtain ⟨H, hpower⟩ := h
  refine ⟨H, ?_⟩
  intro s hz
  simpa [channelIterate] using (hpower s hz 1)

/-- No additional induction hypothesis: it is equivalent to the first step. -/
theorem seed_all_depth_iff_seed_metric :
    SeedAllDepthAdmission ↔ SeedMetricAdmission :=
  ⟨seed_all_depth_implies_seed_metric, seed_metric_implies_all_depth⟩

/-- The all-depth statement is again an equivalent RH condition, not RH itself. -/
theorem SEED_ALL_DEPTH_ADMISSION_IFF_NATIVE_RH :
    SeedAllDepthAdmission ↔ _root_.RiemannHypothesis := by
  exact seed_all_depth_iff_seed_metric.trans
    SEED_METRIC_ADMISSION_IFF_NATIVE_RH

end RHAdmission
