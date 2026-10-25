# v0.1.14 polynomial Rodrigues bridge

- Compiled baseline reported by user: 44 modules PASS (v0.1.13).
- New module: `AllDepth/CayleyPolynomialRodrigues.lean`.
- Fast native Windows runner unchanged in architecture: Lean 4.33.0,
  cached Mathlib, incremental .olean reuse, no network or Lake.
- The local closed-form coefficient formula is inherited and preserved.
- Adds polynomial Taylor/Hasse normalization and its zero-depth agreement.
- **Not proved**: all-depth polynomial convolution, actual xi Taylor germ,
  off-line pole transfer, independent all-depth subexponential bound,
  actual xi zero coverage, or unconditional RH.

Run `run.cmd` in the extracted project, or apply patch and call the existing
`run.cmd` (command in `RODRIGUES_PROOF_FRONTIER.md`).
