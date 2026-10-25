import Solobolo.MainChainV10

/-!
# Finite start parameter <-> SOLOBOLO quarter admission <-> actual RH

`N : Nat` is finite *data*. Its condition `ValidStart p N` quantifies over
all subsequent indices: it is a mathematical proposition, NOT a terminating
finite checker. This file proves the exact semantic equivalence and never
conflates the two notions.

Actual-RH results take the analytic source and RH tail-rate lemmas as
explicit inputs; those are still open for the actual Riemann zeta data.
-/

namespace Solobolo.HypotheticalRH

/-- A finite natural-number start parameter for a uniform dyadic inequality. -/
def ValidStart (p : DyadicProfile) (N : ℕ) : Prop :=
  ∀ n ≥ N, (4 : ℝ) * block p n ≥ residual p n

/-- Every validated start gives a quantitative all-depth induction. -/
theorem validStart_geometric (p : DyadicProfile) (N k : ℕ)
    (hN : ValidStart p N) :
    residual p (N + k) ≤ (3 / 4 : ℝ) ^ k * residual p N :=
  quarter_geometric_induction p N hN k

/-- The finite *parameter* existence statement is definitionally the strong
hypothetical admission (not yet a decidable acceptance certificate). -/
theorem exists_validStart_iff_quarter (p : DyadicProfile) :
    (∃ N : ℕ, ValidStart p N) ↔ QuarterAdmission p := by
  constructor
  · rintro ⟨N, hN⟩
    exact ⟨N, hN⟩
  · rintro ⟨N, hN⟩
    exact ⟨N, hN⟩

/-- Any valid finite start forces zero off-line mass; no tail rate required. -/
theorem exists_validStart_implies_noOffLineMass (p : DyadicProfile) :
    (∃ N : ℕ, ValidStart p N) → NoOffLineMass p := by
  intro h
  exact quarterAdmission_implies_noOffLineMass p
    ((exists_validStart_iff_quarter p).mp h)

/-- The other direction genuinely needs the weighted critical-line tail rate. -/
theorem exists_validStart_iff_noOffLineMass_of_rate (p : DyadicProfile)
    (hrate : TailQuarterRate p) :
    (∃ N : ℕ, ValidStart p N) ↔ NoOffLineMass p :=
  (exists_validStart_iff_quarter p).trans
    (quarterAdmission_iff_noOffLineMass_of_tailRate p hrate)

/-- FINITE-START EXISTS <-> ACTUAL RH, CONDITIONAL ON THE TWO ANALYTIC BRIDGES.
The start index is finite but `ValidStart` is not a Boolean checker. -/
theorem exists_validStart_iff_actualRH (p : DyadicProfile)
    (hsource : ActualRiemannHypothesis ↔ NoOffLineMass p)
    (hrate : ActualRiemannHypothesis → TailQuarterRate p) :
    (∃ N : ℕ, ValidStart p N) ↔ ActualRiemannHypothesis :=
  (exists_validStart_iff_quarter p).trans
    (quarterAdmission_iff_actualRH p hsource hrate)

#print axioms validStart_geometric
#print axioms exists_validStart_iff_actualRH

end Solobolo.HypotheticalRH
