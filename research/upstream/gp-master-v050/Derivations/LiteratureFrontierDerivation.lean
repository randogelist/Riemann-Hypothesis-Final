import Frontier.LiteratureFrontier

namespace RHGPBKQR.Derivations

open RHGPBKQR
open RHGPBKQR.Literature
open RHGPBKQR.Frontier

/-- !!! Zhang gives the minimal literature bridge RH <-> Hausdorff. -/
theorem RH_IFF_HAUSDORFF : RiemannHypothesis ↔ HausdorffPositive :=
  Zhang2023.RH_IFF_HAUSDORFF_ANCHOR

/-- !!! RH <-> Wall/Sokal admissibility. -/
theorem RH_IFF_WALL : RiemannHypothesis ↔ WallAdmissible := by
  constructor
  · intro hRH
    exact Sokal2020.HAUSDORFF_IFF_WALL_ANCHOR.mp
      (Zhang2023.RH_IFF_HAUSDORFF_ANCHOR.mp hRH)
  · intro hWall
    exact Zhang2023.RH_IFF_HAUSDORFF_ANCHOR.mpr
      (Sokal2020.HAUSDORFF_IFF_WALL_ANCHOR.mpr hWall)

/-- !!! RH <-> subnormality of the canonical weighted shift. -/
theorem RH_IFF_WEIGHTED_SHIFT_SUBNORMAL :
    RiemannHypothesis ↔ WeightedShiftSubnormal := by
  constructor
  · intro hRH
    exact BergerGellarWallen.HAUSDORFF_IFF_WEIGHTED_SHIFT_SUBNORMAL_ANCHOR.mp
      (Zhang2023.RH_IFF_HAUSDORFF_ANCHOR.mp hRH)
  · intro hSub
    exact Zhang2023.RH_IFF_HAUSDORFF_ANCHOR.mpr
      (BergerGellarWallen.HAUSDORFF_IFF_WEIGHTED_SHIFT_SUBNORMAL_ANCHOR.mpr hSub)

/-- !!! RH <-> complete hypercontractivity of the canonical shift. -/
theorem RH_IFF_COMPLETE_HYPERCONTRACTIVITY :
    RiemannHypothesis ↔ WeightedShiftCompletelyHypercontractive := by
  constructor
  · intro hRH
    have hSub : WeightedShiftSubnormal := RH_IFF_WEIGHTED_SHIFT_SUBNORMAL.mp hRH
    exact Agler1985.COMPLETE_HYPERCONTRACTIVE_IFF_SUBNORMAL_ANCHOR.mpr hSub
  · intro hHyper
    have hSub : WeightedShiftSubnormal :=
      Agler1985.COMPLETE_HYPERCONTRACTIVE_IFF_SUBNORMAL_ANCHOR.mp hHyper
    exact RH_IFF_WEIGHTED_SHIFT_SUBNORMAL.mpr hSub

/-- !!! The frozen literature frontier is derived from exactly four literature anchors. -/
theorem LITERATURE_FRONTIER_DERIVED : LiteratureFrontier := by
  unfold LiteratureFrontier
  constructor
  · intro hRH
    have hH : HausdorffPositive := RH_IFF_HAUSDORFF.mp hRH
    have hW : WallAdmissible := RH_IFF_WALL.mp hRH
    have hS : WeightedShiftSubnormal := RH_IFF_WEIGHTED_SHIFT_SUBNORMAL.mp hRH
    have hC : WeightedShiftCompletelyHypercontractive :=
      RH_IFF_COMPLETE_HYPERCONTRACTIVITY.mp hRH
    exact ⟨hH, hW, hS, hC⟩
  · intro h
    exact RH_IFF_HAUSDORFF.mpr h.1

end RHGPBKQR.Derivations
