import Mathlib

namespace GPBKQRTierA

open scoped BigOperators

/-- Signed Hausdorff finite difference, recursively encoded without explicit signs. -/
def hdiff (c : ℕ → ℝ) : ℕ → ℕ → ℝ
  | n, 0 => c n
  | n, Nat.succ k => hdiff c n k - hdiff c (n + 1) k

@[simp] theorem hdiff_zero (c : ℕ → ℝ) (n : ℕ) :
    hdiff c n 0 = c n := rfl

@[simp] theorem hdiff_succ (c : ℕ → ℝ) (n k : ℕ) :
    hdiff c n (k + 1) = hdiff c n k - hdiff c (n + 1) k := by
  change hdiff c n (Nat.succ k) = _
  rfl

/-- Pure algebraic Pascal identity for finite differences. -/
theorem hdiff_split (c : ℕ → ℝ) (n k : ℕ) :
    hdiff c n k = hdiff c (n + 1) k + hdiff c n (k + 1) := by
  rw [hdiff_succ]
  ring

/-- Exact finite storage-payment ledger; no positivity premise is used. -/
theorem hdiff_storage_ledger (c : ℕ → ℝ) (n k m : ℕ) :
    hdiff c n k =
      hdiff c (n + m) k +
        Finset.sum (Finset.range m) (fun j => hdiff c (n + j) (k + 1)) := by
  induction m with
  | zero => simp
  | succ m ih =>
      calc
        hdiff c n k =
            hdiff c (n + m) k +
              Finset.sum (Finset.range m) (fun j => hdiff c (n + j) (k + 1)) := ih
        _ =
            (hdiff c ((n + m) + 1) k + hdiff c (n + m) (k + 1)) +
              Finset.sum (Finset.range m) (fun j => hdiff c (n + j) (k + 1)) := by
              rw [hdiff_split c (n + m) k]
        _ =
            hdiff c (n + (m + 1)) k +
              Finset.sum (Finset.range (m + 1)) (fun j => hdiff c (n + j) (k + 1)) := by
              rw [Finset.sum_range_succ]
              have hn : (n + m) + 1 = n + (m + 1) := by omega
              rw [hn]
              ring

/-- Unit interval as a type, so the contraction bounds are intrinsic data rather than hypotheses. -/
abbrev UnitInterval := Set.Icc (0 : ℝ) 1

/-- Pointwise Bernstein/Hausdorff cell. -/
def bernsteinCell (x : UnitInterval) (n k : ℕ) : ℝ :=
  (x : ℝ) ^ n * (1 - (x : ℝ)) ^ k

/-- Every pointwise Bernstein cell is nonnegative. -/
theorem bernsteinCell_nonneg (x : UnitInterval) (n k : ℕ) :
    0 ≤ bernsteinCell x n k := by
  have hx : 0 ≤ (x : ℝ) := x.property.1
  have h1 : 0 ≤ 1 - (x : ℝ) := sub_nonneg.mpr x.property.2
  exact mul_nonneg (pow_nonneg hx n) (pow_nonneg h1 k)

/-- Exact pointwise binary/Pascal split. -/
theorem bernsteinCell_split (x : UnitInterval) (n k : ℕ) :
    bernsteinCell x n k =
      bernsteinCell x (n + 1) k + bernsteinCell x n (k + 1) := by
  unfold bernsteinCell
  rw [pow_succ, pow_succ]
  ring

/-- A finite positive probability model with support intrinsically in [0,1]. -/
structure FiniteProbability (d : ℕ) where
  node : Fin d → UnitInterval
  weight : Fin d → ℝ
  weight_nonneg : ∀ i, 0 ≤ weight i
  weight_sum : ∑ i, weight i = 1

/-- Moment sequence of an explicit finite [0,1]-probability model. -/
def finiteMoment {d : ℕ} (P : FiniteProbability d) (n : ℕ) : ℝ :=
  ∑ i, P.weight i * ((P.node i : ℝ) ^ n)

/-- Explicit positive Pascal energy of the finite model. -/
def finiteEnergy {d : ℕ} (P : FiniteProbability d) (n k : ℕ) : ℝ :=
  ∑ i, P.weight i * bernsteinCell (P.node i) n k

/-- Zeroth difference order is exactly the moment boundary. -/
theorem finiteEnergy_zero {d : ℕ} (P : FiniteProbability d) (n : ℕ) :
    finiteEnergy P n 0 = finiteMoment P n := by
  simp [finiteEnergy, finiteMoment, bernsteinCell]

/-- Every finite-model Pascal energy is nonnegative, with no external positivity premise. -/
theorem finiteEnergy_nonneg {d : ℕ} (P : FiniteProbability d) (n k : ℕ) :
    0 ≤ finiteEnergy P n k := by
  unfold finiteEnergy
  apply Finset.sum_nonneg
  intro i hi
  exact mul_nonneg (P.weight_nonneg i) (bernsteinCell_nonneg (P.node i) n k)

/-- Exact finite-model Pascal split. -/
theorem finiteEnergy_split {d : ℕ} (P : FiniteProbability d) (n k : ℕ) :
    finiteEnergy P n k =
      finiteEnergy P (n + 1) k + finiteEnergy P n (k + 1) := by
  unfold finiteEnergy
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro i hi
  rw [← mul_add, ← bernsteinCell_split]

/-- Exact identification of signed finite differences with explicit positive energies. -/
theorem hdiff_finiteMoment_eq_energy {d : ℕ} (P : FiniteProbability d) :
    ∀ n k, hdiff (finiteMoment P) n k = finiteEnergy P n k := by
  intro n k
  induction k generalizing n with
  | zero =>
      simpa using (finiteEnergy_zero P n).symm
  | succ k ih =>
      rw [hdiff_succ, ih n, ih (n + 1)]
      have hs := finiteEnergy_split P n k
      linarith

/-- Unconditional Hausdorff positivity of every explicit finite [0,1] model. -/
theorem finiteMoment_hausdorff_nonneg {d : ℕ} (P : FiniteProbability d) (n k : ℕ) :
    0 ≤ hdiff (finiteMoment P) n k := by
  rw [hdiff_finiteMoment_eq_energy]
  exact finiteEnergy_nonneg P n k

/-- Scalar norm-square shadow of the canonical binary isometry at x∈[0,1]. -/
theorem binary_square_conservation (x : UnitInterval) (z : ℝ) :
    (Real.sqrt (x : ℝ) * z) ^ 2 +
      (Real.sqrt (1 - (x : ℝ)) * z) ^ 2 = z ^ 2 := by
  have hx : 0 ≤ (x : ℝ) := x.property.1
  have h1 : 0 ≤ 1 - (x : ℝ) := sub_nonneg.mpr x.property.2
  calc
    (Real.sqrt (x : ℝ) * z) ^ 2 +
        (Real.sqrt (1 - (x : ℝ)) * z) ^ 2
        = (Real.sqrt (x : ℝ)) ^ 2 * z ^ 2 +
          (Real.sqrt (1 - (x : ℝ))) ^ 2 * z ^ 2 := by ring
    _ = (x : ℝ) * z ^ 2 + (1 - (x : ℝ)) * z ^ 2 := by
          rw [Real.sq_sqrt hx, Real.sq_sqrt h1]
    _ = z ^ 2 := by ring

end GPBKQRTierA
