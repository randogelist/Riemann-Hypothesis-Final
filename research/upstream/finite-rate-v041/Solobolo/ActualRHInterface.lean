import Solobolo.QuarterContraction
import Solobolo.OffLinePairPositivity

/-!
# Actual RH interface: mathematically honest theorem statements

This module defines the actual Riemann hypothesis using Mathlib's
`riemannZeta`. The two analytic source facts are INPUTS, NOT AXIOMS:

* `hsource`: actual RH iff the off-line mass of this profile is zero.
  Its proof requires the actual completed-xi genus-zero product and a
  strictly positive summable off-line contribution ledger.
* `hrate`: RH implies eventual dyadic quarter-rate for the critical-line
  zero tail. Its proof requires a weighted Riemann-von Mangoldt estimate.

The epsilon admission needs only hsource; the stronger quarter admission
needs both. No witness is imported or assumed anywhere.
-/

namespace Solobolo.HypotheticalRH

/-- Nontrivial zeros of the *actual* Mathlib Riemann zeta in the critical
strip must have real part 1/2. -/
def ActualRiemannHypothesis : Prop :=
  ∀ s : ℂ, 0 < s.re → s.re < 1 →
    riemannZeta s = 0 → s.re = (1 / 2 : ℝ)

/-- Main epsilon-admission <-> actual RH theorem, with the exact analytic
source identification made explicit as a proposition argument. -/
theorem epsilonAdmission_iff_actualRH (p : DyadicProfile)
    (hsource : ActualRiemannHypothesis ↔ NoOffLineMass p) :
    EpsilonAdmission p ↔ ActualRiemannHypothesis :=
  (epsilonAdmission_iff_noOffLineMass p).trans hsource.symm

/-- The strong SOLOBOLO dyadic admission *unconditionally implies* actual RH
once the xi-product source identification has been established. -/
theorem quarterAdmission_implies_actualRH (p : DyadicProfile)
    (hsource : ActualRiemannHypothesis ↔ NoOffLineMass p) :
    QuarterAdmission p → ActualRiemannHypothesis := by
  intro h
  exact hsource.mpr (quarterAdmission_implies_noOffLineMass p h)

/-- Full quarter-admission <-> actual RH: precisely lists the two analytic
input theorems which remain to be formalized for the actual zero ledger. -/
theorem quarterAdmission_iff_actualRH (p : DyadicProfile)
    (hsource : ActualRiemannHypothesis ↔ NoOffLineMass p)
    (hrate : ActualRiemannHypothesis → TailQuarterRate p) :
    QuarterAdmission p ↔ ActualRiemannHypothesis := by
  constructor
  · exact quarterAdmission_implies_actualRH p hsource
  · intro hRH
    exact noOffLineMass_implies_quarterAdmission_of_tailRate p
      (hrate hRH) (hsource.mp hRH)

#print axioms epsilonAdmission_iff_actualRH
#print axioms quarterAdmission_iff_actualRH

end Solobolo.HypotheticalRH
