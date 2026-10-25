import AllDepth.CayleyBinomialTriangle

/-!
# Unconditional top diagonal for the SOLOBOLO Cayley polynomials

For D₀ = 1, D₁ = -4a X, and
Dₙ₊₂ = X((-4a) Dₙ₊₁ - (4a²) Dₙ),
we prove simultaneously:
  (i) coeff(Dₙ,n) = (-4a)^n,
  (ii) coeff(Dₙ,m) = 0 for n<m.
This discharges `CayleyTopDiagonal` from v0.1.11, so the entire binomial
triangle is unconditional. There is no xi-specific hypothesis here.
-/

namespace KQGPBKQRHilbert.AllDepth

noncomputable section

/-- The initial Cayley divided-power polynomial. -/
theorem cayley_poly_base_zero (a : ℝ) :
    cayleyDividedPowerPolynomial a 0 = 1 := by
  rfl

/-- The first Cayley divided-power polynomial. -/
theorem cayley_poly_base_one (a : ℝ) :
    cayleyDividedPowerPolynomial a 1 =
      Polynomial.C (((-4 * a : ℝ) : ℂ)) * Polynomial.X := by
  simp [cayleyDividedPowerPolynomial, cayleyPolynomialPair]

/-- Unified top-coefficient AND vanishing-above-degree theorem, proved
    simultaneously by a paired one-step induction. -/
theorem cayley_top_and_upper_support (a : ℝ) :
    ∀ n : ℕ,
      (cayleyDividedPowerPolynomial a n).coeff n =
          (-4 * (a : ℂ)) ^ n ∧
      ∀ m : ℕ, n < m →
        (cayleyDividedPowerPolynomial a n).coeff m = 0 := by
  let P : ℕ → Prop := fun n =>
    (cayleyDividedPowerPolynomial a n).coeff n =
        (-4 * (a : ℂ)) ^ n ∧
    ∀ m : ℕ, n < m →
      (cayleyDividedPowerPolynomial a n).coeff m = 0
  have hscale : (((-4 * a : ℝ) : ℂ)) = -4 * (a : ℂ) := by
    push_cast
    ring
  have hzero : P 0 := by
    constructor
    · rw [cayley_poly_base_zero]
      simp
    · intro m hm
      rw [cayley_poly_base_zero, Polynomial.coeff_one]
      simp [show m ≠ 0 by omega]
  have hone : P 1 := by
    constructor
    · rw [cayley_poly_base_one, Polynomial.coeff_C_mul_X]
      simp [hscale]
    · intro m hm
      rw [cayley_poly_base_one, Polynomial.coeff_C_mul_X]
      simp [show m ≠ 1 by omega]
  have hstep (n : ℕ) (hn : P n) (hn1 : P (n + 1)) : P (n + 2) := by
    rcases hn with ⟨hn_diag, hn_zero⟩
    rcases hn1 with ⟨hn1_diag, hn1_zero⟩
    constructor
    · have hrec :
          (cayleyDividedPowerPolynomial a (n + 2)).coeff (n + 2) =
            (((-4 * a : ℝ) : ℂ)) *
                (cayleyDividedPowerPolynomial a (n + 1)).coeff (n + 1) -
            (((4 * a ^ 2 : ℝ) : ℂ)) *
                (cayleyDividedPowerPolynomial a n).coeff (n + 1) := by
        simpa only [show (n + 1) + 1 = n + 2 by omega] using
          (cayley_divided_power_coeff_rec a n (n + 1))
      calc
        (cayleyDividedPowerPolynomial a (n + 2)).coeff (n + 2) =
            (((-4 * a : ℝ) : ℂ)) *
                (cayleyDividedPowerPolynomial a (n + 1)).coeff (n + 1) -
            (((4 * a ^ 2 : ℝ) : ℂ)) *
                (cayleyDividedPowerPolynomial a n).coeff (n + 1) := hrec
        _ = (-4 * (a : ℂ)) * (-4 * (a : ℂ)) ^ (n + 1) := by
          rw [hn1_diag, hn_zero (n + 1) (by omega), hscale]
          ring
        _ = (-4 * (a : ℂ)) ^ (n + 2) := by
          calc
            _ = (-4 * (a : ℂ)) ^ (n + 1) * (-4 * (a : ℂ)) := by ring
            _ = (-4 * (a : ℂ)) ^ ((n + 1) + 1) :=
              (pow_succ (-4 * (a : ℂ)) (n + 1)).symm
            _ = (-4 * (a : ℂ)) ^ (n + 2) := by
              simp only [show (n + 1) + 1 = n + 2 by omega]
    · intro m hm
      cases m with
      | zero => omega
      | succ k =>
          have hk1 : n + 1 < k := by omega
          have hk0 : n < k := by omega
          rw [cayley_divided_power_coeff_rec a n k]
          rw [hn1_zero k hk1, hn_zero k hk0]
          ring
  have hall : ∀ n : ℕ, P n ∧ P (n + 1) := by
    intro n
    induction n with
    | zero => exact ⟨hzero, hone⟩
    | succ n ih => exact ⟨ih.2, hstep n ih.1 ih.2⟩
  intro n
  exact (hall n).1

/-- Removes the unique remaining finite-algebra hypothesis of v0.1.11. -/
theorem cayley_top_diagonal_unconditional (a : ℝ) :
    CayleyTopDiagonal a := by
  intro n
  exact (cayley_top_and_upper_support a n).1

/-- All polynomial coefficients above their index are zero. -/
theorem cayley_coeff_above_diagonal_zero
    (a : ℝ) (n m : ℕ) (h : n < m) :
    (cayleyDividedPowerPolynomial a n).coeff m = 0 :=
  (cayley_top_and_upper_support a n).2 m h

/-- Unconditional all-depth binomial triangle, with no `htop` argument. -/
theorem cayley_polynomial_binomial_unconditional
    (a : ℝ) (n k : ℕ) :
    (cayleyDividedPowerPolynomial a (n + k)).coeff n =
      (-4 * (a : ℂ)) ^ n * (a : ℂ) ^ k * (Nat.choose n k : ℂ) :=
  cayley_polynomial_binomial_of_top a (cayley_top_diagonal_unconditional a) n k

end
end KQGPBKQRHilbert.AllDepth
