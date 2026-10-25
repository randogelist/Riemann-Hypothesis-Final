# Recovered actual RH equivalences

Two additional analytic criteria now have complete project source chains in the full build. Their targets are literal Mathlib `_root_.RiemannHypothesis`; neither iff has an extra research hypothesis. **Native compilation and axiom audits are `NOT_RUN`.** Complete source and an audit plan are not a verified build.

These criteria supplement the [original source catalogue](../RH-Equivalences/README.md), which preserves 41 native-target formulations and 10 separately classified model formulations. The original E/M identifiers and historical evidence remain unchanged. Exact unchanged-source hashes are recorded in [recovered-analytic-sources.json](../provenance/recovered-analytic-sources.json). The additions below are related analytic formulations, not claims of new independent mechanisms or literature priority.

## Slit-plane ODE admission

[SoloboloAdmission/NativeODE.lean](../SoloboloAdmission/NativeODE.lean) defines

```lean
def SlitODEAdmission : Prop :=
  ∃ A : ℂ → ℂ,
    AnalyticOnNhd ℂ A Complex.slitPlane ∧
      ∀ z ∈ Complex.slitPlane,
        deriv AWPIRH.theta z + A z * AWPIRH.theta z = 0
```

Its endpoint is

```lean
theorem SoloboloAdmission.slitODEAdmission_iff_RH :
  SoloboloAdmission.SlitODEAdmission ↔ _root_.RiemannHypothesis
```

The function is the actual entire descent

\[
\Theta(z)=\xi(1/2+\sqrt z),\qquad
\xi(s)=\frac{1+s(s-1)\operatorname{completedRiemannZeta}_0(s)}2.
\]

RH excludes theta zeros on the slit plane, so `A=−Θ′/Θ` is holomorphic there and satisfies the ODE. Conversely, the source proves that an entire function nonzero at 1 cannot have a zero where it satisfies a holomorphic first-order ODE. The actual theta zero-geometry equivalence then gives native RH. The coefficient's existence is the criterion to be constructed; the iff does not construct it without RH.

The coherent project closure consists of five original source modules:

| Module | Role |
|---|---|
| [AWPIRH.XiCore](../AWPIRH/XiCore.lean) | Actual xi, reflection, nontrivial-zero binding and nonzero theta anchor |
| [AWPIRH.ThetaEntire](../AWPIRH/ThetaEntire.lean) | Entire square descent, including the branch point |
| [AngularMaster.ZeroGeometry](../AngularMaster/ZeroGeometry.lean) | Actual theta zero geometry iff native RH |
| [AWPIRH.AnalyticODE](../AWPIRH/AnalyticODE.lean) | Generic analytic ODE nonvanishing tools |
| [SoloboloAdmission.NativeODE](../SoloboloAdmission/NativeODE.lean) | Actual slit-plane ODE iff native RH |

The [analytic publication audit](../AnalyticPublicationAudit.lean) checks the native target and lists 50 local named declarations for axiom reporting. The endpoint source also prints its own axiom dependencies. None of these commands has been executed in this publication.

## Analytic reciprocal of the actual Cayley zeta function

[SoloAdmission/AnalyticInverse.lean](../SoloAdmission/AnalyticInverse.lean) defines

```lean
def AnalyticReciprocalAdmission : Prop :=
  ∃ u : ℂ → ℂ,
    DifferentiableOn ℂ u CayleyBridge.unitDisk ∧
    ∀ w : ℂ, w ∈ CayleyBridge.unitDisk → HardyActual.J w * u w = 1
```

The exact endpoint is

```lean
theorem SoloAdmission.ANALYTIC_ADMISSION_IFF_RH :
  SoloAdmission.AnalyticReciprocalAdmission ↔ _root_.RiemannHypothesis
```

`J` is the regularized actual function

\[
J(w)=2\xi\!\left(\frac1{1-w}\right)(1-w)^2
       \Gamma_{\mathbb R}\!\left(\frac1{1-w}\right)^{-1}.
\]

It has `J(0)=1`. Away from zero in the unit disk, it agrees with `w·ζ(1/(1−w))`; that raw product must not replace the regularized value at zero. A reciprocal excludes zeros of J. Conversely, RH gives nonvanishing and the source constructs the holomorphic reciprocal `J⁻¹`.

Its four-module project closure is [FiveInduction.ActualXi](../FiveInduction/ActualXi.lean), [FiveInduction.CayleyBridge](../FiveInduction/CayleyBridge.lean), [FiveInduction.HardyActual](../FiveInduction/HardyActual.lean), and [SoloAdmission.AnalyticInverse](../SoloAdmission/AnalyticInverse.lean). The first three were already preserved archivally; they are now also at the module paths needed by the full build. The [reciprocal audit](../ReciprocalAudit.lean) has an explicit native-target type check and 11 axiom-report targets.

`HardyActual.ActualHardyEnergy` is defined in the source but is not a hypothesis or dependency of this iff proof. The separate conditional Hardy exhaustion route still needs that input.

## Source, execution and verification status

| Item | Status |
|---|---|
| Exact actual-object definitions and local proof bodies | Present |
| Complete project imports for the two analytic iff endpoints | Present |
| Lean version | `leanprover/lean4:v4.33.0` |
| External Mathlib | Compatible existing cache required; identified and fingerprinted by the native runner |
| Planned compilation | Included in [`build-modules-full.txt`](../build-modules-full.txt) |
| Native compilation / kernel axiom reports | `NOT_RUN` |
| An analytic admission constructed without RH | Not supplied |
| Finite raw witness with an accepted actual-RH checker | Not supplied |

Run `run.cmd full` with the cached Mathlib path as described in [BUILD.md](BUILD.md). A pass must be tied to the exact source, resolved imports, compiler and cache fingerprints, and axiom reports must satisfy the repository allow-list. Historical prepare logs and archived objects do not admit this assembled graph automatically.

The [single actual-calibration condition](ACTUAL_CONDITION.md) explains how one finite program with a locally uniform actual residual bound gives slit-plane zero exclusion, without assuming a limit coefficient. The [frontier](FRONTIER.md) keeps its universal analytic requirement, concrete checker soundness, and RH-to-code completeness visible. The normalized theta product and central coefficient strategies are additional implementation work; they are not imported as completed finite reductions.

This repository makes no claim that ordinary RH implies GRH. The separately published Dirichlet project retains that transfer as an explicit open condition.
