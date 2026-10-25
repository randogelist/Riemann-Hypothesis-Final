import GrandConditionalMerge.RI01NativeDeterminantUniform
import GrandConditionalMerge.RI01NativeCayleyRootBound
import GrandConditionalMerge.RI01NativeThetaValue
import Merger02.SlitTransport

/-!
# RI-01 N2 macro block I: an actual, explicitly rooted Cayley determinant

This is the *actual* Mathlib slit Theta, not an axiomatized analytic model.
We choose a square root only to name the two Cayley roots; their symmetric
sum/product and the resulting finite polynomial determinant are independent
of any analytic choice of square-root branch.

No RH, H3, or RI-01 is used in these algebraic/actual-Theta statements.
Holomorphy of the resulting symmetric function on the full disk remains
separate and is NOT asserted by this module.
-/

namespace GrandConditionalMerge

open Filter
noncomputable section

private theorem ri01_sqrt_discriminant_sq (r : ℂ) :
    (Complex.sqrt (r * (r - 1))) ^ 2 = r * (r - 1) := by
  simpa only [Complex.sqrt, Nat.cast_ofNat] using
    Complex.cpow_nat_inv_pow (r * (r - 1))
      (by norm_num : (2 : ℕ) ≠ 0)

noncomputable def ri01CayleyRootPlus (a r : ℂ) : ℂ :=
  a * (1 - 2 * r) + 2 * a * Complex.sqrt (r * (r - 1))

noncomputable def ri01CayleyRootMinus (a r : ℂ) : ℂ :=
  a * (1 - 2 * r) - 2 * a * Complex.sqrt (r * (r - 1))

/-- The actual Cayley-root sum, at every complex radius. -/
theorem RI01_EXPLICIT_CAYLEY_ROOT_SUM (a r : ℂ) :
    ri01CayleyRootPlus a r + ri01CayleyRootMinus a r =
      2 * a * (1 - 2 * r) := by
  simp only [ri01CayleyRootPlus, ri01CayleyRootMinus]
  ring

/-- The actual Cayley-root product, without a discriminant hypothesis. -/
theorem RI01_EXPLICIT_CAYLEY_ROOT_PRODUCT (a r : ℂ) :
    ri01CayleyRootPlus a r * ri01CayleyRootMinus a r = a ^ 2 := by
  calc
    ri01CayleyRootPlus a r * ri01CayleyRootMinus a r =
        (a * (1 - 2 * r)) ^ 2 -
          4 * a ^ 2 * (Complex.sqrt (r * (r - 1))) ^ 2 := by
            unfold ri01CayleyRootPlus ri01CayleyRootMinus
            ring
    _ = a ^ 2 := by
      rw [ri01_sqrt_discriminant_sq]
      ring

/-- The explicitly rooted actual symmetric determinant.
Not yet claimed holomorphic; the branch cancellation is proved at finite
Taylor levels and is an analytic-limit target. -/
noncomputable def ri01ActualCayleyDeterminant (a r : ℂ) : ℂ :=
  NativeSolobolo.mathlibSlitTheta (ri01CayleyRootPlus a r) *
    NativeSolobolo.mathlibSlitTheta (ri01CayleyRootMinus a r)

/-- The determinant at radius zero has its exact, nonzero anchor square. -/
theorem RI01_EXPLICIT_ACTUAL_DET_AT_ZERO (a : ℂ) :
    ri01ActualCayleyDeterminant a 0 =
      NativeSolobolo.mathlibSlitTheta a ^ 2 := by
  simp [ri01ActualCayleyDeterminant,
    ri01CayleyRootPlus, ri01CayleyRootMinus, pow_two]

/-- An actual determinant zero is exactly a zero at one of the two roots. -/
theorem RI01_EXPLICIT_ACTUAL_DET_ZERO_IFF (a r : ℂ) :
    ri01ActualCayleyDeterminant a r = 0 ↔
      NativeSolobolo.mathlibSlitTheta (ri01CayleyRootPlus a r) = 0 ∨
      NativeSolobolo.mathlibSlitTheta (ri01CayleyRootMinus a r) = 0 := by
  simp only [ri01ActualCayleyDeterminant, mul_eq_zero]

/-- At all regular positive anchors, the actual determinant starts nonzero. -/
theorem RI01_EXPLICIT_ACTUAL_DET_NONZERO_AT_ZERO (a : ℝ)
    (ha : a ∈ NativeSoloboloNegativity.xiRegularAnchors) :
    ri01ActualCayleyDeterminant (a : ℂ) 0 ≠ 0 := by
  rw [RI01_EXPLICIT_ACTUAL_DET_AT_ZERO]
  exact pow_ne_zero _ (RI01_ACTUAL_THETA_NONZERO_OF_REGULAR a ha)

/-- The *entire arbitrary-degree* finite Taylor determinant evaluates at the
explicit Cayley roots, not merely at an assumed root pair. -/
theorem RI01_EXPLICIT_FINITE_CAYLEY_DET_EVAL (a r : ℂ) (N : ℕ) :
    Polynomial.eval r
      (ri01FiniteLocalThetaCayleyDet a (ri01ActualThetaTaylorPrefix a N)) =
      ri01ThetaListHorner (ri01ActualThetaTaylorPrefix a N)
        (ri01CayleyRootPlus a r - a) *
      ri01ThetaListHorner (ri01ActualThetaTaylorPrefix a N)
        (ri01CayleyRootMinus a r - a) := by
  exact RI01_FINITE_LOCAL_THETA_CAYLEY_DETERMINANT
    a r (ri01CayleyRootPlus a r) (ri01CayleyRootMinus a r)
    (ri01ActualThetaTaylorPrefix a N)
    (RI01_EXPLICIT_CAYLEY_ROOT_SUM a r)
    (RI01_EXPLICIT_CAYLEY_ROOT_PRODUCT a r)

/-- Under the local Taylor convergence hypotheses at these *explicit* roots,
all finite determinants converge to one uniquely named actual determinant. -/
theorem RI01_EXPLICIT_ACTUAL_DET_TENDSTO
    (a r : ℂ)
    (hp : HasSum
      (fun n : ℕ => ri01ActualThetaTaylorCoeff a n *
        (ri01CayleyRootPlus a r - a) ^ n)
      (NativeSolobolo.mathlibSlitTheta (ri01CayleyRootPlus a r)))
    (hm : HasSum
      (fun n : ℕ => ri01ActualThetaTaylorCoeff a n *
        (ri01CayleyRootMinus a r - a) ^ n)
      (NativeSolobolo.mathlibSlitTheta (ri01CayleyRootMinus a r))) :
    Filter.Tendsto
      (fun N : ℕ => Polynomial.eval r
        (ri01FiniteLocalThetaCayleyDet a
          (ri01ActualThetaTaylorPrefix a N)))
      Filter.atTop (nhds (ri01ActualCayleyDeterminant a r)) := by
  exact RI01_ACTUAL_LOCAL_CAYLEY_DETERMINANT_TENDSTO
    a r (ri01CayleyRootPlus a r) (ri01CayleyRootMinus a r)
    (RI01_EXPLICIT_CAYLEY_ROOT_SUM a r)
    (RI01_EXPLICIT_CAYLEY_ROOT_PRODUCT a r) hp hm

end
end GrandConditionalMerge
