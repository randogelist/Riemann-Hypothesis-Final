import RHAdmission.FiniteVerifierContract

/-!
# Anti-circularity test

The elementary rational positivity checker already accepts the identity
metric even if nothing is known about RH. Therefore soundness for THIS
checker alone would itself constitute a proof of RH.

This makes the missing actual-zeta bridge impossible to conceal in a
checker name, a positive metric, or a generic Hilbert-space model.
-/

namespace RHAdmission

/-- Exact obstruction: soundness of the bare rational positivity checker is
    equivalent to proving native RH itself. -/
theorem POSITIVE_ONLY_CHECKER_SOUNDNESS_IFF_NATIVE_RH :
    CheckerSoundness checkFiniteMetricCode ↔ _root_.RiemannHypothesis := by
  constructor
  · intro hsound
    obtain ⟨hw, hnative⟩ :=
      hsound identityMetricCode identity_metric_code_accepted
    exact FINITELY_CODED_ADMISSION_IFF_NATIVE_RH.mp
      ⟨identityMetricCode, hw, hnative⟩
  · intro hRH W hw
    refine ⟨hw, ?_⟩
    intro s hz v
    have hc : s.re = 1 / 2 := hRH s hz.1 hz.2.1 hz.2.2
    rw [channelStep_of_critical s hc]

/-- Bare positivity-check acceptance has a witness without using RH. -/
theorem POSITIVE_ONLY_ACCEPTED_UNCONDITIONALLY :
    HasAcceptedFiniteWitness checkFiniteMetricCode :=
  finite_metric_code_always_exists

/-- Even an iff theorem for the positivity-only check is equivalent to RH:
    it would not be a noncircular witness construction. -/
theorem POSITIVE_ONLY_FINITE_WITNESS_IFF_RH_EQUIV_RH :
    (HasAcceptedFiniteWitness checkFiniteMetricCode ↔
      _root_.RiemannHypothesis) ↔ _root_.RiemannHypothesis := by
  constructor
  · intro h
    exact h.mp POSITIVE_ONLY_ACCEPTED_UNCONDITIONALLY
  · intro hRH
    exact ⟨fun _ => hRH, fun _ => POSITIVE_ONLY_ACCEPTED_UNCONDITIONALLY⟩

end RHAdmission
