import Mathlib

/-!
# Candidate C / RH-forward finite Cayley geometry

This is an unconditional REAL calculation. It does not assume RH, a
spectral divisor formula, or a fabricated positive xi moment family.
-/

namespace RHForward

/-- The rational fractional parameter used by the Cayley map. -/
noncomputable def cayleyU (a lambda : ℝ) : ℝ := lambda / (a + lambda)

/-- Cayley/QQRH quadratic channel. -/
def cayleyQ (u : ℝ) : ℝ := 4 * u * (1 - u)

def cayleyC (u : ℝ) : ℝ := 1 - 2 * u

/-- The exact sum-of-squares identity `q + c² = 1`. -/
theorem cayleyQ_add_cayleyC_sq (u : ℝ) :
    cayleyQ u + (cayleyC u)^2 = 1 := by
  unfold cayleyQ cayleyC
  ring

/-- Real positive scales produce a parameter in the closed unit interval. -/
theorem cayleyU_unit_interval {a lambda : ℝ}
    (ha : 0 < a) (hl : 0 ≤ lambda) :
    0 ≤ cayleyU a lambda ∧ cayleyU a lambda ≤ 1 := by
  have hd : 0 < a + lambda := by linarith
  constructor
  · unfold cayleyU
    exact div_nonneg hl (le_of_lt hd)
  · unfold cayleyU
    apply (div_le_iff₀ hd).2
    linarith

/-- Exact contractivity of the Cayley channel. -/
theorem cayleyQ_unit_interval {u : ℝ}
    (hu0 : 0 ≤ u) (hu1 : u ≤ 1) :
    0 ≤ cayleyQ u ∧ cayleyQ u ≤ 1 := by
  constructor
  · unfold cayleyQ
    exact mul_nonneg (mul_nonneg (by norm_num : (0 : ℝ) ≤ 4) hu0)
      (sub_nonneg.mpr hu1)
  · have hs : 0 ≤ (2 * u - 1)^2 := sq_nonneg _
    unfold cayleyQ
    nlinarith

/-- A real scale needs no RH to give a contractive Cayley factor. -/
theorem real_scale_cayley_contracts {a lambda : ℝ}
    (ha : 0 < a) (hl : 0 ≤ lambda) :
    0 ≤ cayleyQ (cayleyU a lambda) ∧
      cayleyQ (cayleyU a lambda) ≤ 1 := by
  exact cayleyQ_unit_interval
    (cayleyU_unit_interval ha hl).1
    (cayleyU_unit_interval ha hl).2

end RHForward
