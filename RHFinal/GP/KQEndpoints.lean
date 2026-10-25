import KQGPBKQRHilbert
import FiniteWitness.NativeXi

/-!
# Integrated KQ / GP / BKQR / SOLOBOLO actual-data endpoints

SOURCE_ONLY_NATIVE_RECHECK_REQUIRED.

The imported KQ construction is preserved byte-for-byte from
KQ_GP_BKQR_HILBERT_SOLOBOLO_REAL_RODRIGUES_NORMALIZATION_v0_1_18_FASTCORE.
Its GP reconstruction, common-moment calibration, actual channel analysis,
complex Taylor germ and rate hypotheses retain their original explicit types.
They are not finite certificate fields discharged by this import.

The identities below bind the two recovered source families to the same
literal completed-zeta xi and the same principal-square-root theta. This
source equality transfers the recovered positive-anchor analytic theorem;
it does not assert nonvanishing or a finite RH witness.
-/

namespace RHFinal.GP

theorem actualXi_eq_kqXi :
    WitnessSolobolo.actualXi = NativeSolobolo.mathlibXi := rfl

theorem actualTheta_eq_kqSlitTheta :
    WitnessSolobolo.actualTheta = NativeSolobolo.mathlibSlitTheta := rfl

/-- Actual theta analyticity at every positive anchor follows from the
imported slit-plane theorem. Nonvanishing is a separate obligation. -/
theorem actualTheta_analyticAt_positive (a : ℝ) (ha : 0 < a) :
    AnalyticAt ℂ WitnessSolobolo.actualTheta (a : ℂ) := by
  change AnalyticAt ℂ NativeSolobolo.mathlibSlitTheta (a : ℂ)
  exact KQGPBKQRHilbert.AllDepth.actualMathlibXi_analyticAt_positive a ha

/-- A selected actual-data endpoint: independently defined direct Widder
derivatives agree with the recursive tower on its explicit regular domain. -/
theorem actualWidder_direct_eq_recursive
    (a : ℝ) (ha : a ∈ NativeSoloboloNegativity.xiRegularAnchors)
    (n : ℕ) :
    NativeSoloboloNegativity.xiWidderDirect a n =
      NativeSoloboloNegativity.xiWidderMoment a n :=
  NativeSoloboloNegativity.XI_WIDDER_DIRECT_EQ_RECURSIVE_ON_REGULAR_ANCHORS
    a ha n

/-- Every actual recursive Widder coefficient has the recovered normalized
finite real Taylor-jet formula. This is not the complex infinite germ. -/
theorem actualWidder_finite_cayley_coefficient
    (a : ℝ) (ha : a ∈ NativeSoloboloNegativity.xiRegularAnchors)
    (n : ℕ) :
    KQGPBKQRHilbert.AllDepth.canonicalCayleyCoefficient a
        (KQGPBKQRHilbert.AllDepth.actualXiRealTaylorInput a) n =
      (NativeSoloboloNegativity.xiWidderMoment a n : ℂ) :=
  KQGPBKQRHilbert.AllDepth.actual_xi_all_depth_finite_cayley_coefficients a ha n

end RHFinal.GP
