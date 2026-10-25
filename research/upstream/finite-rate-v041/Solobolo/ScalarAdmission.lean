import Solobolo.ScalarProfile

/-!
# Exact epsilon-admission equivalence

This is an unconditional theorem *for the explicitly supplied spectral ledger*:
no off-line mass iff the residual can be made arbitrarily small.
No dyadic density asymptotic or witness is used.
-/

namespace Solobolo.HypotheticalRH

/-- A hypothetical epsilon admission is exactly absence of off-line mass. -/
theorem epsilonAdmission_iff_noOffLineMass (p : DyadicProfile) :
    EpsilonAdmission p ↔ NoOffLineMass p := by
  constructor
  · intro h
    unfold NoOffLineMass
    by_contra hne
    have hpos : 0 < p.offMass := by
      rcases lt_or_eq_of_le p.offMass_nonneg with hp | hz
      · exact hp
      · exact False.elim (hne hz.symm)
    obtain ⟨n, hn⟩ := h (p.offMass / 2) (by linarith)
    have hle := offMass_le_residual p n
    linarith
  · intro hz ε hε
    obtain ⟨n, hn⟩ := p.tail_small ε hε
    refine ⟨n, ?_⟩
    change p.offMass = 0 at hz
    simpa [residual, hz] using hn

/-- Form convenient for a downstream theorem with no witness parameter. -/
theorem noOffLineMass_iff_epsilonAdmission (p : DyadicProfile) :
    NoOffLineMass p ↔ EpsilonAdmission p :=
  (epsilonAdmission_iff_noOffLineMass p).symm

#print axioms epsilonAdmission_iff_noOffLineMass

end Solobolo.HypotheticalRH
