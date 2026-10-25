import FiveInduction.HardyTail

noncomputable section

namespace FiveInduction.HardyCompleteness

open Filter Topology Set
open FiveInduction.HardyDefect

theorem partial_tendsto {c : ℕ → ℂ} {w z : ℂ}
    (h : HasSum (fun k => c k * w ^ k) z) :
    Tendsto (fun N => «partial» c N w) atTop (𝓝 z) := by
  simpa only [«partial», Function.comp_def] using h.tendsto_sum_nat.comp (tendsto_add_atTop_nat 1)

theorem mass_tendsto {c : ℕ → ℂ} {K : ℝ}
    (h : HasSum (fun k => Complex.normSq (c k)) K) :
    Tendsto (fun N => mass c N) atTop (𝓝 K) := by
  simpa only [mass, Function.comp_def] using h.tendsto_sum_nat.comp (tendsto_add_atTop_nat 1)

theorem tailMass_tendsto_zero {c : ℕ → ℂ} {K : ℝ}
    (h : HasSum (fun k => Complex.normSq (c k)) K) :
    Tendsto (fun N => tailMass c K N) atTop (𝓝 0) := by
  simpa only [tailMass, sub_self] using (tendsto_const_nhds (x := K)).sub (mass_tendsto h)

theorem defect_tendsto {c : ℕ → ℂ} {K : ℝ} {w z : ℂ}
    (henergy : HasSum (fun k => Complex.normSq (c k)) K)
    (hseries : HasSum (fun k => c k * w ^ k) z)
    (hw : Complex.normSq w < 1) :
    Tendsto (fun N => defect c K N w) atTop
      (𝓝 ((1 - Complex.normSq w) * Complex.normSq z)) := by
  have hp := Complex.continuous_normSq.continuousAt.tendsto.comp
    (partial_tendsto hseries)
  have hpow : Tendsto (fun N : ℕ => Complex.normSq w ^ (N + 1)) atTop (𝓝 0) :=
    (tendsto_pow_atTop_nhds_zero_of_lt_one (Complex.normSq_nonneg w) hw).comp
      (tendsto_add_atTop_nat 1)
  simpa only [defect, Function.comp_def, zero_mul, sub_zero] using
    (tendsto_const_nhds.mul hp).sub ((tailMass_tendsto_zero henergy).mul hpow)

theorem exists_positive_defect_of_nonzero {c : ℕ → ℂ} {K : ℝ} {w z : ℂ}
    (henergy : HasSum (fun k => Complex.normSq (c k)) K)
    (hseries : HasSum (fun k => c k * w ^ k) z)
    (hw : Complex.normSq w < 1) (hz : z ≠ 0) :
    ∃ N : ℕ, 0 < defect c K N w := by
  have hpos : 0 < (1 - Complex.normSq w) * Complex.normSq z :=
    mul_pos (sub_pos.mpr hw) (Complex.normSq_pos.mpr hz)
  have hevent := (defect_tendsto henergy hseries hw).eventually
    (Ioi_mem_nhds hpos)
  exact hevent.exists

theorem nonzero_iff_exists_positive_defect {c : ℕ → ℂ} {K : ℝ} {w z : ℂ}
    (henergy : HasSum (fun k => Complex.normSq (c k)) K)
    (hseries : HasSum (fun k => c k * w ^ k) z)
    (hw : Complex.normSq w < 1) :
    z ≠ 0 ↔ ∃ N : ℕ, 0 < defect c K N w := by
  constructor
  · exact exists_positive_defect_of_nonzero henergy hseries hw
  · rintro ⟨N, hN⟩
    exact HardyTail.nonzero_of_defect_pos henergy hseries hw N hN

theorem zero_iff_all_defect_nonpos {c : ℕ → ℂ} {K : ℝ} {w z : ℂ}
    (henergy : HasSum (fun k => Complex.normSq (c k)) K)
    (hseries : HasSum (fun k => c k * w ^ k) z)
    (hw : Complex.normSq w < 1) :
    z = 0 ↔ ∀ N : ℕ, defect c K N w ≤ 0 := by
  constructor
  · intro hz
    subst z
    exact HardyTail.defect_nonpos_of_zero henergy hseries hw
  · intro h
    by_contra hz
    obtain ⟨N, hN⟩ := exists_positive_defect_of_nonzero henergy hseries hw hz
    exact (not_lt_of_ge (h N)) hN

theorem continuous_partial (c : ℕ → ℂ) (N : ℕ) :
    Continuous («partial» c N) := by
  unfold «partial»
  fun_prop

theorem continuous_defect (c : ℕ → ℂ) (K : ℝ) (N : ℕ) :
    Continuous (defect c K N) := by
  unfold defect
  exact ((continuous_const.sub Complex.continuous_normSq).mul
    (Complex.continuous_normSq.comp (continuous_partial c N))).sub
      (continuous_const.mul (Complex.continuous_normSq.pow (N + 1)))

theorem isOpen_positive_defect (c : ℕ → ℂ) (K : ℝ) (N : ℕ) :
    IsOpen {w : ℂ | 0 < defect c K N w} :=
  isOpen_lt continuous_const (continuous_defect c K N)

theorem exists_uniform_positive_defect_on_compact
    {c : ℕ → ℂ} {K : ℝ} {f : ℂ → ℂ} {S : Set ℂ}
    (hc : c 0 = 1)
    (henergy : HasSum (fun k => Complex.normSq (c k)) K)
    (hcompact : IsCompact S)
    (hinside : ∀ w ∈ S, Complex.normSq w < 1)
    (hseries : ∀ w ∈ S, HasSum (fun k => c k * w ^ k) (f w))
    (hnonzero : ∀ w ∈ S, f w ≠ 0) :
    ∃ N : ℕ, ∀ w ∈ S, 0 < defect c K N w := by
  apply hcompact.elim_directed_cover (fun N => {w : ℂ | 0 < defect c K N w})
    (isOpen_positive_defect c K)
  · intro w hw
    obtain ⟨N, hN⟩ := exists_positive_defect_of_nonzero henergy
      (hseries w hw) (hinside w hw) (hnonzero w hw)
    exact mem_iUnion.mpr ⟨N, hN⟩
  · intro M N
    refine ⟨max M N, ?_, ?_⟩
    · intro w hw
      exact defect_pos_of_le c K w hc (le_max_left M N) hw
    · intro w hw
      exact defect_pos_of_le c K w hc (le_max_right M N) hw

theorem exists_uniform_positive_defect_on_disk
    {c : ℕ → ℂ} {K r : ℝ} {f : ℂ → ℂ}
    (hc : c 0 = 1)
    (henergy : HasSum (fun k => Complex.normSq (c k)) K)
    (hr : r < 1)
    (hseries : ∀ w : ℂ, ‖w‖ < 1 → HasSum (fun k => c k * w ^ k) (f w))
    (hnonzero : ∀ w : ℂ, ‖w‖ ≤ r → f w ≠ 0) :
    ∃ N : ℕ, ∀ w : ℂ, ‖w‖ ≤ r → 0 < defect c K N w := by
  have hbound {w : ℂ} (hw : w ∈ Metric.closedBall (0 : ℂ) r) : ‖w‖ ≤ r := by
    simpa only [Metric.mem_closedBall, dist_zero_right] using hw
  obtain ⟨N, hN⟩ := exists_uniform_positive_defect_on_compact hc henergy
    (isCompact_closedBall (0 : ℂ) r)
    (fun w hw => by
      rw [Complex.normSq_eq_norm_sq]
      have hn : ‖w‖ < 1 := lt_of_le_of_lt (hbound hw) hr
      nlinarith [norm_nonneg w])
    (fun w hw => hseries w (lt_of_le_of_lt (hbound hw) hr))
    (fun w hw => hnonzero w (hbound hw))
  refine ⟨N, fun w hw => hN w ?_⟩
  simpa only [Metric.mem_closedBall, dist_zero_right] using hw

theorem nonzero_on_disk_iff_finite_certificate
    {c : ℕ → ℂ} {K r : ℝ} {f : ℂ → ℂ}
    (hc : c 0 = 1)
    (henergy : HasSum (fun k => Complex.normSq (c k)) K)
    (hr : r < 1)
    (hseries : ∀ w : ℂ, ‖w‖ < 1 → HasSum (fun k => c k * w ^ k) (f w)) :
    (∀ w : ℂ, ‖w‖ ≤ r → f w ≠ 0) ↔
      ∃ N : ℕ, ∀ w : ℂ, ‖w‖ ≤ r → 0 < defect c K N w := by
  constructor
  · exact exists_uniform_positive_defect_on_disk hc henergy hr hseries
  · rintro ⟨N, hN⟩ w hw
    have hw1 : ‖w‖ < 1 := lt_of_le_of_lt hw hr
    have hsq : Complex.normSq w < 1 := by
      rw [Complex.normSq_eq_norm_sq]
      nlinarith [norm_nonneg w]
    exact HardyTail.nonzero_of_defect_pos henergy (hseries w hw1) hsq N (hN w hw)

/-- Every prescribed compact subdisk has a strictly positive finite defect. -/
def DiskExhaustion (c : ℕ → ℂ) (K : ℝ) : Prop :=
  ∀ r : ℝ, 0 < r → r < 1 →
    ∃ N : ℕ, ∀ w : ℂ, ‖w‖ ≤ r → 0 < defect c K N w

theorem diskExhaustion_iff_nonzero
    {c : ℕ → ℂ} {K : ℝ} {f : ℂ → ℂ}
    (hc : c 0 = 1)
    (henergy : HasSum (fun k => Complex.normSq (c k)) K)
    (hseries : ∀ w : ℂ, ‖w‖ < 1 → HasSum (fun k => c k * w ^ k) (f w)) :
    DiskExhaustion c K ↔ ∀ w : ℂ, ‖w‖ < 1 → f w ≠ 0 := by
  constructor
  · intro hexhaust w hw
    let r : ℝ := (‖w‖ + 1) / 2
    have hr0 : 0 < r := by dsimp [r]; linarith [norm_nonneg w]
    have hr1 : r < 1 := by dsimp [r]; linarith
    have hwr : ‖w‖ ≤ r := by dsimp [r]; linarith
    exact ((nonzero_on_disk_iff_finite_certificate hc henergy hr1 hseries).mpr
      (hexhaust r hr0 hr1)) w hwr
  · intro hn r _ hr
    exact exists_uniform_positive_defect_on_disk hc henergy hr hseries
      (fun w hw => hn w (lt_of_le_of_lt hw hr))

end FiveInduction.HardyCompleteness
