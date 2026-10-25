import FiniteWitness.AllAnchorDebit

/-!
# A truly accepted finite certificate supplies a UNIVERSAL BKQR ledger

This is not yet an actual-ξ witness. Its accepted certificate certifies only
algebraic rational spectra and their all-anchor finite debit budgets.
-/

namespace WitnessSolobolo

/-- The certified toy generator admits the SHARP debit budget, at every
positive rational anchor, every layer, and every depth. -/
theorem checked_telescopic_sharp_debit_budget
    (c : TelescopicCertificate) (hc : checkTelescopic c = true)
    {a b : ℚ} (ha : 0 < a) (hb : 0 < b)
    (N m : ℕ) :
    0 ≤ (∑ p ∈ Finset.range m,
      allAnchorDebit (telescopicWitness c) N p a b) ∧
    (∑ p ∈ Finset.range m,
      allAnchorDebit (telescopicWitness c) N p a b) ≤
      4*max 1 (b/a) := by
  have h := telescopicWitness_allLevelContractive c hc N
  have hbnd := allAnchorDebit_total_budget
    (telescopicWitness c) N m ha hb h.1
  constructor
  · exact hbnd.1
  · calc
      (∑ p ∈ Finset.range m,
        allAnchorDebit (telescopicWitness c) N p a b) ≤
        4*max 1 (b/a)*mass (telescopicWitness c) N := hbnd.2
      _ ≤ 4*max 1 (b/a)*1 := by
        have hfactor : 0 ≤ (4 : ℚ)*max 1 (b/a) := by
          have hmax : 0 ≤ max (1 : ℚ) (b/a) :=
            le_trans (by norm_num) (le_max_left _ _)
          positivity
        exact mul_le_mul_of_nonneg_left h.2 hfactor
      _ = 4*max 1 (b/a) := mul_one _

/-- A separate finite positive matrix is not chosen at each depth;
this conclusion is for one shared generated finite spectrum. -/
theorem checked_telescopic_allAnchor_antitone
    (c : TelescopicCertificate) (hc : checkTelescopic c = true)
    {a b : ℚ} (ha : 0 < a) (hb : 0 < b)
    (N p : ℕ) :
    allAnchorCayleyPowerTrace (telescopicWitness c) N (p+1) a b ≤
      allAnchorCayleyPowerTrace (telescopicWitness c) N p a b := by
  exact allAnchorTrace_antitone
    (telescopicWitness c) N p ha hb
    (telescopicWitness_allLevelContractive c hc N).1

end WitnessSolobolo
