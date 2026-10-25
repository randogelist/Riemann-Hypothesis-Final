# v0.1.8 FIX1 — real/complex derivative cast

The native v0.1.8 compile reported one unsolved goal in
`AllDepth/CayleyPolynomialGerm.lean` at the last proof.

**Cause:** `push_cast` rewrote the cast of a real derivative into a derivative
of a complex-valued function, leaving a mismatch. This would require an
additional derivative/codomain compatibility theorem, which we do not need
for the first jet: the hypothesis already uses the *real* derivative.

**Repair:** Define `d : ℝ` as that derivative, rewrite using the hypothesis,
then transport only the elementary scalar product through `ℝ → ℂ` using
`norm_cast`. No analytic assumptions were added and the theorem statement
is unchanged. The deprecated polynomial evaluation lemma warning is
harmless and left untouched to minimize patch risk.

**Status:** ZIP/source static validation PASS. Lean 4.33.0 native compilation
has not been executed in this environment; the Windows test must confirm.

## Windows CMD (incremental)

With `KQ_GP_BKQR_HILBERT_SOLOBOLO_POLYNOMIAL_GERM_v0_1_8_FIX1_PATCH.zip`
in Downloads, run:

```bat
cd /d "%USERPROFILE%\Downloads" && tar -xf "KQ_GP_BKQR_HILBERT_SOLOBOLO_POLYNOMIAL_GERM_v0_1_8_FIX1_PATCH.zip" -C "KQ_GP_BKQR_HILBERT_SOLOBOLO_ENDPOINTS_v0_1_3_FASTCORE_FIX1" && call "KQ_GP_BKQR_HILBERT_SOLOBOLO_ENDPOINTS_v0_1_3_FASTCORE_FIX1\run.cmd"
```

Expected incremental work: `CayleyPolynomialGerm.lean`, root module,
`Main.lean` (3 modules); earlier modules reused.

No unconditional RH conclusion follows from this finite-polynomial proof.
