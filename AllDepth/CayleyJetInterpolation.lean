import AllDepth.CayleyRodriguesConvolution
import Bridge.XiWidderIdentification
import Mathlib.Algebra.Polynomial.OfFn

/-!
# v0.1.16 — Exact finite Taylor-jet interpolation (all depths)

This is an unconditional FINITE algebraic bridge for arbitrary sequences c.
It constructs a polynomial whose Taylor coefficients at a agree with c
up to any chosen finite order. It applies the previously proved polynomial
Rodrigues convolution to these interpolants.

Crucial separation: polynomial interpolation is proved. The higher real
Leibniz/analytic Rodrigues compatibility for *actual xiR* is a distinct,
explicitly UNPROVED predicate below. The infinite actual-Theta Taylor germ,
positive BKQR identification, and RH are not asserted here.
-/

namespace KQGPBKQRHilbert.AllDepth

noncomputable section

/-- Given any coefficient sequence, form its local polynomial in X=z-a
by applying the inverse Taylor translation to the finite coefficient vector. -/
noncomputable def localTaylorInterpolant (a : ℝ) (c : ℕ → ℂ)
    (N : ℕ) : Polynomial ℂ := by
  classical
  exact (Polynomial.taylor (-(a : ℂ)))
    ((Polynomial.ofFn N) (fun i : Fin N => c i.val))

/-- The forward Taylor transform is exactly the finite coefficient vector,
not merely equal at one selected coefficient. -/
theorem local_taylor_interpolant_shift
    (a : ℝ) (c : ℕ → ℂ) (N : ℕ) :
    (Polynomial.taylor (a : ℂ)) (localTaylorInterpolant a c N) =
      (Polynomial.ofFn N) (fun i : Fin N => c i.val) := by
  classical
  unfold localTaylorInterpolant
  rw [Polynomial.taylor_taylor]
  simp

/-- Every requested coefficient is reproduced with no differentiability,
positivity or spectral assumptions. -/
theorem local_taylor_interpolant_coeff
    (a : ℝ) (c : ℕ → ℂ) (N j : ℕ) (hj : j < N) :
    polynomialTaylorInput a (localTaylorInterpolant a c N) j = c j := by
  classical
  unfold polynomialTaylorInput
  rw [local_taylor_interpolant_shift]
  simpa using
    (Polynomial.ofFn_coeff_eq_val_of_lt (fun i : Fin N => c i.val) hj)

/-- All Taylor coefficients beyond the finite interpolation order vanish. -/
theorem local_taylor_interpolant_coeff_zero
    (a : ℝ) (c : ℕ → ℂ) (N j : ℕ) (hj : N ≤ j) :
    polynomialTaylorInput a (localTaylorInterpolant a c N) j = 0 := by
  classical
  unfold polynomialTaylorInput
  rw [local_taylor_interpolant_shift]
  exact Polynomial.ofFn_coeff_eq_zero_of_ge
    (fun i : Fin N => c i.val) hj

/-- The all-depth canonical Cayley coefficient of ANY infinite coefficient
sequence is exactly the polynomial Rodrigues coefficient of its minimal
finite Taylor interpolant. There is NO convergence assumption here. -/
theorem canonical_cayley_eq_local_polynomial_rodrigues
    (a : ℝ) (c : ℕ → ℂ) (n : ℕ) :
    canonicalCayleyCoefficient a c n =
      polynomialRodriguesCoefficient a
        (localTaylorInterpolant a c (2 * n + 2)) n := by
  have hjets : ∀ j : ℕ, j ≤ 2 * n + 1 →
      c j = polynomialTaylorInput a
        (localTaylorInterpolant a c (2 * n + 2)) j := by
    intro j hj
    symm
    exact local_taylor_interpolant_coeff a c (2 * n + 2) j (by omega)
  calc
    canonicalCayleyCoefficient a c n =
        canonicalCayleyCoefficient a
          (polynomialTaylorInput a (localTaylorInterpolant a c (2 * n + 2))) n :=
            canonical_cayley_coefficients_congr_initial
              a c _ n hjets
    _ = polynomialRodriguesCoefficient a
          (localTaylorInterpolant a c (2 * n + 2)) n :=
            polynomial_rodrigues_convolution_all_depth a _ n

/-- Actual finite Cayley polynomial jets have the same stable coefficient. -/
theorem finite_cayley_eq_local_polynomial_rodrigues
    (a : ℝ) (c : ℕ → ℂ) (N n : ℕ) (hN : 2 * n + 1 ≤ N) :
    (finiteCayleyJetPolynomial a c N).coeff n =
      polynomialRodriguesCoefficient a
        (localTaylorInterpolant a c (2 * n + 2)) n := by
  calc
    (finiteCayleyJetPolynomial a c N).coeff n =
        stableCayleyCoefficient a c n :=
          finite_cayley_coefficient_stable_of_le a c n N hN
    _ = canonicalCayleyCoefficient a c n :=
          stable_cayley_coefficient_eq_canonical_closed a c n
    _ = polynomialRodriguesCoefficient a
          (localTaylorInterpolant a c (2 * n + 2)) n :=
          canonical_cayley_eq_local_polynomial_rodrigues a c n

/-- For a real anchor, these are the genuine normalized real Taylor
coefficients of x * xiR(x), coerced into complex numbers AFTER taking the
real iterated derivative. This definition assumes no spectral model. -/
def actualXiRealTaylorInput (a : ℝ) (j : ℕ) : ℂ :=
  ((iteratedDeriv j (fun x : ℝ => x * NativeSoloboloNegativity.xiR x) a : ℝ) : ℂ) /
    (j.factorial : ℂ)

/-- The actual completed-xi real Taylor data has an explicit degree-bounded
polynomial interpolant for every depth. This does NOT yet identify Widder
moments with their analytic Cayley series. -/
theorem actual_xi_finite_polynomial_interpolant
    (a : ℝ) (n : ℕ) :
    ∃ P : Polynomial ℂ,
      ∀ j : ℕ, j ≤ 2 * n + 1 →
        polynomialTaylorInput a P j = actualXiRealTaylorInput a j := by
  refine ⟨localTaylorInterpolant a (actualXiRealTaylorInput a) (2 * n + 2), ?_⟩
  intro j hj
  exact local_taylor_interpolant_coeff a (actualXiRealTaylorInput a)
    (2 * n + 2) j (by omega)

/-- The purely algebraic actual-xi coefficient is exactly the Rodrigues
coefficient of the explicit finite interpolant. -/
theorem actual_xi_finite_interpolant_rodrigues
    (a : ℝ) (n : ℕ) :
    canonicalCayleyCoefficient a (actualXiRealTaylorInput a) n =
      polynomialRodriguesCoefficient a
        (localTaylorInterpolant a (actualXiRealTaylorInput a) (2 * n + 2)) n :=
  canonical_cayley_eq_local_polynomial_rodrigues a _ n

/-- Remaining single real-calculus bridge: normalized iterated derivatives
of x*xiR(x) reproduce the Rodrigues derivative of x^(n+1)*xiR(x).
This is an OPEN definition of a research target, NOT an axiom or proof. -/
def ActualXiRealRodriguesCompatibility : Prop :=
  ∀ (a : ℝ), a ∈ NativeSoloboloNegativity.xiRegularAnchors →
    ∀ n : ℕ,
      polynomialRodriguesCoefficient a
        (localTaylorInterpolant a (actualXiRealTaylorInput a) (2 * n + 2)) n =
          (NativeSoloboloNegativity.xiWidderDirect a n : ℂ)

/-- If the remaining REAL derivative compatibility is proved, the existing
all-depth xiWidderDirect=xiWidderMoment endpoint completes the FINITE
coefficient correspondence, with the assumption displayed explicitly. -/
theorem real_rodrigues_compatibility_implies_actual_widder_coefficients
    (hcompat : ActualXiRealRodriguesCompatibility)
    (a : ℝ) (ha : a ∈ NativeSoloboloNegativity.xiRegularAnchors)
    (n : ℕ) :
    canonicalCayleyCoefficient a (actualXiRealTaylorInput a) n =
      (NativeSoloboloNegativity.xiWidderMoment a n : ℂ) := by
  calc
    canonicalCayleyCoefficient a (actualXiRealTaylorInput a) n =
        polynomialRodriguesCoefficient a
          (localTaylorInterpolant a (actualXiRealTaylorInput a) (2 * n + 2)) n :=
            actual_xi_finite_interpolant_rodrigues a n
    _ = (NativeSoloboloNegativity.xiWidderDirect a n : ℂ) :=
          hcompat a ha n
    _ = (NativeSoloboloNegativity.xiWidderMoment a n : ℂ) := by
          exact congrArg (fun t : ℝ => (t : ℂ))
            (NativeSoloboloNegativity.XI_WIDDER_DIRECT_EQ_RECURSIVE_ON_REGULAR_ANCHORS a ha n)

end
end KQGPBKQRHilbert.AllDepth
