import Bridge.AllDepthWidderPositivity
import AWPI.PhiRH.MathlibBridge
import Mathlib.Analysis.Complex.SqrtDeriv

namespace NativeSoloboloContinuant

open Complex
open AWPI.PhiRH.MathlibBridge

/-- Literal centered-square coordinate z = (rho-1/2)^2 in real/imaginary components. -/
noncomputable def actualCenteredSquare (rho : ℂ) : ℂ :=
  Complex.mk
    ((rho.re - (1 / 2 : ℝ)) ^ 2 - rho.im ^ 2)
    (2 * (rho.re - (1 / 2 : ℝ)) * rho.im)

/-- Any point off the critical line has centered square in the complex slit plane. -/
theorem ACTUAL_CENTERED_SQUARE_MEM_SLIT_PLANE_OF_RE_NE_HALF
    (rho : ℂ)
    (hRe : rho.re ≠ (1 / 2 : ℝ)) :
    actualCenteredSquare rho ∈ Complex.slitPlane := by
  rw [Complex.mem_slitPlane_iff]
  change
    0 < ((rho.re - (1 / 2 : ℝ)) ^ 2 - rho.im ^ 2) ∨
      2 * (rho.re - (1 / 2 : ℝ)) * rho.im ≠ 0
  have hSub : rho.re - (1 / 2 : ℝ) ≠ 0 := by
    apply sub_ne_zero.mpr
    simpa [one_div] using hRe
  by_cases hIm : rho.im = 0
  · left
    rw [hIm]
    simpa using sq_pos_of_ne_zero hSub
  · right
    exact mul_ne_zero (mul_ne_zero (by norm_num) hSub) hIm

/--
The actual zero-square exclusion supplied by a Stieltjes logarithmic derivative:
every genuine nontrivial zeta zero has its centered square on the Stieltjes cut.
-/
def ActualSlitZeroFree : Prop :=
  ∀ rho : ℂ, NontrivialZetaZero rho →
    actualCenteredSquare rho ∉ Complex.slitPlane

/--
!!! The remaining zero geometry is elementary: slit zero-freeness forces every
nontrivial zeta zero onto Re rho = 1/2, hence Mathlib RH.
-/
theorem ACTUAL_SLIT_ZERO_FREE_IMPLIES_MATHLIB_RH
    (hSlit : ActualSlitZeroFree) :
    RiemannHypothesis := by
  unfold RiemannHypothesis
  intro rho hz htrivial hneOne
  have hNTZ : NontrivialZetaZero rho := ⟨hz, htrivial, hneOne⟩
  by_contra hRe
  exact (hSlit rho hNTZ)
    (ACTUAL_CENTERED_SQUARE_MEM_SLIT_PLANE_OF_RE_NE_HALF rho hRe)

/--
Classical-specialized analytic frontier.
Intended derivation: all diagonal Widder inequalities for R=Theta'/Theta,
together with R(a)>=0, imply the Stieltjes representation and therefore no
Theta zero in C\(-infinity,0].
-/
def ActualWidderStieltjesSlitExclusion : Prop :=
  ActualAllDepthWidderPositive → ActualSlitZeroFree

/--
Reverse analytic frontier.
Under RH all centered Theta zeros are negative real; the logarithmic derivative
has a positive Stieltjes/zero-channel representation, hence every actual Widder
moment is nonnegative.
-/
def RHImpliesAllDepthWidderPositive : Prop :=
  RiemannHypothesis → ActualAllDepthWidderPositive

end NativeSoloboloContinuant
