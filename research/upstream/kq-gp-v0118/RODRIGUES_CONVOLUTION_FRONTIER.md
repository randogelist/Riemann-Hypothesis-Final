# v0.1.15: the polynomial Rodrigues convolution frontier

**Base:** Native Lean PASS reported by user for v0.1.14, 45 compiled modules.

## New mathlib-based argument

Put Q(X) = Taylor_a(P)(X). Then

    [X^(2n+1)] ((X+a)^n Q(X))
      = sum_{k=0}^n choose(n,k) a^k [X^(n+k+1)] Q(X).

We use `Polynomial.coeff_mul`, `Polynomial.coeff_X_add_C_pow`,
`Finset.Nat.sum_antidiagonal_eq_sum_range_succ_mk`,
`Finset.sum_range_add` and `Finset.sum_range_reflect`.

This is independent of RH, analytic continuation, and any infinite Xi
moment representation. It discharges the *polynomial* proposition
`PolynomialRodriguesConvolution` from v0.1.14, if the Lean proof compiles.

The corresponding arbitrary finite-jet coefficient follows by the
already compiled stable coefficient and finite closed-form theorems.

## Still open (not assumed or claimed)

- Actual analytic Theta Taylor-germ convergence and its derivative coefficients.
- Complex-to-real derivatives of the actual real `xiR`.
- Off-line actual-Xi pole transfer and zero coverage.
- Independent uniform subexponential estimates; unconditional RH.

## Windows native command

Place the patch ZIP in Downloads. Execute in CMD:

```bat
cd /d "%USERPROFILE%\Downloads" && tar -xf "KQ_GP_BKQR_HILBERT_SOLOBOLO_RODRIGUES_CONVOLUTION_v0_1_15_PATCH.zip" -C "KQ_GP_BKQR_HILBERT_SOLOBOLO_ENDPOINTS_v0_1_3_FASTCORE_FIX1" && call "KQ_GP_BKQR_HILBERT_SOLOBOLO_ENDPOINTS_v0_1_3_FASTCORE_FIX1\run.cmd"
```

Expected (if cache is intact): 43 modules reused, 3 compiled.
**Native Lean 4.33.0 compile of v0.1.15 is unverified here.**
