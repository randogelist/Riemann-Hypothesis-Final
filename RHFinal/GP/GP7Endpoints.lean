import GP7.ExpDefectBridge
import GP7.FiniteDyadic
import GP7.ScalarRankOne

/-!
# Supplementary GP7 endpoint interface

Exact statements from the imported GP7 construction. These expose a genuine
Laplace integral/rational-moment identity and finite spectral/dyadic results.
They do not identify a GP moment with actual xi or claim an RH implication.

The eight upstream modules are byte-identical source imports. The upstream
package describes earlier user-reported Windows passes; no such pass is
transferred to this repository without the current native build and audit.
These new interface declarations have not been compiled in this session.
-/

namespace RHFinal.GP

open MeasureTheory Set

/-- The literal polynomial Laplace integral equals its rational functional. -/
theorem gp7_polynomial_laplace_calibration (p : Polynomial ℚ) :
    (∫ t : ℝ in Ioi (0 : ℝ), GP7.polynomialLaplaceKernel p t) =
      (GP7.rationalMomentFunctional p : ℝ) :=
  GP7.polynomialLaplaceKernel_integral p

/-- Positivity of the finite atomic spectral data gives resolvent monotonicity. -/
theorem gp7_finite_resolvent_antitone (n : ℕ) (a w : Fin n → ℝ) (ε δ : ℝ)
    (ha : ∀ i, 0 ≤ a i) (hw : ∀ i, 0 ≤ w i)
    (hε : 0 < ε) (hεδ : ε ≤ δ) :
    GP7.finiteSpectral n a w δ ≤ GP7.finiteSpectral n a w ε :=
  GP7.finiteSpectral_antitone n a w ε δ ha hw hε hεδ

/-- A scalar quadratic-form threshold; no infinite operator is inferred. -/
theorem gp7_scalar_rank_one_threshold (a b τ : ℝ) (ha : 0 < a) (hb : b ≠ 0) :
    (∀ x : ℝ, 0 ≤ a * x ^ 2 - τ * (b * x) ^ 2) ↔ τ ≤ a / b ^ 2 :=
  GP7.scalar_rank_one_threshold a b τ ha hb

/-- The finite rational dyadic identity, with no infinite-series limit assumed. -/
theorem gp7_finite_dyadic_identity (N : ℕ) :
    GP7.etaPairPartial N =
      GP7.zetaPairPartial N - (1 / 64 : ℚ) * GP7.zetaPartial N :=
  GP7.finite_dyadic_pair N

end RHFinal.GP
