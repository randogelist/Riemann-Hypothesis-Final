import RHForward.GramSturm

/-!
# Decidable rational Cayley–Sturm seed checker

The Boolean verifier is sound for EACH finite rational packet. It does not
silently certify a uniform all-N statement or the actual xi divisor.
-/

namespace RHForward

structure RationalSpectrum (d : ℕ) where
  atom : Fin d → ℚ

/-- Terminating finite exact rational test. -/
def RationalSpectrum.check {d : ℕ} (p : RationalSpectrum d) : Bool :=
  decide (∀ i : Fin d, 0 ≤ p.atom i ∧ p.atom i ≤ 1)

theorem RationalSpectrum.check_sound {d : ℕ}
    (p : RationalSpectrum d) (hp : p.check = true) :
    ∀ i : Fin d, 0 ≤ p.atom i ∧ p.atom i ≤ 1 := by
  exact of_decide_eq_true hp

/-- Accepted rational packet -> positive real contraction spectrum. -/
noncomputable def RationalSpectrum.toUnitSpectrum {d : ℕ}
    (p : RationalSpectrum d) (hp : p.check = true) : UnitSpectrum d where
  atom := fun i => (p.atom i : ℝ)
  bounded := by
    intro i
    obtain ⟨h0, h1⟩ := p.check_sound hp i
    constructor
    · exact_mod_cast h0
    · exact_mod_cast h1

/-- Any successfully checked rational packet has all Hausdorff cells. -/
theorem checked_rational_all_Hausdorff {d : ℕ}
    (p : RationalSpectrum d) (hp : p.check = true) :
    ∀ n k, 0 ≤ (p.toUnitSpectrum hp).cell n k := by
  intro n k
  exact UnitSpectrum.cell_nonneg _ _ _

/-- Any accepted rational packet has both localizing Gram square forms. -/
theorem checked_rational_Gram {d n : ℕ}
    (p : RationalSpectrum d) (hp : p.check = true)
    (c : Fin n → ℝ) :
    0 ≤ (p.toUnitSpectrum hp).gramShifted c ∧
    0 ≤ (p.toUnitSpectrum hp).gramComplement c := by
  exact ⟨UnitSpectrum.gramShifted_nonneg _ _,
    UnitSpectrum.gramComplement_nonneg _ _⟩

/-- Exact rational spectrum examples exercise the Boolean code. -/
def demo : RationalSpectrum 2 where
  atom := ![(1 / 4 : ℚ), (3 / 4 : ℚ)]

example : demo.check = true := by
  decide

end RHForward
