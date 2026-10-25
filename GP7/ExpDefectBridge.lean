import GP7.PolynomialLaplaceBridge

/-!
# GP7.ExpDefectBridge (v0.2.7 exponent-cast and associativity patch)

Pointwise bridge between the *actual* polynomial Laplace integral and the
quotient polynomial `(1 - Rpoly N) / (1 + X)`, evaluated at `X = exp (-t)`.
All statements are unconditional.  This module does not claim the still-open
zeta/eta integral binding or positivity of its signed error.
This candidate has not been compiled in the authoring environment.
-/

namespace GP7

open MeasureTheory Set

/-- Factor one genuine Laplace kernel into its Gamma-7 density and
an ordinary exponential monomial. -/
theorem laplaceKernel_factor (k : ℕ) (t : ℝ) :
    laplaceKernel k t =
      t ^ 6 * Real.exp (-t) * (Real.exp (-t)) ^ k := by
  have he :
      Real.exp (-((((k + 1 : ℕ) : ℝ)) * t)) =
        Real.exp (-t) * (Real.exp (-t)) ^ k := by
    calc
      Real.exp (-((((k + 1 : ℕ) : ℝ)) * t)) =
          Real.exp ((-t) + ((k : ℝ) * (-t))) := by
            congr 1
            push_cast
            ring
      _ = Real.exp (-t) * Real.exp ((k : ℝ) * (-t)) :=
            Real.exp_add _ _
      _ = Real.exp (-t) * (Real.exp (-t)) ^ k := by
            rw [Real.exp_nat_mul]
  unfold laplaceKernel
  rw [he]
  have hpow : t ^ ((7 : ℝ) - 1) = t ^ (6 : ℕ) := by
    calc
      t ^ ((7 : ℝ) - 1) = t ^ ((6 : ℕ) : ℝ) := by norm_num
      _ = t ^ (6 : ℕ) := Real.rpow_natCast t 6
  rw [hpow]
  simp only [mul_assoc]

/-- The polynomial Laplace kernel equals the Gamma-7 weight times
actual polynomial evaluation at the positive real point `exp (-t)`. -/
theorem polynomialLaplaceKernel_pointwise (p : Polynomial ℚ) (t : ℝ) :
    polynomialLaplaceKernel p t =
      (t ^ 6 * Real.exp (-t) / 720) *
        Polynomial.eval₂ (algebraMap ℚ ℝ) (Real.exp (-t)) p := by
  unfold polynomialLaplaceKernel
  rw [Polynomial.eval₂_eq_sum]
  change
    (∑ k ∈ p.support, ((p.coeff k : ℝ) / 720) * laplaceKernel k t) =
      (t ^ 6 * Real.exp (-t) / 720) *
        (∑ k ∈ p.support, (p.coeff k : ℝ) * (Real.exp (-t)) ^ k)
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro k _
  rw [laplaceKernel_factor]
  ring

/-- Transport the previously checked polynomial factorization to every
real evaluation point, with no denominator division. -/
theorem Qpoly_eval₂_factor (N : ℕ) (y : ℝ) :
    (1 + y) * Polynomial.eval₂ (algebraMap ℚ ℝ) y (Qpoly N) =
      1 - Polynomial.eval₂ (algebraMap ℚ ℝ) y (Rpoly N) := by
  have h := congrArg
    (fun p : Polynomial ℚ => Polynomial.eval₂ (algebraMap ℚ ℝ) y p)
    (Qpoly_factor N)
  calc
    (1 + y) * Polynomial.eval₂ (algebraMap ℚ ℝ) y (Qpoly N) =
        (y + 1) * Polynomial.eval₂ (algebraMap ℚ ℝ) y (Qpoly N) := by
          rw [add_comm 1 y]
    _ = 1 - Polynomial.eval₂ (algebraMap ℚ ℝ) y (Rpoly N) := by
          simpa using h

/-- The quotient formula is legal away from `y = -1`. -/
theorem Qpoly_eval₂_ratio (N : ℕ) (y : ℝ) (hy : 1 + y ≠ 0) :
    Polynomial.eval₂ (algebraMap ℚ ℝ) y (Qpoly N) =
      (1 - Polynomial.eval₂ (algebraMap ℚ ℝ) y (Rpoly N)) / (1 + y) := by
  apply (eq_div_iff hy).2
  simpa [mul_comm] using Qpoly_eval₂_factor N y

/-- The canonical rational approximant is a *literal* continuous
Laplace integral of its polynomial spectral defect.  This is an analytic
identity independent of RH, and contains no unproved zeta identification. -/
theorem rationalApprox_eq_expDefect_integral (N : ℕ) :
    (rationalApprox N : ℝ) =
      (64 / 63 : ℝ) *
      (∫ t : ℝ in Ioi (0 : ℝ),
        (t ^ 6 * Real.exp (-t) / 720) *
          ((1 - Polynomial.eval₂ (algebraMap ℚ ℝ)
                    (Real.exp (-t)) (Rpoly N)) / (1 + Real.exp (-t)))) := by
  calc
    (rationalApprox N : ℝ) =
        (64 / 63 : ℝ) *
          (∫ t : ℝ in Ioi (0 : ℝ), polynomialLaplaceKernel (Qpoly N) t) :=
            rationalApprox_eq_polynomialLaplace N
    _ = _ := by
      congr 1
      apply MeasureTheory.integral_congr_ae
      filter_upwards [] with t
      rw [polynomialLaplaceKernel_pointwise]
      have hy : (1 : ℝ) + Real.exp (-t) ≠ 0 := by positivity
      rw [Qpoly_eval₂_ratio N (Real.exp (-t)) hy]

end GP7
