import RHAdmission.FiniteVerifierBarrier

/-!
# Finite witness interface — executable gate, explicit native obligations

The gate is a terminating computation whenever `rawCheck` is a terminating
Boolean algorithm on finite rational codes. The gate does NOT test all actual
zeta zeros. The two theorem obligations below remain explicit and cannot be
packaged as proof fields inside an accepted witness.
-/

namespace RHAdmission

/-- A candidate's finite computation is accepted only after a rational
positivity gate. This does not claim to decide native RH. -/
def gatedCheck (rawCheck : FiniteMetricCode → Bool) (W : FiniteMetricCode) : Bool :=
  checkFiniteMetricCode W && rawCheck W

theorem gatedCheck_true_iff (rawCheck : FiniteMetricCode → Bool)
    (W : FiniteMetricCode) :
    gatedCheck rawCheck W = true ↔
      checkFiniteMetricCode W = true ∧ rawCheck W = true := by
  simp [gatedCheck]

theorem gatedCheck_metric_positive (rawCheck : FiniteMetricCode → Bool)
    (W : FiniteMetricCode) (hW : gatedCheck rawCheck W = true) :
    checkFiniteMetricCode W = true :=
  ((gatedCheck_true_iff rawCheck W).mp hW).1

/-- This is an actual analytic research obligation, NOT a certificate field.
Proving it for a concrete `rawCheck` would certify each accepted metric at
all actual zeta-zero channels. -/
def GatedActualSoundness (rawCheck : FiniteMetricCode → Bool) : Prop :=
  ∀ (W : FiniteMetricCode) (hW : gatedCheck rawCheck W = true),
    NativeCalibrated W (gatedCheck_metric_positive rawCheck W hW)

/-- This is the reverse research obligation: RH must produce an ACCEPTED
finite witness, not merely the abstract infinite-dimensional metric. -/
def GatedActualCompleteness (rawCheck : FiniteMetricCode → Bool) : Prop :=
  _root_.RiemannHypothesis →
    ∃ W : FiniteMetricCode, gatedCheck rawCheck W = true

/-- Exact desired finite-witness equivalence when the two independent
native bridge theorems have been constructed. Neither is assumed silently. -/
theorem GATED_FINITE_WITNESS_IFF_NATIVE_RH_OF_BRIDGES
    (rawCheck : FiniteMetricCode → Bool)
    (hsound : GatedActualSoundness rawCheck)
    (hcomplete : GatedActualCompleteness rawCheck) :
    (∃ W : FiniteMetricCode, gatedCheck rawCheck W = true) ↔
      _root_.RiemannHypothesis := by
  constructor
  · rintro ⟨W, hW⟩
    exact FINITELY_CODED_ADMISSION_IFF_NATIVE_RH.mp
      ⟨W, gatedCheck_metric_positive rawCheck W hW, hsound W hW⟩
  · exact hcomplete

end RHAdmission
