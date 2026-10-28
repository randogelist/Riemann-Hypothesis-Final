# RH Hilbert limit — Lean construction v0.2.10

## Startup optimization and helper-log hash repair

The supplied v0.2.9 run reached the E: cache and completed dependency
discovery far enough to request hashes for **37,108 files**. It then reported
`RUN=FAIL` during `CONTENT_FINGERPRINTS`: certutil returned `0x800703ee`
(`ERROR_FILE_INVALID`) for the newly built helper's staged `build.log`.
The excerpt reports 1,088 ms for that failed fingerprint stage; it does not
contain the graph-stage duration or any completed proof compilation/audit.
The earlier v0.2.5 proof-build evidence is preserved separately.

### Narrow empty-file handling

A quiet successful helper compilation can leave an empty build log. That
is a hypothesis about the failed file: its actual bytes were not supplied,
and Windows error 1006 does not itself establish emptiness. The new runner
handles this case only after independent content verification.

For the recognized nonzero certutil error, the runner first checks the file
size, loads its current contents into a fresh **binary** ADODB stream, and
requires stream size zero, position zero and end-of-stream true. It closes
the stream and checks the file size again. Only then does it return the
already self-tested SHA256 of the empty byte sequence. It reports
`SHA256_EMPTY_FILE_VERIFIED=...|BYTES=0|BACKEND=ADODB_BINARY` when used.
The actual binary load is mandatory; file metadata alone is insufficient.

Nonempty, unreadable or changing files still fail. Other error codes and
malformed successful certutil output retain their rejection behavior. No
partial hash set, unverified helper, fabricated audit receipt or general
ignore-errors path is accepted. If the reported file is not actually empty,
this release will preserve the failure for diagnosis rather than accepting it.

The implementation follows Microsoft's documented semantics for
[LoadFromFile](https://learn.microsoft.com/en-us/office/client-developer/access/desktop-database-reference/loadfromfile-method-ado),
[binary stream type](https://learn.microsoft.com/en-us/office/client-developer/access/desktop-database-reference/streamtypeenum),
[stream size](https://learn.microsoft.com/en-us/office/vba/access/concepts/miscellaneous/size-property-ado-stream)
and [end-of-stream](https://learn.microsoft.com/en-us/office/client-developer/access/desktop-database-reference/eos-property-ado).
Microsoft's [error-code reference](https://learn.microsoft.com/en-us/windows/win32/debug/system-error-codes--1000-1299-)
describes error 1006 as an invalidated file handle/volume condition, not an
empty-file certificate.

### Work removed from dependency discovery

| Previous work | Current behavior |
| --- | --- |
| Clean every character in each external Lean source before reading its imports | Read current source text, scan only the import header and first nonheader line |
| Read and clean each local proof source again for its import header | Reuse the already strictly cleaned text; the full proof-placeholder scan remains |
| Rescan a directory's filenames for every external module in that directory | Classify external artifact families once during the current graph walk |
| Normalize each requested hash path twice and repeatedly register package lockfiles | Normalize once and register each package's lockfiles once, preserving the final hash-file map |

Complete source and artifact content hashes are still required each run.
There is no persistent graph or timestamp-based trust shortcut. Import
semantics, first-match package precedence, companion artifact selection,
compilation/audit fingerprint formulas, and same-target receipt checks are
preserved. Mutable working artifact directories remain freshly inspected.

The same synthetic graph fixture produced these selected operation counts:

| Operation during graph discovery | v0.2.9 | v0.2.10 |
| --- | ---: | ---: |
| File-name extraction calls | 13,829 | 291 |
| Absolute-path normalization calls | 867 | 364 |
| Lean source-file reads | 59 | 55 |
| Directory enumerations | 5 | 5 |

The fixture contains 51 external modules and four local modules including
its aggregate audit. Its resolved graph, requested hash-file map and build/
audit identities match; only runner provenance changes. These are simulated
API-operation counts, not Windows timings or a measured native speedup.
Complete source text is still read. The main lexical saving comes from
avoiding full-body cleaning for import discovery, not skipping source hashes.

`STAGE_START=DEPENDENCY_GRAPH` now appears before discovery. During work,
`DEPENDENCY_GRAPH_PROGRESS` reports counters at work boundaries, throttled
to five seconds, then reports `COMPLETE` or `INTERRUPTED`. These are progress
samples, not a separate timer thread. Character counters use JavaScript
UTF-16 code units, not file byte counts. `STAGE_ELAPSED_MS` continues to report
completed-stage timings, so the next native run can measure the improvement.

The combined runner passed **28 targeted Node host-simulation scenarios** and
bounded independent source review. The test evidence covers graph/fingerprint
equivalence, parser behavior, operation counts, and empty-file error handling.
No Lean, Lake, native Windows, C# or CI execution occurred during preparation.
No native speedup or successful native execution of this revision is claimed.
All **86 Lean files** and all proof manifests are unchanged; formal closure
remains open. Detailed reports are in `evidence/startup_v0210/`.

## Persistent cache in E:\RH-FAST

This package runs from **E:\RH-FAST\workspaces** and stores new verified
project anchors and the hash-helper cache under **E:\RH-FAST\anchors**.
Valid anchors have no configured size cap or automatic eviction.

| Stored material | Location |
| --- | --- |
| Package, working compiled modules, generated audits and logs | `E:\RH-FAST\workspaces\RH_HILBERT_LIMIT_LEAN_v0_2_10_construction` |
| Shared immutable module artifacts, source snapshots and audit receipts | `E:\RH-FAST\anchors\RH_HILBERT_LIMIT\LOCAL_COMPILER\lean-4.33.0` |
| Persistent SHA256 helper builds and their provenance | The `hashers` subtree of that shared anchor root |
| Existing native Lean and cached Mathlib | Their existing configured locations, reused directly |

The compiler and Mathlib are not moved: their current paths participate in
the existing fingerprints. The previous custom `LEAN_ANCHORINGS_ROOT`, the
old Local AppData cache, and explicit import roots remain available for
verified read-only import. New entries go to E:. No machine-wide environment
setting is changed; the profile sets its anchor destination for this process.

The first E: run can restore and copy validated old project anchors into the
new shared store. It may build the hash helper once there. Later runs can
retain matching working artifacts; new package versions can restore matching
modules from the shared store. Each version has its own mutable workspace,
logs and lock. The supplied command creates the parent directory and extracts
the whole package there. A direct build launch elsewhere stops before lock
or log writes with an extraction instruction. Read-only follow mode remains
available through the unchanged launcher.

All **85 active modules, including the final audit**, are eligible for reuse
when their receipts and inputs match. Missing, corrupt or changed inputs still
take the normal compile/audit path. Every run freshly checks contents and
same-target audit evidence. Persistent storage does not eliminate validation
work. The default remains 16 Lean threads; no new RAM reservation or Lean
memory flag is added.

The preserved v0.2.9 storage profile previously passed **11 targeted Node
host-simulation scenarios** and independent bounded source review. The 86 earlier runtime scenarios and 19
observer scenarios remain inherited evidence; those suites were not rerun.
No native Windows runner, Lean, Lake, C# or CI execution was performed for this
release, and no native speedup has been measured. See
`evidence/persistent_v029/` for the exact source-bound review and test reports.

### Extract and run

Save the ZIP in Downloads and paste this into Windows CMD:

```cmd
cd /d "%USERPROFILE%\Downloads" && (if not exist "E:\RH-FAST\workspaces" mkdir "E:\RH-FAST\workspaces") && tar -xf "RH_HILBERT_LIMIT_LEAN_v0_2_10_construction.zip" -C "E:\RH-FAST\workspaces" && cmd /k call "E:\RH-FAST\workspaces\RH_HILBERT_LIMIT_LEAN_v0_2_10_construction\run.cmd"
```

The outer `cmd /k` keeps the console open. Subsequent launches can call the
same extracted `run.cmd`; the working objects and shared anchors remain on E:.

## Recorded native build and audit

The supplied v0.2.5 run tail reports `PROJECT_BUILD=PASS`, `RUN=PASS` and
`AXIOM_AUDIT=PASS_STANDARD_LOGICAL_AXIOMS_ONLY`. It reports **3 compiled
modules, 82 frozen reuses and 303 final audit targets**. The visible module
PASS marker is `EquivalenceAudit`; the other two compiled module names are
outside this excerpt.

The excerpt directly contains **28 complete axiom records**, matching target
positions 276–303 of the current manifest. Every visible record lists only
`propext`, `Classical.choice` and `Quot.sound`. The earlier 275 records are
outside the excerpt. `CanonicalPowerSums : Prop` is a definition entry, not
a proof that its universal identity holds.

The canonical mass-one and zeroth power-sum statements are visible without
analytic premises. The canonical root-limit and both natural-parameter RH
criteria explicitly retain `hpower : CanonicalPowerSums` and
`hExtract : DominantExtraction (canonicalCalibration hpower)`. The finite raw
format, terminating checker, its soundness/completeness and the remaining
analytic constructions are still open. Formal closure remains open; obtaining
a concrete accepted witness is not required for that milestone.

This revision preserves that recorded evidence. All **86 Lean files** are
byte-identical to the prepared v0.2.5 and v0.2.8 packages. The launcher,
observer, C# helper, proof manifests and existing hashing/validation
algorithms are preserved. The E: storage profile is described above. With valid
matching receipts for all modules, the next run can reuse **all 85 active
modules including the final audit**, with no source changes to compile.
Every receipt still requires the normal same-target fingerprint and audit
validation. No native receipts or compiled objects are fabricated from this log.

The final log paths identify a v0.2.5 extraction directory. The excerpt does
not include startup source/dependency fingerprints or receipt contents, and
does not establish native success or speed of the optimized v0.2.7 runner.
No Lean, Lake, Windows tools, C# or CI was executed during this update.
The raw log and its bounded review are preserved under `evidence/`.

## Preserved v0.2.7 runtime optimization

The inherited v0.2.7 implementation reduces repeated process launches during verified cache reuse.
The runner batches each current anchor's source, audit log and artifact checks
together with an exact matching working artifact family. The working digests
belong to that one restore attempt and are consumed once. Restored or staged
copies receive a separate fresh check after copying. Later calls hash again.

The validated SHA256 helper is selected once per run. Sets of six or more
files use it; smaller sets use independent certutil calls in parallel. Helper
bootstrap inputs and post-batch guards also use bounded parallel certutil
checks. All original helper validation phases and the separate self-test are
retained. Dependency lookup stops at the first compiled module in LEAN_PATH
order and still requires that selected package's source.

For the same synthetic warm fixture of three modules with five artifacts
each, the comparison was:

| Logical tool invocations during module reuse | v0.2.5 | v0.2.7 |
| --- | ---: | ---: |
| certutil | 36 | 12 |
| SHA256 helper | 0 | 3 |
| Combined | 36 | 15 |
| Lean compilations / audits / artifact copies | 0 / 0 / 0 | 0 / 0 / 0 |

These are Node host-simulation counts, not native timing measurements. They
exclude initial startup/helper preparation, wrapper CMD processes and tool
subprocesses. The report records the exact compared sources and fixture.
Your native run will report `STAGE_ELAPSED_MS`, `MODULE_ELAPSED_MS` and
`HASH_PHASE` in the build log. `run-result.json` contains the corresponding
arrays, total elapsed time and `logical_tool_launches` counts. Stage timing
can include hash timing; these are overlapping views, not additive totals.

All **86 Lean sources**, the fixed **run.cmd**, **NativeSha256.cs**, compiler
settings and proof/audit manifests are byte-identical to v0.2.6. Its read-only
observer and `--follow-root` entry point are also preserved byte-for-byte. Compilation
and audit identity formulas, helper cache identity, receipt schemas and lock
ownership checks are preserved. Valid existing anchors remain eligible for
reuse. Corrupt cache content rejects that candidate. Apart from the narrowly
content-verified empty-file case described above, failed hash execution,
malformed results or changed hashing infrastructure stop the run without
accepting partial results.

The v0.2.7 implementation passed **86 Node host-simulation scenarios** plus
static identity/source review. The storage-profile update preserves those
hashing and validation algorithms; that full suite was not rerun. Its new
profile has the separate targeted validation described above. No Lean,
Lake, native Windows, C# compiler/helper or
CI execution was performed. Native runtime validation and a measured speedup
remain pending. Mathematical formal closure remains open.

## Preserved launch repair

The v0.2.5 launcher repair is retained: the package's absolute directory is
captured before `pushd` and then used to locate the JScript runner. The launch
token and exit-code handling are unchanged. This preserves the repair for
the reported doubled package path in v0.2.4.

## Preserved read-only follow mode

An earlier console report said PID 24284 matched the lock owner's
PID and full creation timestamp. It establishes process presence at that
check. The later supplied v0.2.5 run tail reports completion. The observer
remains available for inspecting a separately active run; it does not start one.

The inherited v0.2.6 feature provides an explicit read-only `--follow-root` mode to the single
`run.cmd`. Use the following command to open a progress view of the existing
v0.2.5 run if it is still active, without extracting files into its directory:

```cmd
cd /d "%USERPROFILE%\Downloads" && (if not exist "E:\RH-FAST\workspaces" mkdir "E:\RH-FAST\workspaces") && tar -xf "RH_HILBERT_LIMIT_LEAN_v0_2_10_construction.zip" -C "E:\RH-FAST\workspaces" && cmd /k call "E:\RH-FAST\workspaces\RH_HILBERT_LIMIT_LEAN_v0_2_10_construction\run.cmd" --follow-root "%USERPROFILE%\Downloads\RH_HILBERT_LIMIT_LEAN_v0_2_5_construction"
```

The observer validates the current owner record, PID, full WMI creation time,
script path and invocation token. It follows that captured owner only. All
displayed build-log lines have an observer prefix. Sharing errors and partial
rewrites are treated as transient samples. Owner replacement or uncertainty
stops observation; owner exit is reported separately from build success.

Follow mode never starts Lean, writes into the observed package, removes a
lock, terminates a process or falls through to a new compiler run. It does
not interpret `run-result.json`: the v0.2.5 result format lacks an owner token
or run-tag binding, so an existing PASS cannot be attributed by this observer
to the current process. Exiting the observer is not a build/axiom-audit PASS.

`run.cmd` without arguments retains the native cached-build behavior. Use it
for a new run after the existing worker has finished. The observer and its CMD dispatch are byte-preserved from v0.2.6. The
native runner has the runtime optimization described above. Native Windows
execution and Lean verification of this release remain pending.


## Preserved proof work and scope

**The requested finite-checker equivalence remains open.** This package adds
source proofs toward the actual-ξ analytic constructions and an explicitly
conditional natural-parameter criterion. It contains no accepted finite
RH certificate and no theorem asserting the requested equivalence.

The preserved v0.2.4 revision repairs the one Lean error in the supplied v0.2.1 console
excerpt. In `GrowthStep.lean`, the natural-number bound `B = 1` requires an
explicit `Nat.cast_one` rewrite. The final proof step now uses
`simpa only [Nat.cast_one]` with the existing equality proof. The theorem,
definitions, quantifiers, and hypotheses are unchanged. All other **85 Lean
files are byte-identical to v0.2.3, v0.2.2 and v0.2.1**.

The earlier v0.2.1 excerpt reported 31 module passes followed by the cast
failure and blocked dependent module. The newly supplied v0.2.5 tail reports
the project and final audit PASS after the repair, with 3 compiled modules
and 82 reused modules. Its 28 visible records include the CanonicalBridge
endpoints with their explicit premises. The current runner preserves those
sources and the persistent caches. All 84 ordinary modules and the final
audit are eligible for reuse if their same-target receipts validate.

Use the existing native Windows Lean 4.33.0 executable and compatible
cached Mathlib through the sole `run.cmd`. The default is still 16 threads
with the existing batch SHA256 path and persistent `LEAN_ANCHORINGS`.

## Lock recovery in v0.2.3

The supplied console output stopped before startup because `.native-run.lock`
already existed. That output does not establish whether its worker was still
active or had been interrupted. This revision checks ownership before acting.

`run.cmd` launches the absolute script path with a unique invocation token.
The runner uses the local Windows WMI process inventory to identify its own
PID and complete process creation time. A complete owner record is staged
and then moved into the lock location without replacing an existing lock.

If a lock is present, an active owner or related worker blocks the new run.
A recognized abandoned owner record can be recovered only after a fresh
process inventory excludes the owner and relevant workers. The old lock is
moved to a deterministic, permanent record below `.native-stale-locks` before
a new owner is published. Competing recovery attempts cannot reuse the same
destination to move a later owner's lock. No process is terminated.

The prior run-tag-only lock and an empty interrupted-initialization lock are
recognized conservatively. Unknown metadata, unexpected files, unreadable
process information or an ambiguous live relative-path legacy runner leave
the lock untouched. Age alone never authorizes recovery. An idle `cmd /k`
window is not treated as a compiler worker merely because its original
command line mentions the package.

Look for `RUNNER_LOCK=OWNED_PID_<pid>` and, when an abandoned lock was safely
retired, `STALE_LOCK_RECOVERED=<kind>`. A live worker instead produces an
explicit `RUNNER_ACTIVE` or `RUNNER_LOCK_BUSY` notice. Let that worker finish
and retry the same command. Busy or uncertain startup leaves previous build
and audit logs intact. Normal cleanup removes only this invocation's own lock.

The persistent project/helper caches, 16-thread default, exact proof targets,
and mathematical boundary are unchanged. The revised launcher hash is
provenance, so it does not by itself invalidate compiled Lean modules.
This revision has synthetic-host validation only; native Windows execution
and Lean verification remain pending.

## Inherited local cached runner

The supplied v0.2.0 log confirms the expected Mathlib cache, 16 threads,
37,108 content hashes in 2,751 ms for the helper batch, nine frozen reuses,
and a compile-and-audit PASS marker for `AngularMaster.ZeroExclusion`.
It then starts the audit of `RiemannHypothesis.ComplexAnalysis.GrowthRigidity`
and reports `Die Datei wurde nicht gefunden.` The project run fails; no
Lean elaboration error or completed final audit appears in the excerpt.

The old staged artifact path for `GrowthRigidity` is 278 characters using
the logged base and run-tag shape; a longer imported module reaches 321.
That is consistent with a legacy Windows path-length failure. The console
log does not identify the exact failing filesystem call, so this remains a
diagnosis rather than a directly observed exception location. Microsoft's
[maximum-path documentation](https://learn.microsoft.com/en-us/windows/win32/fileio/maximum-file-path-limitation)
explains the legacy limits and that extended-path support requires application
opt-in. This update requires no registry or system setting change.

New anchor entries use compact path components below the same branch cache.
The full module name and complete SHA256 identities remain in the receipt and
are still checked. Directory prefixes are lookup aids, never substitutes for
full identity checks. Existing V2 and recognized legacy/imported receipts
remain readable under their previous layouts; nothing deletes old anchors.

The runner tries matching input-key directories before scanning older
history. After validating an anchor completely, it keeps an already matching
working artifact family in place. The filenames must match exactly and every
working file is freshly content-hashed. Missing, extra, changed, or damaged
working outputs take the normal verified restore path. A working `.olean`
without its valid same-target receipt is never accepted.

New writes have an explicit conservative path-length preflight. A custom
cache root that is still too long fails with a clear diagnostic identifying
the path; the runner does not create an incomplete PASS receipt. The schema,
compiler flags, source/dependency identity, axiom policy, and default settings
remain unchanged, allowing existing valid anchors to be reused. New or
invalidated modules still require native compilation and auditing. Expanding
audit targets still requires an audit refresh.

The new code removes avoidable history traversal and artifact copying.
Content verification remains mandatory. No speedup measurement or native
PASS is claimed for v0.2.3. The prior batch timing covers hashing and result
publication only, not total startup or build time.

## Additional persistent cache in v0.2.2

The latest v0.2.1 compact anchor layout, exact-input lookup and verified
working-object retention are preserved. Successful native project modules
and their audits are saved and reused automatically across package versions.
No configuration change is needed. Unchanged modules with valid receipts
skip Lean compilation; expanded audit coverage refreshes only the audit.

The SHA256 helper now also saves a successful build and self-test in a
persistent cache. Its identity includes the supplied source, compiler flags,
installed C# compiler, reference assemblies and listed runtime/configuration
inputs. Before reuse, the executable, source copy and logs are content-checked;
its self-test is rerun and input fingerprints are rechecked. Changed or corrupt
inputs rebuild the helper. Interrupted or failed entries are never published
as successful cache entries.

Look for `PROJECT_CACHE=READ_WRITE`, `FROZEN_REUSE=<module>`, and
`WORKING_ARTIFACTS_RETAINED=<module>`. A first helper build reports
`BATCH_HASH_HELPER_CACHE=BUILT_AND_SAVED`; a verified later reuse reports
`BATCH_HASH_HELPER_CACHE=HIT`. The default remains 16 native Lean threads.
The existing Mathlib cache is loaded without building or downloading it.

Dependency contents are still rehashed before project cache reuse; timestamps
do not stand in for fingerprints. No measured speedup or native PASS is claimed.
The cache save stage now identifies its module explicitly. Moving the writable
anchor root also keeps the previous default root available for verified import.

The update passed 25 project-cache and 17 helper-cache scenarios in a synthetic
host. These checks are runner-logic evidence only. Native Windows execution,
Lean compilation and axiom auditing of this update remain pending. The
mathematical goal and all open obligations are unchanged.

## Requested equivalence

The requested goal is both directions of

```lean
(∃ W : FiniteWitness, check W = true) ↔ _root_.RiemannHypothesis
```

Here `FiniteWitness` must be finite raw data and `check` a terminating
computation with a proved connection to the actual Riemann zeta function.
These two identifiers describe the requested interface; this package does
not claim to have implemented them. Both directions still need a construction:

- Acceptance of a concrete raw witness must imply literal Mathlib RH.
- RH must imply the existence of raw data accepted by that same checker.

An existential natural number accompanied by an inequality for every order
does not yet supply such a checker. A structure carrying an infinite function
or the desired conclusion as a proof field does not fill this gap either.
No assumed soundness/completeness pair or noncomputable Boolean decision
is used to manufacture the requested result.

The earlier logical statement remains conditional: **if this precise
equivalence is proved and RH holds, an accepted finite witness exists.**
Proving that equivalence is the unfinished task.

For this branch, **formal closure** means the compiled and axiom-audited
equivalence above, with the remaining analytic premises discharged. It does
**not require obtaining a concrete accepted witness**. Witness acquisition is
a later milestone; its absence is not the current reason formal closure is open.

## Preserved actual-ξ chain

The definitions are unchanged:

\[
L(z)=\frac{\theta'(z)}{\theta(z)},\qquad
c_n=\frac{(-1)^n L^{(n)}(0)}{n!},\qquad
\kappa=\operatorname{Re}c_0,\qquad
m_n=\frac{\operatorname{Re}c_n}{\kappa^{n+1}}.
\]

Here θ is the literal `AWPIRH.theta` built from actual ξ. The weights and
their variation are

\[
w_{N,j}=\binom Nj\sum_{k=0}^{N-j}(-1)^k\binom{N-j}{k}m_{j+k},
\qquad V_N=\sum_{j=0}^{N}|w_{N,j}|.
\]

The preserved `Main.lean` proves the ordinary root-limit statement and RH
criteria from explicit spectral-calibration data `D` and
`DominantExtraction D`. A successful compilation retains those hypotheses.
The ordinary limit concerns the nth-root sequence `rootScale actualVariation`.
It is not a claim that the unrooted variation has a finite ordinary limit.

The conditional endpoints include

\[
\lim_{N\to\infty}V_N^{1/N}=R_*,\qquad
\bigl(\lim_{N\to\infty}V_N^{1/N}=1\bigr)\iff\mathrm{RH},
\]

and equivalences with subexponential variation, every row having variation
one, all weights being nonnegative, and a uniform bound on variation. The
geometric radius is the supremum of `1` together with all node ellipse radii;
for a nonempty bounded calibrated spectrum it is the usual supremum of
those radii. Limit existence alone does not show that its value is one.

## Source progress and user-reported native evidence

The table records the six preserved extensions and their mathematical
scope. The latest v0.2.5 tail reports the complete project and 303-target
aggregate audit PASS. It directly shows 28 records across FinitePrefix,
SpectralTail, ActualMomentReality and CanonicalBridge. Complete startup
fingerprints and native receipt contents were not supplied; this is
user-reported native evidence with the visible subset separately checked.

| Module | Preserved contribution | Remaining qualification |
| --- | --- | --- |
| `ActualCalibrationProgress` | Positive actual κ; exact normalized complex nodes; norm summability; actual-zero soundness and exhaustive coverage | Its intermediate adapter takes moment reality and all-order power sums explicitly |
| `ActualMomentReality` | Every exact complex moment is real, using Schwarz reflection and conjugation of iterated derivatives | No RH, calibration, or power-sum hypothesis in these reality proofs |
| `CanonicalBridge` | Canonical node mass one, the zeroth normalized power sum, and calibration using the new reality proof | Requires `CanonicalPowerSums`; limit and criterion endpoints also require dominant extraction |
| `SpectralTail` | Finite localization of summable spectral tails and radius attainment above one | Does not yet construct the full dominant exponential decomposition |
| `GrowthStep` | An all-order inverse-linear relative-increment bound implies subexponential growth; conditional natural-parameter RH criteria | Admissibility still quantifies over every order |
| `FinitePrefix` | Exact finite-prefix locality and counterextensions for arbitrary moment sequences | Does not rule out finite certificates for the actual-ξ sequence |

These six modules contain 62 public declarations selected for the native
audit. Source counts are not counts of certified results.

### Canonical nodes and the remaining moment identity

The archived source supplies the same actual θ, a multiplicity-preserving
paired zero index `AngularMaster.ActualPairIndex`, and complex scales
`a i := AngularMaster.actualComplexScale i`. The new definition is

```lean
canonicalNode i := ((actualKappa : ℂ) * AngularMaster.actualComplexScale i)⁻¹
```

The adapter uses actual low-height zero exclusion and the first logarithmic
trace to prove positivity of κ in source. It preserves the complex scales;
no unstated RH assumption replaces them by positive real scales. Exact
divisor exhaustion supplies reverse zero coverage.

The new reflection proof supplies

```lean
actualComplexMoment_im_eq_zero (n : ℕ) :
  (actualComplexMoment n).im = 0
```

without a new analytic premise. Normalized node mass one and the `n = 0`
power-sum identity are also proved in source. Higher orders remain in

```lean
def CanonicalPowerSums : Prop :=
  ∀ n : ℕ, HasSum
    (fun i : AngularMaster.ActualPairIndex => canonicalNode i ^ (n + 1))
    (actualNormalizedMoment n : ℂ)
```

The current composite constructor is therefore

```lean
canonicalCalibration (hpower : CanonicalPowerSums) :
  ActualSpectralCalibration AngularMaster.ActualPairIndex
```

It fills the other fields with source proofs. An unconditional calibration
still requires a proof of `hpower`. Differentiating the actual product with
the necessary local-uniform convergence and exact factorial/sign
normalization remains to be done.

### Exact new natural-parameter criterion

The universal growth predicate is

```lean
def NaturalGrowthStep (V : ℕ → ℝ) (K : ℕ) : Prop :=
  ∀ n : ℕ, ((n : ℝ) + 1) * (V (n + 1) - V n) ≤ (K : ℝ) * V n
```

`CanonicalBridge.lean` supplies the following theorem, whose signature and
standard-axiom record are visible in the v0.2.5 excerpt

```lean
canonical_actual_natural_growth_step_iff_nativeRH
  (hpower : CanonicalPowerSums)
  (hExtract : DominantExtraction (canonicalCalibration hpower)) :
  (∃ K : ℕ, NaturalGrowthStep actualVariation K) ↔
    _root_.RiemannHypothesis
```

For the forward direction, the all-order increment bound gives arbitrarily
small eventual exponential growth factors. A finite initial segment is
absorbed into a positive constant, yielding the preserved `Subexponential`
predicate and RH through the existing conditional chain. Under RH the
calibrated variation is identically one, so `K = 0` satisfies the predicate.

With the same two analytic inputs, the related natural-bound theorem states

```lean
(∃ B : ℕ, ∀ n : ℕ, actualVariation n ≤ (B : ℝ)) ↔
  _root_.RiemannHypothesis
```

RH supplies `B = 1`. The finite size of `K` or `B` does not make its universal
admissibility condition a terminating acceptance test. These criteria are
not substituted for the requested finite-checker equivalence.

### Scope of finite-prefix counterextensions

For an arbitrary real moment sequence, Bernstein rows through order `K`
depend only on moments through `K`. A candidate counterextension agrees
with the constant-one sequence through any chosen `K`, then has moments
`2^n` thereafter. The earlier rows remain nonnegative, while a later row has a
negative weight and the variation has exponential lower growth.

This prevents inferring the generic infinite conclusion from those finite
rows alone. The source does not assert that these counterextensions arise
from actual ξ, or rule out an actual certificate using additional structure.

## Remaining obligations

The full boundary is in `OPEN_OBLIGATIONS.txt`:

1. Prove `CanonicalPowerSums` for the actual nodes at every positive order.
2. Construct `DominantExtraction (canonicalCalibration hpower)`. The new
   tail and maximum lemmas leave phase choice, grouping of equal rates,
   nonzero grouped coefficients, exact decomposition, and a strictly
   smaller remainder bound to prove.
3. Construct a finite raw format and terminating checker, then prove actual
   RH soundness and RH-to-accepted-witness completeness. No reduction of
   the current all-order predicate to a finite test is supplied.

No actual subexponential estimate, accepted finite witness, or unconditional
RH proof is asserted. A successful native build would certify the exact
conditional declarations, not discharge these remaining hypotheses.

## Native run and preserved runner settings

From Windows CMD with the ZIP in Downloads:

```cmd
cd /d "%USERPROFILE%\Downloads" && (if not exist "E:\RH-FAST\workspaces" mkdir "E:\RH-FAST\workspaces") && tar -xf "RH_HILBERT_LIMIT_LEAN_v0_2_10_construction.zip" -C "E:\RH-FAST\workspaces" && cmd /k call "E:\RH-FAST\workspaces\RH_HILBERT_LIMIT_LEAN_v0_2_10_construction\run.cmd"
```

The runner uses the existing native Lean 4.33.0 executable and compatible
cached Mathlib. It installs and downloads nothing. `LEAN_JOBS` still defaults
to 16, referring to threads within each Lean process. The single `run.cmd`, receipt schema, compile/audit policies, semantic flags,
and content-based proof reuse checks are preserved. The batch hashing helper
now has a persistent content-verified cache. `RUNNER_NOTES.txt` documents
the established discovery paths and optional environment overrides.

The optional `final-audit.txt` selects `EquivalenceAudit.lean`. Without a
selector the original `Audit.lean` behavior remains. Invalid or missing
selected roots fail closed. The historical audit source is preserved
unchanged but is not the selected aggregate. Nine baseline proof modules
remain eligible for verified reuse.

The active build contains **84 source modules followed by the selected final
audit**: nine baseline modules, 69 unchanged archived modules, and six new
proof modules. All 84 lie in the new aggregate import closure. The final
audit selects **303 exact declarations**: 126 baseline, 115 archived, and 62
new. The direct Mathlib boundary lists 88 distinct imports. The existing
cache must contain the required transitive dependencies; the runner does
not build missing Mathlib dependencies.

An archive label is not a native receipt. Imported modules need valid
same-target content-bound evidence or fresh native compilation and auditing.
Expanded targets can require a new audit of an otherwise reusable object.
Every required audit record is checked; only `propext`, `Classical.choice`,
and `Quot.sound` are allowed. Missing records and extra axioms fail the run.

The runtime outputs are `run-build.log`, `run-audit.log`, and
`run-result.json`. The runner retains `FINITE_CHECKER_EQUIVALENCE=OPEN` even
after a successful build. The outer `cmd /k` keeps the console open; the
worker exits with its result.

## Evidence and validation

The earlier supplied full v0.1.4 run reports `PROJECT_BUILD=PASS`, `RUN=PASS`, 126
final audit targets, three compiled modules, and seven frozen reuses. The
excerpt directly contains the final 116 axiom records, each using only the
three allowed axioms. The first ten records and startup fingerprints are
outside the excerpt, and actual Windows receipts/artifacts were not supplied.
This is user-reported native evidence for the baseline, not an independent
execution or certification of the extension.

The imported archive is
`36-RH_GIGGA_SMALL_O_EQUIVALENCE_LEAN_v0_2_0-1-1-.zip`, SHA256
`8fac3ebc0d2509622b88501ff77a6c6d0bcb6055508dfadcc035dcc4090e6fa5`.
Its 71-module closure shares two byte-identical AWPIRH files with the
baseline, leaving 69 newly integrated modules. The evidence manifest
records exact archive members, hashes, sizes, and imports.

- `evidence/USER_LAUNCH_v0_2_4.txt` and summary: the reported launch failure before the runner starts.
- `evidence/RUN_CMD_PATH_FIX.diff`: the exact launcher repair.
- `evidence/USER_RUN_v0_2_5_PASS.txt` and its summary/review: reported project and audit PASS, 28 directly visible records, preserved premises and provenance limits.
- `STATUS.json`: requested mathematical goal and preparation status and exact user-reported native evidence.
- `DECLARATIONS.json`: static source inventory, not a kernel export.
- `PROVENANCE.json`: current sources and preserved baseline hashes.
- `STATIC_REVIEW.json`: bounded source, import, audit-manifest, packaging, and runner syntax checks.
- `RUNNER_LOGIC_VALIDATION.json`: current startup/empty-hash mocks and source comparison; inherited runtime, profile and observer evidence remains separately scoped.
- `evidence/startup_v0210/`: portable current harnesses, exact-source reports, operation counts, code diff and independent review.
- `evidence/USER_HASH_FAILURE_v029.txt` and summary: the reported failure in the helper build-log hash.
- `evidence/USER_SLOW_STARTUP_REPORT_v029.txt` and summary: the preceding startup excerpt and slowness observation.
- `evidence/persistent_v029/`: targeted Node tests, source-bound reports, storage-profile diff and independent review.
- `evidence/runtime_v027/`: reproducible mock harnesses, inert historical fixtures, per-suite results, before/after launch counts, source diff and review notes. The unchanged observer retains its separate inherited 19-case report.
- `evidence/RUNNER_LOGIC_VALIDATION_v0_2_0.json`: the inherited five-scenario final-audit selection review.
- `evidence/USER_RUN_v0_2_1_PARTIAL.txt` and its summary: the earlier partial run, 31 module pass markers, the cast failure, and the blocked dependent module.
- `evidence/GROWTHSTEP_CAST_ONE_FIX1.diff`: the exact one-step proof repair.
- `evidence/USER_RUN_v0_2_0_PARTIAL.txt` and its summary: the earlier reuses, one added module pass, and filesystem failure.
- `evidence/USER_RUN_v0_1_4.txt` and its summary: the user-supplied full baseline run.
- `evidence/ARCHIVED_SOURCE_REVIEW.md`: bounded archive review and current composition update.
- `SHA256SUMS.txt`: delivered payload digests.

A valid ZIP, a lexical scan without placeholders, and a static proof review
do not establish Lean elaboration, kernel checking, or an actual axiom audit.
