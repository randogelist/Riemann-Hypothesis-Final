# Candidate policy

Local checker diagnostics are regression data only. They are never accepted
RH witnesses. A future admitted witness must carry raw finite data and a
kernel-checked acceptance proof for the final actual-data checker.

The final checker, its actual-data soundness theorem, and a concrete accepted
RH witness are currently absent. `RHFinal/Search.lean` performs a finite local
search; its output labels explicitly retain that scope.
