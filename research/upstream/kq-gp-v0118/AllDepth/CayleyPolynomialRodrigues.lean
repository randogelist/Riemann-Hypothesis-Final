import AllDepth.CayleyFiniteClosedFormula
import Mathlib.Algebra.Polynomial.Taylor

/-!
# v0.1.14: polynomial Rodrigues / Hasse bridge, all depths

`Polynomial.taylor` is the exact finite algebraic surrogate for the local
Taylor germ of the actual function f(z)=z*Theta'(z)/Theta(z).

Everything proved here holds for arbitrary complex polynomials and arbitrary
nonnegative/negative real anchors: no RH, spectral model, zero hypothesis,
or xi nonvanishing is assumed. The ACTUAL analytic transfer is OPEN.
-/

namespace KQGPBKQRHilbert.AllDepth

noncomputable section

/-- Taylor coefficients of a genuine complex polynomial at a real anchor. -/
def polynomialTaylorInput (a : ℝ) (P : Polynomial ℂ) (j : ℕ) : ℂ :=
  ((Polynomial.taylor (a : ℂ)) P).coeff j

/-- Exact Hasse derivative of every coefficient; no factorial division is
necessary, avoiding coercion/factorial issues at all depths. -/
theorem polynomial_taylor_input_hasse
    (a : ℝ) (P : Polynomial ℂ) (j : ℕ) :
    polynomialTaylorInput a P j =
      Polynomial.eval (a : ℂ) (Polynomial.hasseDeriv j P) := by
  unfold polynomialTaylorInput
  exact Polynomial.taylor_coeff (a : ℂ) P j

/-- The Taylor polynomial evaluates to the actual polynomial translated
by its anchor; this is an exact full polynomial equality. -/
theorem polynomial_taylor_input_eval_shift
    (a : ℝ) (P : Polynomial ℂ) (z : ℂ) :
    Polynomial.eval z ((Polynomial.taylor (a : ℂ)) P) =
      Polynomial.eval (z + (a : ℂ)) P := by
  exact Polynomial.taylor_eval (a : ℂ) P z

/-- First Taylor coefficient is the ordinary polynomial derivative. -/
theorem polynomial_taylor_input_one
    (a : ℝ) (P : Polynomial ℂ) :
    polynomialTaylorInput a P 1 =
      Polynomial.eval (a : ℂ) (Polynomial.derivative P) := by
  exact Polynomial.taylor_coeff_one (a : ℂ) P

/-- The normalized polynomial Rodrigues expression for the same geometric
coefficient scaling as the SOLOBOLO xi-Widder direct tower. -/
def polynomialRodriguesCoefficient (a : ℝ)
    (P : Polynomial ℂ) (n : ℕ) : ℂ :=
  4 * (a : ℂ) * (-4 * (a : ℂ)) ^ n *
    (((Polynomial.taylor (a : ℂ))
      (Polynomial.X ^ n * P)).coeff (2 * n + 1))

/-- All-depth normalized Rodrigues coefficient is exactly the Hasse
(= factorial-normalized iterated) derivative of X^n P at the anchor. -/
theorem polynomial_rodrigues_hasse
    (a : ℝ) (P : Polynomial ℂ) (n : ℕ) :
    polynomialRodriguesCoefficient a P n =
      4 * (a : ℂ) * (-4 * (a : ℂ)) ^ n *
        Polynomial.eval (a : ℂ)
          (Polynomial.hasseDeriv (2 * n + 1) (Polynomial.X ^ n * P)) := by
  unfold polynomialRodriguesCoefficient
  rw [Polynomial.taylor_coeff]

/-- Translation converts the Rodrigues derivative into the coefficient
of a polynomial product in the local variable X=z-a. -/
theorem polynomial_rodrigues_shifted_product
    (a : ℝ) (P : Polynomial ℂ) (n : ℕ) :
    polynomialRodriguesCoefficient a P n =
      4 * (a : ℂ) * (-4 * (a : ℂ)) ^ n *
        (((Polynomial.X + Polynomial.C (a : ℂ)) ^ n *
           (Polynomial.taylor (a : ℂ)) P).coeff (2 * n + 1)) := by
  unfold polynomialRodriguesCoefficient
  rw [Polynomial.taylor_mul, Polynomial.taylor_X_pow]

/-- At n=0 the polynomial Rodrigues coefficient is 4a times the first
Taylor derivative: the already verified SOLOBOLO normalization. -/
theorem polynomial_rodrigues_zero
    (a : ℝ) (P : Polynomial ℂ) :
    polynomialRodriguesCoefficient a P 0 =
      4 * (a : ℂ) * Polynomial.eval (a : ℂ) (Polynomial.derivative P) := by
  simp [polynomialRodriguesCoefficient]

/-- The polynomial Rodrigues and canonical finite Cayley coefficients
match unconditionally at the already proved first depth. -/
theorem polynomial_cayley_rodrigues_zero
    (a : ℝ) (P : Polynomial ℂ) :
    canonicalCayleyCoefficient a (polynomialTaylorInput a P) 0 =
      polynomialRodriguesCoefficient a P 0 := by
  rw [canonical_cayley_coefficient_zero,
      polynomial_taylor_input_one,
      polynomial_rodrigues_zero]

/-- NEXT purely algebraic lemma (definition of an open proposition, NOT an
axiom, theorem, or assumed witness): generalized convolution for n>0.
It would extend the n=0 result above to all polynomial inputs. -/
def PolynomialRodriguesConvolution : Prop :=
  ∀ (a : ℝ) (P : Polynomial ℂ) (n : ℕ),
    canonicalCayleyCoefficient a (polynomialTaylorInput a P) n =
      polynomialRodriguesCoefficient a P n

end
end KQGPBKQRHilbert.AllDepth
