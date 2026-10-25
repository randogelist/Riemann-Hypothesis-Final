import FiniteWitness.FiniteSpectrum

/-!
# SOLOBOLO contractive trace induction

The important point is that the finite spectrum is SHARED across all powers:
no independent spectrum may be chosen at every depth.
-/

namespace WitnessSolobolo

private theorem pow_le_one_of_unit_interval
    {x : ℚ} (hx0 : 0 ≤ x) (hx1 : x ≤ 1) (n : ℕ) : x ^ n ≤ 1 := by
  induction n with
  | zero => simp
  | succ n ih =>
      calc
        x ^ (n + 1) = x ^ n * x := pow_succ x n
        _ ≤ x ^ n * 1 := mul_le_mul_of_nonneg_left hx1 (pow_nonneg hx0 _)
        _ = x ^ n := mul_one _
        _ ≤ 1 := ih

/-- Scalar contractivity at Mersenne powers. -/
theorem scalar_mersenne_step
    {x : ℚ} (hx0 : 0 ≤ x) (hx1 : x ≤ 1) (k : ℕ) :
    x ^ (2 ^ (k + 1)) ≤ x ^ (2 ^ k) := by
  have h₁ := pow_le_one_of_unit_interval hx0 hx1 (2 ^ k)
  have h₀ : 0 ≤ x ^ (2 ^ k) := pow_nonneg hx0 _
  calc
    x ^ (2 ^ (k + 1)) = (x ^ (2 ^ k)) ^ 2 := by
      rw [pow_succ, pow_mul]
    _ = x ^ (2 ^ k) * x ^ (2 ^ k) := pow_two _
    _ ≤ x ^ (2 ^ k) * 1 := mul_le_mul_of_nonneg_left h₁ h₀
    _ = x ^ (2 ^ k) := mul_one _

/-- Automatic SOLOBOLO contraction for each finite generated spectrum. -/
theorem trace_mersenne_step (w : FiniteWitness) (N k : ℕ)
    (h : ∀ i : Fin (N + 1 + w.rankOffset),
      0 ≤ atom w N i ∧ atom w N i ≤ 1) :
    tracePower w N (2 ^ (k + 1)) ≤ tracePower w N (2 ^ k) := by
  unfold tracePower
  apply Finset.sum_le_sum
  intro i hi
  exact scalar_mersenne_step (h i).1 (h i).2 k

/-- The accepted seed supplies the whole trace induction at each VERIFIED level. -/
theorem checked_seed_trace_induction (w : FiniteWitness)
    (hw : checkSeed w = true)
    (N : Fin (w.baseDepth + 1)) (k : ℕ) :
    tracePower w N.val (2 ^ (k + 1)) ≤
      tracePower w N.val (2 ^ k) := by
  exact trace_mersenne_step w N.val k ((checkSeed_sound w hw N).1)

/-- Exact finite Cayley contraction `q = 4t(1-t)`. -/
def cayleyQ (t : ℚ) : ℚ := 4 * t * (1 - t)

/-- The finite Cayley channel is contractive, by a literal square identity. -/
theorem cayleyQ_unit_interval {t : ℚ}
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    0 ≤ cayleyQ t ∧ cayleyQ t ≤ 1 := by
  constructor
  · unfold cayleyQ
    exact mul_nonneg (mul_nonneg (by norm_num) ht0) (sub_nonneg.mpr ht1)
  · have hs : 0 ≤ (2 * t - 1) ^ 2 := sq_nonneg _
    unfold cayleyQ
    nlinarith

/-- Cayley complement `c = 1-2t`. -/
def cayleyC (t : ℚ) : ℚ := 1 - 2 * t

/-- The QQRH/SOLOBOLO algebraic identity `q + c² = 1`. -/
theorem cayley_complement_identity (t : ℚ) :
    cayleyQ t + (cayleyC t) ^ 2 = 1 := by
  unfold cayleyQ cayleyC
  ring

/-- Exact finite SOLOBOLO trace on the shared positive spectrum. -/
def cayleyTrace (w : FiniteWitness) (N k : ℕ) : ℚ :=
  ∑ i : Fin (N + 1 + w.rankOffset),
    (cayleyQ (atom w N i)) ^ (2 ^ k)

/-- Automatic SOLOBOLO trace induction: no RH, no analytic assumptions. -/
theorem cayleyTrace_step (w : FiniteWitness) (N k : ℕ)
    (h : ∀ i : Fin (N + 1 + w.rankOffset),
      0 ≤ atom w N i ∧ atom w N i ≤ 1) :
    cayleyTrace w N (k + 1) ≤ cayleyTrace w N k := by
  unfold cayleyTrace
  apply Finset.sum_le_sum
  intro i hi
  have hi' := cayleyQ_unit_interval (h i).1 (h i).2
  exact scalar_mersenne_step hi'.1 hi'.2 k

/-- Checked finite seed automatically enjoys the Cayley trace induction. -/
theorem checked_seed_cayley_induction (w : FiniteWitness)
    (hw : checkSeed w = true)
    (N : Fin (w.baseDepth + 1)) (k : ℕ) :
    cayleyTrace w N.val (k + 1) ≤ cayleyTrace w N.val k := by
  exact cayleyTrace_step w N.val k ((checkSeed_sound w hw N).1)

end WitnessSolobolo
