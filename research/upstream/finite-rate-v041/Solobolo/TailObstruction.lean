import Solobolo.EventualAdmission

/-!
# Positive off-line mass obstructs every sufficiently late quarter step

No rate theorem or zero counting asymptotic is needed in this direction.
A positive off-line floor forces the block payment to become too small
relative to the residual at ALL sufficiently large dyadic indices.
-/

namespace Solobolo.HypotheticalRH

/-- Each block payment is bounded above by the remaining tail. -/
theorem block_le_tail (p : DyadicProfile) (n : ℕ) :
    block p n ≤ p.tail n := by
  rw [block_eq_tail_difference]
  linarith [p.tail_nonneg (n + 1)]

/-- Strong obstruction: positive off-line mass eventually prevents
    every quarter-payment inequality, not merely one of them. -/
theorem positiveOffMass_eventually_fails_quarter (p : DyadicProfile)
    (hpos : 0 < p.offMass) :
    ∃ N : ℕ, ∀ n ≥ N,
      (4 : ℝ) * block p n < residual p n := by
  obtain ⟨N, hN⟩ := p.tail_small (p.offMass / 4) (by positivity)
  refine ⟨N, ?_⟩
  intro n hn
  have htail : p.tail n < p.offMass / 4 :=
    lt_of_le_of_lt (tail_le_of_le p hn) hN
  have hblock := block_le_tail p n
  have hfloor := offMass_le_residual p n
  linarith

/-- A positive off-line floor also prevents eventual epsilon admission. -/
theorem positiveOffMass_not_eventualAdmission (p : DyadicProfile)
    (hpos : 0 < p.offMass) : ¬ EventualEpsilonAdmission p := by
  intro h
  have hz := (eventualEpsilonAdmission_iff_noOffLineMass p).mp h
  unfold NoOffLineMass at hz
  linarith

#print axioms positiveOffMass_eventually_fails_quarter

end Solobolo.HypotheticalRH
