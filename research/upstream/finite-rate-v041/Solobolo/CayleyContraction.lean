import Solobolo.FiniteContractionModel

/-!
# Cayley-to-contraction algebra, finite model

For each nonnegative real scale λ, q(λ)=4λ/(1+λ)^2 lies in [0,1].
A finite diagonal model then supplies all SOLOBOLO Hausdorff cells.
This module DOES NOT identify these finite models with the actual xi zeros.
-/

namespace Solobolo.HypotheticalRH

/-- The SOLOBOLO Cayley multiplier. -/
def cayleyMultiplier (λ : ℝ) : ℝ :=
  (4 * λ) / (1 + λ) ^ 2

/-- The corresponding Cayley involution coefficient. -/
def cayleyFactor (λ : ℝ) : ℝ :=
  (1 - λ) / (1 + λ)

theorem cayleyMultiplier_nonneg (λ : ℝ) (hλ : 0 ≤ λ) :
    0 ≤ cayleyMultiplier λ := by
  unfold cayleyMultiplier
  exact div_nonneg (mul_nonneg (by norm_num) hλ) (sq_nonneg _)

theorem cayleyMultiplier_le_one (λ : ℝ) (hλ : 0 ≤ λ) :
    cayleyMultiplier λ ≤ 1 := by
  have hden : 0 < (1 + λ) ^ 2 := sq_pos_of_pos (by linarith)
  unfold cayleyMultiplier
  apply (div_le_iff₀ hden).2
  nlinarith [sq_nonneg (1 - λ)]

/-- Exact algebraic identity T=I-C^2, without spectral assumptions. -/
theorem one_sub_cayleyFactor_sq (λ : ℝ) (hλ : 0 ≤ λ) :
    1 - cayleyFactor λ ^ 2 = cayleyMultiplier λ := by
  have hn : 1 + λ ≠ 0 := ne_of_gt (by linarith)
  unfold cayleyFactor cayleyMultiplier
  field_simp [hn]
  <;> ring

variable {ι : Type*} [Fintype ι]

/-- Positivity of every Hausdorff cell from one finite Cayley model. -/
theorem cayleyAtomicCell_nonneg (λ w : ι → ℝ)
    (hλ : ∀ i, 0 ≤ λ i) (hw : ∀ i, 0 ≤ w i) (n k : ℕ) :
    0 ≤ atomicCell (fun i => cayleyMultiplier (λ i)) w n k := by
  apply atomicCell_nonneg
  · intro i; exact cayleyMultiplier_nonneg (λ i) (hλ i)
  · intro i; exact cayleyMultiplier_le_one (λ i) (hλ i)
  · exact hw

#print axioms one_sub_cayleyFactor_sq
#print axioms cayleyAtomicCell_nonneg

end Solobolo.HypotheticalRH
