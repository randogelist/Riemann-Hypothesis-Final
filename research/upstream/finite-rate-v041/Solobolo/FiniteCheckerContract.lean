import Solobolo.FiniteStartAdmission

/-!
# Finite syntactic witness / Boolean acceptance contract

A code carries only a natural start and a finite list of rationals.
`check : WitnessCode -> Bool` is a total Boolean validator (supplied by a
future implementation). The checker-soundness and checker-completeness
statements are EXPLICIT PROPOSITIONS, not definitions of `check`.

No implementation is asserted to satisfy them here. In particular,
`exists_accepted_iff_actualRH` has four substantive theorem arguments:
actual xi-source, RH tail rate, checker soundness and checker completeness.
-/

namespace Solobolo.HypotheticalRH

/-- Finitely represented witness. No proof or infinite family is stored. -/
structure WitnessCode where
  start : ℕ
  payload : List ℚ
  deriving Repr, DecidableEq

/-- A Boolean checker accepts at least one finite code. -/
def AcceptedWitnessExists (check : WitnessCode → Bool) : Prop :=
  ∃ w : WitnessCode, check w = true

/-- Every accepted code establishes the *universal actual-profile* bound. -/
def CheckerSound (p : DyadicProfile) (check : WitnessCode → Bool) : Prop :=
  ∀ w : WitnessCode, check w = true → ValidStart p w.start

/-- Every semantically valid start can be encoded as an accepted finite code.
This is the hard completeness obligation of a proposed certificate language. -/
def CheckerComplete (p : DyadicProfile) (check : WitnessCode → Bool) : Prop :=
  ∀ N : ℕ, ValidStart p N →
    ∃ w : WitnessCode, w.start = N ∧ check w = true

/-- Checker soundness alone supplies the RH direction of a witness theorem. -/
theorem accepted_implies_quarter (p : DyadicProfile)
    (check : WitnessCode → Bool)
    (hsound : CheckerSound p check) :
    AcceptedWitnessExists check → QuarterAdmission p := by
  rintro ⟨w, hw⟩
  exact ⟨w.start, hsound w hw⟩

/-- Checker completeness supplies the *reverse* direction; not automatic
from the hypothetical dyadic admission, and not proved for a real checker. -/
theorem quarter_implies_accepted (p : DyadicProfile)
    (check : WitnessCode → Bool)
    (hcomplete : CheckerComplete p check) :
    QuarterAdmission p → AcceptedWitnessExists check := by
  rintro ⟨N, hN⟩
  obtain ⟨w, _, hw⟩ := hcomplete N hN
  exact ⟨w, hw⟩

/-- The purely logical Boolean-checker equivalence with the hypothetical
admission, conditional on precisely its two missing checker properties. -/
theorem accepted_iff_quarter (p : DyadicProfile)
    (check : WitnessCode → Bool)
    (hsound : CheckerSound p check)
    (hcomplete : CheckerComplete p check) :
    AcceptedWitnessExists check ↔ QuarterAdmission p := by
  constructor
  · exact accepted_implies_quarter p check hsound
  · exact quarter_implies_accepted p check hcomplete

/-- The easy accepted -> RH direction needs source calibration but not a
Riemann-von Mangoldt tail asymptotic or checker completeness. -/
theorem accepted_implies_actualRH (p : DyadicProfile)
    (check : WitnessCode → Bool)
    (hsource : ActualRiemannHypothesis ↔ NoOffLineMass p)
    (hsound : CheckerSound p check) :
    AcceptedWitnessExists check → ActualRiemannHypothesis := by
  intro hw
  apply hsource.mpr
  exact quarterAdmission_implies_noOffLineMass p
    (accepted_implies_quarter p check hsound hw)

/-- The hard RH -> finite accepted witness direction additionally needs
RH-tail rate AND completeness for the Boolean certificate language. -/
theorem actualRH_implies_accepted (p : DyadicProfile)
    (check : WitnessCode → Bool)
    (hsource : ActualRiemannHypothesis ↔ NoOffLineMass p)
    (hrate : ActualRiemannHypothesis → TailQuarterRate p)
    (hcomplete : CheckerComplete p check) :
    ActualRiemannHypothesis → AcceptedWitnessExists check := by
  intro hRH
  apply quarter_implies_accepted p check hcomplete
  exact (quarterAdmission_iff_actualRH p hsource hrate).mpr hRH

/-- Target schema: EXISTENCE OF A FINITE BOOLEAN-ACCEPTED WITNESS <-> RH.
All four mathematical obligations remain manifest in the declaration.
This theorem is NOT an unconditional proof of a computably accepted witness. -/
theorem finiteWitness_exists_iff_actualRH (p : DyadicProfile)
    (check : WitnessCode → Bool)
    (hsource : ActualRiemannHypothesis ↔ NoOffLineMass p)
    (hrate : ActualRiemannHypothesis → TailQuarterRate p)
    (hsound : CheckerSound p check)
    (hcomplete : CheckerComplete p check) :
    AcceptedWitnessExists check ↔ ActualRiemannHypothesis := by
  constructor
  · exact accepted_implies_actualRH p check hsource hsound
  · exact actualRH_implies_accepted p check hsource hrate hcomplete

#print axioms accepted_implies_actualRH
#print axioms finiteWitness_exists_iff_actualRH

end Solobolo.HypotheticalRH
