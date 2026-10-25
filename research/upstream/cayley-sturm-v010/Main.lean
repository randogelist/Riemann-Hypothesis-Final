import Bridge.NativeEndpoint

/-!
Entrypoint: compile using `run.cmd` and then read STATUS.md.
The native theorem is CONDITIONAL, as its Lean type explicitly shows.
-/

#check WitnessSolobolo.actualXi
#check WitnessSolobolo.actualTheta
#check WitnessSolobolo.actualComplexCoefficient
#check WitnessSolobolo.gpMoment
#check WitnessSolobolo.gpHankel_symm
#check WitnessSolobolo.checkSeed_sound
#check WitnessSolobolo.trace_mersenne_step
#check WitnessSolobolo.checked_seed_trace_induction
#check WitnessSolobolo.cayleyQ_unit_interval
#check WitnessSolobolo.cayley_complement_identity
#check WitnessSolobolo.checked_seed_cayley_induction
#check WitnessSolobolo.checked_seed_elementary_nonneg
#check WitnessSolobolo.AllDepthActualLayer
#check WitnessSolobolo.ANALYTIC_HURWITZ_FRONTIER
#check WitnessSolobolo.UNIVERSAL_CHECKER_SOUNDNESS_FRONTIER
#check WitnessSolobolo.CONDITIONAL_NATIVE_RH_OF_FINITE_WITNESS

-- There is intentionally NO theorem `RiemannHypothesis` without inputs.
