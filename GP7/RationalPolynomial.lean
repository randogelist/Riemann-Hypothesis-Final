import Mathlib

/-!
# GP7.RationalPolynomial

The real error weight comes from an actual rational polynomial quotient.
This is finite polynomial algebra, not the yet-unformalized integral bridge.
-/

namespace GP7

private noncomputable def tP : Polynomial ℚ := Polynomial.X * (1 - Polynomial.X)
private noncomputable def aP : Polynomial ℚ := tP * (8 * tP - 1)
private noncomputable def uP : Polynomial ℚ := Polynomial.C (1 / 3) * (1 - 2 * Polynomial.X)
private noncomputable def vP : Polynomial ℚ := Polynomial.C (1 / 34) * aP

/-- The exact polynomial of GP7-RATIONAL, with rational coefficients. -/
noncomputable def Rpoly (N : ℕ) : Polynomial ℚ := uP * (uP ^ 4 * vP ^ 2) ^ N

theorem Rpoly_eval_neg_one (N : ℕ) : (Rpoly N).eval (-1) = 1 := by
  simp [Rpoly, uP, vP, aP, tP]
  norm_num

/-- The quotient `(1 - R_N(X))/(1 + X)` is a rational polynomial. -/
theorem rational_quotient_exists (N : ℕ) :
    ∃ q : Polynomial ℚ, (Polynomial.X + 1) * q = 1 - Rpoly N := by
  have hz : (1 - Rpoly N).IsRoot (-1) := by
    change Polynomial.eval (-1) (1 - Rpoly N) = 0
    simp [Rpoly_eval_neg_one]
  have hd : (Polynomial.X - Polynomial.C (-1 : ℚ)) ∣ (1 - Rpoly N) :=
    (Polynomial.dvd_iff_isRoot).2 hz
  obtain ⟨q, hq⟩ := hd
  refine ⟨q, ?_⟩
  simpa using hq.symm

/-- The actual quotient produced by monic polynomial division. -/
noncomputable def Qpoly (N : ℕ) : Polynomial ℚ :=
  (1 - Rpoly N) /ₘ (Polynomial.X - Polynomial.C (-1))

theorem Qpoly_factor (N : ℕ) :
    (Polynomial.X + 1) * Qpoly N = 1 - Rpoly N := by
  have hz : (1 - Rpoly N).IsRoot (-1) := by
    change Polynomial.eval (-1) (1 - Rpoly N) = 0
    simp [Rpoly_eval_neg_one]
  simpa [Qpoly] using
    (Polynomial.mul_divByMonic_eq_iff_isRoot).2 hz

/-- Rational moment with the genuine weight-seven coefficient `(k+1)⁻⁷`. -/
def rationalMoment (k : ℕ) : ℚ := 1 / (((k + 1 : ℕ) : ℚ) ^ 7)

/-- Polynomial integration against the rational moment functional. -/
noncomputable def rationalMomentFunctional (p : Polynomial ℚ) : ℚ :=
  p.sum fun k c => c * rationalMoment k

/-- Exact rational approximation, defined without decimals or floating point. -/
noncomputable def rationalApprox (N : ℕ) : ℚ :=
  (64 / 63 : ℚ) * rationalMomentFunctional (Qpoly N)

end GP7
