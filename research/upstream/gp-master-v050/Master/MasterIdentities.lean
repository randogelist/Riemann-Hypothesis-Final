import Master.MasterObject

namespace RHGPBKQR.Master

open RHGPBKQR

/-- ! RH slice = zero contour mode. -/
def ZeroModeIdentity (M : MasterObject) : Prop :=
  M.readout (M.modeVec 0) = M.rhSlice

/-- !! Contour Fourier mode = shifted GP datum. -/
def ModeShiftIdentity (M : MasterObject) : Prop :=
  ∀ m : Nat, M.readout (M.modeVec m) = M.shiftedCoeff m

/-- !! Finite local-Q transverse energy accumulation. -/
def LocalQGammaIdentity (M : MasterObject) : Prop :=
  ∀ N : Nat,
    M.qGammaPrefix (N + 1) =
      M.qGammaPrefix N + M.normSq (M.modeVec (N + 1))

/-- !! GP moment boundary = master-state energy boundary. -/
def MomentBoundaryIdentity (M : MasterObject) : Prop :=
  ∀ n : Nat,
    M.energyInt n 0 = CanonicalGPNormalizedCoeff n

/-- !!! One binary-isometry law generates the Pascal-Hopf energy split. -/
def PascalHopfIdentity (M : MasterObject) : Prop :=
  ∀ n k : Nat,
    M.energy n k = M.energy (n + 1) k + M.energy n (k + 1)

/-- !!! Master energy = signed Hausdorff finite difference. -/
def EnergyHausdorffIdentity (M : MasterObject) : Prop :=
  ∀ n k : Nat,
    M.energyInt n k =
      HausdorffDiff CanonicalGPNormalizedCoeff n k

/-- !!! The master object forces complete Hausdorff positivity. -/
def HausdorffPositivityIdentity (_M : MasterObject) : Prop :=
  SequenceHausdorffPositive CanonicalGPNormalizedCoeff

end RHGPBKQR.Master
