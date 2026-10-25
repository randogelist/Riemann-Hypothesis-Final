import Mathlib
import GP7.CoreAlgebra
import GP7.RationalPolynomial

/-!
# GP7.AnalyticObjects

Literal mathematical objects for the three proposed analytic theorems.
IMPORTANT: Their full analytic identifications are NOT proved in this file.
They are objects, not theorem certificates. There is no `sorry` or axiom.
-/

namespace GP7

/-- Genuine Dirichlet-series definition of ζ(7). -/
noncomputable def zetaSeven : ℝ :=
  ∑' n : ℕ, 1 / (((n + 1 : ℕ) : ℝ) ^ 7)

/-- The logarithmic weight, not assumed to be a probability density by definition. -/
noncomputable def densitySeven (y : ℝ) : ℝ :=
  (-Real.log y) ^ 6 / 720

/-- The scalar matrix element of the singular multiplication resolvent. -/
noncomputable def singularResolvent (ε : ℝ) : ℝ :=
  ∫ y in Set.Ioo (0 : ℝ) 1,
    densitySeven y / (1 - y + ε)

/-- Dyadically regularized Li₇; the series is the actual eta-kernel for t ≥ 0. -/
noncomputable def regularizedG (t : ℝ) : ℝ :=
  ∑' n : ℕ,
    (-1 : ℝ) ^ n * Real.exp (-((n + 1 : ℕ) : ℝ) * t) /
      (((n + 1 : ℕ) : ℝ) ^ 7)

/-- The true real weighted-integral error of the exact rational approximant. -/
noncomputable def approximationError (N : ℕ) : ℝ :=
  (64 / 63 : ℝ) *
    ∫ y in Set.Ioo (0 : ℝ) 1,
      R N y / (1 + y) * densitySeven y

end GP7

/- GP7_BRIDGE_PATCH_V014: append-only finite bridge; no imports needed. -/

/-!
# GP7.PointwiseBridge

The real-variable kernel consequences of the checked finite GP7 contraction.
These are unconditional statements about the actual R_N functions, not an
assumed integral identification with zeta(7).
-/
namespace GP7

/-- On the left half of the interval the antisymmetric kernel is nonnegative. -/
theorem R_nonneg_left (N : ℕ) (y : ℝ)
    (hy0 : 0 ≤ y) (hyhalf : y ≤ 1 / 2) : 0 ≤ R N y := by
  have hlin : 0 ≤ (1 - 2 * y) / (3 : ℝ) := by
    apply div_nonneg
    · linarith
    · norm_num
  unfold R
  exact mul_nonneg hlin (pow_nonneg (base_nonneg y) N)

/-- A directly reusable pointwise bound for the integrand of the error. -/
theorem abs_R_div_one_add_le (N : ℕ) (y : ℝ)
    (hy0 : 0 ≤ y) (hy1 : y ≤ 1) :
    |R N y / (1 + y)| ≤ (1 : ℝ) / 3 * ((1 : ℝ) / 161803008) ^ N := by
  have hden : 0 < 1 + y := by linarith
  have hdenge : 1 ≤ 1 + y := by linarith
  have hmul : |R N y| ≤ |R N y| * (1 + y) := by
    nlinarith [mul_nonneg hy0 (abs_nonneg (R N y))]
  calc
    |R N y / (1 + y)| = |R N y| / (1 + y) := by
      rw [abs_div, abs_of_pos hden]
    _ ≤ |R N y| := (div_le_iff₀ hden).2 hmul
    _ ≤ (1 : ℝ) / 3 * ((1 : ℝ) / 161803008) ^ N :=
      R_abs_upper_on_unit N y hy0 hy1

/-- The signed error kernel changes orientation under reflection. -/
theorem R_reflect_pair (N : ℕ) (y : ℝ) :
    R N y / (1 + y) + R N (1 - y) / (2 - y) =
      R N y * (1 / (1 + y) - 1 / (2 - y)) := by
  rw [R_reflect]
  ring

end GP7


/-!
# GP7.FiniteSpectral

An unconditional finite-atomic precursor of the singular resolvent.
In contrast to the scalar rank-one lemma, this records the full
spectral-parameter dependence and its monotonicity.
-/
namespace GP7

/-- A finite positive-measure resolvent matrix element. -/
noncomputable def finiteSpectral (n : ℕ) (a w : Fin n → ℝ) (ε : ℝ) : ℝ :=
  ∑ i : Fin n, w i / (a i + ε)

/-- Exact resolvent identity before passing to an infinite measure. -/
theorem finiteSpectral_difference (n : ℕ) (a w : Fin n → ℝ) (ε δ : ℝ)
    (hε : ∀ i, a i + ε ≠ 0) (hδ : ∀ i, a i + δ ≠ 0) :
    finiteSpectral n a w ε - finiteSpectral n a w δ =
      ∑ i : Fin n, (δ - ε) * w i / ((a i + ε) * (a i + δ)) := by
  unfold finiteSpectral
  rw [← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro i hi
  have h1 : a i + ε ≠ 0 := hε i
  have h2 : a i + δ ≠ 0 := hδ i
  field_simp [h1, h2]
  ring

/-- The resolvent of a positive finite atomic measure is decreasing. -/
theorem finiteSpectral_antitone (n : ℕ) (a w : Fin n → ℝ) (ε δ : ℝ)
    (ha : ∀ i, 0 ≤ a i) (hw : ∀ i, 0 ≤ w i)
    (hε : 0 < ε) (hεδ : ε ≤ δ) :
    finiteSpectral n a w δ ≤ finiteSpectral n a w ε := by
  have hδ : 0 < δ := lt_of_lt_of_le hε hεδ
  have hpε (i : Fin n) : 0 < a i + ε := add_pos_of_nonneg_of_pos (ha i) hε
  have hpδ (i : Fin n) : 0 < a i + δ := add_pos_of_nonneg_of_pos (ha i) hδ
  rw [← sub_nonneg]
  rw [finiteSpectral_difference n a w ε δ
    (fun i => (hpε i).ne') (fun i => (hpδ i).ne')]
  apply Finset.sum_nonneg
  intro i hi
  exact div_nonneg
    (mul_nonneg (sub_nonneg.mpr hεδ) (hw i))
    (mul_nonneg (le_of_lt (hpε i)) (le_of_lt (hpδ i)))

end GP7


/-!
# GP7.FiniteDyadicExp

The original dyadic 7th-weight identity, now with a free real
spectral argument q. Substituting q=exp(-t) is the
finite precursor of the entire analytic dyadic ladder.
-/
namespace GP7

private noncomputable def expTerm (q : ℝ) (n : ℕ) : ℝ :=
  q ^ (n + 1) / (((n + 1 : ℕ) : ℝ) ^ 7)
private noncomputable def expOdd (q : ℝ) (n : ℕ) : ℝ :=
  q ^ (2 * n + 1) / (((2 * n + 1 : ℕ) : ℝ) ^ 7)
private noncomputable def expEven (q : ℝ) (n : ℕ) : ℝ :=
  q ^ (2 * n + 2) / (((2 * n + 2 : ℕ) : ℝ) ^ 7)

/-- Real-valued even-odd partial sum at arbitrary argument. -/
noncomputable def etaExpPartial (q : ℝ) (N : ℕ) : ℝ :=
  ∑ n ∈ Finset.range N, (expOdd q n - expEven q n)

noncomputable def zetaExpPairPartial (q : ℝ) (N : ℕ) : ℝ :=
  ∑ n ∈ Finset.range N, (expOdd q n + expEven q n)

noncomputable def zetaExpPartial (q : ℝ) (N : ℕ) : ℝ :=
  ∑ n ∈ Finset.range N, expTerm q n

private theorem expEven_eq (q : ℝ) (n : ℕ) :
    expEven q n = (1 / 128 : ℝ) * expTerm (q ^ 2) n := by
  have hcast : ((2 * n + 2 : ℕ) : ℝ) = 2 * ((n + 1 : ℕ) : ℝ) := by
    push_cast
    ring
  have hp : q ^ (2 * n + 2) = (q ^ 2) ^ (n + 1) := by
    calc
      q ^ (2 * n + 2) = q ^ (2 * (n + 1)) := by congr 1 <;> omega
      _ = (q ^ 2) ^ (n + 1) := by rw [pow_mul]
  have hn : ((n + 1 : ℕ) : ℝ) ≠ 0 := by
    exact_mod_cast Nat.succ_ne_zero n
  unfold expEven expTerm
  rw [hcast, hp]
  field_simp [hn]
  ring

/-- Dyadic relation, exact at every finite level and for every real q. -/
theorem finite_dyadic_with_argument (q : ℝ) (N : ℕ) :
    etaExpPartial q N =
      zetaExpPairPartial q N - (1 / 64 : ℝ) * zetaExpPartial (q ^ 2) N := by
  calc
    etaExpPartial q N =
        ∑ n ∈ Finset.range N,
          ((expOdd q n + expEven q n) - (1 / 64 : ℝ) * expTerm (q ^ 2) n) := by
      unfold etaExpPartial
      apply Finset.sum_congr rfl
      intro n hn
      rw [expEven_eq]
      ring
    _ = zetaExpPairPartial q N - (1 / 64 : ℝ) * zetaExpPartial (q ^ 2) N := by
      simp [zetaExpPairPartial, zetaExpPartial, Finset.sum_sub_distrib, Finset.mul_sum]

/-- Exact finite dyadic identity at the exponential spectral parameter. -/
theorem finite_dyadic_at_exp (t : ℝ) (N : ℕ) :
    etaExpPartial (Real.exp (-t)) N =
      zetaExpPairPartial (Real.exp (-t)) N -
        (1 / 64 : ℝ) * zetaExpPartial ((Real.exp (-t)) ^ 2) N := by
  exact finite_dyadic_with_argument (Real.exp (-t)) N

end GP7


/- GP7_BRIDGE_PATCH_V014_AUDIT: these statements are finite-level only. -/
#print axioms GP7.R_nonneg_left
#print axioms GP7.abs_R_div_one_add_le
#print axioms GP7.R_reflect_pair
#print axioms GP7.finiteSpectral_difference
#print axioms GP7.finiteSpectral_antitone
#print axioms GP7.finite_dyadic_with_argument
#print axioms GP7.finite_dyadic_at_exp

/-!
GP7 v0.1.5: unconditional integral-moment bridge.

The precise logarithmic-coordinate substitution y = exp(-t) is still a
separate goal.  These declarations prove the Laplace-coordinate integral
and the independent sevenfold unit-interval moment, and identify both
with the rational moments already used by GP7.RationalPolynomial.
No `sorry`, extra `axiom`, or research premise is used.

Audit note: this new Lean source has NOT been compiled in the author's
container. Compile with the existing native Windows Lean 4.33 setup.
-/
namespace GP7

/-- A real Laplace integral with the actual gamma-kernel density. -/
noncomputable def laplaceMomentSeven (k : ℕ) : ℝ :=
  (∫ t : ℝ in Set.Ioi (0 : ℝ),
      t ^ ((7 : ℝ) - 1) * Real.exp (-(((k + 1 : ℕ) : ℝ) * t))) / 720

/-- The sevenfold product of genuine unit-interval power integrals. -/
noncomputable def unitPowerMoment (k : ℕ) : ℝ :=
  ∫ y : ℝ in (0 : ℝ)..1, y ^ k

noncomputable def sevenfoldMoment (k : ℕ) : ℝ :=
  (unitPowerMoment k) ^ 7

/-- Every one-dimensional uniform moment is exact. -/
theorem unitPowerMoment_eq (k : ℕ) :
    unitPowerMoment k = 1 / (((k + 1 : ℕ) : ℝ)) := by
  simp [unitPowerMoment, integral_pow, Nat.cast_add]

/-- Seven genuine integrals recover the weight-seven rational moments. -/
theorem sevenfoldMoment_eq (k : ℕ) :
    sevenfoldMoment k = 1 / (((k + 1 : ℕ) : ℝ) ^ 7) := by
  simp [sevenfoldMoment, unitPowerMoment_eq]

/-- Actual Gamma integral evaluation, with the parameter k+1 > 0. -/
theorem laplaceMomentSeven_eq (k : ℕ) :
    laplaceMomentSeven k = 1 / (((k + 1 : ℕ) : ℝ) ^ 7) := by
  let r : ℝ := ((k + 1 : ℕ) : ℝ)
  have hr : 0 < r := by
    dsimp [r]
    positivity
  have hg : Real.Gamma (7 : ℝ) = 720 := by
    convert Real.Gamma_nat_eq_factorial (6 : ℕ) using 1 <;> norm_num
  have h := Real.integral_rpow_mul_exp_neg_mul_Ioi
    (a := (7 : ℝ)) (r := r) (by norm_num) hr
  change (∫ t : ℝ in Set.Ioi (0 : ℝ),
      t ^ ((7 : ℝ) - 1) * Real.exp (-(r * t))) / 720 = 1 / r ^ 7
  rw [h, hg]
  simp [Real.rpow_natCast, div_pow]

/-- The two independent continuous-moment models coincide. -/
theorem laplaceMomentSeven_eq_sevenfoldMoment (k : ℕ) :
    laplaceMomentSeven k = sevenfoldMoment k := by
  rw [laplaceMomentSeven_eq, sevenfoldMoment_eq]

/-- The scalar moments are literally the rational moments of RationalPolynomial. -/
theorem sevenfoldMoment_eq_rationalMoment (k : ℕ) :
    sevenfoldMoment k = (rationalMoment k : ℝ) := by
  rw [sevenfoldMoment_eq]
  simp [rationalMoment]

/-- The same actual zeta-seven series as a sum of sevenfold Lebesgue moments. -/
theorem zetaSeven_eq_tsum_sevenfold :
    zetaSeven = ∑' k : ℕ, sevenfoldMoment k := by
  unfold zetaSeven
  apply tsum_congr
  intro k
  simp [sevenfoldMoment_eq]

/-- The actual zeta-seven series as a sum of Laplace-Gamma moments. -/
theorem zetaSeven_eq_tsum_laplace :
    zetaSeven = ∑' k : ℕ, laplaceMomentSeven k := by
  rw [zetaSeven_eq_tsum_sevenfold]
  apply tsum_congr
  intro k
  exact (laplaceMomentSeven_eq_sevenfoldMoment k).symm

end GP7

#print axioms GP7.unitPowerMoment_eq
#print axioms GP7.sevenfoldMoment_eq
#print axioms GP7.laplaceMomentSeven_eq
#print axioms GP7.laplaceMomentSeven_eq_sevenfoldMoment
#print axioms GP7.sevenfoldMoment_eq_rationalMoment
#print axioms GP7.zetaSeven_eq_tsum_sevenfold
#print axioms GP7.zetaSeven_eq_tsum_laplace
