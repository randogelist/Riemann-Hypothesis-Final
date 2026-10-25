import Solobolo.FiniteRateEquivalence
import Solobolo.ActualRHNormalForm

/-!
# Actual Riemann hypothesis interface for the finite-rate description

The existence of a finite code PLUS its infinite semantic upper bound is
conditionally equivalent to actual RH. This does NOT yet give a decidable
finite-witness equivalence. The source and tail-rate are open analytic bridges.
-/

namespace Solobolo.HypotheticalRH

/-- Genuine zeta RH -> finite rate parameters + proven universal bound,
conditional on actual xi zero-ledger and RH zero-counting rate. -/
theorem actualRH_implies_semanticRatePacket (p : DyadicProfile)
    (hsource : ActualRiemannHypothesis ↔ NoOffLineMass p)
    (hrate : ActualRiemannHypothesis → TailQuarterRate p)
    (hbudget : RationalBudget p) :
    ActualRiemannHypothesis → SemanticallyAcceptedRatePacket p := by
  intro hRH
  exact noOffLineMass_implies_semanticRatePacket p
    (hrate hRH) hbudget (hsource.mp hRH)

/-- The semantic rate description already excludes actual off-line zeros
once the source has been proved to be the actual zeta zero product. -/
theorem semanticRatePacket_implies_actualRH (p : DyadicProfile)
    (hsource : ActualRiemannHypothesis ↔ NoOffLineMass p) :
    SemanticallyAcceptedRatePacket p → ActualRiemannHypothesis := by
  intro h
  exact hsource.mpr (semanticRatePacket_implies_noOffLineMass p h)

/-- This statement does not suppress the infinite semantic condition. -/
theorem semanticRatePacket_iff_actualRH (p : DyadicProfile)
    (hsource : ActualRiemannHypothesis ↔ NoOffLineMass p)
    (hrate : ActualRiemannHypothesis → TailQuarterRate p)
    (hbudget : RationalBudget p) :
    SemanticallyAcceptedRatePacket p ↔ ActualRiemannHypothesis := by
  constructor
  · exact semanticRatePacket_implies_actualRH p hsource
  · exact actualRH_implies_semanticRatePacket p hsource hrate hbudget

#print axioms semanticRatePacket_iff_actualRH

end Solobolo.HypotheticalRH
