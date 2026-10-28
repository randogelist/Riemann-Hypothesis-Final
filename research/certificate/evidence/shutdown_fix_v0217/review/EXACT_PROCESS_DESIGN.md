# Exact shutdown process revalidation

The v0.2.16 report contains different unreadable certutil PIDs on successive whole-machine checks. Repeating a complete inventory can repeatedly encounter a different short-lived process. The runner's shutdown code and `follow_active.js` do not themselves launch certutil. The reported preexisting relative script host remains unresolved as to workspace; its identity does not authorize excluding native children.

The v0.2.17 change takes one complete shutdown process inventory, keeps that observation, and directly rechecks the original unreadable relevant process rows. A successful exact PID query returning no row retires only that original row. A returned process must retain the complete creation identity, executable name, and parent PID. If it becomes readable, its refreshed command is evaluated by the existing worker guard. A changed identity, failed or malformed query, or persistent unreadable command retains the lock. No process is considered harmless merely because it is called certutil or has a preexisting parent.

Every native launch is registered before its shell call. A launch call that throws leaves an uncertain entry; synchronous calls remain accounted until their waited return; all returned asynchronous process objects remain retained. Only status 1 counts as completed for those objects. Shutdown seals all native launch routes, drains known workers, and checks the launch inventory around process validation. New launch requests after sealing fail before calling the shell.

The exact current lock text and generation are checked before and after every round. Targeted self queries must identify the same PID, full creation identity, executable name, parent PID, absolute script, and launch token. The original acquisition, stale recovery, release, cache, proof audit, and memory admission rules remain unchanged. The prior retained lock is not removed.

## Bounds

There is at most one complete inventory, at most 64 original unresolved worker rows, and at most six rounds. Every round queries each still-unresolved original worker identity once and checks self at the beginning and end. Thus the limits are 384 targeted worker queries, 12 targeted self queries, and 1000 ms of scheduled retry sleeps. WMI calls can exceed that sleep budget; this is not a hard wall-clock deadline. The existing 30000 ms owned-worker drain budget remains.

## Scope of the guarantee

Process enumeration remains time-dependent. The sealed launch registry closes this coordinator's native launch routes and checks retained returned-process statuses. It is not a Windows Job Object and does not claim general descendant containment. The full original worker guard is still applied to every surviving original row after the existing follower/host filters. A foreign process created after the initial snapshot is subject to the ordinary time-of-observation limit of process enumeration; this change does not establish its safety or workspace.

No native Windows, Lean, Lake, C#, Wine, or CI execution was performed during implementation. Node was used only to check JScript-compatible JavaScript syntax. Runtime mock results are owned by the separate regression reviewer.
