import AllDepth.CayleyTopDiagonal

/-!
# v0.1.13: unconditional all-depth finite Cayley coefficient formula

This module combines the already proved v0.1.10 stabilization with the
v0.1.12 UNCONDITIONAL Pascal/binomial coefficient theorem. The result
identifies every coefficient of every sufficiently long finite Cayley jet
with the explicit closed binomial expression. It makes **no** assertion
about infinite Taylor convergence, actual Theta jet calibration, or RH.
-/

namespace KQGPBKQRHilbert.AllDepth

noncomputable section

/-- Terms with polynomial index strictly below the coefficient depth do
not contribute; their required coefficient lies above their degree. -/
private theorem lower_finite_cayley_sum_zero (a : ℝ) (c : ℕ → ℂ)
    (n : ℕ) :
    (∑ j ∈ Finset.range n,
      c (j + 1) * (cayleyDividedPowerPolynomial a j).coeff n) = 0 := by
  apply Finset.sum_eq_zero
  intro j hj
  have hjlt : j < n := Finset.mem_range.mp hj
  simp [cayley_coeff_above_diagonal_zero a j n hjlt]

/-- The surviving n+1 summands are exactly the Pascal/binomial triangle. -/
private theorem upper_finite_cayley_sum_binomial
    (a : ℝ) (c : ℕ → ℂ) (n : ℕ) :
    (∑ k ∈ Finset.range (n + 1),
      c (n + k + 1) * (cayleyDividedPowerPolynomial a (n + k)).coeff n) =
    (-4 * (a : ℂ)) ^ n *
      (∑ k ∈ Finset.range (n + 1),
        (Nat.choose n k : ℂ) * (a : ℂ) ^ k * c (n + k + 1)) := by
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro k hk
  rw [cayley_polynomial_binomial_unconditional a n k]
  ring

/-- The canonical coefficient is literally the stable finite-jet coefficient,
for every depth n, with no top-diagonal hypothesis and no depth restriction. -/
theorem stable_cayley_coefficient_eq_canonical_closed
    (a : ℝ) (c : ℕ → ℂ) (n : ℕ) :
    stableCayleyCoefficient a c n = canonicalCayleyCoefficient a c n := by
  have hsplit :
      (∑ j ∈ Finset.range (2 * n + 1),
        c (j + 1) * (cayleyDividedPowerPolynomial a j).coeff n) =
      (∑ k ∈ Finset.range (n + 1),
        c (n + k + 1) *
          (cayleyDividedPowerPolynomial a (n + k)).coeff n) := by
    rw [show 2 * n + 1 = n + (n + 1) by omega]
    rw [Finset.sum_range_add]
    rw [lower_finite_cayley_sum_zero a c n]
    simp only [zero_add]
  calc
    stableCayleyCoefficient a c n =
        4 * (a : ℂ) *
          (∑ j ∈ Finset.range (2 * n + 1),
            c (j + 1) * (cayleyDividedPowerPolynomial a j).coeff n) := by
              rw [stableCayleyCoefficient, finite_cayley_coefficient_exact]
              rfl
    _ = 4 * (a : ℂ) *
          (∑ k ∈ Finset.range (n + 1),
            c (n + k + 1) *
              (cayleyDividedPowerPolynomial a (n + k)).coeff n) := by
              rw [hsplit]
    _ = 4 * (a : ℂ) *
          ((-4 * (a : ℂ)) ^ n *
            (∑ k ∈ Finset.range (n + 1),
              (Nat.choose n k : ℂ) * (a : ℂ) ^ k * c (n + k + 1))) := by
              rw [upper_finite_cayley_sum_binomial a c n]
    _ = canonicalCayleyCoefficient a c n := by
          unfold canonicalCayleyCoefficient
          ring

/-- Closed coefficient formula for ANY finite Taylor input length N≥2n+1.
This closes the entire finite combinatorial Cayley bridge. -/
theorem finite_cayley_coefficient_closed_all_depth
    (a : ℝ) (c : ℕ → ℂ) (N n : ℕ)
    (hN : 2 * n + 1 ≤ N) :
    (finiteCayleyJetPolynomial a c N).coeff n =
      4 * (a : ℂ) * (-4 * (a : ℂ)) ^ n *
        (∑ k ∈ Finset.range (n + 1),
          (Nat.choose n k : ℂ) * (a : ℂ) ^ k * c (n + k + 1)) := by
  calc
    (finiteCayleyJetPolynomial a c N).coeff n =
        stableCayleyCoefficient a c n :=
          finite_cayley_coefficient_stable_of_le a c n N hN
    _ = canonicalCayleyCoefficient a c n :=
          stable_cayley_coefficient_eq_canonical_closed a c n
    _ = _ := rfl

/-- Minimal 2n+1 Taylor input case as a ready-to-import endpoint. -/
theorem finite_cayley_coefficient_closed_minimal
    (a : ℝ) (c : ℕ → ℂ) (n : ℕ) :
    (finiteCayleyJetPolynomial a c (2 * n + 1)).coeff n =
      canonicalCayleyCoefficient a c n := by
  exact stable_cayley_coefficient_eq_canonical_closed a c n

/-- Only the first 2n+1 original Taylor inputs can influence the
canonical coefficient. This is an unconditional finite-algebra result. -/
theorem canonical_cayley_coefficients_congr_initial
    (a : ℝ) (c d : ℕ → ℂ) (n : ℕ)
    (h : ∀ j : ℕ, j ≤ 2 * n + 1 → c j = d j) :
    canonicalCayleyCoefficient a c n =
      canonicalCayleyCoefficient a d n := by
  rw [← stable_cayley_coefficient_eq_canonical_closed a c n,
      ← stable_cayley_coefficient_eq_canonical_closed a d n]
  change (finiteCayleyJetPolynomial a c (2 * n + 1)).coeff n =
      (finiteCayleyJetPolynomial a d (2 * n + 1)).coeff n
  apply finite_cayley_coefficients_congr
  intro j hj
  exact h (j + 1) (by omega)

end
end KQGPBKQRHilbert.AllDepth
