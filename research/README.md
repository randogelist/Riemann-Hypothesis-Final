# Historical source archive

Files under `upstream/` are preserved source evidence, outside both active
build plans. The SHA-256 inventory is `provenance/upstream-files.json`.
Old proof-tier markers and PASS claims inside these files are historical
statements, not validation of this repository.

The GP incorporation adds:

- `kq-gp-v0118`: recovered KQ/GP/BKQR/SOLOBOLO source and frontier notes;
  48 unchanged modules also appear in the active full build.
- `gp-master-v050`: original master-object sources. These contain an opaque
  custom RH predicate, opaque analytic objects and four research axioms.
  They are not imported by active code. The separately adapted
  `RHFinal/GP/Master/` proves only generic consequences of explicit model laws.
- `gp-h3-pde-v051`: original partial H3 patch with unavailable external patch
  dependencies. Its self-contained polynomial identity is adapted in
  `RHFinal/GP/NativeBinding.lean`; the original patch is not built.
- `gp-analytic-note`: the on-paper continuous Mellin/Hilbert construction,
  preserved unchanged. Integral identities and analytic claims in that note
  are not Lean verification receipts.

Historical CMD runners and compiled objects are not included. Use the one
root `run.cmd` and the active build manifests.
