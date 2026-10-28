# CERTIFICATE

The current paper is [Hilbert-Vector Resolvents and the Riemann Hypothesis](RH_Hilbert_Vector_Anchor_v1_3_construction.pdf), subtitled *A detailed analytic seed criterion*. Version 1.3 preserves the title and original analytic derivations, and adds the actual cancellation-budget formulation and the current evidence boundary.

- [Revised PDF](RH_Hilbert_Vector_Anchor_v1_3_construction.pdf)
- [Editable LaTeX source](docs/papers/RH_Hilbert_Vector_Anchor_v1_3_construction.tex)
- [Current Hilbert-limit source snapshot and status](research/certificate/README_CERTIFICATE.md)

The source snapshot is `RH_HILBERT_LIMIT_LEAN_v0_2_28_SECOND_MOMENT_FIX_construction`. It retains the native runner, audit manifests, historical evidence and the two-line `ZeroBudgetSecondMoment` repair. The reported `ZeroBudgetFiveSector` failure remains unresolved because the supplied excerpt omitted its actual diagnostic. The partial repair has not been natively compiled.

Historical user-supplied native evidence supports the semantic equivalence between an admissible cancellation budget and RH, and the first zero-budget refinement. The first-five extension remains a source candidate under repair. Universal admissibility, a terminating finite checker with soundness and completeness, and an accepted finite RH witness remain open.

Publication preserves `A_TIER_LEAN` and `LOCAL_COMPILER`; it does not select GitHub CI or certify a new proof run. No Lean, Lake, Windows proof runner or GitHub Actions run was executed while preparing this branch. PDF validation uses LaTeX compilation and visual review only.

This branch is based on repository commit `ba58f416746517b865c06ebf64e75b283fbfe437`. The separate snapshot under `research/certificate/` preserves the repository's existing default project and prior paper versions.
