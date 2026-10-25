import AWPI.PhiRH.CanonicalJetAudit
import AWPI.PhiRH.TailDecayDisassembly
import Mathlib.NumberTheory.LSeries.Nonvanishing

namespace AWPI.PhiRH.SingleConcreteFrontier

open AWPI.PhiRH
open AWPI.PhiRH.MathlibBridge
open AWPI.PhiRH.JetLeafDisassembly
open AWPI.PhiRH.LimitCoreDisassembly
open AWPI.PhiRH.CriticalLineCoreDisassembly
open AWPI.PhiRH.CanonicalJetAudit
open AWPI.PhiRH.TailDecayDisassembly

/-- The single concrete remaining forward inequality.  All functions in this
    statement are fixed: the canonical audited plus jet and the literal KQ
    source obtained from the finite-Phi shifted residual. -/
def ActualPlusKQLimitCore : Prop :=
  ∀ (n : ℕ) (rho : ℂ), NontrivialZetaZero rho →
    plusExactDefect canonicalPlusJetScale canonicalTransverseJet rho ≤
      actualKQPlusSource n rho.re rho.im *
        actualKQPlusSource n rho.re rho.im

/-- Direct Mathlib reflection of a literal nontrivial zeta zero.  This is
    repeated here deliberately so the single-frontier theorem does not depend
    on any historical-source certificate. -/
theorem nontrivialZetaZero_one_sub
    {rho : ℂ} (hz : NontrivialZetaZero rho) :
    NontrivialZetaZero (1 - rho) := by
  have hrho0 : rho ≠ 0 := nontrivialZetaZero_ne_zero hz
  have hGamma : rho.Gammaℝ ≠ 0 := by
    intro hGamma0
    rcases Complex.Gammaℝ_eq_zero_iff.mp hGamma0 with ⟨n, hn⟩
    cases n with
    | zero =>
        apply hrho0
        simpa using hn
    | succ n =>
        apply hz.2.1
        refine ⟨n, ?_⟩
        calc
          rho = -(2 * (↑(Nat.succ n) : ℂ)) := hn
          _ = -2 * ((n : ℂ) + 1) := by
            push_cast
            ring
  have hdef := riemannZeta_def_of_ne_zero hrho0
  rw [hz.1] at hdef
  have hcomp : completedRiemannZeta rho = 0 := by
    have hdiv : completedRiemannZeta rho / rho.Gammaℝ = 0 := hdef.symm
    exact (div_eq_zero_iff.mp hdiv).resolve_right hGamma
  have hrefComp : completedRiemannZeta (1 - rho) = 0 := by
    rw [completedRiemannZeta_one_sub rho]
    exact hcomp
  have href0 : 1 - rho ≠ 0 := by
    intro h
    apply hz.2.2
    calc
      rho = 1 - (1 - rho) := by ring
      _ = 1 - 0 := by rw [h]
      _ = 1 := by ring
  have hrefZeta : riemannZeta (1 - rho) = 0 := by
    rw [riemannZeta_def_of_ne_zero href0, hrefComp, zero_div]
  have hrefTrivial : ¬ ∃ n : ℕ, 1 - rho = -2 * ((n : ℂ) + 1) := by
    rintro ⟨n, hn⟩
    have hreEq := congrArg Complex.re hn
    have hn0 : (0 : ℝ) ≤ (n : ℝ) := by positivity
    have hre : 1 ≤ rho.re := by
      simp at hreEq
      linarith
    exact (riemannZeta_ne_zero_of_one_le_re hre) hz.1
  have href1 : 1 - rho ≠ 1 := by
    intro h
    apply hrho0
    calc
      rho = 1 - (1 - rho) := by ring
      _ = 1 - 1 := by rw [h]
      _ = 0 := by ring
  exact ⟨hrefZeta, hrefTrivial, href1⟩

/-- Standard zero-free-half-plane/reflection consequence: a literal
    nontrivial zeta zero has positive real part. -/
theorem nontrivialZetaZero_re_pos
    {rho : ℂ} (hz : NontrivialZetaZero rho) : 0 < rho.re := by
  by_contra hnot
  have hre0 : rho.re ≤ 0 := le_of_not_gt hnot
  have href : NontrivialZetaZero (1 - rho) := nontrivialZetaZero_one_sub hz
  have hre1 : 1 ≤ (1 - rho : ℂ).re := by
    simp
    linarith
  exact (riemannZeta_ne_zero_of_one_le_re hre1) href.1

/-- The literal plus KQ squared tail can be made arbitrarily small at every
    nontrivial zeta zero.  This uses only the already-kernelized terminal-Phi
    decay and the standard positive-real-part theorem above. -/
theorem actualPlusKQSquare_arbitrarily_small
    (rho : ℂ) (hz : NontrivialZetaZero rho)
    (eps : ℝ) (heps : 0 < eps) :
    ∃ n : ℕ,
      actualKQPlusSource n rho.re rho.im *
        actualKQPlusSource n rho.re rho.im ≤ eps := by
  rcases jointTailDecay_of_positiveRealPart rho
      (nontrivialZetaZero_re_pos hz) eps heps with ⟨n, hp, _hm⟩
  exact ⟨n, hp⟩

/-- The single concrete KQ-limit inequality is exactly plus passivity, because
    the literal KQ tail tends to zero. -/
theorem actualPlusKQLimitCore_iff_plusPassivity :
    ActualPlusKQLimitCore ↔
      PlusPassivityCore canonicalPlusJetScale canonicalTransverseJet := by
  constructor
  · intro hLimit rho hz
    by_contra hnot
    have hpos : 0 < plusExactDefect
        canonicalPlusJetScale canonicalTransverseJet rho :=
      lt_of_not_ge hnot
    have heps : 0 < plusExactDefect
        canonicalPlusJetScale canonicalTransverseJet rho / 2 := by
      linarith
    obtain ⟨n, htail⟩ := actualPlusKQSquare_arbitrarily_small rho hz
      (plusExactDefect canonicalPlusJetScale canonicalTransverseJet rho / 2)
      heps
    have hlim := hLimit n rho hz
    linarith
  · intro hPass n rho hz
    have hp := hPass rho hz
    have hsq : 0 ≤ actualKQPlusSource n rho.re rho.im *
        actualKQPlusSource n rho.re rho.im := mul_self_nonneg _
    linarith

/-- One universal plus-passivity direction already implies Mathlib RH by the
    genuine zeta reflection symmetry. -/
theorem mathlibRH_of_canonicalPlusPassivity
    (hPass : PlusPassivityCore canonicalPlusJetScale canonicalTransverseJet) :
    RiemannHypothesis := by
  unfold RiemannHypothesis
  intro rho hz htrivial hne1
  have hnt : NontrivialZetaZero rho := ⟨hz, htrivial, hne1⟩
  have hleft : rho.re ≤ (1 / 2 : ℝ) :=
    (plusPassivity_pointwise_iff_re_le_half
      canonicalPlusJetScale canonicalTransverseJet rho
      (canonicalPlusJet_nonzero rho hnt)).1 (hPass rho hnt)
  have href : NontrivialZetaZero (1 - rho) := nontrivialZetaZero_one_sub hnt
  have hleftRef : (1 - rho).re ≤ (1 / 2 : ℝ) :=
    (plusPassivity_pointwise_iff_re_le_half
      canonicalPlusJetScale canonicalTransverseJet (1 - rho)
      (canonicalPlusJet_nonzero (1 - rho) href)).1 (hPass (1 - rho) href)
  have hright : (1 / 2 : ℝ) ≤ rho.re := by
    simp at hleftRef
    linarith
  exact le_antisymm hleft hright

/-- RH implies the same canonical plus-passivity direction. -/
theorem canonicalPlusPassivity_of_mathlibRH
    (hRH : RiemannHypothesis) :
    PlusPassivityCore canonicalPlusJetScale canonicalTransverseJet := by
  intro rho hz
  have heq : rho.re = (1 / 2 : ℝ) := hRH rho hz.1 hz.2.1 hz.2.2
  exact (plusPassivity_pointwise_iff_re_le_half
    canonicalPlusJetScale canonicalTransverseJet rho
    (canonicalPlusJet_nonzero rho hz)).2 (le_of_eq heq)

/-- Final audit: after all disassembly, the single concrete inequality over the
    actual KQ tail is equivalent to Mathlib's literal Riemann Hypothesis. -/
theorem actualPlusKQLimitCore_iff_mathlibRH :
    ActualPlusKQLimitCore ↔ RiemannHypothesis := by
  constructor
  · intro h
    exact mathlibRH_of_canonicalPlusPassivity
      (actualPlusKQLimitCore_iff_plusPassivity.mp h)
  · intro hRH
    exact actualPlusKQLimitCore_iff_plusPassivity.mpr
      (canonicalPlusPassivity_of_mathlibRH hRH)

end AWPI.PhiRH.SingleConcreteFrontier
