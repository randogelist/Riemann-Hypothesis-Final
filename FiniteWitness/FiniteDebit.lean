import FiniteWitness.FiniteLayers

/-!
# SOLOBOLO finite debit, all integer depths

This layer consists of exact identities for the SAME finite rational spectrum.
The finite deficit is a sum of squares with positive weights. No actual-xi
coefficient identification is claimed or needed for this algebra.
-/

namespace WitnessSolobolo

/-- The trace of arbitrary natural powers of the same finite Cayley spectrum. -/
def cayleyPowerTrace (w : FiniteWitness) (N p : ℕ) : ℚ :=
  ∑ i : Fin (N + 1 + w.rankOffset),
    (cayleyQ (atom w N i)) ^ p

/-- Each scalar debit factors as a Cayley square. -/
theorem scalar_cayley_debit (t : ℚ) (p : ℕ) :
    (cayleyQ t) ^ p - (cayleyQ t) ^ (p + 1) =
      (cayleyQ t) ^ p * (cayleyC t) ^ 2 := by
  rw [pow_succ]
  have h := cayley_complement_identity t
  calc
    (cayleyQ t) ^ p - (cayleyQ t) ^ p * (cayleyQ t) =
        (cayleyQ t) ^ p * (1 - cayleyQ t) := by ring
    _ = (cayleyQ t) ^ p * (cayleyC t) ^ 2 := by
      congr 1
      linarith

/-- The finite trace debit is an exact sum of weighted Cayley squares. -/
theorem cayleyPowerTrace_debit (w : FiniteWitness) (N p : ℕ) :
    cayleyPowerTrace w N p - cayleyPowerTrace w N (p + 1) =
      ∑ i : Fin (N + 1 + w.rankOffset),
        (cayleyQ (atom w N i)) ^ p * (cayleyC (atom w N i)) ^ 2 := by
  simp only [cayleyPowerTrace, ← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro i hi
  exact scalar_cayley_debit (atom w N i) p

/-- The debit is nonnegative whenever the finite atoms are contractions. -/
theorem cayleyPowerTrace_antitone (w : FiniteWitness) (N p : ℕ)
    (h : ∀ i : Fin (N + 1 + w.rankOffset),
      0 ≤ atom w N i ∧ atom w N i ≤ 1) :
    cayleyPowerTrace w N (p + 1) ≤ cayleyPowerTrace w N p := by
  have hs : 0 ≤ ∑ i : Fin (N + 1 + w.rankOffset),
        (cayleyQ (atom w N i)) ^ p * (cayleyC (atom w N i)) ^ 2 := by
    apply Finset.sum_nonneg
    intro i hi
    have hq := cayleyQ_unit_interval (h i).1 (h i).2
    exact mul_nonneg (pow_nonneg hq.1 _) (sq_nonneg _)
  rw [← cayleyPowerTrace_debit] at hs
  exact sub_nonneg.mp hs

/-- An elementary finite telescoping law valid for arbitrary rational sequences. -/
theorem rational_debit_telescope (f : ℕ → ℚ) (n : ℕ) :
    (∑ p ∈ Finset.range n, (f p - f (p + 1))) = f 0 - f n := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [Finset.sum_range_succ, ih]
      ring

/-- Summing every successive Cayley debit produces the endpoint difference. -/
theorem cayleyPowerTrace_telescope (w : FiniteWitness) (N n : ℕ) :
    (∑ p ∈ Finset.range n,
       (cayleyPowerTrace w N p - cayleyPowerTrace w N (p + 1))) =
      cayleyPowerTrace w N 0 - cayleyPowerTrace w N n := by
  exact rational_debit_telescope (cayleyPowerTrace w N) n

/-- The old Mersenne trace is just a subsequence of the whole-power trace. -/
theorem cayleyTrace_eq_power (w : FiniteWitness) (N k : ℕ) :
    cayleyTrace w N k = cayleyPowerTrace w N (2 ^ k) := rfl

end WitnessSolobolo
