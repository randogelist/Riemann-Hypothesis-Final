import RHFinal.Core.LocalWitness

/-!
Bounded search over one linear square for the base and one for the remainder.
The four integer coefficients range from -bound to +bound. This is a limited
template search for a fixed LocalProblem, not a complete SOS or RH search.
-/

namespace RHFinal

open Polynomial

def coefficientRange (bound : Nat) : List Int :=
  (List.range (2 * bound + 1)).map (fun n => Int.ofNat n - Int.ofNat bound)

def linearFactors (bound : Nat) : List Poly :=
  let coeffs := coefficientRange bound
  coeffs.flatMap (fun a => coeffs.map (fun b => [a, b]))

def candidates (bound : Nat) : List FiniteWitness :=
  let factors := linearFactors bound
  factors.flatMap (fun base => factors.map (fun remainder =>
    { baseFactors := [base], remainderFactors := [remainder] }))

def firstAccepted (p : LocalProblem) : List FiniteWitness → Option FiniteWitness
  | [] => none
  | w :: ws => if checkLocal p w = true then some w else firstAccepted p ws

theorem firstAccepted_sound (p : LocalProblem) (ws : List FiniteWitness)
    (w : FiniteWitness) (h : firstAccepted p ws = some w) :
    checkLocal p w = true := by
  induction ws with
  | nil => simp [firstAccepted] at h
  | cons candidate rest ih =>
      simp only [firstAccepted] at h
      split at h
      next hc =>
        have hw : candidate = w := Option.some.inj h
        subst w
        exact hc
      next _ => exact ih h

def searchLocal (p : LocalProblem) (bound : Nat) : Option FiniteWitness :=
  firstAccepted p (candidates bound)

theorem searchLocal_sound (p : LocalProblem) (bound : Nat) (w : FiniteWitness)
    (h : searchLocal p bound = some w) : LocalIdentities p w :=
  checkLocal_sound p w (firstAccepted_sound p (candidates bound) w h)

theorem diagnosticSearchFinds : (searchLocal diagnosticProblem 1).isSome = true := by
  decide

end RHFinal
