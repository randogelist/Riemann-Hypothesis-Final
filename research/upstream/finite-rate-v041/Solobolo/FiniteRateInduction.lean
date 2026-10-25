import Solobolo.FiniteRateSyntax
import Solobolo.GeometricAdmission

/-!
# Finite packet, universal successor, geometric budget

The exact transition is proved once and for all. This theorem has an explicitly
quantified analytic successor premise, which a future trusted checker must
discharge from the actual xi source.
-/

namespace Solobolo.HypotheticalRH

/-- One initial budget and a universal 3/4 successor produce every bound. -/
theorem ratePacket_induction (p : DyadicProfile) (w : RatePacket)
    (hbase : residual p w.start ≤ (w.budget : ℝ))
    (hstep : ∀ n ≥ w.start,
      residual p (n + 1) ≤ (3 / 4 : ℝ) * residual p n) :
    RatePacketBound p w := by
  intro k
  induction k with
  | zero => simpa [RatePacketBound] using hbase
  | succ k ih =>
      have hn : w.start ≤ w.start + k := Nat.le_add_right w.start k
      calc
        residual p (w.start + (k + 1)) =
            residual p ((w.start + k) + 1) := by simp [Nat.add_assoc]
        _ ≤ (3 / 4 : ℝ) * residual p (w.start + k) :=
          hstep (w.start + k) hn
        _ ≤ (3 / 4 : ℝ) * ((w.budget : ℝ) * (3 / 4 : ℝ) ^ k) :=
          mul_le_mul_of_nonneg_left ih (by norm_num)
        _ = (w.budget : ℝ) * (3 / 4 : ℝ) ^ (k + 1) := by
          rw [pow_succ]
          ring

/-- The packet's all-depth semantic bound eliminates off-line mass. -/
theorem ratePacketBound_implies_noOffLineMass (p : DyadicProfile)
    (w : RatePacket) (hcheck : ratePacketCheck w = true)
    (hbound : RatePacketBound p w) : NoOffLineMass p := by
  have hn : (0 : ℝ) ≤ (w.budget : ℝ) := by
    exact_mod_cast (ratePacketCheck_iff w).mp hcheck
  have hgeo : GeometricAdmission p := by
    refine ⟨w.start, (w.budget : ℝ), hn, ?_⟩
    exact hbound
  exact (epsilonAdmission_iff_noOffLineMass p).mp
    (geometricAdmission_implies_epsilonAdmission p hgeo)

#print axioms ratePacket_induction
#print axioms ratePacketBound_implies_noOffLineMass

end Solobolo.HypotheticalRH
