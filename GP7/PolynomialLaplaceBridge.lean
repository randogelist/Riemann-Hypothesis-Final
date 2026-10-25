import GP7.PolynomialLaplace

/-!
# GP7.PolynomialLaplaceBridge (v0.2.2)

Turn the previously verified coefficient-array integral into a theorem
for arbitrary rational polynomials, and then apply it to `Qpoly N`.
No axioms, no `sorry`, no RH assumption. The native zeta identification
and the positive infinite-remainder theorem remain open formalization targets.

NEW MODULE: source candidate, not independently Lean-compiled here.
-/

namespace GP7

open MeasureTheory Set

/-- The actual Laplace kernel formed from the nonzero coefficients of a rational
polynomial. The coefficient of `y^k` is evaluated against the genuine Gamma-7
kernel `t^6 exp(-(k+1)t)/720`. -/
noncomputable def polynomialLaplaceKernel (p : Polynomial ℚ) (t : ℝ) : ℝ :=
  p.sum fun k c => ((c : ℝ) / 720) * laplaceKernel k t

/-- Every rational polynomial integrates to exactly its rational moment
functional. No assumptions on the polynomial or its degree. -/
theorem polynomialLaplaceKernel_integral (p : Polynomial ℚ) :
    (∫ t : ℝ in Ioi (0 : ℝ), polynomialLaplaceKernel p t) =
      (rationalMomentFunctional p : ℝ) := by
  change
    (∫ t : ℝ in Ioi (0 : ℝ),
      ∑ k ∈ p.support, ((p.coeff k : ℝ) / 720) * laplaceKernel k t) =
        ((∑ k ∈ p.support, p.coeff k * rationalMoment k : ℚ) : ℝ)
  have hi (k : ℕ) :
      IntegrableOn
        (fun t : ℝ => ((p.coeff k : ℝ) / 720) * laplaceKernel k t)
        (Ioi (0 : ℝ)) :=
    (laplaceKernel_integrable k).const_mul ((p.coeff k : ℝ) / 720)
  rw [MeasureTheory.integral_finsetSum p.support (fun k _ => hi k)]
  push_cast
  apply Finset.sum_congr rfl
  intro k _
  rw [MeasureTheory.integral_const_mul]
  calc
    ((p.coeff k : ℝ) / 720) *
        (∫ t : ℝ in Ioi (0 : ℝ), laplaceKernel k t) =
      (p.coeff k : ℝ) * laplaceMomentSeven k := by
        unfold laplaceMomentSeven laplaceKernel
        ring
    _ = (p.coeff k : ℝ) * (rationalMoment k : ℝ) := by
        rw [laplaceMomentSeven_eq]
        simp [rationalMoment, div_eq_mul_inv]

/-- The canonical rational GP-7 approximant is exactly a concrete
continuous Laplace integral, using the already constructed `Qpoly N`. -/
theorem rationalApprox_eq_polynomialLaplace (N : ℕ) :
    (rationalApprox N : ℝ) =
      (64 / 63 : ℝ) *
        (∫ t : ℝ in Ioi (0 : ℝ), polynomialLaplaceKernel (Qpoly N) t) := by
  rw [polynomialLaplaceKernel_integral]
  norm_num [rationalApprox]

end GP7
