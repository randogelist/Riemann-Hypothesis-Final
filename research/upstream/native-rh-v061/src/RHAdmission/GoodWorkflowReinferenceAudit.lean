import RHAdmission.FiniteGateNoShortcut
import RHAdmission.GoodWorkflowFinalAudit

/-!
# GOODWORKFLOWFRONTIER reinference / native Lean 4.33

This importer checks real kernel theorems for the existing hypothetical
admission and the newly explicit seed defect. No accepted finite witness,
finite native checker soundness or finite witness completeness is claimed.

  FINAL TARGET (OPEN):
    (∃ W : FiniteMetricCode, nativeCheck W = true) ↔ RiemannHypothesis

The `rawCheck` in the existing modules is an uninstantiated variable.
The ability to decide a rational inequality is not native RH soundness.
-/

#check RHAdmission.positive_metric_seed_defect_formula
#check RHAdmission.positive_metric_seed_defect_strict
#check RHAdmission.off_line_rejects_seed_passivity
#check RHAdmission.actual_off_line_zero_rejects_finite_gate
#check RHAdmission.accepted_native_gate_requires_zero_displacement
#check RHAdmission.GATED_FINITE_WITNESS_IFF_NATIVE_RH_OF_BRIDGES
#print axioms RHAdmission.positive_metric_seed_defect_formula
#print axioms RHAdmission.positive_metric_seed_defect_strict
#print axioms RHAdmission.off_line_rejects_seed_passivity
#print axioms RHAdmission.actual_off_line_zero_rejects_finite_gate
#print axioms RHAdmission.accepted_native_gate_requires_zero_displacement
#print axioms RHAdmission.GATED_FINITE_WITNESS_IFF_NATIVE_RH_OF_BRIDGES
