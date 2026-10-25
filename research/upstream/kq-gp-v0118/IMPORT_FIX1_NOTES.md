# v0.1.7 FIX1 — Lean import ordering

Source change: `KQGPBKQRHilbert.lean` only. The fifth import was placed after
an `/-! ... -/` module doc comment, at line 8; Lean 4 rejected it with
`invalid 'import' command, it must be used in the beginning of the file`.
FIX1 moves all imports before the module documentation. No theorem statement
or proof has changed.

Run against the existing compiled project:

```bat
cd /d "%USERPROFILE%\Downloads" && tar -xf "KQ_GP_BKQR_HILBERT_SOLOBOLO_ACTUAL_THETA_GERM_v0_1_7_FIX1_PATCH.zip" -C "KQ_GP_BKQR_HILBERT_SOLOBOLO_ENDPOINTS_v0_1_3_FASTCORE_FIX1" && call "KQ_GP_BKQR_HILBERT_SOLOBOLO_ENDPOINTS_v0_1_3_FASTCORE_FIX1\run.cmd"
```

Expected next local modules: `KQGPBKQRHilbert.lean` and `Main.lean`.
The 2 new v0.1.7 modules `AllDepth/SymmetricCayleyGerm.lean` and
`AllDepth/ActualMathlibThetaInterface.lean` have already passed according to
user's Windows compiler output.

Static verification only: environment here has no Lean compiler. All other
Lean source files are unchanged; ZIP integrity checked.
The actual theta Taylor-germ and RH inputs remain conditional.
