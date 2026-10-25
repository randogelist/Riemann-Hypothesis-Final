import AllDepth.SubexpEnvelope

/-!
# All-depth finite BKQR / Hausdorff identity

For *any* finite set of contractive nonnegative channels 0 ≤ q ≤ 1,
  μ_n = ∑ w_i q_i^(n+1)
are nonnegative and have nonnegative alternating forward differences at
**all** n,k.  This is an unconditional scalar BKQR statement; it is not yet
calibrated to actual ξ-Widder coefficients.
-/
namespace KQGPBKQRHilbert.AllDepth

open scoped BigOperators

variable {ι : Type*} [Fintype ι]

/-- Finite nonnegative Cayley-channel moments, no dyadic exponent. -/
noncomputable def finiteCayleyMoment (w q : ι → ℝ) (n : ℕ) : ℝ :=
  ∑ i : ι, w i * q i ^ (n + 1)

theorem finiteCayleyMoment_nonneg
    (w q : ι → ℝ)
    (hw : ∀ i, 0 ≤ w i)
    (hq : ∀ i, 0 ≤ q i)
    (n : ℕ) :
    0 ≤ finiteCayleyMoment w q n := by
  unfold finiteCayleyMoment
  apply Finset.sum_nonneg
  intro i hi
  exact mul_nonneg (hw i) (pow_nonneg (hq i) _)

/-- The alternating difference operator Δ⁻_k μ(n). -/
def alternatingDiff (f : ℕ → ℝ) : ℕ → ℕ → ℝ
  | 0, n => f n
  | k + 1, n => alternatingDiff f k n - alternatingDiff f k (n + 1)

/-- All depths, all Hausdorff difference orders: exact coefficient identity. -/
theorem finite_cayley_hausdorff_formula
    (w q : ι → ℝ) (k n : ℕ) :
    alternatingDiff (finiteCayleyMoment w q) k n =
      ∑ i : ι, w i * q i ^ (n + 1) * (1 - q i) ^ k := by
  induction k generalizing n with
  | zero =>
      simp [alternatingDiff, finiteCayleyMoment]
  | succ k hk =>
      change alternatingDiff (finiteCayleyMoment w q) k n -
          alternatingDiff (finiteCayleyMoment w q) k (n + 1) =
        ∑ i : ι, w i * q i ^ (n + 1) * (1 - q i) ^ (k + 1)
      rw [hk n, hk (n + 1), ← Finset.sum_sub_distrib]
      apply Finset.sum_congr rfl
      intro i hi
      simp only [pow_succ]
      ring

/-- Complete Hausdorff positivity for the *finite positive BKQR model*.
    No unproved actual-ξ moment identification occurs in this theorem. -/
theorem finite_cayley_hausdorff_nonneg
    (w q : ι → ℝ)
    (hw : ∀ i, 0 ≤ w i)
    (hq0 : ∀ i, 0 ≤ q i)
    (hq1 : ∀ i, q i ≤ 1)
    (k n : ℕ) :
    0 ≤ alternatingDiff (finiteCayleyMoment w q) k n := by
  rw [finite_cayley_hausdorff_formula]
  apply Finset.sum_nonneg
  intro i hi
  have h1 : 0 ≤ 1 - q i := sub_nonneg.mpr (hq1 i)
  exact mul_nonneg
    (mul_nonneg (hw i) (pow_nonneg (hq0 i) _))
    (pow_nonneg h1 _)


/-- The finite BKQR contraction moments have a common all-depth bound.
    This is independent of any actual xi calibration. -/
theorem finite_cayley_le_mass
    (w q : ι → ℝ)
    (hw : ∀ i, 0 ≤ w i)
    (hq0 : ∀ i, 0 ≤ q i)
    (hq1 : ∀ i, q i ≤ 1)
    (n : ℕ) :
    finiteCayleyMoment w q n ≤ ∑ i : ι, w i := by
  unfold finiteCayleyMoment
  apply Finset.sum_le_sum
  intro i hi
  have hpow : q i ^ (n + 1) ≤ 1 := pow_le_one₀ (hq0 i) (hq1 i)
  have hmul : w i * q i ^ (n + 1) ≤ w i * 1 :=
    mul_le_mul_of_nonneg_left hpow (hw i)
  simpa using hmul

/-- Every positive finite Cayley model satisfies the subexponential envelope
    for **all** depths n; there is no 2^k reduction. -/
theorem finite_cayley_subexponential
    (w q : ι → ℝ)
    (hw : ∀ i, 0 ≤ w i)
    (hq0 : ∀ i, 0 ≤ q i)
    (hq1 : ∀ i, q i ≤ 1) :
    ∀ b : ℝ, 1 < b →
      ∃ C : ℝ, 0 ≤ C ∧ ∀ n : ℕ,
        |finiteCayleyMoment w q n| ≤ C * b ^ n := by
  intro b hb
  have hmass : 0 ≤ (∑ i : ι, w i) := by
    apply Finset.sum_nonneg
    intro i hi
    exact hw i
  refine ⟨∑ i : ι, w i, hmass, ?_⟩
  intro n
  have hnonneg : 0 ≤ finiteCayleyMoment w q n :=
    finiteCayleyMoment_nonneg w q hw hq0 n
  have hbound : finiteCayleyMoment w q n ≤ ∑ i : ι, w i :=
    finite_cayley_le_mass w q hw hq0 hq1 n
  have hbpow : (1 : ℝ) ≤ b ^ n := one_le_pow₀ (le_of_lt hb)
  calc
    |finiteCayleyMoment w q n| = finiteCayleyMoment w q n :=
      abs_of_nonneg hnonneg
    _ ≤ ∑ i : ι, w i := hbound
    _ = (∑ i : ι, w i) * 1 := by ring
    _ ≤ (∑ i : ι, w i) * b ^ n :=
      mul_le_mul_of_nonneg_left hbpow hmass

end KQGPBKQRHilbert.AllDepth
