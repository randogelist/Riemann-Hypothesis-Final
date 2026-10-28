# Dependency-aware parallel plan for v0.2.11

This is a source-only analysis of `RH_HILBERT_LIMIT_LEAN_v0_2_11_construction`.
No Lean, Lake, native Windows, C#, CI, or runtime benchmarks were executed.
The package, its 92 Lean files, and its mathematical endpoint were not edited.
`dependency_plan.json` binds the selected source bytes and runner/manifest hashes.

## Structural result

The selected graph contains **89 ordinary modules plus `AnalyticAudit`**, with
**158 direct local import edges**. Its longest dependency chain contains
**27 modules**. The largest immediate ASAP layer has **12 modules**; the exact
maximum antichain contains **22 modules**. The JSON includes an antichain and a
22-chain cover establishing the latter count. These measures answer different
questions: a 22-module antichain need not appear in the earliest-start schedule.

Under an equal-cost module model, critical-path-priority scheduling gives:

| Lean worker cap | Cold graph slots | Six-node extension slots after 84 verified old-module hits |
| --- | ---: | ---: |
| 1 | 90 | 6 |
| 2 | 46 | 4 |
| 3 | 32 | 4 |
| 4 | 27 | 4 |
| 8 | 27 | 4 |
| 16 | 27 | 4 |

Four workers attain the 27-module dependency lower bound in this model. These
are abstract slots, **not measured durations or speedups**. The cost of different
Lean proofs, internal compiler threads, cache verification, and disk access is
not modeled. More workers can help unequal workloads but are not justified by
the graph's maximum antichain alone.

The full cold critical chain runs through the complex-analysis/Hadamard-product
branch, then the Xi quotient and unconditional-equivalence branch, followed by
`AngularMaster.ComplexScaleProduct`, `OriginTrace`,
`ActualCalibrationProgress`, `CanonicalBridge`, `CanonicalPowerSums`,
`AnalyticClosure`, and `AnalyticAudit`. A complete 27-module chain is in the JSON.
Most of the final chain offers only one ready module; retaining its verified
anchors matters more than increasing the worker cap there.

## Five new proof modules

With the 84 unchanged ordinary modules already accepted from exact matching
anchors, the new part is:

| Module | New-module prerequisites | Previously cached direct prerequisites |
| --- | --- | --- |
| `CanonicalPowerSums` | None | `CanonicalBridge` |
| `SpectralPhase` | None | `SpectralTail` |
| `SpectralGenerating` | None | `Spectral`, `SpectralTail` |
| `SpectralExtraction` | `SpectralPhase`, `SpectralGenerating` | `Main` |
| `AnalyticClosure` | `CanonicalPowerSums`, `SpectralExtraction` | None |
| `AnalyticAudit` | `AnalyticClosure` | `CanonicalBridge`, `FinitePrefix` |

The first three can run together. `SpectralExtraction` becomes ready after the
two spectral modules are accepted; `CanonicalPowerSums` can still be running.
Then `AnalyticClosure` joins the two branches, and the selected aggregate runs
last. The extension has width three and a four-module critical path. With only
two workers, the equal-cost optimal schedule starts `SpectralPhase` and
`SpectralGenerating`, then runs `CanonicalPowerSums` with `SpectralExtraction`.
Native durations may favor starting `CanonicalPowerSums` earlier; none have
been inferred here.

`CanonicalPowerSums` has 83 local ancestors, and `AnalyticAudit` reaches all
89 ordinary modules. The new modules can be built early in the cold schedule
when dependencies permit: `SpectralPhase` and `SpectralGenerating` are at
earliest unit slot 5, and `SpectralExtraction` at slot 6. The fixed file order
currently postpones them until the old chain is finished.

## CPU and RAM budget

Use **at most four concurrent Lean processes** by default when memory permits,
with **16 total requested Lean threads across compile and audit processes**.
Four simultaneous processes receive four threads each. Two can receive eight
each; three can receive six/five/five; a single process can use sixteen.
Reserve threads at launch and keep their sum within the budget. A running
process's allocation cannot be raised retrospectively. Both `-j` and inherited
`LEAN_NUM_THREADS` should describe the selected allocation consistently.

A conservative, adjustable admission starting point is a **4 GiB reservation
per Lean process**, retaining **the larger of 4 GiB and 20% of physical RAM** for
the host and other work. This is an unmeasured estimate, not a process memory
cap or guarantee. Before starting another child, recheck available RAM and
account for reservations held by active processes that have not yet reached
their estimated peak. Do not double-count already-consumed RAM as both free
and available reservation.

If the proposed read-only mapping sidecar is enabled, also reserve its announced
maximum charged-page budget for worker admission. This is deliberately
conservative even when clean file-backed pages overlap Lean mappings. The
sidecar does not guarantee residency or share an elaborated Lean environment;
its own implementation and identity are outside this source-graph analysis.

If the memory query is unavailable, fall back to one process and say that RAM
admission was unavailable. If memory permits only one, run serially. If even
one cannot fit the reserve policy, wait/recheck and give an actionable resource
message rather than adding workers. No new heartbeat, recursion, or compiler
memory-limit option is recommended here. Those changes are outside this
scheduling-only proposal.

The hashing helper currently also uses up to 16 workers. An asynchronous
scheduler should avoid overlapping that full allocation with a full Lean pool
without accounting for it. This does not require changing hash validation or
its freshness boundaries.

## Cache and integration constraints

The current runner is serial: `runToFile` calls `shell.Run(..., true)`,
`processModuleBody` performs a whole restore/compile/audit/save transaction,
and the main loop walks `ordered`. A dependency scheduler therefore needs
explicit phase state; wrapping the current synchronous loop in multiple
independent runner processes would conflict with the workspace lock and
shared mutable state.

Keep one coordinator. It owns the workspace lock, source/dependency identities,
cache checks, output validation, counters, and immutable receipt commits.
Only module-specific compiler and audit children should execute concurrently.
Their source/output/log names are already distinct by module.

For each ready node, attempt exact verified anchor reuse before allocating a
Lean worker. Successful reuse can immediately unblock dependents. A fresh
compile exit does **not** unblock dependents: keep `moduleKeys` and
`artifactHashes` unpublished until the exact audit and artifact acceptance
path succeeds. Audit-only refreshes obey the same barrier. Independent modules
can continue after an ordinary compile/audit failure; its descendants become
blocked. Hash-infrastructure failures remain fatal. Drain/account for all live
owned children before releasing the lock or declaring completion.

Keep the aggregate as a final barrier after every ordinary module is accepted,
including the exact 370 declarations and current mathematical-status fields.
Do not change `SCHEMA`, `COMPILE_POLICY`, `AUDIT_POLICY`, `COMPILE_FLAGS`, source
bytes, dependency keys, audit target lists, or fresh content checks for this
scheduling change. The existing flags explicitly classify thread count as
nonsemantic, and `makeGlobalKey`/`moduleInput` exclude the numerical `jobs`
setting. Worker count, RAM observations, and scheduling decisions can be
reported as runtime provenance without invalidating valid anchors.

Conditional source-derived compiler/audit launch counts are 179 for a fully
cold 90-node graph, 11 for the six new nodes with all old ordinary modules
reused, and zero when all 90 nodes have matching verified anchors and complete
audits. These omit startup compiler queries and hashing. Expanded audit targets
may require audit-only work; existing restoration rules must remain in force.

## Reproduce this analysis

From this evidence directory, with Python available:

```text
python analyze_dependencies.py PATH_TO_PACKAGE --out OUTPUT_DIRECTORY
```

The script reads source and manifests, computes a DAG and finite schedules,
and writes JSON only. It never calls a compiler or native runtime. A new
native run is required to learn actual durations, peak RAM, and whether the
proposed worker/thread allocation improves this machine's workload.
