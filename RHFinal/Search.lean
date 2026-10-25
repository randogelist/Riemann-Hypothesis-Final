import RHFinal.Core.BoundedSearch

/-! Run with `lean --run RHFinal/Search.lean`; diagnostic output only. -/

def main : IO Unit := do
  IO.println "SEARCH_SCOPE=LOCAL_SYMBOLIC_SOS_DIAGNOSTIC"
  IO.println "COEFFICIENT_BOUND=1"
  IO.println s!"CANDIDATE_COUNT={(RHFinal.candidates 1).length}"
  match RHFinal.searchLocal RHFinal.diagnosticProblem 1 with
  | none => IO.println "LOCAL_CANDIDATE=NONE"
  | some w =>
      IO.println "LOCAL_CANDIDATE=FOUND"
      IO.println (reprStr w)
      IO.println s!"LOCAL_CHECK={RHFinal.checkLocal RHFinal.diagnosticProblem w}"
  IO.println "ACTUAL_XI_CALIBRATION=OPEN"
  IO.println "RH_WITNESS_ACCEPTANCE=NOT_IMPLEMENTED"

