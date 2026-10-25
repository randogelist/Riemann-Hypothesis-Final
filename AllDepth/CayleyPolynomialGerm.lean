import AllDepth.ActualMathlibThetaInterface

/-!
# v0.1.8: exact polynomial model of every finite Cayley Taylor jet

The Cayley points involve square roots in the radius.  Their symmetric
shifted divided powers, however, are values of honest polynomials in r.
This removes the r=0 singularity at FINITE order, uniformly in depth,
without any actual-Xi Taylor, sign or RH assumption.

The analytic passage from finite Taylor polynomials to the *actual* Theta
Taylor germ still requires local convergence, Cauchy's formula and
complex-versus-real Widder derivative matching.  It is not hidden here.
-/

namespace KQGPBKQRHilbert.AllDepth

noncomputable section

/-- A polynomial-valued symmetric-power recurrence. The two components
    track the preceding and current shifted divided powers. -/
def cayleyPolynomialPair (a : ℝ) : ℕ → Polynomial ℂ × Polynomial ℂ
  | 0 => (0, 1)
  | n + 1 =>
      let t := cayleyPolynomialPair a n
      (t.2,
       (Polynomial.C (((-4 * a : ℝ) : ℂ)) * Polynomial.X) * t.2 -
         (Polynomial.C (((4 * a ^ 2 : ℝ) : ℂ)) * Polynomial.X) * t.1)

/-- The finite-radius Cayley divided power as a genuine polynomial. -/
def cayleyDividedPowerPolynomial (a : ℝ) (n : ℕ) : Polynomial ℂ :=
  (cayleyPolynomialPair a n).2

/-- Both recurrences agree after polynomial evaluation. This is an
    all-depth identity, requiring no analyticity and no root branch. -/
theorem cayleyPolynomialPair_eval (a r : ℝ) (n : ℕ) :
    Polynomial.eval (r : ℂ) (cayleyPolynomialPair a n).1 =
      (symmetricPowerPair (((-4 * a * r : ℝ) : ℂ))
        (((4 * a ^ 2 * r : ℝ) : ℂ)) n).1 ∧
    Polynomial.eval (r : ℂ) (cayleyPolynomialPair a n).2 =
      (symmetricPowerPair (((-4 * a * r : ℝ) : ℂ))
        (((4 * a ^ 2 * r : ℝ) : ℂ)) n).2 := by
  induction n with
  | zero =>
      simp [cayleyPolynomialPair, symmetricPowerPair]
  | succ n ih =>
      rcases ih with ⟨hprev, hcur⟩
      constructor
      · simpa [cayleyPolynomialPair, symmetricPowerPair] using hcur
      · simp only [cayleyPolynomialPair, symmetricPowerPair,
          Polynomial.eval_sub, Polynomial.eval_mul,
          Polynomial.eval_C, Polynomial.eval_X, hcur, hprev]
        push_cast
        ring

/-- An unconditional exact polynomial realization of the previous
    root-free Cayley divided powers. -/
theorem cayleyDividedPowerPolynomial_eval (a r : ℝ) (n : ℕ) :
    Polynomial.eval (r : ℂ) (cayleyDividedPowerPolynomial a n) =
      shiftedCayleyDividedPower a r n := by
  exact (cayleyPolynomialPair_eval a r n).2

/-- A finite Cayley Taylor jet encoded by one polynomial in r. -/
def finiteCayleyJetPolynomial (a : ℝ) (c : ℕ → ℂ) (N : ℕ) :
    Polynomial ℂ :=
  Polynomial.C (4 * (a : ℂ)) *
    (∑ j ∈ Finset.range N,
      Polynomial.C (c (j + 1)) * cayleyDividedPowerPolynomial a j)

/-- Every finite shifted Cayley jet is polynomial in the radius; its
    root-free value at r=0 is therefore canonical. -/
theorem finiteCayleyJetPolynomial_eval (a r : ℝ) (c : ℕ → ℂ)
    (N : ℕ) :
    Polynomial.eval (r : ℂ) (finiteCayleyJetPolynomial a c N) =
      finiteShiftedCayleyJet a r c N := by
  unfold finiteCayleyJetPolynomial finiteShiftedCayleyJet
  simp only [Polynomial.eval_mul, Polynomial.eval_C]
  congr 1
  rw [Polynomial.eval_finset_sum]
  apply Finset.sum_congr rfl
  intro j hj
  simp only [Polynomial.eval_mul, Polynomial.eval_C]
  rw [cayleyDividedPowerPolynomial_eval]

/-- Every finite Cayley jet has an EXACT finite power-series expansion,
    with its coefficients defined by Polynomial.coeff at arbitrary depth.
    No convergence hypothesis is required for this finite identity. -/
theorem finiteCayleyJetPolynomial_power_expansion
    (a r : ℝ) (c : ℕ → ℂ) (N : ℕ) :
    finiteShiftedCayleyJet a r c N =
      ∑ k ∈ Finset.range ((finiteCayleyJetPolynomial a c N).natDegree + 1),
        (finiteCayleyJetPolynomial a c N).coeff k * (r : ℂ) ^ k := by
  rw [← finiteCayleyJetPolynomial_eval]
  exact Polynomial.eval_eq_sum_range (r : ℂ)

/-- The shifted divided-power base case at the coalesced Cayley pair. -/
theorem shiftedDividedPower_at_zero (a : ℝ) :
    shiftedCayleyDividedPower a 0 0 = 1 := by
  simp [shiftedCayleyDividedPower, symmetricPowerPair]

/-- Every strictly higher shifted divided power vanishes at radius zero. -/
theorem shiftedDividedPower_succ_at_zero (a : ℝ) (n : ℕ) :
    shiftedCayleyDividedPower a 0 (n + 1) = 0 := by
  simp [shiftedCayleyDividedPower, symmetricPowerPair]

/-- All finite Taylor jets, at every degree N+1, have the same
    regularized r=0 value: 4a times the first Taylor coefficient. -/
theorem finiteShiftedCayleyJet_at_zero (a : ℝ) (c : ℕ → ℂ)
    (N : ℕ) :
    finiteShiftedCayleyJet a 0 c (N + 1) = 4 * (a : ℂ) * c 1 := by
  have hsum : ∀ M : ℕ,
      (∑ j ∈ Finset.range (M + 1),
        c (j + 1) * shiftedCayleyDividedPower a 0 j) = c 1 := by
    intro M
    induction M with
    | zero =>
        simp [shiftedDividedPower_at_zero]
    | succ M ih =>
        rw [Finset.sum_range_succ]
        rw [ih]
        simp [shiftedDividedPower_succ_at_zero]
  unfold finiteShiftedCayleyJet
  rw [hsum N]

/-- The CONSTANT polynomial coefficient agrees with the canonical
    regularized r=0 Cayley jet, for every finite Taylor degree N+1. -/
theorem finiteCayleyJetPolynomial_coeff_zero
    (a : ℝ) (c : ℕ → ℂ) (N : ℕ) :
    (finiteCayleyJetPolynomial a c (N + 1)).coeff 0 =
      4 * (a : ℂ) * c 1 := by
  rw [Polynomial.coeff_zero_eq_eval_zero]
  calc
    Polynomial.eval (0 : ℂ) (finiteCayleyJetPolynomial a c (N + 1)) =
        finiteShiftedCayleyJet a 0 c (N + 1) :=
          finiteCayleyJetPolynomial_eval a 0 c (N + 1)
    _ = 4 * (a : ℂ) * c 1 := finiteShiftedCayleyJet_at_zero a c N

/-- The first actual Xi Widder coefficient is the genuine real derivative
    defining the SOLOBOLO base. This is the exact first-jet target. -/
theorem finiteCayleyBase_matches_xi_of_coefficient
    (a : ℝ) (c : ℕ → ℂ) (N : ℕ)
    (hfirst : c 1 =
      ((deriv (fun t : ℝ =>
        (t * NativeSoloboloNegativity.xiR t : ℝ)) a : ℝ) : ℂ)) :
    finiteShiftedCayleyJet a 0 c (N + 1) =
      (NativeSoloboloNegativity.xiWidderMoment a 0 : ℂ) := by
  -- Keep the real derivative opaque while transporting it into ℂ.
  -- In hfirst, the inner `: ℝ` fixes the derivative CODOMAIN as ℝ.
  -- Merely casting an untyped `deriv ...` to ℂ could instead elaborate
  -- the entire derivative as an ℂ-valued function of a real parameter.
  -- `push_cast` on the full goal may change the derivative's codomain.
  let d : ℝ := deriv (fun t : ℝ =>
    t * NativeSoloboloNegativity.xiR t) a
  have hc : c 1 = (d : ℂ) := hfirst
  calc
    finiteShiftedCayleyJet a 0 c (N + 1) =
        4 * (a : ℂ) * c 1 := finiteShiftedCayleyJet_at_zero a c N
    _ = 4 * (a : ℂ) * (d : ℂ) := by rw [hc]
    _ = ((4 * a * d : ℝ) : ℂ) := by norm_cast
    _ = (NativeSoloboloNegativity.xiWidderMoment a 0 : ℂ) := by rfl

end
end KQGPBKQRHilbert.AllDepth
