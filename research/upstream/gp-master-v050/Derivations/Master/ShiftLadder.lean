import Derivations.Master.ZeroMode

namespace RHGPBKQR.Derivations.Master
open RHGPBKQR
open RHGPBKQR.Master

/-- !! Identity II: contour Fourier mode `m` is the shifted GP datum `m`. -/
theorem MASTER_MODE_SHIFT (M : MasterObject) : ModeShiftIdentity M :=
  M.modeShift

end RHGPBKQR.Derivations.Master
