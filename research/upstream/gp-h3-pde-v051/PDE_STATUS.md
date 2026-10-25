# GRAND MERGE v0.5.1 — Cayley kernel PDE

**Additive patch only.** All 46 formerly validated Lean modules are unchanged.

New mathematical identities:

1. Exact polynomial cleared-denominator form of the Cayley kernel PDE.
2. Uniqueness of the all-depth `widderStep` recurrence from its depth-zero value.

These new theorems are **not native-Lean-verified in this environment**.

To discharge H3, prove:

- On a regular anchor, the literal actual-Theta Cayley logarithmic derivative satisfies the kernel PDE (complex-to-real differentiation / analytic transfer).
- Its depth-zero value equals `NativeSoloboloNegativity.xiWidderBase`.
- The actual regularized Cayley germ exists at radius 0, and its Taylor coefficients inherit the PDE.
- The off-line actual determinant zero forces the radius-of-convergence growth of that germ, with a regular anchor choice (including a possible zero real height).

H3 and H2 remain unproved. No spectral representation of actual xi required.
