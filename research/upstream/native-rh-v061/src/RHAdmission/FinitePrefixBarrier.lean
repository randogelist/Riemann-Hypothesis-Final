import RHAdmission.GatedVerifierBarrier

/-!
# Finite-prefix testing does not control every future depth

A terminating checker may inspect finitely many native coefficient windows,
but their successful comparison alone cannot be used as a generic inductive
step. A global algebraic or analytic recurrence with a proved invariant is
necessary for the actual-zeta conclusion.
-/

namespace RHAdmission

/-- Every finite zero prefix admits a nonzero continuation. This is an
ordinary combinatorial fact, not an alleged counterexample to RH. -/
theorem FINITE_PREFIX_CAN_HIDE_FUTURE_FAILURE (N : ℕ) :
    ∃ x : ℕ → ℕ,
      (∀ n : ℕ, n ≤ N → x n = 0) ∧ x (N + 1) = 1 := by
  refine ⟨fun n => if n ≤ N then 0 else 1, ?_, ?_⟩
  · intro n hn
    simp [hn]
  · have hnot : ¬ N + 1 ≤ N := by omega
    simp [hnot]

end RHAdmission
