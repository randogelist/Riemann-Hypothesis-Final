import RHAdmission.Induction

/-!
# Downstream consequences of the hypothetical admission

QQRH here has precisely the user's slope convention.  The target is the
ACTUAL `riemannZeta`, not a project-local model zeta function.
-/

namespace RHAdmission

/-- The slope-m wedge of the open critical strip is zero-free. -/
def QQRH (m : ℝ) : Prop :=
  ∀ s : ℂ, 0 < s.re → s.re < 1 →
    |s.im| < m * |s.re - 1 / 2| → riemannZeta s ≠ 0

/-- Simple nontrivial-zero support inside the strict strip. -/
theorem strip_zero_is_nontrivial (s : ℂ)
    (hp : 0 < s.re) (hlt : s.re < 1) (hz : riemannZeta s = 0) :
    ActualNontrivialZero s := by
  refine ⟨hz, ?_, ?_⟩
  · rintro ⟨n, hn⟩
    have hre := congrArg Complex.re hn
    have hright : ((-2 : ℂ) * ((n : ℂ) + 1)).re =
        -2 * ((n : ℝ) + 1) := by norm_num
    rw [hright] at hre
    have hn0 : 0 ≤ (n : ℝ) := Nat.cast_nonneg n
    linarith
  · intro heq
    rw [heq] at hlt
    norm_num at hlt

/-- Every positive-metric admission yields ALL QQRH slopes. -/
theorem admission_implies_all_QQRH
    (hAdmission : HypotheticalAdmission) : ∀ m : ℝ, QQRH m := by
  have hRH := admission_implies_native_RH hAdmission
  intro m s hp hlt hwedge hz
  have hs := strip_zero_is_nontrivial s hp hlt hz
  have hline : s.re = 1 / 2 := hRH s hs.1 hs.2.1 hs.2.2
  simp [hline] at hwedge

/-- The SOLOBOLO shifted coordinate attached to an actual nontrivial zero. -/
def shiftedCoordinate (s : ℂ) : ℂ := s * (s - 1)

theorem shifted_coordinate_im (s : ℂ) :
    (shiftedCoordinate s).im = (2 * s.re - 1) * s.im := by
  simp [shiftedCoordinate, Complex.mul_im]
  ring

theorem shifted_coordinate_re (s : ℂ) :
    (shiftedCoordinate s).re =
      (s.re - 1 / 2) ^ 2 - s.im ^ 2 - 1 / 4 := by
  simp [shiftedCoordinate, Complex.mul_re]
  ring

/-- Hypothetical admission gives full shifted-axis nonpositivity at each
    actual nontrivial zeta zero, including the sharp quarter-shift. -/
theorem admission_implies_solobolo_axis
    (hAdmission : HypotheticalAdmission) (s : ℂ)
    (hz : ActualNontrivialZero s) :
    (shiftedCoordinate s).im = 0 ∧
    (shiftedCoordinate s).re ≤ -(1 / 4 : ℝ) := by
  have hRH := admission_implies_native_RH hAdmission
  have hc : s.re = 1 / 2 := hRH s hz.1 hz.2.1 hz.2.2
  constructor
  · rw [shifted_coordinate_im, hc]
    ring
  · rw [shifted_coordinate_re, hc]
    nlinarith [sq_nonneg s.im]

/-- The certified downstream bundle is a theorem conditional ONLY on
    hypothetical admission (with no witness constructor). -/
theorem ADMISSION_TO_DOWNSTREAM
    (hAdmission : HypotheticalAdmission) :
    _root_.RiemannHypothesis ∧
    (∀ m : ℝ, QQRH m) ∧
    (∀ s : ℂ, ActualNontrivialZero s →
      (shiftedCoordinate s).im = 0 ∧
      (shiftedCoordinate s).re ≤ -(1 / 4 : ℝ)) := by
  exact ⟨admission_implies_native_RH hAdmission,
    admission_implies_all_QQRH hAdmission,
    admission_implies_solobolo_axis hAdmission⟩

end RHAdmission
