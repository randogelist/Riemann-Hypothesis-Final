# Finite witness ⇔ RH -- v0.4 actual obligations

Proof objective:
`(∃ W : FiniteCode, checkActualXi W = true) ↔ ActualRiemannHypothesis`.

PROVED IN THE SOURCE (pending user's 4.33.0 compiler PASS):
1. Existing v0.3 abstract scalar zero-mass ⇔ epsilon-admission.
2. Existing all-depth quarter contraction from a valid start.
3. New terminating syntax checker of rational budgets (not a source checker).
4. New one-base-plus-uniform-step ⇒ all-depth envelope induction.
5. New semantic rate-packet ⇔ no-off-line-mass, conditional on a
   rational envelope budget and the RH tail-quarter rate.
6. New semantic rate-packet ⇔ ACTUAL RH, conditional on the actual
   xi source identification, RH tail rate and rational budget (now automatically provided).
7. Explicit counterexample: the rational-only packet check accepts zero
   for a positive-off-line-mass profile, so it CANNOT alone prove RH.

FOUR REQUIRED RESEARCH THEOREMS (not silently assumed):
A. ActualXiZeroProductSource: actual Mathlib riemannZeta RH ⇔ offMass = 0
   for the uniquely defined actual dyadic zero ledger.
B. RHWeightedCriticalLineTailRate: actual RH ⇒ uniform dyadic quarter rate.
C. ActualXiFiniteCheckerSoundness: one SPECIFIC terminating Boolean checker
   accepting a finite code ⇒ universal actual-source envelope or contractivity.
D. ActualXiFiniteCheckerCompleteness: actual RH ⇒ exists accepted finite code.

RationalBudget p is established by an explicit Archimedean Lean proof draft
in RationalBudgetClosed.lean (pending compiler PASS).
`SemanticallyAcceptedRatePacket` is NOT a finite accepted witness because
it includes an infinite proposition. Do not conflate these statuses.

Theorem package result on native user Lean PASS certifies the stated conditional
implications only. An axiom-clean theorem with `hsource`, `hsound` and
`hcomplete` as variables does not close those obligations.

RH_PROVED=NO; FINITE_WITNESS_IFF_RH_UNCONDITIONAL=NO; LEAN_READY=NO.
