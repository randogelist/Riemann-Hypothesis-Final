import PositivityPremise.Kernel
import PositivityPremise.Scalar
import Mathlib.Topology.Algebra.InfiniteSum.Real

/-!
# Summable zero data and the positivity equivalence

The data below are explicit inputs. In particular, summability is never
inferred from Lean's totalized `tsum`: a divergent real `tsum` can be zero.
No zero simplicity assumption is used.
-/

noncomputable section

namespace PositivityPremise

/-- Upper-half-plane zero coordinates with positive integral multiplicities.
The analytic convergence obligations are explicit fields, not axioms. -/
structure ZeroData (ι : Type*) where
  multiplicity : ι → ℕ
  delta : ι → ℝ
  gamma : ι → ℝ
  multiplicity_pos : ∀ i, 0 < multiplicity i
  gamma_pos : ∀ i, 0 < gamma i
  strip : ∀ i, delta i ^ 2 ≤ (1 / 4 : ℝ)
  summable_mass : Summable (fun i => (multiplicity i : ℝ) / gamma i ^ 2)
  summable_defect : Summable (fun i => defect (multiplicity i) (delta i) (gamma i))

namespace ZeroData

variable {ι : Type*} (D : ZeroData ι)

def mass (i : ι) : ℝ := (D.multiplicity i : ℝ) / D.gamma i ^ 2
def contribution (i : ι) : ℝ := defect (D.multiplicity i) (D.delta i) (D.gamma i)
def c1 : ℝ := ∑' i, D.mass i
def C : ℝ := ∑' i, D.contribution i
def traceTerm (i : ι) : ℝ :=
  (D.multiplicity i : ℝ) * (D.gamma i ^ 2 - D.delta i ^ 2) /
    (D.gamma i ^ 2 + D.delta i ^ 2) ^ 2
def trace : ℝ := ∑' i, D.traceTerm i
def OnLine : Prop := ∀ i, D.delta i = 0

theorem multiplicity_real_pos (i : ι) : 0 < (D.multiplicity i : ℝ) := by
  exact_mod_cast D.multiplicity_pos i

theorem mass_nonneg (i : ι) : 0 ≤ D.mass i := by
  unfold mass
  positivity

theorem contribution_nonneg (i : ι) : 0 ≤ D.contribution i :=
  defect_nonneg (le_of_lt (D.multiplicity_real_pos i)) (D.gamma_pos i)

theorem c1_nonneg : 0 ≤ D.c1 := tsum_nonneg D.mass_nonneg

theorem C_nonneg : 0 ≤ D.C := tsum_nonneg D.contribution_nonneg

theorem contribution_le_C (i : ι) : D.contribution i ≤ D.C :=
  D.summable_defect.le_tsum i (fun j _ => D.contribution_nonneg j)

theorem C_eq_zero_iff_onLine : D.C = 0 ↔ D.OnLine := by
  constructor
  · intro h i
    apply (defect_eq_zero_iff (D.multiplicity_real_pos i) (D.gamma_pos i)).1
    apply le_antisymm
    · simpa only [h, contribution] using D.contribution_le_C i
    · exact D.contribution_nonneg i
  · intro h
    unfold C contribution
    have hz : ∀ i, defect (D.multiplicity i) (D.delta i) (D.gamma i) = 0 :=
      fun i => (defect_eq_zero_iff (D.multiplicity_real_pos i) (D.gamma_pos i)).2 (h i)
    simp only [hz, tsum_zero]

theorem positivityPremise_iff_onLine : PositivityPremise D.C D.c1 ↔ D.OnLine :=
  (positivityPremise_iff_eq_zero D.c1_nonneg).trans D.C_eq_zero_iff_onLine

theorem mass_sub_traceTerm (i : ι) : D.mass i - D.traceTerm i = D.contribution i :=
  defect_identity (D.gamma_pos i)

theorem traceTerm_eq_mass_sub_contribution (i : ι) :
    D.traceTerm i = D.mass i - D.contribution i := by
  have h := D.mass_sub_traceTerm i
  linarith

theorem summable_trace : Summable D.traceTerm := by
  have h := D.summable_mass.sub D.summable_defect
  exact h.congr (fun i => (D.traceTerm_eq_mass_sub_contribution i).symm)

theorem C_eq_c1_sub_trace : D.C = D.c1 - D.trace := by
  change (∑' i, D.contribution i) = (∑' i, D.mass i) - ∑' i, D.traceTerm i
  have hm : Summable D.mass := D.summable_mass
  rw [← hm.tsum_sub D.summable_trace]
  exact tsum_congr (fun i => (D.mass_sub_traceTerm i).symm)

/-- A single off-line zero gives a strictly positive total defect. -/
theorem C_pos_of_offLine (i : ι) (hi : D.delta i ≠ 0) : 0 < D.C := by
  have hne : D.contribution i ≠ 0 := by
    intro h
    exact hi ((defect_eq_zero_iff (D.multiplicity_real_pos i) (D.gamma_pos i)).1 h)
  exact lt_of_lt_of_le (lt_of_le_of_ne (D.contribution_nonneg i) (Ne.symm hne))
    (D.contribution_le_C i)

/-- The explicit lower bound from any one zero. -/
theorem lower_bound (i : ι) :
    3 * (D.multiplicity i : ℝ) * D.delta i ^ 2 /
      (D.gamma i ^ 2 + 1 / 4) ^ 2 ≤ D.C :=
  (defect_lower_bound (le_of_lt (D.multiplicity_real_pos i))
    (D.gamma_pos i) (D.strip i)).trans (D.contribution_le_C i)

/-- A distinct reflected upper-half-plane pair supplies the factor two.
Reflection, equal ordinates, and equal multiplicities are explicit inputs. -/
theorem reflected_pair_lower_bound (i j : ι) (hij : i ≠ j)
    (hm : D.multiplicity j = D.multiplicity i)
    (hg : D.gamma j = D.gamma i) (hd : D.delta j = -D.delta i) :
    6 * (D.multiplicity i : ℝ) * D.delta i ^ 2 /
      (D.gamma i ^ 2 + 1 / 4) ^ 2 ≤ D.C := by
  classical
  have hs := D.summable_defect.sum_le_tsum ({i, j} : Finset ι)
    (fun k _ => D.contribution_nonneg k)
  have heq : D.contribution j = D.contribution i := by
    simp only [contribution, defect, hm, hg, hd, neg_sq]
  have hl := defect_lower_bound (le_of_lt (D.multiplicity_real_pos i))
    (D.gamma_pos i) (D.strip i)
  have hsum : D.contribution i + D.contribution j ≤ D.C := by
    simpa only [Finset.sum_pair hij, C] using hs
  rw [heq] at hsum
  change 3 * (D.multiplicity i : ℝ) * D.delta i ^ 2 /
    (D.gamma i ^ 2 + 1 / 4) ^ 2 ≤ D.contribution i at hl
  calc
    6 * (D.multiplicity i : ℝ) * D.delta i ^ 2 /
        (D.gamma i ^ 2 + 1 / 4) ^ 2 =
        2 * (3 * (D.multiplicity i : ℝ) * D.delta i ^ 2 /
        (D.gamma i ^ 2 + 1 / 4) ^ 2) := by ring
    _ ≤ 2 * D.contribution i := mul_le_mul_of_nonneg_left hl (by norm_num)
    _ ≤ D.C := by linarith

end ZeroData
end PositivityPremise
