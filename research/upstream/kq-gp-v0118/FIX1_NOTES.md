# v0.1.6 FIX1 — Windows Lean compilation patch

Native Lean 4.33.0 reported one error in `AllDepth/CayleyTaylorAndPole.lean:179`:
`heq : w * T.geometry.cayleyQ z + 0 = 0` where `w * ... = 0` is required.

## Minimal fix

At line 178, replace

```lean
  simp only [zero_mul, zero_add] at heq
```

with

```lean
  simp only [zero_mul, add_zero] at heq
```

Explanation: `zero_add` reduces `0 + x`; `add_zero` reduces `x + 0`.
After the rewrite the proof receives the exact equality required by
`ne_of_gt (positive_principal_numerator _ _ hq hw)`.

Everything else in the Lean source tree is byte-for-byte identical to v0.1.6.
No conditional theorem premise has been discharged by this patch.
The correction has NOT been compiled in this environment because Lean is not
installed here. Please use the cached offline native Windows runner to verify.

## CMD (patch the already extracted v0.1.6 project in-place)

```bat
cd /d "%USERPROFILE%\Downloads" && tar -xf "KQ_GP_BKQR_HILBERT_SOLOBOLO_ACTUAL_THETA_TAYLOR_POLE_v0_1_6_FIX1_PATCH.zip" -C "KQ_GP_BKQR_HILBERT_SOLOBOLO_ENDPOINTS_v0_1_3_FASTCORE_FIX1" && call "KQ_GP_BKQR_HILBERT_SOLOBOLO_ENDPOINTS_v0_1_3_FASTCORE_FIX1\run.cmd"
```
