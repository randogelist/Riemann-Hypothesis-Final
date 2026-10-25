# v0.1.8 FIX4 — direct import and stale export cache invalidation

The user-provided Windows log indicates the root build reached `Main.lean`,
but `Main.lean` could not resolve five polynomial-germ declarations.
All those declarations appear in `AllDepth/CayleyPolynomialGerm.lean` in
FIX3 under `namespace KQGPBKQRHilbert.AllDepth`.

The precise cause cannot be settled without the missing `COMPILE=...` lines
from the current Windows run. The repair is conservative:

1. Add a direct `import AllDepth.CayleyPolynomialGerm` at the start of `Main.lean`.
2. Reaffirm `KQGPBKQRHilbert.lean` imports the same module.
3. Include the exact FIX3 `CayleyPolynomialGerm.lean` as the source of truth.
4. Force-rebuild only the polynomial module, umbrella, and Main by deleting
   their **local** `.olean` and corresponding incremental source snapshots.
5. Run an independent direct-import export check after a successful build.

No inherited theorem or proof is modified, no axiom/sorry is added, and no
analytic RH obligation is discharged.

## Copyable CMD

Unzip the patch over the existing fast project and call the targeted rebuild:

```bat
cd /d "%USERPROFILE%\Downloads" && tar -xf "KQ_GP_BKQR_HILBERT_SOLOBOLO_POLYNOMIAL_GERM_v0_1_8_FIX4_EXPORT_PATCH.zip" -C "KQ_GP_BKQR_HILBERT_SOLOBOLO_ENDPOINTS_v0_1_3_FASTCORE_FIX1" && call "KQ_GP_BKQR_HILBERT_SOLOBOLO_ENDPOINTS_v0_1_3_FASTCORE_FIX1\FIX4_REBUILD.cmd"
```

**Expected:** older modules reused, three modules recompiled, `RUN=PASS`
then `FIX4_DIRECT_IMPORT_CHECK=PASS`. This is still unverified on Windows
until the native compiler runs.
