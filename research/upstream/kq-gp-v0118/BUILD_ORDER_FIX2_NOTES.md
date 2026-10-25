# v0.1.8 FIX2 — missing OLean / stale runner order

The user's last build failed while importing `AllDepth.CayleyPolynomialGerm`
from `KQGPBKQRHilbert.lean`, because no `AllDepth\CayleyPolynomialGerm.olean`
was present. The immediately preceding build of that module had failed, so the
object file had never been generated. The reported newest execution skipped
the polynomial source and went straight to the umbrella import; that ordering
does not match the intended v0.1.8 runner, which compiles it first.

FIX2 explicitly builds `AllDepth\CayleyPolynomialGerm.lean` before the
umbrella module and adds a fail-fast `.olean` presence check. It also includes
the revised FIX1 `CayleyPolynomialGerm.lean` source and the exact matching
umbrella/main modules, so applying a patch is not dependent on an inconsistent
partial update. All other `.lean` files are byte-for-byte identical to FIX1.

**Windows CMD, assuming the original endpoint workspace still exists:**

```bat
cd /d "%USERPROFILE%\Downloads" && tar -xf "KQ_GP_BKQR_HILBERT_SOLOBOLO_POLYNOMIAL_GERM_v0_1_8_FIX2_BUILD_ORDER_PATCH.zip" -C "KQ_GP_BKQR_HILBERT_SOLOBOLO_ENDPOINTS_v0_1_3_FASTCORE_FIX1" && call "KQ_GP_BKQR_HILBERT_SOLOBOLO_ENDPOINTS_v0_1_3_FASTCORE_FIX1\run.cmd"
```

Expected runner banner: `RUNNER_FIX2=DEPENDENCY_FIRST_BUILD_ORDER` and
`BUILD_SEQUENCE_MODULES=39`. Expected line before umbrella compile:
`CAYLEY_POLYNOMIAL_OLEAN=READY`. If `AllDepth\CayleyPolynomialGerm.lean`
produces a new Lean error, that error still needs a separate fix.

**Verification:** Static package/manifest/import-order checks only; no native
Windows Lean compiler is available in this environment. This is a build-system
repair, not a new mathematical theorem.
