# ROOTTEST → actual SOLOBOLO pole-growth frontier

## Established as exact mathematics; new Lean proof awaits native verification

For any sequence `W_n(a)` satisfying

    ∀ b>1, ∃C≥0, ∀n, |W_n(a)|≤C b^n,

the series `Σ_n |W_n(a)| r^n` converges for `0≤r<1`; moreover,
`Σ_n W_n(a) z^n` converges absolutely for every complex `‖z‖<1`.
Choose `b=(3−r)/2`, so `1<b` and `0≤br<1`, then compare with `C(br)^n`.
This is encoded in `subexp_radial_absolute_summable`.

A channel satisfying the genuine lower bound `w q^n≤|W_n|` with
`w>0`, `q>1` cannot satisfy any envelope with `1<b<q`.
The proof uses `pow_unbounded_of_one_lt` on `q/b>1`.

## Still open (mathematical—not simply Lean syntax)

1. Establish the regularized Cayley generating identity

       Σ_n W_n^xi(a) z^n = C_Θ(a,z)

   for `|z|` small, including the actual-ξ Hadamard zero factorization
   and the completion gauge.
2. Show the analytic germ continues to the pole-free portion of `|z|<1`
   and an off-line zero creates a genuine nonremovable pole there.
3. Transfer this pole into all-depth coefficient growth, with proper
   multiplicities and without cancellation. The constructed
   `OffLineChannelDomination` is a sufficient condition but is **stronger**
   than necessary and is not assumed to follow from the existence of a zero.
4. Prove `ActualXiSubexponential` independently from the KQ-GP-BKQR
   Hilbert/Cayley/Hausdorff/Zhang/RIEMANCURVE branches.
5. Prove actual nontrivial ξ-zero coverage as in v0.1.4.

The results do not prove RH without additional assumptions.
