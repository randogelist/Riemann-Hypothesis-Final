# v0.1.8 FIX3 — real/complex derivative elaboration

## Root cause (Windows Lean 4.33.0)

The failing hypothesis `hfirst` was elaborated as

```
c 1 = deriv (fun t : ℝ => (t : ℂ) * (xiR t : ℂ)) a
```

which is a derivative of a **complex-valued function**. The local `d : ℝ`
was instead

```
d := deriv (fun t : ℝ => t * xiR t) a
```

The two are mathematically related under differentiability but are not
definitional equal; therefore `have hc : c 1 = (d : ℂ) := hfirst`
failed. FIX2 repaired only the missing-object ordering, not this type error.

FIX3 changes the `hfirst` type to force the **real derivative before coercion**:

```lean
(hfirst : c 1 =
  ((deriv (fun t : ℝ =>
    (t * NativeSoloboloNegativity.xiR t : ℝ)) a : ℝ) : ℂ))
```

This matches the actual `xiWidderBase` definition, whose derivative has
codomain ℝ. The proof's remaining steps and all other theorem statements
are untouched. No new analytic hypothesis, axiom, `sorry`, or RH assertion.
The premise `hfirst` is itself still a **conditional coefficient identity**;
FIX3 does not establish the actual Theta Taylor-germ calibration.

## Apply to the existing Windows build

Put the ZIP in Downloads. From Command Prompt:

```bat
cd /d "%USERPROFILE%\Downloads" && tar -xf "KQ_GP_BKQR_HILBERT_SOLOBOLO_POLYNOMIAL_GERM_v0_1_8_FIX3_REAL_DERIV_PATCH.zip" -C "KQ_GP_BKQR_HILBERT_SOLOBOLO_ENDPOINTS_v0_1_3_FASTCORE_FIX1" && call "KQ_GP_BKQR_HILBERT_SOLOBOLO_ENDPOINTS_v0_1_3_FASTCORE_FIX1\run.cmd"
```

The FIX2 runner should build `AllDepth\CayleyPolynomialGerm.lean`
first, then check `CAYLEY_POLYNOMIAL_OLEAN=READY`, followed by the umbrella
module and `Main.lean`. Prior modules should be reused from your cache.

**Verification**: ZIP integrity, patch locality and unchanged source hashes
passed. Native Lean compilation is not available in the packaging container.
