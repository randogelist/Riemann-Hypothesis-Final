import Solobolo.ScalarAdmission

/-!
# Eventual SOLOBOLO epsilon admission

The original epsilon-admission asks for one sufficiently small residual.
Because the critical-line tail decreases, this is equivalent to eventual
smallness of every later residual. The argument assumes no dyadic rate.
-/

namespace Solobolo.HypotheticalRH

/-- The residual becomes smaller than every positive tolerance and stays there. -/
def EventualEpsilonAdmission (p : DyadicProfile) : Prop :=
  ∀ ε : ℝ, 0 < ε → ∃ N : ℕ, ∀ n ≥ N, residual p n < ε

/-- A decreasing spectral tail is order-reversing on natural indices. -/
theorem tail_le_of_le (p : DyadicProfile) {n m : ℕ} (h : n ≤ m) :
    p.tail m ≤ p.tail n := by
  obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le h
  induction k with
  | zero => simp
  | succ k ih =>
      have hstep : p.tail (n + (k + 1)) ≤ p.tail (n + k) := by
        simpa [Nat.add_succ] using (p.tail_step_le (n + k))
      exact hstep.trans ih

/-- The actual residual is nonincreasing independently of RH. -/
theorem residual_le_of_le (p : DyadicProfile) {n m : ℕ} (h : n ≤ m) :
    residual p m ≤ residual p n := by
  have htail := tail_le_of_le p h
  dsimp [residual]
  linarith

/-- A single epsilon witness automatically controls all subsequent stages. -/
theorem eventualEpsilonAdmission_iff_epsilonAdmission (p : DyadicProfile) :
    EventualEpsilonAdmission p ↔ EpsilonAdmission p := by
  constructor
  · intro h ε hε
    obtain ⟨N, hN⟩ := h ε hε
    exact ⟨N, hN N le_rfl⟩
  · intro h ε hε
    obtain ⟨N, hN⟩ := h ε hε
    refine ⟨N, ?_⟩
    intro n hn
    exact lt_of_le_of_lt (residual_le_of_le p hn) hN

/-- Strengthened, rate-free hypothetical admission iff no off-line mass. -/
theorem eventualEpsilonAdmission_iff_noOffLineMass (p : DyadicProfile) :
    EventualEpsilonAdmission p ↔ NoOffLineMass p :=
  (eventualEpsilonAdmission_iff_epsilonAdmission p).trans
    (epsilonAdmission_iff_noOffLineMass p)

#print axioms eventualEpsilonAdmission_iff_noOffLineMass

end Solobolo.HypotheticalRH
