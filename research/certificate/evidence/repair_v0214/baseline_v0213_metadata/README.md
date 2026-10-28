# RH Hilbert-limit construction — v0.2.13

**This is a runtime-only repair of v0.2.12. All 92 Lean files, the selected final audit, and its 370 declaration targets are preserved byte for byte.** Native verification of the complete analytic endpoint is still pending. This revision does not establish a new mathematical result or finite-checker equivalence.

The runner can compile independent modules concurrently and can keep read-only mappings of their already-compiled imports open in an optional RAM warmer. The existing persistent cache remains under `E:\RH-FAST`. The scheduler and warmer are new Windows runtime candidates; source review and mocked coordinator tests do not substitute for a native run.

## Repair for the uploaded v0.2.12 run

The supplied tail ends with `PARALLEL_RESOURCE_BLOCKED`: 5,479 MiB available, 10,476 MiB required, and zero active Lean workers. It then retains the workspace lock because a relative-path `native_runner.js` process cannot be assigned to a package. The excerpt contains no Lean compiler error. `SpectralGenerating` immediately precedes the failure with `FROZEN_REUSE`; its name was the last module context, not evidence of an elaboration failure.

This revision changes three runtime decisions:

- If the preferred memory reserve prevents any job from starting, the idle coordinator stops optional RAM warming, confirms its exit, and obtains a fresh memory reading. With default settings it may then admit one compiler with the unchanged 4,096 MiB worker estimate plus a 1,024 MiB host floor. At the reported 5,479 MiB, that 5,120 MiB threshold fits. The invocation remains serial with warming disabled. This is an admission estimate, not a guaranteed memory limit or successful compilation.
- An explicitly set `RH_SYSTEM_RESERVE_MB` remains the minimum host floor, and `RH_WORKER_MEMORY_MB` is never silently reduced. A low or unknown refreshed reading, or uncertain warmer exit, still blocks admission. Dirty final-aggregate compilation/re-audit uses the same serial gate; accepted frozen final reuse needs no launch memory.
- Fresh lock acquisition records exact identities of readable unresolved relative runner hosts that the existing acquisition policy already admits. Shutdown can recognize that same unchanged PID, full creation identity, and command for the same owner. New, changed, unreadable, or absolute-current-workspace-bound processes remain guarded. Stale and legacy recovery rules are unchanged; this exception does not establish the other runner's working directory.

The extraction command uses a new v0.2.13 workspace. It does not delete or forcibly recover the retained v0.2.12 lock. Shared proof anchors remain reusable under their original checks. Further resource failures are reported under `RESOURCE_ADMISSION`, so the last successfully restored module is no longer blamed by the stage label.

The original uploaded bytes and a bounded evidence review are in `evidence/runtime_v0213/native_tail`. Exactly 41 distinct frozen-reuse records and 40 restored-artifact markers are visible in that partial tail. Its `85/89` progress counter is a terminal-state count, not a complete successful-reuse report. The newly reported `SpectralGenerating` receipt has not been independently inspected; no mathematical endpoint is promoted from that line. The whole reported run is `FAIL` and the final aggregate output is absent.

## Run

Save this ZIP in Downloads and paste this one line into Windows CMD:

```bat
cd /d "%USERPROFILE%\Downloads" && (if not exist "E:\RH-FAST\workspaces" mkdir "E:\RH-FAST\workspaces") && tar -xf "RH_HILBERT_LIMIT_LEAN_v0_2_13_construction.zip" -C "E:\RH-FAST\workspaces" && cmd /k call "E:\RH-FAST\workspaces\RH_HILBERT_LIMIT_LEAN_v0_2_13_construction\run.cmd"
```

The existing native Windows Lean 4.33.0 compiler and cached Mathlib are required. The runner does not call Lake, Python, PowerShell, WSL, CI, or network installation. It uses the existing .NET Framework C# compiler if it needs to build either its existing SHA256 helper or the new, separately cached RAM helper. No such native compilation or execution was performed during package preparation.

Persistent locations are:

- Workspace: `E:\RH-FAST\workspaces\RH_HILBERT_LIMIT_LEAN_v0_2_13_construction`
- Shared anchors: `E:\RH-FAST\anchors\RH_HILBERT_LIMIT\LOCAL_COMPILER\lean-4.33.0`

The new versioned workspace can restore unchanged objects from shared validated anchors. It may need to copy those objects once before later runs retain the working files in place. Reuse still requires the original source, dependency, compiler, artifact, and same-target audit checks.

## Which modules can run together?

The scheduler builds its dependency plan from the existing imports. Once dependencies are accepted, a module becomes ready. A compiler exit alone does not release its dependents: its declaration audit and anchor acceptance must also complete. One coordinator owns all receipt commits, counters, shared logs, and readiness changes.

If the 84 older ordinary modules are successfully reused, the new work has this structure:

| Ready group | Modules | Release condition |
| --- | --- | --- |
| First independent group | `CanonicalPowerSums`, `SpectralPhase`, `SpectralGenerating` | Their existing imports are accepted |
| Spectral extraction | `SpectralExtraction` | Both `SpectralPhase` and `SpectralGenerating` are accepted |
| Endpoint | `AnalyticClosure` | `CanonicalPowerSums` and `SpectralExtraction` are accepted |
| Final barrier | `AnalyticAudit` | All ordinary modules finish successfully |

All names in the first three rows have prefix `RH_HilbertLimit.`. `CanonicalPowerSums` may continue while spectral extraction runs if their dependencies and the resource budget allow it.

The full source graph has 89 ordinary modules plus the final aggregate, 158 direct local import edges, and a 27-module critical chain under an equal-cost model. Its largest earliest-start layer has 12 modules. The maximum antichain has 22 modules; that does not imply 22 jobs are ready at the beginning. In the equal-cost simulation, four workers reach the 27-unit lower bound. These are graph calculations, not timings or a predicted speedup. The graph report and analysis are in `evidence/runtime_v0212/graph`.

Among ready modules, the runner prioritizes the longest remaining dependency chain. Each module writes to its own output and compile/audit logs. A normal compile or audit failure blocks descendants while independent modules continue. Fatal infrastructure errors stop further admission and enter bounded worker shutdown.

## RAM warming

Before an eligible group starts, the runner ranks its transitive compiled imports by how many ready jobs use them. Already accepted local imports have first priority, followed by external compiled imports from the existing fingerprinted dependency graph. It selects up to 4,096 files within the configured byte budget and writes the exact selection to `run-ram-plan.tsv`.

The optional x64 helper opens those files read-only, maps them, touches one byte per page, and holds the mappings during the build. Files scheduled for compilation or audit are excluded. Mapping an output that is about to change could interfere with replacement or truncation, so only local imports in the accepted `DONE` state are eligible. The helper neither hashes proof artifacts nor authorizes reuse; the original verifier continues to do that work.

Windows controls residency. It may trim mapped pages, and each Lean process still constructs its own environment. Lean 4.33's source has a Windows copy-on-write mapping path and a read/allocation fallback, so warming these files is a plausible experiment; it does not prove the user's compiler takes that path or that a build becomes faster. See the pinned [Lean module loader](https://github.com/leanprover/lean4/blob/v4.33.0/src/library/module.cpp), Microsoft's [file mapping documentation](https://learn.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-mapviewoffile), and [working-set documentation](https://learn.microsoft.com/en-us/windows/win32/memory/working-set). Full reference metadata is included with the runtime evidence.

The helper uses no RAM disk, privileged page locking, environment snapshot, or copy of Mathlib. Its budget is capped again against available physical RAM at startup. The coordinator waits at most five seconds for initial readiness, then allows compilation while warming continues. At shutdown it requests a token-matched stop. The helper also observes its exact parent-process identity and has a six-hour self-exit watchdog. Blocking Windows I/O can delay cooperative stopping; a hard watchdog exit may leave the last status snapshot stale.

Fresh content hashing already reads dependency bytes and may have warmed the operating-system cache. Extra mapping may therefore add overhead or memory pressure. Compare actual native runs before increasing its cap. A fully reused run skips the RAM helper because there is no dirty ordinary-module group to warm.

## Defaults and controls

Set these environment variables in the same CMD session before calling `run.cmd` if you want to override the defaults. No override is required for the command above.

| Variable | Default | Meaning |
| --- | --- | --- |
| `LEAN_JOBS` | `16` | Total launch-time Lean thread budget; existing range 1–64 |
| `RH_MODULE_WORKERS` | `4` | Maximum concurrent ordinary-module tasks; range 1–16, also limited by threads and RAM |
| `RH_WORKER_MEMORY_MB` | `4096` | Estimated memory allowance per live Lean task; range 512–131072 |
| `RH_SYSTEM_RESERVE_MB` | `4096` | Requested host reserve; effective reserve is at least 20% of physical RAM |
| `RH_RAM_WARM` | `AUTO` | `AUTO` requires at least two ready dirty modules; `ON` also allows one; `OFF` disables warming |
| `RH_RAM_WARM_MB` | `8192` | Maximum warmer budget; range 0–65536, reduced against available RAM |

The MB settings use binary MiB. Memory allowances are admission estimates, not measured peaks or hard allocation limits. Normal admission uses an available-RAM snapshot at most two seconds old and conservatively reserves allowances for live workers plus the live warmer, including recent allocations not yet reflected in that snapshot. Initial unknown-memory configuration falls back to one task and no warming. After known memory pressure, a failed refresh does not become permission to launch.

The preferred host reserve remains max(4,096 MiB, 20% of physical RAM) at default settings. If no Lean task is active and that policy denies the next job, the coordinator can degrade this invocation to serial. It waits up to five seconds for an optional warmer to exit, preserves its process record for final shutdown, and forces a fresh memory reading. The serial host floor is 1,024 MiB by default, or the explicit `RH_SYSTEM_RESERVE_MB` value if set. Free memory must cover that floor plus the unchanged worker estimate. At defaults, 5,120 MiB qualifies and 5,119 MiB does not. Below the threshold or with uncertain helper exit/refresh, the runner fails promptly. It does not add mapped bytes to an old memory reading or kill a worker to obtain space.

After degradation, `PARALLEL_MEMORY_FALLBACK=SERIAL_UNTIL_EXIT` and `SYSTEM_MEMORY_RESERVE_EFFECTIVE_MB` identify the actual policy. The final result records preferred/effective reserves and `memory_serial_fallback`. The initial `run-parallel-plan.json` describes the starting upper limits; the result and later fallback markers describe any downward adjustment. No automatic promotion back to parallel mode occurs during that invocation.

When more than one module worker is configured, one of the 16 default Lean thread tokens is held back for coordinator/hash work. The remaining 15 are divided across admitted Lean tasks. Three initially ready jobs receive five each; a single ordinary job in that parallel configuration receives 15. If configuration falls back to one worker, it can use all 16. The final aggregate runs alone with the original 16-thread setting. This is a Lean thread-allocation budget, not a limit on all operating-system threads or processes.

For a comparison run, `RH_RAM_WARM=OFF` keeps parallel compilation enabled. Setting both `RH_RAM_WARM=OFF` and `RH_MODULE_WORKERS=1` gives serial ordinary-module admission through the new coordinator. It does not restore an older runner version or bypass any validation.

## Diagnostics and shutdown

`run-parallel-plan.json` records local dependencies, priority depth, resource settings, and the final barrier. `run-ram-plan.tsv` records the selected import files and shared-ready-job counts when warming is attempted. The existing `run-result.json`, `run-build.log`, and `run-audit.log` retain build and audit outcomes and now include parallel/RAM diagnostics. Module timings include queueing, compilation, audit, and acceptance where applicable; they are not isolated compiler CPU times.

Read `PARALLEL_PEAK_MODULE_WORKERS`, `PARALLEL_WORKER`, `RAM_WARM_STATE`, and the recorded module/stage timings to see what actually ran. Native measurements are needed to choose better per-worker memory estimates or prove a speedup.

At exit the coordinator drains owned workers for up to 30 seconds and checks the existing process-inventory guard. If a relevant worker is still live or cannot be excluded, it retains the package lock. It never kills Lean workers merely to clear that lock. Existing stale-lock recovery can act only after the ownership and worker checks permit it. A read-only follower is recognized narrowly so observing progress does not itself become a compile worker.

For a newly acquired lock only, an unchanged unresolved relative runner that was already admitted at acquisition does not become a new global veto merely because the coordinator is now shutting down. This exception binds the same owner and exact PID, creation identity, and command; it applies only to that script host, never to its descendants or native workers. Absolute current-workspace references take precedence. No such exception is reconstructed when recovering an existing stale/legacy lock. The original owner verification, quarantine records, and release check remain in force.

The original compact anchor layout, semantic compile flags, axiom policy, artifact validation, and anchor-acceptance functions are preserved. Thread counts were already classified as nonsemantic. Runtime provenance changes while eligible proof-cache identities remain the same. Small-file CertUtil hashing and the content-fingerprint algorithm are not replaced in this revision. Consequently, the old 37,781 ms aggregate hash-phase report is not a speedup claim for this package and is not whole-run time.

## Preserved mathematical endpoint

The v0.2.11 source candidates attempt to construct all-order canonical power sums and dominant extraction for the actual theta/xi construction. The exact ordinary-limit statement remains:

```lean
Tendsto (rootScale actualVariation) atTop (𝓝 (spectralRadius canonicalNode))
```

`rootScale V n` is `Real.rpow (V n) ((n : ℝ)⁻¹)`. The endpoint concerns the rooted variation sequence; it does not assert convergence of the unrooted variation or that the spectral radius is one. Another preserved candidate is:

```lean
Tendsto (rootScale actualVariation) atTop (𝓝 1) ↔ _root_.RiemannHypothesis
```

The preserved leaf also states five other RH criteria, including a natural uniform bound:

```lean
(∃ B : ℕ, ∀ n : ℕ, actualVariation n ≤ (B : ℝ)) ↔ _root_.RiemannHypothesis
```

Its all-order condition is still not a terminating finite check of a raw witness. The requested formal closure,

```lean
(∃ W : FiniteWitness, check W = true) ↔ _root_.RiemannHypothesis
```

remains open. No accepted witness and no unconditional proof of RH is asserted. Native compilation and the exact aggregate axiom audit remain pending for the complete analytic endpoint. Even a successful native run continues to report `FINITE_CHECKER_EQUIVALENCE=OPEN`, `FORMAL_CLOSURE=OPEN`, and `UNCONDITIONAL_RH=NOT_ESTABLISHED`.

## Verification evidence

The package retains the v0.2.12 dependency analysis and its 22 historical mocked scenarios. New source reviews, the exact repair diff, uploaded native tail, frozen-input hashes, and focused repair regressions are in `evidence/runtime_v0213`. The mocks exercise scheduling, audit barriers, failure propagation, budgets, RAM selection/status handling, and shutdown decisions. They do not execute COM, WMI, native Windows process control, C#, or Lean.

All prior mathematical sources and evidence remain intact. `OPEN_OBLIGATIONS.txt` and declaration history retain their v0.2.11 wording because this revision changes runtime only. The immediate parent metadata is archived under `evidence/runtime_v0213/baseline_v0212_metadata`; current status is in the top-level `STATUS.json`. Older evidence remains historical and retains its original source bindings.

The latest user-supplied native PASS remains the v0.2.10 warm-run excerpt. It does not certify the v0.2.11 proof candidates or this new coordinator and warmer. No native object, successful compiler receipt, or new native PASS is manufactured in this archive.
