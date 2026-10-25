import RHAdmission.FiniteNativePort

/-!
# Real target: EXISTS ACCEPTED FINITE WITNESS ⇔ NATIVE RH

The checker must terminate. Soundness and completeness must be THEOREMS
proved independently of RH — they are not fields inside an accepted W.

This module proves the conditional reduction with the hypotheses visible.
No unconditional finite-witness equivalence or witness constructor is claimed.
-/

namespace RHAdmission

/-- The existential finite output of any proposed executable checker. -/
def HasAcceptedFiniteWitness (verify : FiniteMetricCode → Bool) : Prop :=
  ∃ W : FiniteMetricCode, verify W = true

/-- Research theorem A: acceptance must imply ACTUAL global passivity. -/
def CheckerSoundness (verify : FiniteMetricCode → Bool) : Prop :=
  ∀ W : FiniteMetricCode, verify W = true →
    ∃ hw : checkFiniteMetricCode W = true, NativeCalibrated W hw

/-- Research theorem B: RH must supply SOME accepted finite code. -/
def CheckerCompleteness (verify : FiniteMetricCode → Bool) : Prop :=
  _root_.RiemannHypothesis → HasAcceptedFiniteWitness verify

/-- The exact finite-witness iff theorem, conditional precisely on A and B. -/
theorem FINITE_WITNESS_IFF_NATIVE_RH_OF_SOUND_COMPLETE
    (verify : FiniteMetricCode → Bool)
    (hsound : CheckerSoundness verify)
    (hcomplete : CheckerCompleteness verify) :
    HasAcceptedFiniteWitness verify ↔ _root_.RiemannHypothesis := by
  constructor
  · rintro ⟨W, hW⟩
    obtain ⟨hw, hnative⟩ := hsound W hW
    exact FINITELY_CODED_ADMISSION_IFF_NATIVE_RH.mp
      ⟨W, hw, hnative⟩
  · exact hcomplete

/-- For any verifier, the two directions are EXACTLY soundness and
    completeness at the native RH level; no construction can be omitted. -/
theorem FINITE_WITNESS_IFF_SEPARATE_DIRECTIONS
    (verify : FiniteMetricCode → Bool) :
    (HasAcceptedFiniteWitness verify ↔ _root_.RiemannHypothesis) ↔
    ((HasAcceptedFiniteWitness verify → _root_.RiemannHypothesis) ∧
     (_root_.RiemannHypothesis → HasAcceptedFiniteWitness verify)) := by
  constructor
  · intro h
    exact ⟨h.mp, h.mpr⟩
  · rintro ⟨hsound, hcomplete⟩
    exact ⟨hsound, hcomplete⟩

end RHAdmission
