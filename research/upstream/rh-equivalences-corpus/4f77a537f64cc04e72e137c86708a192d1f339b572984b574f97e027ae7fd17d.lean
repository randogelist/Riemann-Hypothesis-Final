import AWPI.PhiRH.NativeRHPointwiseWaist
import AWPI.PhiRH.NativeRHExactWaist
import AWPI.PhiRH.NativePassivityCore

namespace AWPI.PhiRH.NativeRHGlobalNormalForm

open AWPI.PhiRH
open AWPI.PhiRH.NativePhiZeroBridge
open AWPI.PhiRH.NativeEtaPhi
open AWPI.PhiRH.NativePassivityCore
open AWPI.PhiRH.NativeRHExactWaist
open AWPI.PhiRH.NativeRHPointwiseWaist
open AWPI.PhiRH.DyadicScale

/--
Global literal dyadic normal form.

At every internal Phi_eta zero, both reciprocal dyadic directions
must contract to at most one.
-/
def GlobalLiteralDyadicContraction : Prop :=
  ∀ rho : ℂ,
    PhiZero phiEta rho →
      dyadicScale
          (2 * (rho.re - (1 / 2 : ℝ))) ≤ 1 ∧
      dyadicScale
          (-2 * (rho.re - (1 / 2 : ℝ))) ≤ 1

/--
Axiom-free global normal form:

  GlobalLiteralDyadicContraction ↔ Mathlib RiemannHypothesis.
-/
theorem GLOBAL_LITERAL_DYADIC_CONTRACTION_IFF_MATHLIB_RH :
    GlobalLiteralDyadicContraction ↔
      RiemannHypothesis := by

  constructor

  · intro hGlobal

    apply
      CANONICAL_INTERNAL_RH_IFF_MATHLIB_RH.mp

    intro rho hz

    have hre :
        rho.re = (1 / 2 : ℝ) :=
      (POINTWISE_LITERAL_DYADIC_SIGNS_IFF_RE_HALF
        rho hz).1
        (hGlobal rho hz)

    exact hre

  · intro hRH

    have hInternal :
        canonicalModel.RH :=
      CANONICAL_INTERNAL_RH_IFF_MATHLIB_RH.mpr
        hRH

    intro rho hz

    have hre :
        rho.re = (1 / 2 : ℝ) := by

      have hcrit :=
        hInternal rho hz

      exact hcrit

    exact
      (POINTWISE_LITERAL_DYADIC_SIGNS_IFF_RE_HALF
        rho hz).2 hre

end AWPI.PhiRH.NativeRHGlobalNormalForm