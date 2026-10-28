Focused shutdown regression harness
===================================

This directory is a portable Node VM test harness. It is evidence for the
runner's source-level decisions under a simulated host, not part of the user
runner and not a requirement for running the Lean package on Windows.

Run only against an explicitly selected candidate and its exact SHA256:

node focused_review.js --package-root PATH_TO_PACKAGE --expected-runner-sha256 SHA256 --report PATH_TO_NEW_REPORT

The three host dependency files were copied without edits from the earlier
portable mock host. HOST_DEPENDENCIES.json records their hashes and origin.
No old result report was copied. Every result produced by focused_review.js
binds the candidate runner's bytes before and after the scenarios.

The whole WSH entry point is not run. Actual assembled runner functions are
evaluated in Node's VM with in-memory file, process, lock and WMI boundaries.
The existing COM environment-assignment syntax is adapted only at the host
boundary. No child-process API, real shell, Windows process, WMI query, Lean,
Lake, C# compiler, Wine or CI is invoked by this harness.

The scenarios deliberately distinguish:

* A successful complete exact-PID query reporting absence.
* A still-live unresolved relative runner, which remains a blocker.
* Identity/command changes and incomplete query results, which fail closed.
* Preexisting exact admitted hosts and new unresolved hosts.
* Current-workspace worker guards and stale-lock acquisition semantics.
* The initial census's bounded recheck set and the single fresh inventory
  required after an unresolved relative runner disappears.
* A current-workspace child or new unresolved relative host found at that
  fresh inventory, which must block cleanup without a second relative wait.

Scheduled mock-clock sleeps and query counts do not establish a real WMI
wall-clock bound. Results do not certify native operation or a mathematical
proof. Candidate changes require a fresh hash-bound report.
