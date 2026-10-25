# ALL-DEPTH SUBEXPONENTIAL CAYLEY FRONTIER — FASTCORE v0.1.4

A **source-preserving** extension of the user's verified native-Windows SOLOBOLO endpoint project (`v0.1.3_FIX1`, 27/27 `RUN PASS`). Includes:

- **Unmodified** `RH_NATIVE_SOLOBOLO_MERGER05_EXPLICIT_CAYLEY_TRACE_v0_23_0` modules.
- **Unmodified** GP/BKQR v0.18.3 endpoint modules **and** four inherited Cayley-geometry/pole modules.
- Three **new** all-depth modules: `SubexpEnvelope`, `FiniteHausdorff`, `ActualPoleClosure`.
- `KQGPBKQRHilbert/InputEndpoints.lean` and `TargetInterfaces.lean` for compatibility with the existing project.

## Fast incremental patch (recommended)

Place `KQ_GP_BKQR_HILBERT_SOLOBOLO_ALL_DEPTH_v0_1_4_PATCH.zip` in Downloads, then paste this in **CMD**:

```bat
cd /d "%USERPROFILE%\Downloads" && tar -xf "KQ_GP_BKQR_HILBERT_SOLOBOLO_ALL_DEPTH_v0_1_4_PATCH.zip" -C "KQ_GP_BKQR_HILBERT_SOLOBOLO_ENDPOINTS_v0_1_3_FASTCORE_FIX1" && call "KQ_GP_BKQR_HILBERT_SOLOBOLO_ENDPOINTS_v0_1_3_FASTCORE_FIX1
un.cmd"
```

**What it does:** updates the runner (`run.cmd` and `compile_one.cmd`), build order, root imports, Main, and documentation; it adds seven inherited/new geometry and all-depth modules. It preserves all 25 earlier baseline modules and their `.olean`/snapshot state; the runner should reuse them when the environment is unchanged. The first run should compile 9 modules (7 new + 2 modified), not all 34.

## Full standalone package

Alternatively, place the full zip in Downloads and run:

```bat
cd /d "%USERPROFILE%\Downloads" && tar -xf "KQ_GP_BKQR_HILBERT_SOLOBOLO_ALL_DEPTH_v0_1_4_FASTCORE.zip" && call "KQ_GP_BKQR_HILBERT_SOLOBOLO_ALL_DEPTH_v0_1_4_FASTCORE
un.cmd"
```

The standalone package compiles 34 modules (27 baseline positions + 7 new). Requires the existing Lean 4.33.0 and Mathlib cache; no Lake, network, PowerShell, Python, WSL or Git at runtime.

## Mathematics and proof status

See [`ALL_DEPTH_PROOF_FRONTIER.md`](ALL_DEPTH_PROOF_FRONTIER.md).

- **Proved in inherited Lean sources:** abstract off-line zero ⇒ `q>1`, interior Cayley radius and an interior `none` of actual Theta observable (given genuine `CenteredThetaData`). Actual direct/recursive Widder equality on regular anchors; finite BKQR nonnegativity.
- **New Lean proofs (not yet native compiled):** all-depth finite Hausdorff identity/positivity, contradiction between all-depth subexponential envelope and canonical pole-growth witness, conditional actual RH closure via actual-ξ geometry coverage, and all-depth positivity variant using the inherited channel-analysis theorem.
- **Unproved analytic requirements:** `ActualXiSubexponential`, `CanonicalPoleGrowth` or `ActualThetaSubexpRegularity`, and `ActualXiZeroCoverage` for a concrete actual-ξ geometry. None is asserted as an axiom, a theorem, or silently instantiated.

**Important:** This packaging environment has no Lean toolchain and therefore has not newly kernel-checked the extension. Your prior build log established `PASS` only for the original 27-module endpoint baseline. Please run the Windows CMD command and send the full output for any corrections.


## v0.1.5 power-series root-test extension

`AllDepth/PowerSeriesRootTest.lean` proves (subject to successful native Lean compile):

1. `subexp_radial_absolute_summable`: for `SubexponentialAt W a` and
   any real `0 <= r < 1`, the radial coefficient absolute series is summable; the same
   holds for the complex series at every `‖z‖<1`.
   This is a genuine analytical consequence of the all-depth estimate,
   using a comparison with a convergent geometric series.
2. `superunit_lower_bound_forces_growth`: a strictly superunit
   geometric contribution that truly dominates the coefficient magnitudes
   violates weaker exponential envelopes.
3. `domination_implies_canonical_pole_growth`: makes precise the
   extra `OffLineChannelDomination` condition needed to turn those toy
   channel bounds into the actual SOLOBOLO growth predicate.

The **unproved** actual zero-channel noncancellation and actual-Theta
Taylor-series identification are deliberately not hidden.

### Run the small patch (fast incremental)

With the patch ZIP placed in Downloads, use Windows **CMD**:

```bat
cd /d "%USERPROFILE%\Downloads" && tar -xf "KQ_GP_BKQR_HILBERT_SOLOBOLO_ALL_DEPTH_v0_1_5_ROOTTEST_PATCH.zip" -C "KQ_GP_BKQR_HILBERT_SOLOBOLO_ENDPOINTS_v0_1_3_FASTCORE_FIX1" && call "KQ_GP_BKQR_HILBERT_SOLOBOLO_ENDPOINTS_v0_1_3_FASTCORE_FIX1\run.cmd"
```

No network or Mathlib re-download. All earlier source modules unchanged.
The newly added Lean theorem source was not compiled in this environment.


## v0.1.6 All-depth actual Theta Taylor/pole extension

See `TAYLOR_POLE_PROOF_FRONTIER.md`. Adds a finite Cayley Taylor remainder, a positive pole residue algebra lemma, and distinct *unproved* analytic Taylor-germ/pole-crossing targets. No original input proof was changed.

FIX1: single `zero_add` -> `add_zero` proof-script correction; see `FIX1_NOTES.md`.


## v0.1.7 — Root-free genuine Theta germ

See `ACTUAL_THETA_GERM_FRONTIER.md`. Two new Lean modules, unmodified original endpoints, no added axioms or sorry. The B1 actual Mathlib xi Taylor germ is an explicit unproved target.

## v0.1.8 finite radius-polynomial extension

See `CAYLEY_POLYNOMIAL_GERM_FRONTIER.md`. The added Lean proof module
`AllDepth/CayleyPolynomialGerm.lean` is **pending native compilation**.

## v0.1.8 FIX2 (runner order)

Includes `run.cmd` with a `CayleyPolynomialGerm.olean` dependency precheck. See `BUILD_ORDER_FIX2_NOTES.md`.


## FIX3 (real-derivative elaboration)

See `REAL_DERIV_FIX3_NOTES.md`. The first derivative coefficient hypothesis
now explicitly casts a **real** derivative to `ℂ`; Lean must not infer a
complex-valued derivative. The actual-Theta coefficient premise is still
conditional and not automatically supplied.


See `FIX4_NOTES.md` for direct-import and forced local rebuild.

## v0.1.9 addition

`AllDepth/CayleyCoefficientAtlas.lean` proves the universal finite coefficient extraction and finite entire complex-radius continuation. It does not prove the infinite actual-Theta germ. See `COEFFICIENT_ATLAS_PROOF_FRONTIER.md`. The pinned cached Windows native runner includes the new module in dependency order.

## v0.1.10 stable coefficient extension

New `AllDepth/CayleyStableCoefficients.lean`: proves that `[r^n]` of the
finite Cayley jet stabilizes once `N>=2*n+1`, without RH or assuming a
full infinite Taylor identity. Details in `STABLE_COEFFICIENTS_PROOF_FRONTIER.md`.

The new module requires native Lean compilation; previous build PASS remains
valid for the existing 40 modules only.


## v0.1.11 Pascal triangle
See `BINOMIAL_TRIANGLE_FRONTIER.md`; native compilation pending.

## v0.1.12 — Cayley top diagonal

Introduces `AllDepth/CayleyTopDiagonal.lean`. The all-depth top-diagonal
condition from v0.1.11 is targeted by simultaneous induction on leading
coefficients and upper support. Source algebra is in `TOP_DIAGONAL_PROOF_FRONTIER.md`.
This is not yet native Lean verified. Use `run.cmd` for an incremental build.

## v0.1.13: closed finite all-depth binomial atlas

Added `AllDepth/CayleyFiniteClosedFormula.lean`, imported by umbrella root.
Four theorem declarations; first two contain the new all-depth closed
coefficient bridge. Existing Lean sources are byte-identical to v0.1.12
except for umbrella import, Main checks, and new file.

**Windows:** apply PATCH.zip into the existing v0.1.3 FASTCORE directory
and run `run.cmd`; it uses your previous Mathlib cache.
No native compilation performed by the packaging environment.

## v0.1.15 update
See `RODRIGUES_CONVOLUTION_FRONTIER.md`; current source adds the all-depth polynomial coefficient convolution.

## v0.1.16 local polynomial jet interpolation

See `JET_INTERPOLATION_FRONTIER.md`. All inherited v0.1.15 Lean sources are unchanged; native compilation of this new patch remains pending.

## v0.1.17 Actual xi real Leibniz patch

`AllDepth/ActualXiRealLeibniz.lean` adds four proposed Lean theorems for
the ordinary real analytic derivative of the **actual** xiR function;
no replacement of the original Widder definition. It leaves the
factorial/binomial reindexing and complex analytic germ separate.
See `REAL_LEIBNIZ_FRONTIER.md`.

## v0.1.18 - real Rodrigues normalization (native compile pending)

Adds `AllDepth/ActualXiRealRodriguesNormalization.lean` with the
integer factorial identity, real normalization and `ActualXiRealRodriguesCompatibility`
bridge. This is the *real* finite-jet compatibility only, not the actual
*complex* Theta Taylor germ, pole continuation, any uniform subexponential
estimate, or RH.

Use the incremental run script from the established Windows project.
