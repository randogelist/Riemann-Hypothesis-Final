import GP7.AnalyticObjects

/-!
# GP7.PolynomialLaplace (v0.1.9)

Finite polynomial Laplace integration, based on the actual integral moments
kernel-checked in v0.1.8.  No RH assumption or synthetic moment axiom.

This module is a *new compilation target*, not a claimed Lean-verified result.
The native Dirichlet zeta/eta identity and the infinite-dimensional operator
bridges remain separate open formalization obligations.
-/

namespace GP7

open MeasureTheory Set

/-- The genuine order-seven Laplace density before normalizing by 720. -/
noncomputable def laplaceKernel (k : ℕ) (t : ℝ) : ℝ :=
  t ^ ((7 : ℝ) - 1) *
    Real.exp (-(((k + 1 : ℕ) : ℝ) * t))

/-- Integrability is deduced from the *nonzero actual Gamma integral*, rather
than inferred from an arbitrary assignment to an integral. -/
theorem laplaceKernel_integrable (k : ℕ) :
    IntegrableOn (laplaceKernel k) (Ioi (0 : ℝ)) := by
  have hnonzero : laplaceMomentSeven k ≠ 0 := by
    rw [laplaceMomentSeven_eq]
    positivity
  have hIntegral :
      (∫ t : ℝ in Ioi (0 : ℝ), laplaceKernel k t) ≠ 0 := by
    intro hz
    apply hnonzero
    change (∫ t : ℝ in Ioi (0 : ℝ), laplaceKernel k t) / 720 = 0
    rw [hz]
    norm_num
  exact Integrable.of_integral_ne_zero hIntegral

/-- A finite linear combination of the actual Laplace kernels.
The coefficient array represents the rational polynomial
`∑ j, c_j * y^j` after substituting `y = exp(-t)`. -/
noncomputable def finiteLaplaceKernel (n : ℕ) (c : Fin n → ℚ) (t : ℝ) : ℝ :=
  ∑ j : Fin n, ((c j : ℝ) / 720) * laplaceKernel j.val t

/-- Actual integration of *any finite rational coefficient polynomial*, with
no integrability parameter or other extra theorem hypothesis. -/
theorem finiteLaplaceKernel_integral (n : ℕ) (c : Fin n → ℚ) :
    (∫ t : ℝ in Ioi (0 : ℝ), finiteLaplaceKernel n c t) =
      ∑ j : Fin n, (c j : ℝ) / (((j.val + 1 : ℕ) : ℝ) ^ 7) := by
  have hterm (j : Fin n) :
      IntegrableOn
        (fun t : ℝ => ((c j : ℝ) / 720) * laplaceKernel j.val t)
        (Ioi (0 : ℝ)) :=
    (laplaceKernel_integrable j.val).const_mul ((c j : ℝ) / 720)
  unfold finiteLaplaceKernel
  rw [MeasureTheory.integral_finsetSum Finset.univ (fun j _ => hterm j)]
  apply Finset.sum_congr rfl
  intro j _
  rw [MeasureTheory.integral_const_mul]
  calc
    ((c j : ℝ) / 720) *
        (∫ t : ℝ in Ioi (0 : ℝ), laplaceKernel j.val t) =
        (c j : ℝ) * laplaceMomentSeven j.val := by
      unfold laplaceMomentSeven laplaceKernel
      ring
    _ = (c j : ℝ) / (((j.val + 1 : ℕ) : ℝ) ^ 7) := by
      rw [laplaceMomentSeven_eq]
      ring

/-- The full finite integral equals a *rational number* (embedded in ℝ), not
merely a real sum with rational-looking summands. -/
theorem finiteLaplaceKernel_integral_rational (n : ℕ) (c : Fin n → ℚ) :
    (∫ t : ℝ in Ioi (0 : ℝ), finiteLaplaceKernel n c t) =
      ((∑ j : Fin n, c j * rationalMoment j.val : ℚ) : ℝ) := by
  rw [finiteLaplaceKernel_integral]
  push_cast
  apply Finset.sum_congr rfl
  intro j _
  simp [rationalMoment, div_eq_mul_inv]

end GP7
