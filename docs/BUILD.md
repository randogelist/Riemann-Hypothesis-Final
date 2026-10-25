# Native Lean 4.33 build

Status: source prepared and statically reviewed; this runner has not been executed on Windows. No new module is claimed compiled or axiom-audited until the native run succeeds.

Run from native Windows CMD:

```bat
run.cmd
```

To build and audit the core, then run the bounded local symbolic SOS diagnostic:

```bat
run.cmd search
```

`search` uses the same core cache and import environment. It runs `RHFinal/Search.lean` only after all core modules and axiom audits succeed. The receipt and search output state `SEARCH_SCOPE=LOCAL_SYMBOLIC_SOS_DIAGNOSTIC`; a local candidate is not an accepted RH witness. The search log is `.rh-cache\core\logs\search.log`. The current bound and problem are fixed explicitly in `RHFinal/Search.lean`.

The default `core` plan uses the installed Lean standard library. The `full` plan also includes the integrated GP source graph and requires an existing Mathlib checkout and its precompiled dependency cache:

```bat
set "RH_MATHLIB_ROOT=C:\path\to\mathlib4"
run.cmd full
```

Full mode checks a bounded set of existing caches. `RH_MATHLIB_ROOT` has priority and an invalid explicit override fails rather than falling back. Without it, the runner checks `MATHLIB_PROJECT_ROOT_OVERRIDE`, `MATHLIB_CACHE_ROOT`, `GOODWORKFLOWFRONTIER_CACHE_BASE`, and `CACHE_BASE` in that order, then these locations:

- `%USERPROFILE%\lean-native\awpi_phi_rh_lean_sieved_v0_1_1`
- `%USERPROFILE%\Downloads\awpi_phi_rh_lean_sieved_v0_1_1`
- `%USERPROFILE%\mathlib4`
- `%USERPROFILE%\Downloads\mathlib4`

For each candidate, only the candidate itself and its `.lake\packages\mathlib` child are considered. Admission requires `lean-toolchain` and cached `.lake\build\lib\lean\Mathlib.olean`. There is no broad recursive search or download fallback. If none qualifies, the runner fails with instructions to set `RH_MATHLIB_ROOT`.

The Mathlib checkout must declare `leanprover/lean4:v4.33.0` in `lean-toolchain`. Its compiled files are read from `.lake\build\lib\lean`, with dependencies under `.lake\packages` or sibling package directories when Mathlib itself lives under a downstream `.lake\packages` directory. A parent project containing Mathlib should use the actual Mathlib checkout path, such as `C:\project\.lake\packages\mathlib`.

The default compiler is `%USERPROFILE%\.elan\toolchains\leanprover--lean4---v4.33.0\bin\lean.exe`. Override it with `RH_LEAN_EXE` if needed; the established `LEAN_EXE` variable is the second-priority override. The runner never invokes Lake, Python, PowerShell, WSL or a download command. `certutil.exe` is required for SHA-256. The build helper is interpreted directly by the pinned Lean executable.

`build-modules.txt` and `build-modules-full.txt` contain topologically ordered project module paths, one per line, with forward slashes and no `.lean` extension. Names must use letters, digits, underscores and `/`. Lines beginning with `#` are comments. Every plan must include a module whose name ends in `Audit`; each such module must print at least one actual axiom report using `#print axioms`.

## GP source integration

`run.cmd full` builds the active modules listed in `build-modules-full.txt`,
including the literal Mellin–Hilbert objects, native ξ compatibility, recovered
KQ/GP/BKQR/SOLOBOLO construction, GP7 weight-seven modules and the generic
master energy extraction. The full plan currently contains 89 modules; the
manifest is the authoritative module inventory and order. The corresponding `RHFinal/GP/*Audit.lean` modules print the selected
endpoint axiom dependencies. Their compilation, when successful, certifies
only their actual statements and visible hypotheses.

The historical master files with an opaque custom RH and literature axioms,
the analytic bridge note and the H3 PDE patch remain under
`research/upstream/`; they are not imported by this build. See
[GP_CONSTRUCTION.md](GP_CONSTRUCTION.md) for the mathematical boundary.

This integration keeps `v0_1_0_construction` and is identified by Git revision.
Unchanged modules may retain a valid native receipt; new or changed modules
and dependent modules are checked through the existing fingerprint rules.
No historical pass is imported merely because a source file was preserved.
The `core`/`search` scope remains the local symbolic SOS diagnostic, not the
actual-ξ witness search promised by the still-open full reduction.

## PASS-ONCE and LEAN_ANCHORINGS

Each successful module receives a native local receipt under `.rh-cache\<mode>\receipts`. Reuse requires exact matching source, resolved imports, admitted project dependency receipts, output objects and companions, audit log, toolchain, external binary cache, flags, import path and runner fingerprints. Preexisting `.olean` files without this receipt are rebuilt. Supplied historic receipts are not silently converted into admission for this new repository. These local receipts provide the validation basis for LEAN_ANCHORINGS; importing an independently archived checkpoint is not implemented in this initial repository.

The toolchain (including native DLLs) and cached dependency binaries are cryptographically fingerprinted before and after each run. A temporary, deterministically framed binary stream is hashed with one certutil invocation per tree, keeping memory bounded by the largest single cache file. This requires temporary disk space up to the size of the largest cache tree and can take significant time for a large Mathlib cache; it does not recompile those libraries. No timestamp-only shortcut is used. Changes to the external cache conservatively invalidate the mode's project receipts. Changes to project modules propagate through imported receipts. Core and full mode receipts are separate.

Builds use an exclusive directory lock and stage objects before publishing. The old receipt is removed before a replacement starts; a replacement receipt is written only after all new outputs and the audit log are available. An interrupted run therefore cannot admit a partially replaced object. If a process is interrupted, ensure no runner remains active before manually removing `.rh-cache\writer-lock`.

Axiom reports allow only `propext`, `Classical.choice` and `Quot.sound`. `sorryAx`, compiler-trust reduction axioms, malformed lists, missing reports and any other reported axiom fail the build. This checks the declarations actually listed in the audit modules; it does not automatically establish the truth of every prose claim or certify every declaration in archival material.

Do not modify source, toolchain or shared dependency caches while a run is active. The local writer lock covers this repository only; it cannot prevent another application from changing a shared Mathlib checkout.

A build PASS certifies only the compiled statements with their printed hypotheses. The run receipt continues to state `ACTUAL_XI_CALIBRATION=OPEN`, `FINITE_WITNESS_IFF_RH=OPEN`, and `RH_PROVED=NO` until the actual mathematical endpoints are proved and separately audited.
