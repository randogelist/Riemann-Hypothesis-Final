import AngularMaster.Chain
import CayleyRHClosure

/-!
Exact integration of the angular and Cayley RH equivalence atlases.

The xi functions, centered functions, theta functions, and nontrivial-zero
predicates coincide by definition. The conclusions below are equivalences;
none asserts that an RH-equivalent condition holds.
-/

set_option autoImplicit false
noncomputable section

namespace RHMaster

theorem actual_xi_eq_cayley_xi :
    AWPIRH.xi = CayleyGolPhi.mathlibXi := rfl

theorem actual_centeredXi_eq_cayley_centeredXi :
    AWPIRH.centeredXi = CayleyGolPhi.centeredXi := rfl

theorem actual_theta_eq_cayley_slitTheta :
    AWPIRH.theta = CayleyGolPhi.slitTheta := rfl

theorem actual_nontrivialZero_eq_cayley_nontrivialZetaZero :
    AWPIRH.NontrivialZero = CayleyGolPhi.NontrivialZetaZero := rfl

theorem actual_xi_eq_completedGolPhi :
    AWPIRH.xi = CayleyGolPhi.completedGolPhiS1 := rfl

theorem native_RH_iff_golPhi_RH :
    _root_.RiemannHypothesis ↔ CayleyGolPhi.GolPhiRiemannHypothesis :=
  CayleyGolPhi.GOLPHI_RH_IFF_MATHLIB_RH.symm

theorem native_RH_iff_zetaCayleyZeroLoss :
    _root_.RiemannHypothesis ↔ CayleyRHAClosure.ZetaCayleyZeroLoss :=
  CayleyRHAClosure.ZETA_CAYLEY_ZERO_LOSS_IFF_MATHLIB_RH.symm

theorem native_RH_iff_golPhiCayleyZeroLoss :
    _root_.RiemannHypothesis ↔ CayleyRHAClosure.GolPhiCayleyZeroLoss :=
  CayleyRHAClosure.GOLPHI_CAYLEY_ZERO_LOSS_IFF_MATHLIB_RH.symm

theorem native_RH_iff_golPhiCayleySaturation :
    _root_.RiemannHypothesis ↔ CayleyRHAClosure.GolPhiCayleySaturation :=
  CayleyRHAClosure.GOLPHI_CAYLEY_SATURATION_IFF_MATHLIB_RH.symm

theorem native_RH_iff_golPhiCayleyUnitEnergyPreservation :
    _root_.RiemannHypothesis ↔ CayleyRHAClosure.GolPhiCayleyUnitEnergyPreservation :=
  CayleyRHAClosure.GOLPHI_CAYLEY_UNIT_ENERGY_PRESERVATION_IFF_MATHLIB_RH.symm

theorem native_RH_iff_actualDerivativeNonnegative :
    _root_.RiemannHypothesis ↔
      AngularMaster.DerivativeNonnegative AngularMaster.actualProfile :=
  AngularMaster.native_RH_iff_theta_zeros_nonpositive.trans
    AngularMaster.theta_zeros_iff_actual_derivative_nonnegative

theorem actualProfileMaster_iff_zetaCayleyZeroLoss :
    AngularMaster.ProfileMaster AngularMaster.actualProfile ↔
      CayleyRHAClosure.ZetaCayleyZeroLoss :=
  AngularMaster.native_RH_iff_actual_profileMaster.symm.trans
    native_RH_iff_zetaCayleyZeroLoss

theorem actualDerivativeNonnegative_iff_zetaCayleyZeroLoss :
    AngularMaster.DerivativeNonnegative AngularMaster.actualProfile ↔
      CayleyRHAClosure.ZetaCayleyZeroLoss :=
  native_RH_iff_actualDerivativeNonnegative.symm.trans
    native_RH_iff_zetaCayleyZeroLoss

theorem thetaZerosNonpositive_iff_zetaCayleyZeroLoss :
    AngularMaster.ThetaZerosNonpositive ↔ CayleyRHAClosure.ZetaCayleyZeroLoss :=
  AngularMaster.native_RH_iff_theta_zeros_nonpositive.symm.trans
    native_RH_iff_zetaCayleyZeroLoss

theorem frozenLogMaster_iff_zetaCayleyZeroLoss :
    AngularMaster.frozenLogMaster (1 / 2) ↔ CayleyRHAClosure.ZetaCayleyZeroLoss :=
  AngularMaster.FROZEN_RH_MASTER_EQUIVALENCE.symm.trans
    native_RH_iff_zetaCayleyZeroLoss

/-- The angular and Cayley conditions share the same literal native RH endpoint. -/
theorem ANGULAR_CAYLEY_RH_EQUIVALENCE_ATLAS :
    (_root_.RiemannHypothesis ↔
      AngularMaster.ProfileMaster AngularMaster.actualProfile) ∧
    (_root_.RiemannHypothesis ↔
      AngularMaster.DerivativeNonnegative AngularMaster.actualProfile) ∧
    (_root_.RiemannHypothesis ↔ AngularMaster.frozenLogMaster (1 / 2)) ∧
    (_root_.RiemannHypothesis ↔ CayleyRHAClosure.ZetaCayleyZeroLoss) ∧
    (_root_.RiemannHypothesis ↔ CayleyRHAClosure.GolPhiCayleySaturation) ∧
    (_root_.RiemannHypothesis ↔
      CayleyRHAClosure.GolPhiCayleyUnitEnergyPreservation) :=
  ⟨AngularMaster.native_RH_iff_actual_profileMaster,
    native_RH_iff_actualDerivativeNonnegative,
    AngularMaster.FROZEN_RH_MASTER_EQUIVALENCE,
    native_RH_iff_zetaCayleyZeroLoss,
    native_RH_iff_golPhiCayleySaturation,
    native_RH_iff_golPhiCayleyUnitEnergyPreservation⟩

end RHMaster
