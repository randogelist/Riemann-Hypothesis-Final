import Mathlib.MeasureTheory.Function.L2Space
import Mathlib.Analysis.Real.Sqrt

/-!
# A nonnegative integrable density as a genuine Hilbert-space vector

This module constructs `sqrt A` as an element of mathlib's actual `Lp` space
and proves its norm-squared identity. The norm is the library's L2 norm;
it is not defined to equal the integral of `A`.

The Fourier/Laplace identification with the GP Hardy-space boundary is a
separate analytic step. Nothing in this module asserts that the density is
zero or identifies the actual xi divisor without a supplied hypothesis.
-/

noncomputable section

open MeasureTheory
open scoped ENNReal

namespace MasterChain

/-- A nonnegative integrable density has an L2 square root. -/
theorem sqrt_density_memLp
    {μ : Measure ℝ} {A : ℝ → ℝ}
    (hA : ∀ᵐ v ∂μ, 0 ≤ A v)
    (hMass : Integrable A μ) :
    MemLp (fun v => Real.sqrt (A v)) 2 μ := by
  apply (memLp_two_iff_integrable_sq
    (Real.continuous_sqrt.comp_aestronglyMeasurable hMass.1)).mpr
  apply hMass.congr
  filter_upwards [hA] with v hv
  exact (Real.sq_sqrt hv).symm

/-- The actual L2 equivalence class represented by `sqrt A`. -/
def densityL2
    {μ : Measure ℝ} {A : ℝ → ℝ}
    (hA : ∀ᵐ v ∂μ, 0 ≤ A v)
    (hMass : Integrable A μ) : Lp ℝ 2 μ :=
  (sqrt_density_memLp hA hMass).toLp (fun v => Real.sqrt (A v))

/-- Representative identification, stated almost everywhere as required for Lp. -/
theorem densityL2_coe_ae
    {μ : Measure ℝ} {A : ℝ → ℝ}
    (hA : ∀ᵐ v ∂μ, 0 ≤ A v)
    (hMass : Integrable A μ) :
    densityL2 hA hMass =ᵐ[μ] (fun v => Real.sqrt (A v)) :=
  (sqrt_density_memLp hA hMass).coeFn_toLp

/-- Genuine Hilbert norm identity for the square-root density. -/
theorem norm_densityL2_sq
    {μ : Measure ℝ} {A : ℝ → ℝ}
    (hA : ∀ᵐ v ∂μ, 0 ≤ A v)
    (hMass : Integrable A μ) :
    ‖densityL2 hA hMass‖ ^ 2 = ∫ v, A v ∂μ := by
  rw [← real_inner_self_eq_norm_sq, L2.inner_def]
  apply integral_congr_ae
  filter_upwards [densityL2_coe_ae hA hMass, hA] with v hv hAv
  rw [hv, real_inner_self_eq_norm_sq, Real.norm_eq_abs,
    abs_of_nonneg (Real.sqrt_nonneg _), Real.sq_sqrt hAv]

/-- Vanishing of this Hilbert vector is equivalent to vanishing density mass. -/
theorem densityL2_eq_zero_iff_mass
    {μ : Measure ℝ} {A : ℝ → ℝ}
    (hA : ∀ᵐ v ∂μ, 0 ≤ A v)
    (hMass : Integrable A μ) :
    densityL2 hA hMass = 0 ↔ (∫ v, A v ∂μ) = 0 := by
  rw [← norm_densityL2_sq hA hMass]
  simp

end MasterChain
