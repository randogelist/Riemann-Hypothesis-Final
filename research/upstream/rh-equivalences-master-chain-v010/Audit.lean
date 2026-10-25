import MasterChain
import Lean.Util.CollectAxioms

open Lean Elab Command
set_option maxRecDepth 10000
set_option maxHeartbeats 0

#print MasterChain.MASTER_1
#print MasterChain.MASTER_2
#print MasterChain.MASTER_3
#print MasterChain.NativeIntegrability
#print MasterChain.TraceDecomposition
#print MasterChain.KernelMassIdentity
#print MasterChain.LaplacePlancherel
#check MasterChain.master_1_of_analytic_bridges
#check MasterChain.master_2_of_analytic_bridges
#check MasterChain.master_chain_equivalences
#check MasterChain.xiDensityVector_norm_sq
#check MasterChain.master_3_iff_xiDensityVector_zero

run_cmd do
  let env ← getEnv
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
    | _ => throwError m!"MASTER_MUST_BE_A_PROPOSITION_DEFINITION {statement}"
  logInfo m!"PROJECT_DECLARATIONS_AUDITED={count}"
  logInfo "MASTER_1=INDEPENDENT_ACTUAL_XI_STATEMENT"
  logInfo "MASTER_2=INDEPENDENT_ACTUAL_XI_STATEMENT"
  logInfo "MASTER_3=INDEPENDENT_UNPROVED_VANISHING_STATEMENT"
  logInfo "CHAIN=PROVED_WITH_EXPLICIT_HYPOTHESES"
  logInfo "DENSITY_L2_IDENTITY=PROVED_WITH_INTEGRABILITY"
  logInfo "ACTUAL_ANALYTIC_BRIDGES=EXPLICIT_NOT_DISCHARGED"
  logInfo "COMPUTATIONAL_PART=DEFERRED"
  logInfo "MASTER_CHAIN_AXIOM_AUDIT=PASS"
