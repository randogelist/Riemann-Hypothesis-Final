import FiniteWitness.NativeXi

/-!
# Literal Mellin--Hilbert GP objects

Definitions transcribed from the recovered 14 October analytic construction.
This is the continuous GP measure, not the separate weight-seven GP7 model.
The identities named below are OPEN propositions, not assumed instances,
axioms, theorem certificates, or fields of a finite witness.

SOURCE_ONLY: the new integration has not been compiled by native Lean 4.33.
-/

noncomputable section

namespace RHFinal.GP.Literal

open MeasureTheory Set

/-- The Bose kernel whose negative derivative defines the GP density. -/
def bose (r : ℝ) : ℝ := r / (Real.exp r - 1)

/-- The explicit density formula on r > 0; division is totalized elsewhere. -/
def density (r : ℝ) : ℝ :=
  ((r - 1) * Real.exp r + 1) / (Real.exp r - 1) ^ 2

abbrev Coordinate := ℝ × ℝ

/-- The literal integration domain; endpoints in y have zero Lebesgue mass. -/
def domainMeasure : Measure Coordinate :=
  (volume.restrict (Ioi (0 : ℝ))).prod
    (volume.restrict (Icc (1 / 4 : ℝ) (1 / 2 : ℝ)))

/-- dμ = 2 d(r) dr dy/y. Positivity of density is a separate obligation;
`ofReal` alone is not evidence for the intended signed-density identity. -/
def gpMeasure : Measure Coordinate :=
  domainMeasure.withDensity (fun p => ENNReal.ofReal (2 * density p.1 / p.2))

/-- The intended complex L² space, without an asserted realization/isometry. -/
abbrev HilbertSpace := MeasureTheory.Lp ℂ 2 gpMeasure

/-- The multiplication generator L(r,y) = ry. -/
def spectralValue (p : Coordinate) : ℝ := p.1 * p.2

/-- Pointwise heat multiplier. Lifting this to a bounded L² operator is open. -/
def heatMultiplier (h : ℝ) (p : Coordinate) : ℝ :=
  Real.exp (-h * spectralValue p)

/-- Raw vector representative; membership in L² is not asserted by definition. -/
def vectorRepresentative (s : ℝ) (p : Coordinate) : ℝ :=
  Real.rpow (spectralValue p) ((s - 1) / 2)

/-- Real logarithmic Mellin moments; integrability remains to be proved. -/
def logMoment (j : ℕ) (s : ℝ) : ℝ :=
  ∫ p, Real.rpow (spectralValue p) (s - 1) *
    Real.log (spectralValue p) ^ j ∂gpMeasure

/-- Complex Mellin integral used in the completion gauge. -/
def mellin (s : ℂ) : ℂ :=
  ∫ p, (spectralValue p : ℂ) ^ (s - 1) ∂gpMeasure

/-- Closed expression away from s=1; its removable value is a separate goal. -/
def mellinClosed (s : ℂ) : ℂ :=
  (2 : ℂ) ^ (2 - s) * Complex.Gamma s *
    (1 - (2 : ℂ) ^ (1 - s)) * riemannZeta s

/-- Completion gauge away from its apparent singularities. -/
def completionGauge (s : ℂ) : ℂ :=
  s * (s - 1) * (2 : ℂ) ^ (s - 3) *
    (Real.pi : ℂ) ^ (-s / 2) * Complex.Gamma (s / 2) /
    (Complex.Gamma s * (1 - (2 : ℂ) ^ (1 - s)))

theorem heatMultiplier_zero (p : Coordinate) : heatMultiplier 0 p = 1 := by
  simp [heatMultiplier]

/-- Pointwise semigroup algebra only, not an L² operator theorem. -/
theorem heatMultiplier_add (h k : ℝ) (p : Coordinate) :
    heatMultiplier (h + k) p = heatMultiplier h p * heatMultiplier k p := by
  unfold heatMultiplier
  rw [show -(h + k) * spectralValue p =
    -h * spectralValue p + -k * spectralValue p by ring, Real.exp_add]

theorem heatMultiplier_pos (h : ℝ) (p : Coordinate) :
    0 < heatMultiplier h p := Real.exp_pos _

theorem heatMultiplier_le_one (h : ℝ) (p : Coordinate)
    (hh : 0 ≤ h) (hL : 0 ≤ spectralValue p) :
    heatMultiplier h p ≤ 1 := by
  apply Real.exp_le_one_iff.mpr
  exact mul_nonpos_of_nonpos_of_nonneg (neg_nonpos.mpr hh) hL

/-- OPEN: derivative and strict density positivity on the integration domain. -/
def DensityLaw : Prop :=
  ∀ r : ℝ, 0 < r → HasDerivAt bose (-density r) r ∧ 0 < density r

/-- OPEN: integral evaluation including the genuine removable value at one. -/
def MellinEvaluation : Prop :=
  (∀ s : ℂ, 0 < s.re → s ≠ 1 → mellin s = mellinClosed s) ∧
    mellin 1 = (2 * Real.log 2 : ℝ)

/-- OPEN: logarithmic differentiation under the actual integral. -/
def LogMomentDifferentiation : Prop :=
  ∀ (j : ℕ) (s : ℝ), 0 < s →
    HasDerivAt (logMoment j) (logMoment (j + 1) s) s

/-- OPEN: native completed ξ identification, away from gauge artifacts.
No claimed positivity of actual SOLOBOLO moments follows just from this. -/
def NativeXiFactorization : Prop :=
  ∀ s : ℂ, 0 < s.re → s ≠ 1 →
    Complex.Gamma s * (1 - (2 : ℂ) ^ (1 - s)) ≠ 0 →
    WitnessSolobolo.actualXi s = completionGauge s * mellin s

end RHFinal.GP.Literal
