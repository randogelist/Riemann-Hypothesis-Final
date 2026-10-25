# Independent review of the single-condition publication

Review date: 2026-10-25. Source/API inspection only; no Lean or Lake invocation, and no native axiom result is claimed. The reviewer subsequently authored the generic `ResidualNonvanishing.lean` proof at the parent agent's request. `FiniteProgramEndpoint.lean` was independently written by the Lean-core agent and reviewed here; that agent independently reviewed the generic proof.

## Verdict and exact scope

The new endpoint has a genuine single remaining analytic condition for **forward soundness**. It removes the old separately supplied limiting coefficient, holomorphy of that limit, coefficient convergence, and actual residual convergence. It is not merely those fields hidden in one structure.

For a raw finite program G, let

\[
A_N(z)=-\sum_{i<d_G(N)}\frac{m_{N,i}}{t_{N,i}z+(9/4)(1-t_{N,i})},
\qquad E_N(z)=\Theta'(z)+A_N(z)\Theta(z).
\]

The sole remaining property is

\[
E_N\longrightarrow0\quad\text{locally uniformly on }
U=\mathbb C\setminus(-\infty,0].
\]

Precisely, it is `TendstoLocallyUniformlyOn G.actualResidual (fun _ => 0) atTop Complex.slitPlane`, named `ActualUniformResidualCondition G`. For every compact K⊂U and every ε>0, this asks for one stage after which |E_N(z)|<ε simultaneously for all z∈K. This is an infinite analytic statement, not a finite Boolean decision.

The valid publication claim is:

```text
FiniteProgram.nativeRH_of_uniformResidual
  (G : FiniteProgram)
  (hActual : ActualUniformResidualCondition G) : RiemannHypothesis
```

No program satisfying the condition has been constructed. No checker recognizes the condition, no theorem `RH → ∃ G, condition G` has been established, and no finite-witness iff follows. The conclusion remains conditional even though all other analytic premises of this particular endpoint have been discharged.

## Why the new implication has substantive content

`FiniteProgram` contains only a natural-number rank offset and two finite rational expression trees. The same expressions generate every stage. Its node transform x²/(1+x²) and mass transform y² derive all-stage bounds 0≤t≤1 and m≥0. There is no stored arbitrary real function or analytic proof in the program.

For t∈[0,1], a zero of tz+(9/4)(1−t) is on the excluded nonpositive real axis. The t=0 endpoint is the nonzero constant 9/4; t=1 has its only zero at z=0. Hence every A_N is holomorphic on U by finite rational algebra. `rationalNode_denominator_ne_zero`, `rationalODECoefficient_analytic` and `FiniteProgram.coefficient_analytic` implement that derivation. Positivity of masses is not needed for this particular analyticity argument, but remains a structural property of the models.

Now suppose Θ has a zero of order k+1 at z₀∈U. Its order is finite because Θ is entire and Θ(1)≠0. Every product A_NΘ has vanishing derivatives through order k at z₀. Therefore

\[
E_N^{(k)}(z_0)=\Theta^{(k+1)}(z_0)\ne0
\]

for every N. Holomorphic locally uniform convergence implies convergence of every fixed derivative to the corresponding derivative of zero. This contradicts the displayed nonzero constant. Thus Θ is nonzero on U. The recovered actual zero-geometry theorem then yields literal Mathlib RH.

This argument does not require any limit A, positive trace reconstruction, global zero enumeration, simple-zero hypothesis, a radius enlargement assumption, or the central-Widder/product coefficient identity. It addresses zeros of arbitrary finite multiplicity. It also does not identify finite jets with actual functions: its residual explicitly uses the actual entire Θ and its derivative.

A further positive consequence can be proved after nonvanishing: A_N converges locally uniformly to −Θ′/Θ, by dividing E_N by Θ on compact sets whose minimum |Θ| is positive. That limit is holomorphic. Consequently a holomorphic limiting coefficient can be **derived from the one residual condition**, although the current endpoint deliberately avoids introducing it. This consequence is mathematical reasoning, not an additional declaration claimed present in the new files.

## Inspection of the actual source proof

`SoloboloAdmission/ResidualNonvanishing.lean` contains:

- `locallyUniform_zero_iteratedDeriv`: induction using Mathlib's locally uniform derivative theorem.
- `entire_nonvanishing_of_locallyUniform_residual`: finite analytic order, product-order lower bound, the fixed derivative identity, and uniqueness of the limit of a constant sequence.

The generic result allows an arbitrary open U. It does not require U connected or the anchor 1∈U, because Y is entire and nonzero at 1; this supplies finite analytic order on all of ℂ. Downstream U is the slit plane.

The checked Mathlib 4.33 source APIs are:

- `Analysis/Complex/LocallyUniformLimit.lean`: `TendstoLocallyUniformlyOn.deriv` and `.tendsto_at`.
- `Analysis/Calculus/FDeriv/Analytic.lean`: `AnalyticOnNhd.iterated_deriv`, `.differentiableOn`.
- `Analysis/Calculus/IteratedDeriv/Defs.lean`: `iteratedDeriv_eq_iterate`, `iteratedDeriv_succ`, `iteratedDeriv_succ'`.
- `Analysis/Calculus/IteratedDeriv/Lemmas.lean`: `iteratedDeriv_add`.
- `Analysis/Analytic/Order.lean`: finite-order propagation on a preconnected domain, `analyticOrderAt_eq_nat_iff_iteratedDeriv_eq_zero`, `natCast_le_analyticOrderAt_iff_iteratedDeriv_eq_zero`, and `analyticOrderAt_mul`.
- `Data/ENat/Basic.lean`: `ENat.ne_top_iff_exists`.

The derivative helper explicitly identifies the derivative of the zero function, and the product-order bound explicitly simplifies zero addition in ℕ∞. The Lean-core agent independently checked these signatures and found no source-level mismatch. Native elaboration remains necessary before calling this a verified Lean theorem.

For `FiniteProgramEndpoint.lean`, the complex-to-real cast proof was checked against the actual simp lemmas `Complex.ratCast_re` and `Complex.ratCast_im`; the finite sum analyticity lemma is generated by `Finset.analyticAt_sum`; and `ActualUniformResidualCondition`/`actualResidual` unfold definitionally into the generic theorem's exact residual. No mathematical defect was found in that adapter.

## Limits of the finite-program claim

1. `FiniteProgram.smoke G K=true` holds for every program and every K. It checks the structurally enforced model positivity. It does not distinguish successful actual calibrations from unsuccessful ones and must not be advertised as an RH witness acceptance test.
2. The expression language is quite restrictive: rational literals, depth/index, finitely many arithmetic operations and branches, with rank N+offset+1. It is not an arbitrary recursively programmable spectral approximation algorithm. Even a positive infinite realization under RH does not automatically fit this exact syntax or schedule.
3. Locally uniform residual convergence is stronger than checking finitely many samples or jets. Its unbounded quantifiers are not reduced by storing finite syntax alone.
4. Mathematical derivation of the universal rule is an advance, but supplying a particular actual instance remains the research problem. It would prove RH if completed.
5. The direct residual endpoint does not prove the separate central-Widder product identity N01, the RH→finite-code direction, or the claimed RH↔GRH construction.

## Positive-product closure and publication size

The recovered 76-module product support closure is relevant to the distinct direction RH→positive infinite trace realization. Its origin normalization, multiplicity-bearing paired zeros and summable inverse scales are substantial existing source. The positive-ray real-carrier/reindexing adapters still need assembly and native validation. It does not produce one accepted finite raw program.

That large closure is unnecessary for the new conditional soundness endpoint. The realistic present publication is the small actual-Theta/zero-geometry closure, original rational-program sources, the generic residual theorem, and its finite-program specialization. Keep product reconstruction and finite representability documented separately rather than import an unvalidated large graph merely to support the phrase “one condition.”

## Documentation review requirements

Acceptable description: “A raw finite program implies RH under one explicit locally uniform actual-residual condition; structural packet validity and holomorphy are derived.”

Unacceptable descriptions: “one finite condition remains,” “the finite witness reduction is complete,” “the executable checker now proves RH,” “RH iff a finite witness” or “the induction input is fully derived.” The universal structural model step is derived; actual calibration remains one analytic limit statement.

State the new source's native status independently of historical receipts for old versions. Include both new endpoints in the build/axiom audit plan, but do not turn that plan or a placeholder scan into evidence that native checking occurred.

## Review of publication prose

Reviewed `README.md`, `docs/ACTUAL_CONDITION.md`, `docs/FRONTIER.md` and `docs/RECOVERED_EQUIVALENCES.md` against the new source. Their displayed formulas, single residual premise, source-only status and forward-versus-iff separation are accurate. Requested three narrow wording changes from the documentation owner: avoid implying the actual finite induction input has already been derived in the README opening; scope exact base-function equality to the exact-induction route rather than impose it on residual convergence; and spell out that completeness in the fixed arithmetic/branch, linear-rank language may require a richer program syntax. No additional mathematical formula defect was found.
