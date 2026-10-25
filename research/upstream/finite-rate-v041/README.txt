SOLOBOLO FINITE WITNESS <-> RH -- Lean v0.4.1 GOODWORKFLOWFRONTIER CACHED MATHLIB comparison

Goal (NOT yet proven):
  (exists w : FiniteCode, genuine_actual_xi_check w = true) <-> ActualRiemannHypothesis.

Unchanged from v0.3: 18 Lean modules, byte for byte.
New: 9 modules, including a concrete terminating rational packet *syntax* checker,
all-depth geometric induction, a semantic rate-envelope iff theorem with explicit
analytic inputs, a boundary counterexample and axiom audit.

IMPORTANT:
  ratePacketCheck verifies only a rational number's nonnegativity.
  It is NOT an RH checker. FiniteRateBoundary explicitly proves this.
  SemanticallyAcceptedRatePacket contains a universal mathematical hypothesis.
  A genuine finite checker needs an independent, proved actual-xi soundness
  theorem, plus reverse witness completeness under RH.

Workflow compared with GOODWORKFLOWFRONTIER:
  - Native Lean 4.33.0, direct lean.exe -j16, LEAN_NUM_THREADS=16
  - Precompiled Mathlib .olean root, no Lake/build/download/network
  - One ZIP with exactly one run.cmd, and one copyable CMD launch command
  - PASS-ONCE: dependency/environment/source SHA256 keys, staged oleans
  - Reuse legacy v0.3 PASS only after environment, source and log match
  - Frozen unchanged olean skipped; new/modified or affected modules rebuilt
  - Fail fast, isolated logs, Lean -E hasSorry and sorryAx checks
  - Axiom audit is via explicit #print axioms statements in modules
  - No local Lean compilation; user's compiler is authority

GOODWORKFLOWFRONTIER native witness trigger comparison:
  Native search output is untrusted until ingested and reverified in Lean.
  A solver saying PASS is not the proof and cannot close checker soundness.
  RH witness acceptance requires actual-source calibration and universal
  all-order propagation theorem, not merely finite-prefix numerical success.

USER RUN (CMD):
  cd /d "%USERPROFILE%\Downloads" && tar -xf "SOLOBOLO_FINITE_WITNESS_IFF_RH_LEAN_v0_4_1_GOODWORKFLOWFRONTIER_CACHED_MATHLIB.zip" && call "SOLOBOLO_FINITE_WITNESS_IFF_RH_LEAN_v0_4_1_GOODWORKFLOWFRONTIER_CACHED_MATHLIB\run.cmd"

Optional: call run.cmd full (intentionally invalidates the frozen cache).

CACHED MATHLIB FIX v0.4.1:
  - Resolves prior native project including nested .lake\packages\mathlib\.lake\build\lib\lean\Mathlib.olean
  - Includes all cached package .olean directories in LEAN_PATH, no Lake or downloads.
  - Accepts MATHLIB_OLEAN_DIR, MATHLIB_CACHE_ROOT, MATHLIB_LEAN_PATH, CACHE_BASE, or an optional project path.
  - Uses exact same 27 Lean source files as v0.4.0; only runner and docs changed.
  - MATHLIB_CACHE=READY is printed only after finding Mathlib.olean.
