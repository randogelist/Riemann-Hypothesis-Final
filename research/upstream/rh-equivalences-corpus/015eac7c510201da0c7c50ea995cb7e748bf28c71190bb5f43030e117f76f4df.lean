import AWPI.PhiRH.NativeRHExactWaist

namespace AWPI.PhiRH.NativeRHAlgebraicWaist

open AWPI.PhiRH
open AWPI.PhiRH.Model
open AWPI.PhiRH.Geometry
open AWPI.PhiRH.NativeEtaPhi
open AWPI.PhiRH.NativePassivityCore
open AWPI.PhiRH.NativeRHExactWaist

def CanonicalGainBounds : Prop :=
  ∀ rho : ℂ,
    AWPI.PhiRH.NativePhiZeroBridge.PhiZero phiEta rho →
      canonicalModel.gainPlus rho ≤ 1 ∧
      canonicalModel.gainMinus rho ≤ 1

def CanonicalCenteredBounds : Prop :=
  ∀ rho : ℂ,
    AWPI.PhiRH.NativePhiZeroBridge.PhiZero phiEta rho →
      canonicalModel.centered rho ≤ 0 ∧
      0 ≤ canonicalModel.centered rho

theorem plusDefect_nonpos_iff_gainPlus_le_one
    (rho : ℂ)
    (hz : AWPI.PhiRH.NativePhiZeroBridge.PhiZero phiEta rho) :
    canonicalModel.exactPlusDefect rho ≤ 0 ↔
      canonicalModel.gainPlus rho ≤ 1 := by

  have hE :
      0 < canonicalModel.exactPlusEnergy rho :=
    canonicalBackground.exactPlusActive rho hz

  constructor

  · intro h

    unfold Model.exactPlusDefect at h

    nlinarith

  · intro h

    unfold Model.exactPlusDefect

    nlinarith

theorem minusDefect_nonpos_iff_gainMinus_le_one
    (rho : ℂ)
    (hz : AWPI.PhiRH.NativePhiZeroBridge.PhiZero phiEta rho) :
    canonicalModel.exactMinusDefect rho ≤ 0 ↔
      canonicalModel.gainMinus rho ≤ 1 := by

  have hE :
      0 < canonicalModel.exactMinusEnergy rho :=
    canonicalBackground.exactMinusActive rho hz

  constructor

  · intro h

    unfold Model.exactMinusDefect at h

    nlinarith

  · intro h

    unfold Model.exactMinusDefect

    nlinarith

theorem TWO_DEFECT_SIGNS_IFF_GAIN_BOUNDS :
    CanonicalTwoDefectSigns ↔
      CanonicalGainBounds := by

  constructor

  · intro h rho hz

    exact
      ⟨(plusDefect_nonpos_iff_gainPlus_le_one
          rho hz).1 (h rho hz).1,
       (minusDefect_nonpos_iff_gainMinus_le_one
          rho hz).1 (h rho hz).2⟩

  · intro h rho hz

    exact
      ⟨(plusDefect_nonpos_iff_gainPlus_le_one
          rho hz).2 (h rho hz).1,
       (minusDefect_nonpos_iff_gainMinus_le_one
          rho hz).2 (h rho hz).2⟩

theorem gainPlus_le_one_iff_centered_nonpos
    (rho : ℂ) :
    canonicalModel.gainPlus rho ≤ 1 ↔
      canonicalModel.centered rho ≤ 0 := by

  constructor

  · intro h

    have harg :
        2 * canonicalModel.centered rho ≤ 0 := by

      exact
        PHIRH244_SCALE2_LE_ONE_IMPLIES_NONPOSITIVE
          (M := canonicalModel)
          canonicalScaleFacts
          (2 * canonicalModel.centered rho)
          (by
            simpa [Model.gainPlus] using h)

    linarith

  · intro h

    have harg :
        2 * canonicalModel.centered rho ≤ 0 := by
      linarith

    unfold Model.gainPlus

    calc
      canonicalModel.scale2
          (2 * canonicalModel.centered rho)
          ≤
        canonicalModel.scale2 0 :=
          canonicalScaleFacts.2.monotone harg

      _ = 1 :=
        canonicalScaleFacts.1

theorem gainMinus_le_one_iff_centered_nonneg
    (rho : ℂ) :
    canonicalModel.gainMinus rho ≤ 1 ↔
      0 ≤ canonicalModel.centered rho := by

  constructor

  · intro h

    have harg :
        -2 * canonicalModel.centered rho ≤ 0 := by

      exact
        PHIRH244_SCALE2_LE_ONE_IMPLIES_NONPOSITIVE
          (M := canonicalModel)
          canonicalScaleFacts
          (-2 * canonicalModel.centered rho)
          (by
            simpa [Model.gainMinus] using h)

    linarith

  · intro h

    have harg :
        -2 * canonicalModel.centered rho ≤ 0 := by
      linarith

    unfold Model.gainMinus

    calc
      canonicalModel.scale2
          (-2 * canonicalModel.centered rho)
          ≤
        canonicalModel.scale2 0 :=
          canonicalScaleFacts.2.monotone harg

      _ = 1 :=
        canonicalScaleFacts.1

theorem GAIN_BOUNDS_IFF_CENTERED_BOUNDS :
    CanonicalGainBounds ↔
      CanonicalCenteredBounds := by

  constructor

  · intro h rho hz

    exact
      ⟨(gainPlus_le_one_iff_centered_nonpos rho).1
          (h rho hz).1,
       (gainMinus_le_one_iff_centered_nonneg rho).1
          (h rho hz).2⟩

  · intro h rho hz

    exact
      ⟨(gainPlus_le_one_iff_centered_nonpos rho).2
          (h rho hz).1,
       (gainMinus_le_one_iff_centered_nonneg rho).2
          (h rho hz).2⟩

theorem CENTERED_BOUNDS_IFF_INTERNAL_RH :
    CanonicalCenteredBounds ↔
      canonicalModel.RH := by

  constructor

  · intro h rho hz

    have hc :=
      h rho hz

    have hzero :
        canonicalModel.centered rho = 0 := by
      linarith

    exact
      (PHIRH240_CENTERED_ZERO_IFF_CRITICAL_LINE
        (M := canonicalModel) rho).1
        hzero

  · intro h rho hz

    have hcrit :=
      h rho hz

    have hzero :
        canonicalModel.centered rho = 0 :=
      (PHIRH240_CENTERED_ZERO_IFF_CRITICAL_LINE
        (M := canonicalModel) rho).2
        hcrit

    exact
      ⟨by linarith,
       by linarith⟩

theorem CENTERED_BOUNDS_IFF_MATHLIB_RH :
    CanonicalCenteredBounds ↔
      RiemannHypothesis := by

  exact
    CENTERED_BOUNDS_IFF_INTERNAL_RH.trans
      CANONICAL_INTERNAL_RH_IFF_MATHLIB_RH

theorem TWO_DEFECT_SIGNS_IFF_CENTERED_BOUNDS :
    CanonicalTwoDefectSigns ↔
      CanonicalCenteredBounds := by

  exact
    TWO_DEFECT_SIGNS_IFF_GAIN_BOUNDS.trans
      GAIN_BOUNDS_IFF_CENTERED_BOUNDS

end AWPI.PhiRH.NativeRHAlgebraicWaist