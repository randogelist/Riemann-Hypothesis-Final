import AllDepth.CayleyJetInterpolation
import Derivations.Widder.LocalCalculus
import Mathlib.Analysis.Calculus.IteratedDeriv.Lemmas

/-!
# v0.1.17 — actual xi real Rodrigues derivative: finite Leibniz formula

The new theorem applies the existing mathlib iterated derivative product rule
DIRECTLY to the actual real function f(x) = x * xiR(x), at any real xi-regular
anchor. It is not a substitution of an arbitrary polynomial model and does
not posit any positive xi spectral representation.

It produces the exact finite **raw** sum in terms of the derivatives of f.
The remaining normalization from this raw sum to the n-th canonical Cayley
coefficient is a separate factorial/binomial identity. No RH theorem is
claimed, and the infinite complex Theta germ remains open.
-/

namespace KQGPBKQRHilbert.AllDepth

noncomputable section

/-- Generalized high-derivative Leibniz formula for a coordinate power.
The sum has only n+1 terms because every derivative of x^n above n is zero.
This is valid for any real function analytic at the anchor. -/
theorem real_power_leibniz_finite
    (f : ℝ → ℝ) (a : ℝ) (hf : AnalyticAt ℝ f a) (n : ℕ) :
    iteratedDeriv (2 * n + 1) (fun t : ℝ => t ^ n * f t) a =
      ∑ j ∈ Finset.range (n + 1),
        ((Nat.choose (2 * n + 1) j : ℕ) : ℝ) *
          ((n.descFactorial j : ℕ) : ℝ) *
          a ^ (n - j) * iteratedDeriv (2 * n + 1 - j) f a := by
  have hp : ContDiffAt ℝ (↑(2 * n + 1))
      (fun t : ℝ => t ^ n) a :=
    (analyticAt_id.pow n).contDiffAt
  have hfa : ContDiffAt ℝ (↑(2 * n + 1)) f a :=
    hf.contDiffAt
  have hfull :
      iteratedDeriv (2 * n + 1) (fun t : ℝ => t ^ n * f t) a =
      ∑ j ∈ Finset.range (2 * n + 2),
        ((Nat.choose (2 * n + 1) j : ℕ) : ℝ) *
          ((n.descFactorial j : ℕ) : ℝ) *
          a ^ (n - j) * iteratedDeriv (2 * n + 1 - j) f a := by
    simpa only [iteratedDeriv_pow, mul_assoc] using
      (iteratedDeriv_fun_mul (n := 2 * n + 1) (x := a) hp hfa)
  have htail :
      (∑ k ∈ Finset.range (n + 1),
        ((Nat.choose (2 * n + 1) (n + 1 + k) : ℕ) : ℝ) *
          ((n.descFactorial (n + 1 + k) : ℕ) : ℝ) *
          a ^ (n - (n + 1 + k)) *
          iteratedDeriv (2 * n + 1 - (n + 1 + k)) f a) = 0 := by
    apply Finset.sum_eq_zero
    intro k hk
    have hlt : n < n + 1 + k := by omega
    simp [Nat.descFactorial_of_lt hlt]
  calc
    iteratedDeriv (2 * n + 1) (fun t : ℝ => t ^ n * f t) a =
        ∑ j ∈ Finset.range (2 * n + 2),
          ((Nat.choose (2 * n + 1) j : ℕ) : ℝ) *
            ((n.descFactorial j : ℕ) : ℝ) *
            a ^ (n - j) * iteratedDeriv (2 * n + 1 - j) f a := hfull
    _ = ∑ j ∈ Finset.range (n + 1),
          ((Nat.choose (2 * n + 1) j : ℕ) : ℝ) *
            ((n.descFactorial j : ℕ) : ℝ) *
            a ^ (n - j) * iteratedDeriv (2 * n + 1 - j) f a := by
      rw [show 2 * n + 2 = (n + 1) + (n + 1) by omega,
          Finset.sum_range_add, htail, add_zero]

/-- The actual xi logarithmic-derivative channel has the necessary real
analyticity on precisely SOLOBOLO's existing explicit regular anchors. -/
theorem actual_xi_real_weighted_log_derivative_analytic_at
    (a : ℝ) (ha : a ∈ NativeSoloboloNegativity.xiRegularAnchors) :
    AnalyticAt ℝ
      (fun t : ℝ => t * NativeSoloboloNegativity.xiR t) a := by
  exact analyticAt_id.mul
    (NativeSoloboloNegativity.XI_R_ANALYTIC_AT a ha.1 ha.2)

/-- The Leibniz expansion applies to the LITERAL actual-xi Rodrigues jet,
not merely to the finite interpolating polynomial. -/
theorem actual_xi_raw_rodrigues_leibniz
    (a : ℝ) (ha : a ∈ NativeSoloboloNegativity.xiRegularAnchors)
    (n : ℕ) :
    iteratedDeriv (2 * n + 1)
      (fun t : ℝ => t ^ (n + 1) * NativeSoloboloNegativity.xiR t) a =
      ∑ j ∈ Finset.range (n + 1),
        ((Nat.choose (2 * n + 1) j : ℕ) : ℝ) *
          ((n.descFactorial j : ℕ) : ℝ) *
          a ^ (n - j) *
          iteratedDeriv (2 * n + 1 - j)
            (fun t : ℝ => t * NativeSoloboloNegativity.xiR t) a := by
  have hfun :
      (fun t : ℝ => t ^ n * (t * NativeSoloboloNegativity.xiR t)) =
      (fun t : ℝ => t ^ (n + 1) * NativeSoloboloNegativity.xiR t) := by
    funext t
    simp [pow_succ, mul_assoc]
  have h := real_power_leibniz_finite
    (fun t : ℝ => t * NativeSoloboloNegativity.xiR t) a
    (actual_xi_real_weighted_log_derivative_analytic_at a ha) n
  rwa [hfun] at h

/-- The ACTUAL xi direct Widder coefficient has an exact all-depth finite
real-derivative expansion. No spectral, GP/BKQR, or zero-location hypothesis. -/
theorem actual_xi_widder_direct_finite_leibniz
    (a : ℝ) (ha : a ∈ NativeSoloboloNegativity.xiRegularAnchors)
    (n : ℕ) :
    NativeSoloboloNegativity.xiWidderDirect a n =
      ((-1 : ℝ) ^ n * (4 * a) ^ (n + 1) /
          ((2 * n + 1).factorial : ℝ)) *
      (∑ j ∈ Finset.range (n + 1),
        ((Nat.choose (2 * n + 1) j : ℕ) : ℝ) *
          ((n.descFactorial j : ℕ) : ℝ) *
          a ^ (n - j) *
          iteratedDeriv (2 * n + 1 - j)
            (fun t : ℝ => t * NativeSoloboloNegativity.xiR t) a) := by
  unfold NativeSoloboloNegativity.xiWidderDirect
  rw [actual_xi_raw_rodrigues_leibniz a ha n]

end
end KQGPBKQRHilbert.AllDepth
