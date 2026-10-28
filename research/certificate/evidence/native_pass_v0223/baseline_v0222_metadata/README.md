# RH Hilbert Limit v0.2.22 construction

This revision repairs the shutdown handling of legacy script hosts. It preserves
all 96 Lean source files, all 394 selected audit targets, the 92-module ordinary
compile order and the `CancellationAudit.lean` endpoint. The mode remains
`A_TIER_LEAN`, the target remains `LOCAL_COMPILER`, and the branch remains
`RH_HILBERT_LIMIT / Hilbert.vector`.

## Reported failure and repair

The supplied v0.2.21 log reaches 92/92 ordinary modules with zero new or
reaudited tasks. It restores `CancellationAudit` and reports 394 audit targets.
The run then fails at `WORKER_SHUTDOWN`: a readable legacy relative runner has
an unknown workspace. The old diagnostic does not identify that process or
its actual script argument. This revision does not claim to have established
which process caused that native failure.

The guard now identifies the actual WSH script argument for a deliberately
restricted, fully consumed command syntax. A later argument containing
`native_runner.js` no longer classifies an unrelated script as the runner.
Unsupported quoting or host switches retain the previous conservative
matcher. Absolute references to the current workspace still trigger the
existing guard before script classification.

An unresolved relative runner receives bounded exact process checks during
owned shutdown. A still-live host remains a blocker. Only a complete exact
query reporting absence retires that identity. PID reuse, changed creation
time, parent, executable or known relative command, incomplete queries and
query failures preserve the lock. An unreadable host that becomes a relative
runner remains pending and binds its first readable command.

After such a relative host exits, one fresh complete inventory checks for
workers it may have left behind. A new unresolved relative host in that final
inventory blocks release immediately. A current-workspace worker blocks
release as before. These are cooperative lock and point-in-time process
checks, not an atomic operating-system process-tree guarantee.

The recheck has one shared budget: 64 queued rows, six rounds, at most two
complete inventories and five scheduled 200 ms waits. WMI calls have no new
hard wall-clock deadline. Existing exact fresh-admission and read-only
follower exceptions are unchanged. No foreign process is terminated, no old
workspace lock is deleted, and no forced stale recovery is added.

If a genuinely unresolved legacy runner remains active, the lock is still
retained. The diagnostic now identifies its PID, parent, creation timestamp,
host, parser mode, relative script and command hash without printing arbitrary
script arguments. This is a conservative repair, not a guarantee that every
legacy-host conflict will become a successful run.

## Preserved mathematical endpoint

The last complete user-supplied native pass is v0.2.20. Its printed standard
axiom audits include:

```lean
RH_HilbertLimit.nativeRH_of_exists_admissible_cancellationBudget
  (hWitness : ∃ W, W.Admissible) : RiemannHypothesis

RH_HilbertLimit.exists_admissible_cancellationBudget_iff_nativeRH :
  (∃ W, W.Admissible) ↔ RiemannHypothesis
```

Thus the recorded semantic endpoint is retained: assuming an admissible
cancellation budget exists, RH follows, and the converse is also recorded.
The budget contains two natural numbers; admissibility is a universal
condition after the cutoff. This is not a terminating finite Bool checker.
The requested finite-checker soundness and equivalence remain **OPEN**, and
the runner retains `FORMAL_CLOSURE=OPEN`. No unconditional admissible witness,
accepted finite-checker witness or unconditional RH is obtained here.

## Cache and validation

All 93 active modules, including the final audit, remain eligible for reuse
when the existing same-target source, dependency, toolchain, artifact and
audit checks succeed. Zero compilation tasks are induced by source changes.
These are conditional expectations, not aggregate counters from the failed
v0.2.21 log. Missing or invalid cache evidence still causes a rebuild or failure.

The launcher, cache keys, content hashing, helper sources, compiler/audit
flags, scheduling and RAM admission code are preserved. This revision has
no measured runtime-speedup claim. The latest run had no dirty frontier, so
it did not need parallel compilation or RAM warming.

Twenty focused tests execute the assembled runner functions in a Node VM
with synthetic process, WMI, shell, clock and file boundaries. All pass and
the report binds the candidate SHA256. No Windows/WSH/native runner, Lean,
Lake, C# compiler, Wine or CI was executed during preparation. Native receipt
contents were not supplied for independent inspection. The new package
still needs its native run on the user's machine.

## Run

Save the ZIP in Downloads and run this one CMD command:

```cmd
cd /d "%USERPROFILE%\Downloads" && (if not exist "E:\RH-FAST\workspaces" mkdir "E:\RH-FAST\workspaces") && tar -xf "RH_HILBERT_LIMIT_LEAN_v0_2_22_construction.zip" -C "E:\RH-FAST\workspaces" && cmd /k call "E:\RH-FAST\workspaces\RH_HILBERT_LIMIT_LEAN_v0_2_22_construction\run.cmd"
```

This uses a new workspace under `E:\RH-FAST\workspaces` and the established
shared cache under `E:\RH-FAST\anchors`. The earlier retained lock remains
under its own workspace. The runner uses installed native Lean 4.33.0 and
compatible cached Mathlib. It adds no Lake, Python, PowerShell, WSL or network
setup requirement.

## Evidence

The new evidence directory contains a selected exact transcription of the
reported final stages, the runtime diff, frozen source manifest, protected
function comparison, focused simulated-host report and independent source
review. Earlier evidence and declaration metadata remain intact. No new
compiled artifacts, native PASS receipts or mathematical audits are created.
`SHA256SUMS.txt` covers every other payload file.

Primary API references used for the narrow runtime design:

- [Microsoft cscript command documentation](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cscript) separates the script filename from its arguments.
- [Microsoft Win32_Process documentation](https://learn.microsoft.com/en-us/windows/win32/cimwin32prov/win32-process) describes the command, process identity, parent and creation fields used by the existing queries.
