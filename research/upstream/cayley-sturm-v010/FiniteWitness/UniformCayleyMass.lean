import FiniteWitness.BernsteinSolobolo
import FiniteWitness.TelescopicSpectrum

/-!
# Uniform finite SOLOBOLO trace budgets

The mass of a rational positive spectrum controls EVERY positive Cayley
power trace, regardless of depth and rank. This is a proved algebraic
uniform bound, NOT an actual-xi calibration.
-/

namespace WitnessSolobolo

/-- Every power p+1 of a contractive scalar is below the scalar. -/
theorem power_succ_le_self_of_unit
    {x : ℚ} (hx0 : 0 ≤ x) (hx1 : x ≤ 1) (p : ℕ) :
    x ^ (p+1) ≤ x := by
  have hpow : x ^ p ≤ 1 := pow_le_one₀ hx0 hx1
  calc
    x ^ (p+1) = x ^ p * x := pow_succ x p
    _ ≤ 1 * x := mul_le_mul_of_nonneg_right hpow hx0
    _ = x := one_mul _

/-- The Cayley contraction is bounded by four times its input mass. -/
theorem cayleyQ_le_four_mul {t : ℚ}
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    cayleyQ t ≤ 4*t := by
  unfold cayleyQ
  have hn : 0 ≤ 4*t := mul_nonneg (by norm_num) ht0
  nlinarith

/-- Uniform at ALL depths: same finite spectrum, no recalibration. -/
theorem cayleyTrace_uniform_mass
    (w : FiniteWitness) (N p : ℕ)
    (h : ∀ i : Fin (N + 1 + w.rankOffset),
      0 ≤ atom w N i ∧ atom w N i ≤ 1) :
    0 ≤ cayleyPowerTrace w N (p+1) ∧
      cayleyPowerTrace w N (p+1) ≤ 4 * mass w N := by
  constructor
  · unfold cayleyPowerTrace
    apply Finset.sum_nonneg
    intro i hi
    have hq := cayleyQ_unit_interval (h i).1 (h i).2
    exact pow_nonneg hq.1 _
  · calc
      cayleyPowerTrace w N (p+1) ≤
          ∑ i : Fin (N + 1 + w.rankOffset), 4 * atom w N i := by
        unfold cayleyPowerTrace
        apply Finset.sum_le_sum
        intro i hi
        have hq := cayleyQ_unit_interval (h i).1 (h i).2
        exact (power_succ_le_self_of_unit hq.1 hq.2 p).trans
          (cayleyQ_le_four_mul (h i).1 (h i).2)
      _ = 4 * mass w N := by
        simp only [mass, Finset.mul_sum]

/-- Globally certified rational spectra have a uniform 4 budget, even
when the number of eigenvalues increases without bound. -/
theorem telescopic_cayleyTrace_le_four
    (c : TelescopicCertificate) (hc : checkTelescopic c = true)
    (N p : ℕ) :
    0 ≤ cayleyPowerTrace (telescopicWitness c) N (p+1) ∧
      cayleyPowerTrace (telescopicWitness c) N (p+1) ≤ 4 := by
  have h := telescopicWitness_allLevelContractive c hc N
  have hb := cayleyTrace_uniform_mass (telescopicWitness c) N p h.1
  constructor
  · exact hb.1
  · calc
      cayleyPowerTrace (telescopicWitness c) N (p+1) ≤
        4 * mass (telescopicWitness c) N := hb.2
      _ ≤ 4 * 1 := mul_le_mul_of_nonneg_left h.2 (by norm_num)
      _ = 4 := mul_one _

end WitnessSolobolo
