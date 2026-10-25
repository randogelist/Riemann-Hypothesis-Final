import PositivityPremise.Series
import Mathlib.NumberTheory.LSeries.RiemannZeta
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Analytic.Order

/-!
An explicit bridge from the abstract summable zero data to Mathlib's literal
`RiemannHypothesis`.  No actual enumeration or trace identity is postulated as
an axiom: each appears as an argument to the conditional theorems below.

`ZetaBinding` identifies the support of the data with the nontrivial zeta zeros,
up to complex conjugation.  It does not assert injectivity of the enumeration
or identify the positive integer weights with analytic orders of vanishing.
Those additional facts are explicit fields of `CanonicalZetaBinding`; neither
binding is constructed in this module.  They are not needed for the
support-level RH equivalence here.
-/

set_option autoImplicit false

noncomputable section
namespace PositivityPremise

/-- Exactly the three zero hypotheses occurring in Mathlib's RH statement. -/
def NontrivialZetaZero (s : ℂ) : Prop :=
  riemannZeta s = 0 ∧ (¬ ∃ n : ℕ, s = -2 * (n + 1)) ∧ s ≠ 1

/-- A complete positive-height support binding, with conjugation for the lower half-plane. -/
structure ZetaBinding {ι : Type*} (D : ZeroData ι) where
  rho : ι → ℂ
  sound : ∀ i, NontrivialZetaZero (rho i)
  gamma_eq : ∀ i, D.gamma i = (rho i).im
  delta_eq : ∀ i, D.delta i = (rho i).re - 1 / 2
  complete : ∀ s, NontrivialZetaZero s → ∃ i, s = rho i ∨ s = star (rho i)

/-- An exact enumeration and weighting of the nontrivial upper-half-plane zeros.
Constructing this binding, including analytic multiplicity identification,
remains an explicit obligation. -/
structure CanonicalZetaBinding {ι : Type*} (D : ZeroData ι) extends ZetaBinding D where
  injective : Function.Injective rho
  multiplicity_eq : ∀ i, D.multiplicity i = analyticOrderNatAt riemannZeta (rho i)

theorem ZetaBinding.onLine_iff_riemannHypothesis {ι : Type*} {D : ZeroData ι}
    (B : ZetaBinding D) : D.OnLine ↔ RiemannHypothesis := by
  constructor
  · intro hline s hz htriv hone
    obtain ⟨i, hi | hi⟩ := B.complete s ⟨hz, htriv, hone⟩
    · have hd : (B.rho i).re - 1 / 2 = 0 := by
        rw [← B.delta_eq i]
        exact hline i
      rw [hi]
      exact sub_eq_zero.mp hd
    · have hd : (B.rho i).re - 1 / 2 = 0 := by
        rw [← B.delta_eq i]
        exact hline i
      rw [hi]
      simpa using sub_eq_zero.mp hd
  · intro hRH i
    obtain ⟨hz, htriv, hone⟩ := B.sound i
    rw [B.delta_eq i, hRH (B.rho i) hz htriv hone]
    exact sub_self _

/-- Uniform positivity/decay closure, with a literal zeta-support binding made explicit. -/
theorem POSITIVITY_PREMISE_IFF_RH {ι : Type*} {D : ZeroData ι}
    (B : ZetaBinding D) : PositivityPremise D.C D.c1 ↔ RiemannHypothesis := by
  exact D.positivityPremise_iff_onLine.trans B.onLine_iff_riemannHypothesis

/-- The entire completion of Riemann's xi, expressed with Mathlib's entire completion. -/
def canonicalXi (s : ℂ) : ℂ :=
  (1 + s * (s - 1) * completedRiemannZeta₀ s) / 2

/-- The real part of the actual central curvature ratio `xi''(1/2)/(2 xi(1/2))`. -/
def centerCurvature : ℝ :=
  (deriv (deriv canonicalXi) (1 / 2) / (2 * canonicalXi (1 / 2))).re

/-- The analytic trace identification is an explicit, unproved input of this package. -/
def TraceIdentification {ι : Type*} (D : ZeroData ι) : Prop :=
  centerCurvature = D.trace

theorem curvature_defect_eq {ι : Type*} {D : ZeroData ι}
    (htrace : TraceIdentification D) : D.c1 - centerCurvature = D.C := by
  rw [show centerCurvature = D.trace from htrace]
  exact D.C_eq_c1_sub_trace.symm

/-- The scalar premise uses the actual completed-zeta curvature, conditional on its trace identity. -/
theorem CURVATURE_POSITIVITY_PREMISE_IFF_RH {ι : Type*} {D : ZeroData ι}
    (B : ZetaBinding D) (htrace : TraceIdentification D) :
    PositivityPremise (D.c1 - centerCurvature) D.c1 ↔ RiemannHypothesis := by
  rw [curvature_defect_eq htrace]
  exact POSITIVITY_PREMISE_IFF_RH B

/-- The central-curvature equality route, under the same explicit analytic inputs. -/
theorem CENTRAL_CURVATURE_EQUALITY_IFF_RH {ι : Type*} {D : ZeroData ι}
    (B : ZetaBinding D) (htrace : TraceIdentification D) :
    D.c1 = centerCurvature ↔ RiemannHypothesis := by
  have h := CURVATURE_POSITIVITY_PREMISE_IFF_RH B htrace
  rw [positivityPremise_iff_eq_zero D.c1_nonneg, sub_eq_zero] at h
  exact h

/-- The intended exact-weight scalar equivalence with all analytic inputs explicit. -/
theorem CANONICAL_POSITIVITY_PREMISE_IFF_RH {ι : Type*} {D : ZeroData ι}
    (B : CanonicalZetaBinding D) (htrace : TraceIdentification D) :
    PositivityPremise (D.c1 - centerCurvature) D.c1 ↔ RiemannHypothesis :=
  CURVATURE_POSITIVITY_PREMISE_IFF_RH B.toZetaBinding htrace

end PositivityPremise
