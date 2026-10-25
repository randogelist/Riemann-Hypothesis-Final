import Core.ActualXiJet
import Derivations.AnalyticODE
import Mathlib.Analysis.Complex.CauchyIntegral

set_option maxHeartbeats 1200000
set_option maxRecDepth 2048

namespace NativeSolobolo.SignedBernstein.AnalyticClosure

open Filter Topology

/-- The literal right half-plane; no abstract zero geometry is involved. -/
def xiRightHalfPlane : Set ℂ := {z : ℂ | (1 / 2 : ℝ) < z.re}

theorem XI_RIGHT_HALF_PLANE_OPEN : IsOpen xiRightHalfPlane := by
  exact isOpen_Ioi.preimage Complex.continuous_re

theorem XI_RIGHT_HALF_PLANE_CONVEX : Convex ℝ xiRightHalfPlane := by
  intro z hz w hw a b ha hb hab
  change (1 / 2 : ℝ) < z.re at hz
  change (1 / 2 : ℝ) < w.re at hw
  change (1 / 2 : ℝ) < RCLike.re (a • z + b • w)
  rw [map_add, RCLike.smul_re, RCLike.smul_re]
  change (1 / 2 : ℝ) < a * z.re + b * w.re
  by_cases ha0 : a = 0
  · have hb1 : b = 1 := by linarith
    simpa only [ha0, hb1, zero_mul, one_mul, zero_add] using hw
  · have hap : 0 < a := lt_of_le_of_ne ha (Ne.symm ha0)
    have hza : a * (1 / 2 : ℝ) < a * z.re :=
      mul_lt_mul_of_pos_left hz hap
    have hwb : b * (1 / 2 : ℝ) ≤ b * w.re :=
      mul_le_mul_of_nonneg_left hw.le hb
    calc
      (1 / 2 : ℝ) = a * (1 / 2 : ℝ) + b * (1 / 2 : ℝ) := by
        nlinarith [hab]
      _ < a * z.re + b * w.re := add_lt_add_of_lt_of_le hza hwb

theorem XI_RIGHT_HALF_PLANE_PRECONNECTED : IsPreconnected xiRightHalfPlane :=
  XI_RIGHT_HALF_PLANE_CONVEX.isPreconnected

theorem XI_ONE_MEM_RIGHT_HALF_PLANE : (1 : ℂ) ∈ xiRightHalfPlane := by
  norm_num [xiRightHalfPlane]

theorem XI_ONE_NE_ZERO : xiEntire 1 ≠ 0 := by
  rw [xiEntire_one]
  norm_num

theorem XI_ANALYTIC_RIGHT_HALF_PLANE :
    AnalyticOnNhd ℂ xiEntire xiRightHalfPlane :=
  XI_ENTIRE.differentiableOn.analyticOnNhd XI_RIGHT_HALF_PLANE_OPEN

/-- A literal nontrivial zeta zero is a zero of the existing xiEntire definition.
The Gamma factor is dealt with using its actual zero characterization. -/
theorem NONTRIVIAL_ZETA_ZERO_IS_XI_ZERO
    {rho : ℂ}
    (hzeta : riemannZeta rho = 0)
    (htrivial : ¬ ∃ n : ℕ, rho = -2 * ((n : ℂ) + 1))
    (hone : rho ≠ 1) : xiEntire rho = 0 := by
  have hrho0 : rho ≠ 0 := by
    intro h0
    subst rho
    have hbad := hzeta
    rw [riemannZeta_zero] at hbad
    norm_num at hbad
  have hGamma : rho.Gammaℝ ≠ 0 := by
    intro hGamma0
    rcases Complex.Gammaℝ_eq_zero_iff.mp hGamma0 with ⟨n, hn⟩
    cases n with
    | zero =>
        apply hrho0
        simpa using hn
    | succ n =>
        apply htrivial
        refine ⟨n, ?_⟩
        calc
          rho = -(2 * (↑(Nat.succ n) : ℂ)) := hn
          _ = -2 * ((n : ℂ) + 1) := by push_cast; ring
  have hdef := riemannZeta_def_of_ne_zero hrho0
  rw [hzeta] at hdef
  have hcomp : completedRiemannZeta rho = 0 :=
    (div_eq_zero_iff.mp hdef.symm).resolve_right hGamma
  rw [XI_COMPLETED_BINDING rho hrho0 hone, hcomp]
  simp

/-- Actual right-half-plane nonvanishing implies Mathlib's native RH statement.
Reflection of xi, rather than a custom RH proposition, supplies the other side. -/
theorem NATIVE_RH_OF_XI_RIGHT_NONVANISHING
    (hnz : ∀ z ∈ xiRightHalfPlane, xiEntire z ≠ 0) :
    _root_.RiemannHypothesis := by
  intro rho hzeta htrivial hone
  have hxi : xiEntire rho = 0 :=
    NONTRIVIAL_ZETA_ZERO_IS_XI_ZERO hzeta htrivial hone
  apply le_antisymm
  · by_contra hle
    have hgt : (1 / 2 : ℝ) < rho.re := lt_of_not_ge hle
    exact hnz rho hgt hxi
  · by_contra hle
    have hlt : rho.re < (1 / 2 : ℝ) := lt_of_not_ge hle
    have href : (1 - rho : ℂ) ∈ xiRightHalfPlane := by
      change (1 / 2 : ℝ) < (1 - rho : ℂ).re
      simp only [Complex.sub_re, Complex.one_re]
      linarith
    have hxiRef : xiEntire (1 - rho) = 0 := by
      rw [XI_REFLECTION rho, hxi]
    exact hnz (1 - rho) href hxiRef

/-- Explicit analytic input at the endpoint.  This is not claimed to be derived
from ActualWeakEnergyBound in this release.  The matching condition concerns only
the actual local germ at 1, not global reconstruction or assumed nonvanishing. -/
def ActualXiLogDerivativeExtension : Prop :=
  ∃ p : ℂ → ℂ,
    AnalyticOnNhd ℂ p xiRightHalfPlane ∧
    p =ᶠ[𝓝 (1 : ℂ)] (fun z : ℂ => deriv xiEntire z / xiEntire z)

/-- Entirely analytic zero exclusion for the actual xi function. -/
theorem XI_LOG_DERIVATIVE_EXTENSION_NONVANISHING
    (h : ActualXiLogDerivativeExtension) :
    ∀ z ∈ xiRightHalfPlane, xiEntire z ≠ 0 := by
  obtain ⟨p, hp, hmatch⟩ := h
  exact LOG_DERIVATIVE_GERM_EXTENSION_NONZERO_ON
    XI_RIGHT_HALF_PLANE_OPEN XI_RIGHT_HALF_PLANE_PRECONNECTED
    XI_ANALYTIC_RIGHT_HALF_PLANE hp XI_ONE_MEM_RIGHT_HALF_PLANE
    XI_ONE_NE_ZERO hmatch

/-- A real native-RH conclusion, conditional on a fully specified analytic
extension.  There is no AllDepthDiagonalization premise in this theorem. -/
theorem NATIVE_RH_OF_XI_LOG_DERIVATIVE_EXTENSION
    (h : ActualXiLogDerivativeExtension) : _root_.RiemannHypothesis :=
  NATIVE_RH_OF_XI_RIGHT_NONVANISHING
    (XI_LOG_DERIVATIVE_EXTENSION_NONVANISHING h)

/-- An explicit local analytic ODE coefficient is enough for the same endpoint. -/
theorem NATIVE_RH_OF_XI_ODE_GERM
    (p : ℂ → ℂ)
    (hp : AnalyticOnNhd ℂ p xiRightHalfPlane)
    (hode : deriv xiEntire =ᶠ[𝓝 (1 : ℂ)]
      (fun z : ℂ => p z * xiEntire z)) :
    _root_.RiemannHypothesis := by
  apply NATIVE_RH_OF_XI_RIGHT_NONVANISHING
  exact ANALYTIC_ODE_GERM_NONZERO_ON
    XI_RIGHT_HALF_PLANE_OPEN XI_RIGHT_HALF_PLANE_PRECONNECTED
    XI_ANALYTIC_RIGHT_HALF_PLANE hp XI_ONE_MEM_RIGHT_HALF_PLANE
    XI_ONE_NE_ZERO hode

end NativeSolobolo.SignedBernstein.AnalyticClosure
