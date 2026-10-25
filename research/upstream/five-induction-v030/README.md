# RH Five Inductions — actual coefficient-defect chain, v0.3.0

This release retains the five conditional induction architectures from v0.2.0
and adds a checked coefficient-defect SOS chain for the **actual** normalized
Riemann zeta function. It does not prove the Riemann hypothesis.

## Run on native Windows

```cmd
cd /d "%USERPROFILE%\Downloads" && tar -xf "RH_FIVE_INDUCTION_LEAN_v0_3_0.zip" && call "RH_FIVE_INDUCTION_LEAN_v0_3_0\run.cmd"
```

The runner uses your existing Lean 4.33.0 and cached Mathlib workspace. It does
not use the network, Lake, Python, PowerShell, WSL, or dependency downloads.
Defaults are the same as the passing v0.2.0 runner. To override paths:

```cmd
run.cmd "C:\path\to\cached-mathlib-workspace" "C:\path\to\lean.exe"
```

Each invocation compiles copied source into a fresh `runs\run_*` directory.
No prebuilt project objects are included in this archive.

## Actual objects

`FiveInduction.HardyActual.J` is defined using Mathlib's actual xi and reciprocal
completed Gamma factor, so its value at zero is regularized without a division
exception. The following are proved:

* `J 0 = 1` and analyticity on the entire open unit disk;
* `J w = w * riemannZeta (1 / (1 - w))` for nonzero w in that disk;
* canonical coefficients `coeff n = iteratedDeriv n J 0 / n!`;
* the actual Taylor series sums to J throughout the disk;
* `coeff 0 = 1` and `coeff 1 = gamma - 1`;
* zero exclusion for J throughout the disk is equivalent to literal Mathlib
  `RiemannHypothesis`.

Set K = log(2*pi) - gamma. The coefficient defect is

```text
p_N(w) = sum_{k=0}^N coeff(k) w^k
T_N    = K - sum_{k=0}^N |coeff(k)|^2
D_N(w) = (1-|w|^2)|p_N(w)|^2 - T_N |w|^(2N+2).
```

The kernel checks the exact identity

```text
D_(N+1)(w) = |w|^2 D_N(w)
           + |(1-|w|^2)p_N(w) + coeff(N+1) w^(N+1)|^2.
```

The correction is also expanded into its two real squares. Positivity persists
at the same point and throughout any already certified disk.

## Main endpoint and the two explicit inputs

```lean
FiveInduction.HardyEndpoint.RH_OF_ACTUAL_HARDY_EXHAUSTION
  (henergy : FiveInduction.HardyActual.ActualHardyEnergy)
  (hexhaust : FiveInduction.HardyEndpoint.ActualDiskExhaustion) :
  RiemannHypothesis
```

1. **Analytic identity still to formalize:**

   `ActualHardyEnergy` means
   `HasSum (fun n => Complex.normSq (coeff n)) K`.

   The preceding paper derivation uses the fractional-part integral, Laguerre
   expansion and Parseval. This release does not formalize that derivation.
   The energy proposition is an explicit theorem argument, not a proved witness.

2. **Open mathematical exhaustion statement:**

   For every 0 < r < 1 there is a finite N such that D_N(w) > 0 for every
   |w| <= r. Under the energy input this is proved equivalent to RH.

The energy identity and the exhaustion statement have different statuses:
the former is an analytic formalization task; the latter is the substantive
remaining RH condition. No placeholder proof or new logical constant is used
to hide either input.

## What the analytic transfer actually proves

Given the coefficient-energy identity, the general Hardy tail estimate is
**derived**, using finite Cauchy-Schwarz, convergent sums and the geometric
series. It is not an additional input.

From it the package proves:

* D_N(w) > 0 implies J(w) is nonzero;
* D_N(w) tends to (1-|w|^2)|J(w)|^2;
* J(w) is nonzero iff some finite defect is positive;
* every compact zero-free subset of the disk has one finite positive-defect
  certificate, by compactness and the nested certificate regions;
* zero exclusion on a closed subdisk is equivalent to its finite certificate;
* disk exhaustion is equivalent to RH.

No separate uniform-convergence or compactness premise remains.

## Base, first extension, and prescribed-radius induction

`HardyConstants.actual_seed_half` proves unconditionally that the actual base
polynomial D_0 is positive on |w| <= 1/2. The transfer of this base certificate
to zero exclusion uses the energy input, as do all defect certificates.

`HardyEndpoint.actual_first_disk_certificate` proves the first extension from
the exact quartic inequality

```text
(1-r^2)(1-u*r)^2 - (K-1-u^2)*r^4 > 0,   u=1-gamma.
```

The actual coefficient calibration is proved. The quartic inequality is an
explicit premise; this release does not certify the numerical radius quoted
in the paper discussion.

For radius(n) = 1 - (1/2)^(n+1), `HardyInduction` proves:

* the initial finite certificate;
* radius(n) tends to 1;
* a prescribed-radius successor rule gives every stage by induction;
* those stages exhaust the disk and imply RH under the energy input.

`PrescribedRadiusStep` is the explicit successor **input** and is proved
equivalent to exhaustion. It is not the same theorem as coefficient-index
positivity preservation. The latter is proved without this input.

## Source map

| Module | Content |
| --- | --- |
| `HardyDefect.lean` | Finite definitions, exact SOS recurrence, positivity induction |
| `HardyTail.lean` | Derived Cauchy-Schwarz tail bound and certificate soundness |
| `HardyCompleteness.lean` | Limit, compact certificates, exhaustion equivalence |
| `HardyActual.lean` | Actual J, canonical coefficients, Taylor identification, RH bridge |
| `HardySeed.lean` | General base and first-degree disk certificate |
| `HardyConstants.lean` | Actual K bounds and radius-1/2 base polynomial |
| `HardyEndpoint.lean` | Actual coefficient-defect endpoint and explicit inputs |
| `HardyInduction.lean` | Prescribed-radius chain and its conditional RH endpoint |

The older five realization inputs remain open. This new construction is not
claimed to discharge the older `SOSXiRealization` or `ProjectionXiRealization`
interfaces. The H2 Gram-matrix projection chain and singular-inner-factor
argument from the paper discussion are not implemented in this release.

## Verification

See `validation/BUILD_STATUS.json`, compile logs, theorem audit, and source
hashes. All eight new modules were compiled individually with Lean 4.33.0 on
Linux. The 19 earlier modules are unchanged from the previously validated
release. A redundant fresh rebuild was interrupted after eight modules because
the shared environment was under heavy memory pressure. The combined Main and
277-theorem Audit checks also could not complete in that environment. No full
v0.3.0 rebuild or combined axiom-audit pass is claimed here.

The native Windows runner rebuilds all 29 modules from source and runs the full
audit for your local replay. This new release has not been executed on Windows
here. The source scan and independent semantic/runner audits passed; there are
no placeholder proofs or custom axiom declarations in the package sources.

A theorem audit listing only `propext`, `Classical.choice`, and `Quot.sound`
checks logical dependencies. It does not remove the explicit hypotheses from
the theorem's type. `Main.lean` prints both new input definitions and endpoints.
