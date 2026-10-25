import RHMaster.AngularClosure
import RHMaster.CayleyBridge
import RHMaster.QQRHFrontier
import RHMaster.NativeClosures
import Merger02.FiniteFilter
import RHGPExactLedgerAdapter

/-!
# One actual-RH endpoint for the selected closure routes

Each sufficient condition is written as an explicit theorem argument. The
equivalence atlas does not assert any of its equivalent conditions. Combining
several inputs into a single label does not discharge those inputs.
-/

set_option autoImplicit false
noncomputable section

namespace RHMaster

/-- All angular and Cayley consequences exported by a successful RH route. -/
def UnifiedAngularClosure : Prop :=
  _root_.RiemannHypothesis ∧
  GlobalAngularNonnegative ∧
  GlobalRegularLogSlopeNonnegative ∧
  AngularMaster.frozenLogMaster (1 / 2) ∧
  CayleyRHAClosure.ZetaCayleyZeroLoss

theorem unifiedAngularClosure_of_native_RH (hRH : _root_.RiemannHypothesis) :
    UnifiedAngularClosure :=
  ⟨hRH, native_RH_iff_globalAngularNonnegative.mp hRH,
    native_RH_iff_globalRegularLogSlopeNonnegative.mp hRH,
    AngularMaster.RH_iff_Master.mp hRH,
    native_RH_iff_zetaCayleyZeroLoss.mp hRH⟩

theorem native_RH_iff_unifiedAngularClosure :
    _root_.RiemannHypothesis ↔ UnifiedAngularClosure :=
  ⟨unifiedAngularClosure_of_native_RH, fun h => h.1⟩

theorem cofinal_QQRH_of_native_RH (hRH : _root_.RiemannHypothesis) :
    CofinalQQRH := by
  intro M
  have hm : (0 : ℝ) < |M| + 1 := by positivity
  refine ⟨|M| + 1, by linarith [le_abs_self M], ?_⟩
  apply AngularMaster.QQRH_of_angular_positivity hm
  intro r hr x hx
  have hcut := AngularMaster.slopeCutoff_mem_Ioo hm
  exact (native_RH_iff_actualDerivativeNonnegative.mp hRH) r hr x
    ⟨(lt_trans hcut.1 hx.1).le, hx.2.le⟩

theorem native_RH_iff_cofinal_QQRH :
    _root_.RiemannHypothesis ↔ CofinalQQRH :=
  ⟨cofinal_QQRH_of_native_RH, native_RH_of_cofinal_QQRH⟩

theorem unified_closure_of_cofinal_QQRH (h : CofinalQQRH) :
    UnifiedAngularClosure :=
  unifiedAngularClosure_of_native_RH (native_RH_of_cofinal_QQRH h)

theorem unified_closure_of_global_angular_nonnegative
    (h : GlobalAngularNonnegative) : UnifiedAngularClosure :=
  unifiedAngularClosure_of_native_RH (native_RH_of_globalAngularNonnegative h)

theorem unified_closure_of_regular_logSlope_nonnegative
    (h : GlobalRegularLogSlopeNonnegative) : UnifiedAngularClosure :=
  unifiedAngularClosure_of_native_RH
    (native_RH_iff_globalRegularLogSlopeNonnegative.mpr h)

theorem unified_closure_of_cayley_zero_loss
    (h : CayleyRHAClosure.ZetaCayleyZeroLoss) : UnifiedAngularClosure :=
  unifiedAngularClosure_of_native_RH (native_RH_iff_zetaCayleyZeroLoss.mpr h)

theorem unified_closure_of_native_energy_and_coefficient_identity
    (hUS : AWPIRH.US_AWPI)
    (hCoeff : AWPIRH.NativeProductCoefficientIdentity) : UnifiedAngularClosure :=
  unifiedAngularClosure_of_native_RH
    (Native.rh_of_native_subexponential_and_coefficient_identity hUS hCoeff)

theorem unified_closure_of_native_energy_and_local_row_ode
    (hUS : AWPIRH.US_AWPI)
    (hLocal : AWPIRH.ActualLocalRowODE) : UnifiedAngularClosure :=
  unifiedAngularClosure_of_native_RH
    (Native.rh_of_native_subexponential_and_local_row_ode hUS hLocal)

theorem unified_closure_of_finite_filter_and_energy
    (hFilter : Merger02.ActualFiniteFilterStatement)
    (hUS : Merger02.ActualUS) : UnifiedAngularClosure :=
  unifiedAngularClosure_of_native_RH
    (Merger02.US_ENERGY_IMPLIES_RH_GIVEN_FINITE_FILTER hFilter hUS)

theorem unified_closure_of_local_pole_negativity_and_frozen_positivity
    (hlocal : Merger04.ForwardLocalPole.ActualLocalPoleForcesDirectNegativity)
    (hUS : NativeSoloboloContinuant.ActualCofinalUniformDepthPositive) :
    UnifiedAngularClosure :=
  unifiedAngularClosure_of_native_RH
    (Native.rh_of_local_pole_negativity_and_frozen_positivity hlocal hUS)

theorem unified_closure_of_mersenne_trace_and_channel_analysis
    (S : NativeSoloboloNegativity.FiniteCayleyDefectSystem)
    (hchannel : NativeSoloboloNegativity.ActualOffLineChannelAnalysis)
    (hconv : NativeSoloboloNegativity.CofinalMersenneXiCayleyTraceConvergence S) :
    UnifiedAngularClosure :=
  unifiedAngularClosure_of_native_RH
    (Native.rh_of_mersenne_trace_convergence_and_channel_analysis S hchannel hconv)

theorem unified_closure_of_xi_analytics_and_payment
    {HeatZero : ℝ → ℝ → ℝ → Prop} {safeThreshold : ℝ}
    {EscapeEvent : ℝ → ℝ → Prop}
    (hXi : RHGPNativeReserveReduction.XiAnalyticPointwisePackage
      RHGPNativeReserveReduction.ActualNontrivialZero HeatZero safeThreshold EscapeEvent)
    (hM7 : RHGPNativeReserveReduction.NativeM7BKQROneStepPaymentPackage
      RHGPNativeReserveReduction.ActualNontrivialZero HeatZero) :
    UnifiedAngularClosure :=
  unifiedAngularClosure_of_native_RH
    (RHGPNativeReserveReduction.ACTUAL_XI_PLUS_M7_BKQR_PAYMENT_IMPLIES_MATHLIB_RH
      hXi hM7)

/-- The final equivalence atlas, with ordinary slopes restricted to the interior. -/
theorem RH_MASTER_EQUIVALENCE_ATLAS :
    (_root_.RiemannHypothesis ↔ GlobalAngularNonnegative) ∧
    (_root_.RiemannHypothesis ↔ GlobalRegularLogSlopeNonnegative) ∧
    (_root_.RiemannHypothesis ↔ AngularMaster.frozenLogMaster (1 / 2)) ∧
    (_root_.RiemannHypothesis ↔ CayleyRHAClosure.ZetaCayleyZeroLoss) ∧
    (_root_.RiemannHypothesis ↔ CofinalQQRH) :=
  ⟨native_RH_iff_globalAngularNonnegative,
    native_RH_iff_globalRegularLogSlopeNonnegative,
    AngularMaster.RH_iff_Master,
    native_RH_iff_zetaCayleyZeroLoss,
    native_RH_iff_cofinal_QQRH⟩

end RHMaster
