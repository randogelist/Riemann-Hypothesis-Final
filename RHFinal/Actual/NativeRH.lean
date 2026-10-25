import FiniteWitness.NativeXi

/-!
Exact native Mathlib target, adapted from RHAdmission/NativeZeros.lean in
v0_6_1. The proxy two-mode gain is deliberately not part of this interface.
SOURCE_ONLY: native compilation and axiom audit pending.
-/

namespace RHFinal.Actual

def NontrivialZero (s : ℂ) : Prop :=
  riemannZeta s = 0 ∧ (¬ ∃ n : ℕ, s = -2 * (n + 1)) ∧ s ≠ 1

theorem nativeRH_iff_zero_rigidity :
    _root_.RiemannHypothesis ↔
      (∀ s : ℂ, NontrivialZero s → s.re = 1 / 2) := by
  constructor
  · intro h s hz
    exact h s hz.1 hz.2.1 hz.2.2
  · intro h s hz ht hn
    exact h s ⟨hz, ht, hn⟩

end RHFinal.Actual
