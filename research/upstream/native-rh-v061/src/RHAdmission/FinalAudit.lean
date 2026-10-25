import RHAdmission.FinalChain

/-!
The final audit checks that the actual theorem depends only on Mathlib's
standard logical axioms and not on sorryAx, a witness, or a research axiom.
An axiom report is diagnostic: theorem propositions must also be inspected.
-/

#check RHAdmission.FINAL_HYPOTHETICAL_ADMISSION_IFF_RH
#check RHAdmission.FINAL_ALL_DEPTH_ADMISSION_IFF_RH
#check RHAdmission.FINAL_SOLOBOLO_AXIS_IFF_RH
#check RHAdmission.FINAL_ADMISSION_TO_RH_QQRH_AND_ALL_DEPTHS
#check RHAdmission.shared_tower_equal_all_depths
#check RHAdmission.shared_tower_transfer_nonnegative

#print axioms RHAdmission.solobolo_shifted_axis_iff_critical
#print axioms RHAdmission.native_RH_iff_solobolo_shifted_axis
#print axioms RHAdmission.full_admission_iff_all_depth
#print axioms RHAdmission.ALL_DEPTH_ADMISSION_IFF_NATIVE_RH
#print axioms RHAdmission.shared_tower_equal_all_depths
#print axioms RHAdmission.shared_tower_transfer_nonnegative
#print axioms RHAdmission.FINAL_HYPOTHETICAL_ADMISSION_IFF_RH
#print axioms RHAdmission.FINAL_ALL_DEPTH_ADMISSION_IFF_RH
#print axioms RHAdmission.FINAL_SOLOBOLO_AXIS_IFF_RH
#print axioms RHAdmission.FINAL_ADMISSION_TO_RH_QQRH_AND_ALL_DEPTHS
