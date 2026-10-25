import AWPI.PhiRH.ReflectionCollapse

namespace AWPI.PhiRH.FactorizationFrontier

open AWPI.PhiRH
open AWPI.PhiRH.MathlibBridge
open AWPI.PhiRH.RocqPortModel
open AWPI.PhiRH.JetLeafDisassembly
open AWPI.PhiRH.LimitCoreDisassembly
open AWPI.PhiRH.CanonicalJetAudit
open AWPI.PhiRH.ReflectionCollapse

/-- Exact plus energy on the canonical nonzero audit jet. -/
noncomputable def canonicalPlusEnergy (rho : ℂ) : ℝ :=
  (jetPlus canonicalPlusJetScale canonicalTransverseJet rho) ^ 2

/-- Forward gain used throughout the plus passivity channel. -/
noncomputable def canonicalPlusGain (rho : ℂ) : ℝ :=
  scale2 (2 * (rho.re - (1 / 2 : ℝ)))

/-- Finite plus defect associated with an explicit finite-energy approximation. -/
noncomputable def finitePlusDefect
    (finitePlusEnergy : ℕ → ℂ → ℝ) (n : ℕ) (rho : ℂ) : ℝ :=
  canonicalPlusGain rho * finitePlusEnergy n rho - finitePlusEnergy n rho

/-- Tail plus defect associated with an explicit tail-energy term. -/
noncomputable def plusTailDefect
    (plusTailEnergy : ℕ → ℂ → ℝ) (n : ℕ) (rho : ℂ) : ℝ :=
  canonicalPlusGain rho * plusTailEnergy n rho - plusTailEnergy n rho

/-- Rocq factorization leaf: exact energy is finite energy plus tail energy. -/
def PlusEnergySplit
    (finitePlusEnergy plusTailEnergy : ℕ → ℂ → ℝ) : Prop :=
  ∀ (n : ℕ) (rho : ℂ), NontrivialZetaZero rho →
    canonicalPlusEnergy rho = finitePlusEnergy n rho + plusTailEnergy n rho

/-- Rocq factorization leaf: every finite plus defect is passive. -/
def FinitePlusPassivity
    (finitePlusEnergy : ℕ → ℂ → ℝ) : Prop :=
  ∀ (n : ℕ) (rho : ℂ), NontrivialZetaZero rho →
    finitePlusDefect finitePlusEnergy n rho ≤ 0

/-- Rocq factorization leaf: the plus tail defect is controlled by one scalar remainder. -/
def PlusTailControl
    (plusTailEnergy : ℕ → ℂ → ℝ) (uniformRemainder : ℕ → ℝ) : Prop :=
  ∀ (n : ℕ) (rho : ℂ), NontrivialZetaZero rho →
    plusTailDefect plusTailEnergy n rho ≤ uniformRemainder n

/-- Rocq factorization leaf: the scalar remainder is arbitrarily small from above. -/
def UniformRemainderArbitrarilySmall (uniformRemainder : ℕ → ℝ) : Prop :=
  ∀ eps : ℝ, 0 < eps → ∃ n : ℕ, uniformRemainder n ≤ eps

/-- The exact plus defect is the sum of the finite and tail defects whenever
    the exact energy splits as finite plus tail energy. -/
theorem exactPlusDefect_eq_finitePlusDefect_add_plusTailDefect
    (finitePlusEnergy plusTailEnergy : ℕ → ℂ → ℝ)
    (hSplit : PlusEnergySplit finitePlusEnergy plusTailEnergy)
    (n : ℕ) (rho : ℂ) (hz : NontrivialZetaZero rho) :
    plusExactDefect canonicalPlusJetScale canonicalTransverseJet rho =
      finitePlusDefect finitePlusEnergy n rho +
        plusTailDefect plusTailEnergy n rho := by
  have hs := hSplit n rho hz
  dsimp [plusExactDefect, canonicalPlusEnergy, canonicalPlusGain,
    finitePlusDefect, plusTailDefect] at hs ⊢
  rw [hs]
  ring

/-- The four one-directional finite-energy factorization leaves imply exact
    plus passivity, without using RH. -/
theorem canonicalPlusPassivity_of_factorization_leaves
    (finitePlusEnergy plusTailEnergy : ℕ → ℂ → ℝ)
    (uniformRemainder : ℕ → ℝ)
    (hSplit : PlusEnergySplit finitePlusEnergy plusTailEnergy)
    (hFinite : FinitePlusPassivity finitePlusEnergy)
    (hTail : PlusTailControl plusTailEnergy uniformRemainder)
    (hSmall : UniformRemainderArbitrarilySmall uniformRemainder) :
    PlusPassivityCore canonicalPlusJetScale canonicalTransverseJet := by
  intro rho hz
  by_contra hnot
  have hpos : 0 < plusExactDefect canonicalPlusJetScale canonicalTransverseJet rho :=
    lt_of_not_ge hnot
  have heps : 0 < plusExactDefect canonicalPlusJetScale canonicalTransverseJet rho / 2 := by
    linarith
  obtain ⟨n, hrem⟩ := hSmall
    (plusExactDefect canonicalPlusJetScale canonicalTransverseJet rho / 2) heps
  have hdecomp := exactPlusDefect_eq_finitePlusDefect_add_plusTailDefect
    finitePlusEnergy plusTailEnergy hSplit n rho hz
  have hfin := hFinite n rho hz
  have htail := hTail n rho hz
  linarith

/-- Existence of a one-directional factorization certificate.  This mirrors
    the plus half of the older Rocq `FiniteEnergyTailPhiKQFactorization` record. -/
def ExistsCanonicalPlusFactorization : Prop :=
  ∃ (finitePlusEnergy plusTailEnergy : ℕ → ℂ → ℝ)
    (uniformRemainder : ℕ → ℝ),
      PlusEnergySplit finitePlusEnergy plusTailEnergy ∧
      FinitePlusPassivity finitePlusEnergy ∧
      PlusTailControl plusTailEnergy uniformRemainder ∧
      UniformRemainderArbitrarilySmall uniformRemainder

/-- Any such factorization certificate implies Mathlib RH: first derive plus
    passivity, then use the already-kernel-checked reflection collapse. -/
theorem mathlibRH_of_existsCanonicalPlusFactorization
    (h : ExistsCanonicalPlusFactorization) : RiemannHypothesis := by
  rcases h with ⟨finiteE, tailE, rem, hSplit, hFinite, hTail, hSmall⟩
  apply canonicalPlusPassivityCore_iff_mathlibRH.mp
  exact canonicalPlusPassivity_of_factorization_leaves
    finiteE tailE rem hSplit hFinite hTail hSmall

/-- Conversely RH gives a canonical trivial factorization: finite energy is
    the exact energy, tail energy is zero, and the uniform remainder is zero.
    This is an audit theorem showing that mere existence of a factorization
    certificate is not weaker than RH. -/
theorem existsCanonicalPlusFactorization_of_mathlibRH
    (hRH : RiemannHypothesis) : ExistsCanonicalPlusFactorization := by
  let finiteE : ℕ → ℂ → ℝ := fun _ rho => canonicalPlusEnergy rho
  let tailE : ℕ → ℂ → ℝ := fun _ _ => 0
  let rem : ℕ → ℝ := fun _ => 0
  have hPass : PlusPassivityCore canonicalPlusJetScale canonicalTransverseJet :=
    canonicalPlusPassivityCore_iff_mathlibRH.mpr hRH
  refine ⟨finiteE, tailE, rem, ?_, ?_, ?_, ?_⟩
  · intro n rho hz
    simp [finiteE, tailE]
  · intro n rho hz
    have hp := hPass rho hz
    simpa [finitePlusDefect, finiteE, canonicalPlusGain, canonicalPlusEnergy,
      plusExactDefect] using hp
  · intro n rho hz
    simp [PlusTailControl, plusTailDefect, tailE, rem]
  · intro eps heps
    exact ⟨0, le_of_lt heps⟩

/-- Decisive factorization audit: existence of the one-direction finite-energy
    factorization is exactly Mathlib RH.  Therefore this factorization cannot
    serve as an already-lower proof principle unless its concrete fields are
    established independently. -/
theorem existsCanonicalPlusFactorization_iff_mathlibRH :
    ExistsCanonicalPlusFactorization ↔ RiemannHypothesis := by
  constructor
  · exact mathlibRH_of_existsCanonicalPlusFactorization
  · exact existsCanonicalPlusFactorization_of_mathlibRH

#print axioms exactPlusDefect_eq_finitePlusDefect_add_plusTailDefect
#print axioms canonicalPlusPassivity_of_factorization_leaves
#print axioms mathlibRH_of_existsCanonicalPlusFactorization
#print axioms existsCanonicalPlusFactorization_of_mathlibRH
#print axioms existsCanonicalPlusFactorization_iff_mathlibRH

end AWPI.PhiRH.FactorizationFrontier
