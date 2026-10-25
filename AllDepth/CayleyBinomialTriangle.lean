import AllDepth.CayleyStableCoefficients

/-!
# v0.1.11: Pascal diagonal for the all-depth Cayley polynomial coefficients

All statements in this file are algebraic. The boundary/degree lemma and
binomial recurrence concern the exact Cayley polynomials from v0.1.8.
There are no xi spectral or RH assumptions and no exponent 2^k.

The resulting diagonal formula is the discrete ingredient needed to derive
[r^n] J_N = 4a (-4a)^n ∑_{k=0}^n choose(n,k) a^k c_(n+k+1).
This last finite-sum reindexing and the Rodrigues analytic bridge are tracked
as separate next targets, not treated as proved here.
-/

namespace KQGPBKQRHilbert.AllDepth

noncomputable section

/-- The explicit two-variable Pascal triangle underlying the radius powers. -/
def cayleyBinomialTriangle (a : ℝ) (n k : ℕ) : ℂ :=
  (-4 * (a : ℂ)) ^ n * (a : ℂ) ^ k * (Nat.choose n k : ℂ)

/-- Exact boundary on the top radius diagonal. -/
theorem cayley_binomial_triangle_top (a : ℝ) (n : ℕ) :
    cayleyBinomialTriangle a n 0 = (-4 * (a : ℂ)) ^ n := by
  simp [cayleyBinomialTriangle]

/-- The triangle vanishes beyond its binomial support. -/
theorem cayley_binomial_triangle_outside (a : ℝ) (n k : ℕ)
    (hk : n < k) : cayleyBinomialTriangle a n k = 0 := by
  simp [cayleyBinomialTriangle, Nat.choose_eq_zero_of_lt hk]

/-- The binomial triangle obeys the *same* two-step Cayley recurrence.
    In particular the second scalar is the NEGATIVE of 4a². -/
theorem cayley_binomial_triangle_pascal (a : ℝ) (n k : ℕ) :
    cayleyBinomialTriangle a (n + 1) (k + 1) =
      (((-4 * a : ℝ) : ℂ)) * cayleyBinomialTriangle a n (k + 1) -
      (((4 * a ^ 2 : ℝ) : ℂ)) * cayleyBinomialTriangle a n k := by
  have ha : (((-4 * a : ℝ) : ℂ)) = -4 * (a : ℂ) := by
    push_cast
    ring
  have hb : (((4 * a ^ 2 : ℝ) : ℂ)) = 4 * (a : ℂ) ^ 2 := by
    push_cast
    ring
  rw [ha, hb]
  simp only [cayleyBinomialTriangle, Nat.choose_succ_succ',
    Nat.cast_add, pow_succ]
  ring

/-- The actual polynomial coefficients satisfy the matching Pascal step. -/
theorem cayley_polynomial_diagonal_rec (a : ℝ) (n k : ℕ) :
    (cayleyDividedPowerPolynomial a ((n + 1) + (k + 1))).coeff (n + 1) =
      (((-4 * a : ℝ) : ℂ)) *
          (cayleyDividedPowerPolynomial a (n + (k + 1))).coeff n -
      (((4 * a ^ 2 : ℝ) : ℂ)) *
          (cayleyDividedPowerPolynomial a (n + k)).coeff n := by
  have hidx : (n + 1) + (k + 1) = (n + k) + 2 := by omega
  have hidx1 : n + (k + 1) = (n + k) + 1 := by omega
  rw [hidx, hidx1]
  exact cayley_divided_power_coeff_rec a (n + k) n

/-- General boundary-to-all-depth theorem: if the top diagonal is fixed,
    the v0.1.10 polynomial recurrence fixes EVERY deeper diagonal. This
    theorem has only an explicitly stated top-diagonal hypothesis. -/
theorem cayley_polynomial_diagonal_of_top
    (a : ℝ)
    (htop : ∀ m : ℕ,
      (cayleyDividedPowerPolynomial a m).coeff m =
        (-4 * (a : ℂ)) ^ m) :
    ∀ (n k : ℕ),
      (cayleyDividedPowerPolynomial a (n + k)).coeff n =
        cayleyBinomialTriangle a n k := by
  intro n
  induction n with
  | zero =>
      intro k
      cases k with
      | zero =>
          simpa [cayley_binomial_triangle_top] using htop 0
      | succ k =>
          simp only [Nat.zero_add]
          rw [cayley_divided_power_coeff_zero_succ]
          exact (cayley_binomial_triangle_outside a 0 (k + 1) (by omega)).symm
  | succ n ih =>
      intro k
      cases k with
      | zero =>
          simpa only [Nat.add_zero, cayley_binomial_triangle_top] using htop (n + 1)
      | succ k =>
          calc
            (cayleyDividedPowerPolynomial a ((n + 1) + (k + 1))).coeff (n + 1) =
                (((-4 * a : ℝ) : ℂ)) *
                    (cayleyDividedPowerPolynomial a (n + (k + 1))).coeff n -
                (((4 * a ^ 2 : ℝ) : ℂ)) *
                    (cayleyDividedPowerPolynomial a (n + k)).coeff n :=
                      cayley_polynomial_diagonal_rec a n k
            _ = (((-4 * a : ℝ) : ℂ)) * cayleyBinomialTriangle a n (k + 1) -
                  (((4 * a ^ 2 : ℝ) : ℂ)) * cayleyBinomialTriangle a n k := by
                  rw [ih (k + 1), ih k]
            _ = cayleyBinomialTriangle a (n + 1) (k + 1) :=
                  (cayley_binomial_triangle_pascal a n k).symm

/-- The one genuinely remaining finite-algebra input: leading radius
    coefficient of the n-th divided-power polynomial. No analytic axiom. -/
def CayleyTopDiagonal (a : ℝ) : Prop :=
  ∀ n : ℕ, (cayleyDividedPowerPolynomial a n).coeff n =
    (-4 * (a : ℂ)) ^ n

/-- The complete binomial Cayley coefficient identity follows from the
    single named top-diagonal obligation, without extra per-depth inputs. -/
theorem cayley_polynomial_binomial_of_top
    (a : ℝ) (htop : CayleyTopDiagonal a) (n k : ℕ) :
    (cayleyDividedPowerPolynomial a (n + k)).coeff n =
      (-4 * (a : ℂ)) ^ n * (a : ℂ) ^ k * (Nat.choose n k : ℂ) := by
  exact cayley_polynomial_diagonal_of_top a htop n k

end
end KQGPBKQRHilbert.AllDepth
