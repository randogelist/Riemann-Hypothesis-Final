import Frontier.LiteratureFrontier

namespace RHGPBKQR.Derivations

open RHGPBKQR
open RHGPBKQR.Literature
open RHGPBKQR.Frontier

/-- !!! Zhang 2023 gives the discrete minimal bridge RH <-> Hausdorff. -/
theorem RH_IFF_HAUSDORFF : RiemannHypothesis ↔ HausdorffPositive :=
  Zhang2023.RH_IFF_HAUSDORFF_ANCHOR

/-- !!! Zhang 2022 gives the continuous CM landing zone. -/
theorem RH_IFF_ZHANG2022_COMPLETE_MONOTONICITY :
    RiemannHypothesis ↔ Zhang2022CompleteMonotonicityHierarchy :=
  Zhang2022.RH_IFF_COMPLETE_MONOTONICITY_ANCHOR

/-- !!! All citation-pinned Zhang reconstruction identities are available. -/
theorem ZHANG_LANDING_IDENTITIES_DERIVED : ZhangLandingIdentities := by
  unfold ZhangLandingIdentities
  exact ⟨Zhang2023.PHI_MOMENT_IDENTITY_ANCHOR,
    Zhang2023.RAW_MOMENT_DERIVATIVE_IDENTITY_ANCHOR,
    Zhang2023.RAW_MOMENT_RECURRENCE_IDENTITY_ANCHOR,
    Zhang2022.XI_SQRT_ENTIRE_IDENTITY_ANCHOR,
    Zhang2022.CM_OPERATOR_IDENTITY_ANCHOR,
    Zhang2022.RESOLVENT_LAPLACE_IDENTITY_ANCHOR⟩

/-- !!! The 2023 reconstruction target is citation-pinned independently of RH. -/
theorem OPERATION_ZHANG_2023_RECONSTRUCTION_TARGET_ESTABLISHED :
    OperationZhang2023ReconstructionTarget := by
  unfold OperationZhang2023ReconstructionTarget
  exact ⟨Zhang2023.PHI_MOMENT_IDENTITY_ANCHOR,
    Zhang2023.RAW_MOMENT_DERIVATIVE_IDENTITY_ANCHOR,
    Zhang2023.RAW_MOMENT_RECURRENCE_IDENTITY_ANCHOR⟩

/-- !!! The 2022 reconstruction target is citation-pinned independently of RH. -/
theorem OPERATION_ZHANG_2022_RECONSTRUCTION_TARGET_ESTABLISHED :
    OperationZhang2022ReconstructionTarget := by
  unfold OperationZhang2022ReconstructionTarget
  exact ⟨Zhang2022.XI_SQRT_ENTIRE_IDENTITY_ANCHOR,
    Zhang2022.CM_OPERATOR_IDENTITY_ANCHOR,
    Zhang2022.RESOLVENT_LAPLACE_IDENTITY_ANCHOR⟩

/-- !!! Combined Operation Zhang reconstruction endpoint. -/
theorem OPERATION_ZHANG_RECONSTRUCTION_TARGET_ESTABLISHED :
    OperationZhangReconstructionTarget := by
  unfold OperationZhangReconstructionTarget
  exact ⟨OPERATION_ZHANG_2023_RECONSTRUCTION_TARGET_ESTABLISHED,
    OPERATION_ZHANG_2022_RECONSTRUCTION_TARGET_ESTABLISHED⟩

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

/-- !!! The extended literature frontier is derived from five paper anchors. -/
theorem LITERATURE_FRONTIER_DERIVED : LiteratureFrontier := by
  unfold LiteratureFrontier
  constructor
  · intro hRH
    exact ⟨RH_IFF_HAUSDORFF.mp hRH,
      RH_IFF_WALL.mp hRH,
      RH_IFF_WEIGHTED_SHIFT_SUBNORMAL.mp hRH,
      RH_IFF_COMPLETE_HYPERCONTRACTIVITY.mp hRH,
      RH_IFF_ZHANG2022_COMPLETE_MONOTONICITY.mp hRH⟩
  · intro h
    exact RH_IFF_HAUSDORFF.mpr h.1

end RHGPBKQR.Derivations
