import AWPI.PhiRH.NativeRHAlgebraicWaist

namespace AWPI.PhiRH.NativeRHFinal

open AWPI.PhiRH
open AWPI.PhiRH.NativeRHExactWaist
open AWPI.PhiRH.NativeRHAlgebraicWaist

/-- Stable public terminal: Mathlib RH iff the two exact defect signs. -/
theorem RH_IFF_CANONICAL_TWO_DEFECT_SIGNS :
    RiemannHypothesis ↔
      CanonicalTwoDefectSigns :=
  CANONICAL_TWO_DEFECT_SIGNS_IFF_MATHLIB_RH.symm

/-- Stable public terminal: Mathlib RH iff the two dyadic gain bounds. -/
theorem RH_IFF_CANONICAL_GAIN_BOUNDS :
    RiemannHypothesis ↔
      CanonicalGainBounds := by

  exact
    CENTERED_BOUNDS_IFF_MATHLIB_RH.symm.trans
      GAIN_BOUNDS_IFF_CENTERED_BOUNDS.symm

/-- Stable public terminal: Mathlib RH iff centered is simultaneously
    nonpositive and nonnegative on every internal Phi zero. -/
theorem RH_IFF_CANONICAL_CENTERED_BOUNDS :
    RiemannHypothesis ↔
      CanonicalCenteredBounds :=
  CENTERED_BOUNDS_IFF_MATHLIB_RH.symm

end AWPI.PhiRH.NativeRHFinal