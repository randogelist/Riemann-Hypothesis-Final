import Derivations.OurFrontierDerivation
import Derivations.GP.GPIdentities
import Derivations.GP.GPContourGauge
import Derivations.GP.GPShiftLadder
import Derivations.GP.GPJet
import Derivations.Hopf.HopfPassivity
import Derivations.Hopf.PascalHopf
import Derivations.Hopf.BinaryIsometry
import Derivations.BKQR.BKQRHelpers
import Derivations.BKQR.BKQRGram
import Derivations.BKQR.BKQRContraction

namespace RHGPBKQR

open Frontier
open Derivations

#check MasterObject
#check Master.ZeroModeIdentity
#check Master.ModeShiftIdentity
#check Master.LocalQGammaIdentity
#check Master.MomentBoundaryIdentity
#check Master.PascalHopfIdentity
#check Master.EnergyHausdorffIdentity
#check Master.HausdorffPositivityIdentity

#check Derivations.Master.MASTER_ZERO_MODE
#check Derivations.Master.MASTER_MODE_SHIFT
#check Derivations.Master.MASTER_LOCAL_Q_GAMMA
#check Derivations.Master.MASTER_MOMENT_BOUNDARY
#check Derivations.Master.MASTER_PASCAL_HOPF
#check Derivations.Master.MASTER_ENERGY_HAUSDORFF
#check Derivations.Master.MASTER_HAUSDORFF_POSITIVITY
#check Derivations.Master.MASTER_TO_ZHANG_HAUSDORFF
#check Derivations.Master.MASTER_TO_RH
#check Derivations.OUR_FRONTIER_TO_HAUSDORFF
#check Derivations.OUR_FRONTIER_TO_RH

#print axioms Derivations.Master.MASTER_ZERO_MODE
#print axioms Derivations.Master.MASTER_MODE_SHIFT
#print axioms Derivations.Master.MASTER_LOCAL_Q_GAMMA
#print axioms Derivations.Master.MASTER_MOMENT_BOUNDARY
#print axioms Derivations.Master.MASTER_PASCAL_HOPF
#print axioms Derivations.Master.MASTER_ENERGY_HAUSDORFF
#print axioms Derivations.Master.MASTER_HAUSDORFF_POSITIVITY
#print axioms Derivations.Master.MASTER_TO_ZHANG_HAUSDORFF
#print axioms Derivations.Master.MASTER_TO_RH
#print axioms Derivations.OUR_FRONTIER_TO_HAUSDORFF
#print axioms Derivations.OUR_FRONTIER_TO_RH

end RHGPBKQR
