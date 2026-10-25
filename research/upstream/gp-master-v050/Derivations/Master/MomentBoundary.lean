import Derivations.Master.LocalQGamma

namespace RHGPBKQR.Derivations.Master
open RHGPBKQR
open RHGPBKQR.Master

/-- !! Identity IV: the GP moment sequence is the boundary energy of the master state. -/
theorem MASTER_MOMENT_BOUNDARY (M : MasterObject) : MomentBoundaryIdentity M :=
  M.momentBoundary

end RHGPBKQR.Derivations.Master
