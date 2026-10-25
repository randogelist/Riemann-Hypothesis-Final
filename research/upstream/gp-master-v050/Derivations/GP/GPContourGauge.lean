import Derivations.Master.LocalQGamma

namespace RHGPBKQR.Derivations.GP
open RHGPBKQR
open RHGPBKQR.Master

/-- !!! Local contour-Q energy from the unified master object. -/
theorem GP_LOCAL_Q_FROM_MASTER (M : MasterObject) : LocalQGammaIdentity M :=
  RHGPBKQR.Derivations.Master.MASTER_LOCAL_Q_GAMMA M

end RHGPBKQR.Derivations.GP
