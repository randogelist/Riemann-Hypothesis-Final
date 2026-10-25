import Derivations.Master.PascalHopf

namespace RHGPBKQR.Derivations.Master
open RHGPBKQR
open RHGPBKQR.Master

/-- !!! Identity VI: master energy equals the signed Hausdorff finite difference. -/
theorem MASTER_ENERGY_HAUSDORFF (M : MasterObject) : EnergyHausdorffIdentity M := by
  intro n k
  induction k generalizing n with
  | zero =>
      exact M.momentBoundary n
  | succ k ih =>
      rw [HausdorffDiff]
      have hsplit :
          M.energyInt n k =
            M.energyInt (n + 1) k + M.energyInt n (k + 1) := by
        have hnat := MASTER_PASCAL_HOPF M n k
        exact congrArg Int.ofNat hnat
      have hLeft :
          M.energyInt n k =
            HausdorffDiff CanonicalGPNormalizedCoeff n k := ih n
      have hRight :
          M.energyInt (n + 1) k =
            HausdorffDiff CanonicalGPNormalizedCoeff (n + 1) k := ih (n + 1)
      rw [hLeft, hRight] at hsplit
      omega

end RHGPBKQR.Derivations.Master
