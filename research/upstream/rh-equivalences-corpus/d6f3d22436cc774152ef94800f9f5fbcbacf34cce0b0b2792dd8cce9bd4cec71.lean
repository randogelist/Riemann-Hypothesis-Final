import AWPI.PhiRH.RawConcreteFrontier

namespace AWPI.PhiRH.ScalarConcreteFrontier

open AWPI.PhiRH
open AWPI.PhiRH.MathlibBridge
open AWPI.PhiRH.RocqPortModel
open AWPI.PhiRH.CriticalLineCoreDisassembly
open AWPI.PhiRH.SingleConcreteFrontier
open AWPI.PhiRH.RawConcreteFrontier
open AWPI.PhiRH.LimitCoreDisassembly
open AWPI.PhiRH.CanonicalJetAudit
open AWPI.PhiRH.JetLeafDisassembly
open AWPI.PhiRH.TailDecayDisassembly

/-- The scalar dyadic core left after removing the positive canonical jet
    factor and the vanishing terminal-Phi/KQ tail. -/
def ScalarDyadicCore : Prop :=
  ∀ rho : ℂ, NontrivialZetaZero rho →
    scale2 (2 * (rho.re - (1 / 2 : ℝ))) ≤ 1

/-- The scalar dyadic inequality is exactly the left critical half. -/
theorem scalarDyadicCore_iff_leftCriticalHalf :
    ScalarDyadicCore ↔ LeftCriticalHalf := by
  constructor
  · intro h rho hz
    have hgain := h rho hz
    have hexp : 2 * (rho.re - (1 / 2 : ℝ)) ≤ 0 := by
      by_contra hnot
      have hpos : 0 < 2 * (rho.re - (1 / 2 : ℝ)) := lt_of_not_ge hnot
      have hstrict :
          scale2 0 < scale2 (2 * (rho.re - (1 / 2 : ℝ))) :=
        scale2_strictMono_proved hpos
      rw [scale2_at_zero] at hstrict
      linarith
    linarith
  · intro h rho hz
    have hre := h rho hz
    have hexp : 2 * (rho.re - (1 / 2 : ℝ)) ≤ 0 := by
      linarith
    have hmono := scale2_strictMono_proved.monotone hexp
    simpa only [scale2_at_zero] using hmono

/-- The raw v0.2.15 frontier implies the scalar dyadic core.  No RH theorem is
    used here: we pass through the already-proved raw-frontier -> plus-passivity
    reduction, then extract the gain inequality pointwise. -/
theorem scalarDyadicCore_of_rawActualPlusKQFrontier
    (hRaw : RawActualPlusKQFrontier) : ScalarDyadicCore := by
  have hLimit : ActualPlusKQLimitCore :=
    rawActualPlusKQFrontier_iff_actualPlusKQLimitCore.mp hRaw
  have hPass : PlusPassivityCore canonicalPlusJetScale canonicalTransverseJet :=
    actualPlusKQLimitCore_iff_plusPassivity.mp hLimit
  have hLeft : LeftCriticalHalf :=
    (plusPassivityCore_iff_leftCriticalHalf
      canonicalPlusJetScale canonicalTransverseJet canonicalPlusJet_nonzero).1 hPass
  exact scalarDyadicCore_iff_leftCriticalHalf.mpr hLeft

/-- Conversely, the scalar dyadic inequality makes the raw frontier immediate:
    its left side is nonpositive, while the explicit terminal-Phi expression is
    a square and therefore nonnegative. -/
theorem rawActualPlusKQFrontier_of_scalarDyadicCore
    (hScalar : ScalarDyadicCore) : RawActualPlusKQFrontier := by
  intro n rho hz
  have hgain : scale2 (2 * (rho.re - (1 / 2 : ℝ))) ≤ 1 := hScalar rho hz
  have hnorm : 0 ≤ (rhoNorm2 rho) ^ 2 := sq_nonneg _
  have hlhs :
      scale2 (2 * (rho.re - (1 / 2 : ℝ))) * (rhoNorm2 rho) ^ 2 -
          (rhoNorm2 rho) ^ 2 ≤ 0 := by
    nlinarith
  have hrhs :
      0 ≤
        (Real.cos (dyadicPhase rho.im) * phiCellRe n 1 rho.re rho.im +
          Real.sin (dyadicPhase rho.im) * phiCellIm n 1 rho.re rho.im) ^ 2 :=
    sq_nonneg _
  exact le_trans hlhs hrhs

/-- The raw concrete frontier and the scalar dyadic core have exactly the same
    logical content. -/
theorem rawActualPlusKQFrontier_iff_scalarDyadicCore :
    RawActualPlusKQFrontier ↔ ScalarDyadicCore := by
  constructor
  · exact scalarDyadicCore_of_rawActualPlusKQFrontier
  · exact rawActualPlusKQFrontier_of_scalarDyadicCore

/-- Genuine zeta reflection collapses the one-sided scalar dyadic core to
    Mathlib's literal Riemann Hypothesis. -/
theorem scalarDyadicCore_iff_mathlibRH :
    ScalarDyadicCore ↔ RiemannHypothesis := by
  rw [scalarDyadicCore_iff_leftCriticalHalf]
  constructor
  · intro hleft
    unfold RiemannHypothesis
    intro rho hz htrivial hne1
    have hnt : NontrivialZetaZero rho := ⟨hz, htrivial, hne1⟩
    have hl : rho.re ≤ (1 / 2 : ℝ) := hleft rho hnt
    have href : NontrivialZetaZero (1 - rho) := nontrivialZetaZero_one_sub hnt
    have hlref : (1 - rho : ℂ).re ≤ (1 / 2 : ℝ) := hleft (1 - rho) href
    have hr : (1 / 2 : ℝ) ≤ rho.re := by
      simp at hlref
      linarith
    exact le_antisymm hl hr
  · intro hRH rho hz
    exact le_of_eq (hRH rho hz.1 hz.2.1 hz.2.2)

end AWPI.PhiRH.ScalarConcreteFrontier
