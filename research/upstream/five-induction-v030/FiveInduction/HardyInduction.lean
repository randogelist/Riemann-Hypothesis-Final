import FiveInduction.HardyEndpoint

/-!
# Prescribed-radius induction

The finite coefficient recurrence preserves a certificate at its current
radius. Advancing to each next prescribed radius is a separate input.
-/

namespace FiveInduction.HardyInduction

open Filter
open scoped Topology
open FiveInduction.HardyActual FiveInduction.HardyEndpoint

noncomputable section

def radius (n : ℕ) : ℝ := 1 - (1 / 2 : ℝ) ^ (n + 1)

@[simp] theorem radius_zero : radius 0 = 1 / 2 := by norm_num [radius]

theorem radius_pos (n : ℕ) : 0 < radius n := by
  unfold radius
  exact sub_pos.mpr (pow_lt_one₀ (by norm_num) (by norm_num) (by omega))

theorem radius_lt_one (n : ℕ) : radius n < 1 := by
  unfold radius
  have h : 0 < (1 / 2 : ℝ) ^ (n + 1) := by positivity
  linarith

theorem radius_tendsto_one : Tendsto radius atTop (𝓝 1) := by
  change Tendsto (fun n : ℕ => 1 - (1 / 2 : ℝ) ^ (n + 1)) atTop (𝓝 1)
  have h : Tendsto (fun n : ℕ => (1 / 2 : ℝ) ^ (n + 1)) atTop (𝓝 0) :=
    (tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num : (0 : ℝ) ≤ 1 / 2)
      (by norm_num : (1 / 2 : ℝ) < 1)).comp (tendsto_add_atTop_nat 1)
  simpa only [sub_zero] using (tendsto_const_nhds (x := (1 : ℝ))).sub h

def PrescribedRadiusStep : Prop :=
  ∀ n : ℕ, FiniteDiskCertificate (radius n) → FiniteDiskCertificate (radius (n + 1))

theorem base : FiniteDiskCertificate (radius 0) := by
  simpa using ACTUAL_BASE_CERTIFICATE

theorem all_stages_of_step (hstep : PrescribedRadiusStep) :
    ∀ n : ℕ, FiniteDiskCertificate (radius n) := by
  intro n
  induction n with
  | zero => exact base
  | succ n ih => exact hstep n ih

theorem exhaustion_of_all_stages
    (hall : ∀ n : ℕ, FiniteDiskCertificate (radius n)) : ActualDiskExhaustion := by
  intro r _ hr
  have hevent := radius_tendsto_one.eventually (Ioi_mem_nhds hr)
  obtain ⟨n, hn⟩ := hevent.exists
  obtain ⟨N, hN⟩ := hall n
  exact ⟨N, fun w hw => hN w (hw.trans hn.le)⟩

theorem exhaustion_of_step (hstep : PrescribedRadiusStep) : ActualDiskExhaustion :=
  exhaustion_of_all_stages (all_stages_of_step hstep)

theorem prescribed_step_iff_exhaustion : PrescribedRadiusStep ↔ ActualDiskExhaustion := by
  constructor
  · exact exhaustion_of_step
  · intro hexhaust n _
    exact hexhaust (radius (n + 1)) (radius_pos (n + 1)) (radius_lt_one (n + 1))

theorem RH_OF_PRESCRIBED_RADIUS_STEP
    (henergy : ActualHardyEnergy) (hstep : PrescribedRadiusStep) : RiemannHypothesis :=
  RH_OF_ACTUAL_HARDY_EXHAUSTION henergy (exhaustion_of_step hstep)

theorem RH_IFF_PRESCRIBED_RADIUS_STEP (henergy : ActualHardyEnergy) :
    RiemannHypothesis ↔ PrescribedRadiusStep :=
  (RH_IFF_ACTUAL_DISK_EXHAUSTION henergy).trans prescribed_step_iff_exhaustion.symm

end
end FiveInduction.HardyInduction
