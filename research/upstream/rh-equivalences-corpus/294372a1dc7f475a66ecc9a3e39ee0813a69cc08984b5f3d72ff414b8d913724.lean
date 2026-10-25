import Derivations.XiNativeEndpoint
import Mathlib.NumberTheory.LSeries.Nonvanishing

set_option maxHeartbeats 1200000

namespace NativeSolobolo.SignedBernstein.AnalyticClosure

open Filter Topology

/-- In the right half-plane, an actual xi zero is an actual zeta zero.
The removable endpoints are excluded by the preserved values xi(0)=xi(1)=1/2. -/
theorem XI_ZERO_RIGHT_IS_ZETA_ZERO {z : ℂ}
    (hz : z ∈ xiRightHalfPlane) (hxi : xiEntire z = 0) :
    riemannZeta z = 0 := by
  have hz0 : z ≠ 0 := by
    intro heq
    subst z
    norm_num [xiRightHalfPlane] at hz
  have hz1 : z ≠ 1 := by
    intro heq
    subst z
    exact XI_ONE_NE_ZERO hxi
  have hpref : z * (z - 1) / (2 : ℂ) ≠ 0 := by
    exact div_ne_zero (mul_ne_zero hz0 (sub_ne_zero.mpr hz1)) (by norm_num)
  have hcomp : completedRiemannZeta z = 0 := by
    rw [XI_COMPLETED_BINDING z hz0 hz1] at hxi
    exact (mul_eq_zero.mp hxi).resolve_left hpref
  rw [riemannZeta_def_of_ne_zero hz0, hcomp]
  exact zero_div _

/-- Unconditional nonvanishing on the classical right half-plane, derived
from Mathlib's actual zeta nonvanishing theorem. -/
theorem XI_NE_ZERO_OF_ONE_LE_RE {z : ℂ} (hz : 1 ≤ z.re) :
    xiEntire z ≠ 0 := by
  intro hxi
  have hright : z ∈ xiRightHalfPlane := by
    change (1 / 2 : ℝ) < z.re
    linarith
  exact riemannZeta_ne_zero_of_one_le_re hz (XI_ZERO_RIGHT_IS_ZETA_ZERO hright hxi)

theorem XI_THREE_HALVES_NE_ZERO : xiEntire (3 / 2 : ℂ) ≠ 0 := by
  apply XI_NE_ZERO_OF_ONE_LE_RE
  norm_num

theorem XI_THREE_HALVES_MEM_RIGHT_HALF_PLANE : (3 / 2 : ℂ) ∈ xiRightHalfPlane := by
  norm_num [xiRightHalfPlane]

/-- The actual converse of the passed right-half-plane nonvanishing endpoint. -/
theorem XI_RIGHT_NONVANISHING_OF_NATIVE_RH
    (hRH : _root_.RiemannHypothesis) :
    ∀ z ∈ xiRightHalfPlane, xiEntire z ≠ 0 := by
  intro z hz hxi
  have hzeta : riemannZeta z = 0 := XI_ZERO_RIGHT_IS_ZETA_ZERO hz hxi
  have hz1 : z ≠ 1 := by
    intro heq
    subst z
    exact XI_ONE_NE_ZERO hxi
  have htrivial : ¬ ∃ n : ℕ, z = -2 * ((n : ℂ) + 1) := by
    rintro ⟨n, heq⟩
    have hn : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
    have hre : z.re = -2 * ((n : ℝ) + 1) := by
      have ht := congrArg Complex.re heq
      simpa using ht
    change (1 / 2 : ℝ) < z.re at hz
    linarith
  have hline : z.re = (1 / 2 : ℝ) := hRH z hzeta htrivial hz1
  change (1 / 2 : ℝ) < z.re at hz
  linarith

/-- This is an equivalence about the fixed literal xi definition, not a new RH predicate. -/
theorem XI_RIGHT_NONVANISHING_IFF_NATIVE_RH :
    (∀ z ∈ xiRightHalfPlane, xiEntire z ≠ 0) ↔ _root_.RiemannHypothesis := by
  exact ⟨NATIVE_RH_OF_XI_RIGHT_NONVANISHING, XI_RIGHT_NONVANISHING_OF_NATIVE_RH⟩

/-- Under RH the actual logarithmic derivative is itself the required extension. -/
theorem XI_LOG_DERIVATIVE_ANALYTIC_OF_NATIVE_RH
    (hRH : _root_.RiemannHypothesis) :
    AnalyticOnNhd ℂ (fun z : ℂ => deriv xiEntire z / xiEntire z)
      xiRightHalfPlane := by
  exact XI_ANALYTIC_RIGHT_HALF_PLANE.deriv.div
    XI_ANALYTIC_RIGHT_HALF_PLANE (XI_RIGHT_NONVANISHING_OF_NATIVE_RH hRH)

theorem XI_LOG_DERIVATIVE_EXTENSION_OF_NATIVE_RH
    (hRH : _root_.RiemannHypothesis) : ActualXiLogDerivativeExtension := by
  refine ⟨fun z : ℂ => deriv xiEntire z / xiEntire z,
    XI_LOG_DERIVATIVE_ANALYTIC_OF_NATIVE_RH hRH, ?_⟩
  exact Filter.EventuallyEq.rfl

/-- Completed analytic-endpoint equivalence.  This is deliberately NOT the
still-unfinished equivalence for ActualWeakEnergyBound. -/
theorem XI_LOG_DERIVATIVE_EXTENSION_IFF_NATIVE_RH :
    ActualXiLogDerivativeExtension ↔ _root_.RiemannHypothesis := by
  exact ⟨NATIVE_RH_OF_XI_LOG_DERIVATIVE_EXTENSION,
    XI_LOG_DERIVATIVE_EXTENSION_OF_NATIVE_RH⟩

/-- Every extension satisfying the original local matching condition is forced
to be the literal logarithmic derivative throughout the right half-plane. -/
theorem XI_LOG_DERIVATIVE_EXTENSION_MATCHES_GLOBALLY
    (p : ℂ → ℂ)
    (hp : AnalyticOnNhd ℂ p xiRightHalfPlane)
    (hmatch : p =ᶠ[𝓝 (1 : ℂ)]
      (fun z : ℂ => deriv xiEntire z / xiEntire z)) :
    Set.EqOn p (fun z : ℂ => deriv xiEntire z / xiEntire z) xiRightHalfPlane := by
  have hRH : _root_.RiemannHypothesis :=
    NATIVE_RH_OF_XI_LOG_DERIVATIVE_EXTENSION ⟨p, hp, hmatch⟩
  exact hp.eqOn_of_preconnected_of_eventuallyEq
    (XI_LOG_DERIVATIVE_ANALYTIC_OF_NATIVE_RH hRH)
    XI_RIGHT_HALF_PLANE_PRECONNECTED XI_ONE_MEM_RIGHT_HALF_PLANE hmatch

/-- A converse for the ODE-germ endpoint, again with no weak-energy premise. -/
theorem XI_ODE_GERM_IFF_NATIVE_RH :
    (∃ p : ℂ → ℂ,
      AnalyticOnNhd ℂ p xiRightHalfPlane ∧
      deriv xiEntire =ᶠ[𝓝 (1 : ℂ)] (fun z : ℂ => p z * xiEntire z)) ↔
      _root_.RiemannHypothesis := by
  constructor
  · rintro ⟨p, hp, hode⟩
    exact NATIVE_RH_OF_XI_ODE_GERM p hp hode
  · intro hRH
    refine ⟨fun z : ℂ => deriv xiEntire z / xiEntire z,
      XI_LOG_DERIVATIVE_ANALYTIC_OF_NATIVE_RH hRH, ?_⟩
    filter_upwards [XI_RIGHT_HALF_PLANE_OPEN.mem_nhds XI_ONE_MEM_RIGHT_HALF_PLANE]
      with z hz
    exact (div_mul_cancel₀ (deriv xiEntire z)
      (XI_RIGHT_NONVANISHING_OF_NATIVE_RH hRH z hz)).symm

end NativeSolobolo.SignedBernstein.AnalyticClosure
