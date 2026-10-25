# v0.1.6 — Actual Θ Taylor / pole bridge

**Goal:** replace the `2^k`-restricted trace interface with the actual all-depth Cayley Taylor generating function and a genuine nonremovable pole argument.

### Proved at source level, pending native Lean compilation

For arbitrary real `q,r` and every `n`, the finite Cayley polynomial recursively defined by

\[P_0=q,\qquad P_{n+1}=q+rqP_n\]

obeys the exact **finite remainder** identity

\[(1-rq)P_n=q-q(rq)^{n+1},\]
\[\frac q{1-rq}=P_n+\frac{q(rq)^{n+1}}{1-rq}\quad(1-rq\ne0).\]

At `r=1/q` and `q>0`, \(P_n=(n+1)q\); for `w>0`, the numerator `w*q>0` cannot be canceled by any **finite** regular remainder in an equality after multiplying by `(1-rq)` and evaluating at `r=1/q`.

These are source theorems `cayleyPartial_denominator`, `cayley_geometric_remainder`, `cayleyPartial_at_reciprocal`, and `positive_pole_cannot_be_cross_multiplied`.

### Not proved (critical obligations)

- **B1:** `ActualXiTaylorGerm T`. Identify the actual `Theta'/Theta` Cayley divided difference with the actual `xiWidderMoment` generating series on a small positive radius. This requires explicitly regularizing `r=0`, so it cannot be obtained by evaluating the existing `Option` definition at `0`.
- **B2:** `ActualXiPoleCrossing T`. Continue the germ across the punctured Cayley disk, obtain an actual Laurent factor with **positive nonzero residue**, and pass the cross-multiplied identity to the canonical interior radius. `Option.none` at a zero is not alone sufficient to establish this analytic singularity.
- **A:** `ActualXiSubexponential` independently from KQ/GP/BKQR-Hilbert and the other anchors.
- **C:** `ActualXiZeroCoverage T.geometry` for all actual nontrivial zeros.

### Certified logical closure (conditional)

\[A+B2+C \Longrightarrow \mathrm{RH}.\]

B1 is an analytic component of a future proof of B2, **not** automatically implied by the other endpoints. No direct positive spectral representation of \(\xi\), no axiom and no `sorry` has been added.

### Native Windows fast patch

Copy `KQ_GP_BKQR_HILBERT_SOLOBOLO_ACTUAL_THETA_TAYLOR_POLE_v0_1_6_PATCH.zip` into Downloads, then from Command Prompt:

```bat
cd /d "%USERPROFILE%\Downloads" && tar -xf "KQ_GP_BKQR_HILBERT_SOLOBOLO_ACTUAL_THETA_TAYLOR_POLE_v0_1_6_PATCH.zip" -C "KQ_GP_BKQR_HILBERT_SOLOBOLO_ENDPOINTS_v0_1_3_FASTCORE_FIX1" && call "KQ_GP_BKQR_HILBERT_SOLOBOLO_ENDPOINTS_v0_1_3_FASTCORE_FIX1\run.cmd"
```

The patch assumes your previous v0.1.5 FIX1 files are **already installed** in the `v0_1_3_FASTCORE_FIX1` working folder. The only new/changed Lean files are the new `AllDepth/CayleyTaylorAndPole.lean`, `KQGPBKQRHilbert.lean`, and `Main.lean`. Expected incremental work: 33 reused, 3 compiled. Because no native Lean compiler is installed in this authoring environment, this is an **expected**, not verified, native outcome.
