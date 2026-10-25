import FiniteWitness.GramFactor

/-!
# Universal successor propagation

These are fully quantified downstream induction theorems. A finite certificate
which can prove the particular `step` for actual xi would trigger this chain;
the algebraic checker has NOT supplied that analytic step.
-/

namespace WitnessSolobolo

/-- Arbitrary-depth propagation from a base and one universal successor. -/
theorem universal_successor_propagation {P : ℕ → Prop}
    (hbase : P 0) (hstep : ∀ n, P n → P (n + 1)) :
    ∀ n, P n := by
  intro n
  induction n with
  | zero => exact hbase
  | succ n ih => exact hstep n ih

/-- Exact uniform half-contraction, with no positivity of `error` assumed. -/
theorem halving_successor_bound
    (error : ℕ → ℝ) (C : ℝ)
    (hbase : error 0 ≤ C)
    (hstep : ∀ n, error (n + 1) ≤ (1 / 2 : ℝ) * error n) :
    ∀ n, error n ≤ C * (1 / 2 : ℝ) ^ n := by
  intro n
  induction n with
  | zero => simpa using hbase
  | succ n ih =>
      calc
        error (n + 1) ≤ (1 / 2 : ℝ) * error n := hstep n
        _ ≤ (1 / 2 : ℝ) * (C * (1 / 2 : ℝ) ^ n) :=
          mul_le_mul_of_nonneg_left ih (by norm_num)
        _ = C * (1 / 2 : ℝ) ^ (n + 1) := by
          rw [pow_succ]
          ring

/-- The exact debit identity also holds after checking global contractions. -/
theorem checked_telescopic_all_depth_debit
    (c : TelescopicCertificate) (hc : checkTelescopic c = true)
    (N p : ℕ) :
    0 ≤ cayleyPowerTrace (telescopicWitness c) N p -
      cayleyPowerTrace (telescopicWitness c) N (p + 1) := by
  have h := (telescopicWitness_allLevelContractive c hc N).1
  exact sub_nonneg.mpr (cayleyPowerTrace_antitone (telescopicWitness c) N p h)

end WitnessSolobolo
