import ConstructiveWeakRH

namespace ConstructiveCriticalLine

open ConstructiveWeakRH

/-- The concrete base-2 scale used by the GP/BKQR critical-line upgrade. -/
noncomputable def scale2 (a : ℝ) : ℝ := Real.rpow 2 a

/-- Base-2 scale is normalized at the critical line. -/
theorem scale2_at_zero : scale2 0 = 1 := by
  simp [scale2]

/-- Base-2 real powers are strictly increasing in the exponent. -/
theorem scale2_strictMono : StrictMono scale2 := by
  intro a b hab
  simpa [scale2] using
    (Real.rpow_lt_rpow_of_exponent_lt
      (x := (2 : ℝ)) (y := a) (z := b) (by norm_num) hab)

/-- Centered horizontal coordinate. -/
noncomputable def centered (rho : ℂ) : ℝ := rho.re - (1 / 2 : ℝ)

/-- Forward GP/BKQR scale gain at a spectral point. -/
noncomputable def forwardGain (rho : ℂ) : ℝ :=
  scale2 (2 * centered rho)

/-- Scalar one-step defect attached to a positive pointwise carrier. -/
noncomputable def plusDefect (rho : ℂ) (carrier : ℝ) : ℝ :=
  forwardGain rho * carrier ^ 2 - carrier ^ 2

/--
A pointwise GP/BKQR plus-passivity witness.  This is deliberately a theorem
argument, not an axiom: the remaining analytic task is to construct this
witness from the actual GP slice at a supplied zeta zero.
-/
def PointwiseGPBKQRPlusPassivityAt (rho : ℂ) : Prop :=
  ∃ carrier : ℝ, 0 < carrier ∧ plusDefect rho carrier ≤ 0

/-- Positive one-sided BKQR passivity excludes the open right half of the
critical strip. -/
theorem re_le_half_of_plusPassivity
    {rho : ℂ} (h : PointwiseGPBKQRPlusPassivityAt rho) :
    rho.re ≤ (1 / 2 : ℝ) := by
  rcases h with ⟨carrier, hcarrier_pos, hdef⟩
  have hcarrier_ne : carrier ≠ 0 := ne_of_gt hcarrier_pos
  have hsq : 0 < carrier ^ 2 := sq_pos_of_ne_zero hcarrier_ne
  unfold plusDefect at hdef
  have hgain : forwardGain rho ≤ 1 := by
    nlinarith
  unfold forwardGain at hgain
  have hexp : 2 * centered rho ≤ 0 := by
    by_contra hnot
    have hpos : 0 < 2 * centered rho := lt_of_not_ge hnot
    have hstrict : scale2 0 < scale2 (2 * centered rho) :=
      scale2_strictMono hpos
    rw [scale2_at_zero] at hstrict
    linarith
  unfold centered at hexp
  linarith

/-- Applying the same one-sided passivity to the reflected point excludes the
open left half of the critical strip. -/
theorem half_le_re_of_reflected_plusPassivity
    {rho : ℂ} (h : PointwiseGPBKQRPlusPassivityAt (1 - rho)) :
    (1 / 2 : ℝ) ≤ rho.re := by
  have href : (1 - rho : ℂ).re ≤ (1 / 2 : ℝ) :=
    re_le_half_of_plusPassivity h
  simp at href
  linarith

/-- The minimal pointwise critical-line witness: the same plus-passivity
mechanism is available at the supplied zero and at its completed-zeta
reflection. -/
def ReflectedPointwiseGPBKQRPassivityAt (rho : ℂ) : Prop :=
  PointwiseGPBKQRPlusPassivityAt rho ∧
    PointwiseGPBKQRPlusPassivityAt (1 - rho)

/-- Pure scalar closure: reflected pointwise passivity forces the critical
line. -/
theorem criticalLine_of_reflected_plusPassivity
    {rho : ℂ} (h : ReflectedPointwiseGPBKQRPassivityAt rho) :
    rho.re = (1 / 2 : ℝ) := by
  apply le_antisymm
  · exact re_le_half_of_plusPassivity h.1
  · exact half_le_re_of_reflected_plusPassivity h.2

/--
Constructive critical-line upgrade at one supplied literal nontrivial zeta
zero.  Weak RH supplies the proved open-strip localization and completed-zeta
reflection supplies the companion nontrivial zero.  The only additional input
is the explicit reflected pointwise GP/BKQR passivity witness.
-/
theorem constructiveCriticalLineAt
    {rho : ℂ}
    (hz : NontrivialZetaZero rho)
    (hpass : ReflectedPointwiseGPBKQRPassivityAt rho) :
    rho.re = (1 / 2 : ℝ) := by
  have _hstrip : InOpenCriticalStrip rho := constructiveWeakRHAt hz
  have _href : NontrivialZetaZero (1 - rho) :=
    nontrivialZetaZero_one_sub hz
  exact criticalLine_of_reflected_plusPassivity hpass

/-- A uniform constructor interface for the still-open analytic bridge. -/
def ActualPointwiseGPBKQRPlusPassivity : Prop :=
  ∀ rho : ℂ, NontrivialZetaZero rho → PointwiseGPBKQRPlusPassivityAt rho

/-- Once the actual pointwise GP/BKQR constructor is supplied, the reflected
witness is built constructively from the already-proved zeta reflection. -/
theorem constructiveCriticalLineAt_of_actualPointwiseGPBKQR
    (hactual : ActualPointwiseGPBKQRPlusPassivity)
    {rho : ℂ} (hz : NontrivialZetaZero rho) :
    rho.re = (1 / 2 : ℝ) := by
  have href : NontrivialZetaZero (1 - rho) :=
    nontrivialZetaZero_one_sub hz
  exact criticalLine_of_reflected_plusPassivity ⟨
    hactual rho hz,
    hactual (1 - rho) href
  ⟩

end ConstructiveCriticalLine
