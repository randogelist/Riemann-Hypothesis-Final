import FiveInduction.SOS
import FiveInduction.SOSGeometry
import Mathlib.Topology.Order.Basic

/-!
# The actual angular SOS input and its conditional RH endpoint

The only research input is pointwise convergence of positive SOS orbits to
the angular derivative at every positive radius and every interior angle.
All analytic identification and angular exclusion lemmas are proved.
-/

noncomputable section
open Set Filter
open scoped Topology

namespace FiveInduction.SOSInput

theorem xi_identification (s : ℂ) : SOSGeometry.xi s = ActualXi.xi s := by
  unfold SOSGeometry.xi ActualXi.xi
  ring

theorem theta_identification (z : ℂ) :
    SOSGeometry.theta z = ActualXi.xi ((1 / 2 : ℂ) + Complex.sqrt z) := by
  exact xi_identification _

/-- The actual pointwise SOS realization target; no witness is supplied. -/
def SOSXiRealization : Prop :=
  ∀ r : ℝ, 0 < r →
    ∃ (δ : ℝ) (κ : ℕ → ℝ) (A B : ℕ → Polynomial ℝ),
      0 < δ ∧ (∀ n, 0 < κ n) ∧
      ∀ x ∈ Ioo (-1 : ℝ) 1,
        Tendsto (fun n => (SOS.sequence δ κ A B n).eval x) atTop
          (𝓝 (deriv (SOSGeometry.actualProfile r) x))

theorem actual_derivative_nonnegative (h : SOSXiRealization)
    (r : ℝ) (hr : 0 < r) (x : ℝ) (hx : x ∈ Ioo (-1 : ℝ) 1) :
    0 ≤ deriv (SOSGeometry.actualProfile r) x := by
  obtain ⟨δ, κ, A, B, hδ, hκ, hconv⟩ := h r hr
  exact le_of_tendsto_of_tendsto tendsto_const_nhds (hconv x hx) (Filter.Eventually.of_forall
    (fun n => (SOS.all_positive δ κ A B hδ hκ n x ⟨hx.1.le, hx.2.le⟩).le))

theorem full_angular_input (h : SOSXiRealization) :
    SOSGeometry.CutoffDerivativeNonnegative (-1) := by
  intro r hr x hx
  change 0 ≤ derivWithin (SOSGeometry.actualProfile r) (Icc (-1) 1) x
  rw [derivWithin_of_mem_nhds (Icc_mem_nhds hx.1 hx.2)]
  exact actual_derivative_nonnegative h r hr x hx

theorem squared_shift_in_sector (s : ℂ) (hs : s.re ≠ 1 / 2) :
    let z := (s - (1 / 2 : ℂ)) ^ 2
    z ≠ 0 ∧ -1 < z.re / ‖z‖ := by
  dsimp only
  have hshift : s - (1 / 2 : ℂ) ≠ 0 := by
    intro hz
    apply hs
    have h := congrArg Complex.re hz
    norm_num at h
    linarith
  have hz : (s - (1 / 2 : ℂ)) ^ 2 ≠ 0 := pow_ne_zero _ hshift
  refine ⟨hz, ?_⟩
  have hnorm : 0 < ‖(s - (1 / 2 : ℂ)) ^ 2‖ := norm_pos_iff.mpr hz
  apply (lt_div_iff₀ hnorm).mpr
  have hsq : 0 < (s.re - 1 / 2) ^ 2 := sq_pos_of_ne_zero (sub_ne_zero.mpr hs)
  rw [norm_pow]
  rw [← Complex.normSq_eq_norm_sq]
  simp only [Complex.normSq_apply, Complex.sub_re, Complex.sub_im,
    Complex.div_re, Complex.div_im, Complex.one_re, Complex.one_im,
    pow_two, Complex.mul_re]
  norm_num at *
  nlinarith

/-- The complete SOS chain concludes literal Mathlib RH. -/
theorem RH_OF_SOS_REALIZATION (h : SOSXiRealization) : RiemannHypothesis := by
  intro s hz htrivial hs1
  by_contra hline
  have hsector := squared_shift_in_sector s hline
  have hnonzero := SOSGeometry.actual_theta_ne_zero_of_angular_cutoff
    (a := -1) (by norm_num) (full_angular_input h) hsector.1 hsector.2
  apply hnonzero
  rw [SOSGeometry.theta_square]
  change SOSGeometry.xi ((1 / 2 : ℂ) + (s - 1 / 2)) = 0
  rw [xi_identification]
  have harg : (1 / 2 : ℂ) + (s - 1 / 2) = s := by ring
  rw [harg]
  exact ActualXi.xi_zero_of_nontrivial_zeta_zero hz htrivial hs1

end FiveInduction.SOSInput
