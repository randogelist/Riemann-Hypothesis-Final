# Bounded lock-scope design review

The v0.2.12 tail exposes an acquisition/shutdown mismatch. On fresh acquisition, `assertNoLockWorkers` receives no existing lock snapshot and permits a readable relative `native_runner.js` with no current-workspace binding. During owned shutdown, the same guard receives `{owner:null}` and rejects that process globally. The supplied tail does not identify its PID, creation time, command, parent chain, or actual workspace, so it does not prove that the process is unrelated.

## Recommended minimal repair

Preserve the fresh admission decision in memory. Only when the original lock was absent, capture the exact PID, full `CreationDate`, and exact readable command of actual relative-script WSH hosts already admitted by that acquisition inventory. Require that each existed no later than the identified coordinator and lacked a current-root absolute binding. Activate the snapshot only after the fresh lock and exact owner are verified.

During shutdown of that same owned lock, retain absolute-root and exact-owner checks first. Exempt only an unchanged captured host itself. Do not exempt its descendants or any compiler/hash/RAM worker by association. New hosts, reused PIDs, changed or unreadable commands, and absolute-root matches remain guarded. Parse the WSH script argument itself; a later data argument containing `native_runner.js` is insufficient. Never extend the exception set during shutdown or import it from a previous run.

This is an exception for **preexisting admitted unresolved hosts**, not a claim that they are read-only observers or belong to another workspace. All tracked-process draining, same-workspace orphan checks, owner verification, and quarantine behavior remain in force.

## Recovery boundary

Do not apply this exception to stale or legacy lock recovery. In particular, it does not make the already retained v0.2.12 lock recoverable while that other relative process remains unresolved. A distinct new v0.2.13 workspace can start with a fresh lock and retain the admission snapshot. No process termination, forced lock deletion, or overwrite is part of this design.

## Why a generic lineage exclusion is insufficient

PID plus full creation identity and validated parent links can establish positive descent; absolute workspace paths can identify orphaned compilers after their parent exits. But a missing parent does not establish independence, and a relative command does not identify the working directory. Microsoft's `Win32_Process` documentation explicitly warns that parents may have exited and parent PIDs may be reused. The narrow repair above needs no generic “not my descendant” exclusion.

Primary source: [Microsoft Win32_Process documentation](https://github.com/MicrosoftDocs/win32/blob/docs/desktop-src/CIMWin32Prov/win32-process.md), blob `275a275184bf8bd2614b66de3b27c7c9b4579b36`.

## Source and evidence binding

- Native tail SHA-256: `fe90ee4f2db2f779539b422cd6884ed16482dc860a3b9048c447885785faa541`.
- Reviewed v0.2.12 runner SHA-256: `b11c97c591c5e200978fcfff5f37d6f6cd4b9388a464697a673174ab20c5a632`.
- Relevant functions: `assertNoLockWorkers`, `acquireRunnerLock`, `parallelShutdown`, `quarantineStaleLock`.
- Observed resource failure: `FREE_MB=5479`, `REQUIRED_MB=10476`, `LIVE_WORKERS=0`; the resource policy is outside this lock-only review.

No runner or proof file was changed. No Lean, Lake, native Windows, C#, CI, or test execution was performed. This is a source-level design review; it is not implementation or native-run validation.
