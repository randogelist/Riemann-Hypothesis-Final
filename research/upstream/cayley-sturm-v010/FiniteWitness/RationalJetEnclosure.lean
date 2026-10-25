import FiniteWitness.CofinalCalibration

/-!
# A terminating rational Taylor-box certificate (one finite layer)

The finite checker verifies a rational budget that a POSITIVE spectrum is
within an interval box for the FULL complex Taylor jet. The analytic validity
of that box is a separate, explicitly named proposition.

No decimal floating point, numerical sampling, imported RH axiom, or hidden
continuous test is used in the Boolean checker.
-/


namespace WitnessSolobolo

/-- Rational enclosure with real center and independent Re/Im radii. -/
structure RationalJetRectangle (N : ℕ) where
  center : Fin (N + 1) → ℚ
  radiusRe : Fin (N + 1) → ℚ
  radiusIm : Fin (N + 1) → ℚ

/-- FINITE exact-rational checker: all inequalities are decidable. -/
def checkJetRectangle (w : FiniteWitness) (N : ℕ)
    (r : RationalJetRectangle N) : Bool :=
  decide (∀ j : Fin (N + 1),
    0 ≤ r.radiusRe j ∧ 0 ≤ r.radiusIm j ∧
      (Nat.factorial j.val : ℚ) *
        (|elementary w N j.val - r.center j| +
          r.radiusRe j + r.radiusIm j) ≤ (1 / 2 : ℚ) ^ N)

/-- THIS is the analytic enclosure obligation, not checked by rational
arithmetic. It refers to the actual completed zeta function. -/
def ActualXiJetInside (N : ℕ) (r : RationalJetRectangle N) : Prop :=
  ∀ j : Fin (N + 1),
    |(actualComplexCoefficient j.val).re - (r.center j : ℝ)| ≤
      (r.radiusRe j : ℝ) ∧
    |(actualComplexCoefficient j.val).im| ≤ (r.radiusIm j : ℝ)

/-- A checked rational rectangle together with a VALID analytic enclosure
produces the exact finite layer needed by the RH architecture. -/
theorem checkJetRectangle_sound (w : FiniteWitness) (N : ℕ)
    (r : RationalJetRectangle N)
    (hc : checkJetRectangle w N r = true)
    (hXi : ActualXiJetInside N r) :
    ∀ j : ℕ, j ≤ N →
      (Nat.factorial j : ℝ) *
        ‖(elementary w N j : ℂ) - actualComplexCoefficient j‖ ≤
          (1 / 2 : ℝ) ^ N := by
  intro j hj
  let ij : Fin (N + 1) := ⟨j, Nat.lt_succ_of_le hj⟩
  have hq := (of_decide_eq_true hc :
    ∀ j : Fin (N + 1),
      0 ≤ r.radiusRe j ∧ 0 ≤ r.radiusIm j ∧
        (Nat.factorial j.val : ℚ) *
          (|elementary w N j.val - r.center j| +
            r.radiusRe j + r.radiusIm j) ≤ (1 / 2 : ℚ) ^ N) ij
  have hx := (hXi ij).1
  have hy := (hXi ij).2
  have hbudget :
      (Nat.factorial j : ℝ) *
        (|(elementary w N j : ℝ) - (r.center ij : ℝ)| +
          (r.radiusRe ij : ℝ) + (r.radiusIm ij : ℝ)) ≤
            (1 / 2 : ℝ) ^ N := by
    exact_mod_cast hq.2.2
  let z : ℂ := (elementary w N j : ℂ) - actualComplexCoefficient j
  have hre : |z.re| ≤
      |(elementary w N j : ℝ) - (r.center ij : ℝ)| +
        (r.radiusRe ij : ℝ) := by
    have hsub :
        (elementary w N j : ℝ) - (actualComplexCoefficient j).re =
        ((elementary w N j : ℝ) - (r.center ij : ℝ)) +
        ((r.center ij : ℝ) - (actualComplexCoefficient j).re) := by ring
    have htri := abs_add_le
      ((elementary w N j : ℝ) - (r.center ij : ℝ))
      ((r.center ij : ℝ) - (actualComplexCoefficient j).re)
    have htail :
        |(r.center ij : ℝ) - (actualComplexCoefficient j).re| ≤
        (r.radiusRe ij : ℝ) := by simpa [abs_sub_comm] using hx
    simpa [z, hsub] using (htri.trans (add_le_add_left htail _))
  have him : |z.im| ≤ (r.radiusIm ij : ℝ) := by
    simpa [z] using hy
  have hnorm : ‖z‖ ≤
      |(elementary w N j : ℝ) - (r.center ij : ℝ)| +
        (r.radiusRe ij : ℝ) + (r.radiusIm ij : ℝ) := by
    calc
      ‖z‖ ≤ |z.re| + |z.im| := Complex.norm_le_abs_re_add_abs_im z
      _ ≤ (|(elementary w N j : ℝ) - (r.center ij : ℝ)| +
          (r.radiusRe ij : ℝ)) + (r.radiusIm ij : ℝ) := add_le_add hre him
  have hf : 0 ≤ (Nat.factorial j : ℝ) := by positivity
  calc
    (Nat.factorial j : ℝ) * ‖z‖ ≤
      (Nat.factorial j : ℝ) *
        (|(elementary w N j : ℝ) - (r.center ij : ℝ)| +
          (r.radiusRe ij : ℝ) + (r.radiusIm ij : ℝ)) :=
        mul_le_mul_of_nonneg_left hnorm hf
    _ ≤ (1 / 2 : ℝ) ^ N := hbudget

/-- A FINITE arithmetic program with bounded sums, sufficient to express
rational harmonic approximations as N increases. A language containing only
rational functions of N could NOT approximate arbitrary irrational jet values.
Bounded sums are essential for the ODD_ZETA/GP connection. -/
inductive RatProgram where
  | basic (t : RatTerm)
  | add (p q : RatProgram)
  | mul (p q : RatProgram)
  | div (p q : RatProgram)
  | sumSlots (p : RatProgram)
  deriving Repr

/-- Total terminating rational semantics, including finite harmonic sums. -/
def RatProgram.eval : RatProgram → ℕ → ℕ → ℚ
  | .basic t, N, j => t.eval N j
  | .add p q, N, j => p.eval N j + q.eval N j
  | .mul p q, N, j => p.eval N j * q.eval N j
  | .div p q, N, j => p.eval N j / q.eval N j
  | .sumSlots p, N, _ => ∑ i ∈ Finset.range (N + 1), p.eval N i

/-- Reject zero denominators in EVERY rational subexpression, rather than
relying on Lean's totalized division on ℚ. -/
def RatTerm.denominatorsSafe : RatTerm → ℕ → ℕ → Bool
  | .lit _, _, _ => true
  | .level, _, _ => true
  | .slot, _, _ => true
  | .add p q, N, j => p.denominatorsSafe N j && q.denominatorsSafe N j
  | .mul p q, N, j => p.denominatorsSafe N j && q.denominatorsSafe N j
  | .div p q, N, j =>
      p.denominatorsSafe N j && q.denominatorsSafe N j &&
        decide (q.eval N j ≠ 0)

/-- A finite program, including all its bounded summands, must use defined
rational divisions at this level and slot. -/
def RatProgram.denominatorsSafe : RatProgram → ℕ → ℕ → Bool
  | .basic t, N, j => t.denominatorsSafe N j
  | .add p q, N, j => p.denominatorsSafe N j && q.denominatorsSafe N j
  | .mul p q, N, j => p.denominatorsSafe N j && q.denominatorsSafe N j
  | .div p q, N, j =>
      p.denominatorsSafe N j && q.denominatorsSafe N j &&
        decide (q.eval N j ≠ 0)
  | .sumSlots p, N, _ =>
      decide (∀ i : Fin (N + 1), p.denominatorsSafe N i.val = true)

/-- A single finite datum generates a full hierarchy of rational enclosures. -/
structure JetBoxProgram where
  spectrum : FiniteWitness
  centerRule : RatProgram
  reRadiusRule : RatProgram
  imRadiusRule : RatProgram
  deriving Repr

def JetBoxProgram.rectangle (p : JetBoxProgram) (N : ℕ) :
    RationalJetRectangle N where
  center := fun j => p.centerRule.eval N j.val
  radiusRe := fun j => p.reRadiusRule.eval N j.val
  radiusIm := fun j => p.imRadiusRule.eval N j.val

/-- A genuinely terminating finite-layer verifier. -/
def checkGeneratedJetLayer (p : JetBoxProgram) (N : ℕ) : Bool :=
  decide (∀ j : Fin (N + 1),
    p.centerRule.denominatorsSafe N j.val = true ∧
    p.reRadiusRule.denominatorsSafe N j.val = true ∧
    p.imRadiusRule.denominatorsSafe N j.val = true) &&
    checkJetRectangle p.spectrum N (p.rectangle N)

/-- Soundness of the generated finite layer. The actual analytic jet enclosure
remains an EXPLICIT input, separate from the rational computation. -/
theorem checkGeneratedJetLayer_sound (p : JetBoxProgram) (N : ℕ)
    (hc : checkGeneratedJetLayer p N = true)
    (hXi : ActualXiJetInside N (p.rectangle N)) :
    ∀ j : ℕ, j ≤ N →
      (Nat.factorial j : ℝ) *
        ‖(elementary p.spectrum N j : ℂ) - actualComplexCoefficient j‖ ≤
          (1 / 2 : ℝ) ^ N := by
  have hrect : checkJetRectangle p.spectrum N (p.rectangle N) = true :=
    (Bool.and_eq_true.mp hc).2
  exact checkJetRectangle_sound p.spectrum N (p.rectangle N) hrect hXi

end WitnessSolobolo
