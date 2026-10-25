import Bridge.WidderStieltjesGeometry
import AWPI.PhiRH.Final

namespace NativeSoloboloContinuant

/-- Merger_04 source condition, unchanged from IMPLICATION_RH_04. -/
abbrev US : Prop := ActualCofinalUniformDepthPositive

/--
!!! New forward route: US -> all-depth Widder positivity -> Stieltjes slit
zero-exclusion -> Mathlib RH. PPC is not used.
-/
theorem US_IMPLIES_RH_STIELTJES_ROUTE
    (hDown : ActualWidderDownwardPositivity)
    (hStieltjes : ActualWidderStieltjesSlitExclusion)
    (hUS : US) :
    RiemannHypothesis := by
  apply ACTUAL_SLIT_ZERO_FREE_IMPLIES_MATHLIB_RH
  exact hStieltjes (US_IMPLIES_ALL_DEPTH_WIDDER_POSITIVITY hDown hUS)

/-- Reverse route: RH -> all-depth Widder positivity -> US. -/
theorem RH_IMPLIES_US_ZERO_CHANNEL_ROUTE
    (hReverse : RHImpliesAllDepthWidderPositive)
    (hRH : RiemannHypothesis) :
    US :=
  ALL_DEPTH_WIDDER_POSITIVITY_IMPLIES_US (hReverse hRH)

/--
!!! MERGER_04 equivalence architecture.
All remaining analytic obligations are explicit theorem arguments, not axioms.
-/
theorem US_IFF_MATHLIB_RH_05
    (hDown : ActualWidderDownwardPositivity)
    (hStieltjes : ActualWidderStieltjesSlitExclusion)
    (hReverse : RHImpliesAllDepthWidderPositive) :
    US ↔ RiemannHypothesis := by
  constructor
  · exact US_IMPLIES_RH_STIELTJES_ROUTE hDown hStieltjes
  · exact RH_IMPLIES_US_ZERO_CHANNEL_ROUTE hReverse

/-- Existing independent PPC anchor. -/
theorem PPC_IFF_MATHLIB_RH_05 :
    AWPI.PhiRH.Final.PlusPassivityCore ↔ RiemannHypothesis :=
  AWPI.PhiRH.Final.plusPassivityCore_iff_riemannHypothesis

/-- !!! Once the three analytic interfaces are discharged, US and PPC coincide. -/
theorem US_IFF_PPC_05
    (hDown : ActualWidderDownwardPositivity)
    (hStieltjes : ActualWidderStieltjesSlitExclusion)
    (hReverse : RHImpliesAllDepthWidderPositive) :
    US ↔ AWPI.PhiRH.Final.PlusPassivityCore :=
  (US_IFF_MATHLIB_RH_05 hDown hStieltjes hReverse).trans
    PPC_IFF_MATHLIB_RH_05.symm

/-- Compact equivalence atlas for the two independent anchors. -/
theorem US_RH_PPC_EQUIVALENCE_ATLAS_05
    (hDown : ActualWidderDownwardPositivity)
    (hStieltjes : ActualWidderStieltjesSlitExclusion)
    (hReverse : RHImpliesAllDepthWidderPositive) :
    (US ↔ RiemannHypothesis) ∧
    (US ↔ AWPI.PhiRH.Final.PlusPassivityCore) ∧
    (AWPI.PhiRH.Final.PlusPassivityCore ↔ RiemannHypothesis) := by
  exact ⟨US_IFF_MATHLIB_RH_05 hDown hStieltjes hReverse,
    US_IFF_PPC_05 hDown hStieltjes hReverse,
    PPC_IFF_MATHLIB_RH_05⟩

end NativeSoloboloContinuant
