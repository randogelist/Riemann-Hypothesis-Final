import Mathlib

/-!
Terminating rational positive-Cayley checker. This module deliberately does not
open a noncomputable section: the Bool check can be evaluated independently of
the infinite actual-xi calibration obligation.
-/
set_option autoImplicit false
namespace SoloboloAdmission

structure RationalPacket (d : ℕ) where
  node : Fin d → ℚ
  mass : Fin d → ℚ

def RationalPacket.Valid {d : ℕ} (P : RationalPacket d) : Prop :=
  ∀ i : Fin d, 0 ≤ P.node i ∧ P.node i ≤ 1 ∧ 0 ≤ P.mass i

def RationalPacket.check {d : ℕ} (P : RationalPacket d) : Bool :=
  decide P.Valid

theorem RationalPacket.check_sound {d : ℕ} (P : RationalPacket d)
    (h : P.check = true) : P.Valid := by
  simpa [RationalPacket.check] using h

end SoloboloAdmission
