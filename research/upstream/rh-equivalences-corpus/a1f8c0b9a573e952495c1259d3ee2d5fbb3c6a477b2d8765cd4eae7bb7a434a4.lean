import Anchors.ConcreteXiKernelCalibration
import Literature.Zhang2023

namespace GPBKQRAnchoring01

open RHGPBKQR
open RHGPBKQR.Literature

/-- One-paper RH closure from the genuinely concrete finite Tier-A kernel
calibration.  The core implication to Hausdorff positivity is axiom-free; this
last handover uses exactly Zhang 2023. -/
theorem ACTUAL_XI_CONCRETE_PACKAGE_IMPLIES_RH :
    ActualXiConcreteTierAPackage → RHGPBKQR.RiemannHypothesis := by
  intro h
  exact Zhang2023.RH_IFF_HAUSDORFF_ANCHOR.mpr
    (ACTUAL_XI_CONCRETE_PACKAGE_TO_HAUSDORFF h)

/-- With the standard truncated Hausdorff finite-realization theorem, the
concrete package becomes genuinely equivalent to RH. -/
theorem RH_IFF_ACTUAL_XI_CONCRETE_PACKAGE
    (hRealize : TruncatedHausdorffFiniteKernelRealization) :
    RHGPBKQR.RiemannHypothesis ↔ ActualXiConcreteTierAPackage := by
  exact Zhang2023.RH_IFF_HAUSDORFF_ANCHOR.trans
    (HAUSDORFF_IFF_ACTUAL_XI_CONCRETE_PACKAGE hRealize)

end GPBKQRAnchoring01
