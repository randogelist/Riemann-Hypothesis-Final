import Derivations.Master.MomentBoundary

namespace RHGPBKQR.Derivations.Master
open RHGPBKQR
open RHGPBKQR.Master

/-- !!! Identity V: one binary-isometry law generates the complete Pascal-Hopf split. -/
theorem MASTER_PASCAL_HOPF (M : MasterObject) : PascalHopfIdentity M := by
  intro n k
  unfold MasterObject.energy
  calc
    M.normSq (M.energyVec n k)
        = M.normSq (M.leftBranch (M.energyVec n k)) +
          M.normSq (M.rightBranch (M.energyVec n k)) := M.binaryIsometry _
    _ = M.normSq (M.energyVec (n + 1) k) +
        M.normSq (M.energyVec n (k + 1)) := by
          rw [M.energyLeft n k, M.energyRight n k]

/-- !! Both Hopf children have no more energy than the parent. -/
theorem MASTER_LEFT_CONTRACTIVE (M : MasterObject) (n k : Nat) :
    M.energy (n + 1) k ≤ M.energy n k := by
  have h := MASTER_PASCAL_HOPF M n k
  omega

/-- !! Right-branch contraction. -/
theorem MASTER_RIGHT_CONTRACTIVE (M : MasterObject) (n k : Nat) :
    M.energy n (k + 1) ≤ M.energy n k := by
  have h := MASTER_PASCAL_HOPF M n k
  omega

end RHGPBKQR.Derivations.Master
