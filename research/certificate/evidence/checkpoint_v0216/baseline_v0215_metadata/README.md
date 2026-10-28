# RH Hilbert Limit v0.2.15 — construction

Mode: **A_TIER_LEAN**. Target: **LOCAL_COMPILER**. Native Windows Lean **4.33.0**.

This revision repairs four proof bodies in `SpectralPhase.lean` and `CanonicalPowerSums.lean`. Exact theorem statements, quantifiers, hypotheses, imports and selected audit targets are preserved. The other 90 Lean files remain byte-identical. The runner's functional code, launcher and helpers are unchanged; only the package/version identity strings advance. Native Lean compilation and axiom auditing of this revision have not been run during preparation.

## Run

Download the ZIP to the Windows Downloads folder and execute this command in CMD:

```cmd
cd /d "%USERPROFILE%\Downloads" && (if not exist "E:\RH-FAST\workspaces" mkdir "E:\RH-FAST\workspaces") && tar -xf "RH_HILBERT_LIMIT_LEAN_v0_2_15_construction.zip" -C "E:\RH-FAST\workspaces" && cmd /k call "E:\RH-FAST\workspaces\RH_HILBERT_LIMIT_LEAN_v0_2_15_construction\run.cmd"
```

The versioned workspace stays under `E:\RH-FAST\workspaces`; verified same-target anchors remain under `E:\RH-FAST\anchors\RH_HILBERT_LIMIT\LOCAL_COMPILER\lean-4.33.0`. The command keeps the window open. The user's existing native compiler and compatible Mathlib cache are used. The runner does not invoke Lake setup, Python, PowerShell, WSL, network setup or CI.

## Proof repairs

| Declaration | Repair |
|---|---|
| `SpectralPhase.affine_eq_iff` | Introduce the fixed equality premise and apply `affine_injective hx` to it. |
| `SpectralPhase.norm_affine_lt_ellipseRadius_of_norm_lt_one` | Use the pinned API's addition-order lemma that matches the displayed sum order. |
| `CanonicalPowerSumAnalysis.hasDerivAt_resolvent` | Preserve `fun_div`, prove its scalar derivative equals the requested scalar, rewrite that equality into the derivative fact, and use the result. |
| `CanonicalPowerSumAnalysis.hasDerivAt_resolvent_pow` | Preserve `fun_pow` and normalize its scalar coefficient through a separate typed equality. |

The two derivative proofs now use explicit algebraic identities:

```text
(0 * d - b * b) / d² = -((b / d)²)
c * r^(n + 1 - 1) * (-(r²)) = -c * r^(n + 2)
```

Restricted simplification proves these identities. The original denominator-nonzero argument remains supplied to the quotient derivative theorem. No new nonzero, analytic, calibration or RH premise is introduced. The previous real-to-complex normalization repair in `canonicalNode_power_sum` remains byte-identical. Its old diagnostic is absent from the latest supplied excerpt, but `CanonicalPowerSums` still failed overall in that run.

The two changed module identities invalidate dependent identities through `SpectralExtraction`, `AnalyticClosure`, and the selected `AnalyticAudit`. Independent unchanged modules remain eligible for verified cache reuse. All original source/dependency/toolchain/artifact/audit checks remain active. Missing or mismatched receipts cause rebuilding or failure, never acceptance under an old identity.

## Native evidence supplied for v0.2.14

The excerpt reports `COMPILE_FAIL` for both changed modules and blocks `SpectralExtraction` and `AnalyticClosure`. It ends with `PROJECT_BUILD=FAIL` and `RUN=FAIL`. The `89/89` scheduler counter includes failed and blocked terminal states. No aggregate compile or axiom-audit success is present.

The same excerpt reports successful runtime control-flow progress: serial memory admission with 7,283 MiB free against the 5,120 MiB threshold, one 16-thread compile worker at a time, and `WORKER_INVENTORY_RECHECK=CLEAR|ATTEMPTS:4`. Three unreadable certutil records were observed before that clear check. The excerpt has no explicit successful lock-deletion record, so physical lock release is not independently verified. Parent PID alone is not used to classify a process's command or workspace.

The 79,115 ms timing covers the project-module stage only. No whole-run speedup or mathematical promotion is inferred. The two displayed reuse receipts are retained as user-reported log evidence; their files and artifacts were not supplied for independent inspection.

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

The selected aggregate remains `AnalyticAudit.lean` with 370 axiom-audit targets. There are 89 ordinary scheduled modules and 90 active modules including the aggregate. The exact source candidates preserve:

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

These analytic source candidates still require successful native compilation and the selected aggregate audit. The older successful v0.2.10 evidence remains historical; it does not certify this source frontier. This repair preparation asserts no new native proof or axiom PASS.

The requested finite raw terminating-checker equivalence remains OPEN:

```lean
(∃ W : FiniteWitness, check W = true) ↔ _root_.RiemannHypothesis
```

Proving this equivalence would not require an obtained witness, but does require a finite raw format, a terminating checker, and soundness/completeness proofs for actual RH. A natural bound with a universal all-order admissibility condition does not itself provide such a finite check. No accepted finite witness or unconditional RH proof is asserted.

## Verification and evidence

`evidence/repair_v0215` contains exact proof diffs, source reviews, an independent review of the derivative algebra, the pasted-tail transcription, and the byte comparison of the runtime. All 35 declaration headers in the two edited files are unchanged. The old runtime mock evidence remains historical and is not relabeled as a v0.2.15 execution. No additional runtime tests were needed because all functional runner bytes and helper files are unchanged.

`STATUS.json`, `STATIC_REVIEW.json`, `RUNNER_LOGIC_VALIDATION.json`, and `PROVENANCE.json` describe this revision. Immediate parent metadata is preserved under `evidence/repair_v0215/baseline_v0214_metadata`. All prior evidence is preserved byte-for-byte with its original source bindings. The proof-obligation ledger has only its version/scope heading updated. `SHA256SUMS.txt` covers every other archive payload file.

Pinned primary source references checked during source review:

- [Mathlib v4.33.0 quotient derivatives](https://github.com/leanprover-community/mathlib4/blob/v4.33.0/Mathlib/Analysis/Calculus/Deriv/Inv.lean).
- [Mathlib v4.33.0 power derivatives](https://github.com/leanprover-community/mathlib4/blob/v4.33.0/Mathlib/Analysis/Calculus/Deriv/Pow.lean).
- [Mathlib v4.33.0 ordered addition](https://github.com/leanprover-community/mathlib4/blob/v4.33.0/Mathlib/Algebra/Order/Monoid/Unbundled/Basic.lean).

The review records include the returned Git blob identities. Source review and archive verification do not replace native elaboration, kernel checking, or axiom auditing.
