# Runner static review — 2026-10-25

Files inspected: `Riemann-Hypothesis-Final/run.cmd`, `scripts/cache/Build.lean`, `docs/BUILD.md`.
No compilation or Windows execution performed. Initial review findings were sent to the runner owner for correction; this is not a final PASS.

1. The initial `Build.lean` printed an overall PASS without the input recheck promised by its adjacent comment. Changes during a run could be admitted.
2. Staging directories persisted across runs, but old `.olean.private`/`.olean.server` companions were not removed before compiling a replacement. An interrupted old artifact could be mistaken for a new companion.
3. Receipt keys mapped `/` to `_`, allowing collisions between valid module paths (e.g. `A_B/C` and `A/B_C`).
4. A failed run could leave the preceding `last-run.txt` PASS visible as if current.
5. Toolchain fingerprinting covered `lean.exe` and `lib/lean`, but omitted compiler/runtime DLLs under `bin`.

Current CMD quoting uses `cd /d`, quoted paths and disabled delayed expansion; paths with spaces should be preserved. `LEAN_PATH` and `LEAN_SRC_PATH` are cleared in CMD before running the helper. It requires existing native Windows Lean 4.33.0 and `certutil.exe`, and no download/Lake/WSL/Python command is present in the runner.

Public-proof audit scope must stay explicit: the log parser can only inspect the declarations actually printed by Audit modules. Standard-axiom allowlisting does not establish a global source admission theorem or discharge endpoint hypotheses.

Provenance/docs scan found no credential-like strings, tokens, email addresses, user account details, signed URLs, or external URLs in the then-current `provenance/*.json` and `docs/*`. This is a scoped inspection, not a guarantee for future files or all historical references.

## Re-review after runner corrections

All five initial issues have corresponding source fixes: end-of-run binary-tree/source/output rechecks; stale staged companions deleted; injective separator-to-dot receipt keys; RUNNING/FAIL receipt states; toolchain bin fingerprint. No compiler execution was used to establish this.

Additional issue sent to owner: the documented nested Mathlib checkout path has dependency caches in sibling packages, while the helper currently searches only the Mathlib checkout's own `.lake/packages`. Support for sibling packages is needed for that documented layout.

## Final scoped review

Sibling-package discovery and deduplication are now present, and BUILD.md describes both supported layouts. All six actionable findings raised in this review have corresponding source changes. No further blocking defect was identified in the reviewed code. This conclusion is a static review only: Lean 4.33 elaboration, Windows process behavior and runtime cache semantics still require the user's native run. Plans and active theorem coverage remain the root agent's automated static audit responsibility.
