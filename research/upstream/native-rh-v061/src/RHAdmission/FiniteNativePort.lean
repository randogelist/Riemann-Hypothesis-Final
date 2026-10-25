import RHAdmission.FiniteMetricCode

/-!
# Finitely encoded *hypothetical* admission ⇔ native RH

The rational metric code has a terminating positivity check.
The following NativeCalibrated condition is NOT finite: it quantifies over
all actual nontrivial zeta zeros. This module proves a genuine equivalence
while keeping that non-finite semantic obligation visibly separate.
-/

namespace RHAdmission

/-- Analytic/global obligation NOT discharged by rational checking. -/
def NativeCalibrated (W : FiniteMetricCode)
    (hw : checkFiniteMetricCode W = true) : Prop :=
  ∀ s : ℂ, ActualNontrivialZero s →
    FullMetricPassivityAt (positiveMetricFromCode W hw) s

/-- Finitely described metric PLUS separately stated actual-zeta calibration. -/
def FinitelyCodedAdmission : Prop :=
  ∃ W : FiniteMetricCode,
    ∃ hw : checkFiniteMetricCode W = true, NativeCalibrated W hw

/-- The finite part has a concrete witness; the native part is still global. -/
theorem FINITELY_CODED_ADMISSION_IFF_NATIVE_RH :
    FinitelyCodedAdmission ↔ _root_.RiemannHypothesis := by
  constructor
  · rintro ⟨W, hw, hnative⟩
    exact full_admission_implies_native_RH
      ⟨positiveMetricFromCode W hw, hnative⟩
  · intro hRH
    refine ⟨identityMetricCode, identity_metric_code_accepted, ?_⟩
    intro s hz v
    have hc : s.re = 1 / 2 := hRH s hz.1 hz.2.1 hz.2.2
    rw [channelStep_of_critical s hc]

/-- Consequently the actual metric admission can be encoded by finite data,
    but its global calibration is not thereby finitely *checked*. -/
theorem FINITELY_CODED_ADMISSION_IFF_FULL_ADMISSION :
    FinitelyCodedAdmission ↔ FullHypotheticalAdmission := by
  exact FINITELY_CODED_ADMISSION_IFF_NATIVE_RH.trans
    FULL_HYPOTHETICAL_ADMISSION_IFF_NATIVE_RH.symm

end RHAdmission
