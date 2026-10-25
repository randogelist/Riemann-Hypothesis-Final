import FiniteWitness.GPMoments

/-!
# Finite rational spectra and a terminating finite check

A finite rational spectrum is the eigenvalue model for a diagonal rational
positive-semidefinite matrix. This module does not assert that the spectrum
represents actual ξ. It proves its own finite spectral contraction law.
-/

namespace WitnessSolobolo

/-- Finite expression syntax; every witness has finitely many constructors. -/
inductive RatTerm where
  | lit (q : ℚ)
  | level
  | slot
  | add (left right : RatTerm)
  | mul (left right : RatTerm)
  | div (left right : RatTerm)
  deriving Repr, DecidableEq

/-- Exact rational evaluation. Rational division is total in Lean; soundness
certificates must additionally rule out unintended zero denominators. -/
def RatTerm.eval (t : RatTerm) (N i : ℕ) : ℚ :=
  match t with
  | .lit q => q
  | .level => N
  | .slot => i
  | .add p q => p.eval N i + q.eval N i
  | .mul p q => p.eval N i * q.eval N i
  | .div p q => p.eval N i / q.eval N i

/-- An actual FINITE program description, rather than a function-oracle. -/
structure FiniteWitness where
  baseDepth : ℕ
  rankOffset : ℕ
  atomRule : RatTerm
  /-- Finite user-submitted algebraic certificate data (language unfinished). -/
  certificate : List RatTerm
  deriving Repr

/-- Spectrum of the `N`th generated finite matrix. -/
def atom (w : FiniteWitness) (N : ℕ)
    (i : Fin (N + 1 + w.rankOffset)) : ℚ :=
  w.atomRule.eval N i.val

/-- Finite trace of an integer power of the generated diagonal matrix. -/
def tracePower (w : FiniteWitness) (N k : ℕ) : ℚ :=
  ∑ i : Fin (N + 1 + w.rankOffset), (atom w N i) ^ k

/-- Finite mass/trace. -/
def mass (w : FiniteWitness) (N : ℕ) : ℚ :=
  ∑ i : Fin (N + 1 + w.rankOffset), atom w N i

/-- Semantic content of the finite seed check. -/
def SeedValid (w : FiniteWitness) : Prop :=
  ∀ N : Fin (w.baseDepth + 1),
    (∀ i : Fin (N.val + 1 + w.rankOffset),
      0 ≤ atom w N.val i ∧ atom w N.val i ≤ 1) ∧
    mass w N.val ≤ 1

/-- The computation really terminates: it tests finitely many rational
inequalities on finitely many generated matrices. -/
def checkSeed (w : FiniteWitness) : Bool := decide (SeedValid w)

/-- Soundness of the implemented Boolean checker (only for its seed window). -/
theorem checkSeed_sound (w : FiniteWitness)
    (hw : checkSeed w = true) : SeedValid w := by
  exact of_decide_eq_true hw

/-- A zero spectrum is a demonstrably accepted seed. This does NOT imply RH. -/
def sampleWitness : FiniteWitness where
  baseDepth := 0
  rankOffset := 0
  atomRule := .lit 0
  certificate := []

example : checkSeed sampleWitness = true := by decide

end WitnessSolobolo
