# FIX2: complete the fresh compiled import directory

FIX1's Windows runner created a fresh `build\MasterChain` directory and put it
before the baseline on `LEAN_PATH`. Lean 4.33 resolves the first matching root
directory for a namespace, then looks for all its submodules there. It therefore
did not fall back to the baseline for `MasterChain.AnalyticBridges`.

This was a runner import-path error. FIX2 copies exactly eighteen verified,
unchanged compiled modules into the fresh build directory before compiling.
Each copy must succeed, be nonempty, and pass a binary comparison with its
baseline source. The three affected source modules and Audit are rebuilt into
the same directory. The original passing baseline is not modified.

The corrected KernelMass and Audit sources from FIX1 are included unchanged,
so this patch is cumulative when applied over version 0.2.0.

```bat
cd /d "%USERPROFILE%\Downloads"
tar -xf "RH_MASTER3_COMPUTATION_LEAN_v0_2_0_FIX2.zip"
call "RH_MASTER3_COMPUTATION_LEAN_v0_2_0\resume_kernel_audit.cmd" ".native-runs\run_12464_11771"
```

Use the original successful baseline shown above. The failed `kernel_fix1_*`
session is not a valid baseline.

Expected progress includes

```text
REUSED_COMPILED_SOURCE_COUNT=18
MATERIALIZED_COMPILED_SOURCE_COUNT=18
NATIVE_L2_SIGNATURE=ONE_EXPLICIT_MOMENT_INPUT
PROJECT_DECLARATIONS_AUDITED=277
MASTER3_COMPUTATION_AXIOM_AUDIT=PASS
RUN=PASS
```

Validation reproduced the missing-object error with an empty first namespace
directory using the installed Linux Lean 4.33.0. Copying the same eighteen
dependencies then allowed KernelMass, FiniteHeightCertificates,
Master3Computation, and Audit to compile successfully with full kernel checking.
The audit accepted only `propext`, `Classical.choice`, and `Quot.sound`.

Logs and source hashes are in `validation/fix2/`. The Windows batch file was
statically reviewed; it was not executed in the Linux validation environment.
The user's Windows runner needs no network, Lake, Python, PowerShell, or WSL.
