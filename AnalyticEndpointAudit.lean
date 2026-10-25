import SoloboloAdmission.FiniteProgramEndpoint
import SoloAdmission.AnalyticInverse

/-!
Additional exact endpoint and dependency targets for the recovered analytic
closures and raw finite-program residual route. SOURCE_ONLY: native Lean
compilation and actual axiom-report execution are NOT_RUN.

The two typed RH implications retain the external actual residual condition.
The definitional iff below expands it completely, without a coefficient-limit
or gluing premise. It does not construct a program satisfying that condition
or turn locally uniform convergence into finite Boolean acceptance.
-/

#check (SoloboloAdmission.FiniteProgram.nativeRH_of_uniformResidual :
  ∀ G : SoloboloAdmission.FiniteProgram,
    SoloboloAdmission.ActualUniformResidualCondition G → _root_.RiemannHypothesis)

#check (SoloboloAdmission.exists_finiteProgram_uniformResidual_implies_RH :
  (∃ G : SoloboloAdmission.FiniteProgram,
    SoloboloAdmission.ActualUniformResidualCondition G) → _root_.RiemannHypothesis)

#check (fun G : SoloboloAdmission.FiniteProgram =>
  (Iff.rfl : SoloboloAdmission.ActualUniformResidualCondition G ↔
    TendstoLocallyUniformlyOn
      (fun (n : ℕ) (z : ℂ) =>
        deriv AWPIRH.theta z +
          SoloboloAdmission.rationalODECoefficient (G.emit n) z * AWPIRH.theta z)
      (fun _ : ℂ => 0) Filter.atTop Complex.slitPlane))

#print SoloboloAdmission.FiniteProgram
#print SoloboloAdmission.ActualUniformResidualCondition
#print axioms SoloboloAdmission.FiniteProgram.actualResidual
#print axioms SoloboloAdmission.ActualUniformResidualCondition

#print axioms FiveInduction.ActualXi.Xi_nontrivial
#print axioms FiveInduction.ActualXi.critical_shift_re
#print axioms FiveInduction.ActualXi.differentiable_Xi
#print axioms FiveInduction.ActualXi.differentiable_xi
#print axioms FiveInduction.ActualXi.rh_of_nonreal_nonzero
#print axioms FiveInduction.ActualXi.rh_of_real_zeros
#print axioms FiveInduction.ActualXi.xi_eq_completed
#print axioms FiveInduction.ActualXi.xi_one
#print axioms FiveInduction.ActualXi.xi_zero
#print axioms FiveInduction.CayleyBridge.F_zero
#print axioms FiveInduction.CayleyBridge.analyticOnNhd_F
#print axioms FiveInduction.CayleyBridge.cayley_inverse_identity
#print axioms FiveInduction.CayleyBridge.cayley_inverse_mem_disk
#print axioms FiveInduction.CayleyBridge.differentiableAt_F
#print axioms FiveInduction.CayleyBridge.differentiableOn_F
#print axioms FiveInduction.CayleyBridge.mem_unitDisk
#print axioms FiveInduction.CayleyBridge.one_sub_ne_zero
#print axioms FiveInduction.CayleyBridge.xi_nonzero_right_of_cayley
#print axioms FiveInduction.CayleyBridge.zero_mem_unitDisk
#print axioms FiveInduction.HardyActual.J_NONZERO_OF_RH
#print axioms FiveInduction.HardyActual.J_eq_regularized
#print axioms FiveInduction.HardyActual.RH_OF_J_NONZERO
#print axioms FiveInduction.HardyActual.analyticOnNhd_J
#print axioms FiveInduction.HardyActual.cayley_re_gt_half
#print axioms FiveInduction.HardyActual.coeff_one
#print axioms FiveInduction.HardyActual.coeff_zero
#print axioms FiveInduction.HardyActual.differentiableOn_J
#print axioms FiveInduction.HardyActual.hasDerivAt_J_zero
#print axioms FiveInduction.HardyActual.hasSum_coeff
#print axioms SoloboloAdmission.FiniteProgram.coefficient_analytic
#print axioms SoloboloAdmission.FiniteProgram.emit_check
#print axioms SoloboloAdmission.FiniteProgram.emit_valid
#print axioms SoloboloAdmission.FiniteProgram.modelMoment_nonneg
#print axioms SoloboloAdmission.FiniteProgram.modelMoment_succ_le
#print axioms SoloboloAdmission.FiniteProgram.nativeRH_of_uniformResidual
#print axioms SoloboloAdmission.FiniteProgram.smoke_sound
#print axioms SoloboloAdmission.FiniteProgram.smoke_true
#print axioms SoloboloAdmission.FiniteProgram.theta_nonvanishing_of_uniformResidual
#print axioms SoloboloAdmission.RationalPacket.all_model_depths_monotone
#print axioms SoloboloAdmission.RationalPacket.all_model_depths_nonnegative
#print axioms SoloboloAdmission.RationalPacket.check_sound
#print axioms SoloboloAdmission.RealSpectrum.moment_nonneg
#print axioms SoloboloAdmission.RealSpectrum.moment_succ_le
#print axioms SoloboloAdmission.ResidualBudget.upper
#print axioms SoloboloAdmission.ResidualLimit.actual_ode
#print axioms SoloboloAdmission.baseKernel_nonneg
#print axioms SoloboloAdmission.cayleyQ_le_one
#print axioms SoloboloAdmission.cayleyQ_nonneg
#print axioms SoloboloAdmission.denominator_pos
#print axioms SoloboloAdmission.entire_nonvanishing_of_locallyUniform_residual
#print axioms SoloboloAdmission.exists_finiteProgram_uniformResidual_implies_RH
#print axioms SoloboloAdmission.kernel_nonneg
#print axioms SoloboloAdmission.kernel_succ
#print axioms SoloboloAdmission.kernel_succ_le
#print axioms SoloboloAdmission.locallyUniform_zero_iteratedDeriv
#print axioms SoloboloAdmission.rationalNode_denominator_ne_zero
#print axioms SoloboloAdmission.rationalODECoefficient_analytic
