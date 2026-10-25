import RHAdmission.CrossInferenceAudit

/-!
# Finite rational metric codes — sound finite arithmetic, no RH claim

A proof that a rational metric is positive is FINITE and decidable.
Checking positivity does not check its passivity on every actual zeta zero.
This distinction is the central research boundary.
-/

namespace RHAdmission

/-- Exactly one rational number: a finite encoding of a scalar 2x2 metric. -/
structure FiniteMetricCode where
  scale : ℚ
  deriving DecidableEq, Repr

/-- A genuinely terminating Boolean checker (only rational arithmetic). -/
def checkFiniteMetricCode (W : FiniteMetricCode) : Bool :=
  decide (0 < W.scale)

/-- The identity metric has an accepted finite encoding, regardless of RH. -/
def identityMetricCode : FiniteMetricCode := ⟨1⟩

theorem identity_metric_code_accepted :
    checkFiniteMetricCode identityMetricCode = true := by
  decide

/-- The checker proves a real, strictly positive definite metric. -/
def positiveMetricFromCode (W : FiniteMetricCode)
    (hw : checkFiniteMetricCode W = true) : PositiveTwoModeMetric := by
  have hpQ : 0 < W.scale := by
    exact of_decide_true (by simpa [checkFiniteMetricCode] using hw)
  have hpR : 0 < (W.scale : ℝ) := by exact_mod_cast hpQ
  refine {
    eps := (W.scale : ℝ)
    eps_pos := hpR
    h11 := (W.scale : ℝ)
    h12 := 0
    h22 := (W.scale : ℝ)
    positive := ?_
  }
  intro v
  change (W.scale : ℝ) * (v.1 ^ 2 + v.2 ^ 2) ≤
    (W.scale : ℝ) * v.1 ^ 2 + 2 * 0 * v.1 * v.2 +
      (W.scale : ℝ) * v.2 ^ 2
  apply le_of_eq
  ring

/-- Positive metric codes are always accepted: this is not an RH certificate. -/
theorem finite_metric_code_always_exists :
    ∃ W : FiniteMetricCode, checkFiniteMetricCode W = true :=
  ⟨identityMetricCode, identity_metric_code_accepted⟩

end RHAdmission
