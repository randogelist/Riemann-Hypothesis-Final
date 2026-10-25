import RHFinal.Core.Polynomial

/-!
This checks finite symbolic SOS identities only. `LocalProblem` is a fixed
search target; it is not a definition of the actual xi data. No accepted value
of this checker is an RH witness.
-/

namespace RHFinal

open Polynomial

structure LocalProblem where
  base : Poly
  multiplier : Poly
  next : Poly
  deriving Repr, DecidableEq

/-- Raw finite coefficients only: no propositions, proofs, or function fields. -/
structure FiniteWitness where
  baseFactors : List Poly
  remainderFactors : List Poly
  deriving Repr, DecidableEq

def LocalIdentities (p : LocalProblem) (w : FiniteWitness) : Prop :=
  p.base = sumSquares w.baseFactors ∧
  p.next = add (mul (mul p.multiplier p.multiplier) p.base)
    (sumSquares w.remainderFactors)

instance (p : LocalProblem) (w : FiniteWitness) : Decidable (LocalIdentities p w) := by
  unfold LocalIdentities
  infer_instance

def checkLocal (p : LocalProblem) (w : FiniteWitness) : Bool :=
  decide (LocalIdentities p w)

theorem checkLocal_sound (p : LocalProblem) (w : FiniteWitness)
    (h : checkLocal p w = true) : LocalIdentities p w :=
  of_decide_eq_true h

theorem checked_base_identity (p : LocalProblem) (w : FiniteWitness)
    (h : checkLocal p w = true) (x : Int) :
    eval p.base x = squareValues w.baseFactors x := by
  rw [(checkLocal_sound p w h).1, eval_sumSquares]

theorem checked_transition_identity (p : LocalProblem) (w : FiniteWitness)
    (h : checkLocal p w = true) (x : Int) :
    eval p.next x =
      (eval p.multiplier x * eval p.multiplier x) * eval p.base x +
      squareValues w.remainderFactors x := by
  rw [(checkLocal_sound p w h).2, eval_add, eval_mul, eval_mul, eval_sumSquares]

/-- Diagnostic target: (1+x)^2, then (1+x)^2+x^2, with multiplier 1. -/
def diagnosticProblem : LocalProblem :=
  { base := [1, 2, 1], multiplier := [1], next := [1, 2, 2] }

def diagnosticWitness : FiniteWitness :=
  { baseFactors := [[1, 1]], remainderFactors := [[0, 1]] }

def rejectedDiagnosticWitness : FiniteWitness :=
  { baseFactors := [[1, 1]], remainderFactors := [] }

theorem diagnosticAccepted : checkLocal diagnosticProblem diagnosticWitness = true := by
  decide

theorem diagnosticRejected :
    checkLocal diagnosticProblem rejectedDiagnosticWitness = false := by
  decide

end RHFinal
