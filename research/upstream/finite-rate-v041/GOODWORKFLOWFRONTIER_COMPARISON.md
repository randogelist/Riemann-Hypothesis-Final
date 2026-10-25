# Workflow comparison

| Rule | GOODWORKFLOWFRONTIER | SOLOBOLO v0.4 |
|---|---|---|
| Windows native Lean | pinned 4.33.0 | pinned 4.33.0 |
| Fast startup | direct lean.exe -j16 | direct lean.exe -j16 |
| Prebuilt Mathlib | cached `.olean` | cached `.olean`; checks root and zeta key |
| Freeze | pass-once module-level | source/dependency/environment fingerprint |
| Invalidation | changed source/dep/env | changed source/dep/env, graph stamps |
| External pass reuse | only for exact unchanged compiler environment | v0.3 source+olean+log+environment match |
| Axiom gate | `#print axioms`, no sorryAx | same, no custom axioms in new source |
| Network/build | no Lake/network/PowerShell/WSL | same |
| External witness search | candidate packet untrusted until Lean proof | no external witness admitted |
| Finite witness iff RH | goal requires sound and complete validator | four open mathematical bridges |

Note: the workflow equivalence is operational, not a proof of RH.
