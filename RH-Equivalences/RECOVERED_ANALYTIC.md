# Recovered analytic criteria

These two additional formulations now have complete project-source import
closures in the full build. They are separate from the frozen 51-entry source
catalogue and do not increase its historical counts. Native compilation and
executed axiom audits remain **NOT_RUN**.

| ID | Criterion equivalent to native Mathlib RH in the source | Exact theorem | Project sources |
|---|---|---|---:|
| A01 | Actual regularized Cayley zeta has an analytic reciprocal on the unit disk | [`SoloAdmission.ANALYTIC_ADMISSION_IFF_RH`](../SoloAdmission/AnalyticInverse.lean) | 4 |
| A02 | Actual theta admits a holomorphic coefficient A with Θ′ + AΘ = 0 on the slit plane | [`SoloboloAdmission.slitODEAdmission_iff_RH`](../SoloboloAdmission/NativeODE.lean) | 5 |

The explicit native-target checks and axiom-report requests are in
[ReciprocalAudit](../ReciprocalAudit.lean) and
[AnalyticPublicationAudit](../AnalyticPublicationAudit.lean).
The [source manifest](../provenance/recovered-analytic-sources.json) records
byte-identical active and archival originals.

## Literature classification

Both belong to **Identified by Literature**, with the qualification already
used for E07/E08: the mathematical mechanism is a standard analytic
reformulation of zero-freeness. The exact project wording is not asserted to
be a separately located published criterion, and this classification is an
inference from its explicit reduction. No novelty claim is made. A02 overlaps
the ODE mechanism of E08; the change of actual carrier/domain is recorded
explicitly. A01 uses the reciprocal criterion for the actual Cayley carrier.
See the existing [literature policy](LITERATURE.md) and
[machine-readable supplement](recovered-analytic.json).

## Remaining condition

These equivalences do not construct either admitted analytic object.
The additional SOLOBOLO endpoint is a conditional sufficient theorem from
locally uniform decay of the **actual** residual. The exact current statement,
its raw-program boundary and the separate finite-checker completeness gap are
documented in [ACTUAL_CONDITION](../docs/ACTUAL_CONDITION.md).

The native theorem target is not an opaque project RH predicate. However,
source completeness, compilation, axiom audit, and construction of a finite
accepted witness remain distinct statuses.
