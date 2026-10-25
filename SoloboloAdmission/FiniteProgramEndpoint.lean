import SoloboloAdmission.FiniteProgram
import SoloboloAdmission.ResidualLimits
import SoloboloAdmission.ResidualNonvanishing
import SoloboloAdmission.NativeODE

/-!
# One actual residual condition for a raw finite program

`FiniteProgram` contains only a natural number and two finite rational syntax
trees. Its emitted packets are positive at every stage by `emit_valid`.
Here their rational ODE coefficients are proved analytic on the slit plane.

The ONE remaining analytic input is locally uniform convergence of the ACTUAL
theta residuals to zero. There is no separately assumed limit coefficient,
holomorphic gluing, actual-RH oracle, or proof field in the raw program.

This is a conditional forward RH theorem. The analytic condition is not a
Boolean check; no program satisfying it, finite checker for it, or converse
finite-representability theorem is constructed here. Native checks are pending.
-/

set_option autoImplicit false

noncomputable section

namespace SoloboloAdmission

open Filter
open scoped Topology BigOperators

/-- A positive-contraction node can have denominator zeros only on the cut.
The endpoint values of the node, including zero, are covered explicitly. -/
theorem rationalNode_denominator_ne_zero
    (t : ℚ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1)
    (z : ℂ) (hz : z ∈ Complex.slitPlane) :
    (t : ℂ) * z + (9 / 4 : ℂ) * (1 - (t : ℂ)) ≠ 0 := by
  by_cases ht : t = 0
  · norm_num [ht]
  have htpos : (0 : ℚ) < t := lt_of_le_of_ne ht0 (Ne.symm ht)
  have htrpos : (0 : ℝ) < (t : ℝ) := by exact_mod_cast htpos
  have htr1 : (t : ℝ) ≤ 1 := by exact_mod_cast ht1
  have htrne : (t : ℝ) ≠ 0 := ne_of_gt htrpos
  intro hden
  have hreal : (t : ℝ) * z.re + (9 / 4 : ℝ) * (1 - (t : ℝ)) = 0 := by
    have h := congrArg Complex.re hden
    norm_num [Complex.mul_re] at h
    exact h
  have himag : (t : ℝ) * z.im = 0 := by
    have h := congrArg Complex.im hden
    norm_num [Complex.mul_im] at h
    exact h
  have hzIm : z.im = 0 := (mul_eq_zero.mp himag).resolve_left htrne
  rcases Complex.mem_slitPlane_iff.mp hz with hzRe | hzImNe
  · have hfirst : 0 < (t : ℝ) * z.re := mul_pos htrpos hzRe
    have hsecond : 0 ≤ (9 / 4 : ℝ) * (1 - (t : ℝ)) :=
      mul_nonneg (by norm_num) (sub_nonneg.mpr htr1)
    linarith
  · exact hzImNe hzIm

/-- Finite packet validity discharges every denominator needed for analytic
rational ODE coefficients. No actual-theta calibration is used. -/
theorem rationalODECoefficient_analytic {d : ℕ}
    (P : RationalPacket d) (hP : P.Valid) :
    AnalyticOnNhd ℂ (rationalODECoefficient P) Complex.slitPlane := by
  intro z hz
  have hsum : AnalyticAt ℂ
      (fun w : ℂ => ∑ i : Fin d,
        (P.mass i : ℂ) /
          ((P.node i : ℂ) * w + (9 / 4 : ℂ) * (1 - (P.node i : ℂ)))) z := by
    apply Finset.analyticAt_fun_sum
    intro i hi
    have hnum : AnalyticAt ℂ (fun _ : ℂ => (P.mass i : ℂ)) z :=
      analyticAt_const
    have hden : AnalyticAt ℂ
        (fun w : ℂ =>
          (P.node i : ℂ) * w + (9 / 4 : ℂ) * (1 - (P.node i : ℂ))) z :=
      (analyticAt_const.mul analyticAt_id).add analyticAt_const
    exact hnum.div hden
      (rationalNode_denominator_ne_zero (P.node i) (hP i).1 (hP i).2.1 z hz)
  exact hsum.neg

/-- The finite syntax itself derives analyticity at every emitted stage. -/
theorem FiniteProgram.coefficient_analytic (G : FiniteProgram) (n : ℕ) :
    AnalyticOnNhd ℂ (rationalODECoefficient (G.emit n)) Complex.slitPlane :=
  rationalODECoefficient_analytic (G.emit n) (G.emit_valid n)

/-- The literal division-free error against the actual entire theta. -/
def FiniteProgram.actualResidual (G : FiniteProgram) (n : ℕ) (z : ℂ) : ℂ :=
  deriv AWPIRH.theta z + rationalODECoefficient (G.emit n) z * AWPIRH.theta z

/-- ONE analytic obligation: actual residuals tend locally uniformly to zero
on the whole slit plane. It is external to the finite raw data, not an
implemented Boolean acceptance predicate or a claimed inhabited condition. -/
def ActualUniformResidualCondition (G : FiniteProgram) : Prop :=
  TendstoLocallyUniformlyOn G.actualResidual (fun _ : ℂ => 0)
    atTop Complex.slitPlane

/-- No coefficient limit or analytic gluing input is needed: a hypothetical
zero has finite order, contradicted by convergence of residual derivatives. -/
theorem FiniteProgram.theta_nonvanishing_of_uniformResidual
    (G : FiniteProgram) (hActual : ActualUniformResidualCondition G) :
    ∀ z ∈ Complex.slitPlane, AWPIRH.theta z ≠ 0 := by
  apply entire_nonvanishing_of_locallyUniform_residual
    AWPIRH.theta_entire AWPIRH.theta_one_ne_zero Complex.isOpen_slitPlane
    (fun n => G.coefficient_analytic n)
  exact hActual

/-- All analytic hypotheses besides one actual residual-limit condition
have been discharged by the finite program and the literal theta sources.
This theorem does not prove that the condition holds for any finite program. -/
theorem FiniteProgram.nativeRH_of_uniformResidual
    (G : FiniteProgram) (hActual : ActualUniformResidualCondition G) :
    _root_.RiemannHypothesis := by
  have hnv := G.theta_nonvanishing_of_uniformResidual hActual
  apply AngularMaster.native_RH_iff_theta_zeros_nonpositive.mpr
  intro z hz
  have hnot : z ∉ Complex.slitPlane := by
    intro hslit
    exact hnv z hslit hz
  have hre : z.re ≤ 0 := by
    by_contra hn
    have hp : 0 < z.re := lt_of_not_ge hn
    exact hnot (Complex.mem_slitPlane_iff.mpr (Or.inl hp))
  have him : z.im = 0 := by
    by_contra hn
    exact hnot (Complex.mem_slitPlane_iff.mpr (Or.inr hn))
  exact ⟨him, hre⟩

/-- Existence of a raw finite program WITH the external actual analytic
property suffices. This existential is not finite-checker acceptance. -/
theorem exists_finiteProgram_uniformResidual_implies_RH
    (h : ∃ G : FiniteProgram, ActualUniformResidualCondition G) :
    _root_.RiemannHypothesis := by
  obtain ⟨G, hG⟩ := h
  exact G.nativeRH_of_uniformResidual hG

end SoloboloAdmission
