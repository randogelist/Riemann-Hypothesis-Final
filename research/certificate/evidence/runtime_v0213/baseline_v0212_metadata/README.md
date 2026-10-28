# RH Hilbert-limit construction — v0.2.12

**This is a runtime-only revision of v0.2.11. All 92 Lean files, the selected final audit, and its 370 declaration targets are preserved byte for byte.** The native Windows build of the five analytic proof candidates is still pending. This revision does not establish a new mathematical result or finite-checker equivalence.

The runner can compile independent modules concurrently and can keep read-only mappings of their already-compiled imports open in an optional RAM warmer. The existing persistent cache remains under `E:\RH-FAST`. The scheduler and warmer are new Windows runtime candidates; source review and mocked coordinator tests do not substitute for a native run.

## Run

Save this ZIP in Downloads and paste this one line into Windows CMD:

```bat
cd /d "%USERPROFILE%\Downloads" && (if not exist "E:\RH-FAST\workspaces" mkdir "E:\RH-FAST\workspaces") && tar -xf "RH_HILBERT_LIMIT_LEAN_v0_2_12_construction.zip" -C "E:\RH-FAST\workspaces" && cmd /k call "E:\RH-FAST\workspaces\RH_HILBERT_LIMIT_LEAN_v0_2_12_construction\run.cmd"
```

The existing native Windows Lean 4.33.0 compiler and cached Mathlib are required. The runner does not call Lake, Python, PowerShell, WSL, CI, or network installation. It uses the existing .NET Framework C# compiler if it needs to build either its existing SHA256 helper or the new, separately cached RAM helper. No such native compilation or execution was performed during package preparation.

Persistent locations are:

- Workspace: `E:\RH-FAST\workspaces\RH_HILBERT_LIMIT_LEAN_v0_2_12_construction`
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

The MB settings use binary MiB. Memory allowances are admission estimates, not measured peaks or hard allocation limits. Before each launch, the coordinator uses an available-RAM snapshot at most two seconds old and conservatively reserves allowances for live workers plus the live warmer, including recent launches whose allocations may not yet appear in that snapshot. If memory information is unavailable, it admits only one Lean task at a time and disables warming at initial configuration. A valid low-memory reading with no running Lean task produces a clear `PARALLEL_RESOURCE_BLOCKED` failure instead of silently overcommitting or waiting forever.

When more than one module worker is configured, one of the 16 default Lean thread tokens is held back for coordinator/hash work. The remaining 15 are divided across admitted Lean tasks. Three initially ready jobs receive five each; a single ordinary job in that parallel configuration receives 15. If configuration falls back to one worker, it can use all 16. The final aggregate runs alone with the original 16-thread setting. This is a Lean thread-allocation budget, not a limit on all operating-system threads or processes.

For a comparison run, `RH_RAM_WARM=OFF` keeps parallel compilation enabled. Setting both `RH_RAM_WARM=OFF` and `RH_MODULE_WORKERS=1` gives serial ordinary-module admission through the new coordinator. It does not restore an older runner version or bypass any validation.

## Diagnostics and shutdown

`run-parallel-plan.json` records local dependencies, priority depth, resource settings, and the final barrier. `run-ram-plan.tsv` records the selected import files and shared-ready-job counts when warming is attempted. The existing `run-result.json`, `run-build.log`, and `run-audit.log` retain build and audit outcomes and now include parallel/RAM diagnostics. Module timings include queueing, compilation, audit, and acceptance where applicable; they are not isolated compiler CPU times.

Read `PARALLEL_PEAK_MODULE_WORKERS`, `PARALLEL_WORKER`, `RAM_WARM_STATE`, and the recorded module/stage timings to see what actually ran. Native measurements are needed to choose better per-worker memory estimates or prove a speedup.

At exit the coordinator drains owned workers for up to 30 seconds and checks the existing process-inventory guard. If a relevant worker is still live or cannot be excluded, it retains the package lock. It never kills Lean workers merely to clear that lock. Existing stale-lock recovery can act only after the ownership and worker checks permit it. A read-only follower is recognized narrowly so observing progress does not itself become a compile worker.

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

remains open. No accepted witness and no unconditional proof of RH is asserted. Native compilation and the exact axiom audit remain pending for the five analytic candidates and their aggregate. Even a successful native run continues to report `FINITE_CHECKER_EQUIVALENCE=OPEN`, `FORMAL_CLOSURE=OPEN`, and `UNCONDITIONAL_RH=NOT_ESTABLISHED`.

## Verification evidence

The package contains the exact runtime diff, frozen-input hashes, dependency analysis, primary-source references, source reviews, and bounded Node mock tests. The mocks exercise scheduling, audit barriers, failure propagation, budgets, RAM selection/status handling, and shutdown decisions. They do not execute COM, WMI, native Windows process control, C#, or Lean.

All prior mathematical sources and evidence remain intact. `OPEN_OBLIGATIONS.txt` and declaration history retain their v0.2.11 wording because this revision changes runtime only. Earlier package metadata is archived under `evidence/runtime_v0212/baseline_v0211_metadata`; current status is in the top-level `STATUS.json`.

The latest user-supplied native PASS remains the v0.2.10 warm-run excerpt. It does not certify the v0.2.11 proof candidates or this new coordinator and warmer. No native object, successful compiler receipt, or new native PASS is manufactured in this archive.
