import AllDepth.SymmetricCayleyGerm
import Core.MathlibXiSlitTheta

/-!
# Specialize B1 to the genuine Mathlib Theta model

`CenteredThetaData` is intentionally abstract: it does NOT assume analytic
or actual-xi theta, and its `thetaPrime` is an independent function field.
Therefore B1 cannot be established unconditionally for arbitrary `T`.

This module makes the *real* analytic target independent of any
abstract zero geometry. It then transports the target back to
`mathlibSlitThetaData X hzero` without inventing any positive zero model.
The target proposition is OPEN; these are provable structural adapters.
-/

namespace KQGPBKQRHilbert.AllDepth

noncomputable section

/-- The true Mathlib slit-Theta observable, without requiring a zero family. -/
def actualMathlibXiCayleyEval (a r : ℝ) : Option ℂ :=
  let zp := NativeSolobolo.cayleyPointPlus a r
  let zm := NativeSolobolo.cayleyPointMinus a r
  if NativeSolobolo.mathlibSlitTheta zp = 0 ∨
      NativeSolobolo.mathlibSlitTheta zm = 0 then
    none
  else
    some ((4 * (a : ℂ)) *
      ((zm * (deriv NativeSolobolo.mathlibSlitTheta zm /
          NativeSolobolo.mathlibSlitTheta zm) -
        zp * (deriv NativeSolobolo.mathlibSlitTheta zp /
          NativeSolobolo.mathlibSlitTheta zp)) / (zm - zp)))

/-- Specialization of the abstract Option-valued observable to the *actual*
    completed Mathlib xi, with the theta derivative fixed definitionally. -/
theorem actualMathlibXiCayleyEval_eq_model
    (X : NativeSolobolo.CenteredXiGeometry)
    (hzero : ∀ z : X.Zero,
      NativeSolobolo.mathlibSlitTheta (X.thetaZeroPoint z) = 0)
    (a r : ℝ) :
    (NativeSolobolo.actualThetaCayleyObservable
      (NativeSolobolo.mathlibSlitThetaData X hzero)).eval a r =
      actualMathlibXiCayleyEval a r := by
  rfl

/-- The genuine slit Theta is already complex-analytic at EVERY positive
    anchor. Analyticity does not by itself give the Taylor-jet identity. -/
theorem actualMathlibXi_analyticAt_positive
    (a : ℝ) (ha : 0 < a) :
    AnalyticAt ℂ NativeSolobolo.mathlibSlitTheta (a : ℂ) :=
  NativeSolobolo.MATHLIB_SLIT_THETA_ANALYTIC_ON_NHD (a : ℂ)
    (NativeSolobolo.POSITIVE_ANCHOR_MEM_SLIT_PLANE ha)

/-- OPEN B1, correctly specialized to the *literal* Mathlib completed ξ.
    The domain uses the already established open regular-anchor set.

    The remaining analytic proof should use the Cauchy kernel
    `(ζ-a)^2+4*a*r*ζ`, the polynomial identity in
    `AllDepth.SymmetricCayleyGerm`, and complex/real derivative matching.
    No spectral representation or positivity is assumed. -/
def ActualMathlibXiTaylorGermOnRegularAnchors : Prop :=
  ∀ a : ℝ, a ∈ NativeSoloboloNegativity.xiRegularAnchors →
    ∃ δ : ℝ, 0 < δ ∧
      ∀ r : ℝ, 0 < r → r < δ →
        ∃ v : ℂ,
          actualMathlibXiCayleyEval a r = some v ∧
          v = ∑' n : ℕ,
            (NativeSoloboloNegativity.xiWidderMoment a n : ℂ) * (r : ℂ) ^ n

/-- The only remaining anchor-domain condition for upgrading the local
    theorem to the original all-positive-anchor B1 proposition is the
    genuine xi nonvanishing on the positive real a-axis. -/
theorem actualMathlibXiTaylorGerm_to_original
    (X : NativeSolobolo.CenteredXiGeometry)
    (hzero : ∀ z : X.Zero,
      NativeSolobolo.mathlibSlitTheta (X.thetaZeroPoint z) = 0)
    (hregular : NativeSoloboloNegativity.AllPositiveXiRegular)
    (hgerm : ActualMathlibXiTaylorGermOnRegularAnchors) :
    ActualXiTaylorGerm (NativeSolobolo.mathlibSlitThetaData X hzero) := by
  intro a ha
  obtain ⟨δ, hδ, hg⟩ := hgerm a (hregular a ha)
  refine ⟨δ, hδ, ?_⟩
  intro r hr hrδ
  obtain ⟨v, hv, hcoeff⟩ := hg r hr hrδ
  refine ⟨v, ?_, hcoeff⟩
  rw [actualMathlibXiCayleyEval_eq_model X hzero a r]
  exact hv

end
end KQGPBKQRHilbert.AllDepth
