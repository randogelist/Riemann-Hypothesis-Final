# WITNESS × SOLOBOLO × RH-FINAL × ODD_ZETA × GP–KQ–BKQR–XY × ZETA_HYPERBOLIC

## v0.5.0 — Sharp all-anchor debit and actual-xi Widder frontier

**Uncompiled Lean source.** Native Windows Lean 4.33.0 is the user's sole compiler authority. No Lean compiler, Lean runner, or theorem tactic was run to certify this source here.

### Modules

- **26 byte-preserved v0.4.0 Lean modules**. Reuse a previously validated `.olean` only if its source, Mathlib/Lean environment and dependencies match. No module counts as verified solely because it was in a previous ZIP.
- **8 new modules** (34 total):
  - `FiniteWitness/SharpAnchorMass.lean`: exact sharper anchor scale `max(1,b/a)` and universal Cayley-power mass bound.
  - `FiniteWitness/AllAnchorDebit.lean`: transported Cayley debit = sum of weighted squares, positivity, exact telescope, total debit bound.
  - `FiniteWitness/CheckedDebitBudget.lean`: an actually accepted finite algebra certificate entails all-layer, all-anchor sharp debit budgets; no xi calibration.
  - `FiniteWitness/MatchedAmplification.lean`: exact modulus formula at an off-line spectral channel; matched-radius maximum and strict >1 for off-line displacement.
  - `FiniteWitness/RealAnchorMass.lean`: lift rational finite atoms to **arbitrary real** positive target anchors; mass budget independent of layer rank and depth.
  - `Bridge/NativeWidderTrace.lean`: actual completed-xi logarithmic jets and the correct centered Widder combination; separate actual-trace calibration proposition.
  - `Bridge/ActualTraceEndpoint.lean`: native-RH implication from actual calibration plus a separately stated off-line spectral-explosion theorem. Does **not** supply those analytic inputs.
  - `WitnessMainV05.lean`: exports `#check` and selected `#print axioms` for source inspection.

### Main identities

For `0 < a,b`, `0 ≤ t ≤ 1`:

\[
 u_b=\frac{bt}{a+(b-a)t},\qquad
 q_b=4u_b(1-u_b),\qquad
 0\le q_b\le1,\qquad
 u_b\le \max(1,b/a)t.
\]

For the SAME finite spectrum \(t_i\) at every depth:

\[
 T_p(b)=\sum_i q_b(t_i)^{p+1},\quad
 \Delta_p(b)=T_p(b)-T_{p+1}(b)
 =\sum_i q_b(t_i)^{p+1}(1-2u_b(t_i))^2\ge0.
\]

\[
 0\le\sum_{p<m}\Delta_p(b)=T_0(b)-T_m(b)
 \le 4\max(1,b/a)\sum_i t_i.
\]

For \(\rho=\tfrac12+\beta+i\gamma\), \(\gamma\ne0\), set \(L=\beta^2+\gamma^2\). Then

\[
 |q_a((\gamma-i\beta)^2)|=
 \frac{4aL}{(a-L)^2+4a\gamma^2}
 \le\frac{L}{\gamma^2},\quad
 \text{equality at }a=L,
 \quad \frac{L}{\gamma^2}>1\ (\beta\ne0).
\]

### Native endpoint and still-open arguments

`Bridge.ActualTraceEndpoint.CONDITIONAL_RH_OF_SOLOBOLO_WITNESS` states:

```lean
(check : FiniteWitness → Bool)
(hSound : ACTUAL_TRACE_CHECKER_SOUNDNESS check)
(hPole : OFFLINE_WIDDER_EXPLOSION_FRONTIER)
(w : FiniteWitness) (hw : check w = true) :
  _root_.RiemannHypothesis
```

Neither `hSound` nor `hPole` is constructed unconditionally in v0.5. In particular, a sample checked rational model is **not** a proof of RH. The previous cofinal-complex-Hurwitz route remains available in frozen modules, but this native Widder endpoint does not require Hurwitz when the two displayed inputs are established.

### Windows run

```bat
cd /d "%USERPROFILE%\Downloads"
tar -xf WITNESS_SOLOBOLO_NATIVE_LEAN_v0_5_0.zip
cd WITNESS_SOLOBOLO_NATIVE_LEAN_v0_5_0
run.cmd
```

The runner retains the shared `WITNESS_SOLOBOLO_SHARED_CACHE`, compiling only new, edited or invalidated modules if the previous compiler artifacts are valid, and writes `BUILD_LOG.txt` plus `BUILD_STATUS.txt`. Force all with `set FULL_REBUILD=1` before `run.cmd`. No network, PowerShell, Python, WSL, or Lake update is used in the Windows runner.

**WITNESS_READY=NO**: checker-to-actual-xi soundness and the actual off-line pole theorem must be formalized and tested.
