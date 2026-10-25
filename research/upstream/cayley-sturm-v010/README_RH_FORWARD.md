# SOLOBOLO–CAYLEY–STURM / RH-forward v0.1.0

**Purpose:** Lean the direction `native RiemannHypothesis -> critical native zeros -> finite Cayley contractions -> all finite Hausdorff cells, Mersenne traces and localizing Gram sums of squares`. This package is NOT an unconditional RH proof and does NOT establish the actual infinite-`xi` divisor or finite-witness checker soundness.

**Source reuse:** All 34 v0.5.0 original Lean sources preserved **byte for byte**. The `run.cmd` uses the same `%USERPROFILE%\Downloads\WITNESS_SOLOBOLO_SHARED_CACHE`, same `Lean 4.33.0`/Mathlib fingerprint checks, source hash stamps and dependency invalidation. No network, Lake fetch, PowerShell or Python required on Windows. Run `set FULL_REBUILD=1` to force a full rebuild.

## Native theorem spine

```lean
RHForward.rh_zero_real_half
RHForward.rh_complexZeroScale_eq
RHForward.RH_TO_FINITE_HAUSDORFF
RHForward.RH_TO_FINITE_MERSENNE
RHForward.RH_TO_FINITE_GRAM
RHForward.RH_TO_FINITE_PACKET_CHAIN
RHForward.checked_rational_all_Hausdorff
RHForward.checked_rational_Gram
```

**Boundary:** The Gram modules prove manifest nonnegative SOS forms and symmetric Hankel entries; a complete native `Matrix.PosSemidef` packaging is not yet included. Each native packet contains a finite number of literal `riemannZeta` zeros with their nontriviality evidence. No theorem here asserts that the packet exhausts the infinite native xi zero divisor. RH gives the critical line for those supplied actual zeros. The abstract positive spectral calculus is unconditional finite mathematics.

## Use

```cmd
cd /d "%USERPROFILE%\Downloads"
tar -xf "SOLOBOLO_CAYLEY_STURM_RH_FORWARD_v0_1_0.zip"
cd SOLOBOLO_CAYLEY_STURM_RH_FORWARD_v0_1_0
run.cmd
```

Return `BUILD_LOG.txt` and `BUILD_STATUS.txt` for the next changed-module-only compiler fix. This source was statically inspected; it was **not** compiled by the assistant.

## Remaining actual-xi work

1. `RH -> Xi zero divisor with all multiplicities and absolute convergence` in native Lean.
2. `actual xi logarithmic derivative = sum over genuine critical zeros`.
3. `infinite positive measure -> all Hankel/Schur positivity`.
4. `rational spectral approximation and coefficient error certificates for actual xi`.
5. **Only thereafter:** finite universal witness checker -> RH, without hypothesis binders or research axioms.
