import FiniteWitness.NativeXi

/-!
# Formula-derived SOLOBOLO direct-jet successor

SOURCE_ONLY: authored for native Lean 4.33.0; not compiled in this session.

The successor is derived from the normalized derivative formula, rather than
inserted as the definition of a recursively manufactured tower. The derivative
hypothesis remains explicit. In particular, this file does not prove analytic
regularity of the actual logarithmic derivative, GP calibration, positivity,
or acceptance of an RH witness.
-/

noncomputable section

namespace RHFinal.Actual

/-- The normalized direct jet of one fixed function. -/
def directJet (f : ℂ → ℂ) (n : ℕ) (z : ℂ) : ℂ :=
  (-1 : ℂ) ^ n * z ^ (n + 1) * iteratedDeriv n f z /
    (Nat.factorial n : ℂ)

/-- Product-rule differentiation of the literal normalized jet.

The premise states precisely the derivative of the nth derivative that is
needed. It must be supplied from actual analytic regularity, not from a finite
list of point evaluations or from positivity of a separate model.
-/
theorem hasDerivAt_directJet (f : ℂ → ℂ) (n : ℕ) (z : ℂ)
    (h : HasDerivAt (iteratedDeriv n f)
      (iteratedDeriv (n + 1) f z) z) :
    HasDerivAt (directJet f n)
      ((-1 : ℂ) ^ n *
        (((n + 1 : ℕ) : ℂ) * z ^ n * iteratedDeriv n f z +
          z ^ (n + 1) * iteratedDeriv (n + 1) f z) /
        (Nat.factorial n : ℂ)) z := by
  have hp : HasDerivAt (fun w : ℂ => w ^ (n + 1))
      (((n + 1 : ℕ) : ℂ) * z ^ n) z := by
    simpa only [Nat.add_sub_cancel] using hasDerivAt_pow (n + 1) z
  simpa only [directJet, mul_assoc] using
    (((hp.mul h).const_mul ((-1 : ℂ) ^ n)).div_const
      (Nat.factorial n : ℂ))

/-- The exact successor `d_(n+1) = d_n - z d_n'/(n+1)`.

Only the explicit derivative premise and factorial/product algebra enter.
There is no assumption that the successor preserves positivity.
-/
theorem directJet_succ_of_hasDerivAt (f : ℂ → ℂ) (n : ℕ) (z : ℂ)
    (h : HasDerivAt (iteratedDeriv n f)
      (iteratedDeriv (n + 1) f z) z) :
    directJet f (n + 1) z =
      directJet f n z - z * deriv (directJet f n) z /
        ((n + 1 : ℕ) : ℂ) := by
  have hf : (Nat.factorial n : ℂ) ≠ 0 := by
    exact_mod_cast Nat.factorial_ne_zero n
  have hn : (n : ℂ) + 1 ≠ 0 := by
    exact_mod_cast Nat.succ_ne_zero n
  rw [(hasDerivAt_directJet f n z h).deriv]
  simp only [directJet, Nat.factorial_succ, Nat.cast_mul,
    Nat.cast_add, Nat.cast_one, pow_succ]
  field_simp [hf, hn] <;> ring

/-- Literal logarithmic derivative of the recovered completed-zeta descent.

Division is totalized outside the regular locus; no regularity or nonvanishing
claim is hidden in this definition.
-/
def actualLogDerivative (z : ℂ) : ℂ :=
  deriv WitnessSolobolo.actualTheta z / WitnessSolobolo.actualTheta z

/-- The actual-xi direct jet, with the complex anchor left unrestricted. -/
def actualDirectJet (n : ℕ) (z : ℂ) : ℂ :=
  directJet actualLogDerivative n z

/-- Specialization to literal actual-xi data, with regularity still explicit. -/
theorem actualDirectJet_succ_of_hasDerivAt (n : ℕ) (z : ℂ)
    (h : HasDerivAt (iteratedDeriv n actualLogDerivative)
      (iteratedDeriv (n + 1) actualLogDerivative z) z) :
    actualDirectJet (n + 1) z =
      actualDirectJet n z - z * deriv (actualDirectJet n) z /
        ((n + 1 : ℕ) : ℂ) := by
  simpa only [actualDirectJet] using
    directJet_succ_of_hasDerivAt actualLogDerivative n z h

end RHFinal.Actual
