import Frontier.OurFrontier
import Derivations.Master.SourceToMaster
import Derivations.Master.AnchorHandover

namespace RHGPBKQR.Derivations
open RHGPBKQR
open RHGPBKQR.Frontier

/-- !!! The generated source frontier implies Zhang/Hausdorff positivity. -/
theorem OUR_FRONTIER_TO_HAUSDORFF : OurFrontier → HausdorffPositive := by
  intro h
  exact Nonempty.elim h (fun S =>
    RHGPBKQR.Derivations.Master.MASTER_TO_ZHANG_HAUSDORFF
      (RHGPBKQR.Derivations.Master.MASTER_SOURCE_TO_MASTER S))

/-- !!! The generated source frontier implies RH using only Zhang as the research hinge. -/
theorem OUR_FRONTIER_TO_RH : OurFrontier → RiemannHypothesis := by
  intro h
  exact Nonempty.elim h (fun S =>
    RHGPBKQR.Derivations.Master.MASTER_TO_RH
      (RHGPBKQR.Derivations.Master.MASTER_SOURCE_TO_MASTER S))

/-- !!! Our frontier explicitly contains a generated unified master object. -/
theorem OUR_FRONTIER_TO_MASTER : OurFrontier → Nonempty MasterObject := by
  intro h
  exact Nonempty.elim h (fun S =>
    ⟨RHGPBKQR.Derivations.Master.MASTER_SOURCE_TO_MASTER S⟩)

end RHGPBKQR.Derivations
