import Solobolo.CayleyContraction

/-!
# SOLOBOLO moment-difference induction, every (n,k)

Exact calibration of one infinite moment sequence is the mathematical
admission that cannot be replaced by checking a finite initial segment.
The finite spectral model is an algebraic illustration; no xi calibration
is manufactured or assumed in this module.
-/

namespace Solobolo.HypotheticalRH

/-- Repeated right-forward finite differences with alternating sign. -/
def momentCell (d : ℕ → ℝ) : ℕ → ℕ → ℝ
  | n, 0 => d n
  | n, k + 1 => momentCell d n k - momentCell d (n + 1) k

/-- The finite-difference cells of a calibrated atomic moment sequence
    coincide exactly with the SOLOBOLO contraction cells. -/
theorem momentCell_atomicMoment {ι : Type*} [Fintype ι]
    (q w : ι → ℝ) (n k : ℕ) :
    momentCell (atomicMoment q w) n k = atomicCell q w n k := by
  induction k generalizing n with
  | zero =>
      simpa [momentCell] using (atomicCell_initial q w n).symm
  | succ k ih =>
      change momentCell (atomicMoment q w) n k -
        momentCell (atomicMoment q w) (n + 1) k =
        atomicCell q w n (k + 1)
      rw [ih n, ih (n + 1)]
      linarith [atomicCell_successor q w n k]

/-- All Hausdorff cells are nonnegative from a SINGLE global moment
    calibration and one finite positive contraction, with no induction
    assumptions at new orders. -/
theorem calibratedMoment_all_cells_nonneg {ι : Type*} [Fintype ι]
    (d : ℕ → ℝ) (q w : ι → ℝ)
    (hcal : ∀ n, d n = atomicMoment q w n)
    (hq0 : ∀ i, 0 ≤ q i) (hq1 : ∀ i, q i ≤ 1)
    (hw : ∀ i, 0 ≤ w i) (n k : ℕ) :
    0 ≤ momentCell d n k := by
  have hd : d = atomicMoment q w := funext hcal
  rw [hd, momentCell_atomicMoment q w n k]
  exact atomicCell_nonneg q w hq0 hq1 hw n k

/-- Fully automatic all-depth SOLOBOLO induction for a Cayley-generated
    calibrated finite model. -/
theorem cayleyCalibratedMoment_all_cells_nonneg {ι : Type*} [Fintype ι]
    (d : ℕ → ℝ) (λ w : ι → ℝ)
    (hcal : ∀ n, d n = atomicMoment (fun i => cayleyMultiplier (λ i)) w n)
    (hλ : ∀ i, 0 ≤ λ i) (hw : ∀ i, 0 ≤ w i) (n k : ℕ) :
    0 ≤ momentCell d n k := by
  apply calibratedMoment_all_cells_nonneg d
    (fun i => cayleyMultiplier (λ i)) w hcal
  · intro i; exact cayleyMultiplier_nonneg (λ i) (hλ i)
  · intro i; exact cayleyMultiplier_le_one (λ i) (hλ i)
  · exact hw

#print axioms momentCell_atomicMoment
#print axioms calibratedMoment_all_cells_nonneg

end Solobolo.HypotheticalRH
