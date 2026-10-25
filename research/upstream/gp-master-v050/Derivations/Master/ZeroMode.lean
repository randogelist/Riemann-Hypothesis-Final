import Master.MasterIdentities

namespace RHGPBKQR.Derivations.Master
open RHGPBKQR
open RHGPBKQR.Master

/-- ! Identity I: the RH slice is the zero contour mode. -/
theorem MASTER_ZERO_MODE (M : MasterObject) : ZeroModeIdentity M :=
  M.zeroMode

end RHGPBKQR.Derivations.Master
