import Std

/-!
The algebraic SOLOBOLO transfer pattern, with every required hypothesis exposed.
For the intended application State is a space of functions and step is the
actual differential recurrence. A base equality at finitely many points does
not supply the functional equality required here.
-/

namespace RHFinal

theorem sharedTransition_eq {State : Sort u}
    (actual model : Nat → State) (step : Nat → State → State)
    (actualStep : ∀ n, actual (n + 1) = step n (actual n))
    (modelStep : ∀ n, model (n + 1) = step n (model n))
    (base : actual 0 = model 0) : ∀ n, actual n = model n := by
  intro n
  induction n with
  | zero => exact base
  | succ n ih => rw [actualStep n, modelStep n, ih]

theorem transfer_property_of_sharedTransition {State : Sort u}
    (actual model : Nat → State) (step : Nat → State → State)
    (actualStep : ∀ n, actual (n + 1) = step n (actual n))
    (modelStep : ∀ n, model (n + 1) = step n (model n))
    (base : actual 0 = model 0)
    (P : Nat → State → Prop) (modelProperty : ∀ n, P n (model n)) :
    ∀ n, P n (actual n) := by
  intro n
  rw [sharedTransition_eq actual model step actualStep modelStep base n]
  exact modelProperty n

/-- Conditional contract: constructing `baseSound` for actual xi remains open. -/
theorem transfer_of_finite_base_soundness {State : Sort u} {Packet : Type v}
    (actual model : Nat → State) (step : Nat → State → State)
    (actualStep : ∀ n, actual (n + 1) = step n (actual n))
    (modelStep : ∀ n, model (n + 1) = step n (model n))
    (check : Packet → Bool)
    (baseSound : ∀ w, check w = true → actual 0 = model 0)
    (w : Packet) (accepted : check w = true) :
    ∀ n, actual n = model n :=
  sharedTransition_eq actual model step actualStep modelStep (baseSound w accepted)

end RHFinal
