# Attachment source review for RH publication

**No attachment supplies the missing actual-ξ calibration, a sound and complete finite RH checker, or the RH-to-GRH transfer.** There are useful new constructions, but their exact targets must be retained. No compiler was run and no new A-Tier, formal-closure, or S-Tier status is assigned.

## Inventory and publication boundary

All 25 ZIP central directories and every contained Lean text were inspected, including the nested ZIP in attachment 03. The result is 814 Lean occurrences and 545 distinct byte hashes. Of these, 535 are absent from the earlier review-bundle/recent-library union, while 508 are absent from both tracked repositories. Those counts mostly describe odd-zeta and manuscript sources; they are **not** counts of new RH results.

The comparison uses tracked Git paths only and records every matching path. At inspection, RH HEAD was `69ad4d6a66c5826d77013c33afeb40b7a1a90639`, GRH HEAD `b9fadffe5f4430dc39c27813b69f1c704404626f`. All 29 Lean hashes in attachment 16 are already tracked. Eight substantive GP7 sources from attachment 10 are already tracked; its four unmatched files are audit and umbrella-import modules rather than a newly discovered RH bridge.

Attachment 21 contains only a progress report and runner; attachment 22 contains a runner recovery patch and notices. Neither contains a mathematical Lean module. Manuscript PDF 26 was not copied or prepared for publication. Workflow 27 was read and hash-indexed: it requires native Windows Lean 4.33, exact reuse provenance, finite admission distinguished from conditional proofs, and no unverified PASS.

Full archive/member hashes, import lists, exact repository matches, and extracted relevant source paths are in `attachment-archive-provenance.json`, `attachment-source-provenance.json`, and `attachment-inventory-summary.json`. The 16 selected result records in `attachment-relevant-results.json` give exact declaration signatures, source lines, conditions and relevance decisions.

## Direct RH material: already present, assumptions still open

Attachment 16, `RH_FIVE_INDUCTION_LEAN_v0_3_0`, provides real literal-Mathlib RH endpoints. It does not derive their inputs:

- `ProjectionInput.RH_OF_RECIPROCAL_RADIUS` needs `1 ≤ reciprocalSeries.radius`. Its alternative `ProjectionXiRealization E` requires identification of **every** actual reciprocal coefficient with projection readouts and a subexponential bound for all readout norms.
- `SOSXiRealization` requires positive SOS trajectories converging to the actual angular derivative at **every** positive radius and interior angle. `SchurXiRealization`, `SturmInput`, and `DifferentialInput` require actual-function locally uniform convergence of their specified approximants.
- `HardyInduction.RH_IFF_PRESCRIBED_RADIUS_STEP` has the explicit argument `ActualHardyEnergy`, the identity `HasSum (fun n => Complex.normSq (coeff n)) K`. `PrescribedRadiusStep` remains a universal successor premise. Its `FiniteDiskCertificate r := ∃ N, ∀ w : ℂ, ‖w‖ ≤ r → 0 < D N w` is not a finite raw-data Boolean checker.

The attachment's own build record says integrated Main/Audit and fresh rebuilding were incomplete; actual Hardy energy is an input and prescribed-radius advancement is open. Its eight module source hashes can be checked against the supplied sources, but historical individual compilation metadata does not certify a fresh integrated native run.

## New reusable patterns, with their actual scope

Attachment 03 supplies data-only rational packets and `checkRiesz_iff`/`checkApery_iff`. Their soundness and completeness are relative to the displayed **rational** validity predicates. The file explicitly leaves real-zeta envelope correctness outside that checker. This is a useful design example, not RH soundness or completeness.

Attachment 06 supplies a stronger target-specific example: `NativeE.lock`, `NativeE.linear_laws`, `NativeE.seed_checks`, and `NATIVE_E_IRRATIONAL_FROM_ONE_COORDINATE` derive the recurrence laws, actual error interpretation, and a checked seed for `Real.exp 1`. The generic `RieszCore.LockLaws` still separately demands invariant preservation, rate monotonicity and contraction for every admissible state. `RieszRepresentative.LinearLaws` separately demands the actual target error interpretation. Those proofs must be constructed anew for actual ξ. Moreover, `NativePiChecks.raw_awpi_has_no_native_pi_linear_laws` explicitly rejects the raw AWPI-to-native-π interpretation. Attachment 05 likewise leaves `PiAnalyticIdentification`, uniform actual error bounds and `PiSparseLock` as hypotheses.

These modules are reasonable optional reference examples. They should not expand the active RH graph merely because their namespaces contain GP/BKQR.

## Zetahyperbolic additions: substantive, different target

Attachment 20 contains `stage03_original_gram_unconditional`, `stage03_original_exact_zero_free_disk`, and `stage03_unconditional_general_statement`. Their source derives positive definiteness and real-root spectral geometry for the **original finite rational determinant pencil centered at ζ(2k+1)**, for admissible Hankel parameters and `1 ≤ k`. This is substantive actual-pencil calibration, not a theorem that the zeros of the Riemann ξ function lie on the critical line. The source closure is included in that archive. Its new adjacent-drift endpoint for ζ(5) still requires `c > 0` and a negative actual log-increment bound for **every** `n`; it does not replace the infinite premise with one finite check.

Attachment 25 has a complete local source import closure for its 26 supplied modules, with Mathlib external. The new `Paper10Section3FiniteFraction` and `Paper10Section3WeightedGram` derive the original numerator's partial fractions and

```lean
gram_eq_weighted_monomial_integral (p : Real.Parameters)
    (hp : Real.Admissible p) (i j : Fin p.h) :
  Real.gram p (Real.zeta p.weight) i j =
    ∫ y : ℝ in Ioi 0,
      y ^ (2 * (i.val + j.val)) * weightedDensity p y
```

Here admissibility is `k > 0`, `m > 0`, `N > 0`, `N < K`. `weightedDensity_pos` is also supplied. These are promising source-level constructions for the paper's Bose-weighted pencil, not actual-ξ/GP functional BASE calibration. The README explicitly marks both new modules as awaiting their first native run; strict Gram positivity, normalization to the full denominator and complete manuscript results remain outside that checkpoint. Its `SpectralPolynomialFamily` still carries all-stage factorization and spectral-bound proof fields, with additional `ScaleUpper` and `RationalIndexBudget` premises for irrationality.

Attachment 24's `manuscriptGramAt_posDef_of_explicitBoseIntegrals` still takes exact equality between the manuscript pencil and Bose integrals as an argument; its latest affine-source repair is native-unverified. The external frozen `Zetahyperbolic.Section2Checked` import and dependencies must be supplied coherently if used. Attachment 23 adds a finite mass-fraction inequality from per-entry caps and a lower average, without an actual asymptotic estimate. Attachment 19 supplies finite weighted-Gram nonnegativity, likewise without actual ξ identification. These can support future generic work, but none discharges the publication's RH condition.

## Recommendation

Preserve attachment inventory and exact mathematical boundaries in publication provenance. Reuse the already tracked FiveInduction and GP7 sources rather than duplicating them. Keep the new non-RH examples and paper branches outside the active RH proof graph unless a particular theorem is deliberately imported with its complete dependency closure. Do not claim that grouping the unresolved hypotheses into one structure derives them or makes them finite.

The static scan found no admit/axiom/unsafe/native-decision token in the relevant extracted RH/GP/paper sources after comment stripping. Attachment 17 separately declares `Zeta5.Axioms.chebyshev_theta_asymptotic`; it must not silently enter an axiom-free RH graph. This scan is a source review, not a Lean axiom audit. No binaries, historical runners, manuscript PDF, or unrelated odd-zeta source dump is needed for the RH publication.
