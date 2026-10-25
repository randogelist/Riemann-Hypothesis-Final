import FiveInduction.LimitTransfer

/-!
# Zero exclusion under locally uniform convergence on a disk

This is a local version of the entire-limit transfer.  Its proof uses
isolated zeros and the proved minimum-modulus boundary argument.
-/

namespace FiveInduction.DiskTransfer

open Complex Metric Set Filter
open scoped Topology

theorem exists_small_nonzero_sphere_on {f : ℂ → ℂ} {s : Set ℂ}
    (hf : AnalyticOnNhd ℂ f s) (hs : IsPreconnected s)
    (hnt : ∃ w ∈ s, f w ≠ 0) {c : ℂ} (hc : c ∈ s)
    {R : ℝ} (hR : 0 < R) :
    ∃ r, 0 < r ∧ r < R ∧ ∀ z ∈ sphere c r, f z ≠ 0 := by
  have hi : ∀ᶠ z in 𝓝[≠] c, f z ≠ 0 := by
    rcases (hf c hc).eventually_eq_zero_or_eventually_ne_zero with hz | hn
    · obtain ⟨w, hws, hw⟩ := hnt
      have heq : EqOn f 0 s :=
        hf.eqOn_zero_of_preconnected_of_eventuallyEq_zero hs hc hz
      exact False.elim (hw (heq hws))
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

/-- A nontrivial holomorphic locally uniform limit of nonvanishing holomorphic
functions is nonvanishing on an open connected domain. -/
theorem nonzero_on_of_locally_uniform_limit
    {F : ℕ → ℂ → ℂ} {g : ℂ → ℂ} {s : Set ℂ}
    (hs : IsOpen s) (hconn : IsPreconnected s)
    (hF : ∀ n, DifferentiableOn ℂ (F n) s)
    (hne : ∀ n z, z ∈ s → F n z ≠ 0)
    (hg : DifferentiableOn ℂ g s) (hnt : ∃ w ∈ s, g w ≠ 0)
    (hu : TendstoLocallyUniformlyOn F g atTop s) :
    ∀ z ∈ s, g z ≠ 0 := by
  intro c hc
  obtain ⟨R, hR, hRs⟩ := Metric.isOpen_iff.mp hs c hc
  obtain ⟨r, hr, hrR, hsphere⟩ :=
    exists_small_nonzero_sphere_on (hg.analyticOnNhd hs) hconn hnt hc hR
  have hcb : closedBall c r ⊆ s := (closedBall_subset_ball hrR).trans hRs
  have hsp : sphere c r ⊆ s := sphere_subset_closedBall.trans hcb
  obtain ⟨w, hw, hmin⟩ := (isCompact_sphere c r).exists_isMinOn
    (NormedSpace.sphere_nonempty.mpr hr.le)
    (hg.continuousOn.norm.mono hsp)
  have hm : 0 < ‖g w‖ := norm_pos_iff.mpr (hsphere w hw)
  have hub : TendstoUniformlyOn F g atTop (sphere c r) :=
    (tendstoLocallyUniformlyOn_iff_forall_isCompact hs).mp hu
      (sphere c r) hsp (isCompact_sphere c r)
  exact LimitTransfer.nonzero_of_boundary_convergence hr hm
    (fun n => (hF n).mono hcb)
    (fun n z hz => hne n z (hcb hz)) hmin hub (hu.tendsto_at hc)

/-- Unit-disk specialization, with the normalization at zero excluding
the identically-zero limit. -/
theorem nonzero_on_unitDisk_of_locally_uniform_limit
    {F : ℕ → ℂ → ℂ} {g : ℂ → ℂ}
    (hF : ∀ n, DifferentiableOn ℂ (F n) (ball 0 1))
    (hne : ∀ n z, z ∈ ball 0 1 → F n z ≠ 0)
    (hg : DifferentiableOn ℂ g (ball 0 1)) (hg0 : g 0 ≠ 0)
    (hu : TendstoLocallyUniformlyOn F g atTop (ball 0 1)) :
    ∀ z ∈ ball 0 1, g z ≠ 0 := by
  apply nonzero_on_of_locally_uniform_limit isOpen_ball
    (convex_ball (0 : ℂ) 1).isPreconnected hF hne hg ?_ hu
  exact ⟨0, mem_ball_self (by norm_num), hg0⟩

end FiveInduction.DiskTransfer
