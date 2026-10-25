import Literature.BergerGellarWallen

namespace RHGPBKQR

/-- Complete hypercontractivity of the same canonical weighted shift. -/
opaque WeightedShiftCompletelyHypercontractive : Prop

namespace Literature.Agler1985

/-
LITERATURE ANCHOR
Jim Agler, "Hypercontractions and subnormality", J. Operator Theory 13 (1985),
203-217, Theorem 3.1: complete hypercontractivity is equivalent to contractive
subnormality.

Exactly one research axiom is contributed by this file.
-/
axiom COMPLETE_HYPERCONTRACTIVE_IFF_SUBNORMAL_ANCHOR :
    WeightedShiftCompletelyHypercontractive ↔ WeightedShiftSubnormal

end Literature.Agler1985
end RHGPBKQR
