import RHAdmission.AllDepthAdmission

/-!
# SOLOBOLO equality propagation: abstract algebraic core

The base identity must hold as a WHOLE function of the anchor, not at a
single anchor point. Same raising step and same initial function imply
all-depth equality. Model positivity is a separate explicit hypothesis.
This file does not claim an actual xi-to-GP realization.
-/

namespace RHAdmission

/-- Two function-valued towers driven by the same raising operator. -/
structure SharedTower (Anchor : Type) where
  step : ℕ → (Anchor → ℝ) → Anchor → ℝ
  native : ℕ → Anchor → ℝ
  model : ℕ → Anchor → ℝ
  initial : native 0 = model 0
  native_succ : ∀ n : ℕ, native (n + 1) = step n (native n)
  model_succ : ∀ n : ℕ, model (n + 1) = step n (model n)

/-- The initial FUNCTION determines all later functions under a common step. -/
theorem shared_tower_equal_all_depths {Anchor : Type} (T : SharedTower Anchor) :
    ∀ n : ℕ, T.native n = T.model n := by
  intro n
  induction n with
  | zero => exact T.initial
  | succ n ih =>
      calc
        T.native (n + 1) = T.step n (T.native n) := T.native_succ n
        _ = T.step n (T.model n) := congrArg (T.step n) ih
        _ = T.model (n + 1) := (T.model_succ n).symm

/-- When the calibrated comparison tower is positive, so is the native one. -/
theorem shared_tower_transfer_nonnegative {Anchor : Type}
    (T : SharedTower Anchor)
    (hModel : ∀ n : ℕ, ∀ a : Anchor, 0 ≤ T.model n a) :
    ∀ n : ℕ, ∀ a : Anchor, 0 ≤ T.native n a := by
  intro n a
  rw [shared_tower_equal_all_depths T n]
  exact hModel n a

end RHAdmission
