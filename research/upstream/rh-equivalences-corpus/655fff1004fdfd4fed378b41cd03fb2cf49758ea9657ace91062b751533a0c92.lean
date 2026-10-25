import AWPI.PhiRH.CanonicalJetAudit
import Mathlib.NumberTheory.LSeries.Nonvanishing

namespace AWPI.PhiRH.HistoricalSourceStandaloneClean

open AWPI.PhiRH
open AWPI.PhiRH.MathlibBridge
open AWPI.PhiRH.JetLeafDisassembly
open AWPI.PhiRH.LimitCoreDisassembly
open AWPI.PhiRH.CriticalLineCoreDisassembly
open AWPI.PhiRH.CanonicalJetAudit
open AWPI.PhiRH.RocqPortModel

/-- Canonical exact plus energy on the already-audited nonzero jet. -/
noncomputable def canonicalPlusEnergy (rho : ℂ) : ℝ :=
  (jetPlus canonicalPlusJetScale canonicalTransverseJet rho) ^ 2

/-- Literal forward dyadic gain. -/
noncomputable def canonicalPlusGain (rho : ℂ) : ℝ :=
  scale2 (2 * (rho.re - (1 / 2 : ℝ)))

/-- Finite plus defect attached to a proposed finite-energy approximation. -/
noncomputable def finitePlusDefect
    (finitePlusEnergy : ℕ → ℂ → ℝ) (n : ℕ) (rho : ℂ) : ℝ :=
  canonicalPlusGain rho * finitePlusEnergy n rho - finitePlusEnergy n rho

/-- Tail plus defect attached to a proposed tail-energy term. -/
noncomputable def plusTailDefect
    (plusTailEnergy : ℕ → ℂ → ℝ) (n : ℕ) (rho : ℂ) : ℝ :=
  canonicalPlusGain rho * plusTailEnergy n rho - plusTailEnergy n rho

/-- Exact energy split into finite and tail pieces. -/
def PlusEnergySplit
    (finitePlusEnergy plusTailEnergy : ℕ → ℂ → ℝ) : Prop :=
  ∀ (n : ℕ) (rho : ℂ), NontrivialZetaZero rho →
    canonicalPlusEnergy rho = finitePlusEnergy n rho + plusTailEnergy n rho

/-- Tail defect controlled by a scalar remainder. -/
def PlusTailControl
    (plusTailEnergy : ℕ → ℂ → ℝ) (uniformRemainder : ℕ → ℝ) : Prop :=
  ∀ (n : ℕ) (rho : ℂ), NontrivialZetaZero rho →
    plusTailDefect plusTailEnergy n rho ≤ uniformRemainder n

/-- Scalar remainder can be made arbitrarily small from above. -/
def UniformRemainderArbitrarilySmall (uniformRemainder : ℕ → ℝ) : Prop :=
  ∀ eps : ℝ, 0 < eps → ∃ n : ℕ, uniformRemainder n ≤ eps

/-- Literal finite prefix sum. -/
def scalarPrefixSum : ℕ → (ℕ → ℝ) → ℝ
  | 0, _ => 0
  | n + 1, f => scalarPrefixSum n f + f n

/-- Telescoping of successive potential differences. -/
theorem scalarPrefixSum_difference (P : ℕ → ℝ) (n : ℕ) :
    scalarPrefixSum n (fun k => P (k + 1) - P k) = P n - P 0 := by
  induction n with
  | zero => simp [scalarPrefixSum]
  | succ n ih =>
      simp [scalarPrefixSum, ih]

/-- Historical negative-square cell potential. -/
def plusPotential (plusCell : ℕ → ℂ → ℝ) (n : ℕ) (rho : ℂ) : ℝ :=
  -(plusCell n rho) ^ 2

/-- Historical local cell flux. -/
def plusLocalFlux (plusCell : ℕ → ℂ → ℝ) (k : ℕ) (rho : ℂ) : ℝ :=
  plusPotential plusCell (k + 1) rho - plusPotential plusCell k rho

/-- Standalone historical plus source: exactly five explicit fields. -/
def HistoricalPlusPointwiseSource
    (finitePlusEnergy plusTailEnergy : ℕ → ℂ → ℝ)
    (uniformRemainder : ℕ → ℝ)
    (plusCell : ℕ → ℂ → ℝ) : Prop :=
  PlusEnergySplit finitePlusEnergy plusTailEnergy ∧
  (∀ rho : ℂ, NontrivialZetaZero rho → plusCell 0 rho = 0) ∧
  (∀ (n : ℕ) (rho : ℂ), NontrivialZetaZero rho →
    finitePlusDefect finitePlusEnergy n rho =
      scalarPrefixSum n (fun k => plusLocalFlux plusCell k rho)) ∧
  PlusTailControl plusTailEnergy uniformRemainder ∧
  UniformRemainderArbitrarilySmall uniformRemainder

/-- The finite defect is nonpositive by telescoping the negative-square cell potential. -/
theorem finitePlusPassivity_of_historicalSource
    (finitePlusEnergy plusTailEnergy : ℕ → ℂ → ℝ)
    (uniformRemainder : ℕ → ℝ)
    (plusCell : ℕ → ℂ → ℝ)
    (h : HistoricalPlusPointwiseSource
      finitePlusEnergy plusTailEnergy uniformRemainder plusCell) :
    ∀ (n : ℕ) (rho : ℂ), NontrivialZetaZero rho →
      finitePlusDefect finitePlusEnergy n rho ≤ 0 := by
  rcases h with ⟨_hSplit, hzero, hflux, _hTail, _hSmall⟩
  intro n rho hz
  have hdef :
      finitePlusDefect finitePlusEnergy n rho = -(plusCell n rho) ^ 2 := by
    calc
      finitePlusDefect finitePlusEnergy n rho =
          scalarPrefixSum n (fun k => plusLocalFlux plusCell k rho) := hflux n rho hz
      _ = plusPotential plusCell n rho - plusPotential plusCell 0 rho := by
        simpa [plusLocalFlux] using
          scalarPrefixSum_difference (fun k => plusPotential plusCell k rho) n
      _ = -(plusCell n rho) ^ 2 := by
        simp [plusPotential, hzero rho hz]
  rw [hdef]
  exact neg_nonpos.mpr (sq_nonneg _)

/-- The five historical source fields imply exact plus passivity directly.
    This proof does not import or use the v0.2.12 factorization theorem. -/
theorem canonicalPlusPassivity_of_historicalSource
    (finitePlusEnergy plusTailEnergy : ℕ → ℂ → ℝ)
    (uniformRemainder : ℕ → ℝ)
    (plusCell : ℕ → ℂ → ℝ)
    (h : HistoricalPlusPointwiseSource
      finitePlusEnergy plusTailEnergy uniformRemainder plusCell) :
    PlusPassivityCore canonicalPlusJetScale canonicalTransverseJet := by
  rcases h with ⟨hSplit, hzero, hflux, hTail, hSmall⟩
  intro rho hz
  have hFinite : ∀ n : ℕ, finitePlusDefect finitePlusEnergy n rho ≤ 0 := by
    intro n
    exact finitePlusPassivity_of_historicalSource
      finitePlusEnergy plusTailEnergy uniformRemainder plusCell
      ⟨hSplit, hzero, hflux, hTail, hSmall⟩ n rho hz
  by_contra hnot
  have hpos : 0 < plusExactDefect canonicalPlusJetScale canonicalTransverseJet rho :=
    lt_of_not_ge hnot
  have heps : 0 < plusExactDefect canonicalPlusJetScale canonicalTransverseJet rho / 2 := by
    linarith
  obtain ⟨n, hrem⟩ := hSmall
    (plusExactDefect canonicalPlusJetScale canonicalTransverseJet rho / 2) heps
  have hs := hSplit n rho hz
  have hdecomp :
      plusExactDefect canonicalPlusJetScale canonicalTransverseJet rho =
        finitePlusDefect finitePlusEnergy n rho +
          plusTailDefect plusTailEnergy n rho := by
    calc
      plusExactDefect canonicalPlusJetScale canonicalTransverseJet rho =
          canonicalPlusGain rho * canonicalPlusEnergy rho - canonicalPlusEnergy rho := by
            rfl
      _ = canonicalPlusGain rho *
            (finitePlusEnergy n rho + plusTailEnergy n rho) -
            (finitePlusEnergy n rho + plusTailEnergy n rho) := by
            rw [hs]
      _ = finitePlusDefect finitePlusEnergy n rho +
            plusTailDefect plusTailEnergy n rho := by
            unfold finitePlusDefect plusTailDefect
            ring
  have hfin := hFinite n
  have htail := hTail n rho hz
  linarith

/-- Direct Mathlib reflection of a literal nontrivial zeta zero. -/
theorem nontrivialZetaZero_one_sub_clean
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

/-- Existence of a standalone five-field historical source. -/
def ExistsHistoricalPlusPointwiseSource : Prop :=
  ∃ (finitePlusEnergy plusTailEnergy : ℕ → ℂ → ℝ)
    (uniformRemainder : ℕ → ℝ)
    (plusCell : ℕ → ℂ → ℝ),
      HistoricalPlusPointwiseSource
        finitePlusEnergy plusTailEnergy uniformRemainder plusCell

/-- The standalone five-field source implies literal Mathlib RH directly. -/
theorem mathlibRH_of_existsHistoricalPlusPointwiseSource
    (h : ExistsHistoricalPlusPointwiseSource) : RiemannHypothesis := by
  rcases h with ⟨finiteE, tailE, rem, cell, hsrc⟩
  have hPass : PlusPassivityCore canonicalPlusJetScale canonicalTransverseJet :=
    canonicalPlusPassivity_of_historicalSource finiteE tailE rem cell hsrc
  unfold RiemannHypothesis
  intro rho hz htrivial hne1
  have hnt : NontrivialZetaZero rho := ⟨hz, htrivial, hne1⟩
  have hleft : rho.re ≤ (1 / 2 : ℝ) :=
    (plusPassivity_pointwise_iff_re_le_half
      canonicalPlusJetScale canonicalTransverseJet rho
      (canonicalPlusJet_nonzero rho hnt)).1 (hPass rho hnt)
  have href : NontrivialZetaZero (1 - rho) := nontrivialZetaZero_one_sub_clean hnt
  have hleftRef : (1 - rho).re ≤ (1 / 2 : ℝ) :=
    (plusPassivity_pointwise_iff_re_le_half
      canonicalPlusJetScale canonicalTransverseJet (1 - rho)
      (canonicalPlusJet_nonzero (1 - rho) href)).1 (hPass (1 - rho) href)
  have hright : (1 / 2 : ℝ) ≤ rho.re := by
    simp at hleftRef
    linarith
  exact le_antisymm hleft hright

noncomputable def zeroFinitePlusEnergy : ℕ → ℂ → ℝ := fun _ _ => 0
noncomputable def exactPlusTailEnergy : ℕ → ℂ → ℝ := fun _ rho => canonicalPlusEnergy rho
def zeroPlusCell : ℕ → ℂ → ℝ := fun _ _ => 0

/-- Exact energy placed entirely in the tail gives the exact defect. -/
theorem exactPlusTailDefect_eq_exactPlusDefect (n : ℕ) (rho : ℂ) :
    plusTailDefect exactPlusTailEnergy n rho =
      plusExactDefect canonicalPlusJetScale canonicalTransverseJet rho := by
  calc
    plusTailDefect exactPlusTailEnergy n rho =
        canonicalPlusGain rho * canonicalPlusEnergy rho - canonicalPlusEnergy rho := by
          rfl
    _ = plusExactDefect canonicalPlusJetScale canonicalTransverseJet rho := by
          rfl

/-- Zero cell has zero local flux and prefix sum. -/
theorem scalarPrefixSum_zero (n : ℕ) :
    scalarPrefixSum n (fun _ => (0 : ℝ)) = 0 := by
  induction n with
  | zero => simp [scalarPrefixSum]
  | succ n ih => simp [scalarPrefixSum, ih]

/-- RH gives canonical plus passivity directly from the critical-line equality. -/
theorem canonicalPlusPassivity_of_mathlibRH
    (hRH : RiemannHypothesis) :
    PlusPassivityCore canonicalPlusJetScale canonicalTransverseJet := by
  intro rho hz
  have heq : rho.re = (1 / 2 : ℝ) := hRH rho hz.1 hz.2.1 hz.2.2
  exact (plusPassivity_pointwise_iff_re_le_half
    canonicalPlusJetScale canonicalTransverseJet rho
    (canonicalPlusJet_nonzero rho hz)).2 (le_of_eq heq)

/-- Reverse audit: RH gives a trivial five-field source certificate. -/
theorem existsHistoricalPlusPointwiseSource_of_mathlibRH
    (hRH : RiemannHypothesis) : ExistsHistoricalPlusPointwiseSource := by
  let rem : ℕ → ℝ := fun _ => 0
  have hPass : PlusPassivityCore canonicalPlusJetScale canonicalTransverseJet :=
    canonicalPlusPassivity_of_mathlibRH hRH
  refine ⟨zeroFinitePlusEnergy, exactPlusTailEnergy, rem, zeroPlusCell, ?_⟩
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · intro n rho hz
    simp [zeroFinitePlusEnergy, exactPlusTailEnergy]
  · intro rho hz
    rfl
  · intro n rho hz
    simp [finitePlusDefect, zeroFinitePlusEnergy, plusLocalFlux, plusPotential,
      zeroPlusCell, scalarPrefixSum_zero]
  · intro n rho hz
    have hp := hPass rho hz
    rw [exactPlusTailDefect_eq_exactPlusDefect]
    simpa [rem] using hp
  · intro eps heps
    exact ⟨0, le_of_lt heps⟩

/-- Standalone transitive audit equivalence. -/
theorem existsHistoricalPlusPointwiseSource_iff_mathlibRH :
    ExistsHistoricalPlusPointwiseSource ↔ RiemannHypothesis := by
  constructor
  · exact mathlibRH_of_existsHistoricalPlusPointwiseSource
  · exact existsHistoricalPlusPointwiseSource_of_mathlibRH

end AWPI.PhiRH.HistoricalSourceStandaloneClean
