# KQ–GP–BKQR-Hilbert → actual SOLOBOLO Θ'/Θ Cayley jets

**Mathematical analytic derivation, 14 October 2026.**

**Scope.** This note establishes an analytic identity and a local Taylor-coefficient bridge. It is **not** a Lean-compiled proof, a sign theorem for the resulting Cayley jets, or an RH proof. It deliberately does not posit a positive spectral representation of ξ.

## Theorem: exact Mellin–Hilbert–Cayley correspondence

For `r>0` let

\[
B(r)=\frac{r}{e^r-1}, \qquad
 d(r)=-B'(r)=\frac{(r-1)e^r+1}{(e^r-1)^2}>0.
\]

Let `Y=(1/4,1/2)`, and let \(d\nu(r,y)=2d(r)\,dr\,dy/y\), on \((0,\infty)\times Y\). On \(\mathcal H=L^2(d\nu)\) let `L` be multiplication by \(ry\), and \(Q_h=e^{-hL}\) for \(h\ge 0\). For \(\Re s>0\), \(u>-1\), and \(j,k\in\mathbb N\), set

\[
\begin{aligned}
\mathcal I(u,s)
 &=\int (ry)^{s-1}e^{-(u-1)ry}\,d\nu(r,y),\\
I_j(s)
 &=\int (ry)^{s-1}(\log(ry))^j\,d\nu(r,y).
\end{aligned}
\]

Let

\[
G(u,s)=\frac2{\Gamma(s)}\int_0^\infty t^{s-1}e^{-ut}\operatorname{sech}t\,dt.
\]

Then

\[
\boxed{\mathcal I(u,s)=\Gamma(s)G(u,s)},\qquad
\boxed{(-\partial_u)^k\partial_s^j\mathcal I(u,s)
 =\int (ry)^{s+k-1}(\log(ry))^j e^{-(u-1)ry}\,d\nu},
\tag{1}
\]

and \(\partial_s^j I_0(s)=I_j(s)\). For real \(s>0\), \(u>-1\), write \(v_{u,s}=L^{(s-1)/2}e^{-(u-1)L/2}\mathbf 1\); then

\[
\mathcal I(u+nh,s)=\langle v_{u,s},Q_h^n v_{u,s}\rangle,
\quad
(-1)^k\Delta_h^k\mathcal I(u+nh,s)
 =\|Q_h^{n/2}(I-Q_h)^{k/2}v_{u,s}\|^2\ge0.
\tag{2}
\]

Define the *completion gauge*

\[
P(s)=\frac{s(s-1)2^{s-3}\pi^{-s/2}\Gamma(s/2)}{\Gamma(s)(1-2^{1-s})}.
\tag{3}
\]

At \(s=1\) the singularity in (3) is removable with \(P(1)=(4\log2)^{-1}\). The other apparent poles at \(s=1+2\pi i m/\log2\), nonzero integer `m`, arise from the GP-to-ζ gauge; statements using \(P'/P\) are made away from them. Around **every real** \(s>0\) the factor \(P\) is analytic and nonzero.

On the slit plane let \(s(z)=\tfrac12+\sqrt z\) and \(\Theta(z)=\xi(s(z))\), with the *genuine entire completed* Riemann ξ. Then locally about **every** real \(a>0\),

\[
\boxed{\Theta(z)=P(s(z))I_0(s(z))}.
\tag{4}
\]

For \(a>0\), \(s_a=1/2+\sqrt a\), \(I_0(s_a)>0\), \(P(s_a)>0\). Thus

\[
\boxed{\Theta(a)>0}\quad\text{for all }a>0.
\tag{5}
\]

Define

\[
E(s)=\frac{I_1(s)}{I_0(s)}+g(s), \quad g(s)=P'(s)/P(s)
\]

where the denominators are nonzero. The *actual* logarithmic derivative, not an abstract spectral model, is

\[
\boxed{R_\Theta(z)=\frac{\Theta'(z)}{\Theta(z)}=\frac{E(s(z))}{2\sqrt z}}.
\tag{6}
\]

In particular, for real \(a>0\) the first term is a KQ–BKQR quadratic-form ratio:

\[
\boxed{R_\Theta(a)
=\frac1{2\sqrt a}
\left[
\frac{\langle v_{1,s_a},(\log L)v_{1,s_a}\rangle}
     {\|v_{1,s_a}\|^2}
+g(s_a)\right]}.
\tag{7}
\]

For reference, with \(\psi=\Gamma'/\Gamma\),

\[
g(s)=\frac1s+\frac1{s-1}+\log2-\frac{\log\pi}{2}
 +\tfrac12\psi(s/2)-\psi(s)
 -\frac{(\log2)2^{1-s}}{1-2^{1-s}}.
\tag{8}
\]

The two apparent terms singular at \(s=1\) cancel in (8).

For \(0<\eta<\pi\), let \(r=\sin^2(\eta/2)\), \(z_\pm=ae^{\pm i\eta}\), \(s_+=1/2+\sqrt a e^{i\eta/2}\). If \(\Theta(z_\pm)\ne0\), and the gauge ratios are defined, SOLOBOLO's actual divided-difference Cayley observable obeys

\[
\boxed{\mathcal C_\Theta(a,\eta)
=\frac{2\sqrt a}{\sin\eta}
\operatorname{Im}\bigl[e^{i\eta/2}E(s_+)\bigr]}.
\tag{9}
\]

A removable interpretation is used if the split representation \(P I_0\) has gauge artifacts but \(\Theta\ne0\).

Write \(\mathcal C_\Theta^{\rm reg}(a,r)\) for the analytic continuation of this divided difference to `r=0`. Its coefficients obey, for every \(n\ge0\),

\[
\boxed{\begin{aligned}
[r^n]\mathcal C_\Theta^{\rm reg}(a,r)
&=\frac{(-1)^n(4a)^{n+1}}{(2n+1)!}
\left[\frac{d^{2n+1}}{dx^{2n+1}}
\left(x^{n+1}R_\Theta(x)\right)\right]_{x=a}\\
&=\frac{(-1)^n(4a)^{n+1}}{2(2n+1)!}
\left[\frac{d^{2n+1}}{dx^{2n+1}}
\left(x^{n+1/2}E(\tfrac12+\sqrt x)\right)\right]_{x=a}.
\end{aligned}}
\tag{10}
\]

Expression (10) is **identically** the quantity `xiWidderDirect a n` from `Core/EntireXiWidder.lean`; the supplied SOLOBOLO theorem `XI_WIDDER_DIRECT_EQ_RECURSIVE_ON_REGULAR_ANCHORS` identifies it with `xiWidderMoment a n` whenever \(a>0\) and \(\Theta(a)\ne0\). By (5), all real positive anchors qualify *analytically*.

For example, with \(s=s_a\), \(\mathbb E_s\) the probability law induced by \(|v_{1,s}|^2d\nu/I_0(s)\), and \(X=\log L\),

\[
\boxed{\begin{aligned}
[r^0]\mathcal C_\Theta^{\rm reg}(a,r)
={}&\sqrt a\,\bigl(\mathbb E_s[X]+g(s)\bigr)\\
 &+a\,\bigl(\operatorname{Var}_s(X)+g'(s)\bigr).
\end{aligned}}
\tag{11}
\]

This formula displays the *positive variance* and the *completion-gauge correction* separately; it does **not** imply positivity of the entire expression.

## Proof

1. Since \(B(2t)-B(4t)=2t/(e^{2t}+1)\), we have \(2e^{-t}\operatorname{sech}t=(2/t)\int_{2t}^{4t}d(r)\,dr\). Insert this into \(\Gamma(s)G(u,s)\), apply Tonelli for real positive data (Fubini with absolute convergence for complex `s`), and change variables `t=ry`; this gives (1). On compact subsets of `Re s>0`, powers of `|log(ry)|` are dominated by integrable powers near `r=0`, while the density has exponential decay at infinity. Thus all parameter differentiations in (1) are justified.

2. The GP specialization is \(G(1,s)=2^{2-s}(1-2^{1-s})\zeta(s)\) by the alternating ζ (Dirichlet η) integral for `Re s>0`, extended across `s=1`. Multiply by (3) and use \(\xi(s)=\tfrac12s(s-1)\pi^{-s/2}\Gamma(s/2)\zeta(s)\) to derive (4), including removable values by analytic continuation. For positive real `s`, `I_0(s)>0` by the integrand, and `P(s)>0` because \((s-1)/(1-2^{1-s})>0\), with positive limiting value at `s=1`. This gives (5) without assuming RH.

3. Differentiate (4): \(\partial_z s(z)=1/(2\sqrt z)\), \(I_0'=I_1\), and take logarithmic derivatives on an open neighborhood with nonzero factors to give (6). Using `L=ry` on `L²(dν)` gives (7). Differentiating the gamma/exponential gauge gives (8).

4. For \(z_\pm=ae^{\pm i\eta}\), the two terms \(f(z_\pm)=z_\pm R_\Theta(z_\pm)\) are conjugate, as ξ respects complex conjugation. Since \(z_--z_+=-2ia\sin\eta\), the SOLOBOLO observable \(4a(f(z_-)-f(z_+))/(z_--z_+)\) equals \(4\operatorname{Im}f(z_+)/\sin\eta\); substituting (6) yields (9).

5. Fix `a>0`. By (5), \(f(z)=zR_\Theta(z)\) is holomorphic on some disk around `a`. On a sufficiently small enclosing contour \(\gamma\), Cauchy's formula and the SOLOBOLO quadratic Cayley-kernel identity give

\[
\mathcal C_\Theta^{\rm reg}(a,r)
=\frac{4a}{2\pi i}\oint_\gamma
\frac{f(\zeta)}{(\zeta-a)^2+4ar\zeta}\,d\zeta.
\]

For small `r` the denominator admits a uniformly convergent geometric series on \(\gamma\):

\[
\frac1{(\zeta-a)^2+4ar\zeta}
=\sum_{n\ge0}\frac{(-4ar\zeta)^n}{(\zeta-a)^{2n+2}}.
\]

Termwise integration and the Cauchy derivative formula produce the first line of (10); inserting (6) produces the second. Formula (11) follows by one derivative and the exact identity \(\partial_s^2\log I_0(s)=\operatorname{Var}_s(\log L)\) on the positive real axis.

6. For real `s>0`, `Q_h=e^{-hL}` is a positive contraction and \(e^{-nhL}\) is multiplication by \(e^{-nhry}\). Taking ordinary finite differences of the scalar readout proves (2), connecting the same measure and generator to BKQR. This *does not* prove \([r^n]\mathcal C_\Theta^{\rm reg}\ge0\), since taking a logarithmic derivative and adding `g(s)` does not preserve positive moment coefficients.

## Lean-package interface and an endpoint subtlety

Existing source checked in the provided `RH_NATIVE_SOLOBOLO_MERGER05_EXPLICIT_CAYLEY_TRACE_v0_23_0` archive:

- `Core/MathlibXiSlitTheta.lean`: `mathlibSlitTheta`, `mathlibSlitThetaPrime`.
- `Core/ActualThetaCayley.lean`: `actualThetaCayleyObservable` and metric depth.
- `Derivations/Geometry/CayleyChannelKernel.lean`: `CAYLEY_QUADRATIC_KERNEL_IDENTITY`.
- `Core/EntireXiWidder.lean`: `xiWidderDirect`.
- `Bridge/XiWidderIdentification.lean`: `XI_WIDDER_DIRECT_EQ_RECURSIVE_ON_REGULAR_ANCHORS`.
- `Bridge/MersenneCentralCriterion.lean`: `AllPositiveXiRegular` and its role in central-cell transfer.

**Endpoint subtlety:** The current `actualThetaCayleyObservable` in `Core/ActualThetaCayley.lean` calculates the quotient even when `r=0`. At `r=0`, both Cayley points coincide; Lean's totalized complex division makes the displayed numerator/denominator evaluate to `0` rather than the nontrivial continuous extension \(4a\,\partial_a(aR_\Theta(a))\). Consequently, (10) is the Taylor series of the *regularized extension*, not literally the existing observable evaluated at `r=0`. A future Lean module should distinguish these definitions explicitly.

**Proof status:** The analytic identity (1)–(11) is derived here. None of (1)–(11) has been newly compiled in Lean in this session (no Lean executable available). The independent positivity of the actual Θ Cayley jets, and any resulting RH closure, remain unproved.
