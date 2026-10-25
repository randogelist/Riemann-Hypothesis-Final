import FiveInduction.HardyDefect

namespace FiveInduction.HardyTail

open Filter Finset
open scoped Topology

open FiveInduction.HardyDefect

theorem normSq_sum_mul_le (s : Finset ℕ) (a b : ℕ → ℂ) :
    Complex.normSq (∑ n ∈ s, a n * b n) ≤
      (∑ n ∈ s, Complex.normSq (a n)) * ∑ n ∈ s, Complex.normSq (b n) := by
  rw [Complex.normSq_eq_norm_sq]
  calc
    ‖∑ n ∈ s, a n * b n‖ ^ 2 ≤ (∑ n ∈ s, ‖a n * b n‖) ^ 2 := by
      gcongr
      exact norm_sum_le _ _
    _ = (∑ n ∈ s, ‖a n‖ * ‖b n‖) ^ 2 := by simp only [norm_mul]
    _ ≤ (∑ n ∈ s, ‖a n‖ ^ 2) * ∑ n ∈ s, ‖b n‖ ^ 2 :=
      Finset.sum_mul_sq_le_sq_mul_sq s (fun n => ‖a n‖) (fun n => ‖b n‖)
    _ = _ := by simp only [Complex.normSq_eq_norm_sq]

theorem normSq_hasSum_mul_le {a b : ℕ → ℂ} {A B : ℝ} {s : ℂ}
    (ha : HasSum (fun n => Complex.normSq (a n)) A)
    (hb : HasSum (fun n => Complex.normSq (b n)) B)
    (hs : HasSum (fun n => a n * b n) s) :
    Complex.normSq s ≤ A * B := by
  apply le_of_tendsto_of_tendsto
    (Complex.continuous_normSq.continuousAt.tendsto.comp hs.tendsto_sum_nat)
    (ha.tendsto_sum_nat.mul hb.tendsto_sum_nat)
  exact Filter.Eventually.of_forall (fun n => normSq_sum_mul_le (Finset.range n) a b)

/-- Square summability of both factors implies absolute summability of their product. -/
theorem summable_mul_of_normSq {a b : ℕ → ℂ}
    (ha : Summable (fun n => Complex.normSq (a n)))
    (hb : Summable (fun n => Complex.normSq (b n))) :
    Summable (fun n => a n * b n) := by
  apply Summable.of_norm
  apply ((ha.add hb).div_const 2).of_nonneg_of_le
  · intro n
    exact norm_nonneg _
  · intro n
    simp only [norm_mul, Complex.normSq_eq_norm_sq]
    nlinarith [sq_nonneg (‖a n‖ - ‖b n‖)]

/-- The coefficient series exists throughout the disk, solely from its total energy. -/
theorem coeffSeries_summable {c : ℕ → ℂ} {K : ℝ} {w : ℂ}
    (henergy : HasSum (fun n => Complex.normSq (c n)) K)
    (hw : Complex.normSq w < 1) :
    Summable (fun n => c n * w ^ n) := by
  apply summable_mul_of_normSq henergy.summable
  simpa only [map_pow] using
    (hasSum_geometric_of_lt_one (Complex.normSq_nonneg w) hw).summable

/-- Removing a finite prefix leaves precisely the unused coefficient energy. -/
theorem tailMass_hasSum {c : ℕ → ℂ} {K : ℝ}
    (henergy : HasSum (fun n => Complex.normSq (c n)) K) (N : ℕ) :
    HasSum (fun n => Complex.normSq (c (n + (N + 1)))) (tailMass c K N) := by
  simpa only [tailMass, mass] using (hasSum_nat_add_iff' (N + 1)).mpr henergy

theorem tailMass_nonneg {c : ℕ → ℂ} {K : ℝ}
    (henergy : HasSum (fun n => Complex.normSq (c n)) K) (N : ℕ) :
    0 ≤ tailMass c K N :=
  HasSum.nonneg (fun _ => Complex.normSq_nonneg _) (tailMass_hasSum henergy N)

/-- The exact Hardy tail estimate follows from coefficient energy and the geometric series. -/
theorem tail_bound {c : ℕ → ℂ} {K : ℝ} {w z : ℂ}
    (henergy : HasSum (fun n => Complex.normSq (c n)) K)
    (hvalue : HasSum (fun n => c n * w ^ n) z)
    (hw : Complex.normSq w < 1) (N : ℕ) :
    (1 - Complex.normSq w) * Complex.normSq (z - HardyDefect.partial c N w) ≤
      tailMass c K N * (Complex.normSq w) ^ (N + 1) := by
  have ha := tailMass_hasSum henergy N
  have hb : HasSum (fun n => Complex.normSq (w ^ (n + (N + 1))))
      ((1 - Complex.normSq w)⁻¹ * (Complex.normSq w) ^ (N + 1)) := by
    simpa only [map_pow, map_mul, pow_add] using
      (hasSum_geometric_of_lt_one (Complex.normSq_nonneg w) hw).mul_right
        ((Complex.normSq w) ^ (N + 1))
  have hs : HasSum (fun n => c (n + (N + 1)) * w ^ (n + (N + 1)))
      (z - HardyDefect.partial c N w) := by
    simpa only [HardyDefect.partial] using (hasSum_nat_add_iff' (N + 1)).mpr hvalue
  have hcs := normSq_hasSum_mul_le ha hb hs
  have hpos : 0 < 1 - Complex.normSq w := sub_pos.mpr hw
  calc
    (1 - Complex.normSq w) * Complex.normSq (z - HardyDefect.partial c N w) ≤
        (1 - Complex.normSq w) * (tailMass c K N *
          ((1 - Complex.normSq w)⁻¹ * (Complex.normSq w) ^ (N + 1))) :=
      mul_le_mul_of_nonneg_left hcs hpos.le
    _ = tailMass c K N * (Complex.normSq w) ^ (N + 1) := by
      field_simp

/-- A zero cannot have a strictly positive finite coefficient defect. -/
theorem defect_nonpos_of_zero {c : ℕ → ℂ} {K : ℝ} {w : ℂ}
    (henergy : HasSum (fun n => Complex.normSq (c n)) K)
    (hvalue : HasSum (fun n => c n * w ^ n) 0)
    (hw : Complex.normSq w < 1) (N : ℕ) :
    defect c K N w ≤ 0 := by
  have h := tail_bound henergy hvalue hw N
  simp only [zero_sub, Complex.normSq_neg] at h
  exact sub_nonpos.mpr h

theorem nonzero_of_defect_pos {c : ℕ → ℂ} {K : ℝ} {w z : ℂ}
    (henergy : HasSum (fun n => Complex.normSq (c n)) K)
    (hvalue : HasSum (fun n => c n * w ^ n) z)
    (hw : Complex.normSq w < 1) (N : ℕ)
    (hpos : 0 < defect c K N w) : z ≠ 0 := by
  intro hz
  subst z
  exact (not_lt_of_ge (defect_nonpos_of_zero henergy hvalue hw N)) hpos

end FiveInduction.HardyTail
