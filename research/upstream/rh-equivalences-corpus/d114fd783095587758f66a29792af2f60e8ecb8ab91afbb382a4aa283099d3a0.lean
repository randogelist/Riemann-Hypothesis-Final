import PointwiseCriticalLine

namespace ConstructiveCriticalLine

open ConstructiveWeakRH

/-!
This file formalizes the remaining gap *upstream* of the scalar RH-equivalent
passivity statement.

The scalar predicate `PointwiseGPBKQRPlusPassivityAt rho` is deliberately
firewalled below: it is equivalent to the one-sided inequality
`rho.re ≤ 1/2`, and its universal version is equivalent to Mathlib's native
`RiemannHypothesis` once the already-derived zeta reflection is used.

The genuinely structural interface is instead `ActualGPIntertwiningGap`.
It takes an independently supplied contractive BKQR scale step `Q` and an
actual-GP state assignment `gpState`, and asks for the exact energy
intertwining identity at every literal nontrivial zeta zero.
-/

/-- Scalar firewall: pointwise plus-passivity is exactly the one-sided
critical-line inequality. -/
theorem pointwiseGPBKQRPlusPassivityAt_iff_re_le_half
    (rho : ℂ) :
    PointwiseGPBKQRPlusPassivityAt rho ↔ rho.re ≤ (1 / 2 : ℝ) := by
  constructor
  · intro h
    exact re_le_half_of_plusPassivity h
  · intro hre
    refine ⟨1, by norm_num, ?_⟩
    unfold plusDefect forwardGain centered
    have hexp : 2 * (rho.re - (1 / 2 : ℝ)) ≤ 0 := by
      linarith
    have hscale : scale2 (2 * (rho.re - (1 / 2 : ℝ))) ≤ scale2 0 :=
      scale2_strictMono.monotone hexp
    rw [scale2_at_zero] at hscale
    norm_num
    linarith

/-- The global scalar frontier is logically equivalent to Mathlib's native RH.
This theorem is an audit firewall: constructing this proposition directly is
not a smaller problem than RH. -/
theorem actualPointwiseGPBKQRPlusPassivity_iff_riemannHypothesis :
    ActualPointwiseGPBKQRPlusPassivity ↔ RiemannHypothesis := by
  constructor
  · intro hactual
    unfold RiemannHypothesis
    intro rho hzeta htrivial hneOne
    exact constructiveCriticalLineAt_of_actualPointwiseGPBKQR hactual
      ⟨hzeta, htrivial, hneOne⟩
  · intro hRH rho hz
    have hcrit : rho.re = (1 / 2 : ℝ) :=
      hRH rho hz.1 hz.2.1 hz.2.2
    apply (pointwiseGPBKQRPlusPassivityAt_iff_re_le_half rho).2
    exact le_of_eq hcrit

/-- A minimal real two-coordinate BKQR state.  This is only the receiving
Hilbert/Gram coordinate surface; the actual GP construction must provide the
state assignment used below. -/
abbrev GPBKQRState := ℝ × ℝ

/-- Squared Euclidean energy of a finite BKQR state. -/
def stateEnergy (v : GPBKQRState) : ℝ := v.1 ^ 2 + v.2 ^ 2

/-- State energy is nonnegative. -/
theorem stateEnergy_nonneg (v : GPBKQRState) : 0 ≤ stateEnergy v := by
  unfold stateEnergy
  positivity

/-- A nonzero finite BKQR state has strictly positive energy. -/
theorem stateEnergy_pos_of_ne_zero
    {v : GPBKQRState} (hv : v ≠ (0, 0)) : 0 < stateEnergy v := by
  rcases v with ⟨x, y⟩
  have hxy : x ≠ 0 ∨ y ≠ 0 := by
    by_contra hnot
    push_neg at hnot
    apply hv
    simp [hnot.1, hnot.2]
  unfold stateEnergy
  rcases hxy with hx | hy
  · have hx2 : 0 < x ^ 2 := sq_pos_of_ne_zero hx
    have hy2 : 0 ≤ y ^ 2 := sq_nonneg y
    nlinarith
  · have hx2 : 0 ≤ x ^ 2 := sq_nonneg x
    have hy2 : 0 < y ^ 2 := sq_pos_of_ne_zero hy
    nlinarith

/-- An independently supplied BKQR scale step whose energy is contractive.
In the intended application this object is constructed on the π/BKQR side,
not from the zeta-zero real part. -/
structure PiBKQRContraction where
  step : GPBKQRState → GPBKQRState
  contractive : ∀ v : GPBKQRState, stateEnergy (step v) ≤ stateEnergy v

/-- The precise pointwise missing bridge on the GP side, relative to a fixed
π/BKQR contraction and a supplied actual-GP state assignment.

The first clause binds the zero to a nonzero state.  The second is the actual
intertwining identity: one BKQR scale step changes the state energy by exactly
the GP dyadic gain.  Contractivity itself is *not* placed here; it belongs to
`Q` and is therefore independent of the zero being analyzed. -/
def PointwiseActualGPIntertwiningGapAt
    (Q : PiBKQRContraction)
    (gpState : ℂ → GPBKQRState)
    (rho : ℂ) : Prop :=
  gpState rho ≠ (0, 0) ∧
    stateEnergy (Q.step (gpState rho)) =
      forwardGain rho * stateEnergy (gpState rho)

/-- Global form of the missing GP-side bridge. -/
def ActualGPIntertwiningGap
    (Q : PiBKQRContraction)
    (gpState : ℂ → GPBKQRState) : Prop :=
  ∀ rho : ℂ, NontrivialZetaZero rho →
    PointwiseActualGPIntertwiningGapAt Q gpState rho

/-- The structural intertwining gap supplies the one-sided scalar passivity
witness.  This is the key derived bridge from the upstream operator statement
to the already-compiled scalar closure. -/
theorem pointwisePlusPassivity_of_actualGPIntertwining
    {Q : PiBKQRContraction}
    {gpState : ℂ → GPBKQRState}
    {rho : ℂ}
    (hgap : PointwiseActualGPIntertwiningGapAt Q gpState rho) :
    PointwiseGPBKQRPlusPassivityAt rho := by
  rcases hgap with ⟨hstate_ne, hintertwine⟩
  have hEpos : 0 < stateEnergy (gpState rho) :=
    stateEnergy_pos_of_ne_zero hstate_ne
  have hcontract := Q.contractive (gpState rho)
  rw [hintertwine] at hcontract
  have hgain : forwardGain rho ≤ 1 := by
    nlinarith
  refine ⟨1, by norm_num, ?_⟩
  unfold plusDefect
  nlinarith

/-- A shorter direct version of the preceding theorem: the gap implies the
one-sided location bound without passing through any global RH statement. -/
theorem re_le_half_of_actualGPIntertwining
    {Q : PiBKQRContraction}
    {gpState : ℂ → GPBKQRState}
    {rho : ℂ}
    (hgap : PointwiseActualGPIntertwiningGapAt Q gpState rho) :
    rho.re ≤ (1 / 2 : ℝ) := by
  exact re_le_half_of_plusPassivity
    (pointwisePlusPassivity_of_actualGPIntertwining hgap)

/-- If the fixed π/BKQR contraction intertwines the actual GP state assignment
at all literal nontrivial zeros, then the old scalar frontier is constructed. -/
theorem actualPointwisePlusPassivity_of_actualGPIntertwiningGap
    {Q : PiBKQRContraction}
    {gpState : ℂ → GPBKQRState}
    (hgap : ActualGPIntertwiningGap Q gpState) :
    ActualPointwiseGPBKQRPlusPassivity := by
  intro rho hz
  exact pointwisePlusPassivity_of_actualGPIntertwining (hgap rho hz)

/-- Pointwise critical-line closure from the *structural* GP/BKQR gap.  The
reflected zero is already constructed by Constructive Weak RH, so the same
fixed contraction and the same GP-state assignment are applied there. -/
theorem criticalLineAt_of_actualGPIntertwiningGap
    {Q : PiBKQRContraction}
    {gpState : ℂ → GPBKQRState}
    (hgap : ActualGPIntertwiningGap Q gpState)
    {rho : ℂ} (hz : NontrivialZetaZero rho) :
    rho.re = (1 / 2 : ℝ) := by
  have hactual : ActualPointwiseGPBKQRPlusPassivity :=
    actualPointwisePlusPassivity_of_actualGPIntertwiningGap hgap
  exact constructiveCriticalLineAt_of_actualPointwiseGPBKQR hactual hz

/-- Global native RH follows once the actual GP state assignment is proved to
intertwine one independently supplied π/BKQR contraction. -/
theorem riemannHypothesis_of_actualGPIntertwiningGap
    {Q : PiBKQRContraction}
    {gpState : ℂ → GPBKQRState}
    (hgap : ActualGPIntertwiningGap Q gpState) :
    RiemannHypothesis := by
  exact actualPointwiseGPBKQRPlusPassivity_iff_riemannHypothesis.mp
    (actualPointwisePlusPassivity_of_actualGPIntertwiningGap hgap)

end ConstructiveCriticalLine
