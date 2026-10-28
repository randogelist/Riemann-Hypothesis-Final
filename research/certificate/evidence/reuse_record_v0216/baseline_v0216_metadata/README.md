# RH Hilbert Limit v0.2.16 — reported-pass checkpoint

Mode **A_TIER_LEAN**; target **LOCAL_COMPILER**; native Windows Lean **4.33.0**.

The user reports `PROJECT_BUILD=PASS` and `RUN=PASS` for v0.2.15: **5 modules compiled and 85 reused**, with 5 compact anchors saved. This checkpoint preserves all **92 Lean files byte-for-byte**, all theorem statements and assumptions, and the complete functional runner. Only package identity and checkpoint/documentation metadata change. No Lean, Lake, Windows executable, C# compiler, Wine or CI was run during preparation.

## Run

Download the ZIP to Downloads and run this command in Windows CMD:

```cmd
cd /d "%USERPROFILE%\Downloads" && (if not exist "E:\RH-FAST\workspaces" mkdir "E:\RH-FAST\workspaces") && tar -xf "RH_HILBERT_LIMIT_LEAN_v0_2_16_construction.zip" -C "E:\RH-FAST\workspaces" && cmd /k call "E:\RH-FAST\workspaces\RH_HILBERT_LIMIT_LEAN_v0_2_16_construction\run.cmd"
```

The command leaves its window open. The workspace is under `E:\RH-FAST\workspaces`; the shared validated anchors stay under `E:\RH-FAST\anchors\RH_HILBERT_LIMIT\LOCAL_COMPILER\lean-4.33.0`. The existing native compiler and compatible cached Mathlib are used, without Lake setup, Python, PowerShell, WSL or network setup in the runner.

With all 90 active module anchors present and matching, the expected next run has **0 compiled and 90 reused modules**. This is an expectation, not an observed warm-run result. Missing or invalid source/dependency/toolchain/artifact/audit identities still cause rebuilding or failure. A new workspace may restore working artifacts from the shared anchors; the version change alone does not force proof recompilation.

## Recorded evidence

| User-reported field | Value |
|---|---:|
| Compiled modules | 5 |
| Frozen reused modules | 85 |
| Audit-only modules | 0 |
| Compact anchors saved | 5 |
| Restored artifact files | 85 |
| Working artifact modules retained | 0 |
| Project build | PASS |
| Run | PASS |
| Formal closure | OPEN |

The supplied tail is stored as a UTF-8/LF transcription, not as original log bytes. It omits direct per-declaration axiom output, native fingerprints and receipt contents. The reviewed runner prints PASS only after successful ordinary modules, its selected aggregate audit, and guarded worker shutdown. Therefore, **if the supplied run used the reviewed package unchanged**, its PASS markers entail those gates along that runner path. This is a source-based interpretation of the reported result; no receipt or native audit output has been independently reconstructed.

The reported hash-phase total is 51,231 ms. It is not the whole-run duration or an end-to-end speedup measurement. Counters alone do not identify the five compiled modules. The short tail also does not independently verify final lock deletion.

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

## Preservation and checkpoint files

`CHECKPOINT.json` links the reported PASS, exact source hashes, endpoint types and remaining goal. `STATUS.json` distinguishes the user's reported native success from execution performed during package preparation. `OPEN_OBLIGATIONS.txt` records the remaining finite-checker work and evidence limits.

The 67 analytic entries in `DECLARATIONS.json` now have current local source hashes/locations and explicitly user-reported aggregate PASS status. The other 1,038 entries remain unchanged. No per-declaration native audit record is invented. All old metadata is archived under `evidence/checkpoint_v0216/baseline_v0215_metadata`, and all prior evidence remains byte-preserved.

Lean source comments describing their preparation as uncompiled/source-only are intentionally retained as part of the frozen input bytes. They describe the earlier preparation stage; the latest reported native outcome is recorded in the checkpoint metadata without invalidating proof caches through comment edits.

All proof files, audit targets, cache policies, launcher and native helpers remain unchanged. The runner differs only in its package/version literals. No new runtime tests were run for this metadata checkpoint. Static source/identity comparison and archive verification are recorded in `STATIC_REVIEW.json` and `RUNNER_LOGIC_VALIDATION.json`; historical mock results retain their original source bindings. `SHA256SUMS.txt` covers all other payload files.
