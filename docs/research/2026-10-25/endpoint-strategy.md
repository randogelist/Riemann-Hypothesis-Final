# Choosing the actual RH endpoint after finite-program calibration

Source review and mathematical strategy, 2026-10-25. No Lean compiler was run and no repository or remote was changed for this review. Proposed intermediate results below are targets, not claims of existing compiled declarations. Existing theorem names refer to the inspected recovered source.

The most economical analytic endpoint depends on what the finite program can actually certify. A positive summable resolvent program fits the slit-ODE endpoint. A program that gives an all-depth bound on the actual Bernstein energy can use an even more direct generating-series/ODE argument and bypass eventual negative-Widder dominance. A reciprocal on the Cayley disk has the shortest final implication, but a single bounded global approximation is the wrong certificate format.

The shared unresolved task is actual calibration: the finite checker must derive a uniform statement about the literal actual function. An executable packet check plus an unproved analytic proof field is not a finite reduction of that input.

## 1. Recommended order of work

| Priority | Endpoint and matching certificate semantics | Minimum actual analytic obligation beyond finite arithmetic | Main obstruction |
|---|---|---|---|
| 1 | Slit ODE for a positive summable resolvent program | Globally holomorphic resolvent limit on the slit plane; actual calibration on one regular interval, extended by the identity theorem | Finite jets or checked packet positivity do not prove the actual calibration |
| 1, if the checker supplies all-depth energy bounds | Actual row generating series, then a disk ODE | Actual binomial-transform coefficient identity; all-depth subexponential norm bound; analytic identity continuation | A merely cofinal bound does not give a unit-disk radius |
| 2 | Actual reciprocal of J on the unit disk | A derived compact-disk exhaustion of actual reciprocal residual bounds, or exact actual reciprocal identity | One bounded candidate with one global strict residual margin is impossible because J has boundary zeros |
| 3 | Local pole forces eventual direct-Widder negativity | Actual coefficient transfer plus a phase/cluster/remainder argument establishing the required signs at every sufficiently large depth | A singularity alone does not establish that particular sign conclusion |

This is a ranking of analytic closure complexity once the indicated semantics has been obtained, not a ranking of the likelihood of proving RH. None currently produces an accepted finite witness or proves completeness of a finite language. The direct-jet row endpoint in section 3 is a potentially shorter **alternative soundness route** for v1.0.2, not a discharge of the existing central-Widder/product predicate N01.

## 2. The slit-ODE route: a precise minimal contract

The recovered v0.2.3 source proves

```text
SlitODEAdmission := ∃ A : ℂ → ℂ,
  AnalyticOnNhd ℂ A Complex.slitPlane ∧
  ∀ z ∈ Complex.slitPlane, deriv theta z + A z * theta z = 0

slitODEAdmission_iff_RH : SlitODEAdmission ↔ RiemannHypothesis
```

Here the actual normalization is

\[
\xi(s)=\frac{1+s(s-1)\,\operatorname{completedRiemannZeta}_0(s)}2,
\quad \Xi(w)=\xi(1/2+w),\quad\Theta(z)=\Xi(\sqrt z).
\]

The evenness of Ξ gives the entire square descent. The source has Θ entire and Θ(1)≠0. Its forward proof uses finite analytic order: at a zero of order m>0, Θ′ has order m−1, whereas AΘ has order at least m if A is holomorphic. They cannot sum to zero. Thus no global list of zeros, positive operator representation, or Hadamard product is needed for this forward endpoint.

The actual theorem asks for the equation everywhere on the slit plane, but the following smaller calibration target suffices mathematically:

1. Construct A holomorphic on the entire slit plane U.
2. Derive Θ′(x)+A(x)Θ(x)=0 on a real interval around the regular anchor 1.
3. Prove the residual is holomorphic on connected U and apply the identity theorem.

An accumulation set inside U is sufficient in step 2; the whole interval is a convenient certificate target. This is a proposed reduction of calibration, not a claim that the source already implements this identity-theorem bridge. Global holomorphy of A is essential. A germ only at 1 does not ensure continuation through a possible off-axis pole.

A useful globally holomorphic candidate is

\[
A(z)=-\sum_{i\ge0}\frac{\lambda_i}{1+z\lambda_i},
\qquad\lambda_i\ge0,\quad\sum_i\lambda_i<\infty.
\]

For compact K⊂U, write t=λ/(1+λ)∈[0,1]. The denominator (1−t)+tz is nonzero on K×[0,1]: otherwise either t=0 gives 1=0, or z is nonpositive real. Compactness gives a positive lower bound c_K. Consequently

\[
\left|\frac{\lambda}{1+z\lambda}\right|
=\frac{t}{|(1-t)+tz|}\le c_K^{-1}\lambda.
\]

Summable domination gives local uniform convergence and holomorphy. A finite program can generate truncations or rational approximations, with tail and approximation bounds checked through a finite proof language. Proving this generic analytic resolvent theorem is ordinary reusable mathematics; identifying its limit with actual Θ′/Θ remains the RH-strength calibration.

Use the regular interval carefully. Θ(1)≠0 and continuity provide one without assuming RH. Lean division is totalized at zero, so an equality written with Θ′/Θ at arbitrary points is not by itself a division-free ODE at zeros. First restrict the logarithmic-derivative calibration to the proved regular interval, multiply there, and then continue the analytic residual.

The recovered `ResidualLimit.actual_ode` proves the correct limit transfer from pointwise limits of the coefficients and actual residuals. It does not derive those limits. `FiniteProofWitness` carries `calibrated : AnalyticCalibration program`, including global holomorphy and all-point actual residual convergence. Replacing that proof field by `check program = true` is exactly the missing soundness theorem, not a renaming exercise.

### Can a finite rational identity establish the actual residual?

Yes, if an independently proved representation theorem has reduced the entire actual residual to finitely many algebraic generators and the finite identity is its exact normal form. For example, a verified finite-state recurrence with derived initial data and a proved universal transition could reduce infinitely many coefficient equations to a finite relation. The actual state representation and the derived transition must be present in the proof.

No, if the identity concerns only a candidate rational function or matches finitely many actual derivatives. For any K, adding a nonzero multiple of (z−1)^(K+1) preserves the first K jets and changes the germ. A product vanishing at finitely many sample points gives the analogous point-sampling obstruction. A residual budget is useful only after a valid actual remainder bound has been derived.

A fixed rational logarithmic derivative is also a poor all-orders target. If Θ has infinitely many distinct nonzero zeros, its logarithmic derivative has infinitely many genuine poles; it cannot equal one fixed rational function after meromorphic continuation. This statement is conditional on the supplied infinitude/continuation facts and is not claimed formalized here. A finite program generating increasing-rank approximants has no such fixed-rank obstruction.

## 3. A potentially shorter native-energy endpoint

The local-pole branch contains a real opportunity to remove the strongest missing sign theorem. This applies to an **all-depth** energy bound, such as the linear bound intended from calibrated positive Bernstein induction.

Use the exact recovered Merger02 objects:

\[
g(u)=u\Theta'(u)/\Theta(u),\qquad
c_n=\frac{(-1)^n}{(n+1)!}g^{(n+1)}(1),
\]

\[
R_N(z)=\sum_{j=0}^N\binom Nj c_j(z-1)^j,\qquad
M_z(v)=\frac{1-zv}{1-v}.
\]

`CoefficientTransfer` already proves that the regularized quotient

\[
C(w)=\frac{g(1)-g(1-w)}w
\]

has actual coefficients c_n at zero. It defines

\[
\operatorname{regularGenerating}(z,v)
=(1-v)^{-1}C\!\left(\frac{(z-1)v}{1-v}\right)
\]

and identifies it, away from the removable point, with

\[
\frac{g(M_z(v))-g(1)}{(1-z)v}.
\]

The tower normalization must remain explicit. These c_n are the anchor-1 direct derivatives of g, matching the intended form of v1.0.2 `SoloBoloWitness.actualJet`. They are **not** the D154 `nativeCoefficients`/`complexRodrigues1n` central-Widder coefficients, whose formula has derivative order 2n+1, factorial (2n+1)!, and the factor (4a)^(n+1). The row argument therefore does not prove N01 or the symmetric-product coefficient identity. Its application to v1.0.2 additionally requires an explicit real-to-complex binding: the positive-real `actualThetaPos`, its real derivative and iterated derivatives at 1 must agree with this complex actual Θ/g germ. The two xi formulas agree, but the derivative transport is still a theorem to prove. Likewise compare the real Bernstein energy and Merger02 complex norm-square energy explicitly; do not identify them by similar names.

The exact missing composition lemma is

\[
\operatorname{actualRegularGeneratingJet}(z,N)=R_N(z),
\]

or equivalently the local power-series identity

\[
\sum_{N\ge0}R_N(z)v^N
=(1-v)^{-1}\sum_{j\ge0}c_j
 \left(\frac{(z-1)v}{1-v}\right)^j.
\]

This is the ordinary binomial transform of an analytic germ. It should be proved generically from formal-series composition or locally absolutely convergent sums, then instantiated with the actual c_n. It requires no RH or positivity.

The source `Envelope.rowPolynomial_norm_sq_le_energy` gives

\[
|R_N(z)|^2\le E_N\qquad(|z|\le1).
\]

An all-depth estimate E_N≤C(N+1)^k, or more generally
limsup E_N^(1/N)≤1, makes

\[
R_z(v)=\sum_{N\ge0}R_N(z)v^N
\]

holomorphic throughout |v|<1. The coefficient identity calibrates this global function to the actual germ near v=0.

Now clear denominators near zero:

\[
\big((1-z)vR_z(v)+g(1)\big)\Theta(M_z(v))
=M_z(v)\Theta'(M_z(v)).\tag{*}
\]

Both sides are holomorphic on the entire disk. `SlitTransport.mobius_mem_slitPlane` already proves M_z(v)∈U when |z|≤1 and |v|<1, so M_z(v)≠0. The identity theorem extends (*) throughout the disk without assuming that Θ is nonzero there.

Writing T_z=Θ∘M_z yields the division-free ODE

\[
T_z'(v)=\frac{M_z'(v)}{M_z(v)}
 \big((1-z)vR_z(v)+g(1)\big)T_z(v).
\]

Its coefficient is holomorphic on the disk and T_z(0)=Θ(1)≠0. The same finite-order argument excludes all zeros of T_z. The already derived actual off-line-zero/Cayley geometry then yields RH. The source's actual interior-simple-pole construction can supply the contradiction, but one only needs its zero-location step; neither global zero enumeration nor eventual negative-Widder asymptotics is required.

This argument is a new proposed assembly of recovered components, not an existing theorem in those files. Its remaining lemmas are concrete:

1. The real-to-complex actual carrier/derivative and Bernstein-energy bindings for v1.0.2, followed by the actual binomial-transform coefficient identity.
2. Analyticity of the actual row series from the certificate-derived all-depth bound.
3. Denominator-cleared analytic continuation of (*).
4. The generic disk linear-ODE nonvanishing lemma and assembly with actual zero geometry.
5. Most importantly, derivation of the actual all-depth bound from the accepted finite program.

The **cofinal** `ActualUS` statement is weaker. Bounds only on a sparse subsequence do not control the radius of a power series. For example, coefficients can vanish at every even index and grow exponentially at odd indices. The current cofinal route therefore needs its eventual growth/finite-filter argument, or a separate theorem upgrading its bounds; it cannot directly use the radius proof above. When the program already provides a linear bound for every depth, do not throw away that stronger information.

## 4. Reciprocal admission: simplest logic, delicate certificate geometry

The recovered v0.4.1 source proves

```text
AnalyticReciprocalAdmission := ∃ u,
  DifferentiableOn ℂ u unitDisk ∧
  ∀ w ∈ unitDisk, J w * u w = 1

ANALYTIC_ADMISSION_IFF_RH
```

The source's actual normalization satisfies J(0)=1 and, for nonzero w in the disk,

\[
J(w)=w\zeta\!\left(\frac1{1-w}\right).
\]

For forward soundness, the pointwise product identity already excludes zeros; holomorphy of u is needed for the analytic admission and the reverse construction. More generally, a proved residual bound |1−J(w)u(w)|<1 everywhere in the disk excludes zeros. It need not reconstruct a positive spectrum.

However, a single polynomial p, or any bounded holomorphic u, cannot satisfy one global uniform bound

\[
|1-J(w)u(w)|\le q<1\qquad(|w|<1)
\]

if there is a critical-line zero ρ. Indeed,

\[
w_\rho=1-1/\rho,\qquad |w_\rho|=1,
\]

and wρ≠1. The actual formula for J extends holomorphically near that boundary point with J(wρ)=0. On the radial path rwρ, r↑1, boundedness of u gives Ju→0 and |1−Ju|→1, contradicting q<1. The argument for a polynomial needs only one critical-line zero. For a rational candidate with finitely many boundary poles, choose a critical-line zero whose image is not one of those poles; infinitely many critical-line zeros supply this. These are mathematical obstruction statements, not newly formalized Lean theorems.

This does not obstruct the actual reciprocal under RH: it is unbounded near those boundary zeros. Nor does it obstruct a growing sequence of approximants on compact disks. The suitable certificate format is

\[
r_n\uparrow1,\qquad
\sup_{|w|\le r_n}|1-J(w)u_n(w)|\le q_n<1
\]

for every n, with u_n and its bounds produced by one finite program and one checked uniform proof. The q_n need not share a strict global upper bound. Merely finding separate finite certificates at finitely many radii, or proving existence of an unconstrained certificate for each radius, is not yet one accepted finite witness.

The Hardy sources already expose exactly this radius issue. Their defect successor identity preserves positivity at the same w. It does not enlarge the certified disk. `PrescribedRadiusStep` remains a separate mathematical statement, equivalent to actual disk exhaustion under the source's other hypotheses.

A concrete counterexample illustrates the gap. Take the toy function J(w)=1−(4/3)w, whose coefficient energy is K=25/9. Its initial defect is D₀(w)=1−K|w|², positive on |w|≤1/2 (minimum 11/36). The same generic algebraic successor recurrence holds. Yet J vanishes at w=3/4, so no valid strict certificate can cover a disk reaching that point. Thus the recurrence and a base disk cannot logically yield arbitrary radius expansion.

## 5. Why local-pole negativity is a more expensive target

The source genuinely derives

```text
NOT_RH_GIVES_ACTUAL_XI_INTERIOR_SIMPLE_POLE
```

from literal Mathlib RH failure. It proves an actual Cayley pole with nonzero residue, norm less than one, and a holomorphic local remainder. That is substantive recovered mathematics.

Its proposed forward bridge still assumes

```text
ActualLocalPoleForcesDirectNegativity :=
  ∀ P : ActualXiInteriorSimplePole,
    ∃ K, ∀ n ≥ K, ∃ a ∈ xiRegularAnchors,
      xiWidderDirect a n < 0
```

A local pole implies failure of holomorphic extension through that point. It does not alone supply the sign of a particular real derivative transform at every sufficiently large depth. One must establish the actual coefficient identity, the relevant phase/anchor choice, and control competing poles and the holomorphic remainder. Equal-modulus poles can create oscillation and cancellation. Working with finitely many zeros in a compact region avoids a global zero enumeration, but does not eliminate the dominance analysis.

If the certificate yields an all-depth norm bound, the preceding holomorphic-extension contradiction is weaker and more direct than eventual negativity. Retain the sign route for a certificate that intrinsically supplies only the cofinal positivity conditions needed by that bridge.

The differential recurrence itself cannot provide positivity for free. For the source's direct-Widder step, with m=n+1,

\[
\mathcal S_n f(a)=\frac{2}{m(2m+1)}
 \left(m^2f(a)-af'(a)-a^2f''(a)\right).
\]

At n=0 and f(a)=a²>0 for a>0, the output is −2a². Any positivity-preserving induction therefore needs a stronger derived invariant, such as a positive moment representation, rather than the assertion f≥0 alone.

## 6. The determinant coefficient route fits, but its radius must be explicit

A complementary route is the actual symmetric product

\[
H_a(r)=\Theta(z_+(r))\Theta(z_-(r)),\quad
z_++z_-=2a(1-2r),\quad z_+z_-=a².
\]

For F=Θ′/Θ and a regular nonzero anchor, its logarithmic derivative has the proposed coefficient formula

\[
[r^n]\frac{-H_a'(r)}{H_a(r)}
=\frac{(-1)^n(4a)^{n+1}}{(2n+1)!}
 \left.\frac{d^{2n+1}}{dz^{2n+1}}ig(z^{n+1}F(z)\big)\right|_{z=a}.
\]

The checked low orders are 4a(F+aF′) and
−16a²(F′+aF″+a²F‴/6). A finite-jet proof can use r=t²/(1+t²), z±=a(1±it)/(1∓it), and analytic order under composition, avoiding a global logarithm or contour interchange. This is detailed separately in `coefficient-bridge-strategy.md`.

RI01 supplies actual local holomorphic products and convergence on a small disk. Those statements do not give a unit-disk ODE. Once the coefficient identity is proved, an actual all-depth absolute moment bound could extend the series for the ODE coefficient to |r|<1. One then continues the division-free residual, uses ODE nonvanishing, and derives RH from the actual zero correspondence. An upper bound without nonnegativity or a lower bound is not an absolute bound. The local coefficient theorem is a useful independent milestone; the actual global bound is still the input the finite checker must derive.

## 7. Soundness and completeness must remain separate

A useful first theorem has a concrete executable checker and the form

```text
check code = true → actual global bound / calibrated resolvent admission
```

with no packet-specific assumption of actual calibration, radius enlargement, actual enclosure validity, or universal transition soundness. Generic analytic theorems used in its proof may be proved once and reused. A separate actual admission→RH theorem then closes soundness.

A finite-witness equivalence additionally requires

```text
RiemannHypothesis → ∃ code, check code = true.
```

RH supplies an analytic reciprocal or, after a proved product theorem, an infinite positive realization. It does not automatically imply that the chosen finite syntax can encode and verify a uniform proof of the required approximation schedule. A proof-search checker likewise gives provability in the chosen theory; its truth-to-provability direction is not automatic. No impossibility for this particular conjecture follows from this observation, but completeness cannot be inferred from the existing analytic iff.

## 8. Exact evidence locations

Paths are relative to the audit workspace. Hashes identify the exact inspected source; they do not certify compilation.

| Source | Evidence |
|---|---|
| `reinference/corpus/554667603de88d116d8455b3db517ea6258ff91acf4c4a557a3da3be298f254e.lean` | NativeODE; actual slit-ODE admission, local finite-order proof, actual RH iff |
| v0.2.3 `SoloboloAdmission/ResidualLimits.lean` | `ResidualLimit` fields and derived limit-to-ODE transfer |
| `reinference/corpus/70afdd2694bea4c9c9640120ea2dddcbe941b886e4c46cb370ebd7f7cb1e92f4.lean` | FiniteProofWitness retains full AnalyticCalibration proof fields |
| `strategy_deep/staged-analytic/reciprocal/SoloAdmission/AnalyticInverse.lean` | Actual reciprocal admission iff RH |
| `strategy_deep/staged-analytic/reciprocal/FiveInduction/HardyActual.lean` | Actual J normalization, whole-disk Taylor series, zero criterion, separate Hardy-energy premise |
| v0.4.1 FIX1 `FiveInduction/HardyEndpoint.lean`, `HardyInduction.lean` | Same-radius defect induction versus separate prescribed-radius step |
| `reinference/corpus/16c28076681bdca6f44e962de59748ef2f81a32911d4b0ced09092ee53278fdf.lean` | Actual quotient germ and explicit regularGenerating/rawGenerating relation |
| `reinference/corpus/b4ae4c6414bdfab0e368b8e1e635176c49fae47762155831111de44e5edaf667.lean` | Explicit remaining actual row-composition coefficient identity |
| `reinference/corpus/93d48d3d8af787353e29aa52b2ca1a4cabbe49459718acbe396edb6c55d1d0e7.lean` | Slit Möbius transport, actual denominator analyticity and zero geometry |
| `reinference/corpus/3a5058dfe6e4123b0f58f56bf51241a01961caf044e6f6da31a1408ecb79578c.lean` | Actual row norm dominated by Bernstein energy |
| `reinference/corpus/a9f4f52786f89cbf9c9cc2b298f410529bbce556695f1c44b824a9ecf818f382.lean` | Actual off-line zero→actual interior simple pole; cross-branch actual-function binding |
| `reinference/corpus/98547e3a34358759159c74f4977716543700aa69ba4638c0104b4b6a3bef9b4b.lean` | The still-assumed local-pole→eventual-direct-negativity bridge |

The v0.2.3 package root is `reinference/new-solobolo-finite/SOLOBOLO_FINITE_WITNESS_IFF_RH_LEAN_v0_2_3_GOODWORKFLOW_CACHED_MATHLIB/SOLOBOLO_FINITE_WITNESS_IFF_RH_LEAN_v0_2_3_GOODWORKFLOW_CACHED_MATHLIB/`. The v0.4.1 FIX1 package root is the corresponding duplicated `SOLOBOLO_FINITE_WITNESS_IFF_RH_GOODWORKFLOWFRONTIER_v0_4_1_CACHED_MATHLIB_FIX1/` path under that same `new-solobolo-finite/` directory.
