import FiniteWitness.SharpAnchorMass

/-!
# Exact BKQR–SOLOBOLO debit ledger at every positive anchor

The finite payment is not merely bounded: it is exactly a sum of weighted
Cayley squares. The ledger telescopes with no missing carry terms.
-/

namespace WitnessSolobolo

/-- One-step debit at the transported anchor. -/
def allAnchorDebit (w : FiniteWitness) (N p : ℕ) (a b : ℚ) : ℚ :=
  allAnchorCayleyPowerTrace w N p a b -
    allAnchorCayleyPowerTrace w N (p+1) a b

/-- Exact finite sum-of-squares identity. -/
theorem allAnchorDebit_eq_squares
    (w : FiniteWitness) (N p : ℕ) (a b : ℚ) :
    allAnchorDebit w N p a b =
      ∑ i : Fin (N+1+w.rankOffset),
        (cayleyQ (anchorTransport a b (atom w N i)))^(p+1) *
          (cayleyC (anchorTransport a b (atom w N i)))^2 := by
  unfold allAnchorDebit allAnchorCayleyPowerTrace
  rw [← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro i hi
  exact scalar_cayley_debit (anchorTransport a b (atom w N i)) (p+1)

/-- Every debit is nonnegative for a contractive initial spectrum. -/
theorem allAnchorDebit_nonneg
    (w : FiniteWitness) (N p : ℕ) {a b : ℚ}
    (ha : 0 < a) (hb : 0 < b)
    (h : ∀ i : Fin (N+1+w.rankOffset),
      0 ≤ atom w N i ∧ atom w N i ≤ 1) :
    0 ≤ allAnchorDebit w N p a b := by
  rw [allAnchorDebit_eq_squares]
  apply Finset.sum_nonneg
  intro i hi
  have ht := anchorTransport_cayley_unit_interval
    ha hb (h i).1 (h i).2
  exact mul_nonneg (pow_nonneg ht.1 _) (sq_nonneg _)

/-- All-anchor trace contractivity, every integer depth. -/
theorem allAnchorTrace_antitone
    (w : FiniteWitness) (N p : ℕ) {a b : ℚ}
    (ha : 0 < a) (hb : 0 < b)
    (h : ∀ i : Fin (N+1+w.rankOffset),
      0 ≤ atom w N i ∧ atom w N i ≤ 1) :
    allAnchorCayleyPowerTrace w N (p+1) a b ≤
      allAnchorCayleyPowerTrace w N p a b := by
  have hd := allAnchorDebit_nonneg w N p ha hb h
  unfold allAnchorDebit at hd
  linarith

/-- No loss in summation: BKQR ledger equals its endpoint drop. -/
theorem allAnchorDebit_telescope
    (w : FiniteWitness) (N m : ℕ) (a b : ℚ) :
    (∑ p ∈ Finset.range m, allAnchorDebit w N p a b) =
      allAnchorCayleyPowerTrace w N 0 a b -
      allAnchorCayleyPowerTrace w N m a b := by
  exact rational_debit_telescope
    (fun p => allAnchorCayleyPowerTrace w N p a b) m

/-- One finite mass controls the complete accumulated debit at any depth. -/
theorem allAnchorDebit_total_budget
    (w : FiniteWitness) (N m : ℕ) {a b : ℚ}
    (ha : 0 < a) (hb : 0 < b)
    (h : ∀ i : Fin (N+1+w.rankOffset),
      0 ≤ atom w N i ∧ atom w N i ≤ 1) :
    0 ≤ (∑ p ∈ Finset.range m, allAnchorDebit w N p a b) ∧
    (∑ p ∈ Finset.range m, allAnchorDebit w N p a b) ≤
      4*max 1 (b/a)*mass w N := by
  have h0 := allAnchorCayleyPowerTrace_sharp_bound w N 0 ha hb h
  have hm := allAnchorCayleyPowerTrace_sharp_bound w N m ha hb h
  constructor
  · apply Finset.sum_nonneg
    intro p hp
    exact allAnchorDebit_nonneg w N p ha hb h
  · calc
      (∑ p ∈ Finset.range m, allAnchorDebit w N p a b) =
        allAnchorCayleyPowerTrace w N 0 a b -
          allAnchorCayleyPowerTrace w N m a b :=
          allAnchorDebit_telescope w N m a b
      _ ≤ allAnchorCayleyPowerTrace w N 0 a b := by
        linarith [hm.1]
      _ ≤ 4*max 1 (b/a)*mass w N := h0.2

end WitnessSolobolo
