# RH Hilbert Limit v0.2.16 — cached reuse record

Mode **A_TIER_LEAN**; target **LOCAL_COMPILER**; native Windows Lean **4.33.0**.

The supplied v0.2.16 run reports **PASS**, **0 modules compiled**, **90 frozen modules reused**, and a selected `AnalyticAudit.lean` summary covering **370 declarations**, with standard logical axioms only and no `sorryAx`. The finite-checker equivalence and formal closure remain **OPEN**.

This delivery records that result and preserves all **92 Lean source files**, every runner/helper/launcher byte, package identity, audit targets and execution settings. The external ZIP filename distinguishes this evidence update; its internal root and Windows workspace remain `RH_HILBERT_LIMIT_LEAN_v0_2_16_construction`.

## Run in the same workspace

Save this ZIP to Downloads and run in Windows CMD:

```cmd
cd /d "%USERPROFILE%\Downloads" && (if not exist "E:\RH-FAST\workspaces" mkdir "E:\RH-FAST\workspaces") && tar -xf "RH_HILBERT_LIMIT_LEAN_v0_2_16_REUSE_RECORD_construction.zip" -C "E:\RH-FAST\workspaces" && cmd /k call "E:\RH-FAST\workspaces\RH_HILBERT_LIMIT_LEAN_v0_2_16_construction\run.cmd"
```

The command updates the existing v0.2.16 workspace and leaves its CMD window open. The ZIP contains source and metadata, without compiled artifacts or working cache files. Extraction therefore preserves the workspace's existing `.native-build` files. The unchanged runner can retain those artifacts when its source, dependency, toolchain, artifact and audit checks pass. Shared anchors remain under `E:\RH-FAST\anchors`. No cache check or lock policy is weakened.

The supplied run restored 90 artifact files and retained zero working modules. Keeping the same workspace allows future reuse of the working files; the next run still validates them. Future counters or timing are not guaranteed. No new native execution was performed while preparing this delivery.

## Recorded evidence

| User-reported field | Value |
|---|---:|
| Compiled modules | 0 |
| Frozen reused modules | 90 |
| Selected audit declarations | 370 |
| Axiom audit | PASS_STANDARD_LOGICAL_AXIOMS_ONLY |
| sorryAx | NONE |
| Working artifact modules retained | 0 |
| Restored artifact files | 90 |
| Anchor history scans / compact anchors saved | 0 / 0 |
| Project build / run | PASS / PASS |
| Finite-checker equivalence / formal closure | OPEN / OPEN |

The transcript preserves the clipped first line exactly and records the supplied anchor receipt path. Receipt contents, individual declaration audit output and native dependency/toolchain fingerprints were not supplied. This is explicitly user-reported aggregate audit evidence. The locally verified source preservation is recorded separately.

The project-module stage was 53,350 ms; the aggregate hash-phase counter was 34,526 ms. Those counters are not total run duration and must not be added as disjoint elapsed times. RAM warming was skipped because there was no eligible dirty compilation frontier. The two logical Lean launches do not indicate that any module was newly compiled.

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

## Preservation and evidence files

`CHECKPOINT.json` retains all ten exact `AnalyticClosure.lean` endpoint statements and links the new reuse evidence. `STATUS.json` records the observed user-reported 0/90 result separately from assistant execution, which was not performed. `OPEN_OBLIGATIONS.txt` retains the finite-checker goal.

All older evidence is preserved. The previous top-level metadata is archived under `evidence/reuse_record_v0216/baseline_v0216_metadata`. The 67 analytic declaration inventory entries now reference the explicit aggregate reuse audit summary; their names, source locations and source hashes are unchanged. The remaining 1,038 inventory entries are unchanged.

Historical preparation comments in the Lean files remain byte-identical. Current reported status is recorded in metadata to preserve proof cache inputs. No new tests, Lean/Lake runs, native Windows execution, C# compilation, Wine or CI were performed. Static byte comparison and ZIP integrity checks validate this metadata-only delivery. `SHA256SUMS.txt` covers every other payload file.
