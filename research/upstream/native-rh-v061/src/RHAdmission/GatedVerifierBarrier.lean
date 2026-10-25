import RHAdmission.GatedFiniteVerifier

/-!
# Soundness barrier for any already-accepted finite metric checker

If any concrete checker has an unconditionally accepted finite code, its
native soundness claim is RH-equivalent. Positivity of the finite metric
alone does not discharge this global analytic step.
-/

namespace RHAdmission

/-- When the checker has an accepted finite code, soundness for the actual
native zeta channels is equivalent to native RH. This is NOT a proof of
soundness; it is a diagnostic of exactly what is still missing. -/
theorem GATED_SOUNDNESS_IFF_NATIVE_RH_OF_ACCEPTED
    (rawCheck : FiniteMetricCode → Bool)
    (haccepted : ∃ W : FiniteMetricCode, gatedCheck rawCheck W = true) :
    GatedActualSoundness rawCheck ↔ _root_.RiemannHypothesis := by
  constructor
  · intro hsound
    obtain ⟨W, hW⟩ := haccepted
    exact FINITELY_CODED_ADMISSION_IFF_NATIVE_RH.mp
      ⟨W, gatedCheck_metric_positive rawCheck W hW, hsound W hW⟩
  · intro hRH W hW
    intro s hz v
    have hc : s.re = 1 / 2 := hRH s hz.1 hz.2.1 hz.2.2
    rw [channelStep_of_critical s hc]

/-- Under one accepted certificate, actual native soundness alone forces
all QQRH slopes, through the already established native RH chain. -/
theorem GATED_SOUNDNESS_AND_ACCEPTANCE_FORCE_ALL_QQRH
    (rawCheck : FiniteMetricCode → Bool)
    (hsound : GatedActualSoundness rawCheck)
    (haccepted : ∃ W : FiniteMetricCode, gatedCheck rawCheck W = true) :
    ∀ m : ℝ, QQRH m := by
  have hRH : _root_.RiemannHypothesis :=
    (GATED_SOUNDNESS_IFF_NATIVE_RH_OF_ACCEPTED rawCheck haccepted).mp hsound
  exact ADMISSION_FORCES_ALL_QQRH (native_RH_implies_full_admission hRH)

end RHAdmission
