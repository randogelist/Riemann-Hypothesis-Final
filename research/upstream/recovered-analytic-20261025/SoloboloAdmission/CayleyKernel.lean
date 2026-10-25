import Mathlib

/-!
# Positive SOLOBOLO kernel and forward induction

All propositions in this file are pure finite real algebra. No claim about the
actual Riemann xi-function is assumed. For each positive model the SAME fixed
spectrum is propagated through every depth.
-/
set_option autoImplicit false
noncomputable section
namespace SoloboloAdmission

open scoped BigOperators

private def anchor : ℝ := 9 / 4

def denominator (a t : ℝ) : ℝ := a * t + anchor * (1 - t)

def cayleyQ (a t : ℝ) : ℝ :=
  4 * a * anchor * t * (1 - t) / (denominator a t) ^ 2

def baseKernel (a t : ℝ) : ℝ :=
  4 * a * anchor * (1 - t) / (denominator a t) ^ 2

/-- nth order actual SOLOBOLO-shaped kernel of one REAL contraction node. -/
def kernel (a t : ℝ) (n : ℕ) : ℝ :=
  baseKernel a t * cayleyQ a t ^ n

theorem denominator_pos {a t : ℝ} (ha : 0 < a)
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) : 0 < denominator a t := by
  have hb : 0 < anchor := by norm_num [anchor]
  have ht : 0 ≤ 1 - t := sub_nonneg.mpr ht1
  have hbt : 0 ≤ anchor * (1 - t) := mul_nonneg hb.le ht
  rcases lt_or_eq_of_le ht0 with hpos | hzero
  · exact add_pos_of_pos_of_nonneg (mul_pos ha hpos) hbt
  · have hz : t = 0 := hzero.symm
    subst t
    norm_num [denominator, anchor]

theorem cayleyQ_nonneg {a t : ℝ} (ha : 0 < a)
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) : 0 ≤ cayleyQ a t := by
  unfold cayleyQ
  have hb : 0 ≤ anchor := by norm_num [anchor]
  have ht : 0 ≤ 1 - t := sub_nonneg.mpr ht1
  have hn : 0 ≤ 4 * a * anchor * t * (1 - t) := by positivity
  exact div_nonneg hn (sq_nonneg _)

theorem cayleyQ_le_one {a t : ℝ} (ha : 0 < a)
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) : cayleyQ a t ≤ 1 := by
  have hden : 0 < (denominator a t) ^ 2 :=
    sq_pos_of_pos (denominator_pos ha ht0 ht1)
  have hsq := sq_nonneg (a * t - anchor * (1 - t))
  have hid : (denominator a t) ^ 2 -
      4 * a * anchor * t * (1 - t) =
      (a * t - anchor * (1 - t)) ^ 2 := by
    unfold denominator
    ring
  have hbound : 4 * a * anchor * t * (1 - t) ≤
      (denominator a t) ^ 2 := by linarith
  unfold cayleyQ
  exact (div_le_iff₀ hden).2 (by nlinarith)

theorem baseKernel_nonneg {a t : ℝ} (ha : 0 < a)
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) : 0 ≤ baseKernel a t := by
  unfold baseKernel
  have hb : 0 ≤ anchor := by norm_num [anchor]
  have ht : 0 ≤ 1 - t := sub_nonneg.mpr ht1
  have hn : 0 ≤ 4 * a * anchor * (1 - t) := by positivity
  exact div_nonneg hn (sq_nonneg _)

theorem kernel_succ (a t : ℝ) (n : ℕ) :
    kernel a t (n + 1) = kernel a t n * cayleyQ a t := by
  simp only [kernel, pow_succ]
  ring

theorem kernel_nonneg {a t : ℝ} (ha : 0 < a)
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) (n : ℕ) :
    0 ≤ kernel a t n := by
  exact mul_nonneg (baseKernel_nonneg ha ht0 ht1)
    (pow_nonneg (cayleyQ_nonneg ha ht0 ht1) n)

theorem kernel_succ_le {a t : ℝ} (ha : 0 < a)
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) (n : ℕ) :
    kernel a t (n + 1) ≤ kernel a t n := by
  rw [kernel_succ]
  calc
    kernel a t n * cayleyQ a t ≤ kernel a t n * 1 :=
      mul_le_mul_of_nonneg_left (cayleyQ_le_one ha ht0 ht1)
        (kernel_nonneg ha ht0 ht1 n)
    _ = kernel a t n := mul_one _

/-- Finite positive spectrum. The soundness source for its parameters is in
`RationalPackets.lean`, where bounds are checked by a terminating Boolean. -/
structure RealSpectrum (d : ℕ) where
  node : Fin d → ℝ
  mass : Fin d → ℝ
  node_bounds : ∀ i, 0 ≤ node i ∧ node i ≤ 1
  mass_nonneg : ∀ i, 0 ≤ mass i

def RealSpectrum.moment {d : ℕ} (S : RealSpectrum d)
    (a : ℝ) (n : ℕ) : ℝ :=
  ∑ i : Fin d, S.mass i * kernel a (S.node i) n

theorem RealSpectrum.moment_nonneg {d : ℕ} (S : RealSpectrum d)
    {a : ℝ} (ha : 0 < a) (n : ℕ) :
    0 ≤ S.moment a n := by
  unfold RealSpectrum.moment
  exact Finset.sum_nonneg (fun i _ =>
    mul_nonneg (S.mass_nonneg i)
      (kernel_nonneg ha (S.node_bounds i).1 (S.node_bounds i).2 n))

theorem RealSpectrum.moment_succ_le {d : ℕ} (S : RealSpectrum d)
    {a : ℝ} (ha : 0 < a) (n : ℕ) :
    S.moment a (n + 1) ≤ S.moment a n := by
  unfold RealSpectrum.moment
  apply Finset.sum_le_sum
  intro i hi
  exact mul_le_mul_of_nonneg_left
    (kernel_succ_le ha (S.node_bounds i).1 (S.node_bounds i).2 n)
    (S.mass_nonneg i)

end SoloboloAdmission
