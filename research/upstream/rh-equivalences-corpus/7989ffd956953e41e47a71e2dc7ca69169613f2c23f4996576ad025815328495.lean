import Derivations.Minimal.HausdorffToMinimal
import Derivations.LiteratureFrontierDerivation

namespace RHGPBKQR.Derivations.Minimal

open RHGPBKQR
open RHGPBKQR.Frontier
open RHGPBKQR.Derivations

/-- !!! RH -> Zhang/Hausdorff -> smallest construction anchor. -/
theorem RH_TO_MINIMAL_CONSTRUCTION_ANCHOR :
    RiemannHypothesis → MinimalConstructionAnchor := by
  intro hRH
  exact HAUSDORFF_TO_MINIMAL_ANCHOR (RH_IFF_HAUSDORFF.mp hRH)

/-- !!! Smallest construction anchor -> Zhang/Hausdorff -> RH. -/
theorem MINIMAL_CONSTRUCTION_ANCHOR_TO_RH :
    MinimalConstructionAnchor → RiemannHypothesis := by
  intro hMin
  exact RH_IFF_HAUSDORFF.mpr (MINIMAL_ANCHOR_TO_HAUSDORFF hMin)

/--
!!! ONE-CHAIN RH IDENTIFIER
This is the requested vertical chain compressed into a single theorem:
RH is equivalent to the smallest presently formalized construction anchor.
-/
theorem RH_IFF_MINIMAL_CONSTRUCTION_ANCHOR :
    RiemannHypothesis ↔ MinimalConstructionAnchor := by
  constructor
  · exact RH_TO_MINIMAL_CONSTRUCTION_ANCHOR
  · exact MINIMAL_CONSTRUCTION_ANCHOR_TO_RH

end RHGPBKQR.Derivations.Minimal
