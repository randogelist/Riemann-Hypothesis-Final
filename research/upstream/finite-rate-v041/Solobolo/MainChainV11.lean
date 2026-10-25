import Solobolo.FiniteCheckerContract
import Solobolo.FinitePrefixObstruction

/-!
# SOLOBOLO v0.3: FINITE WITNESS EXISTS <-> ACTUAL RH

This is the definitive dependency-separated target theorem schema.

SOUNDNESS: accepted finite code -> all-depth quarter contraction.
COMPLETENESS: actual RH -> accepted finite code.
SOURCE: actual xi zero-product -> off-line mass identification.
RATE: RH -> dyadic weighted zero-tail contraction.

All four are currently EXPLICIT OPEN RESEARCH OBLIGATIONS. No custom axiom,
no `sorry`, no `admit`, no unchecked positivity of the actual zeta moments.

Mathematical warning: `ValidStart p N` is an infinite quantified predicate.
Its existence with N finite is NOT YET a finite *decidable* certificate.
The Boolean-checker equivalence only follows after `CheckerSound` AND
`CheckerComplete` have been independently established for one real `check`.
-/

namespace Solobolo.HypotheticalRH

/-- The admission-only equivalence, with exactly two analytic inputs. -/
theorem v11_finite_start_admission_iff_RH (p : DyadicProfile)
    (hsource : ActualRiemannHypothesis ↔ NoOffLineMass p)
    (hrate : ActualRiemannHypothesis → TailQuarterRate p) :
    (∃ N : ℕ, ValidStart p N) ↔ ActualRiemannHypothesis :=
  exists_validStart_iff_actualRH p hsource hrate

/-- An accepted witness forces RH without assuming reverse completeness. -/
theorem v11_finite_witness_sound_direction (p : DyadicProfile)
    (check : WitnessCode → Bool)
    (hsource : ActualRiemannHypothesis ↔ NoOffLineMass p)
    (hsound : CheckerSound p check) :
    (∃ w : WitnessCode, check w = true) → ActualRiemannHypothesis :=
  accepted_implies_actualRH p check hsource hsound

/-- Requested target: FINITE WITNESS EXISTS <-> ACTUAL RH.
The explicit arguments show exactly which unsolved lemmas a subsequent
finite-checker construction must discharge. -/
theorem v11_finite_witness_iff_RH (p : DyadicProfile)
    (check : WitnessCode → Bool)
    (hsource : ActualRiemannHypothesis ↔ NoOffLineMass p)
    (hrate : ActualRiemannHypothesis → TailQuarterRate p)
    (hsound : CheckerSound p check)
    (hcomplete : CheckerComplete p check) :
    (∃ w : WitnessCode, check w = true) ↔ ActualRiemannHypothesis :=
  finiteWitness_exists_iff_actualRH p check hsource hrate hsound hcomplete

#print axioms v11_finite_start_admission_iff_RH
#print axioms v11_finite_witness_sound_direction
#print axioms v11_finite_witness_iff_RH

end Solobolo.HypotheticalRH
