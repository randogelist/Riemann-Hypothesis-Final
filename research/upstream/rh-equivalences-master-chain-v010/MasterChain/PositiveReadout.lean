import Mathlib.MeasureTheory.Integral.Bochner.Basic
import Mathlib.Analysis.Real.Sqrt
import Mathlib.Analysis.SpecialFunctions.Exp

/-!
# Positive readout: exact vanishing, with analytic hypotheses explicit

For a nonnegative integrable density `A` and a strictly positive weight `w`,
the integrable readout `w * sqrt A` has integral zero exactly when `A` vanishes
almost everywhere. This is a measure-theoretic theorem, with no assertion that
any particular density or its readout actually vanishes.
-/

noncomputable section

open MeasureTheory
open scoped ENNReal

namespace MasterChain

/-- A positive weighted square-root integral detects exact a.e. vanishing.
Integrability is explicit to prevent use of the totalized Bochner integral
outside its integrable domain. -/
theorem positive_readout_eq_zero_iff_ae
    {μ : Measure ℝ} {A w : ℝ → ℝ}
    (hA : ∀ᵐ v ∂μ, 0 ≤ A v)
    (hw : ∀ᵐ v ∂μ, 0 < w v)
    (hReadout : Integrable (fun v => w v * Real.sqrt (A v)) μ) :
    (∫ v, w v * Real.sqrt (A v) ∂μ) = 0 ↔ A =ᵐ[μ] 0 := by
  have hnonneg : ∀ᵐ v ∂μ, 0 ≤ w v * Real.sqrt (A v) := by
    filter_upwards [hw] with v hv
    exact mul_nonneg hv.le (Real.sqrt_nonneg _)
  rw [integral_eq_zero_iff_of_nonneg_ae hnonneg hReadout]
  constructor
  · intro h
    filter_upwards [h, hA, hw] with v hv hAv hwv
    change w v * Real.sqrt (A v) = 0 at hv
    change A v = 0
    exact (Real.sqrt_eq_zero hAv).mp
      ((mul_eq_zero.mp hv).resolve_left (ne_of_gt hwv))
  · intro h
    filter_upwards [h] with v hv
    change A v = 0 at hv
    change w v * Real.sqrt (A v) = 0
    simp [hv]

/-- A positive weighted square-root integral vanishes exactly when the mass
of the nonnegative density vanishes. -/
theorem positive_readout_eq_zero_iff_mass
    {μ : Measure ℝ} {A w : ℝ → ℝ}
    (hA : ∀ᵐ v ∂μ, 0 ≤ A v)
    (hw : ∀ᵐ v ∂μ, 0 < w v)
    (hMass : Integrable A μ)
    (hReadout : Integrable (fun v => w v * Real.sqrt (A v)) μ) :
    (∫ v, w v * Real.sqrt (A v) ∂μ) = 0 ↔ (∫ v, A v ∂μ) = 0 := by
  exact (positive_readout_eq_zero_iff_ae hA hw hReadout).trans
    (integral_eq_zero_iff_of_nonneg_ae hA hMass).symm

/-- Specialization to the actual positive evaluation weight at `u = 1`.
The measure may be `volume.restrict (Set.Ioi 0)`. -/
theorem evaluation_one_eq_zero_iff_mass
    {μ : Measure ℝ} {A : ℝ → ℝ}
    (hA : ∀ᵐ v ∂μ, 0 ≤ A v)
    (hMass : Integrable A μ)
    (hReadout : Integrable
      (fun v => Real.exp (-(3 : ℝ) * v / 2) * Real.sqrt (A v)) μ) :
    (∫ v, Real.exp (-(3 : ℝ) * v / 2) * Real.sqrt (A v) ∂μ) = 0 ↔
      (∫ v, A v ∂μ) = 0 := by
  exact positive_readout_eq_zero_iff_mass hA
    (Filter.Eventually.of_forall fun v => Real.exp_pos _) hMass hReadout

end MasterChain
