# Clone and update the repository

The user created the public repository
[`randogelist/Riemann-Hypothesis-Final`](https://github.com/randogelist/Riemann-Hypothesis-Final).
Its default branch is `main`. This source snapshot is the prepared initial
research project; native Lean compilation and the actual-ξ finite-input
reduction remain pending/open. No credential is stored in the source tree.

## Clone

With Git installed, clone the existing repository:

```cmd
git clone https://github.com/randogelist/Riemann-Hypothesis-Final.git
cd Riemann-Hypothesis-Final
```

After the initial source upload is present, use the single `run.cmd` as
specified in [BUILD.md](BUILD.md). A Git commit or upload is not a native
compilation or axiom-audit receipt.

## Update

Before editing, fetch and fast-forward a clean checkout:

```cmd
git pull --ff-only origin main
```

Review `git status` and `git diff`, stage only the intended source changes,
and commit them with an accurate message. Authenticated write access is
required to push:

```cmd
git push origin main
```

If the branch has moved, fetch and reconcile the changes before retrying.
Do not force-push or replace existing history to publish an exported ZIP.
The ZIP omits `.git` and generated caches; use a clone as the base when
transferring reviewed files from a ZIP.

Keep `provenance/status.json` aligned with actual publication and build
evidence. Native compilation remains `NOT_RUN` until a Windows receipt
exists. Local checker acceptance does not establish actual-ξ calibration,
finite-witness soundness, or RH.
