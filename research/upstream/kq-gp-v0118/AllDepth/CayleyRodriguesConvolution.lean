import AllDepth.CayleyPolynomialRodrigues
import Mathlib.Algebra.BigOperators.NatAntidiagonal

/-!
# v0.1.15 — Polynomial Rodrigues convolution at EVERY depth

Pure polynomial result: the Hasse/Rodrigues coefficient from v0.1.14 equals
exactly the canonical finite Cayley coefficient from v0.1.13. Uses only
Mathlib's coefficient convolution and elementary binomial symmetry.

**Scope:** arbitrary polynomial P and real a, no analytic Theta assumptions,
no zero assumptions, and no Riemann Hypothesis.
-/

namespace KQGPBKQRHilbert.AllDepth

noncomputable section

/-- The generalized binomial product formula at the precise Rodrigues
coefficient degree. The shift of indices is made explicit (2n+1).
This is the algebraic kernel behind the all-depth SOLOBOLO bridge. -/
private theorem shifted_binomial_mul_coeff
    (a : ℂ) (Q : Polynomial ℂ) (n : ℕ) :
    (((Polynomial.X + Polynomial.C a) ^ n) * Q).coeff (2 * n + 1) =
      ∑ k ∈ Finset.range (n + 1),
        (Nat.choose n k : ℂ) * a ^ k * Q.coeff (n + k + 1) := by
  let F : ℕ → ℂ := fun j =>
    a ^ (n - j) * (Nat.choose n j : ℂ) * Q.coeff (2 * n + 1 - j)
  have hmul :
      (((Polynomial.X + Polynomial.C a) ^ n) * Q).coeff (2 * n + 1) =
        ∑ j ∈ Finset.range (2 * n + 2), F j := by
    simp only [Polynomial.coeff_mul,
      Finset.Nat.sum_antidiagonal_eq_sum_range_succ_mk,
      Polynomial.coeff_X_add_C_pow, F]
  have htail :
      (∑ k ∈ Finset.range (n + 1), F ((n + 1) + k)) = 0 := by
    apply Finset.sum_eq_zero
    intro k hk
    have ht : n < n + 1 + k := by omega
    simp [F, Nat.choose_eq_zero_of_lt ht]
  have htruncate :
      (∑ j ∈ Finset.range (2 * n + 2), F j) =
        ∑ j ∈ Finset.range (n + 1), F j := by
    rw [show 2 * n + 2 = (n + 1) + (n + 1) by omega,
      Finset.sum_range_add]
    rw [htail, add_zero]
  have hreflection :
      (∑ j ∈ Finset.range (n + 1), F j) =
        ∑ k ∈ Finset.range (n + 1),
          (Nat.choose n k : ℂ) * a ^ k * Q.coeff (n + k + 1) := by
    rw [← Finset.sum_range_reflect F (n + 1)]
    apply Finset.sum_congr rfl
    intro k hk
    have hkn : k ≤ n := Nat.le_of_lt_succ (Finset.mem_range.mp hk)
    have hshift : n + 1 - 1 - k = n - k := by omega
    have hpower : n - (n - k) = k := by omega
    have hindex : 2 * n + 1 - (n - k) = n + k + 1 := by omega
    have hindex' : 1 + n * 2 - (n - k) = 1 + n + k := by omega
    -- First normalize the reflected index, then simplify the newly formed
    -- subtraction terms. This avoids relying on simp's rewrite order.
    simp only [F, hshift, Nat.choose_symm hkn] <;>
      simp only [hpower, hindex, hindex'] <;> ring
  exact hmul.trans (htruncate.trans hreflection)

/-- The previously open `PolynomialRodriguesConvolution` is now a
pure algebraic theorem, without the assumption as a parameter. -/
theorem polynomial_rodrigues_convolution_all_depth
    (a : ℝ) (P : Polynomial ℂ) (n : ℕ) :
    canonicalCayleyCoefficient a (polynomialTaylorInput a P) n =
      polynomialRodriguesCoefficient a P n := by
  calc
    canonicalCayleyCoefficient a (polynomialTaylorInput a P) n =
        4 * (a : ℂ) * (-4 * (a : ℂ)) ^ n *
          (∑ k ∈ Finset.range (n + 1),
            (Nat.choose n k : ℂ) * (a : ℂ) ^ k *
              ((Polynomial.taylor (a : ℂ)) P).coeff (n + k + 1)) := rfl
    _ = 4 * (a : ℂ) * (-4 * (a : ℂ)) ^ n *
          ((((Polynomial.X + Polynomial.C (a : ℂ)) ^ n) *
            (Polynomial.taylor (a : ℂ)) P).coeff (2 * n + 1)) := by
              rw [shifted_binomial_mul_coeff]
    _ = polynomialRodriguesCoefficient a P n :=
      (polynomial_rodrigues_shifted_product a P n).symm

/-- Fully discharge the named polynomial convolution proposition. -/
theorem polynomialRodriguesConvolution_proven :
    PolynomialRodriguesConvolution := by
  intro a P n
  exact polynomial_rodrigues_convolution_all_depth a P n

/-- Every sufficiently large finite Cayley jet already has its exact
polynomial Rodrigues coefficient. No extra derivative/moment hypotheses. -/
theorem finite_cayley_jet_eq_polynomial_rodrigues
    (a : ℝ) (P : Polynomial ℂ) (N n : ℕ)
    (hN : 2 * n + 1 ≤ N) :
    (finiteCayleyJetPolynomial a (polynomialTaylorInput a P) N).coeff n =
      polynomialRodriguesCoefficient a P n := by
  calc
    (finiteCayleyJetPolynomial a (polynomialTaylorInput a P) N).coeff n =
        stableCayleyCoefficient a (polynomialTaylorInput a P) n :=
          finite_cayley_coefficient_stable_of_le a _ n N hN
    _ = canonicalCayleyCoefficient a (polynomialTaylorInput a P) n :=
          stable_cayley_coefficient_eq_canonical_closed a _ n
    _ = polynomialRodriguesCoefficient a P n :=
          polynomial_rodrigues_convolution_all_depth a P n

end
end KQGPBKQRHilbert.AllDepth
