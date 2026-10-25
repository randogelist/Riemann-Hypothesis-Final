import RHAdmission.ScalarCriterion

/-!
# Cross-inference 2: only one fixed expanding seed vector is necessary

This removes the quantification over ALL input vectors from the proposed
2x2 positive-metric admission. It is a simplification of an RH-equivalent
hypothesis, not a proof of its existence.
-/

namespace RHAdmission

/-- One common positive metric, evaluated only at e₁=(1,0). -/
def SeedMetricAdmission : Prop :=
  ∃ H : PositiveTwoModeMetric,
    ∀ s : ℂ, ActualNontrivialZero s →
      fullMetricEnergy H (channelStep s (1, 0)) ≤
        fullMetricEnergy H (1, 0)

/-- Coercivity and the seed inequality force gain≤1 for each actual zero. -/
theorem seed_metric_implies_scalar (h : SeedMetricAdmission) :
    ScalarChannelAdmission := by
  obtain ⟨H, hseed⟩ := h
  intro s hz
  have hpos : H.eps ≤ H.h11 := by
    simpa using H.positive (1, 0)
  have h11 : 0 < H.h11 := lt_of_lt_of_le H.eps_pos hpos
  have hupper : H.h11 * channelGain s ^ 2 ≤ H.h11 := by
    simpa [fullMetricEnergy, channelStep] using (hseed s hz)
  have hsq : channelGain s ^ 2 ≤ 1 := by
    apply (mul_le_mul_left h11).mp
    simpa only [mul_one] using hupper
  have hgain := channelGain_one_le s
  nlinarith

/-- RH provides the identity metric and hence the seed inequality. -/
theorem native_RH_implies_seed_metric
    (hRH : _root_.RiemannHypothesis) : SeedMetricAdmission := by
  obtain ⟨H, hpass⟩ := native_RH_implies_full_admission hRH
  refine ⟨H, ?_⟩
  intro s hz
  exact hpass s hz (1, 0)

/-- Seed-only ⇔ global full quadratic passivity: no hidden successor binder. -/
theorem seed_metric_iff_full_admission :
    SeedMetricAdmission ↔ FullHypotheticalAdmission := by
  constructor
  · intro h
    have hRH : _root_.RiemannHypothesis :=
      scalar_admission_implies_native_RH (seed_metric_implies_scalar h)
    exact native_RH_implies_full_admission hRH
  · intro h
    obtain ⟨H, hpass⟩ := h
    refine ⟨H, ?_⟩
    intro s hz
    exact hpass s hz (1, 0)

/-- Native theorem: ONE input state already provides the complete equivalence. -/
theorem SEED_METRIC_ADMISSION_IFF_NATIVE_RH :
    SeedMetricAdmission ↔ _root_.RiemannHypothesis := by
  exact seed_metric_iff_full_admission.trans
    FULL_HYPOTHETICAL_ADMISSION_IFF_NATIVE_RH

end RHAdmission
