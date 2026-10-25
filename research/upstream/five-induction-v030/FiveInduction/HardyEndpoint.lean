import FiveInduction.HardyActual
import FiveInduction.HardyCompleteness
import FiveInduction.HardySeed
import FiveInduction.HardyConstants

/-!
# The actual coefficient-defect chain

The actual zeta normalization and its Taylor series are already identified.
The exact Hardy energy and exhaustion of all compact subdisks remain explicit
inputs. Coefficient-index positivity propagation does not supply exhaustion.
-/

namespace FiveInduction.HardyEndpoint

open Filter
open scoped Topology
open FiveInduction.HardyActual

noncomputable section

def D (N : ℕ) (w : ℂ) : ℝ := HardyDefect.defect coeff K N w

def FiniteDiskCertificate (r : ℝ) : Prop :=
  ∃ N : ℕ, ∀ w : ℂ, ‖w‖ ≤ r → 0 < D N w

def ActualDiskExhaustion : Prop := HardyCompleteness.DiskExhaustion coeff K

def u : ℝ := 1 - Real.eulerMascheroniConstant

theorem actual_coeff_one : coeff 1 = -(u : ℂ) := by
  rw [coeff_one]
  simp [u]

theorem actual_first_disk_certificate (henergy : ActualHardyEnergy)
    {r : ℝ} (hr : 0 ≤ r) (hr1 : r < 1)
    (hmargin : 0 < (1 - r ^ 2) * (1 - u * r) ^ 2 -
      (K - 1 - u ^ 2) * r ^ 4) : FiniteDiskCertificate r := by
  have hu : 0 ≤ u := by
    unfold u
    linarith [Real.eulerMascheroniConstant_lt_two_thirds]
  have hu1 : u ≤ 1 := by
    unfold u
    linarith [Real.one_half_lt_eulerMascheroniConstant]
  have hur : u * r ≤ 1 := by nlinarith
  have hT : 0 ≤ K - 1 - u ^ 2 := by
    have h := HardyTail.tailMass_nonneg henergy 1
    rw [HardyDefect.tailMass, HardySeed.mass_one coeff u coeff_zero actual_coeff_one] at h
    linarith
  exact ⟨1, HardySeed.first_disk_pos coeff K u r coeff_zero actual_coeff_one
    hu hr hr1 hur hT hmargin⟩

theorem ACTUAL_BASE_CERTIFICATE : FiniteDiskCertificate (1 / 2) :=
  ⟨0, HardyConstants.actual_seed_half⟩

theorem actual_defect_succ (N : ℕ) (w : ℂ) :
    D (N + 1) w = Complex.normSq w * D N w +
      Complex.normSq
        (((1 - Complex.normSq w : ℝ) : ℂ) * HardyDefect.partial coeff N w +
          coeff (N + 1) * w ^ (N + 1)) :=
  HardyDefect.defect_succ coeff K N w

@[simp] theorem actual_defect_zero (w : ℂ) : D 0 w = 1 - K * Complex.normSq w :=
  HardyDefect.defect_zero coeff K w coeff_zero

@[simp] theorem actual_defect_at_zero (N : ℕ) : D N 0 = 1 :=
  HardyDefect.defect_at_zero coeff K N coeff_zero

theorem actual_positive_persists {N M : ℕ} (hNM : N ≤ M) {w : ℂ}
    (hN : 0 < D N w) : 0 < D M w :=
  HardyDefect.defect_pos_of_le coeff K w coeff_zero hNM hN

theorem normSq_lt_one {w : ℂ} (hw : ‖w‖ < 1) : Complex.normSq w < 1 := by
  rw [Complex.normSq_eq_norm_sq]
  nlinarith [norm_nonneg w]

theorem actual_series (w : ℂ) (hw : ‖w‖ < 1) :
    HasSum (fun n => coeff n * w ^ n) (J w) :=
  hasSum_coeff ((CayleyBridge.mem_unitDisk w).mpr hw)

theorem actual_tail_bound (henergy : ActualHardyEnergy)
    {w : ℂ} (hw : ‖w‖ < 1) (N : ℕ) :
    (1 - Complex.normSq w) * Complex.normSq (J w - HardyDefect.partial coeff N w) ≤
      HardyDefect.tailMass coeff K N * Complex.normSq w ^ (N + 1) :=
  HardyTail.tail_bound henergy (actual_series w hw) (normSq_lt_one hw) N

theorem actual_nonzero_of_positive (henergy : ActualHardyEnergy)
    {w : ℂ} (hw : ‖w‖ < 1) {N : ℕ} (hN : 0 < D N w) : J w ≠ 0 :=
  HardyTail.nonzero_of_defect_pos henergy (actual_series w hw) (normSq_lt_one hw) N hN

theorem actual_defect_tendsto (henergy : ActualHardyEnergy)
    {w : ℂ} (hw : ‖w‖ < 1) :
    Tendsto (fun N => D N w) atTop (𝓝 ((1 - Complex.normSq w) * Complex.normSq (J w))) :=
  HardyCompleteness.defect_tendsto henergy (actual_series w hw) (normSq_lt_one hw)

theorem actual_nonzero_iff_finite_certificate (henergy : ActualHardyEnergy)
    {w : ℂ} (hw : ‖w‖ < 1) : J w ≠ 0 ↔ ∃ N : ℕ, 0 < D N w :=
  HardyCompleteness.nonzero_iff_exists_positive_defect henergy
    (actual_series w hw) (normSq_lt_one hw)

theorem actual_disk_iff_finite_certificate (henergy : ActualHardyEnergy)
    {r : ℝ} (hr : r < 1) :
    (∀ w : ℂ, ‖w‖ ≤ r → J w ≠ 0) ↔ FiniteDiskCertificate r :=
  HardyCompleteness.nonzero_on_disk_iff_finite_certificate coeff_zero henergy hr actual_series

theorem RH_IFF_ACTUAL_DISK_EXHAUSTION (henergy : ActualHardyEnergy) :
    RiemannHypothesis ↔ ActualDiskExhaustion := by
  have h := HardyCompleteness.diskExhaustion_iff_nonzero coeff_zero henergy actual_series
  constructor
  · intro hRH
    apply h.mpr
    intro w hw
    exact J_NONZERO_OF_RH hRH w ((CayleyBridge.mem_unitDisk w).mpr hw)
  · intro hexhaust
    apply RH_OF_J_NONZERO
    intro w hw
    exact h.mp hexhaust w ((CayleyBridge.mem_unitDisk w).mp hw)

theorem RH_OF_ACTUAL_HARDY_EXHAUSTION
    (henergy : ActualHardyEnergy) (hexhaust : ActualDiskExhaustion) :
    RiemannHypothesis :=
  (RH_IFF_ACTUAL_DISK_EXHAUSTION henergy).mpr hexhaust

end
end FiveInduction.HardyEndpoint
