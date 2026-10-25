# Riemann-Hypothesis-Final

Research objective: a finite, terminating-checker witness for actual Mathlib
`_root_.RiemannHypothesis`, along the SOLOBOLO/Cayley–Sturm route.

Read `docs/FRONTIER.md`, `docs/BUILD.md`, and
`docs/YOU_ARE_GOODWORKFLOWFRONTIER_v1_0_15.txt` before changing proofs or runners.
Use Lean 4.33.0 and compatible cached Mathlib. The native Windows user run is
the authoritative build; do not promote source inspection to a compiled pass.

- Work modes: B_TIER_DERIVATION, A_TIER_PLANNING, A_TIER_EXECUTION.
- Preserve `YOU_ARE_GOODWORKFLOWFRONTIER` and `LEAN_ANCHORINGS` names.
- Compile only new/invalidated sources; reuse requires verified fingerprints.
- Keep witnesses finite raw data. No proof fields, real-number oracles, infinite
  functions, RH assumptions, or all-orders premises inside witness data.
- Keep local arithmetic acceptance separate from actual ξ calibration and RH.
- A shared algebraic recurrence is not a positivity-preservation theorem.
- A value or finite Taylor jet at one anchor is not a functional base identity.
- Do not replace Mathlib RH with a custom predicate without proving equivalence.
- No `sorry`, `admit`, new axioms, `unsafe` proof shortcuts, or `native_decide`
  in the active proof graph. Audit the exact endpoint and its dependencies.
- Universal analytic hypotheses belong in named open obligations, not in
  certificates or hidden structure fields presented as derived facts.
- Neither conditional theorem compilation nor local diagnostics warrant
  formal closure, S-Tier, or the `🟢 LEAN-READY` signal.
- The iff target additionally requires RH-to-finite-witness completeness.
- Keep original files under `research/upstream` byte-identical and outside
  the default build. They are source provenance, not verified checkpoints.
- No license grant is implied by source import; do not invent authorship or
  redistribute the supplied manuscript without an explicit reason.
- A GitHub setup request authorizes creating and populating this repository.
  Default private visibility; do not grant collaborators or public access.
