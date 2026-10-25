import Derivations.CancellationLedger

namespace NativeSolobolo.SignedBernstein

open scoped BigOperators

/-- The actual quadratic row energy. No growth hypothesis enters its definition. -/
noncomputable def rowEnergy (s : ℕ → ℝ) (N : ℕ) : ℝ :=
  ((N : ℝ) + 1) * ∑ j ∈ Finset.range (N + 1), coeff s N j ^ 2

/-- The numerator of the weighted adjacent-coefficient square sum. -/
noncomputable def weightedDifferenceSum (s : ℕ → ℝ) (N : ℕ) : ℝ :=
  ∑ j ∈ Finset.range (N + 1),
    ((N + 1 - j : ℕ) : ℝ) * ((j + 1 : ℕ) : ℝ) *
      (coeff s (N + 1) j - coeff s (N + 1) (j + 1)) ^ 2

/-- Nonnegative energy added by refinement; not a dissipation upper bound. -/
noncomputable def rowEnergyIncrement (s : ℕ → ℝ) (N : ℕ) : ℝ :=
  weightedDifferenceSum s N / ((N : ℝ) + 1)

@[simp] theorem ROW_ENERGY_ZERO (s : ℕ → ℝ) : rowEnergy s 0 = s 0 ^ 2 := by
  simp [rowEnergy]

theorem ROW_ENERGY_NONNEG (s : ℕ → ℝ) (N : ℕ) : 0 ≤ rowEnergy s N := by
  unfold rowEnergy
  exact mul_nonneg (by positivity) (Finset.sum_nonneg (fun j hj => sq_nonneg _))

theorem WEIGHTED_DIFFERENCE_SUM_NONNEG (s : ℕ → ℝ) (N : ℕ) :
    0 ≤ weightedDifferenceSum s N := by
  unfold weightedDifferenceSum
  apply Finset.sum_nonneg
  intro j hj
  positivity

theorem ROW_ENERGY_INCREMENT_NONNEG (s : ℕ → ℝ) (N : ℕ) :
    0 ≤ rowEnergyIncrement s N := by
  exact div_nonneg (WEIGHTED_DIFFERENCE_SUM_NONNEG s N) (by positivity)

/-- An all-depth literal sum of real squares for the energy itself. -/
theorem ROW_ENERGY_SUM_OF_SQUARES (s : ℕ → ℝ) (N : ℕ) :
    rowEnergy s N = ∑ j ∈ Finset.range (N + 1),
      (Real.sqrt ((N : ℝ) + 1) * coeff s N j) ^ 2 := by
  unfold rowEnergy
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j hj
  rw [mul_pow, Real.sq_sqrt (show 0 ≤ (N : ℝ) + 1 by positivity)]

/-- The two-point weighted variance identity in the original elevation weights. -/
theorem ELEVATION_QUADRATIC_IDENTITY (N j : ℕ) (hj : j ≤ N) (u v : ℝ) :
    ((N : ℝ) + 1) * (leftWeight N j * u + rightWeight N j * v) ^ 2 +
      (((N + 1 - j : ℕ) : ℝ) * ((j + 1 : ℕ) : ℝ) * (u - v) ^ 2) /
        ((N : ℝ) + 1) =
    ((N : ℝ) + 2) * (leftWeight N j * u ^ 2 + rightWeight N j * v ^ 2) := by
  have hj' : j ≤ N + 1 := by omega
  have hd : (N : ℝ) + 1 ≠ 0 := by positivity
  unfold leftWeight rightWeight
  rw [Nat.cast_sub hj']
  push_cast
  field_simp [hd] <;> ring

/-- !!! Exact all-depth quadratic refinement, with no positivity premise on the jet. -/
theorem ROW_ENERGY_REFINEMENT (s : ℕ → ℝ) (N : ℕ) :
    rowEnergy s (N + 1) = rowEnergy s N + rowEnergyIncrement s N := by
  have hmerge := weighted_merge_sum N (fun j => coeff s (N + 1) j ^ 2)
  have hlocal : ∀ j ∈ Finset.range (N + 1),
      ((N : ℝ) + 2) *
        (leftWeight N j * coeff s (N + 1) j ^ 2 +
         rightWeight N j * coeff s (N + 1) (j + 1) ^ 2) =
      ((N : ℝ) + 1) * coeff s N j ^ 2 +
        (((N + 1 - j : ℕ) : ℝ) * ((j + 1 : ℕ) : ℝ) *
          (coeff s (N + 1) j - coeff s (N + 1) (j + 1)) ^ 2) /
          ((N : ℝ) + 1) := by
    intro j hj
    have hjle : j ≤ N := by have := Finset.mem_range.mp hj; omega
    have he := ELEVATION_QUADRATIC_IDENTITY N j hjle
      (coeff s (N + 1) j) (coeff s (N + 1) (j + 1))
    have hc := COEFFICIENT_REFINEMENT s N j hjle
    change coeff s N j =
      leftWeight N j * coeff s (N + 1) j +
      rightWeight N j * coeff s (N + 1) (j + 1) at hc
    rw [← hc] at he
    exact he.symm
  calc
    rowEnergy s (N + 1) = ((N : ℝ) + 2) *
        ∑ j ∈ Finset.range (N + 2), coeff s (N + 1) j ^ 2 := by
      simp only [rowEnergy, Nat.cast_add, Nat.cast_one] <;> ring
    _ = ((N : ℝ) + 2) * ∑ j ∈ Finset.range (N + 1),
        (leftWeight N j * coeff s (N + 1) j ^ 2 +
         rightWeight N j * coeff s (N + 1) (j + 1) ^ 2) := by rw [hmerge]
    _ = ∑ j ∈ Finset.range (N + 1),
        ((N : ℝ) + 2) *
          (leftWeight N j * coeff s (N + 1) j ^ 2 +
           rightWeight N j * coeff s (N + 1) (j + 1) ^ 2) := by
      rw [Finset.mul_sum]
    _ = ∑ j ∈ Finset.range (N + 1),
        (((N : ℝ) + 1) * coeff s N j ^ 2 +
        (((N + 1 - j : ℕ) : ℝ) * ((j + 1 : ℕ) : ℝ) *
          (coeff s (N + 1) j - coeff s (N + 1) (j + 1)) ^ 2) /
          ((N : ℝ) + 1)) := Finset.sum_congr rfl hlocal
    _ = rowEnergy s N + rowEnergyIncrement s N := by
      simp only [rowEnergy, rowEnergyIncrement, weightedDifferenceSum,
        Finset.sum_add_distrib, Finset.mul_sum, Finset.sum_div]

/-- !!! Exact telescoping energy ledger. -/
theorem ROW_ENERGY_LEDGER (s : ℕ → ℝ) (N : ℕ) :
    rowEnergy s N = s 0 ^ 2 + ∑ r ∈ Finset.range N, rowEnergyIncrement s r := by
  induction N with
  | zero => simp
  | succ N ih =>
    rw [ROW_ENERGY_REFINEMENT, ih, Finset.sum_range_succ]
    ring

theorem ROW_ENERGY_MONOTONE (s : ℕ → ℝ) : Monotone (rowEnergy s) := by
  apply monotone_nat_of_le_succ
  intro N
  rw [ROW_ENERGY_REFINEMENT]
  linarith [ROW_ENERGY_INCREMENT_NONNEG s N]

/-- Squared l1 mass is bounded by the normalized l2 energy. -/
theorem ROW_MASS_SQ_LE_ENERGY (s : ℕ → ℝ) (N : ℕ) :
    rowMass s N ^ 2 ≤ rowEnergy s N := by
  have h := Finset.sum_mul_sq_le_sq_mul_sq (Finset.range (N + 1))
    (fun _ : ℕ => (1 : ℝ)) (fun j => |coeff s N j|)
  simpa [rowMass, rowEnergy, sq_abs] using h

/-- Conversely the quadratic energy loses only the row length. -/
theorem ROW_ENERGY_LE_LENGTH_MASS_SQ (s : ℕ → ℝ) (N : ℕ) :
    rowEnergy s N ≤ ((N : ℝ) + 1) * rowMass s N ^ 2 := by
  have h := Finset.sum_sq_le_sq_sum_of_nonneg
    (s := Finset.range (N + 1)) (f := fun j => |coeff s N j|)
    (fun j hj => abs_nonneg (coeff s N j))
  have hs : (∑ j ∈ Finset.range (N + 1), coeff s N j ^ 2) ≤ rowMass s N ^ 2 := by
    simpa only [sq_abs, rowMass] using h
  exact mul_le_mul_of_nonneg_left hs (by positivity)

theorem ROW_MASS_LE_ONE_ADD_ENERGY (s : ℕ → ℝ) (N : ℕ) :
    rowMass s N ≤ 1 + rowEnergy s N := by
  have h := ROW_MASS_SQ_LE_ENERGY s N
  nlinarith [sq_nonneg (rowMass s N - 1 / 2)]

/-- This stronger uniform-energy obligation is not the uniform-row-mass obligation. -/
def UniformEnergyBound (s : ℕ → ℝ) : Prop :=
  ∃ B : ℝ, ∀ N : ℕ, rowEnergy s N ≤ B

theorem ENERGY_BOUND_IFF_INCREMENT_SUMMABLE (s : ℕ → ℝ) :
    UniformEnergyBound s ↔ Summable (rowEnergyIncrement s) := by
  constructor
  · rintro ⟨B, hB⟩
    apply summable_of_sum_range_le (ROW_ENERGY_INCREMENT_NONNEG s) (c := B - s 0 ^ 2)
    intro N
    have h := hB N
    rw [ROW_ENERGY_LEDGER] at h
    linarith
  · intro h
    refine ⟨s 0 ^ 2 + ∑' r, rowEnergyIncrement s r, ?_⟩
    intro N
    rw [ROW_ENERGY_LEDGER]
    exact add_le_add (le_refl (s 0 ^ 2))
      (Summable.sum_le_tsum (Finset.range N)
        (fun r hr => ROW_ENERGY_INCREMENT_NONNEG s r) h)

end NativeSolobolo.SignedBernstein
