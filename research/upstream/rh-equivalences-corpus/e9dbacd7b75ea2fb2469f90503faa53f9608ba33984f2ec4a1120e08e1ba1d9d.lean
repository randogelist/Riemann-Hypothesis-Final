import AWPI.PhiRH.NativeCanonicalJet
import AWPI.PhiRH.NativeConcreteKQ
import AWPI.PhiRH.NativeEtaPhi
import AWPI.PhiRH.Reverse

namespace AWPI.PhiRH.NativePassivityCore

open AWPI.PhiRH
open AWPI.PhiRH.Model
open AWPI.PhiRH.Geometry
open AWPI.PhiRH.Reverse

open AWPI.PhiRH.MathlibBridge
open AWPI.PhiRH.NativePhiZeroBridge
open AWPI.PhiRH.NativeS1Exact
open AWPI.PhiRH.NativeEtaPhi
open AWPI.PhiRH.NativeAxiomLedgerV2
open AWPI.PhiRH.NativeSevenFrontiers
open AWPI.PhiRH.NativeCanonicalJet
open AWPI.PhiRH.NativeConcreteKQ

open AWPI.PhiRH.RocqKQSourceMerge
open AWPI.PhiRH.RocqSourceExact
open AWPI.PhiRH.RocqResidualExact

/--
Canonical fully concrete model after all previous actualizations.
-/
noncomputable def canonicalModel :=
  PhiActualModel
    phiEta
    (literalShiftedPhiValue phiEta)
    canonicalTransverseJet
    canonicalBindingScale
    canonicalBindingScale
    concreteKQPlusSource
    concreteKQMinusSource

theorem canonicalScaleFacts :
    Scale2Facts canonicalModel := by

  simpa [canonicalModel] using
    (phiActualScaleFacts
      phiEta
      (literalShiftedPhiValue phiEta)
      canonicalTransverseJet
      canonicalBindingScale
      canonicalBindingScale
      concreteKQPlusSource
      concreteKQMinusSource)

theorem canonicalNormalizedSource :
    LiteralNormalizedDyadicMultiplierSourceFormula
      concreteKQPlusSource
      concreteKQMinusSource := by

  intro N sigma tau

  apply Prod.ext

  · simpa [
      actualKQSourcePair,
      c2Mul,
      c2Re,
      c2Im,
      normalizedDyadicMultiplier,
      actualPhiResidualPair,
      sub_eq_add_neg
    ] using
      (concreteKQPlus_coordinate N sigma tau)

  · simpa [
      actualKQSourcePair,
      c2Mul,
      c2Re,
      c2Im,
      normalizedDyadicMultiplier,
      actualPhiResidualPair,
      sub_eq_add_neg
    ] using
      (concreteKQMinus_coordinate N sigma tau)

theorem canonicalTransverseFrontier :
    TransverseIdentity
      phiEta
      (literalShiftedPhiValue phiEta)
      canonicalTransverseJet := by

  intro rho hz

  simpa [
    rhoNorm2,
    shiftedPhiNorm2
  ] using
    (canonicalTransverseIdentity rho hz)

theorem canonicalBindingScales :
    BindingScalesNonzero
      phiEta
      canonicalBindingScale
      canonicalBindingScale := by

  exact
    ⟨canonicalPlusScaleNonzero,
     canonicalMinusScaleNonzero⟩

theorem canonicalBackground :
    Background canonicalModel := by

  refine
    { normalizedSourceFormula := ?_
      zeroInPositiveStrip := ?_
      exactPlusActive := ?_
      exactMinusActive := ?_
      criticalLineForwardGainOne := ?_
      criticalLineBackwardGainOne := ?_ }

  · exact canonicalNormalizedSource

  · intro rho hz

    exact
      phiZero_re_pos
        phiEta rho hz

  · intro rho hz

    simpa [canonicalModel] using
      (plusEnergy_active
        phiEta
        (literalShiftedPhiValue phiEta)
        canonicalTransverseJet
        canonicalBindingScale
        canonicalBindingScale
        concreteKQPlusSource
        concreteKQMinusSource
        phiEta_shifted_slice_nonzero
        canonicalTransverseFrontier
        canonicalBindingScales
        rho hz)

  · intro rho hz

    simpa [canonicalModel] using
      (minusEnergy_active
        phiEta
        (literalShiftedPhiValue phiEta)
        canonicalTransverseJet
        canonicalBindingScale
        canonicalBindingScale
        concreteKQPlusSource
        concreteKQMinusSource
        phiEta_shifted_slice_nonzero
        canonicalTransverseFrontier
        canonicalBindingScales
        rho hz)

  · intro rho hcrit

    exact
      PHIRH283_CRITICAL_LINE_GIVES_FORWARD_GAIN_ONE
        canonicalScaleFacts
        rho hcrit

  · intro rho hcrit

    exact
      PHIRH284_CRITICAL_LINE_GIVES_BACKWARD_GAIN_ONE
        canonicalScaleFacts
        rho hcrit

theorem canonicalMultiplierFacts :
    NormalizedDyadicMultiplierFacts
      canonicalModel := by

  simpa [canonicalModel] using
    (phiActualMultiplierFacts
      phiEta
      (literalShiftedPhiValue phiEta)
      canonicalTransverseJet
      canonicalBindingScale
      canonicalBindingScale
      concreteKQPlusSource
      concreteKQMinusSource)

/--
The entire constructor / finite-energy / pointwise-flux layer
collapses to exact two-sided passivity.
-/
theorem CANONICAL_PASSIVITY_IFF_INTERNAL_RH :
    ExactTwoSidedPassivity canonicalModel ↔
      canonicalModel.RH := by

  exact
    PHIRH296_BACKGROUND_GIVES_PASSIVITY_IFF_RH
      canonicalMultiplierFacts
      canonicalScaleFacts
      canonicalBackground

/--
Native Mathlib RH from exactly two atomic defect-sign premises.
-/
theorem RIEMANN_HYPOTHESIS_OF_TWO_DEFECT_SIGNS

    (hPlus :
      ∀ rho : ℂ,
        PhiZero phiEta rho →
        canonicalModel.exactPlusDefect rho ≤ 0)

    (hMinus :
      ∀ rho : ℂ,
        PhiZero phiEta rho →
        canonicalModel.exactMinusDefect rho ≤ 0) :

    RiemannHypothesis := by

  have hPass :
      ExactTwoSidedPassivity
        canonicalModel := by

    intro rho hz

    exact
      ⟨hPlus rho hz,
       hMinus rho hz⟩

  have hInternal :
      canonicalModel.RH :=
    CANONICAL_PASSIVITY_IFF_INTERNAL_RH.mp
      hPass

  unfold RiemannHypothesis

  intro rho hz htrivial hne1

  have hzNT :
      NontrivialZetaZero rho :=
    ⟨hz, htrivial, hne1⟩

  have hPhi :
      PhiZero phiEta rho :=
    zetaZero_to_phiZero_of_literalS1
      phiEta
      phiEta_literalS1ValueIdentity
      rho hzNT

  exact
    hInternal rho hPhi

end AWPI.PhiRH.NativePassivityCore