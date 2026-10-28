# CERTIFICATE: Hilbert-vector cancellation-budget branch

This directory publishes the complete source snapshot of
`RH_HILBERT_LIMIT_LEAN_v0_2_28_SECOND_MOMENT_FIX_construction` alongside the
updated Hilbert-vector paper. It preserves all 775 original package files
byte-for-byte, including 106 Lean source files, 99 ordinary build modules,
one selected final audit and 463 selected audit targets. These inventory
counts do not mean that the latest source package has passed its native build.

The execution locks remain `A_TIER_LEAN` and `LOCAL_COMPILER`. Publication on
the Git branch `CERTIFICATE` does not select GitHub CI. No Lean compilation,
native Windows runner, or axiom audit was executed while preparing this
publication, and no workflow is added.

## Mathematical boundary

The semantic cancellation budget consists of two natural numbers, a cutoff
and a coefficient. Its separate admissibility proposition requires the
cancellation bound at every index beyond the cutoff. The historical native
evidence supplied by the user reports equivalence between existence of such
an admissible budget and literal Mathlib `RiemannHypothesis`.

The named candidate is `(0,0)`. Its admissibility is equivalent to vanishing
of every cancellation defect. The reported v0.2.24 native checkpoint verifies
only the first refinement, cancellation index 0. The all-order propagation
step and admissibility of this candidate remain open.

The first-five source endpoint is:

```lean
RH_HilbertLimit.zeroBudgetCandidate_first_five_cancellations
    (n : Nat) (hn : n < 5) :
    rowCancellation actualNormalizedMoment n = 0
```

This endpoint is a proof-source candidate pending a successful native build
and axiom audit. The latest supplied v0.2.27 run failed
`ZeroBudgetFiveSector` and `ZeroBudgetSecondMoment`, and blocked
`ZeroBudgetFiveRows`. The present partial repair removes two redundant
`ring` calls in `ZeroBudgetSecondMoment`; it has not been compiled.
The actual `ZeroBudgetFiveSector` error is missing from the supplied log
excerpt. Its source is unchanged and that failure remains unresolved.

No terminating finite-checker soundness or completeness theorem, accepted
finite RH witness, universal admissibility, or unconditional proof of RH is
established by this snapshot. A universal semantic predicate is not a finite
Boolean check. Indices 5 through 9 are not part of the current finite batch.

## Evidence and provenance

The evidence directory is preserved in full so that existing metadata links
and the original package hash manifest remain meaningful. The evidence is
historical user-supplied excerpts and source-review records, not newly
executed build receipts.

| Evidence | Scope |
| --- | --- |
| `evidence/native_pass_v0221/USER_NATIVE_V0220_PASS_TAIL.txt` | Historical user-reported endpoint axiom lists; standard logical axioms only |
| `evidence/zero_budget_v0224/USER_NATIVE_V0223_PASS_EXCERPT.txt` | Historical user-reported v0.2.23 aggregate frozen-reuse PASS |
| `evidence/zero_budget_second_v0225/USER_NATIVE_V0224_PASS_EXCERPT.txt` | Historical user-reported first-refinement checkpoint; index 0 only |
| `evidence/compile_fix_v0227/USER_NATIVE_V0226_FAILURE_SUMMARY.json` | Earlier reported failure and source-repair context |
| `evidence/no_goals_fix_v0228/USER_V0227_FAILURE_SUMMARY.json` | Latest supplied failure; FiveSector diagnostic missing |
| `evidence/no_goals_fix_v0228/SOURCE_DIFF.patch` | Exact two-line SecondMoment repair |
| `evidence/no_goals_fix_v0228/STATIC_VALIDATION.json` | Source/archive integrity checks; not native Lean verification |

`STATUS.json`, `CHECKPOINT.json`, `PROVENANCE.json` and `OPEN_OBLIGATIONS.txt`
record the current boundary. Historical documents keep their original
version-specific claims and must not be read as current-build success.

## Native execution

The original `run.cmd`, runner sources and cache/lock policies are unchanged.
The runner requires the entire snapshot directory to be placed below
`E:\RH-FAST\workspaces`; it rejects other locations before writing locks or
logs. Run its `run.cmd` using the user's installed native Lean 4.33.0 and
compatible cached Mathlib. No Lake setup, Python, PowerShell or WSL is needed
by the runner. Python files under `evidence/` are historical preparation or
review artifacts, not runner dependencies.

Frozen reuse requires the same target, exact source and dependency
fingerprints, compatible toolchain/cache artifacts and a prior validated
audit PASS. The publication does not change those conditions.

`SHA256SUMS.txt` is the original package manifest. This added publication
README is deliberately outside that historical manifest; the enclosing Git
commit records it together with the preserved package snapshot.
