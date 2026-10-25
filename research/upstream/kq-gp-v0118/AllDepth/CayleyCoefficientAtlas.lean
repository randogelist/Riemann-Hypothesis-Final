import AllDepth.CayleyPolynomialGerm

/-!
# v0.1.9: finite Cayley coefficient atlas, all depths

This module proves coefficient extraction for EVERY n in the existing
finite Cayley jet polynomial, and complex-radius holomorphicity of every
finite jet. It does not assert any convergence of the infinite actual-Theta
Taylor expansion or equality of its coefficients with the real Widder tower.
-/

namespace KQGPBKQRHilbert.AllDepth

noncomputable section

/-- The literal finite coefficient obtained by expanding the existing
    Cayley polynomial into radius monomials. -/
def finiteCayleyCoefficient (a : ℝ) (c : ℕ → ℂ) (N n : ℕ) : ℂ :=
  4 * (a : ℂ) *
    (∑ j ∈ Finset.range N,
      c (j + 1) * (cayleyDividedPowerPolynomial a j).coeff n)

/-- The coefficient of EVERY radius power is an explicit finite sum
    of the polynomially regularized Cayley divided powers. -/
theorem finite_cayley_coefficient_exact
    (a : ℝ) (c : ℕ → ℂ) (N n : ℕ) :
    (finiteCayleyJetPolynomial a c N).coeff n =
      finiteCayleyCoefficient a c N n := by
  simp only [finiteCayleyJetPolynomial, finiteCayleyCoefficient,
    Polynomial.coeff_C_mul, Polynomial.finsetSum_coeff]

/-- The full *candidate closed expression*, with no powers of two.
    Its equality with the finite-polynomial coefficient at N ≥ 2*n+1
    is the next explicit combinatorial theorem, not assumed here. -/
def canonicalCayleyCoefficient (a : ℝ) (c : ℕ → ℂ)
    (n : ℕ) : ℂ :=
  4 * (a : ℂ) * (-4 * (a : ℂ)) ^ n *
    (∑ k ∈ Finset.range (n + 1),
      (Nat.choose n k : ℂ) * (a : ℂ) ^ k * c (n + k + 1))

/-- Normalization check at the zeroth radius coefficient. -/
theorem canonical_cayley_coefficient_zero
    (a : ℝ) (c : ℕ → ℂ) :
    canonicalCayleyCoefficient a c 0 = 4 * (a : ℂ) * c 1 := by
  simp [canonicalCayleyCoefficient]

/-- Compatibility of the explicit all-depth candidate with the
    established (Lean-compiled) zeroth polynomial coefficient. -/
theorem zeroth_cayley_coefficient_matches_canonical
    (a : ℝ) (c : ℕ → ℂ) (N : ℕ) :
    (finiteCayleyJetPolynomial a c (N + 1)).coeff 0 =
      canonicalCayleyCoefficient a c 0 := by
  rw [finiteCayleyJetPolynomial_coeff_zero,
      canonical_cayley_coefficient_zero]

/-- The finite Cayley germ evaluated at an arbitrary COMPLEX radius.
    The original square-root Cayley points were only used for real radii. -/
def complexFiniteCayleyJet (a : ℝ) (c : ℕ → ℂ)
    (N : ℕ) (z : ℂ) : ℂ :=
  Polynomial.eval z (finiteCayleyJetPolynomial a c N)

/-- Each finite jet is an entire function of complex radius. -/
theorem complex_finite_cayley_jet_differentiable
    (a : ℝ) (c : ℕ → ℂ) (N : ℕ) :
    Differentiable ℂ (complexFiniteCayleyJet a c N) := by
  exact (finiteCayleyJetPolynomial a c N).differentiable

/-- The new complex-radius jet restricts to the EXACT real-radius
    Cayley polynomial endpoint proved in v0.1.8. -/
theorem complex_finite_cayley_jet_real
    (a r : ℝ) (c : ℕ → ℂ) (N : ℕ) :
    complexFiniteCayleyJet a c N (r : ℂ) =
      finiteShiftedCayleyJet a r c N :=
  finiteCayleyJetPolynomial_eval a r c N

/-- No new hidden calibration: if two Taylor inputs agree through N,
    every coefficient of their N-term Cayley polynomials agrees. -/
theorem finite_cayley_coefficients_congr
    (a : ℝ) (c d : ℕ → ℂ) (N n : ℕ)
    (h : ∀ j : ℕ, j < N → c (j + 1) = d (j + 1)) :
    (finiteCayleyJetPolynomial a c N).coeff n =
      (finiteCayleyJetPolynomial a d N).coeff n := by
  simp only [finite_cayley_coefficient_exact, finiteCayleyCoefficient]
  have hsum :
      (∑ j ∈ Finset.range N,
        c (j + 1) * (cayleyDividedPowerPolynomial a j).coeff n) =
      (∑ j ∈ Finset.range N,
        d (j + 1) * (cayleyDividedPowerPolynomial a j).coeff n) := by
    apply Finset.sum_congr rfl
    intro j hj
    rw [h j (Finset.mem_range.mp hj)]
  rw [hsum]

end
end KQGPBKQRHilbert.AllDepth
