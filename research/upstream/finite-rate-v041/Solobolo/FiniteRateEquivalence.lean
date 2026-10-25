import Solobolo.FiniteRateInduction
import Solobolo.FiniteStartAdmission

/-!
# Finite-datum SEMANTIC rate equivalence

Important: the all-index semantic bound is still a Prop, not a terminating
checker. This theorem proves that finitely many rational PARAMETERS suffice to
DESCRIBE a suitable envelope under RH, not that an algorithm can validate it.
-/

namespace Solobolo.HypotheticalRH

/-- The real residual has some rational upper enclosure at each fixed index. -/
def RationalBudget (p : DyadicProfile) : Prop :=
  ∀ n : ℕ, ∃ q : ℚ, 0 ≤ q ∧ residual p n ≤ (q : ℝ)

/-- Finite parameters with a (still mathematical) all-depth semantic claim. -/
def SemanticallyAcceptedRatePacket (p : DyadicProfile) : Prop :=
  ∃ w : RatePacket,
    ratePacketCheck w = true ∧ RatePacketBound p w

/-- The forward implication requires NO tail rate or rational budget lemma. -/
theorem semanticRatePacket_implies_noOffLineMass (p : DyadicProfile) :
    SemanticallyAcceptedRatePacket p → NoOffLineMass p := by
  rintro ⟨w, hcheck, hbound⟩
  exact ratePacketBound_implies_noOffLineMass p w hcheck hbound

/-- A vanishing off-line mass and the RH tail rate produce finite rational
parameters for a 3/4 envelope. The bound itself is then proved by induction. -/
theorem noOffLineMass_implies_semanticRatePacket (p : DyadicProfile)
    (hrate : TailQuarterRate p) (hbudget : RationalBudget p) :
    NoOffLineMass p → SemanticallyAcceptedRatePacket p := by
  intro hzero
  obtain ⟨N, hs⟩ := noOffLineMass_implies_quarterAdmission_of_tailRate
    p hrate hzero
  obtain ⟨q, hq, hqbound⟩ := hbudget N
  let w : RatePacket := ⟨N, q⟩
  refine ⟨w, ?_, ?_⟩
  · exact (ratePacketCheck_iff w).2 hq
  · intro k
    have hgeo := quarter_geometric_induction p N hs k
    have hpow : 0 ≤ (3 / 4 : ℝ) ^ k := pow_nonneg (by norm_num) k
    calc
      residual p (w.start + k) ≤
          (3 / 4 : ℝ) ^ k * residual p N := by
            simpa [w] using hgeo
      _ ≤ (3 / 4 : ℝ) ^ k * (q : ℝ) :=
          mul_le_mul_of_nonneg_left hqbound hpow
      _ = (w.budget : ℝ) * (3 / 4 : ℝ) ^ k := by
          dsimp [w]
          ring

/-- Semantic finite-parameter equivalence; NOT Boolean-checker equivalence. -/
theorem semanticRatePacket_iff_noOffLineMass (p : DyadicProfile)
    (hrate : TailQuarterRate p) (hbudget : RationalBudget p) :
    SemanticallyAcceptedRatePacket p ↔ NoOffLineMass p := by
  constructor
  · exact semanticRatePacket_implies_noOffLineMass p
  · exact noOffLineMass_implies_semanticRatePacket p hrate hbudget

#print axioms semanticRatePacket_iff_noOffLineMass

end Solobolo.HypotheticalRH
