import RHFinal.Actual.NativeRH
import RHFinal.Actual.Successor
import RHFinal.Core.LocalWitness

/-!
OPEN ACTUAL-DATA CONTRACTS, not added axioms or witness proof fields.
The conditional endpoint below states exactly which infinite analytic inputs
remain to be derived from a finite certificate. No concrete global checker is
implemented by this file, and no theorem proves any of the open propositions.
-/

noncomputable section

namespace RHFinal.Actual

/-- Same normalization as the recovered actual central Widder expression. -/
def centralWidder (a : ℝ) (n : ℕ) : ℝ :=
  ((4 : ℂ) ^ (n + 1) *
    ∑ j ∈ Finset.range (n + 2),
      (-1 : ℂ) ^ j * (Nat.choose (n + 1) j : ℂ) *
        actualDirectJet (n + j) (a : ℂ)).re

/-- OPEN: all-order actual moment control, not a decidable finite predicate. -/
def ActualMomentControl : Prop :=
  ∀ a : ℝ, 0 < a → ∃ C : ℝ, ∀ n : ℕ, centralWidder a n ≤ C

/-- OPEN: actual zero/divisor amplification, for this literal moment function. -/
def ActualOffLineExplosion : Prop :=
  ¬ _root_.RiemannHypothesis →
    ∃ a : ℝ, 0 < a ∧ ∀ C : ℝ, ∃ n : ℕ, C < centralWidder a n

/-- OPEN: actual analyticity must supply the product-rule regularity premise. -/
def ActualSuccessorRegularity : Prop :=
  ∀ n : ℕ, ∀ a : ℝ, 0 < a →
    HasDerivAt (iteratedDeriv n actualLogDerivative)
      (iteratedDeriv (n + 1) actualLogDerivative (a : ℂ)) (a : ℂ)

/-- A global check must derive the input, not append it to the finite witness.
    The local SOS checker does not establish this proposition. -/
def FiniteInputReduction (check : RHFinal.FiniteWitness → Bool) : Prop :=
  ∀ w, check w = true → ActualMomentControl

/-- Separate OPEN completeness direction for the same final checker. -/
def FiniteCompleteness (check : RHFinal.FiniteWitness → Bool) : Prop :=
  _root_.RiemannHypothesis → ∃ w, check w = true

/-- Exact requested target, recorded as a proposition, not asserted. -/
def FiniteWitnessIffNativeRH (check : RHFinal.FiniteWitness → Bool) : Prop :=
  (∃ w, check w = true) ↔ _root_.RiemannHypothesis

/-- Conditional analytic contradiction; both substantial premises are visible. -/
theorem nativeRH_of_momentControl
    (hControl : ActualMomentControl) (hExplosion : ActualOffLineExplosion) :
    _root_.RiemannHypothesis := by
  by_contra hRH
  obtain ⟨a, ha, hlarge⟩ := hExplosion hRH
  obtain ⟨C, hC⟩ := hControl a ha
  obtain ⟨n, hn⟩ := hlarge C
  exact (not_lt_of_ge (hC n)) hn

/-- Conditional composition only. No final check or input reduction is supplied. -/
theorem nativeRH_of_finite_input_reduction
    (check : RHFinal.FiniteWitness → Bool)
    (hInput : FiniteInputReduction check)
    (hExplosion : ActualOffLineExplosion)
    (w : RHFinal.FiniteWitness) (hw : check w = true) :
    _root_.RiemannHypothesis :=
  nativeRH_of_momentControl (hInput w hw) hExplosion

end RHFinal.Actual
