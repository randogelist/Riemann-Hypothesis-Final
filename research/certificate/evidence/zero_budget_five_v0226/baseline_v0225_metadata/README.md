# RH Hilbert Limit v0.2.25 construction — second check of (0,0)

This is a proof-source continuation toward the admissibility of
`zeroBudgetCandidate : CancellationBudget := ⟨0,0⟩`. It prepares an independent
analytic proof of the second cancellation row:

```lean
rowCancellation actualNormalizedMoment 1 = 0
```

The sources have not been compiled or axiom-audited here. They must pass the
user's native Windows Lean 4.33.0 and compatible cached Mathlib audit before
the new endpoint is certified. A passing build establishes the two finite
refinement indices 0 and 1 only. It does not establish full admissibility,
an accepted finite RH witness, a complete terminating checker, or RH.

## Proof scope

The previous user excerpt reports v0.2.24 `RUN=PASS`, 3 compiled modules,
92 reused modules, and the first cancellation row audited at index 0 only.
It does not print the audit declaration count, explicit axiom lists, or a
`SORRYAX` line. The previous package selects 428 targets; that manifest count
is kept separate from what the excerpt actually prints. Earlier explicit
axiom evidence for the conditional witness-to-RH transfer remains preserved.

The new sector module bounds the theta kernel by x^(-2)/6 above one,
uses inversion below one, and bounds the pole-subtracted completed zeta
function by 1/6 on the critical strip. This excludes xi zeros up to height
two and gives positive real parts of the cubed canonical nodes. The new moment
module uses exact canonical power sums and unit real mass to prepare:

    0 < u₂,    u₂ ≤ u₁,    2u₁ ≤ 1 + u₂,

where `uₙ = actualNormalizedMoment n`. These are exactly the second-row
conditions exposed by the preserved v0.2.24 algebra. No RH hypothesis is
used in the new finite-row proofs. Source inspection is not native validation.

## Remaining endpoint

Full admissibility of (0,0) still requires the unchanged universal statement

```lean
∀ n : ℕ, rowCancellation actualNormalizedMoment n = 0
```

No uniform propagation theorem is supplied here. Two finite rows do not
imply that statement, and this package must not report witness acceptance.
A fixed sector bound cannot by itself prove every row: generic conjugate
nodes 1/2 +/- i epsilon have unit mass and arbitrarily narrow sectors, yet
some higher power has negative real part. This is a limitation of this
method, not a counterexample involving actual xi. A new argument specific
to actual xi is still needed. The independent review records this frontier.
The separate finite-checker soundness and equivalence goals remain open.

## Native build and preserved sources

All 99 previous Lean files and 1163 previous declaration records
are retained unchanged. The new active order has 96 ordinary modules plus
`SecondMomentAudit.lean`. All 428 former audit targets are retained, with 20 new
public declarations added (448 selected targets total).

With valid same-target source/dependency/toolchain/artifact/audit identities,
94 old ordinary modules are eligible for reuse and the two new source
modules plus the new audit are expected to compile. Missing or invalid cache
records rebuild or fail. These are expected counts, not an observed run.

Only package identity and mathematical result reporting change in the runner.
Compiler, cache, audit, scheduling, memory, lock, and shutdown decisions retain
the baseline bytes. The existing offline setup is used without Lake setup,
Python, PowerShell, WSL, or CI in the runner.

```cmd
cd /d "%USERPROFILE%\Downloads" && (if not exist "E:\RH-FAST\workspaces" mkdir "E:\RH-FAST\workspaces") && tar -xf "RH_HILBERT_LIMIT_LEAN_v0_2_25_construction.zip" -C "E:\RH-FAST\workspaces" && cmd /k call "E:\RH-FAST\workspaces\RH_HILBERT_LIMIT_LEAN_v0_2_25_construction\run.cmd"
```
