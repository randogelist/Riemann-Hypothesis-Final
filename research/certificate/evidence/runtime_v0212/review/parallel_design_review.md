# Dependency-aware native compiler parallelism: bounded design review

## Scope and source identity

Read-only architecture review of the v0.2.11 native Windows runner. No Lean, Lake, Windows, C#, Wine, CI, or compiler process was run. No package source was changed.

Base: `/workspace/scratch/f128c1434505/output/RH_HILBERT_LIMIT_LEAN_v0_2_11_construction`.

| File | SHA-256 |
| --- | --- |
| `tools/native_runner.js` | `738f7f92b68f8145a3c6b9e5b395e0c5ac95b156b6e4c5bdf2799c6d272fbb7f` |
| `run.cmd` | `5e6c6561c370c904b13d165986f0c045c6e7732de1745744b03619cf4a4b9f16` |
| `tools/follow_active.js` | `beb08b78f7c8ef53d06db9e99b266f1fb5a33cbb21d936a71dd6b1a8354f024f` |
| `tools/NativeSha256.cs` | `d8cd2d616ed2b7a64931fe391bd6e25b236a1c450e5b7c669df26c2974dd9f18` |

## Recommended minimal architecture

Keep one WSH coordinator and the existing package lock. Parallelize only native Lean invocations. The coordinator alone owns cache discovery, fresh hashing, restoration, source and audit generation, audit parsing, artifact cleanup, receipt publication, shared logs, counters, and the result file. Children receive their module's source, output path, and private log path; they never run another copy of the full runner.

Refactor the synchronous body into coordinator preparation, asynchronous native launch, and coordinator completion stages. A small task record holds the existing immutable input manifest, module name, phase, process handle, output/log paths, restoration information, and start time. The scheduler polls process handles and runs every completion action serially in the coordinator.

Use the current quoted `cmd /d /v:off /s /c` command with both streams redirected to the task's log, launched through `shell.Exec`. Do not add `start` or another detaching command: completion must mean the tracked shell has waited for its Lean command. Reuse the existing quoting restrictions. Do not pipe arbitrary Lean output into unread WSH pipes; direct redirection avoids a pipe filling while the coordinator polls.

## Concrete integration hazards

| Existing function / location | Required invariant |
| --- | --- |
| `processModuleBody`, dependency test | Missing `moduleKeys[dep]` currently immediately means BLOCKED. Under concurrency it can instead mean the dependency is running. Distinguish WAITING from a terminal failed/blocked dependency. |
| `moduleInput`, `saveAnchor`, `acceptRestored` | Build an input only after all local dependencies have audited terminal success, input keys, and artifact hashes. A file's existence or successful compiler exit is insufficient. An audit-only restore remains unavailable until its new audit passes. |
| `runToFile`, `invokeNative` | They currently wait synchronously. Add an asynchronous launch counterpart while preserving launch counting, quoting, flags, and exit handling. Do not make all invocations asynchronous: startup queries and hashing can retain their established behavior. |
| `append`, `log`, `result` | `append` reads and rewrites the whole shared file. Multiple writers would lose output. Only the coordinator writes shared logs/result; completed task logs are merged as whole labelled sections. |
| `clearOutputs`, `restoreAnchor`, `saveAnchor` | Never touch a task's output family while its compiler or audit is live. A compiled module is not released to dependents until fresh artifact validation, audit acceptance, and publication finish. |
| `readAnchorCore`, `workingArtifactsMatch` | Keep the one-use working digest scope confined to one synchronous restore attempt. Do not retain it across a native launch or reuse it for another module. Fresh copy/save hash phases stay separate. |
| `processModule`, global `stage` | The present finally block measures a blocking module call. Async launch returning is not module completion. Finalize timing/counters once at terminal completion and record the failing module/phase explicitly. |
| Global catch followed by `releaseRunnerLock()` | An exception can now leave child processes alive. Stop admission and drain them before releasing the lock. If completion cannot be established, preserve the lock and outputs. |
| `selectCompiler`, `certutilHashSet`, `batchHashes` | `jobs` currently controls both Lean `-j` and hash concurrency. Multiplying full-job compiler processes, then overlapping full-job hashing, oversubscribes. Separate the resource budgets. |
| `finalAudit` | Keep the selected aggregate behind a barrier: all ordinary modules must have audited success and no live tasks remain. Preserve the fresh aggregate's use of its compile log as the audit log, and the separate audit-only restored path. |

Generated audit source names currently flatten dots to underscores in `processModuleBody`. Before admitting simultaneous tasks, ensure normalized output/log/audit paths are distinct, including Windows case-insensitivity; either reject an alias or use unique per-task audit paths. Do not have an async worker silently overwrite another task's generated source.

## Dependency and failure state transitions

1. Keep `loadPlan`'s existing complete graph, source screening, topological validation, target coverage, and content fingerprints.
2. A pending module waits while any local dependency is unfinished. A terminal failure blocks its descendants. Independent ready modules remain eligible.
3. For a ready module, run `moduleInput` and the entire restore attempt in the coordinator. A verified full reuse completes immediately. A restored module needing an audit enters the audit queue without a success key.
4. A cache miss launches compilation to that module's existing output family and private compile log. On nonzero exit, merge the finished log, clear only that completed module's outputs, mark failure, and continue independent work.
5. A successful compile is inspected for the existing forbidden-output checks and then enters an audit phase. The audit is a second native Lean invocation subject to the same process/CPU/memory admission limits.
6. Only after audit exit zero, exact `checkAxioms` acceptance, and the existing fresh-content `saveAnchor` path may the task reach audited success and release dependents.
7. Do not swallow `rhFatalHash` errors inside per-module recovery. Integrity, protocol, or ownership failures stop further launches and publication; existing running tasks must be drained or left protected by the retained lock.

Use both terminal-success state and the verified key/hash pair for scheduler readiness. This prevents a partially completed coordinator action or a later logging/publication error from accidentally treating an unfinished task as ready merely because a map entry was assigned.

The compile and audit identity formulas, target matching, allowed axioms, fresh hashes, staged copies, and atomic non-overwriting receipt publication should remain unchanged. Scheduling order and the existing nonsemantic thread count are runtime policy. No kernel flag, heartbeat limit, proof source, or mathematical endpoint needs to change.

## Lock, interruption, and follower behavior

Keep the source-root-bound single owner record and its exact schema. Do not place child records inside `.native-run.lock`: both `lockSnapshotAt` and `followSnapshot` require that directory to contain only the accepted owner record.

Every compiler/audit command should retain an absolute source/output path under this workspace. Existing `assertNoLockWorkers` uses those paths to refuse stale-lock recovery while related `cmd.exe /c` or `lean.exe` workers remain. Do not weaken this rule or exclude a surviving child merely because the coordinator has exited.

For a controlled abort, stop admission, wait for tracked native commands to finish, and only then clean their partial output families and release the owner's lock. Calling `Terminate` only on a wrapper is not evidence that its compiler child has stopped. A forcibly killed coordinator cannot guarantee cleanup; preserving the owner record and the recovery checks makes that uncertainty visible and prevents unsafe reuse.

The existing follower can remain read-only and attached to the coordinator's PID/creation identity. It must continue saying that owner exit or lock removal does not certify completion of child work. It observes the coordinator's merged log, not worker log tails, and does not acquire or release locks.

## CPU and memory admission

Treat process parallelism and per-process Lean jobs as separate settings. Choose a fixed per-worker job allocation so the sum for all live compile and audit tasks stays within the configured CPU budget. Do not give every worker the existing full 16-job allocation.

Hashing during active compilation also needs budget: either reserve capacity for coordinator hash operations and cap their workers to that reserve, or defer those operations until capacity is available. Startup hashing can use its existing full budget before any Lean task begins. A minimum-one helper rule is not sufficient if every CPU slot was already allocated to compilers.

For RAM, query available memory before admitting an additional task; retain an OS reserve and a configurable per-compiler allowance. Validate the measurement before arithmetic, and throttle queries and wait logging. If RAM observation is unavailable, disable parallel admission rather than claiming an established safe parallel capacity. If no tasks are active and the valid measurement is below the launch threshold, report the resource block rather than spin indefinitely.

A launch gate is an estimate, not a hard memory limit: Lean workloads and other applications can grow after admission. Do not claim a strict memory ceiling without an enforced limit, and do not add a new Lean memory flag under the guise of a scheduling-only change.

Microsoft documents `Win32_OperatingSystem.FreePhysicalMemory` as a read-only uint64 measurement in kilobytes of currently unused available physical memory. Source read: [Microsoft Win32 documentation](https://github.com/MicrosoftDocs/win32/blob/docs/desktop-src/CIMWin32Prov/win32-operatingsystem.md), Git blob `e6a3e7bad2118d21f2bc26cddea722837985fa63`.

The baseline's exact native invocation is `lean.exe -j<jobs> -o <module.olean> <source.lean>`; audit invocations also receive `-j<jobs>`. Pinned Lean source confirms the shell's configured thread count is passed to its task manager: [Lean v4.33.0 src/util/shell.cpp](https://github.com/leanprover/lean4/blob/v4.33.0/src/util/shell.cpp), Git blob `29b859887e2ca380b30216242fa02c95f291cb1a`. No change to theorem semantics or compilation flags is recommended.

## Verification limits

Portable mocked-host scenarios can inspect dependency admission, completion order, failure propagation, shared-write ownership, launch counters, resource-budget arithmetic, audit-only gating, and lock-preservation decisions. They cannot establish Windows process-tree behavior, real shell quoting/redirection, WMI availability and accuracy, compiler termination, memory use, or elapsed-time improvement. Those require the user's native run.

No speedup, native execution result, or compiler/axiom-audit result is claimed by this design review.

