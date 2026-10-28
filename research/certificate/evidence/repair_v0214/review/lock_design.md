# v0.2.14 lock shutdown review

Reviewed input: `output/RH_HILBERT_LIMIT_LEAN_v0_2_13_construction/tools/native_runner.js`, SHA256 `f6726db78ef9b532b24e2c09092e44e1e7f855c5eb84a6873c1dc519ef13803f`.

## Evidence boundary

The new user tail reports an unreadable `certutil.exe` command line at shutdown after a Lean compile failure. It supplies no certutil PID, creation identity, command, owner, or process handle. It cannot distinguish a transient or exited process row from an unrelated protected process or a still-active orphan. The reported relative script-host admission is a separate, already-recognized condition.

The runner's synchronous SHA256 paths normally wait for `WshScriptExec.Status` to indicate completion. They do not retain a global registry of certutil process objects. Shutdown drains tracked Lean and RAM tasks, then inventories every relevant process. The original `assertNoLockWorkers` intentionally permits unknown command lines during a fresh no-lock admission and rejects them whenever a lock snapshot is present. This policy can produce a conservative false positive in owned shutdown. The excerpt does not establish that it is false in this run.

## Recommended minimal change

Add a bounded retry wrapper at the owned-shutdown inventory check. An unreadable-worker rejection may be retried after a short delay using a new complete Windows inventory. Every attempt must run the original full `assertNoLockWorkers` guard on the latest complete inventory. Use a structured marker on the specific unreadable-worker exception, retaining its failure semantics and original message; do not infer exemption from PID, executable name, or parent PID.

The selected policy is at most six complete inventory attempts with 200 ms between retries: at most 1000 ms of scheduled sleeps, plus COM/WMI call time. This is not a hard wall-clock guarantee. On success, the entire latest inventory has passed the guard. On persistent ambiguity, changed/unreadable ownership, or inventory failure, preserve the lock. A newly readable absolute current-workspace command remains a hard block. For every attempt, require the current lock snapshot to retain the exact owner text, identify the same PID and full creation identity in that attempt’s freshly queried process array, and check tracked Lean/RAM processes before and after the full guard. Preserve the existing exact owner release validation, and never invoke the retry path for stale-lock acquisition/quarantine.

Log retry count and safe process metadata (PID, executable name, parent PID, creation string) for the blocked row. Do not print arbitrary process command lines. The change should make a transient row self-resolving while retaining persistent ambiguity for the next review. It cannot promise to resolve the particular certutil condition from this partial log.

## Changes to avoid

- No global allowlist for certutil, hashing helpers, or unknown commands.
- No PID-only exemption, parent-only ownership inference, or assumption that a named certutil process is executing `-hashfile`.
- No extension of the v0.2.13 relative-script admission snapshot to arbitrary unreadable native processes.
- No termination of any process and no automatic removal of the prior retained v0.2.13 lock.
- No downgrade of stale or legacy lock checks.
- No proof/cache/audit acceptance change.

## Focused cases

1. First inventory has unreadable certutil; later full inventory omits it and otherwise passes: release may proceed.
2. Unknown certutil persists throughout the budget: lock retained.
3. Same PID reappears with a different creation identity and unreadable command: lock retained.
4. Unknown row becomes a readable current-workspace worker: immediate hard block; lock retained.
5. Old blocked PID vanishes but a new relevant blocker appears: full guard still blocks.
6. WMI inventory query fails or is inconsistent during retry: lock retained.
7. Exact lock owner changes or becomes unreadable: no release.
8. Live/uncertain tracked Lean or RAM worker remains: earlier drain safeguard still blocks.
9. A valid preexisting relative runner admission remains same-owner and exact-identity scoped; it does not exempt native children.
10. Stale/legacy acquisition and quarantine execute unchanged logic and cannot use the owned-shutdown retry as an exception.

## Primary sources consulted

- Microsoft Win32_Process reference: https://learn.microsoft.com/en-us/windows/win32/cimwin32prov/win32-process . It documents creation identity, command-line and parent fields, PID reuse, and parent PID limitations.
- Microsoft Old New Thing, Raymond Chen, 2011-01-07: https://devblogs.microsoft.com/oldnewthing/20110107-00/?p=11803 . It explains that a terminated process object and its PID can remain while a handle is retained. This supports a possible transient explanation, not a diagnosis of the supplied log.
- Microsoft MSDN Magazine archive, 2002-05: https://learn.microsoft.com/en-us/archive/msdn-magazine/2002/may/scripting-windows-script-host-5-6-boasts-windows-xp-integration-security-new-object-model . It describes the `WshScriptExec` object returned by `Exec` and its status and I/O access.

No Windows, Lean, Lake, C#, Wine, or CI execution was performed for this review.
