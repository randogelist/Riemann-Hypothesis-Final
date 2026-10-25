import Migration.DirectXiBinding

namespace Merger04.ForwardChannel

open NativeSoloboloNegativity Merger04.Migration

/--
The sole remaining forward analytic construction.

It asks only for the direct actual-Xi peak packet attached to a hypothetical
failure of Mathlib RH, with its limiting anchor in the already-proved regular
Xi domain.  All recurrence transport, phase dominance, tail control,
regularization migration, and contradiction with frozen US are proved outside
this proposition.
-/
def ActualOffLineDirectChannelAnalysis : Prop :=
  ¬ _root_.RiemannHypothesis →
    ∃ P : ChannelPeakData xiWidderDirect,
      P.baseAnchor ∈ xiRegularAnchors

/-- The sole channel construction implies the old eventual-negativity shape,
    now for the regularized moment profile rather than as a separate premise. -/
theorem OFFLINE_DIRECT_CHANNEL_IMPLIES_REGULARIZED_EVENTUAL_NEGATIVITY
    (hchannel : ActualOffLineDirectChannelAnalysis) :
    ¬ _root_.RiemannHypothesis →
      ∃ K : ℕ, ∀ n : ℕ, K ≤ n →
        ∃ a : ℝ, 0 < a ∧ moment Merger04.Regularization.entireXi a n < 0 := by
  intro hnot
  rcases hchannel hnot with ⟨P, hbase⟩
  exact DIRECT_PEAK_DATA_GIVE_REGULARIZED_EVENTUAL_NEGATIVITY P hbase

/--
!!! MERGER_04 FORWARD REDUCTION
Frozen US itself, not a replacement predicate, implies Mathlib RH once the
actual off-line zero is converted to the direct Xi channel packet.
-/
theorem FROZEN_US_IMPLIES_RH_FROM_DIRECT_CHANNEL
    (hchannel : ActualOffLineDirectChannelAnalysis)
    (hUS : NativeSoloboloContinuant.ActualCofinalUniformDepthPositive) :
    _root_.RiemannHypothesis := by
  have hReg : RegularizedUS := FROZEN_US_IMPLIES_REGULARIZED_US hUS
  by_contra hnot
  rcases hchannel hnot with ⟨P, hbase⟩
  exact REGULARIZED_US_EXCLUDES_DIRECT_PEAK_DATA hReg P hbase

/-- Exact contrapositive form requested by the Merger_04 architecture. -/
theorem NOT_RH_IMPLIES_NOT_FROZEN_US_FROM_DIRECT_CHANNEL
    (hchannel : ActualOffLineDirectChannelAnalysis) :
    ¬ _root_.RiemannHypothesis →
      ¬ NativeSoloboloContinuant.ActualCofinalUniformDepthPositive := by
  intro hnot hUS
  exact hnot (FROZEN_US_IMPLIES_RH_FROM_DIRECT_CHANNEL hchannel hUS)

end Merger04.ForwardChannel
