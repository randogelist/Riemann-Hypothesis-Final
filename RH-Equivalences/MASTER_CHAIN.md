# Master-chain auxiliary equivalences

These eight records are additional source/receipt evidence, outside the 41
native-RH catalogue entries. No theorem in the recovered packages identifies
`MASTER_3` with `_root_.RiemannHypothesis`. The exact hypotheses are retained.

The exact project packaging is indexed under
[Potentially novel](Potentially-novel/README.md#master-chain-auxiliaries), with
priority unresolved. Its scalar, integral and Hilbert-space identities use
standard mathematics; this label does not turn these auxiliary statements into
native RH equivalences.

| Statement | Required inputs | Source/evidence |
|---|---|---|
| `MASTER_3 ↔ c1 = kappa` | `h1 : MASTER_1` | [MasterChain.master_3_iff_c1_eq_kappa](../research/upstream/rh-equivalences-master-chain-v010/MasterChain/Chain.lean) |
| `MASTER_3 ↔ C_RR = 0` | `h2 : MASTER_2` | [MasterChain.master_3_iff_defect_zero](../research/upstream/rh-equivalences-master-chain-v010/MasterChain/Chain.lean) |
| `MASTER_3 ↔ densityMass = 0` | `h2 : MASTER_2` | [MasterChain.master_3_iff_mass_zero](../research/upstream/rh-equivalences-master-chain-v010/MasterChain/Chain.lean) |
| `scalarReadout = 0 ↔ densityMass = 0` | `Integrable A positiveLebesgue`; `Integrable (fun v => exp(-3*v/2)*g v) positiveLebesgue` | [MasterChain.scalarReadout_zero_iff_mass_zero](../research/upstream/rh-equivalences-master-chain-v010/MasterChain/Chain.lean) |
| `MASTER_3 ↔ scalarReadout = 0` | `h2 : MASTER_2`; `hInt : NativeIntegrability` | [MasterChain.master_3_iff_scalarReadout_zero](../research/upstream/rh-equivalences-master-chain-v010/MasterChain/Chain.lean) |
| `MASTER_3 ↔ V 1 = 0` | `h2 : MASTER_2`; `hInt : NativeIntegrability` | [MasterChain.master_3_iff_V_one_zero](../research/upstream/rh-equivalences-master-chain-v010/MasterChain/Chain.lean) |
| `MASTER_3 ↔ xiDensityVector hMass = 0` | `h2 : MASTER_2`; `hMass : Integrable A positiveLebesgue` | [MasterChain.master_3_iff_xiDensityVector_zero](../research/upstream/rh-equivalences-master-chain-v010/MasterChain/Realization.lean) |
| `MASTER_3 ↔ ∀ p : ℕ, C_RR ≤ dyadicThreshold p` | `h2 : MASTER_2` | [MasterChain.master_3_iff_all_dyadic_defect_bounds](../research/upstream/rh-equivalences-master3-v020/validation/fix2/audit.log) — receipt only; theorem source absent |

`MASTER_1`, `MASTER_2` and integrability are mathematical premises. The raw
totalized integrals and suprema do not establish convergence. The all-dyadic
bound quantifies over every natural index; it is not a finite witness check.

Historical Linux Lean 4.33 receipts match the 13 recovered v0.1.0 source hashes
and two supplied FIX2 files. This is inherited evidence, not a new Windows run
or an admitted `LEAN_ANCHORINGS` checkpoint. FIX2 is an incomplete patch whose
baseline imports and dyadic equivalence source are missing.

[Full evidence and exact signatures](master-chain-evidence.json) retain these
distinctions and the separate kernel-mass bridge statements.
