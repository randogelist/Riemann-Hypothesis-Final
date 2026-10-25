import RHFinal.GP.KQEndpoints
import RHFinal.GP.GP7Endpoints
import RHFinal.GP.MasterEndpoints
import RHFinal.GP.Literal
import RHFinal.GP.NativeBinding

/-!
Integrated GP construction entry point. This imports actual native-xi
interfaces, supplementary finite GP7 algebra, generic master energy induction,
and the literal Mellin--Hilbert definitions. It does not assert that the
remaining actual calibration or finite witness obligations have been solved.
Run `run.cmd full` for the native Lean build and the separate audit modules.
-/
