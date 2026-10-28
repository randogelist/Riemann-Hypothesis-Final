# RH Hilbert-limit construction — v0.2.11

**This ZIP adds five Lean proof candidates. Their native compilation and axiom audit have not been run here.** It preserves all 86 older Lean files and the v0.2.10 caching implementation. The user's latest v0.2.10 warm-run excerpt reports 85 reused modules, 85 working artifacts retained, zero compilations, and `RUN=PASS`. That evidence applies to the older sources.

## What this revision adds

The new sources attempt to supply the two analytic inputs that were still explicit premises in `CanonicalBridge.lean`: all-order canonical power sums and dominant spectral extraction. The resulting leaf statements use the actual theta/xi construction and `_root_.RiemannHypothesis`; they have no extra analytic input hypotheses. Native Lean elaboration, tactic closure, kernel checking, and the exact axiom audit remain the next gate.

| New module | Construction | Public declarations audited |
| --- | --- | ---: |
| `CanonicalPowerSums.lean` | Locally uniformly summable resolvent powers; differentiation of the actual affine product; every normalized moment as a canonical-node power sum | 27 |
| `SpectralPhase.lean` | A unit phase attaining the maximal affine norm and injectivity of the affine map at that phase | 8 |
| `SpectralGenerating.lean` | Exact generating-row identity and a finite-head plus infinite-remainder decomposition | 15 |
| `SpectralExtraction.lean` | A finite dominant head, repeated-node grouping, nonzero grouped coefficients, and a strict exponential remainder bound | 7 |
| `AnalyticClosure.lean` | Actual calibration, actual dominant extraction, ordinary root-limit existence, and six RH criteria | 10 |

The exact source hashes, public names, independent reviews, and pinned Mathlib API references are in `evidence/analytic_v0211`. These are source reviews, not compiler receipts.

## The ordinary limit stated here

The new endpoint is exactly:

```lean
Tendsto (rootScale actualVariation) atTop (𝓝 (spectralRadius canonicalNode))
```

The sequence is `rootScale actualVariation`, defined in the preserved `Growth.lean`. This statement concerns the rooted variation sequence. It does not say that the unrooted `actualVariation` has a finite ordinary limit, and it does not assert that the limiting spectral radius is one.

The leaf also states, as a new proof candidate, that convergence of this rooted sequence to one is equivalent to the actual Riemann hypothesis:

```lean
Tendsto (rootScale actualVariation) atTop (𝓝 1) ↔ _root_.RiemannHypothesis
```

Other candidate equivalences concern subexponential variation, every variation being one, all Bernstein weights being nonnegative, an admissible natural growth-step parameter, and a uniform natural bound. All refer to the exact pre-existing definitions.

## Formal closure is still open

The requested formal closure is an equivalence of the following shape, without needing to obtain an accepted witness:

```lean
(∃ W : FiniteWitness, check W = true) ↔ _root_.RiemannHypothesis
```

This package does **not** supply that theorem, a finite raw witness format, or a terminating actual-RH checker. In particular, the new natural-bound criterion still has the form:

```lean
(∃ B : ℕ, ∀ n : ℕ, actualVariation n ≤ (B : ℝ)) ↔ _root_.RiemannHypothesis
```

Although `B` is a natural number, its admissibility contains an unbounded universal quantifier. `NaturalGrowthStep` likewise retains its all-order condition. These criteria do not by themselves provide a finite computation checking admissibility. No accepted finite witness or unconditional proof of RH is asserted. The preserved `FinitePrefix.lean` records why a finite generic prefix does not establish the required tail property.

## Run on the existing native Windows setup

Save the ZIP in Downloads and paste this single line into Windows CMD:

```bat
cd /d "%USERPROFILE%\Downloads" && (if not exist "E:\RH-FAST\workspaces" mkdir "E:\RH-FAST\workspaces") && tar -xf "RH_HILBERT_LIMIT_LEAN_v0_2_11_construction.zip" -C "E:\RH-FAST\workspaces" && cmd /k call "E:\RH-FAST\workspaces\RH_HILBERT_LIMIT_LEAN_v0_2_11_construction\run.cmd"
```

`run.cmd` is preserved byte for byte, including its absolute package-path handling. The native runner uses the existing Windows Lean 4.33.0 compiler and locally cached Mathlib; it does not invoke Lake, Python, PowerShell, WSL, CI, or network setup. The default Lean job count remains 16. Python was used only to prepare this archive in the assistant's scratch environment.

Persistent paths remain:

- Workspace: `E:\RH-FAST\workspaces\RH_HILBERT_LIMIT_LEAN_v0_2_11_construction`
- Shared anchors: `E:\RH-FAST\anchors\RH_HILBERT_LIMIT\LOCAL_COMPILER\lean-4.33.0`

The versioned workspace is new. A first run can restore the unchanged 84 ordinary modules from shared validated anchors, then compile the five new modules and the new aggregate audit. This is an expected path, not a guaranteed run result: fresh source, dependency, toolchain, artifact, and same-target audit validation still decide reuse. The older `EquivalenceAudit.lean` remains unchanged but is no longer the selected aggregate; the new selection is `AnalyticAudit.lean`.

There are 89 ordered ordinary modules plus one selected aggregate, for 90 active modules. The new aggregate retains all 303 old audit targets and adds all 67 new public declarations, for 370 total. There are 91 direct Mathlib requirements. A later unchanged successful run can retain the new workspace artifacts under the same validation rules. No runtime speedup is promised by this proof revision.

## Cache behavior and reporting

Compilation, hashing, locking, receipt validation, cache identity, helper caching, and working-artifact retention algorithms are unchanged. Only the package/version labels and mathematical status reporting in the JavaScript runner change. The small exact diff is supplied in `evidence/analytic_v0211/RUNTIME_REPORTING_DIFF.txt`.

New analytic status markers are emitted only after all modules and the selected audit succeed. A failed run leaves these constructions pending. Even a successful new audit continues to report `FINITE_CHECKER_EQUIVALENCE=OPEN`, `FORMAL_CLOSURE=OPEN`, and `UNCONDITIONAL_RH=NOT_ESTABLISHED`. It audits the exact declarations and their hypotheses.

The latest supplied old warm-run tail records 381 `certutil` logical invocations, two helper invocations, two Lean invocations, and a 37,781 ms aggregate hash-phase duration. The two Lean invocations are consistent with unchanged compiler probes; the excerpt reports zero compiled modules. These counts are logical runner invocations, not an operating-system process census. The hash total is not whole-run time. Its difference from the preceding 38,326 ms total does not establish a controlled speedup.

## Evidence and verification scope

- All 86 prior Lean source files are preserved byte for byte, along with `run.cmd`, the SHA256 helper source, follower, and toolchain file.
- The previous 1,038 declaration inventory entries retain their original historical metadata; 67 pending entries are appended. Current run evidence and current pending status are stated separately in `STATUS.json`.
- Prior evidence files are preserved unchanged. The latest supplied message is saved as a UTF-8/LF transcription, explicitly distinguished from original native log-file bytes.
- Static checks cover source hashes, local imports and order, public declaration names, audit coverage, prohibited placeholders outside comments/strings, runtime reporting-only changes, JavaScript syntax, and archive integrity.
- No Lean, Lake, C# compiler, native Windows runner, Wine, or CI execution was performed during preparation. No native objects, successful receipts, or new native PASS results are manufactured in this ZIP.

The exact leaf statements are in `RH_HilbertLimit/AnalyticClosure.lean`. `OPEN_OBLIGATIONS.txt` separates the native verification gate from the remaining finite-checker construction. Historical top-level metadata is retained under `evidence/baseline_v0210_metadata` and is not the current package status.
