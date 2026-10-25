import RHAdmission.Main

/-!
Run with `lean -E hasSorry` and inspect the printed axiom dependencies.
Only the standard Mathlib logical axioms are permitted.  A successful
compilation is NOT a proof that the hypothetical admission exists.
-/

#print axioms RHAdmission.channelGain_eq_one_iff
#print axioms RHAdmission.channelStep_preserves_krein
#print axioms RHAdmission.metric_passivity_iff_critical
#print axioms RHAdmission.metric_passivity_all_depths
#print axioms RHAdmission.FULL_HYPOTHETICAL_ADMISSION_IFF_NATIVE_RH
#print axioms RHAdmission.full_metric_all_depths
#print axioms RHAdmission.full_admission_all_depths
#print axioms RHAdmission.HYPOTHETICAL_ADMISSION_IFF_RH
#print axioms RHAdmission.MAIN_ADMISSION_IFF_NATIVE_RH
#print axioms RHAdmission.ADMISSION_TO_DOWNSTREAM
#print axioms RHAdmission.ADMISSION_FORCES_ALL_DEPTHS

#check RHAdmission.MAIN_ADMISSION_IFF_NATIVE_RH
#check RHAdmission.ADMISSION_TO_DOWNSTREAM
