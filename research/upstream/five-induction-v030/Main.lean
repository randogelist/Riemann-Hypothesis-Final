import FiveInduction.InputChain
import FiveInduction.HardyInduction

#check FiveInduction.FIVE_INDUCTION_CHAIN
#check FiveInduction.BASE_CERTIFICATE
#check FiveInduction.PROVED_SUCCESSOR
#check FiveInduction.EXAMPLE_ALL_STAGES
#check FiveInduction.Applications.RH_OF_STURM_CONVERGENCE
#check FiveInduction.Applications.RH_OF_DIFFERENTIAL_CONVERGENCE
#check FiveInduction.Applications.SturmXiRealization
#check FiveInduction.Applications.DifferentialXiRealization

-- Print the actual open inputs, not only their names and Prop types.
#print FiveInduction.SOSInput.SOSXiRealization
#print FiveInduction.ProjectionInput.ProjectionXiRealization
#print FiveInduction.SchurInput.SchurXiRealization
#print FiveInduction.NormalizedInputs.SturmInput
#print FiveInduction.NormalizedInputs.DifferentialInput

#check FiveInduction.SOSInput.RH_OF_SOS_REALIZATION
#check FiveInduction.ProjectionInput.RH_OF_PROJECTION_REALIZATION
#check FiveInduction.SchurInput.RH_OF_SCHUR_REALIZATION
#check FiveInduction.NormalizedInputs.RH_OF_STURM_INPUT
#check FiveInduction.NormalizedInputs.RH_OF_DIFFERENTIAL_INPUT
#check FiveInduction.InputChain.RH_OF_ANY_INPUT
#check FiveInduction.InputChain.FIVE_INPUT_ENDPOINTS

-- Actual normalized-zeta SOS chain.
#check FiveInduction.HardyDefect.defect_succ
#check FiveInduction.HardyDefect.defect_succ_squares
#check FiveInduction.HardyDefect.defect_pos_of_le
#check FiveInduction.HardyTail.tail_bound
#check FiveInduction.HardyCompleteness.nonzero_on_disk_iff_finite_certificate
#check FiveInduction.HardyActual.J_eq_zeta
#check FiveInduction.HardyActual.J_eq_regularized
#check FiveInduction.HardyActual.coeff_one
#check FiveInduction.HardyActual.hasSum_coeff
#check FiveInduction.HardyActual.J_NONZERO_IFF_RH
#check FiveInduction.HardyEndpoint.ACTUAL_BASE_CERTIFICATE
#check FiveInduction.HardyEndpoint.actual_first_disk_certificate
#check FiveInduction.HardyEndpoint.RH_IFF_ACTUAL_DISK_EXHAUSTION
#check FiveInduction.HardyInduction.RH_OF_PRESCRIBED_RADIUS_STEP
#print FiveInduction.HardyActual.ActualHardyEnergy
#print FiveInduction.HardyCompleteness.DiskExhaustion
#print FiveInduction.HardyEndpoint.ActualDiskExhaustion
#print FiveInduction.HardyInduction.PrescribedRadiusStep
