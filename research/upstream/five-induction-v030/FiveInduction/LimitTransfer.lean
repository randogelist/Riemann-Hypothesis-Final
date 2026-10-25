import Mathlib.Analysis.Complex.AbsMax
import Mathlib.Analysis.Analytic.IsolatedZeros
import Mathlib.Topology.UniformSpace.LocallyUniformConvergence
import Mathlib.Tactic

namespace FiveInduction.LimitTransfer

open Complex Metric Set Filter
open scoped Topology

/-- Minimum modulus on a closed disk, obtained from the maximum modulus of the reciprocal. -/
theorem disk_lower_bound {f : ℂ → ℂ} {c : ℂ} {r m : ℝ}
    (hr : 0 < r) (hm : 0 < m)
    (hf : DifferentiableOn ℂ f (closedBall c r))
    (hne : ∀ z ∈ closedBall c r, f z ≠ 0)
    (hb : ∀ z ∈ sphere c r, m ≤ ‖f z‖) :
    m ≤ ‖f c‖ := by
  have hdc : DiffContOnCl ℂ (fun z => (f z)⁻¹) (ball c r) := by
    apply DifferentiableOn.diffContOnCl
    rw [closure_ball c hr.ne']
    exact hf.inv hne
  have hbound : ‖(f c)⁻¹‖ ≤ m⁻¹ := by
    apply Complex.norm_le_of_forall_mem_frontier_norm_le (isBounded_ball) hdc
    · intro z hz
      rw [frontier_ball c hr.ne'] at hz
      rw [norm_inv]
      exact inv_anti₀ hm (hb z hz)
    · exact subset_closure (mem_ball_self hr)
  rw [norm_inv] at hbound
  exact (inv_le_inv₀ (norm_pos_iff.mpr (hne c (mem_closedBall_self hr.le))) hm).mp hbound

/-- A nonvanishing analytic sequence cannot converge to zero at the center while
remaining uniformly bounded away from zero on the boundary. -/
theorem nonzero_of_boundary_convergence
    {F : ℕ → ℂ → ℂ} {f : ℂ → ℂ} {c : ℂ} {r m : ℝ}
    (hr : 0 < r) (hm : 0 < m)
    (hF : ∀ n, DifferentiableOn ℂ (F n) (closedBall c r))
    (hne : ∀ n z, z ∈ closedBall c r → F n z ≠ 0)
    (hb : ∀ z ∈ sphere c r, m ≤ ‖f z‖)
    (hu : TendstoUniformlyOn F f atTop (sphere c r))
    (hc : Tendsto (fun n => F n c) atTop (𝓝 (f c))) : f c ≠ 0 := by
  have he : ∀ᶠ n in atTop, ∀ z ∈ sphere c r, dist (f z) (F n z) < m / 2 :=
    (Metric.tendstoUniformlyOn_iff.mp hu) (m / 2) (by positivity)
  have hl : ∀ᶠ n in atTop, m / 2 ≤ ‖F n c‖ := by
    filter_upwards [he] with n hn
    apply disk_lower_bound hr (by positivity) (hF n) (hne n)
    intro z hz
    have ht := norm_le_norm_add_norm_sub (F n z) (f z)
    have hd := hn z hz
    rw [dist_eq_norm] at hd
    rw [norm_sub_rev] at ht
    linarith [hb z hz]
  have hlimit : m / 2 ≤ ‖f c‖ := ge_of_tendsto hc.norm hl
  intro hz
  rw [hz, norm_zero] at hlimit
  linarith

/-- A nonzero entire function has a small circle without zeros around any point. -/
theorem exists_small_nonzero_sphere {f : ℂ → ℂ}
    (hf : Differentiable ℂ f) (hnt : ∃ w, f w ≠ 0)
    (c : ℂ) {R : ℝ} (hR : 0 < R) :
    ∃ r, 0 < r ∧ r < R ∧ ∀ z ∈ sphere c r, f z ≠ 0 := by
  have hi : ∀ᶠ z in 𝓝[≠] c, f z ≠ 0 := by
    rcases (hf.analyticAt c).eventually_eq_zero_or_eventually_ne_zero with hz | hn
    · obtain ⟨w, hw⟩ := hnt
      have ha : AnalyticOnNhd ℂ f univ := fun z _ => hf.analyticAt z
      have heq : EqOn f 0 univ :=
        ha.eqOn_zero_of_preconnected_of_eventuallyEq_zero
          isPreconnected_univ (mem_univ c) hz
      exact False.elim (hw (heq (mem_univ w)))
    · exact hn
  obtain ⟨ε, hε, he⟩ := Metric.mem_nhdsWithin_iff.mp hi
  let r := min ε R / 2
  have hr : 0 < r := by dsimp [r]; positivity
  have hre : r < ε := by dsimp [r]; linarith [min_le_left ε R]
  have hrR : r < R := by dsimp [r]; linarith [min_le_right ε R]
  refine ⟨r, hr, hrR, ?_⟩
  intro z hz
  apply he
  constructor
  · rw [mem_ball, mem_sphere.mp hz]
    exact hre
  · simp only [mem_compl_iff, mem_singleton_iff]
    intro hzc
    subst z
    have := mem_sphere.mp hz
    simp only [dist_self] at this
    linarith

/-- Entire locally uniform limits of entire functions with only real zeros
also have only real zeros, provided the limit is not identically zero. -/
theorem real_zeros_of_locally_uniform_limit
    {F : ℕ → ℂ → ℂ} {f : ℂ → ℂ}
    (hF : ∀ n, Differentiable ℂ (F n))
    (hreal : ∀ n z, z.im ≠ 0 → F n z ≠ 0)
    (hf : Differentiable ℂ f) (hnt : ∃ w, f w ≠ 0)
    (hu : TendstoLocallyUniformly F f atTop) :
    ∀ z, f z = 0 → z.im = 0 := by
  intro c hc
  by_contra hci
  obtain ⟨r, hr, hri, hsphere⟩ :=
    exists_small_nonzero_sphere hf hnt c (abs_pos.mpr hci)
  have hcb : ∀ z ∈ closedBall c r, z.im ≠ 0 := by
    intro z hz hzi
    have hn := Complex.abs_im_le_norm (z - c)
    simp only [Complex.sub_im, hzi, zero_sub, abs_neg] at hn
    have hd : ‖z - c‖ ≤ r := by simpa only [mem_closedBall, dist_eq_norm] using hz
    linarith
  obtain ⟨w, hw, hmin⟩ := (isCompact_sphere c r).exists_isMinOn
    (NormedSpace.sphere_nonempty.mpr hr.le) hf.continuous.norm.continuousOn
  have hm : 0 < ‖f w‖ := norm_pos_iff.mpr (hsphere w hw)
  have hbound : ∀ z ∈ sphere c r, ‖f w‖ ≤ ‖f z‖ := hmin
  have hub : TendstoUniformlyOn F f atTop (sphere c r) :=
    (tendstoLocallyUniformly_iff_forall_isCompact.mp hu) _ (isCompact_sphere c r)
  have huc : Tendsto (fun n => F n c) atTop (𝓝 (f c)) :=
    (hu.tendstoLocallyUniformlyOn (s := univ)).tendsto_at (mem_univ c)
  exact nonzero_of_boundary_convergence hr hm
    (fun n => (hF n).differentiableOn)
    (fun n z hz => hreal n z (hcb z hz)) hbound hub huc hc

end FiveInduction.LimitTransfer
