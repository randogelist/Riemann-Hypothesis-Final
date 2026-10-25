import Mathlib.NumberTheory.LSeries.RiemannZeta
import Mathlib.Analysis.Analytic.Order
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.MeasureTheory.Measure.Dirac
import Mathlib.MeasureTheory.Integral.Bochner.Set
import Mathlib.MeasureTheory.Integral.Bochner.ContinuousLinearMap
import Mathlib.Tactic.FunProp
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Ring

/-!
# Concrete objects for the three master statements

All objects in this file are fixed by Mathlib's pole-removed completed zeta.
The divisor measure records the natural analytic multiplicity at every point,
then restricts to the upper half-plane. No zero list is an input.

The definitions use Lean's total Bochner integral. Their analytic convergence
is a separate proposition in the statement layer; the elementary sign lemmas
below do not assert convergence or any master identity.
-/

noncomputable section

open MeasureTheory Set
open scoped ENNReal

namespace MasterChain

/-- The standard entire Riemann xi, including its values at 0 and 1. -/
def xi (s : ℂ) : ℂ :=
  (1 + s * (s - 1) * completedRiemannZeta₀ s) / 2

@[simp] theorem xi_zero : xi 0 = (1 / 2 : ℂ) := by
  norm_num [xi]

@[simp] theorem xi_one : xi 1 = (1 / 2 : ℂ) := by
  norm_num [xi]

theorem xi_differentiable : Differentiable ℂ xi := by
  intro s
  have hL : DifferentiableAt ℂ completedRiemannZeta₀ s :=
    differentiable_completedZeta₀ s
  unfold xi
  fun_prop

theorem xi_reflection (s : ℂ) : xi (1 - s) = xi s := by
  unfold xi
  rw [completedRiemannZeta₀_one_sub]
  ring

/-- The half-plane for the divisor variable s, not the GP variable u. -/
def H : Set ℂ := {s | 0 < s.im}

def displacement (s : ℂ) : ℝ := s.re - 1 / 2

def height (s : ℂ) : ℝ := s.im

/-- Exact analytic-multiplicity measure of xi in the upper half-plane. -/
def xiDivisorMeasure : Measure ℂ :=
  (Measure.sum fun s : ℂ =>
    (analyticOrderNatAt xi s : ℝ≥0∞) • Measure.dirac s).restrict H

/-- The scalar derivative ratio is fixed independently of the divisor integral. -/
def kappa : ℝ :=
  (deriv (deriv xi) (1 / 2 : ℂ) / (2 * xi (1 / 2 : ℂ))).re

/-- The positive reciprocal-height second moment. -/
def c1 : ℝ :=
  ∫ s : ℂ, (height s ^ 2)⁻¹ ∂xiDivisorMeasure

/-- The pointwise nonnegative defect kernel. -/
def defectKernel (s : ℂ) : ℝ :=
  displacement s ^ 2 * (3 * height s ^ 2 + displacement s ^ 2) /
    (height s ^ 2 * (height s ^ 2 + displacement s ^ 2) ^ 2)

/-- The RR defect is defined independently as its positive kernel integral. -/
def C_RR : ℝ := ∫ s : ℂ, defectKernel s ∂xiDivisorMeasure

/-- The density entering the positive Laplace realization. -/
def A (v : ℝ) : ℝ :=
  2 * v * ∫ s : ℂ,
    Real.exp (-height s * v) * Real.sin (displacement s * v / 2) ^ 2
      ∂xiDivisorMeasure

/-- Lebesgue measure on positive v. -/
def positiveLebesgue : Measure ℝ := volume.restrict (Ioi 0)

def densityMass : ℝ := ∫ v : ℝ, A v ∂positiveLebesgue

def g (v : ℝ) : ℝ := Real.sqrt (A v)

/-- The Laplace transform; its intended analytic domain is Re(u)>-1/2. -/
def V (u : ℂ) : ℂ :=
  ∫ v : ℝ in Ioi 0,
    Complex.exp (-(u + 1 / 2) * (v : ℂ)) * (g v : ℂ)

/-- The real positive integral at u=1, kept separate for later computation. -/
def scalarReadout : ℝ :=
  ∫ v : ℝ in Ioi 0, Real.exp (-3 * v / 2) * g v

theorem c1_nonneg : 0 ≤ c1 := by
  apply integral_nonneg
  intro s
  exact inv_nonneg.mpr (sq_nonneg (height s))

theorem defectKernel_nonneg (s : ℂ) : 0 ≤ defectKernel s := by
  unfold defectKernel
  positivity

theorem C_RR_nonneg : 0 ≤ C_RR :=
  integral_nonneg defectKernel_nonneg

theorem A_nonneg {v : ℝ} (hv : 0 ≤ v) : 0 ≤ A v := by
  unfold A
  apply mul_nonneg (mul_nonneg (by norm_num) hv)
  apply integral_nonneg
  intro s
  exact mul_nonneg (Real.exp_pos _).le (sq_nonneg _)

theorem densityMass_nonneg : 0 ≤ densityMass := by
  unfold densityMass positiveLebesgue
  apply integral_nonneg_of_ae
  filter_upwards [ae_restrict_mem measurableSet_Ioi] with v hv
  exact A_nonneg (le_of_lt hv)

theorem g_nonneg (v : ℝ) : 0 ≤ g v := Real.sqrt_nonneg _

theorem g_sq {v : ℝ} (hv : 0 ≤ v) : g v ^ 2 = A v :=
  Real.sq_sqrt (A_nonneg hv)

theorem scalarReadout_nonneg : 0 ≤ scalarReadout := by
  apply integral_nonneg
  intro v
  exact mul_nonneg (Real.exp_pos _).le (g_nonneg v)

/-- This normalization identity holds even for total integrals; convergence
is deliberately not inferred from it. -/
theorem V_one_eq_scalarReadout : V 1 = (scalarReadout : ℂ) := by
  unfold V scalarReadout
  rw [← integral_complex_ofReal]
  apply integral_congr_ae
  filter_upwards [] with v
  rw [Complex.ofReal_mul, Complex.ofReal_exp]
  congr 2
  push_cast
  ring

end MasterChain
