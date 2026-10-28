# RH Hilbert limit — Lean construction v0.2.10

## Warm cache rerun: all 85 working modules retained

The latest pasted native tail reports **PASS**, with **85 frozen reused
modules, 85 working modules retained, zero compiled modules, zero restored
artifacts and zero new anchors saved**. The selected aggregate audit was
reused and reports 303 targets with standard logical axioms only and no
`sorryAx`. This is user-supplied runtime evidence, not a fresh execution here.

The two complete receipt paths visible for `CanonicalBridge` and
`EquivalenceAudit` exactly match their E: anchor-save paths in the preceding
population run. The `ActualMomentReality` reuse marker is also visible, but
its receipt path begins before this excerpt. Actual receipt contents and
startup fingerprints were not supplied.

| Reported counter | Population run | Warm rerun |
| --- | ---: | ---: |
| Compiled modules | 0 | 0 |
| Frozen reused modules | 85 | 85 |
| Working modules retained | 0 | 85 |
| Restored artifact files | 85 | 0 |
| Compact anchors saved | 85 | 0 |
| Combined working digest sets consumed | 0 | 85 |
| C# compiler logical launches | 1 | 0 |
| Total logical tool launches | 727 | 385 |
| Hash sets | 343 | 89 |
| Cumulative hash-phase time (ms) | 46,682 | 38,326 |

The warm run reports 342 fewer logical tool launches. These runs performed
different cache work: the earlier run restored artifacts and saved anchors;
the latest retained existing working artifacts. The hash-phase totals do
not measure end-to-end runtime or dependency-graph speedup. Fresh content,
environment and audit validation still run; retained cache entries are not
accepted solely because their files exist.

This evidence update keeps the same v0.2.10 runner, all proof inputs and the
same internal workspace directory. The full package includes both excerpts,
their independent reviews and the earlier directly visible axiom evidence.
**Finite-checker equivalence and formal closure remain OPEN.**

## Earlier cache population run: PASS with 85 reused modules

The supplied native console tail reports `PROJECT_BUILD=PASS`, `RUN=PASS`,
`AXIOM_AUDIT=PASS_STANDARD_LOGICAL_AXIOMS_ONLY` and `SORRYAX=NONE`.
It reports **zero compiled modules, 85 frozen reused modules, and 303 final
audit declarations**. The aggregate `EquivalenceAudit` was itself reused.
These are user-reported runtime results, not a new build performed here.

This archive records that evidence and preserves the original v0.2.10
runtime and proof sources byte for byte. Its filename identifies the recorded
run; its internal folder remains `RH_HILBERT_LIMIT_LEAN_v0_2_10_construction`.
The runner version and the existing E: workspace therefore stay the same.

**Formal closure remains OPEN.** The run explicitly reports
`FINITE_CHECKER_EQUIVALENCE=OPEN`, `MATHEMATICAL_STATUS=CONDITIONAL_PARTIAL`
and `UNCONDITIONAL_RH=NOT_ESTABLISHED`.

## Download, extract and run

Save this ZIP in Downloads, then paste this single line into Windows CMD:

```cmd
cd /d "%USERPROFILE%\Downloads" && (if not exist "E:\RH-FAST\workspaces" mkdir "E:\RH-FAST\workspaces") && tar -xf "RH_HILBERT_LIMIT_LEAN_v0_2_10_WARM_CACHE_PASS_construction.zip" -C "E:\RH-FAST\workspaces" && cmd /k call "E:\RH-FAST\workspaces\RH_HILBERT_LIMIT_LEAN_v0_2_10_construction\run.cmd"
```

The command extracts into the same persistent v0.2.10 workspace used in the
supplied log. The ZIP contains no `.native-build` directory, native objects,
receipts or locks. Extraction leaves existing unlisted cache files in place.
The outer `cmd /k` keeps the console open after completion.

The runner uses the existing native Windows Lean **4.33.0** compiler and
Mathlib cache with the existing **16-thread default**. It does not invoke
Lake, Python, PowerShell or WSL. The native runner, single `run.cmd`, C# hash
helper and read-only follower are unchanged by this evidence update.

## Earlier population counters and cache behavior

| Reported counter | Value | Interpretation |
| --- | ---: | --- |
| Compiled modules | 0 | No project source compilation was reported |
| Frozen reused modules | 85 | 84 ordinary modules plus the selected aggregate audit |
| Audit-only modules | 0 | No new audit-only execution was reported |
| Restored artifact files | 85 | Objects were restored into this workspace |
| Compact anchors saved | 85 | Entries were saved into the E: anchor store |
| Working artifact modules retained | 0 | This was not yet a demonstrated retained-output warm run |
| Anchor history scans | 0 | No historical directory scans were reported |

The 18 visible module entries form the final suffix of the current module
order, including `EquivalenceAudit`. Their source receipt paths point into
the previous LOCALAPPDATA cache; their newly saved receipt paths point into
`E:\RH-FAST\anchors`. Earlier module entries are outside the supplied tail.
The aggregate counters report 85 restored artifacts and 85 saved anchors.

Running again from the same workspace permits the existing working objects
and shared E: entries to be reused after validation. Retention is conditional
on fresh matching source, dependency, native compiler, semantic flags,
artifact content and same-target audit evidence. The update introduces no
hashing shortcuts, quota changes or cache eviction.

Compiler and Mathlib paths remain at their existing configured locations.
Mutable objects, logs and owner locks remain isolated under this package's
workspace; immutable validated entries use the shared E: anchor store.

## Earlier population measurements and their limits

The tail reports **727 logical tool launches**: 722 certutil, one C# compiler,
two hash-helper and two Lean invocations. The unchanged compiler-selection
function calls Lean for `--version` and `--print-prefix`; this accounts for
two startup queries without implying two proof compilations. Logical launch
counts are not operating-system process counts.

`HASH_PHASE_TOTALS.elapsed_ms=46682` is cumulative recorded hash-phase time.
It is not total runtime or dependency-graph time. The final aggregate reuse
reports 891 ms for its module and 989 ms for the final-audit stage. The excerpt
has no total runtime, startup/graph timings, or explicit
`SHA256_EMPTY_FILE_VERIFIED` marker. It therefore supplies no measured native
speedup and does not identify whether the empty-file recovery branch ran.

The original v0.2.10 preparation optimized import-header scanning, reused
strictly cleaned local source text, indexed external artifact families once
per graph walk, and removed repeated path normalization and package-lock
registration. It also added progress diagnostics and narrowly verified empty
file hashing after the specific certutil error. All of that runtime is
unchanged here. The original rationale and validation remain in
`evidence/native_run_v0210/PREPARATION_README.md` and `evidence/startup_v0210/`.

## Evidence boundaries

The earlier attachment begins during artifact restoration; the latest pasted
tail begins within a receipt path. Neither excerpt contains a startup
runner hash, source/dependency/toolchain fingerprint, actual receipt contents,
individual `depends on axioms` records or theorem-type printouts. Their final
log paths identify the v0.2.10 workspace; they do not independently bind the
executed bytes to this archive. The earlier raw attachment, the latest message transcription and their
bounded independent reviews are included without reconstructing missing
records. The transcription uses UTF-8/LF and is not the original native
log-file byte stream.

The earlier v0.2.5 evidence remains separate. It contains 28 directly visible
individual axiom records at target positions 276–303, as well as a reported
303-target aggregate pass. Its printed canonical endpoints retain
`CanonicalPowerSums` and `DominantExtraction` premises. Neither later reused-audit
PASS discharges those premises or adds directly visible axiom records.

## Mathematical scope

The requested formal-closure statement is:

```lean
(∃ W : FiniteWitness, check W = true) ↔ _root_.RiemannHypothesis
```

Here `FiniteWitness` must be an actual finite format and `check` a terminating
checker, with proved soundness and completeness for the actual Riemann
hypothesis. No accepted witness needs to be obtained to meet that equivalence
milestone. This package has not proved that statement.

The current canonical criteria instead relate natural-parameter conditions
to RH under explicit analytic premises. Their admission conditions retain
all-order quantifiers. A finite natural number alone is not a terminating
finite computation verifying those quantified conditions.

Open work includes higher-order actual `CanonicalPowerSums`, full
`DominantExtraction`, and the finite-format/checker/soundness/completeness
construction. The ordinary-limit endpoint concerns the rooted variation
sequence under its stated hypotheses. Existing finite-tail and maximum
attainment sublemmas do not remove the remaining premises.

See `OPEN_OBLIGATIONS.txt`, `DECLARATIONS.json`, the preserved Lean sources
and the original preparation README for the exact conditional statements.

## Files and validation

| File or directory | Purpose |
| --- | --- |
| `run.cmd` | Sole Windows entry point |
| `tools/native_runner.js` | Unchanged v0.2.10 native runner |
| `EquivalenceAudit.lean` | Selected aggregate audit source |
| `audit-targets.tsv` | Unchanged 303-declaration target list |
| `evidence/warm_run_v0210/USER_RUN_MESSAGE.txt` | UTF-8/LF transcription of the latest pasted warm-run tail |
| `evidence/warm_run_v0210/SUMMARY.json` | Warm retention results and bounded comparison |
| `evidence/warm_run_v0210/INDEPENDENT_REVIEW.json` | Independent review of the new evidence |
| `evidence/native_run_v0210/USER_RUN_PASS.txt` | Exact 18,707-byte attached native tail |
| `evidence/native_run_v0210/SUMMARY.json` | Parsed results and explicit evidence limits |
| `evidence/native_run_v0210/INDEPENDENT_REVIEW.json` | Independent text/source review |
| `evidence/native_run_v0210/FROZEN_INPUTS.json` | Digests of 97 unchanged runtime and proof inputs |
| `evidence/USER_RUN_v0_2_5_PASS.txt` | Earlier directly visible theorem/axiom evidence |
| `STATUS.json` and `PROVENANCE.json` | Current scope and evidence history |
| `SHA256SUMS.txt` | Digests for every other payload file |

All **86 Lean files** and all proof manifests are byte-identical to the
original v0.2.10 package. The runner, version marker, CMD, native helper and
observer are also byte-identical. The inherited 28 targeted Node scenarios
and older 86/19/11-scenario suites were not rerun for this documentation-only
update. Byte preservation, metadata consistency, the archive root, checksums
and ZIP integrity were checked. No native Windows, Lean, Lake, C#, Wine or CI
execution was performed by the assistant.
