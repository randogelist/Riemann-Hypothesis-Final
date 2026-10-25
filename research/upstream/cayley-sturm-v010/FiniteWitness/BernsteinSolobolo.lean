import FiniteWitness.FiniteDebit

/-!
# Exact Bernstein central-row / SOLOBOLO trace identity

For ONE finite rational spectrum the Bernstein row at 2*n+1 is exactly
proportional to the (n+1)-st power trace of its Cayley transform.
No RH, analytic continuation, model calibration, or positivity hypothesis
is required for this algebraic equality.
-/

namespace WitnessSolobolo

/-- Finite Bernstein row of the SAME finite spectrum. -/
def spectralBernsteinRow
    (w : FiniteWitness) (N L j : ℕ) : ℚ :=
  (Nat.choose L j : ℚ) *
    ∑ i : Fin (N + 1 + w.rankOffset),
      (atom w N i) ^ (j + 1) * (1 - atom w N i) ^ (L - j)

/-- The central row is the actual Cayley power trace, up to the
explicit integer binomial normalization. -/
theorem bernsteinCentral_eq_cayleyTrace
    (w : FiniteWitness) (N n : ℕ) :
    (Nat.choose (2*n+1) n : ℚ) * cayleyPowerTrace w N (n+1) =
      4 ^ (n+1) * spectralBernsteinRow w N (2*n+1) n := by
  have hpower (t : ℚ) :
      (cayleyQ t) ^ (n+1) =
        (4 : ℚ) ^ (n+1) * (t ^ (n+1) * (1-t) ^ (n+1)) := by
    unfold cayleyQ
    rw [mul_pow, mul_pow]
    ring
  have hsum : cayleyPowerTrace w N (n+1) =
      (4 : ℚ) ^ (n+1) *
        (∑ i : Fin (N + 1 + w.rankOffset),
          (atom w N i) ^ (n+1) * (1 - atom w N i) ^ (n+1)) := by
    unfold cayleyPowerTrace
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i hi
    exact hpower (atom w N i)
  rw [hsum]
  unfold spectralBernsteinRow
  have hn : 2*n+1-n = n+1 := by omega
  rw [hn]
  ring

/-- A checked finite seed has nonnegative Bernstein rows on every
actually checked layer. -/
theorem checked_bernsteinRow_nonneg
    (w : FiniteWitness) (hw : checkSeed w = true)
    (N : Fin (w.baseDepth + 1)) (L j : ℕ) :
    0 ≤ spectralBernsteinRow w N.val L j := by
  unfold spectralBernsteinRow
  apply mul_nonneg
  · exact_mod_cast Nat.zero_le (Nat.choose L j)
  · apply Finset.sum_nonneg
    intro i hi
    have h := (checkSeed_sound w hw N).1 i
    exact mul_nonneg (pow_nonneg h.1 _) (pow_nonneg (sub_nonneg.mpr h.2) _)

end WitnessSolobolo
