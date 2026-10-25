import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Tactic

/-!
# Design 2: an actual orthogonal-projection orbit

The exact decrement is derived from the concrete vector update. It is not
passed in as a hypothesis. Identification of a Cayley coefficient readout is
a separate analytic task.
-/

namespace FiveInduction.Projection

set_option autoImplicit false

noncomputable section

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

def step (w v : E) : E := v - (inner ℝ w v / ‖w‖ ^ 2) • w

theorem exact_debit (w v : E) (hw : w ≠ 0) :
    ‖step w v‖ ^ 2 = ‖v‖ ^ 2 - (inner ℝ w v) ^ 2 / ‖w‖ ^ 2 := by
  have hn : ‖w‖ ≠ 0 := norm_ne_zero_iff.mpr hw
  unfold step
  rw [norm_sub_sq_real]
  simp only [real_inner_smul_right, norm_smul, Real.norm_eq_abs,
    mul_pow, sq_abs, real_inner_comm v w]
  field_simp [hn]
  ring

theorem step_norm_sq_le (w v : E) (hw : w ≠ 0) :
    ‖step w v‖ ^ 2 ≤ ‖v‖ ^ 2 := by
  rw [exact_debit w v hw]
  exact sub_le_self _ (div_nonneg (sq_nonneg _) (sq_nonneg _))

def trajectory (w : ℕ → E) (v₀ : E) : ℕ → E
  | 0 => v₀
  | n + 1 => step (w n) (trajectory w v₀ n)

theorem trajectory_exact_debit (w : ℕ → E) (v₀ : E)
    (hw : ∀ n, w n ≠ 0) (n : ℕ) :
    ‖trajectory w v₀ (n + 1)‖ ^ 2 = ‖trajectory w v₀ n‖ ^ 2 -
      (inner ℝ (w n) (trajectory w v₀ n)) ^ 2 / ‖w n‖ ^ 2 := by
  exact exact_debit (w n) (trajectory w v₀ n) (hw n)

theorem trajectory_norm_sq_le (w : ℕ → E) (v₀ : E)
    (hw : ∀ n, w n ≠ 0) (n : ℕ) :
    ‖trajectory w v₀ n‖ ^ 2 ≤ ‖v₀‖ ^ 2 := by
  induction n with
  | zero => rfl
  | succ n ih =>
      exact le_trans (step_norm_sq_le (w n) (trajectory w v₀ n) (hw n)) ih

theorem trajectory_norm_le (w : ℕ → E) (v₀ : E)
    (hw : ∀ n, w n ≠ 0) (n : ℕ) :
    ‖trajectory w v₀ n‖ ≤ ‖v₀‖ := by
  have h := trajectory_norm_sq_le w v₀ hw n
  nlinarith [norm_nonneg (trajectory w v₀ n), norm_nonneg v₀]

theorem readout_bound (w : ℕ → E) (v₀ u : E)
    (hw : ∀ n, w n ≠ 0) (n : ℕ) :
    |inner ℝ u (trajectory w v₀ n)| ≤ ‖u‖ * ‖v₀‖ := by
  calc
    |inner ℝ u (trajectory w v₀ n)| ≤ ‖u‖ * ‖trajectory w v₀ n‖ :=
      abs_real_inner_le_norm _ _
    _ ≤ ‖u‖ * ‖v₀‖ :=
      mul_le_mul_of_nonneg_left (trajectory_norm_le w v₀ hw n) (norm_nonneg u)

end

end FiveInduction.Projection
