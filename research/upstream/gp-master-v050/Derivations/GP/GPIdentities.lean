import Derivations.Master.ZeroMode
import Derivations.Master.ShiftLadder

namespace RHGPBKQR.Derivations.GP
open RHGPBKQR
open RHGPBKQR.Master

/-- !!! GP/u-gauge zero-mode identity from the unified master object. -/
theorem GP_ZERO_MODE_FROM_MASTER (M : MasterObject) : ZeroModeIdentity M :=
  RHGPBKQR.Derivations.Master.MASTER_ZERO_MODE M

/-- !!! GP shift ladder from the unified master object. -/
theorem GP_SHIFT_FROM_MASTER (M : MasterObject) : ModeShiftIdentity M :=
  RHGPBKQR.Derivations.Master.MASTER_MODE_SHIFT M

end RHGPBKQR.Derivations.GP
