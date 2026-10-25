import Mathlib

/-!
# Native actual-zeta zero channels

The predicate below agrees definitionally with the three hypotheses of
Mathlib's `_root_.RiemannHypothesis`.  It does not assert RH and does not
postulate any zero distribution.
-/

namespace RHAdmission

/-- The actual, nontrivial Riemann-zeta zero predicate, including Mathlib's
    exceptional-value exclusion. -/
def ActualNontrivialZero (s : ℂ) : Prop :=
  riemannZeta s = 0 ∧
  (¬ ∃ n : ℕ, s = -2 * (n + 1)) ∧
  s ≠ 1

/-- The real displacement from the critical line. -/
def criticalOffset (s : ℂ) : ℝ := s.re - 1 / 2

/-- Exactly the numerator `4δ²` of the normalized fixed-anchor Cayley
    expansion defect; this definition deliberately omits its denominator. -/
def cayleyNumerator (s : ℂ) : ℝ := 4 * criticalOffset s ^ 2

/-- A canonical strictly expanding *algebraic* two-mode channel off the line.
    It is NOT a claim of equivalence with the earlier Mellin--zero trace model. -/
def channelGain (s : ℂ) : ℝ := 1 + cayleyNumerator s

theorem cayleyNumerator_nonneg (s : ℂ) : 0 ≤ cayleyNumerator s := by
  unfold cayleyNumerator
  positivity

theorem channelGain_one_le (s : ℂ) : 1 ≤ channelGain s := by
  unfold channelGain
  have h := cayleyNumerator_nonneg s
  linarith

theorem channelGain_pos (s : ℂ) : 0 < channelGain s := by
  have h := channelGain_one_le s
  linarith

theorem channelGain_ne_zero (s : ℂ) : channelGain s ≠ 0 :=
  ne_of_gt (channelGain_pos s)

theorem criticalOffset_eq_zero_iff (s : ℂ) :
    criticalOffset s = 0 ↔ s.re = 1 / 2 := by
  unfold criticalOffset
  constructor <;> intro h <;> linarith

theorem channelGain_eq_one_iff (s : ℂ) :
    channelGain s = 1 ↔ s.re = 1 / 2 := by
  constructor
  · intro h
    have hsq : (criticalOffset s) ^ 2 = 0 := by
      unfold channelGain cayleyNumerator at h
      nlinarith
    have hz : criticalOffset s = 0 := by nlinarith [hsq]
    exact (criticalOffset_eq_zero_iff s).mp hz
  · intro h
    have hoff : criticalOffset s = 0 := (criticalOffset_eq_zero_iff s).mpr h
    simp [channelGain, cayleyNumerator, hoff]

/-- RH is exactly rigidity of Mathlib's actual nontrivial zero predicate. -/
theorem native_RH_iff_actual_zero_rigidity :
    _root_.RiemannHypothesis ↔
      (∀ s : ℂ, ActualNontrivialZero s → s.re = 1 / 2) := by
  constructor
  · intro h s hz
    exact h s hz.1 hz.2.1 hz.2.2
  · intro h s hz htriv hne
    exact h s ⟨hz, htriv, hne⟩

end RHAdmission
