# RH Hilbert Limit v0.2.17 — exact-process shutdown repair

Mode **A_TIER_LEAN**; target **LOCAL_COMPILER**; native Windows Lean **4.33.0**.

This package repairs the shutdown check following the latest reported v0.2.16 failure. All **92 Lean sources**, **370 selected audit targets**, theorem definitions and hypotheses, declaration inventory, native helpers and launcher are preserved. The changed JavaScript runner is **prepared for the user's native run**; its static and synthetic checks do not establish a Windows or Lean PASS.

## Run

Download the ZIP to Downloads and run this in Windows CMD:

```cmd
cd /d "%USERPROFILE%\Downloads" && (if not exist "E:\RH-FAST\workspaces" mkdir "E:\RH-FAST\workspaces") && tar -xf "RH_HILBERT_LIMIT_LEAN_v0_2_17_construction.zip" -C "E:\RH-FAST\workspaces" && cmd /k call "E:\RH-FAST\workspaces\RH_HILBERT_LIMIT_LEAN_v0_2_17_construction\run.cmd"
```

The new workspace is `E:\RH-FAST\workspaces\RH_HILBERT_LIMIT_LEAN_v0_2_17_construction`. The existing v0.2.16 workspace and its retained lock remain untouched. The new runner uses the same shared `E:\RH-FAST\anchors` cache, subject to all existing source, dependency, toolchain, artifact and audit checks. It may restore the 90 valid active module artifacts into the new workspace; later runs in that same workspace can retain validated working files. A package version change does not by itself require proof recompilation.

The command leaves CMD open. Native execution uses the already installed compatible compiler and cached Mathlib. The runner does not use Lake setup, Python, PowerShell, WSL or network setup.

## What the latest log establishes

The visible clipped progress line ends at 89/89 with no active worker, and the full lines report zero new or reaudited tasks. `AnalyticAudit` is explicitly retained and frozen-reused with 370 declarations. Shutdown then observes six different unreadable `certutil.exe` process rows, all bearing numeric parent 34008, and reports `PROJECT_BUILD=FAIL`, `FAILED_STAGE=WORKER_SHUTDOWN`, `RUN=FAIL`.

The supplied tail does not include a final overall axiom-PASS summary or aggregate compiled/reused module counts. It establishes retention of the final audit artifact, not retention of all 90 artifacts. The previous v0.2.16 successful run remains separately recorded evidence for all 90 reused modules and the standard-axiom audit with no `sorryAx`. No mathematical result is promoted from this failed run.

Source inspection and a focused synthetic reproduction show that shutdown logging and lock metadata reads do not themselves launch `certutil`. The changing rows are consistent with another process's continuing hashing, but their unreadable commands do not identify a foreign workspace or prove that the workers have exited.

## The repair

1. **Close the runner's own launch set.** Every direct native launch is recorded before it starts. Shutdown seals that set and checks the retained process handles or completed synchronous waits. A live, uncertain or incompletely recorded owned launch prevents lock release.
2. **Keep one complete shutdown inventory.** Each unreadable relevant row is rechecked by a targeted process query. A row is retired only after a successfully completed query returns no process. A readable row with the same PID, full creation identity, name and parent goes through the existing workspace guard.
3. **Preserve uncertainty.** A still-unreadable worker, changed identity, reused PID, inconsistent response or query failure retains the lock. A preexisting parent's admission grants no exemption to its children. Exact lock-owner and self-process checks surround the revalidation.

The retries now resolve the identities that actually caused uncertainty, instead of repeatedly replacing the entire inventory and encountering another hash process. Rechecks are bounded. This remains a process-observation protocol under the workspace lock; it is not an atomic operating-system snapshot. Existing acquisition, stale-lock recovery, permanent quarantine and release rules are preserved.

The PID/creation and query-result handling follows Microsoft's [Win32_Process documentation](https://learn.microsoft.com/en-us/windows/win32/cimwin32prov/win32-process) and [SWbemServices.ExecQuery documentation](https://learn.microsoft.com/en-us/windows/win32/wmisdk/swbemservices-execquery). Source links and the precise design inference are recorded in the evidence directory.

## Exact analytic endpoint retained

The selected `AnalyticAudit.lean` has 370 unique axiom-print targets. Its source covers the actual canonical calibration, dominant extraction, and the following unchanged endpoints:

```lean
Tendsto (rootScale actualVariation) atTop (𝓝 (spectralRadius canonicalNode))
```

```lean
Tendsto (rootScale actualVariation) atTop (𝓝 1) ↔ _root_.RiemannHypothesis
```

```lean
(∃ B : ℕ, ∀ n : ℕ, actualVariation n ≤ (B : ℝ)) ↔ _root_.RiemannHypothesis
```

Other retained equivalences use subexponential variation, all variation values equal to one, nonnegative weights, and a natural growth-step parameter. `CHECKPOINT.json` records all ten exact declarations from `AnalyticClosure.lean`, and the evidence review verifies their expected audit-source coverage. These are the analytic statements in the user-reported successful package. The limit's existence alone does not prove that its value is one or establish RH, and it does not assert convergence of the unrooted variation sequence.

## Remaining formal-closure goal

```lean
(∃ W : FiniteWitness, check W = true) ↔ _root_.RiemannHypothesis
```

This separate finite raw terminating-checker equivalence remains OPEN. Its proof requires the finite data format, terminating checker, soundness for actual RH and completeness under RH. An obtained witness would not be required to prove the equivalence. The current natural-bound and growth-step criteria still quantify over all orders, so they do not themselves supply such a terminating check. No accepted finite witness or unconditional RH proof is asserted.

## Runtime and cache settings retained

| Setting | Default behavior |
|---|---|
| `LEAN_JOBS` | 16 total Lean threads |
| `RH_MODULE_WORKERS` | Up to 4 dependency-ready module workers |
| `RH_WORKER_MEMORY_MB` | 4,096 MiB admission allowance per worker |
| Preferred system reserve | Maximum of 4,096 MiB and 20% of physical RAM |
| Idle serial reserve | 1,024 MiB, or explicit `RH_SYSTEM_RESERVE_MB` as the minimum |
| Default serial threshold | 5,120 MiB with a fresh valid memory reading |
| `RH_RAM_WARM` | AUTO; requires at least two eligible dirty ordinary modules |
| `RH_RAM_WARM_MB` | 8,192 MiB upper limit, adjusted against available memory |
| Proof cache | Content/dependency/toolchain/artifact/audit verification before reuse |

The existing idle fallback stops optional warming, confirms its exit, and refreshes memory before admitting one worker. It preserves explicit host and worker allowances. That invocation remains serial with warming disabled. When more than one worker is configured, one thread is reserved from the 16-thread total; a serial worker may use all 16. The final aggregate remains behind the ordinary-module completion barrier and its launch memory check. Accepted frozen final reuse does not need a new compiler launch.

The warmer maps eligible compiled import files read-only and requests no guaranteed resident allocation. Memory allowances are estimates, not hard allocation limits. These policies are unchanged from v0.2.13; this revision does not claim a measured speedup.

## Evidence and validation

`STATUS.json` separates the latest failed run, the earlier successful proof-audit evidence, and the unexecuted native repair. `CHECKPOINT.json` preserves all ten exact endpoint types. `DECLARATIONS.json` is byte-identical to the previous delivery. Formal closure and the finite raw terminating-checker equivalence remain **OPEN**.

`evidence/shutdown_fix_v0217` contains the exact clipped-log transcription, a bounded review, the runner change review, targeted Node VM tests and the archived baseline metadata. Test processes, files and WMI replies are simulated. No Lean, Lake, Windows/WSH/WMI execution, C# compilation, Wine or CI was performed during preparation. The tests cover the new shutdown behavior and failure boundaries; historical test records retain their original source bindings.

`RUNNER_LOGIC_VALIDATION.json` and `STATIC_REVIEW.json` state the exact checked scope. Prior evidence and all mathematical source bytes are preserved. `SHA256SUMS.txt` covers all other payload files. The ZIP contains no fabricated compiled artifacts or native receipts.
