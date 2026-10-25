import Bridge.UniformDepthPositivityRH04

namespace NativeSoloboloContinuant

/-- Positivity at every actual Widder depth and every positive anchor. -/
def ActualAllDepthWidderPositive : Prop :=
  ∀ N : Nat, ActualUniformDepthPositive N

/--
Analytic Green-kernel interface:
positivity one level higher propagates one level downward.
The intended proof is the positive Laplace-kernel identity
  Sigma_n = p_(n+1) * Sigma_(n+1),
  p_m(v) = (m/2) exp(-m |v|).
-/
def ActualWidderDownwardPositivity : Prop :=
  ∀ n : Nat,
    ActualUniformDepthPositive (n + 1) →
      ActualUniformDepthPositive n

/-- Iterated downward propagation from any higher positive depth. -/
theorem DOWNWARD_POSITIVITY_PROPAGATES_TO_LOWER_DEPTH
    (hDown : ActualWidderDownwardPositivity)
    {n N : Nat}
    (hnN : n ≤ N)
    (hN : ActualUniformDepthPositive N) :
    ActualUniformDepthPositive n := by
  induction N generalizing n with
  | zero =>
      have hn0 : n = 0 := by omega
      simpa [hn0] using hN
  | succ N ih =>
      by_cases hEq : n = N + 1
      · simpa [hEq] using hN
      · have hnN' : n ≤ N := by omega
        have hPrev : ActualUniformDepthPositive N := by
          simpa [Nat.add_comm] using hDown N hN
        exact ih hnN' hPrev

/--
!!! Cofinal uniform positivity plus the positive backward kernel yields
uniform positivity at every finite depth.
-/
theorem US_IMPLIES_ALL_DEPTH_WIDDER_POSITIVITY
    (hDown : ActualWidderDownwardPositivity)
    (hUS : ActualCofinalUniformDepthPositive) :
    ActualAllDepthWidderPositive := by
  intro n
  rcases hUS n with ⟨N, hnN, hN⟩
  exact DOWNWARD_POSITIVITY_PROPAGATES_TO_LOWER_DEPTH hDown hnN hN

/-- All-depth positivity trivially supplies a cofinal positive depth. -/
theorem ALL_DEPTH_WIDDER_POSITIVITY_IMPLIES_US
    (hAll : ActualAllDepthWidderPositive) :
    ActualCofinalUniformDepthPositive := by
  intro K
  exact ⟨K, le_rfl, hAll K⟩

end NativeSoloboloContinuant
