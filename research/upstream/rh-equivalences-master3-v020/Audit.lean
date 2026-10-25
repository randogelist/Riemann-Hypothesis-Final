import Master3Computation
import Lean.Util.CollectAxioms

open Lean Elab Command
set_option autoImplicit false
set_option maxRecDepth 10000
set_option maxHeartbeats 0

#print MasterChain.MASTER_3
#check MasterChain.xiZeroSet_countable
#check MasterChain.xiDivisorMeasure_sigmaFinite
#check MasterChain.integral_laplace_kernel
#check MasterChain.defect_integrable_of_second_moment
#check MasterChain.kernelMassIdentity_of_second_moment
#check MasterChain.density_integrable_of_second_moment
#check MasterChain.C_RR_eq_densityL2_norm_sq_of_second_moment
#check MasterChain.scalarReadout_sq_le_C_RR_of_second_moment
#check MasterChain.C_RR_eq_defectAbove_of_finiteHeightOnLine
#check MasterChain.C_RR_le_tail_certificate_of_finiteHeightOnLine
#check MasterChain.C_RR_le_dyadic_121_of_finiteHeightOnLine
#check MasterChain.master_3_iff_all_dyadic_defect_bounds

run_cmd do
  let env ← getEnv
  let some l2Info := env.find? ``MasterChain.C_RR_eq_densityL2_norm_sq_of_second_moment
    | throwError "MISSING_NATIVE_L2_THEOREM"
  match l2Info.type with
  | .forallE _ _ body .default =>
      if body.isForall then
        throwError "NATIVE_L2_THEOREM_HAS_ADDITIONAL_HYPOTHESES"
  | _ => throwError "NATIVE_L2_THEOREM_MUST_HAVE_ONE_EXPLICIT_HYPOTHESIS"
  let allowed : Array Name := #[``propext, ``Classical.choice, ``Quot.sound]
  let mut count : Nat := 0
  for (name, info) in env.constants.toList do
    if (`MasterChain).isPrefixOf name then
      match info with
      | .axiomInfo _ => throwError m!"PROJECT_AXIOM_REJECTED {name}"
      | _ => pure ()
      let dependencies ← Lean.collectAxioms name
      for dependency in dependencies do
        unless allowed.contains dependency do
          throwError m!"UNAPPROVED_DEPENDENCY {name}: {dependency}"
      count := count + 1
  if count == 0 then
    throwError "EMPTY_PROJECT_AUDIT"
  for statement in #[``MasterChain.MASTER_1, ``MasterChain.MASTER_2,
      ``MasterChain.MASTER_3] do
    match env.find? statement with
    | some (.defnInfo _) => pure ()
    | _ => throwError m!"MASTER_MUST_REMAIN_A_PROPOSITION_DEFINITION {statement}"
  logInfo m!"PROJECT_DECLARATIONS_AUDITED={count}"
  logInfo "NATIVE_L2_SIGNATURE=ONE_EXPLICIT_MOMENT_INPUT"
  logInfo "DIVISOR_SIGMA_FINITE=PROVED_FOR_ACTUAL_XI"
  logInfo "SCALAR_LAPLACE_KERNEL=PROVED_WITH_CONVERGENCE"
  logInfo "KERNEL_MASS=PROVED_FROM_SECOND_MOMENT_INTEGRABILITY"
  logInfo "DENSITY_INTEGRABILITY=DERIVED_FROM_SECOND_MOMENT_INTEGRABILITY"
  logInfo "FINITE_HEIGHT_RULES=CONDITIONAL_INPUTS_EXPLICIT"
  logInfo "COMPUTATIONAL_PART=KERNEL_BRIDGE_AND_CERTIFICATE_RULES_PROVED"
  logInfo "NUMERICAL_RESULTS=EXTERNAL_ARB_ENCLOSURES_NOT_LEAN_VERIFIED"
  logInfo "ACTUAL_ANALYTIC_BRIDGES=PARTLY_DISCHARGED_REMAINING_INPUTS_EXPLICIT"
  logInfo "MASTER_3=UNPROVED_VANISHING_STATEMENT"
  logInfo "MASTER3_COMPUTATION_AXIOM_AUDIT=PASS"
