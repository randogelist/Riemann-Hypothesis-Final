# Literature and classification policy

Review date: **25 October 2026**.

The [literature group](Identified-by-Literature/README.md) and [provisional group](Potentially-novel/README.md) partition all 51 primary catalogue entries. The original catalogue, statement text, hypotheses and source hashes remain the authority for what each entry says.

“Identified by Literature” includes direct criteria and explicitly identified standard reformulations. A classical theorem is not made novel by a coordinate change, a positive scalar factor, a new acronym or a project-specific Lean declaration name. For opaque models, the label identifies intended literature provenance; it does not certify the model-to-paper or model-to-Mathlib bridge.

“Potentially novel” concerns the exact project formulation, domain restriction or construction. It is a provisional research category, not a priority or correctness claim. Elementary rescalings, limiting arguments, calculus variants and assumed interfaces are described as such. A source cited on one of these rows is background or a nearby comparison, not evidence that the exact statement is published.

This was a focused comparison of the supplied exact criteria with primary literature on zero geometry, logarithmic-derivative positivity, modulus monotonicity, reciprocal-zero sums, moment sequences and operator models. It is not an exhaustive literature or citation search. The classifications and the elementary reductions are the reviewers’ assessments. Revising a classification does not alter the mathematical or native verification status.

The [machine-readable assessment](literature-classification.json) records every assignment and its references. The integrity audit checks coverage and links, not literature priority or mathematical truth.

## Primary references

<a id="riemann1859"></a>

### RIEMANN1859

[Bernhard Riemann, Ueber die Anzahl der Primzahlen unter einer gegebenen Grösse, Monatsberichte der Berliner Akademie, November 1859. English translation by D. R. Wilkins.](https://www.maths.tcd.ie/pub/HistMath/People/Riemann/Zeta/EZeta.pdf)

Locator: PDF pp. 3–4: centered xi and real-zero hypothesis; PDF pp. 2–3: functional equation.

Primary founding paper. Supplies the classical zero-location criterion and reflection. It does not use the project QQRH, AWPI, GP/BKQR, Cayley-loss or dyadic-passivity terminology.

<a id="lagarias1999"></a>

### LAGARIAS1999

[Jeffrey C. Lagarias, On a positivity property of the Riemann ξ-function, Acta Arithmetica 89 (1999), no. 3, 217–234. DOI: 10.4064/aa-89-3-217-234.](https://websites.umich.edu/~lagarias/doc/positivity.pdf)

Locator: Author preprint §1, equation (1.5), PDF page 2; logarithmic-derivative expansion (1.9), PDF page 3.

Directly states RH equivalence with Re(ξ′/ξ)>0 on Re(s)>1/2, described there as a known fact. Supports E05, not a priority claim that Lagarias originated it. Other entries use explicitly identified transformations.

<a id="lagarias_publications"></a>

### LAGARIAS_PUBLICATIONS

[Jeffrey C. Lagarias, author publications list, 1999 section.](https://websites.umich.edu/~lagarias/papers.html)

Locator: 1999: On a positivity property of the Riemann xi function.

Primary author bibliography confirms publication details; author-hosted PDFs are preprints and may differ from final journal versions.

<a id="sd2010"></a>

### SD2010

[Jonathan Sondow and Cristian Dumitrescu, A monotonicity property of Riemann’s xi function and a reformulation of the Riemann Hypothesis, Periodica Mathematica Hungarica 60 (2010), 37–40.](https://arxiv.org/abs/1005.1104)

Locator: Theorem 1 and Corollary 1; DOI 10.1007/s10998-010-1037-3

Known horizontal modulus monotonicity and zero-free half-plane equivalence; related mechanism, not an exact angular-circle criterion.

<a id="msz2014"></a>

### MSZ2014

[Yuri Matiyasevich, Filip Saidak and Peter Zvengrowski, Horizontal Monotonicity of the Modulus of the Riemann Zeta Function and Related Functions, Acta Arithmetica 166 (2014), 189–200.](https://arxiv.org/html/1205.2773v1)

Locator: Introduction and section 2; DOI 10.4064/aa166-2-4

Horizontal modulus/logarithmic-derivative inequalities for zeta, eta and xi; not theta semicircle derivatives.

<a id="sun2024"></a>

### SUN2024

[Wei Sun, Modulus representation of the Riemann xi function and polynomial inequalities equivalent to the Riemann hypothesis, arXiv:2404.06642v3 (2024).](https://arxiv.org/html/2404.06642v3)

Locator: Theorems 1.2 and 1.3; section 3, equation 3.5

Near-match checked and excluded: polynomials approximate a horizontal derivative of the modulus representation, not the project angular derivative or its residual regions.

<a id="gron1919"></a>

### GRON1919

[T. H. Gronwall, Note on the Derivatives with Respect to a Parameter of the Solutions of a System of Differential Equations, Annals of Mathematics 20 (1919), 292–296.](https://www.jstor.org/stable/1967124)

Locator: DOI 10.2307/1967124

Classical differential/integral inequality mechanism only; contains no asserted exact RH criterion E28 or E29.

<a id="blm2014"></a>

### BLM2014

[H. M. Bui, S. J. Lester and M. B. Milinovich, On Balazard, Saias, and Yor’s equivalence to the Riemann Hypothesis, Journal of Mathematical Analysis and Applications 409 (2014), 244–253.](https://www.sciencedirect.com/science/article/pii/S0022247X13006215)

Locator: Introduction, equations 1.1–1.2 and Theorem 1.1; DOI 10.1016/j.jmaa.2013.06.063

Primary paper studying the classical critical-line log|zeta| integral and its truncation rate. Different integral and asymptotic parameter from E27; not an exact match.

<a id="adr2026"></a>

### ADR2026

[J. Arias de Reyna, Riemann and the logarithmic derivatives of zeta, arXiv:2605.27552v1 (2026).](https://arxiv.org/html/2605.27552v1)

Locator: Section 2, Theorems 1 and 3

Explicitly does not assume RH; defines potentially complex centered zeros alpha and the product/reciprocal-square identity with multiplicities. Establishes normalization antecedents, not the exact E23–E26 iff statements.

<a id="kaw2024"></a>

### KAW2024

[Artur Kawalec, On the series expansion of the secondary zeta function, arXiv:2403.15741v1 (2024).](https://arxiv.org/html/2403.15741v1)

Locator: Introduction, equations 1, 4 and 7

Assumes RH. Equation 4 at m=1 gives the forward curvature equality using xi′(1/2)=0; does not establish the converse.

<a id="vor2003"></a>

### VOR2003

[André Voros, Zeta functions for the Riemann zeros, Annales de l’Institut Fourier 53 (2003), 665–699.](https://aif.centre-mersenne.org/articles/10.5802/aif.1955/)

Locator: DOI 10.5802/aif.1955; centered secondary-zeta special values

Earlier primary treatment of secondary-zeta identities; no exact real-ordinate-defect equivalence established by this review.

<a id="biss2018"></a>

### BISS2018

[Andriy Bondarenko, Aleksandar Ivić, Eero Saksman and Kristian Seip, On certain sums over ordinates of zeta-zeros II, arXiv:1808.01763 (2018).](https://arxiv.org/pdf/1808.01763)

Locator: Section 1, definition of G(s)

Defines the real-ordinate sum with multiplicities without assuming RH and gives absolute convergence for Re(s)>1; distinguishes c1=G(2) from a complex-centered-zero secondary zeta.

<a id="gmr2018"></a>

### GMR2018

[Sanoli Gun, M. Ram Murty and Purusottam Rath, Transcendental sums related to the zeros of zeta functions, Mathematika 64 (2018), 875–897.](https://arxiv.org/pdf/1807.11201)

Locator: Introduction, pages 4–5; DOI 10.1112/S0025579318000293

Proves the related criterion RH iff sum over all rho of |rho|^-2 equals 2+EulerGamma-log(4pi). A substantive positive-discrepancy antecedent, with different center and weights from E23/E25.

<a id="zhang2023"></a>

### ZHANG2023

[Ruiming Zhang, An Application of Hausdorff Moment Problem, arXiv:2303.09396v6 (2023).](https://arxiv.org/pdf/2303.09396)

Locator: Theorem 2, equations (2.9)–(2.11); Corollary 6, equations (3.7)–(3.10); Remark 5, equation (2.21).

Actual real Xi logarithmic-derivative moments and signed finite-difference RH criterion. Does not identify the project opaque integer sequence, its scale normalization, or opaque RH proposition.

<a id="zhang2022"></a>

### ZHANG2022

[Ruiming Zhang, On Certain Genus 0 Entire Functions, arXiv:2206.05104v8 (submitted 2022, revised 2023).](https://arxiv.org/pdf/2206.05104)

Locator: Theorem 1, equations (1.7)–(1.9); RH specialization Corollary 4, equation (3.12), pp. 10–11.

Existence of derivative order m such that the displayed xi-derived hierarchy is completely monotone for every k. The project comment matches the intended family; its opaque proposition contains no such formula.

<a id="sokal2020"></a>

### SOKAL2020

[Alan D. Sokal, Wall’s continued-fraction characterization of Hausdorff moment sequences: A conceptual proof, Proc. Amer. Math. Soc. 148 (2020), 2111–2116; arXiv:1903.12455v2.](https://arxiv.org/pdf/1903.12455)

Locator: Page 2, equation (2), and accompanying iff statement; proof on following pages.

Real Hausdorff moment sequences are characterized by c≥0 and g_i in [0,1] in a specified formal continued fraction. No RH statement, no opaque WallAdmissible interpretation.

<a id="gellar_wallen1970"></a>

### GELLAR_WALLEN1970

[R. Gellar and L. J. Wallen, Subnormal Weighted Shifts and the Halmos–Bram Criterion, Proc. Japan Acad. 46 (1970), 375–378, DOI 10.3792/pja/1195520357.](https://www.jstage.jst.go.jp/article/pjab1945/46/4/46_4_375/_pdf/-char/en)

Locator: Section 2 theorem and corollary, p.376: after spectral-radius normalization r(W)=1, subnormality iff the squared weight-product sequence is Hausdorff.

Classical weighted-shift/moment representation mechanism. Matching a normalized Hausdorff sequence requires an explicitly defined shift, positive moments/weights and the contraction/support normalization. These are absent at the project opaque node.

<a id="agler1985"></a>

### AGLER1985

[Jim Agler, Hypercontractions and subnormality, Journal of Operator Theory 13 (1985), 203–217.](https://jot.theta.ro/jot/archive/1985-013-002/1985-013-002-001.pdf)

Locator: Theorem 3.1, p. 212; operator-difference convention in the preceding definitions and proof.

Under the T*^k T^k difference convention, complete hypercontractivity characterizes subnormal contractions of T. Under the opposite T^k T*^k convention the statement concerns T*. The opaque project nodes specify neither orientation nor contractivity, so the imported iff is not thereby validated.

<a id="bondesson_simon2016"></a>

### BONDESSON_SIMON2016

[Lennart Bondesson and Thomas Simon, Stieltjes functions of finite order and hyperbolic monotonicity, arXiv:1604.05267.](https://arxiv.org/pdf/1604.05267)

Locator: Introduction, equations (3)–(4) and the Stieltjes hierarchy; Theorem 1, equation (5).

Finite-order Widder/Stieltjes inequalities and positive integral representations. Background for E41 and local Widder routes; does not establish their particular raw-xi normalization, cofinal-depth downward implication, or native Lean analytic interfaces.

<a id="bayer_teichmann2006"></a>

### BAYER_TEICHMANN2006

[Christian Bayer and Josef Teichmann, The proof of Tchakaloff’s theorem, Proc. Amer. Math. Soc. 134 (2006), 3035–3040; arXiv:math/0502473.](https://people.math.ethz.ch/~jteichma/tchakaloff120405.pdf)

Locator: Definition 1 and the existence theorem for positive cubature matching a prescribed finite polynomial degree.

Positive finite atomic realization of each finite moment window. Supplies the classical mathematical ingredient behind M10, not a Lean proof of hRealize or an identification of the opaque Xi/RH objects.
