import Solobolo.MainChainV12
import Solobolo.RationalBudgetClosed

/-!
# Strongest finite-description semantic equivalence, no budget premise

FINITE WITNESS <-> RH remains the research objective. The semantic
rate-packet equivalence shown here is not a Boolean witness equivalence.
-/

namespace Solobolo.HypotheticalRH

theorem v13_semanticRatePacket_iff_actualRH (p : DyadicProfile)
    (hsource : ActualRiemannHypothesis ↔ NoOffLineMass p)
    (hrate : ActualRiemannHypothesis → TailQuarterRate p) :
    SemanticallyAcceptedRatePacket p ↔ ActualRiemannHypothesis :=
  semanticRatePacket_iff_actualRH p hsource hrate
    (rationalBudget_unconditional p)

#print axioms v13_semanticRatePacket_iff_actualRH

end Solobolo.HypotheticalRH
