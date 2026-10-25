import Solobolo.FiniteRateActualInterface
import Solobolo.FinitePrefixObstruction

/-!
# Barrier against a spurious finite-witness claim

A rational-only syntax checker can accept a packet even when an unrelated
abstract zero ledger contains off-line mass. Exact calibration is indispensable.
-/

namespace Solobolo.HypotheticalRH

/-- The checker accepts an empty zero-budget packet even for a positive-mass
abstract ledger. Acceptance alone is not the missing actual-source theorem. -/
theorem syntaxAccepted_does_not_imply_universalBound :
    ratePacketCheck ⟨0, 0⟩ = true ∧
      ¬ RatePacketBound prefixPositiveMassProfile ⟨0, 0⟩ := by
  constructor
  · exact ratePacketCheck_zero
  · intro h
    have h0 := h 0
    norm_num [RatePacketBound, residual, prefixPositiveMassProfile] at h0

/-- Therefore the concrete rational syntax check cannot be claimed to
establish actual RH without additional verified analytic calibration. -/
theorem no_universal_syntax_soundness :
    ¬ (∀ p : DyadicProfile, ∀ w : RatePacket,
      ratePacketCheck w = true → RatePacketBound p w) := by
  intro h
  have hbad := h prefixPositiveMassProfile ⟨0, 0⟩ ratePacketCheck_zero
  exact syntaxAccepted_does_not_imply_universalBound.2 hbad

#print axioms no_universal_syntax_soundness

end Solobolo.HypotheticalRH
