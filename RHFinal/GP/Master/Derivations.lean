import RHFinal.GP.Master.Model

/-!
The binary energy split, contraction and Hausdorff induction are extracted
from the master package. Their hypotheses remain explicit in MasterModel.
No literature theorem or assertion about actual xi is imported.
-/

namespace RHFinal.GP.Master

theorem zero_mode {c : Nat → Int} (M : MasterModel c) :
    M.readout (M.modeVec 0) = M.anchorSlice := M.zeroMode

theorem mode_shift {c : Nat → Int} (M : MasterModel c) :
    ∀ m, M.readout (M.modeVec m) = M.shiftedCoeff m := M.modeShift

theorem qGamma_step {c : Nat → Int} (M : MasterModel c) (N : Nat) :
    M.qGammaPrefix (N + 1) =
      M.qGammaPrefix N + M.normSq (M.modeVec (N + 1)) := rfl

theorem qGamma_monotone_step {c : Nat → Int} (M : MasterModel c) (N : Nat) :
    M.qGammaPrefix N ≤ M.qGammaPrefix (N + 1) := by
  rw [qGamma_step]
  omega

theorem moment_boundary {c : Nat → Int} (M : MasterModel c) (n : Nat) :
    M.energyInt n 0 = c n := M.momentBoundary n

theorem pascal_hopf {c : Nat → Int} (M : MasterModel c) (n k : Nat) :
    M.energy n k = M.energy (n + 1) k + M.energy n (k + 1) := by
  unfold MasterModel.energy
  calc
    M.normSq (M.energyVec n k) =
        M.normSq (M.leftBranch (M.energyVec n k)) +
          M.normSq (M.rightBranch (M.energyVec n k)) := M.binaryIsometry _
    _ = M.normSq (M.energyVec (n + 1) k) +
        M.normSq (M.energyVec n (k + 1)) := by
          rw [M.energyLeft n k, M.energyRight n k]

theorem left_contractive {c : Nat → Int} (M : MasterModel c) (n k : Nat) :
    M.energy (n + 1) k ≤ M.energy n k := by
  have h := pascal_hopf M n k
  omega

theorem right_contractive {c : Nat → Int} (M : MasterModel c) (n k : Nat) :
    M.energy n (k + 1) ≤ M.energy n k := by
  have h := pascal_hopf M n k
  omega

theorem energy_hausdorff {c : Nat → Int} (M : MasterModel c) (n k : Nat) :
    M.energyInt n k = hausdorffDiff c n k := by
  induction k generalizing n with
  | zero => exact M.momentBoundary n
  | succ k ih =>
      rw [hausdorffDiff]
      have hsplit :
          M.energyInt n k = M.energyInt (n + 1) k + M.energyInt n (k + 1) := by
        exact congrArg Int.ofNat (pascal_hopf M n k)
      have hLeft : M.energyInt n k = hausdorffDiff c n k := ih n
      have hRight : M.energyInt (n + 1) k = hausdorffDiff c (n + 1) k := ih (n + 1)
      rw [hLeft, hRight] at hsplit
      omega

end RHFinal.GP.Master
