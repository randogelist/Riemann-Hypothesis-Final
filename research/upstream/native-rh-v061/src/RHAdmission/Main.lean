import RHAdmission.GeneralMetric
import RHAdmission.Downstream

/-!
# Final chain: hypothetical admission iff Mathlib RH

The admission's existence is NOT claimed; we prove an equivalence.
The induction from depth n to n+1 is entirely closed for this metric model.
The native xi/Widder identification and any finite witness construction are
NOT part of this package.
-/

namespace RHAdmission

/-- Main theorem: the FULL positive two-mode metric admission is equivalent
    to Mathlib's actual `_root_.RiemannHypothesis`. -/
theorem MAIN_ADMISSION_IFF_NATIVE_RH :
    FullHypotheticalAdmission ↔ _root_.RiemannHypothesis :=
  FULL_HYPOTHETICAL_ADMISSION_IFF_NATIVE_RH

/-- The earlier diagonal admission is equivalent too. -/
theorem DIAGONAL_ADMISSION_IFF_NATIVE_RH :
    HypotheticalAdmission ↔ _root_.RiemannHypothesis :=
  HYPOTHETICAL_ADMISSION_IFF_RH

/-- Native RH is sufficient to obtain the same admission. -/
theorem RH_CONSTRUCTS_THE_HYPOTHETICAL_ADMISSION
    (hRH : _root_.RiemannHypothesis) : FullHypotheticalAdmission :=
  native_RH_implies_full_admission hRH

/-- The hypothetical admission also forces SOLOBOLO and QQRH zero geometry. -/
theorem ADMISSION_FORCES_ALL_QQRH
    (h : FullHypotheticalAdmission) : ∀ m : ℝ, QQRH m :=
  admission_implies_all_QQRH
    (native_RH_implies_admission (full_admission_implies_native_RH h))

/-- Under admission, ordinary induction gives every finite channel iterate. -/
theorem ADMISSION_FORCES_ALL_DEPTHS
    (h : FullHypotheticalAdmission) :
    ∃ H : PositiveTwoModeMetric,
      ∀ s : ℂ, ActualNontrivialZero s →
        ∀ n : ℕ, ∀ v : ChannelVec,
          fullMetricEnergy H (channelIterate s n v) ≤ fullMetricEnergy H v :=
  full_admission_all_depths h

/-- The full-metric admission yields SOLOBOLO axis geometry too. -/
theorem ADMISSION_FORCES_SOLOBOLO_SHIFTED_AXIS
    (h : FullHypotheticalAdmission) (s : ℂ)
    (hz : ActualNontrivialZero s) :
    (shiftedCoordinate s).im = 0 ∧
    (shiftedCoordinate s).re ≤ -(1 / 4 : ℝ) :=
  admission_implies_solobolo_axis
    (native_RH_implies_admission (full_admission_implies_native_RH h)) s hz

end RHAdmission
