import FiveInduction.Projection
import FiveInduction.ProjectionRadius
import FiveInduction.ProjectionConvolution
import FiveInduction.CayleyBridge
import Mathlib.Analysis.Analytic.OfScalars
import Mathlib.Analysis.Analytic.Uniqueness
import Mathlib.Analysis.Analytic.Constructions
import Mathlib.Analysis.Analytic.ChangeOrigin
import Mathlib.Analysis.Calculus.IteratedDeriv.Defs
import Mathlib.Analysis.SpecialFunctions.Exp

/-!
# Actual reciprocal coefficients and the projection input

The reciprocal is used only as an analytic germ at zero, where the actual
Cayley transform equals one. No disk-wide inverse is assumed.
-/
namespace FiveInduction.ProjectionInput

open Filter Set
open scoped Topology

noncomputable section

/-- The actual local reciprocal germ is analytic unconditionally. -/
theorem analyticAt_reciprocal : AnalyticAt ℂ (fun z => (CayleyBridge.F z)⁻¹) 0 :=
  (CayleyBridge.analyticOnNhd_F 0 CayleyBridge.zero_mem_unitDisk).inv
    (by rw [CayleyBridge.F_zero]; norm_num)

/-- A Taylor series of the actual reciprocal germ; its coefficients are unique. -/
def reciprocalSeries : FormalMultilinearSeries ℂ ℂ ℂ :=
  Classical.choose analyticAt_reciprocal

theorem hasFPowerSeriesAt_reciprocal :
    HasFPowerSeriesAt (fun z => (CayleyBridge.F z)⁻¹) reciprocalSeries 0 :=
  Classical.choose_spec analyticAt_reciprocal

/-- Canonical actual reciprocal coefficient. -/
def reciprocalCoeff (n : ℕ) : ℂ := reciprocalSeries.coeff n

theorem reciprocalSeries_eq_ofScalars :
    reciprocalSeries = FormalMultilinearSeries.ofScalars ℂ reciprocalCoeff := by
  ext n
  simp [FormalMultilinearSeries.ofScalars, reciprocalCoeff,
    FormalMultilinearSeries.apply_eq_prod_smul_coeff, mul_comm]

@[simp] theorem reciprocalCoeff_zero : reciprocalCoeff 0 = 1 := by
  have h := hasFPowerSeriesAt_reciprocal.coeff_zero (1 : Fin 0 → ℂ)
  simpa only [reciprocalCoeff, FormalMultilinearSeries.coeff, CayleyBridge.F_zero, inv_one] using h

/-- The coefficient definition is independent of the chosen analytic expansion. -/
theorem reciprocalCoeff_eq_iteratedDeriv (n : ℕ) :
    reciprocalCoeff n =
      iteratedDeriv n (fun z => (CayleyBridge.F z)⁻¹) 0 / n.factorial := by
  have h := hasFPowerSeriesAt_reciprocal.eq_formalMultilinearSeries
    analyticAt_reciprocal.hasFPowerSeriesAt
  have hc := congrArg (fun p : FormalMultilinearSeries ℂ ℂ ℂ => p.coeff n) h
  simpa only [reciprocalCoeff, FormalMultilinearSeries.coeff_ofScalars] using hc

/-- Actual Taylor coefficients of the normalized Cayley transform. -/
def cayleyCoeff (n : ℕ) : ℂ := iteratedDeriv n CayleyBridge.F 0 / n.factorial

theorem hasFPowerSeriesAt_cayley :
    HasFPowerSeriesAt CayleyBridge.F (FormalMultilinearSeries.ofScalars ℂ cayleyCoeff) 0 :=
  (CayleyBridge.analyticOnNhd_F 0 CayleyBridge.zero_mem_unitDisk).hasFPowerSeriesAt

@[simp] theorem cayleyCoeff_zero : cayleyCoeff 0 = 1 := by
  simp [cayleyCoeff, CayleyBridge.F_zero]

/-- The local reciprocal identity needs only continuity at zero and F(0)=1. -/
theorem local_reciprocal_identity :
    ∀ᶠ z in 𝓝 (0 : ℂ), CayleyBridge.F z * (CayleyBridge.F z)⁻¹ = 1 := by
  have hne : ∀ᶠ z in 𝓝 (0 : ℂ), CayleyBridge.F z ≠ 0 :=
    (CayleyBridge.analyticOnNhd_F 0 CayleyBridge.zero_mem_unitDisk).continuousAt.eventually_ne
      (by rw [CayleyBridge.F_zero]; norm_num)
  exact hne.mono (fun _ hz => mul_inv_cancel₀ hz)

/-- The canonical germ coefficients satisfy the exact formal reciprocal recurrence. -/
theorem reciprocalCoeff_succ (n : ℕ) :
    reciprocalCoeff (n + 1) =
      -(∑ j ∈ Finset.range (n + 1), cayleyCoeff (j + 1) * reciprocalCoeff (n - j)) := by
  have h := ProjectionConvolution.reciprocal_coeff_succ hasFPowerSeriesAt_cayley
    hasFPowerSeriesAt_reciprocal CayleyBridge.F_zero local_reciprocal_identity n
  simpa only [reciprocalCoeff, FormalMultilinearSeries.coeff_ofScalars] using h

/-- The same arithmetic object defined solely by its finite convolution recursion. -/
def reciprocalFromTaylor (n : ℕ) : ℂ :=
  match n with
  | 0 => 1
  | n + 1 => -(∑ j ∈ Finset.range (n + 1), cayleyCoeff (j + 1) * reciprocalFromTaylor (n - j))
termination_by n
decreasing_by omega

/-- The recursive arithmetic object is identified with the actual reciprocal germ. -/
theorem reciprocalFromTaylor_eq (n : ℕ) : reciprocalFromTaylor n = reciprocalCoeff n := by
  induction n using Nat.strong_induction_on with
  | h n ih =>
      cases n with
      | zero => simp [reciprocalFromTaylor]
      | succ n =>
          rw [reciprocalFromTaylor, reciprocalCoeff_succ]
          congr 1
          apply Finset.sum_congr rfl
          intro j hj
          rw [ih (n - j) (by omega)]

/-- Reciprocal power series, evaluated wherever it converges. -/
def reciprocalSum : ℂ → ℂ := reciprocalSeries.sum

/-- Local identification is automatic from the actual reciprocal germ. -/
theorem reciprocalSum_eventually :
    reciprocalSum =ᶠ[𝓝 0] (fun z => (CayleyBridge.F z)⁻¹) := by
  obtain ⟨r, hr⟩ := hasFPowerSeriesAt_reciprocal
  filter_upwards [Metric.eball_mem_nhds (0 : ℂ) hr.r_pos] with z hz
  exact (by simpa [reciprocalSum] using (hr.sum hz).symm)

/-- A radius bound is sufficient for an actual inverse throughout the Cayley disk. -/
theorem cayley_mul_reciprocalSum (hradius : 1 ≤ reciprocalSeries.radius) :
    ∀ z ∈ CayleyBridge.unitDisk, CayleyBridge.F z * reciprocalSum z = 1 := by
  have hsub : CayleyBridge.unitDisk ⊆ Metric.eball (0 : ℂ) reciprocalSeries.radius := by
    intro z hz
    apply lt_of_lt_of_le _ hradius
    change dist z 0 < 1 at hz
    simpa only [← ENNReal.ofReal_one, edist_lt_ofReal] using hz
  have hsum : AnalyticOnNhd ℂ reciprocalSum CayleyBridge.unitDisk :=
    reciprocalSeries.analyticOnNhd.mono hsub
  have hprod : AnalyticOnNhd ℂ (fun z => CayleyBridge.F z * reciprocalSum z)
      CayleyBridge.unitDisk := CayleyBridge.analyticOnNhd_F.mul hsum
  have heq : (fun z => CayleyBridge.F z * reciprocalSum z) =ᶠ[𝓝 0] (fun _ => (1 : ℂ)) := by
    have hne : ∀ᶠ z in 𝓝 (0 : ℂ), CayleyBridge.F z ≠ 0 :=
      (CayleyBridge.analyticOnNhd_F 0 CayleyBridge.zero_mem_unitDisk).continuousAt.eventually_ne
        (by rw [CayleyBridge.F_zero]; norm_num)
    filter_upwards [reciprocalSum_eventually, hne] with z hz hn
    rw [hz, mul_inv_cancel₀ hn]
  exact hprod.eqOn_of_preconnected_of_eventuallyEq analyticOnNhd_const
    (convex_ball (0 : ℂ) 1).isPreconnected CayleyBridge.zero_mem_unitDisk heq

theorem RH_OF_RECIPROCAL_RADIUS (hradius : 1 ≤ reciprocalSeries.radius) :
    RiemannHypothesis := by
  apply CayleyBridge.RH_OF_CAYLEY_NONZERO
  intro z hz hzero
  have h := cayley_mul_reciprocalSum hradius z hz
  rw [hzero, zero_mul] at h
  exact zero_ne_one h

/-- Explicit projection/readout realization of the actual reciprocal coefficients. -/
def ProjectionXiRealization (E : Type*) [NormedAddCommGroup E] [InnerProductSpace ℝ E] : Prop :=
  ∃ (v₀ : E) (w u : ℕ → E),
    (∀ n, w n ≠ 0) ∧
    (∀ n, reciprocalCoeff n = (inner ℝ (u n) (Projection.trajectory w v₀ n) : ℂ)) ∧
    (∀ ε : ℝ, 0 < ε → ∃ C : ℝ, 0 < C ∧
      ∀ n : ℕ, ‖u n‖ ≤ C * Real.exp (ε * n))

/-- The inherited energy bound transfers growth control to the actual coefficients. -/
theorem reciprocalCoeff_subexp_of_realization
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (h : ProjectionXiRealization E) :
    ∀ ε : ℝ, 0 < ε → ∃ C : ℝ, 0 < C ∧
      ∀ n : ℕ, ‖reciprocalCoeff n‖ ≤ C * Real.exp (ε * n) := by
  obtain ⟨v₀, w, u, hw, hid, hgrowth⟩ := h
  intro ε hε
  obtain ⟨C, hC, hbound⟩ := hgrowth ε hε
  refine ⟨C * (‖v₀‖ + 1), mul_pos hC (by positivity), ?_⟩
  intro n
  calc
    ‖reciprocalCoeff n‖ = |inner ℝ (u n) (Projection.trajectory w v₀ n)| := by
      rw [hid n, Complex.norm_real, Real.norm_eq_abs]
    _ ≤ ‖u n‖ * ‖v₀‖ := Projection.readout_bound w v₀ (u n) hw n
    _ ≤ (C * Real.exp (ε * n)) * ‖v₀‖ :=
      mul_le_mul_of_nonneg_right (hbound n) (norm_nonneg v₀)
    _ ≤ (C * (‖v₀‖ + 1)) * Real.exp (ε * n) := by
      nlinarith [Real.exp_pos (ε * n)]

/-- The complete projection chain concludes Mathlib's literal RH. -/
theorem RH_OF_PROJECTION_REALIZATION
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (h : ProjectionXiRealization E) : RiemannHypothesis := by
  apply RH_OF_RECIPROCAL_RADIUS
  rw [reciprocalSeries_eq_ofScalars]
  exact radius_ge_one_of_subexp reciprocalCoeff (reciprocalCoeff_subexp_of_realization h)

end
end FiveInduction.ProjectionInput
