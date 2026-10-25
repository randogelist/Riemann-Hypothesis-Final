import KQGPBKQRHilbert.InputEndpoints

/-! Conditional actual-ξ calibration: no witness is asserted here. -/
namespace KQGPBKQRHilbert

def GPToXiDirectCalibration (muGP : ℝ → ℕ → ℝ) : Prop :=
  ∀ (a : ℝ), a ∈ NativeSoloboloNegativity.xiRegularAnchors →
    ∀ (n : ℕ), muGP a n = NativeSoloboloNegativity.xiWidderDirect a n

theorem calibration_to_recursive
    (muGP : ℝ → ℕ → ℝ) (hcal : GPToXiDirectCalibration muGP)
    (a : ℝ) (ha : a ∈ NativeSoloboloNegativity.xiRegularAnchors)
    (n : ℕ) :
    muGP a n = NativeSoloboloNegativity.xiWidderMoment a n := by
  calc
    muGP a n = NativeSoloboloNegativity.xiWidderDirect a n := hcal a ha n
    _ = NativeSoloboloNegativity.xiWidderMoment a n :=
      NativeSoloboloNegativity.XI_WIDDER_DIRECT_EQ_RECURSIVE_ON_REGULAR_ANCHORS
        a ha n

theorem common_moments_calibrated_actual_square
    {Vec : Type}
    {G : NativeSolobolo.GPObservable ℂ}
    {C : NativeSolobolo.CayleyMomentCodec ℝ ℂ}
    {Q : NativeSolobolo.Derivations.BKQR.ScalarProductGeometry ℝ Vec}
    (A : NativeSolobolo.GPTransferMomentModel G C)
    (M : NativeSolobolo.BKQRCayleyModel ℝ Vec ℂ Q C)
    (H : NativeSolobolo.GPBKQRCommonMomentIdentity A M)
    (hcal : GPToXiDirectCalibration A.moment)
    (a : ℝ) (ha : a ∈ NativeSoloboloNegativity.xiRegularAnchors)
    (n : ℕ) :
    NativeSoloboloNegativity.xiWidderMoment a n =
      Q.normSq (M.widderVector a n) := by
  calc
    NativeSoloboloNegativity.xiWidderMoment a n =
        NativeSoloboloNegativity.xiWidderDirect a n :=
          (NativeSoloboloNegativity.XI_WIDDER_DIRECT_EQ_RECURSIVE_ON_REGULAR_ANCHORS
            a ha n).symm
    _ = A.moment a n := (hcal a ha n).symm
    _ = M.widderCoeff a n := H.moment_eq a n
    _ = Q.normSq (M.widderVector a n) := M.widder_square a n

end KQGPBKQRHilbert
