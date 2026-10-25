import Bridge.XiWidderIdentification
import Derivations.Geometry.CayleyRadius

/-!
# ALL-DEPTH SUBEXPONENTIAL CAYLEY FRONTIER (no Mersenne restriction)

The envelope is the precise (∀ b > 1) exponential-majorant condition.
The pole-to-coefficient-growth theorem is an explicit unproved research input.
This file proves the contradiction and the centered-RH consequence, not
analytic pole-to-growth itself.
-/

namespace KQGPBKQRHilbert.AllDepth

/-- For every base b>1, the entire scalar sequence has an O(b^n) bound. -/
def SubexponentialAt (W : ℝ → ℕ → ℝ) (a : ℝ) : Prop :=
  ∀ b : ℝ, 1 < b →
    ∃ C : ℝ, 0 ≤ C ∧ ∀ n : ℕ, |W a n| ≤ C * b ^ n

/-- Uniform in every positive anchor, but not in the constants C. -/
def Subexponential (W : ℝ → ℕ → ℝ) : Prop :=
  ∀ a : ℝ, 0 < a → SubexponentialAt W a

/-- The *actual* recursive ξ-Widder sequence from SOLOBOLO. -/
def ActualXiSubexponential : Prop :=
  Subexponential NativeSoloboloNegativity.xiWidderMoment

/-- Stronger than merely `q>1`: a pole of spectral radius q means that
    every weaker exponential base 1<b<q fails to dominate the sequence.
    This is still an OPEN analytic condition for the actual ξ moments. -/
def CanonicalPoleGrowth
    (X : NativeSolobolo.CenteredXiGeometry)
    (W : ℝ → ℕ → ℝ) : Prop :=
  ∀ z : X.Zero, X.beta z ≠ 0 →
    ∀ b : ℝ, 1 < b → b < X.cayleyQ z →
      ∀ C : ℝ, 0 ≤ C →
        ∃ n : ℕ, C * b ^ n < |W (X.anchor z) n|

/-- An abstract pole growth witness cannot coexist with a subexponential
    envelope at the canonical positive anchor.  ALL n occur, not 2^k. -/
theorem subexponential_excludes_offline_zero
    (X : NativeSolobolo.CenteredXiGeometry)
    (W : ℝ → ℕ → ℝ)
    (hsub : Subexponential W)
    (hpole : CanonicalPoleGrowth X W) :
    NativeSolobolo.RiemannHypothesis X := by
  by_contra hnot
  obtain ⟨z, hb⟩ :=
    NativeSolobolo.Derivations.Geometry.NOT_RH_GIVES_OFFLINE_ZERO X hnot
  have hq : 1 < X.cayleyQ z :=
    NativeSolobolo.Derivations.Geometry.CAYLEY_Q_GT_ONE X z hb
  let b : ℝ := (1 + X.cayleyQ z) / 2
  have hb1 : 1 < b := by
    dsimp [b]
    linarith
  have hbq : b < X.cayleyQ z := by
    dsimp [b]
    linarith
  have ha : 0 < X.anchor z :=
    NativeSolobolo.Derivations.Geometry.ANCHOR_POSITIVE X z
  obtain ⟨C, hC, hupper⟩ := hsub (X.anchor z) ha b hb1
  obtain ⟨n, hlower⟩ := hpole z hb b hb1 hbq C hC
  exact (not_lt_of_ge (hupper n)) hlower

/-- Explicitly record actual-zeta-zero coverage; `X` is an abstract centered
    geometry until it is identified with *all* actual nontrivial ξ-zeros. -/
def ActualXiZeroCoverage (X : NativeSolobolo.CenteredXiGeometry) : Prop :=
  NativeSolobolo.RiemannHypothesis X → _root_.RiemannHypothesis

/-- Conditional closure, with both substantive analytic bridges visible. -/
theorem actual_subexponential_and_pole_growth_imply_RH
    (X : NativeSolobolo.CenteredXiGeometry)
    (hcoverage : ActualXiZeroCoverage X)
    (hpole : CanonicalPoleGrowth X NativeSoloboloNegativity.xiWidderMoment)
    (hsub : ActualXiSubexponential) :
    _root_.RiemannHypothesis :=
  hcoverage (subexponential_excludes_offline_zero X
    NativeSoloboloNegativity.xiWidderMoment hsub hpole)

end KQGPBKQRHilbert.AllDepth
