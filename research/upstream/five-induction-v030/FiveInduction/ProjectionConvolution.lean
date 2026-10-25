import Mathlib.Analysis.Analytic.Uniqueness
import Mathlib.Analysis.Analytic.OfScalars
import Mathlib.Analysis.Normed.Ring.InfiniteSum
import Mathlib.Analysis.Normed.Module.FiniteDimension
import Mathlib.LinearAlgebra.Complex.FiniteDimensional
import Mathlib.Tactic

namespace FiveInduction.ProjectionConvolution

open Filter Topology Finset

noncomputable section

def convolution (a b : ℕ → ℂ) (n : ℕ) : ℂ :=
  ∑ j ∈ Finset.range (n + 1), a j * b (n - j)

theorem hasFPowerSeriesAt_mul {f g : ℂ → ℂ}
    {p q : FormalMultilinearSeries ℂ ℂ ℂ}
    (hf : HasFPowerSeriesAt f p 0) (hg : HasFPowerSeriesAt g q 0) :
    HasFPowerSeriesAt (fun z => f z * g z)
      (FormalMultilinearSeries.ofScalars ℂ (convolution p.coeff q.coeff)) 0 := by
  rw [hasFPowerSeriesAt_iff] at hf hg ⊢
  filter_upwards [hf, hg] with z hfz hgz
  simp only [zero_add, smul_eq_mul] at hfz hgz ⊢
  have hsum := hasSum_sum_range_mul_of_summable_norm hfz.summable.norm hgz.summable.norm
  rw [hfz.tsum_eq, hgz.tsum_eq] at hsum
  have hterm : (fun n => z ^ n * (FormalMultilinearSeries.ofScalars ℂ (convolution p.coeff q.coeff)).coeff n) =
      (fun n => ∑ j ∈ Finset.range (n + 1), (z ^ j * p.coeff j) * (z ^ (n-j) * q.coeff (n-j))) := by
    funext n
    simp only [FormalMultilinearSeries.coeff_ofScalars, convolution, Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro j hj
    have hjn : j ≤ n := Nat.le_of_lt_succ (Finset.mem_range.mp hj)
    rw [show z ^ n = z ^ j * z ^ (n - j) from by rw [← pow_add, Nat.add_sub_of_le hjn]]
    ring
  rw [hterm]
  exact hsum
theorem convolution_eq_of_product_germ {f g : ℂ → ℂ}
    {p q : FormalMultilinearSeries ℂ ℂ ℂ}
    (hf : HasFPowerSeriesAt f p 0) (hg : HasFPowerSeriesAt g q 0)
    (hprod : ∀ᶠ z in 𝓝 (0 : ℂ), f z * g z = 1) (n : ℕ) :
    convolution p.coeff q.coeff n = if n = 0 then 1 else 0 := by
  have hp := hasFPowerSeriesAt_mul hf hg
  have heq := hp.eq_formalMultilinearSeries_of_eventually
    (hasFPowerSeriesAt_const (c := (1 : ℂ)) (e := (0 : ℂ))) hprod
  have heqc := congrArg (fun r : FormalMultilinearSeries ℂ ℂ ℂ => r.coeff n) heq
  rw [FormalMultilinearSeries.coeff_ofScalars] at heqc
  rw [heqc]
  cases n <;> rfl

theorem reciprocal_coeff_zero {f g : ℂ → ℂ}
    {p q : FormalMultilinearSeries ℂ ℂ ℂ}
    (hf : HasFPowerSeriesAt f p 0) (hg : HasFPowerSeriesAt g q 0)
    (hf0 : f 0 = 1) (hprod : ∀ᶠ z in 𝓝 (0 : ℂ), f z * g z = 1) :
    q.coeff 0 = 1 := by
  have h := convolution_eq_of_product_germ hf hg hprod 0
  have hp0 : p.coeff 0 = 1 := by
    exact (hf.coeff_zero 1).trans hf0
  simpa [convolution, hp0] using h

theorem reciprocal_coeff_succ {f g : ℂ → ℂ}
    {p q : FormalMultilinearSeries ℂ ℂ ℂ}
    (hf : HasFPowerSeriesAt f p 0) (hg : HasFPowerSeriesAt g q 0)
    (hf0 : f 0 = 1) (hprod : ∀ᶠ z in 𝓝 (0 : ℂ), f z * g z = 1) (n : ℕ) :
    q.coeff (n + 1) =
      -(∑ j ∈ Finset.range (n + 1), p.coeff (j + 1) * q.coeff (n - j)) := by
  have h := convolution_eq_of_product_germ hf hg hprod (n + 1)
  have hp0 : p.coeff 0 = 1 := by
    exact (hf.coeff_zero 1).trans hf0
  simp only [convolution, Nat.add_eq_zero_iff, Nat.one_ne_zero, and_false,
    ↓reduceIte] at h
  rw [Finset.sum_range_succ'] at h
  simp only [Nat.add_sub_add_right, hp0, Nat.sub_zero, one_mul] at h
  linear_combination h

end
end FiveInduction.ProjectionConvolution
