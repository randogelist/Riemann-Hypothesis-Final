import Solobolo.ScalarProfile

/-!
# Finite spectral model of the SOLOBOLO n -> n+1 transition

This is the *algebraic* finite-rank analogue of a positive contraction.
It is not asserted to reproduce the actual zeta data. An actual source
calibration theorem would be required for that assertion.
-/

namespace Solobolo.HypotheticalRH

variable {ι : Type*} [Fintype ι]

/-- Moments of a finite positive diagonal contraction with nonnegative weights. -/
def atomicMoment (q w : ι → ℝ) (n : ℕ) : ℝ :=
  ∑ i : ι, w i * (q i) ^ n

/-- All Hausdorff cells are produced by *one* contraction. -/
def atomicCell (q w : ι → ℝ) (n k : ℕ) : ℝ :=
  ∑ i : ι, w i * (q i) ^ n * (1 - q i) ^ k

theorem atomicCell_nonneg (q w : ι → ℝ)
    (hq0 : ∀ i, 0 ≤ q i) (hq1 : ∀ i, q i ≤ 1)
    (hw : ∀ i, 0 ≤ w i) (n k : ℕ) :
    0 ≤ atomicCell q w n k := by
  unfold atomicCell
  apply Finset.sum_nonneg
  intro i hi
  apply mul_nonneg
  · exact mul_nonneg (hw i) (pow_nonneg (hq0 i) n)
  · exact pow_nonneg (sub_nonneg.mpr (hq1 i)) k

theorem atomicCell_initial (q w : ι → ℝ) (n : ℕ) :
    atomicCell q w n 0 = atomicMoment q w n := by
  simp [atomicCell, atomicMoment]

/-- SOLOBOLO Pascal conservation is an identity, independent of RH. -/
theorem atomicCell_successor (q w : ι → ℝ) (n k : ℕ) :
    atomicCell q w n k =
      atomicCell q w (n + 1) k + atomicCell q w n (k + 1) := by
  unfold atomicCell
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro i hi
  simp only [pow_succ]
  ring

/-- The model yields every positivity cell automatically, with no induction
hypothesis for a new order. -/
theorem atomicCell_all_orders (q w : ι → ℝ)
    (hq0 : ∀ i, 0 ≤ q i) (hq1 : ∀ i, q i ≤ 1)
    (hw : ∀ i, 0 ≤ w i) :
    ∀ n k, 0 ≤ atomicCell q w n k := by
  intro n k
  exact atomicCell_nonneg q w hq0 hq1 hw n k

#print axioms atomicCell_successor
#print axioms atomicCell_all_orders

end Solobolo.HypotheticalRH
