import Bridge.ActualTraceEndpoint
import FiniteWitness.MatchedAmplification

/-!
# v0.5.0 summary

The 26 v0.4.0 modules are byte-for-byte preserved.
New results (if native Lean 4.33.0 accepts them):
* sharp positive-anchor mass control (all ranks / all depths)
* exact transported Cayley debit = positive weighted squares
* rank-independent total debit storage budget
* same algebraic bound at EVERY REAL positive anchor
* actual xi direct centered Widder is explicitly defined
* native RH implication is conditional on actual-xi calibration and the
  off-line spectral-explosion theorem, both STILL OPEN in this package.
No proved theorem has native RH as a closed conclusion.
-/

#check WitnessSolobolo.channelMagnitude_le_peak
#check WitnessSolobolo.channelMagnitude_matched
#check WitnessSolobolo.channelPeak_gt_one
#check WitnessSolobolo.anchorTransport_le_sharp
#check WitnessSolobolo.allAnchorCayleyPowerTrace_sharp_bound
#check WitnessSolobolo.allAnchorDebit_eq_squares
#check WitnessSolobolo.allAnchorDebit_total_budget
#check WitnessSolobolo.checked_telescopic_sharp_debit_budget
#check WitnessSolobolo.allRealAnchorTrace_bound
#check WitnessSolobolo.calibrated_actualWidder_bounded
#check WitnessSolobolo.CONDITIONAL_RH_OF_SOLOBOLO_WITNESS

#print axioms WitnessSolobolo.channelMagnitude_le_peak
#print axioms WitnessSolobolo.anchorTransport_le_sharp
#print axioms WitnessSolobolo.allAnchorDebit_total_budget
#print axioms WitnessSolobolo.checked_telescopic_sharp_debit_budget
#print axioms WitnessSolobolo.allRealAnchorTrace_bound
#print axioms WitnessSolobolo.CONDITIONAL_RH_OF_SOLOBOLO_WITNESS
