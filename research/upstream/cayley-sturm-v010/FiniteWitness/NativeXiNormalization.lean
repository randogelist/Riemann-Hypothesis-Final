import FiniteWitness.NativeXi

/-!
# Literal completed-zeta normalization and reflection

These are unconditional native identities, not model equations. They are
used to align SOLOBOLO, the square-descended theta germ, and QQRH.
-/

namespace WitnessSolobolo

/-- The completed entire xi normalization at s=0. -/
theorem actualXi_at_zero : actualXi 0 = (1 : ℂ) / 2 := by
  simp [actualXi]

/-- The completed entire xi normalization at s=1. -/
theorem actualXi_at_one : actualXi 1 = (1 : ℂ) / 2 := by
  simp [actualXi]

/-- The exact native functional equation for our normalization. -/
theorem actualXi_one_sub (s : ℂ) : actualXi (1 - s) = actualXi s := by
  unfold actualXi
  rw [completedRiemannZeta₀_one_sub]
  ring

/-- Evenness about the critical-line center, prior to square descent. -/
theorem actualXi_centered_even (z : ℂ) :
    actualXi ((1 : ℂ) / 2 + z) = actualXi ((1 : ℂ) / 2 - z) := by
  calc
    actualXi ((1 : ℂ) / 2 + z) =
        actualXi (1 - ((1 : ℂ) / 2 + z)) :=
          (actualXi_one_sub _).symm
    _ = actualXi ((1 : ℂ) / 2 - z) := by congr 1; ring

end WitnessSolobolo
