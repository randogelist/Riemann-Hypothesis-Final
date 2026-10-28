# RH Hilbert Limit v0.2.14 — construction

Mode: **A_TIER_LEAN**. Target: **LOCAL_COMPILER**. Native Windows Lean **4.33.0**.

This repair changes the local cast proof in `canonicalNode_power_sum` and adds bounded shutdown-inventory rechecks. All theorem statements, assumptions, imports and audit targets remain unchanged. Of the 92 Lean files, 91 are byte-identical to v0.2.13. Native compilation and axiom auditing of this revision have not been run during preparation.

## Run

Download the ZIP to the Windows Downloads folder, then execute this one command in CMD:

```cmd
cd /d "%USERPROFILE%\Downloads" && (if not exist "E:\RH-FAST\workspaces" mkdir "E:\RH-FAST\workspaces") && tar -xf "RH_HILBERT_LIMIT_LEAN_v0_2_14_construction.zip" -C "E:\RH-FAST\workspaces" && cmd /k call "E:\RH-FAST\workspaces\RH_HILBERT_LIMIT_LEAN_v0_2_14_construction\run.cmd"
```

The new versioned workspace is under `E:\RH-FAST\workspaces`; the shared proof anchors remain under `E:\RH-FAST\anchors\RH_HILBERT_LIMIT\LOCAL_COMPILER\lean-4.33.0`. The command leaves its window open. It does not delete or forcibly recover the retained v0.2.13 lock. The existing native compiler and Mathlib cache are used. The runner does not run Lake, Python, PowerShell, WSL, network setup, or CI.

## Repairs

### Ordered real-to-complex rewrites

The supplied tail reports an unsolved goal in `CanonicalPowerSums.lean:312:40`. The restricted recursive simplifier had rewritten the real quotient underneath its complex cast into a product before the quotient cast lemma applied. The remaining identity was a cast-normalization goal.

The replacement proof performs the rewrites in order:

```lean
    rw [actualComplexMoment_eq_ofReal_actualMoment, actualNormalizedMoment,
      Complex.ofReal_div, Complex.ofReal_pow, inv_pow, div_eq_mul_inv]
    exact mul_comm _ _
```

The quotient and power are first cast into `ℂ`. The final equality follows from multiplication commutativity. No nonzero hypothesis, analytic premise, axiom or `sorry` is introduced. Native elaboration remains to be verified. Unused-tactic warnings elsewhere are unchanged.

Source identity changes for `RH_HilbertLimit.CanonicalPowerSums` and propagates through `RH_HilbertLimit.AnalyticClosure` to `AnalyticAudit`. The original source/dependency/toolchain/artifact/audit checks continue to determine reuse. Valid anchors for independent unchanged modules remain eligible; a changed module is not accepted under its old identity.

### Bounded shutdown inventory recheck

The same tail retains the lock because a `certutil.exe` command line is unreadable. It supplies neither that process's PID nor its creation identity. The tail does not establish whether the row is transient, owned, unrelated, or already exited.

Owned shutdown now retries only a structured unreadable-worker error. There are at most six full fresh inventories, with 200 ms scheduled between failed attempts: at most 1,000 ms of scheduled sleep, plus native query time. On each attempt the runner verifies the exact current lock owner, identifies the same runner PID and full creation identity, checks tracked workers, and applies the existing full worker guard to that same inventory.

A subsequent complete clear inventory allows ordinary owner-checked release. Persistent unreadability, an active related worker, changed owner/self identity, query failure or unknown tracked-worker status keeps the lock. No PID or executable-name exemption is added. No process is killed. Acquisition and stale/legacy recovery retain their previous rules. Diagnostics include unreadable-worker PID, parent PID, creation identity and name, without command-line contents. `run-result.json` records `shutdown_inventory_attempts`.

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

## Mathematical endpoint and current evidence

The selected aggregate remains `AnalyticAudit.lean`, with 370 axiom-audit targets. There are 89 ordinary scheduled modules and 90 active modules including that aggregate. The source candidates preserve:

```lean
Tendsto (rootScale actualVariation) atTop (𝓝 (spectralRadius canonicalNode))
```

and:

```lean
Tendsto (rootScale actualVariation) atTop (𝓝 1) ↔ _root_.RiemannHypothesis
```

The natural-bound criterion also remains unchanged:

```lean
(∃ B : ℕ, ∀ n : ℕ, actualVariation n ≤ (B : ℝ)) ↔ _root_.RiemannHypothesis
```

These complete analytic source candidates still require successful native compilation and the selected aggregate audit. This package preparation does not certify them. The most recent supplied v0.2.13 tail reports `PROJECT_BUILD=FAIL` and `RUN=FAIL`. The older successful v0.2.10 warm-run evidence remains historical and does not certify the new candidates.

The requested finite raw terminating-checker equivalence remains OPEN:

```lean
(∃ W : FiniteWitness, check W = true) ↔ _root_.RiemannHypothesis
```

Formal closure in that sense would not require an obtained witness, but it does require the finite format, terminating checker, soundness and completeness proofs. A natural bound with a universal all-order admissibility condition is not itself a terminating finite check. No accepted finite witness or unconditional RH proof is asserted.

The latest tail's `89/89` counter includes all terminal states, including failures and dependency blocks. It is not a successful-module count. It reports peak concurrency 1 and two new-or-reaudited tasks, without identifying the other task's result. The 79,554 ms timing covers the module stage only. No whole-run speedup or aggregate audit result is inferred from it.

## Verification and evidence

The exact source diff, proof review, native-tail transcription, lock reviews and 15 focused Node mock scenarios are in `evidence/repair_v0214`. Mock results cover the retry and retention decisions, ownership changes, stale-lock protections, and retained memory/final-reuse barriers. They do not execute the whole native WSH entry point, Windows processes, Lean, Lake or C#.

`STATIC_REVIEW.json`, `RUNNER_LOGIC_VALIDATION.json`, `STATUS.json` and `PROVENANCE.json` describe this revision. The earlier package metadata is archived under `evidence/repair_v0214/baseline_v0213_metadata`. All prior evidence remains byte-preserved with its original version/source binding. The inherited obligation ledger has only its version heading clarified. `SHA256SUMS.txt` covers every other archive payload file.

Static source references: [Mathlib v4.33.0 complex cast lemmas](https://github.com/leanprover-community/mathlib4/blob/v4.33.0/Mathlib/Data/Complex/Basic.lean), [Microsoft Win32_Process](https://learn.microsoft.com/en-us/windows/win32/cimwin32prov/win32-process). The proof review records the Mathlib blob identity. The supplied log remains the sole basis for claims about the reported native run.
