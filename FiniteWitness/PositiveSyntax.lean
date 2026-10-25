import FiniteWitness.FiniteDebit

/-!
# A genuine terminating, universally sound finite algebra certificate

This is NOT an oracle for actual-xi calibration. It demonstrates a useful
finite certificate language: a finite sum/product/square syntax with checked
nonnegative rational literals. Once accepted, its evaluation is nonnegative
for EVERY depth and slot, not merely for finitely many tested samples.
-/

namespace WitnessSolobolo

inductive PosTerm where
  | const (q : ℚ)
  | level
  | slot
  | add (a b : PosTerm)
  | mul (a b : PosTerm)
  | square (a : RatTerm)
  deriving Repr

/-- Exact rational evaluation of a finite symbolic positivity certificate. -/
def PosTerm.eval : PosTerm → ℕ → ℕ → ℚ
  | .const q, _, _ => q
  | .level, N, _ => N
  | .slot, _, i => i
  | .add a b, N, i => a.eval N i + b.eval N i
  | .mul a b, N, i => a.eval N i * b.eval N i
  | .square a, N, i => (a.eval N i) ^ 2

/-- Decidable checker: only the rational literals require sign tests. -/
def PosTerm.check : PosTerm → Bool
  | .const q => decide (0 ≤ q)
  | .level => true
  | .slot => true
  | .add a b => a.check && b.check
  | .mul a b => a.check && b.check
  | .square _ => true

/-- Key universal soundness theorem for the restricted finite syntax. -/
theorem PosTerm.check_sound (t : PosTerm) :
    t.check = true → ∀ (N i : ℕ), 0 ≤ t.eval N i := by
  induction t with
  | const q =>
      intro h N i
      have hq : 0 ≤ q := of_decide_eq_true (by simpa [PosTerm.check] using h)
      simpa [PosTerm.eval] using hq
  | level =>
      intro h N i
      simp only [PosTerm.eval]
      exact_mod_cast Nat.zero_le N
  | slot =>
      intro h N i
      simp only [PosTerm.eval]
      exact_mod_cast Nat.zero_le i
  | add a b ha hb =>
      intro h N i
      have hh : a.check = true ∧ b.check = true := by
        simpa [PosTerm.check] using h
      simpa only [PosTerm.eval] using
        add_nonneg (ha hh.1 N i) (hb hh.2 N i)
  | mul a b ha hb =>
      intro h N i
      have hh : a.check = true ∧ b.check = true := by
        simpa [PosTerm.check] using h
      simpa only [PosTerm.eval] using
        mul_nonneg (ha hh.1 N i) (hb hh.2 N i)
  | square a =>
      intro h N i
      simp only [PosTerm.eval]
      positivity

/-- An accepted witness establishes a universal SOS-type inequality. -/
structure AlgebraWitness where
  nonnegativeExpression : PosTerm
  deriving Repr

def checkAlgebra (w : AlgebraWitness) : Bool :=
  w.nonnegativeExpression.check

theorem checkAlgebra_sound (w : AlgebraWitness)
    (hw : checkAlgebra w = true) (N i : ℕ) :
    0 ≤ w.nonnegativeExpression.eval N i := by
  exact PosTerm.check_sound w.nonnegativeExpression hw N i

/-- Nontrivial, finitely accepted certificate: (N-i)^2 + i >= 0. -/
def exampleAlgebra : AlgebraWitness :=
  ⟨.add (.square (.add .level (.mul (.lit (-1)) .slot))) .slot⟩

example : checkAlgebra exampleAlgebra = true := by decide

end WitnessSolobolo
