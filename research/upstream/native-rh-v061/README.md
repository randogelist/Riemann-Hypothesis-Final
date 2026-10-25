# GOODWORKFLOWFRONTIER — cached Mathlib FIX1

Project: RH_SOLOBOLO_FINITE_WITNESS_IFF_RH_LEAN_v0_6_1_GOODWORKFLOW_CACHED_MATHLIB_FIX1

The exact 30 Lean source files are byte-for-byte unchanged from v0.6.0.
This release fixes the **Windows cached-Mathlib discovery/startup**, not mathematical proof status.

## Crucial offline cached Mathlib location

The runner now searches, first, for:

`%USERPROFILE%\lean-native\awpi_phi_rh_lean_sieved_v0_1_1\.lake\packages\mathlib\.lake\build\lib\lean\Mathlib.olean`

It also handles `MATHLIB_OLEAN_DIR`, `MATHLIB_CACHE_ROOT`, `LEAN_CACHED_WORKSPACE`,
other known local cached roots and an inherited `LEAN_PATH`. Cached companion
package `.olean` folders under `.lake\packages` are added automatically.
The runner requires `Mathlib.olean` **before attempting any project compilation**.
Missing cache is a preflight discovery failure, never a Lean-proof failure.

No Lake invocation, Mathlib build, network, git, PowerShell, Python, or WSL.
Native Windows Lean **4.33.0** only; direct `lean.exe -j16 -E hasSorry`.

## GOODWORKFLOWFRONTIER freeze-on-PASS

- User compiler is authoritative; there was **no local Lean compilation**.
- Frozen `.olean` reuse requires matching source+direct-dependency+environment fingerprints.
- Only changed/invalidated modules compile; failed staged artifacts never replace a frozen `.olean`.
- Persistent cache: `%USERPROFILE%\Downloads\RH_SOLOBOLO_ADMISSION_CACHE_433`, overridable via `RH_ADMISSION_CACHE`.
- `run.cmd` is the only runner; `run.cmd full` explicitly clears previously frozen cache.
- No global active-Lean-process check or lock imposed on unrelated work.
- Actual output: `reports\result.txt`, `reports\latest.log`.

## Formal theorem scope

The 30 modules express an equivalence between native RH and a **hypothetical
metric admission for the actual-zero-indexed algebraic Cayley modes**.  An
executable Boolean rational-metric positivity check exists, but **it is not a
native RH checker**: the default metric code is accepted independently of RH.
The finite-witness equivalence therefore still has two OPEN interfaces:

```
CheckerSoundness : accepted finite code -> actual native passivity
CheckerCompleteness : RH -> exists accepted finite code
```

No actual GP/Mellin unitary operator calibration is established. The successful
Lean build would check the conditional chain only; no unconditional RH proof.

## One CMD command

```
cd /d "%USERPROFILE%\Downloads" && tar -xf "RH_SOLOBOLO_FINITE_WITNESS_IFF_RH_LEAN_v0_6_1_GOODWORKFLOW_CACHED_MATHLIB_FIX1.zip" && call "RH_SOLOBOLO_FINITE_WITNESS_IFF_RH_LEAN_v0_6_1_GOODWORKFLOW_CACHED_MATHLIB_FIX1\run.cmd"
```
