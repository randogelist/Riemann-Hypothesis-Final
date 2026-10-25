# MASTER chain: independent statements

This package fixes the actual Riemann xi objects and places MASTER_1,
MASTER_2, and MASTER_3 in three independent Lean modules. It proves the
connecting implications with all remaining analytic hypotheses visible.

**It does not prove the actual-xi MASTER_1 or MASTER_2 unconditionally, and it
does not prove MASTER_3.** Defining a proposition is not proving it.
The numerical computation is deliberately deferred.

## The three statements

- `MasterChain.MASTER_1`: `c1 = kappa + gpEnergy V`.
- `MasterChain.MASTER_2`: Hardy admissibility, existence of an L2 boundary
  trace `b`, and `C_RR = densityMass = boundaryEnergy b = gpEnergy V`.
- `MasterChain.MASTER_3`: `gpEnergy V = 0` (the unproved vanishing goal).

Each master module imports only `MasterChain.Hardy`, never either of the
other masters. The word independent describes their declarations and import
dependencies; it is not a claim of logical independence of propositions.

## Concrete objects

`xi s = (1 + s*(s-1)*completedRiemannZeta₀ s)/2` is the standard entire xi,
including xi(0)=xi(1)=1/2. The file proves differentiability and xi(1-s)=xi(s).
The scalar `kappa` is the real part of xi''(1/2)/(2 xi(1/2)).

`xiDivisorMeasure` is the canonical measure formed from analytic vanishing
multiplicities and restricted to Im(s)>0. It takes no zero list as an input.
Its equivalence to the distribution (1/(2*pi)) Delta log|xi| is not proved here.
Its definition is not a computational zero-counting algorithm.

Writing d=Re(s)-1/2 and t=Im(s), the definitions are:

```
c1       = integral t^(-2) d(mu_xi)
C_RR     = integral d^2*(3*t^2+d^2)/(t^2*(t^2+d^2)^2) d(mu_xi)
A(v)     = 2*v * integral exp(-t*v)*sin(d*v/2)^2 d(mu_xi)
g(v)     = sqrt(A(v))
V(u)     = integral_(v>0) exp(-(u+1/2)*v)*g(v) dv
```

The actual Hardy energy is independently defined as the supremum, over
epsilon>0, of `(1/(2*pi))*integral |V(-1/2+epsilon+i*y)|^2 dy`.
It is not defined to equal C_RR or the mass of A.
`GPAdmissible` requires holomorphy, line integrability, and bounded energy.
`IsL2BoundaryTrace` requires L2 integrability and convergence from inside the
half-plane, not pointwise substitution at the boundary.

Lean's integrals and real suprema are total operations. `NativeIntegrability`
and `GPAdmissible` therefore remain explicit in the analytic interfaces;
an expression's existence as Lean syntax does not prove convergence.

## What the kernel checks

- Actual-xi normalization, differentiability, and reflection.
- Nonnegativity of the kernels, density, and real readout.
- `V 1 = (scalarReadout : Complex)`.
- For a nonnegative integrable density, a genuine mathlib L2 vector represented
  by its square root, with its existing Hilbert norm squared equal to its mass.
- An integrable positive weighted square-root readout vanishes iff the density
  vanishes almost everywhere; with integrability of the density, iff its mass
  vanishes.
- MASTER_2 follows from `KernelMassIdentity` and `LaplacePlancherel`.
- MASTER_1 follows from these plus `TraceDecomposition`.
- Given the displayed master and integrability hypotheses:
  MASTER_3 iff c1=kappa iff C_RR=0 iff densityMass=0 iff V(1)=0.

The three actual-xi bridge obligations are explicitly declared propositions:

1. `TraceDecomposition`: c1=kappa+C_RR (Hadamard/second-moment trace).
2. `KernelMassIdentity`: C_RR=integral A (Tonelli/Laplace kernel).
3. `LaplacePlancherel`: actual V is Hardy-admissible and its L2 boundary energy
   agrees with both the density mass and its Hardy energy.

No proof terms for these bridges or `NativeIntegrability` are supplied.
They are arguments of the transfer theorems, not axioms or implicit instances.
The classical analytic derivations discussed in the conversation are not
silently counted as completed Lean proofs.

## Native Windows run

Lean 4.33.0 and an existing compatible Mathlib cache are required. The default
cache location is `%USERPROFILE%\lean-native\awpi_phi_rh_lean_sieved_v0_1_1`.

```
cd /d "%USERPROFILE%\Downloads"
tar -xf "RH_MASTER_CHAIN_LEAN_v0_1_0.zip"
call "RH_MASTER_CHAIN_LEAN_v0_1_0\run.cmd"
```

Optional explicit cache:

```
call run.cmd "%USERPROFILE%\lean-native\awpi_phi_rh_lean_sieved_v0_1_1"
```

Set `AWPIRH_LEAN_EXE` to override the native lean.exe, or `MATHLIB_CACHE_ROOT`
to override the cache. The runner builds every local module into a fresh
session directory, checks compiler failures, and runs the mandatory transitive
axiom audit. It uses no network, Lake, Python, PowerShell, or WSL on Windows.

Only the standard logical axioms `propext`, `Classical.choice`, and `Quot.sound`
are accepted. Project axioms and transitive `sorryAx` are rejected. The audit
prints the actual statements and remaining hypotheses.

See `VALIDATION.md` for the build actually performed for this release.
