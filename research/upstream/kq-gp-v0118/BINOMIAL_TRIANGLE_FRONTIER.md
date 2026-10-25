# v0.1.11 — Pascal triangle for all-depth Cayley coefficients

Let D_j(r) be the previously verified Cayley polynomial defined by
D_0=1, D_1=-4ar, D_(j+2)=-4ar D_(j+1)-4a²r D_j.

The exact candidate coefficient on the diagonal j=n+k is

  B_(n,k)=(-4a)^n a^k * choose(n,k).

The new Lean source formally proves:

  B_(n+1,k+1)=(-4a) B_(n,k+1)-(4a²) B_(n,k),

and the matching recurrence for [r^(n+1)]D_(n+k+2). Given ONLY the
leading-diagonal identity

  [r^n]D_n=(-4a)^n,

induction on n proves for all k

  [r^n] D_(n+k)=(-4a)^n a^k choose(n,k).

**Still conditional:** The leading-diagonal identity is a small, finite
polynomial boundary lemma not yet discharged in this patch. Furthermore,
the stabilized Cayley coefficient must still be identified with the
canonical finite binomial sum, and then with the actual xi Widder
coefficient through complex Taylor derivatives. The actual infinite
Theta germ, analytic pole bridge, zero coverage, and independent
subexponential estimates are **not** proved.

This packaging environment has no Lean executable; v0.1.11 proof sources
await Windows kernel compilation. There are no sorry, admit, or axioms.
