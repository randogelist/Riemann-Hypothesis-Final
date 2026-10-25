import AWPI.PhiRH.SingleConcreteFrontier

namespace AWPI.PhiRH.RawConcreteFrontier

open AWPI.PhiRH
open AWPI.PhiRH.MathlibBridge
open AWPI.PhiRH.RocqPortModel
open AWPI.PhiRH.JetLeafDisassembly
open AWPI.PhiRH.AncillaryJetCoreDisassembly
open AWPI.PhiRH.CanonicalJetAudit
open AWPI.PhiRH.LimitCoreDisassembly
open AWPI.PhiRH.TailDecayDisassembly
open AWPI.PhiRH.SingleConcreteFrontier

/-- Under the canonical audit normalization, the common transverse jet is
    literally the real-coordinate squared norm of the spectral point. -/
@[simp] theorem canonicalTransverseJet_eq_rhoNorm2 (rho : ℂ) :
    canonicalTransverseJet rho = rhoNorm2 rho := by
  simp [canonicalTransverseJet, concretePhiTransverseJet,
    shiftedPhiNorm2, canonicalShiftedPhiValue]

/-- Consequently the canonical plus jet is exactly `rhoNorm2`. -/
@[simp] theorem canonicalPlusJet_eq_rhoNorm2 (rho : ℂ) :
    jetPlus canonicalPlusJetScale canonicalTransverseJet rho = rhoNorm2 rho := by
  simp [jetPlus, canonicalPlusJetScale]

/-- The exact plus defect with the canonical jet, with all jet wrappers removed. -/
theorem canonicalPlusExactDefect_formula (rho : ℂ) :
    plusExactDefect canonicalPlusJetScale canonicalTransverseJet rho =
      scale2 (2 * (rho.re - (1 / 2 : ℝ))) * (rhoNorm2 rho) ^ 2 -
        (rhoNorm2 rho) ^ 2 := by
  simp [plusExactDefect]

/-- The actual KQ plus source is the dyadic rotation applied to the negative
    terminal Phi cell. -/
theorem actualKQPlusSource_eq_terminal_combo
    (n : ℕ) (sigma tau : ℝ) :
    actualKQPlusSource n sigma tau =
      -(Real.cos (dyadicPhase tau) * phiCellRe n 1 sigma tau +
        Real.sin (dyadicPhase tau) * phiCellIm n 1 sigma tau) := by
  unfold actualKQPlusSource AWPI.PhiRH.TailDecayDisassembly.actualKQSourcePair c2Mul
    normalizedDyadicMultiplier actualResidualRe actualResidualIm
  rw [finitePhiShiftResidualRe_eq_neg_terminal,
    finitePhiShiftResidualIm_eq_neg_terminal]
  ring

/-- Squaring removes the harmless global minus sign in the KQ source. -/
theorem actualKQPlusSource_square_eq_terminal_combo_square
    (n : ℕ) (sigma tau : ℝ) :
    actualKQPlusSource n sigma tau * actualKQPlusSource n sigma tau =
      (Real.cos (dyadicPhase tau) * phiCellRe n 1 sigma tau +
        Real.sin (dyadicPhase tau) * phiCellIm n 1 sigma tau) ^ 2 := by
  rw [actualKQPlusSource_eq_terminal_combo]
  ring

/-- The v0.2.14 frontier with both remaining named wrappers expanded.  The
    only inequality left is now written directly using the spectral norm,
    the literal dyadic scale, and the terminal Phi cell. -/
def RawActualPlusKQFrontier : Prop :=
  ∀ (n : ℕ) (rho : ℂ), NontrivialZetaZero rho →
    scale2 (2 * (rho.re - (1 / 2 : ℝ))) * (rhoNorm2 rho) ^ 2 -
        (rhoNorm2 rho) ^ 2 ≤
      (Real.cos (dyadicPhase rho.im) * phiCellRe n 1 rho.re rho.im +
        Real.sin (dyadicPhase rho.im) * phiCellIm n 1 rho.re rho.im) ^ 2

/-- Formula exposure changes no logical content. -/
theorem rawActualPlusKQFrontier_iff_actualPlusKQLimitCore :
    RawActualPlusKQFrontier ↔ ActualPlusKQLimitCore := by
  constructor
  · intro h n rho hz
    rw [canonicalPlusExactDefect_formula,
      actualKQPlusSource_square_eq_terminal_combo_square]
    exact h n rho hz
  · intro h n rho hz
    have hh := h n rho hz
    rw [canonicalPlusExactDefect_formula,
      actualKQPlusSource_square_eq_terminal_combo_square] at hh
    exact hh

/-- Final transitive-clean audit at the raw formula level. -/
theorem rawActualPlusKQFrontier_iff_mathlibRH :
    RawActualPlusKQFrontier ↔ RiemannHypothesis := by
  rw [rawActualPlusKQFrontier_iff_actualPlusKQLimitCore]
  exact actualPlusKQLimitCore_iff_mathlibRH

end AWPI.PhiRH.RawConcreteFrontier
