import Solobolo.FiniteRateEquivalence

/-!
# Elementary rational envelope budgets always exist

For each finite real residual there is a natural-number upper bound. This
removes the harmless `RationalBudget` input from the semantic equivalence.
It does not certify any all-depth source estimate.
-/

namespace Solobolo.HypotheticalRH

theorem rationalBudget_unconditional (p : DyadicProfile) :
    RationalBudget p := by
  intro n
  obtain ⟨M, hM⟩ := exists_nat_gt (residual p n)
  refine ⟨(M : ℚ), ?_, ?_⟩
  · exact_mod_cast (Nat.zero_le M)
  · simpa using (le_of_lt hM : residual p n ≤ (M : ℝ))

#print axioms rationalBudget_unconditional

end Solobolo.HypotheticalRH
