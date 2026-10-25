import Solobolo.EventualAdmission
import Solobolo.TailObstruction
import Solobolo.GeometricAdmission
import Solobolo.MomentDifference
import Solobolo.ActualRHNormalForm

/-!
# SOLOBOLO v0.2 witness-free main chain, including hypothetical admissions

Mathematically exact distinctions:
  ABSTRACT: epsilon/eventual-epsilon iff zero off-line mass. No rate needed.
  STRONG:  quarter and geometric admissions imply zero off-line mass.
  REVERSE STRONG: RH-tail rate is a named input, not a hidden axiom.
  ACTUAL ZETA: 'hsource' is an explicit nontrivial xi-zero-product bridge.
  MODEL:  one globally calibrated finite contraction propagates all cells.

There is no finite witness in this package, no admitted proof (`sorry`),
no new custom axiom, and NO purported unconditional proof of RH.
-/

namespace Solobolo.HypotheticalRH

/-- Stronger epsilon criterion: once the residual is small, it stays small. -/
theorem v10_eventual_admission_iff_zero_offline (p : DyadicProfile) :
    EventualEpsilonAdmission p ↔ NoOffLineMass p :=
  eventualEpsilonAdmission_iff_noOffLineMass p

/-- Quarter contraction implies the epsilon criterion via a proven
    n→n+1 geometric induction. -/
theorem v10_quarter_implies_eventual_admission (p : DyadicProfile) :
    QuarterAdmission p → EventualEpsilonAdmission p := by
  intro h
  exact (eventualEpsilonAdmission_iff_epsilonAdmission p).mpr
    (quarterAdmission_implies_epsilonAdmission p h)

/-- Three strong admission variants are equivalent in a profile whose
    (independently provided) critical-line tail satisfies the actual rate. -/
theorem v10_all_admissions_equivalent_of_rate (p : DyadicProfile)
    (hrate : TailQuarterRate p) :
    (EpsilonAdmission p ↔ QuarterAdmission p) ∧
    (QuarterAdmission p ↔ GeometricAdmission p) := by
  constructor
  · exact (epsilonAdmission_iff_noOffLineMass p).trans
      (quarterAdmission_iff_noOffLineMass_of_tailRate p hrate).symm
  · exact (quarterAdmission_iff_noOffLineMass_of_tailRate p hrate).trans
      (geometricAdmission_iff_noOffLineMass_of_tailRate p hrate).symm

/-- Actual-riemannZeta epsilon-admission equivalence: the xi spectral
    identification is the ONE explicit analytic source hypothesis. -/
theorem v10_eventual_admission_iff_actual_RH (p : DyadicProfile)
    (hsource : ActualRiemannHypothesis ↔ NoOffLineMass p) :
    EventualEpsilonAdmission p ↔ ActualRiemannHypothesis :=
  (v10_eventual_admission_iff_zero_offline p).trans hsource.symm

/-- Strong hypothetical quarter-admission iff RH with exactly the two
    substantive analytic bridges shown in the theorem statement. -/
theorem v10_quarter_admission_iff_actual_RH (p : DyadicProfile)
    (hsource : ActualRiemannHypothesis ↔ NoOffLineMass p)
    (hrate : ActualRiemannHypothesis → TailQuarterRate p) :
    QuarterAdmission p ↔ ActualRiemannHypothesis :=
  quarterAdmission_iff_actualRH p hsource hrate

/-- An equivalent geometric admission, again with explicit inputs. -/
theorem v10_geometric_admission_iff_actual_RH (p : DyadicProfile)
    (hsource : ActualRiemannHypothesis ↔ NoOffLineMass p)
    (hrate : ActualRiemannHypothesis → TailQuarterRate p) :
    GeometricAdmission p ↔ ActualRiemannHypothesis := by
  constructor
  · intro h
    apply hsource.mpr
    exact (epsilonAdmission_iff_noOffLineMass p).mp
      (geometricAdmission_implies_epsilonAdmission p h)
  · intro h
    have hz := hsource.mp h
    exact (geometricAdmission_iff_noOffLineMass_of_tailRate p (hrate h)).mpr hz

/-- Under an actual spectral source bridge, any strictly positive off-line
    mass eventually violates every candidate quarter step. -/
theorem v10_positive_mass_eventual_obstruction (p : DyadicProfile)
    (hpos : 0 < p.offMass) :
    ∃ N : ℕ, ∀ n ≥ N,
      (4 : ℝ) * block p n < residual p n :=
  positiveOffMass_eventually_fails_quarter p hpos

#print axioms v10_eventual_admission_iff_actual_RH
#print axioms v10_quarter_admission_iff_actual_RH
#print axioms v10_geometric_admission_iff_actual_RH

end Solobolo.HypotheticalRH
