import AWPI.PhiRH.ScalarConcreteFrontier

namespace AWPI.PhiRH.MinimalFrontier

open AWPI.PhiRH
open AWPI.PhiRH.MathlibBridge
open AWPI.PhiRH.CriticalLineCoreDisassembly
open AWPI.PhiRH.RawConcreteFrontier
open AWPI.PhiRH.ScalarConcreteFrontier

/-- Final disassembly normal form: every literal nontrivial zeta zero lies on or
    to the left of the critical line.  This contains no GP/KQ/Phi/dyadic
    wrapper. -/
def MinimalRHFrontier : Prop :=
  ∀ rho : ℂ, NontrivialZetaZero rho → rho.re ≤ (1 / 2 : ℝ)

/-- The minimal frontier is definitionally the left critical half. -/
theorem minimalRHFrontier_iff_leftCriticalHalf :
    MinimalRHFrontier ↔ LeftCriticalHalf := by
  rfl

/-- The previous scalar dyadic core contains exactly the same logical content
    as the wrapper-free minimal frontier. -/
theorem scalarDyadicCore_iff_minimalRHFrontier :
    ScalarDyadicCore ↔ MinimalRHFrontier := by
  rw [minimalRHFrontier_iff_leftCriticalHalf]
  exact scalarDyadicCore_iff_leftCriticalHalf

/-- The raw concrete Phi/KQ frontier contains exactly the same logical content
    as the wrapper-free minimal frontier. -/
theorem rawActualPlusKQFrontier_iff_minimalRHFrontier :
    RawActualPlusKQFrontier ↔ MinimalRHFrontier := by
  exact rawActualPlusKQFrontier_iff_scalarDyadicCore.trans
    scalarDyadicCore_iff_minimalRHFrontier

/-- Genuine zeta reflection makes one directional half-line statement
    equivalent to Mathlib's literal Riemann Hypothesis.  This is an audit
    equivalence, not an unconditional proof of RH. -/
theorem minimalRHFrontier_iff_mathlibRH :
    MinimalRHFrontier ↔ RiemannHypothesis := by
  constructor
  · intro hmin
    have hscalar : ScalarDyadicCore :=
      scalarDyadicCore_iff_minimalRHFrontier.mpr hmin
    exact scalarDyadicCore_iff_mathlibRH.mp hscalar
  · intro hRH
    have hscalar : ScalarDyadicCore :=
      scalarDyadicCore_iff_mathlibRH.mpr hRH
    exact scalarDyadicCore_iff_minimalRHFrontier.mp hscalar

end AWPI.PhiRH.MinimalFrontier
