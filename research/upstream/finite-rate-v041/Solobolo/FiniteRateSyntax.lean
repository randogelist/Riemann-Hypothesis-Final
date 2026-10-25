import Solobolo.FiniteCheckerContract

/-!
# Finite rational SOLOBOLO rate packet

An ACTUAL, terminating rational-only Boolean syntax check. It verifies only
finite packet admissibility and does not claim to know actual zeta residuals.
Every output proof stays separate from the source-calibration frontier.
-/

namespace Solobolo.HypotheticalRH

structure RatePacket where
  start : ℕ
  budget : ℚ
  deriving Repr, DecidableEq

/-- A terminating Boolean test for the nonnegative rational envelope budget. -/
def ratePacketCheck (w : RatePacket) : Bool :=
  decide (0 ≤ w.budget)

/-- Explicit encoding into the original finite `WitnessCode` data language. -/
def RatePacket.toWitnessCode (w : RatePacket) : WitnessCode :=
  { start := w.start, payload := [w.budget, (3/4 : ℚ)] }

theorem ratePacketCheck_iff (w : RatePacket) :
    ratePacketCheck w = true ↔ 0 ≤ w.budget := by
  simp [ratePacketCheck]

/-- The finite packet is syntactically accepted; no analytic assertion follows. -/
theorem ratePacketCheck_zero :
    ratePacketCheck ⟨0, 0⟩ = true := by
  decide

/-- The semantic all-depth bound is deliberately NOT part of the Boolean test. -/
def RatePacketBound (p : DyadicProfile) (w : RatePacket) : Prop :=
  ∀ k : ℕ, residual p (w.start + k) ≤
    (w.budget : ℝ) * (3 / 4 : ℝ) ^ k

#print axioms ratePacketCheck_iff

end Solobolo.HypotheticalRH
