# RH equivalences

This collection brings together **41 native-RH-target formulations in 22
families**, plus **10 separately classified opaque-model formulations**, from
the project's 21 October source catalogue. It also indexes newer SOLOBOLO,
finite-witness, GP and Hardy criteria available in this repository.

Start with the [catalogue](CATALOG.md). Each entry retains its exact criterion,
hypotheses, Lean declaration, source snapshot and source hash. The
[machine-readable catalogue](catalog.json) carries the same evidence, including
115 definition records. The formulation count includes algebraic variants;
it is not a count of independent proof mechanisms.

| Family | Entries |
|---|---|
| Native ξ/Ξ/Θ zero geometry and right-half-plane nonvanishing | E01–E04 |
| Lagarias and anti-Herglotz signs; analytic continuation and ODE germs | E05–E08 |
| Cayley loss, saturation and unit-energy preservation | E09–E11 |
| Angular derivatives, logarithmic flux, residual regions and QQRH exhaustion | E12–E22 |
| Actual RR defects, central curvature and small-o angular asymptotics | E23–E27 |
| Relative derivative bounds, finite-rate propagation and local increments | E28–E30 |
| Dyadic contraction, passivity and KQ-tail bounds | E31–E37 |
| Factorization, telescoping sources and calibrated constructors | E38–E40 |
| Cofinal uniform Widder positivity | E41 |
| Opaque GP/BKQR/Hausdorff/shift models | M01–M10, separate from native RH |

## Literature provenance

| Group | Native-target | Opaque-model | Total |
|---|---:|---:|---:|
| [Identified by Literature](Identified-by-Literature/README.md) | 18 | 5 | 23 |
| [Potentially novel](Potentially-novel/README.md) | 23 | 5 | 28 |

“Identified by Literature” distinguishes direct published criteria from standard reformulations and literature-inspired models. “Potentially novel” is a provisional label for exact project formulations whose priority remains unresolved; it does not certify novelty. Neither category changes proof or Lean verification status.

Each entry has a classification rationale and primary references where applicable. See the [literature and review policy](LITERATURE.md) and [classification data](literature-classification.json). The twelve selected local summaries and eight master-chain auxiliaries are indexed separately, without increasing the 51-entry count.

## Source and verification boundary

All 51 primary declaration source files were recovered from the original
review bundle and match the catalogue's recorded SHA-256 hashes. The
[source map](source-map.json) links 97 referenced Lean source bodies,
including definitions, aliases and related results. These bodies are preserved
unchanged under `research/upstream/rh-equivalences-corpus/`, with their original
snapshot paths recorded in the map. Applicable supplied notices are preserved.

These are archived source files, **not a combined Lean library**. Their import
closures are not all installed in the active build. Equal declaration names in
different snapshots do not establish compatible definitions. The active
89-module build and its finite SOS diagnostic are unchanged by this collection.

No new native Lean compilation or kernel axiom audit was run. The original
catalogue's “no extra theorem hypotheses” label describes a declaration's
signature; it is not a fresh dependency or axiom audit. E25, E26, E40 and E41
retain explicit analytic/model interfaces. M01–M10 use an opaque project RH
predicate and literature axioms and must not be cited as native Mathlib RH
equivalences.

An equivalence does not prove its criterion. In particular, existential energy
functions, proof-bearing model structures, universal calibration assumptions and
all-depth bounds are not finite raw witnesses accepted by a terminating checker.
The actual-ξ finite-witness reduction remains open.

## Additional evidence

- [Current repository criteria](LOCAL_CRITERIA.md) distinguish genuine native
  targets, scalar proxy encodings, conditional sufficient results and custom RH
  predicates in the newer source packages.
- [Master-chain notes](MASTER_CHAIN.md) record conditional auxiliary
  equivalences and the limits of historical compiler receipts.
- [Original catalogue](sources/AS_MANY_DISTINCTIVE_RH_EQUIVALENCES_AS_POSSIBLE.txt)
  is preserved byte-for-byte, including the separate supporting results and
  exclusions from its RH-iff count.
- [Angular source review](angular-evidence.json) checks 16 matching catalogue
  entries and their recovered local dependency graphs by source inspection.
- [Collection validation](validation.json) records integrity checks only.

The collection preserves `YOU_ARE_GOODWORKFLOWFRONTIER`, PASS-ONCE and
`LEAN_ANCHORINGS`: historical source or log recovery does not admit a frozen
compiled checkpoint into this repository.
