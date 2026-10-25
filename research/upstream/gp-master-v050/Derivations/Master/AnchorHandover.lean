import Derivations.Master.HausdorffPositivity
import Derivations.LiteratureFrontierDerivation

namespace RHGPBKQR.Derivations.Master
open RHGPBKQR

/-- !!! Master object -> Zhang/Hausdorff -> RH. -/
theorem MASTER_TO_RH (M : MasterObject) : RiemannHypothesis :=
  RHGPBKQR.Derivations.RH_IFF_HAUSDORFF.mpr (MASTER_TO_ZHANG_HAUSDORFF M)

end RHGPBKQR.Derivations.Master
