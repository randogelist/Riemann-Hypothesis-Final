# v0.1.15 FIX1 — native Lean errors at lines 35, 56 and 60

Only `AllDepth/CayleyRodriguesConvolution.lean` is changed.

1. The coefficient-product simplifier already closes `hmul`; remove the extra `congr 1; omega`.
2. Make the reflected-index bound explicit from `Finset.mem_range`: `k <= n`.
3. Normalize reflected subtractive indices in two separate steps and allow both
   syntactic normal forms `2*n+1` and `1+n*2` for the last coefficient index.

No axioms, `sorry`, proof shortcuts or new hypotheses were added.
No other source file was modified. This is **not native Lean verified**; please
compile on Windows with the existing Lean 4.33.0 Fastcore runner.

Run (after saving FIX1_PATCH.zip in Downloads):

```bat
cd /d "%USERPROFILE%\Downloads" && tar -xf "KQ_GP_BKQR_HILBERT_SOLOBOLO_RODRIGUES_CONVOLUTION_v0_1_15_FIX1_PATCH.zip" -C "KQ_GP_BKQR_HILBERT_SOLOBOLO_ENDPOINTS_v0_1_3_FASTCORE_FIX1" && call "KQ_GP_BKQR_HILBERT_SOLOBOLO_ENDPOINTS_v0_1_3_FASTCORE_FIX1\run.cmd"
```

Expected incremental scope: CayleyRodriguesConvolution, KQGPBKQRHilbert, Main.
Actual Theta Taylor/Rodrigues bridge remains unproved.
