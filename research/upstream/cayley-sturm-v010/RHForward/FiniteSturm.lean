import RHForward.RationalChecker

/-!
# Finite Sturm zero-exclusion on the rational and RH-specialized real spectra

The characteristic product is finite and explicit. This is NOT a theorem
about the full actual xi divisor, which requires an analytic passage to
infinity.
-/

namespace RHForward

noncomputable def UnitSpectrum.spectralProduct {d : ℕ}
    (s : UnitSpectrum d) (x : ℝ) : ℝ :=
  ∏ i : Fin d, (1 - x * s.atom i)

theorem UnitSpectrum.spectralProduct_pos {d : ℕ}
    (s : UnitSpectrum d) (x : ℝ)
    (hx0 : 0 ≤ x) (hx1 : x < 1) :
    0 < s.spectralProduct x := by
  unfold UnitSpectrum.spectralProduct
  apply Finset.prod_pos
  intro i _
  have hi := (s.bounded i).2
  have hmul : x * s.atom i ≤ x := calc
    x * s.atom i ≤ x * 1 :=
      mul_le_mul_of_nonneg_left hi hx0
    _ = x := by ring
  linarith

theorem RH_TO_FINITE_STURM {d : ℕ}
    (hRH : _root_.RiemannHypothesis)
    (p : NativeZeroPacket d) (a : ℝ) (ha : 0 < a)
    (x : ℝ) (hx0 : 0 ≤ x) (hx1 : x < 1) :
    0 < ((criticalPacket_of_RH hRH p).toUnitSpectrum a ha).spectralProduct x := by
  exact UnitSpectrum.spectralProduct_pos _ x hx0 hx1

/-- Exact rational characteristic product for a checked rational spectrum. -/
def RationalSpectrum.spectralProduct {d : ℕ}
    (p : RationalSpectrum d) (x : ℚ) : ℚ :=
  ∏ i : Fin d, (1 - x * p.atom i)

theorem RationalSpectrum.spectralProduct_pos {d : ℕ}
    (p : RationalSpectrum d) (hp : p.check = true)
    (x : ℚ) (hx0 : 0 ≤ x) (hx1 : x < 1) :
    0 < p.spectralProduct x := by
  unfold RationalSpectrum.spectralProduct
  apply Finset.prod_pos
  intro i _
  have hi := (p.check_sound hp i).2
  have hmul : x * p.atom i ≤ x := calc
    x * p.atom i ≤ x * 1 :=
      mul_le_mul_of_nonneg_left hi hx0
    _ = x := by ring
  linarith

end RHForward
