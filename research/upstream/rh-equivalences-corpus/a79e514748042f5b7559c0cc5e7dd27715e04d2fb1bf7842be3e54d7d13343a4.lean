import Frontier.OurFrontier
import Derivations.Master.AnchorHandover

namespace RHGPBKQR.Derivations
open RHGPBKQR
open RHGPBKQR.Frontier

/-- !!! The unified frontier implies Zhang/Hausdorff positivity. -/
theorem OUR_FRONTIER_TO_HAUSDORFF : OurFrontier → HausdorffPositive := by
  intro h
  exact Nonempty.elim h RHGPBKQR.Derivations.Master.MASTER_TO_ZHANG_HAUSDORFF

/-- !!! The unified frontier implies RH using only Zhang as the research hinge. -/
theorem OUR_FRONTIER_TO_RH : OurFrontier → RiemannHypothesis := by
  intro h
  exact Nonempty.elim h RHGPBKQR.Derivations.Master.MASTER_TO_RH

end RHGPBKQR.Derivations
