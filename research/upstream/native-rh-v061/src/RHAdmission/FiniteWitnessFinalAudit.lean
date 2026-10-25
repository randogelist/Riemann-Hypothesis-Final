import RHAdmission.FiniteVerifierBarrier

/-!
# FINAL AUDIT
Goal (NOT YET PROVED UNCONDITIONALLY):
  (∃ finite W, nativeCheck W = true) ↔ _root_.RiemannHypothesis

Proved here:
  1. finite rational positivity checking;
  2. finite metric construction;
  3. finitely coded GLOBAL admission ↔ actual native RH;
  4. soundness + completeness of a proposed executable checker => goal;
  5. generic positivity-checker soundness is itself RH-equivalent.

OPEN: an independently justified native checker and both directions of its
soundness/completeness. No theorem assumes RH inside an accepted certificate.
-/

#check RHAdmission.identity_metric_code_accepted
#check RHAdmission.FINITELY_CODED_ADMISSION_IFF_NATIVE_RH
#check RHAdmission.FINITE_WITNESS_IFF_NATIVE_RH_OF_SOUND_COMPLETE
#check RHAdmission.POSITIVE_ONLY_CHECKER_SOUNDNESS_IFF_NATIVE_RH
#check RHAdmission.POSITIVE_ONLY_FINITE_WITNESS_IFF_RH_EQUIV_RH
#print axioms RHAdmission.identity_metric_code_accepted
#print axioms RHAdmission.FINITELY_CODED_ADMISSION_IFF_NATIVE_RH
#print axioms RHAdmission.FINITE_WITNESS_IFF_NATIVE_RH_OF_SOUND_COMPLETE
#print axioms RHAdmission.POSITIVE_ONLY_CHECKER_SOUNDNESS_IFF_NATIVE_RH
#print axioms RHAdmission.POSITIVE_ONLY_FINITE_WITNESS_IFF_RH_EQUIV_RH
