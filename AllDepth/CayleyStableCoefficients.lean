import AllDepth.CayleyCoefficientAtlas

/-!
# v0.1.10: all-depth finite Cayley coefficient stabilization

The n-th radius coefficient of an arbitrary finite Cayley jet depends on
only the first 2*n+1 nonconstant Taylor coefficients.  This is proved
without a binomial closed form, an actual-xi calibration, convergence of
infinite series, or any assumption about the Riemann hypothesis.

The key lemma is that D_j(r) has no r^n term once j>2*n.  It follows
inductively from the shifted-power recurrence in the previous module.
-/

namespace KQGPBKQRHilbert.AllDepth

noncomputable section

/-- The all-depth recurrence with an explicit factor of X. -/
theorem cayley_divided_power_polynomial_rec (a : ℝ) (j : ℕ) :
    cayleyDividedPowerPolynomial a (j + 2) =
      Polynomial.X *
        (Polynomial.C (((-4 * a : ℝ) : ℂ)) *
            cayleyDividedPowerPolynomial a (j + 1) -
         Polynomial.C (((4 * a ^ 2 : ℝ) : ℂ)) *
            cayleyDividedPowerPolynomial a j) := by
  unfold cayleyDividedPowerPolynomial
  simp only [cayleyPolynomialPair]
  ring

/-- Positive-index Cayley divided powers have no constant-radius term. -/
theorem cayley_divided_power_coeff_zero_succ (a : ℝ) (j : ℕ) :
    (cayleyDividedPowerPolynomial a (j + 1)).coeff 0 = 0 := by
  cases j with
  | zero =>
      simp [cayleyDividedPowerPolynomial, cayleyPolynomialPair,
        Polynomial.coeff_zero_eq_eval_zero]
  | succ j =>
      change (cayleyDividedPowerPolynomial a (j + 2)).coeff 0 = 0
      rw [cayley_divided_power_polynomial_rec]
      rw [Polynomial.coeff_zero_eq_eval_zero]
      simp

/-- Coefficient-level Cayley recurrence, uniformly over j,n. -/
theorem cayley_divided_power_coeff_rec
    (a : ℝ) (j n : ℕ) :
    (cayleyDividedPowerPolynomial a (j + 2)).coeff (n + 1) =
      (((-4 * a : ℝ) : ℂ)) *
        (cayleyDividedPowerPolynomial a (j + 1)).coeff n -
      (((4 * a ^ 2 : ℝ) : ℂ)) *
        (cayleyDividedPowerPolynomial a j).coeff n := by
  rw [cayley_divided_power_polynomial_rec]
  rw [Polynomial.coeff_X_mul]
  simp only [Polynomial.coeff_sub, Polynomial.coeff_C_mul]

/-- Strong lower-degree bound: radius-degree n cannot occur in D_j for j>2*n.
    This is the substantive all-depth stabilization input. -/
theorem cayley_divided_power_coeff_vanishes_above_twice (a : ℝ) :
    ∀ n j : ℕ, 2 * n < j →
      (cayleyDividedPowerPolynomial a j).coeff n = 0 := by
  intro n
  induction n with
  | zero =>
      intro j hj
      cases j with
      | zero => omega
      | succ j =>
          exact cayley_divided_power_coeff_zero_succ a j
  | succ n ih =>
      intro j hj
      obtain ⟨k, hk⟩ : ∃ k : ℕ, j = k + 2 :=
        ⟨j - 2, by omega⟩
      subst j
      rw [cayley_divided_power_coeff_rec]
      rw [ih (k + 1) (by omega), ih k (by omega)]
      ring

/-- Beyond 2*n+1 Taylor inputs, appending one coefficient cannot
    change the radius coefficient at depth n. -/
theorem finite_cayley_coefficient_stable_succ
    (a : ℝ) (c : ℕ → ℂ) (n N : ℕ) (hN : 2 * n < N) :
    (finiteCayleyJetPolynomial a c (N + 1)).coeff n =
      (finiteCayleyJetPolynomial a c N).coeff n := by
  simp only [finite_cayley_coefficient_exact, finiteCayleyCoefficient]
  rw [Finset.sum_range_succ]
  have hz : (cayleyDividedPowerPolynomial a N).coeff n = 0 :=
    cayley_divided_power_coeff_vanishes_above_twice a n N hN
  simp [hz]

/-- Stabilization under any finite extension of the Taylor input. -/
theorem finite_cayley_coefficient_stable_add
    (a : ℝ) (c : ℕ → ℂ) (n k : ℕ) :
    (finiteCayleyJetPolynomial a c (2 * n + 1 + k)).coeff n =
      (finiteCayleyJetPolynomial a c (2 * n + 1)).coeff n := by
  induction k with
  | zero => rfl
  | succ k ih =>
      simpa only [Nat.add_succ] using
        (finite_cayley_coefficient_stable_succ
          a c n (2 * n + 1 + k) (by omega)).trans ih

/-- The same stabilization in a natural input-length formulation. -/
theorem finite_cayley_coefficient_stable_of_le
    (a : ℝ) (c : ℕ → ℂ) (n N : ℕ)
    (hN : 2 * n + 1 ≤ N) :
    (finiteCayleyJetPolynomial a c N).coeff n =
      (finiteCayleyJetPolynomial a c (2 * n + 1)).coeff n := by
  obtain ⟨k, hk⟩ : ∃ k : ℕ, N = (2 * n + 1) + k :=
    ⟨N - (2 * n + 1), by omega⟩
  rw [hk]
  exact finite_cayley_coefficient_stable_add a c n k

/-- Canonical finite-definition coefficient at every depth n. -/
def stableCayleyCoefficient (a : ℝ) (c : ℕ → ℂ) (n : ℕ) : ℂ :=
  (finiteCayleyJetPolynomial a c (2 * n + 1)).coeff n

/-- An arbitrary longer finite Cayley jet has exactly the same coefficient. -/
theorem stable_cayley_coefficient_eq_finite
    (a : ℝ) (c : ℕ → ℂ) (n N : ℕ)
    (hN : 2 * n + 1 ≤ N) :
    (finiteCayleyJetPolynomial a c N).coeff n =
      stableCayleyCoefficient a c n :=
  finite_cayley_coefficient_stable_of_le a c n N hN

/-- Zeroth stabilized coefficient agrees with the finite-jet endpoint. -/
theorem stable_cayley_coefficient_zero (a : ℝ) (c : ℕ → ℂ) :
    stableCayleyCoefficient a c 0 = 4 * (a : ℂ) * c 1 := by
  change (finiteCayleyJetPolynomial a c 1).coeff 0 = 4 * (a : ℂ) * c 1
  exact finiteCayleyJetPolynomial_coeff_zero a c 0

/-- At radius order zero this matches the proposed all-depth binomial atlas. -/
theorem stable_cayley_zero_eq_canonical (a : ℝ) (c : ℕ → ℂ) :
    stableCayleyCoefficient a c 0 =
      canonicalCayleyCoefficient a c 0 := by
  rw [stable_cayley_coefficient_zero,
      canonical_cayley_coefficient_zero]

end
end KQGPBKQRHilbert.AllDepth
