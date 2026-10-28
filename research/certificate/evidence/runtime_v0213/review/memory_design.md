# Bounded adaptive memory admission review

## Recommendation

The proposed fallback is a reasonable narrow repair for the reported idle-worker failure: retain the normal reserve policy, but permit **one** Lean task against a fresh known snapshot when the optional warmer is absent or confirmed exited and the free memory covers the unchanged worker estimate plus a 1,024 MiB fallback host reserve. With the default 4,096 MiB worker estimate, the threshold is **5,120 MiB**. The reported 5,479 MiB would pass, leaving an estimated 1,383 MiB, including 359 MiB above the fallback reserve.

This is an admission estimate, not a process memory limit or a guarantee against allocation failure. No native code or proof was executed during this review. No runner, helper, launcher, or Lean source was edited.

The implementation owner accepted the bounded choices below: keep the preferred reserve separate; preserve an explicit host-reserve request as the fallback floor, otherwise use 1,024 MiB; allow a warmer-only stop/wait of at most five seconds; require confirmed exit/absence and a fresh known snapshot; remain serial for the rest of the invocation; leave active-worker accounting unchanged; and guard needed final-audit launches after the accepted-reuse fast path.

## Evidence and exact scope

Reviewed runner:

`output/RH_HILBERT_LIMIT_LEAN_v0_2_12_construction/tools/native_runner.js`

SHA256: `b11c97c591c5e200978fcfff5f37d6f6cd4b9388a464697a673174ab20c5a632`.

Reviewed user-supplied excerpt:

`upload/Pasted text(20261027-200359).txt`

SHA256: `fe90ee4f2db2f779539b422cd6884ed16482dc860a3b9048c447885785faa541`.

The excerpt records `PARALLEL_PROGRESS=85/89|ACTIVE=0|READY=2|LEAN_THREADS=0` and `PARALLEL_RESOURCE_BLOCKED: FREE_MB=5479|REQUIRED_MB=10476|LIVE_WORKERS=0` at lines 244–248. Its visible tail contains no new Lean-launch marker. It omits initialization, so it does not separately establish total RAM, the configured reserve, or whether a warmer had started. Assuming the default worker estimate, 10,476−4,096=6,380 MiB is the combined reserve/warmer allowance; attributing all 6,380 to the 20% reserve is an inference.

In the reviewed source:

- `configureParallelRuntime`, lines 1307–1330, chooses the preferred reserve as the larger of the configured reserve and 20% of total visible RAM, but clamps the selected worker count to at least one even when no worker fits that reserve.
- `parallelMemoryAllowsLaunch`, lines 1459–1475, compares free RAM against the preferred reserve, a live/unknown warmer allowance, and `(live+1) × workerMemoryMB`. Its refusal at the logged values follows that policy.
- `processModulesParallel`, lines 1586–1607, invokes optional warming before its admission loop and converts a no-active-worker denial into a bounded resource error.
- `parallelShutdown`, lines 1535–1569, permanently sets shutdown bookkeeping. It must not be reused to stop only the warmer halfway through a run.
- `finalAudit` calls `processModule` at lines 1831–1834; actual serial compile/audit launches in `processModuleBody` currently bypass the parallel admission function.

## Smallest practical changes

1. Keep the preferred reserve in its own field. Record the effective admission policy/reserve separately. Do not overwrite the worker estimate or the preferred reserve globally with a fallback value.
2. When initialization already shows that one normal worker cannot fit, select one worker and a zero warming cap. Do not fail merely during configuration: a completely cached run can still finish without any Lean launch.
3. On an actual launch denial with no active Lean task, disable future warming attempts. If the warmer exists, send its tokenized stop request, wait at most five seconds, and confirm process exit. Preserve its process/status record for final reporting and ownership checks. A live or unknown warmer must not be treated as released.
4. Force `parallelMemorySnapshot(true)` after any release, then retry normal admission. If that still fails, allow the serial fallback only when the refreshed snapshot is valid and covers `fallbackReserveMB + workerMemoryMB`. At defaults this is 5,120 MiB. Below it, retain the bounded resource failure.
5. Keep the current invocation serial once degraded; this avoids oscillating worker/thread reservations and warmer restarts. The preferred policy remains available for a later normal admission check or next invocation. A second job cannot slip into the same launch loop after the fallback grants the first.
6. If the implementation claims that every actual Lean launch follows the floor, apply the same serial admission to a needed final audit compile/re-audit. Place it after successful frozen reuse has had the opportunity to return, so no memory denial is introduced for a cache-only final audit.

Preserve explicitly configured resource minima. In particular, an explicit `RH_SYSTEM_RESERVE_MB` is documented as a requested host reserve; absent an explicit opt-in to relax it, use at least that value in fallback. Likewise use the configured `RH_WORKER_MEMORY_MB` unchanged. The 5,120 MiB threshold is the default-policy case, not a hardcoded replacement for custom settings.

## Accounting and lifecycle pitfalls

**Do not erase a live reservation.** Setting `ramCapMB=0` before the warmer actually exits makes the existing admission expression stop reserving that live helper. Use a separate disabled-for-future-starts flag, or retain its original allocation record, until exit is confirmed.

**Do not use the whole-run shutdown function midrun.** It sets `shutdownComplete` and `shutdownClean`, which could cause final draining and inventory checks to return early. A warmer-only stop must leave those fields and the workspace lock untouched.

**Do not credit supposedly released bytes.** Unmapping need not increase free RAM by the published `HELD_BYTES`, and an old READY status does not prove current residency. Query again; never add a mapped-byte count to the prior free-memory snapshot.

**Preserve conservative live-worker accounting in this patch.** The free-memory snapshot already reflects resident process use, while the current formula also reserves a full estimate for every live worker and the warmer. That can conservatively count some consumption twice. It also covers future growth and workers launched since the bounded-age snapshot. Removing those reservations without tracking unreflected commitments would be a separate policy redesign; it is unnecessary to fix the idle failure.

**Do not convert known-low memory into an unknown-memory permission.** If the forced refresh for a known-pressure fallback fails, decline that fallback. The existing initial unknown-memory serial policy should not accidentally override a known-pressure decision.

**Keep compile-to-audit reservations.** A logical task retains its resource allowance across the compile-to-audit transition. The transition must not be treated as a new unrelated free slot while other tasks are live.

**Keep logs honest.** Record preferred reserve, effective fallback reserve, worker estimate, warming reservation, refreshed free/total memory, live count, threshold, and reason. Label the policy as an estimate. Do not claim that 4 GiB is enforced as a Lean process limit or that 1 GiB is a measured sufficient host reserve.

Suggested concise event:

`MEMORY_ADMISSION=ADAPTIVE_SERIAL|FREE_MB=5479|PREFERRED_RESERVE_MB=6380|EFFECTIVE_RESERVE_MB=1024|WORKER_ESTIMATE_MB=4096|WARM_RESERVE_MB=0|REQUIRED_MB=5120|LIVE_WORKERS=0`

The preferred-reserve value above is illustrative; log the value actually configured and observed.

## Focused checks for the implementation owner

These are proposed mocked-host scenarios, **not executed tests**:

| Scenario | Expected result |
|---|---|
| Fresh free 5,479 MiB, defaults, no live task/warmer | One serial task admitted; warming stays disabled |
| Fresh free 5,120 MiB | Boundary admission |
| Fresh free 5,119 MiB | Bounded resource failure; no Lean launch |
| One active task | No serial fallback and no lowering of live-task reservations |
| Warmer stops and fresh free becomes 5,479 MiB | Admit only after confirmed exit and refreshed snapshot |
| Warmer stays live or status is unknown | No released-memory credit; bounded failure; preserve ownership/lock checks |
| Cached snapshot high, forced refresh below 5,120 MiB | Reject using the fresh value |
| Forced refresh fails after known pressure | Reject the adaptive fallback |
| Worker estimate explicitly 8,192 MiB | Require at least 9,216 MiB with the default fallback host floor |
| Host reserve explicitly 4,096 MiB | Preserve that request; default worker needs at least 8,192 MiB |
| Every module/final audit is reusable, low free RAM | No unnecessary memory error and no Lean launch |
| Final audit needs a launch after prior tasks finish | Same serial floor applied if all-launch admission is claimed |

## Primary source context

Microsoft documents `Win32_OperatingSystem.FreePhysicalMemory` as currently unused and available physical memory, in kilobytes: <https://learn.microsoft.com/en-us/windows/win32/cimwin32prov/win32-operatingsystem#properties>. The runner divides these values by 1,024 and floors them, so its `MB` fields are binary MiB.

Microsoft explicitly describes `GlobalMemoryStatusEx` results as volatile: <https://learn.microsoft.com/en-us/windows/win32/api/sysinfoapi/nf-sysinfoapi-globalmemorystatusex>. A current snapshot is evidence for admission, not a reservation of physical pages. No documentation establishes the proposed 4 GiB worker estimate or 1 GiB fallback reserve as a measured requirement for these proofs.
