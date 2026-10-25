import Solobolo.ActualRHInterface

/-!
# Actual Riemann-zeta hypothesis in an explicit zero-exclusion normal form

This theorem uses the *actual* Mathlib riemannZeta, not a model function.
It is unconditional logic. It does not construct any off-line zero ledger.
-/

namespace Solobolo.HypotheticalRH

/-- An actual off-critical-line zero strictly inside the critical strip. -/
def ExistsOffLineZero : Prop :=
  ∃ s : ℂ, 0 < s.re ∧ s.re < 1 ∧
    riemannZeta s = 0 ∧ s.re ≠ (1 / 2 : ℝ)

/-- An unconditional logical restatement of the genuine RH. -/
theorem actualRH_iff_no_offline_zero :
    ActualRiemannHypothesis ↔ ¬ ExistsOffLineZero := by
  constructor
  · intro h ⟨s, h0, h1, hz, hne⟩
    exact hne (h s h0 h1 hz)
  · intro h s h0 h1 hz
    by_contra hne
    exact h ⟨s, h0, h1, hz, hne⟩

#print axioms actualRH_iff_no_offline_zero

end Solobolo.HypotheticalRH
