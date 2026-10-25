import Literature.Zhang2023

namespace RHGPBKQR

/-- Subnormality of the canonical weighted shift attached to the moment data. -/
opaque WeightedShiftSubnormal : Prop

namespace Literature.BergerGellarWallen

/-
LITERATURE ANCHOR
Classical Berger / Gellar-Wallen weighted-shift moment theorem: subnormality of a
scalar weighted shift is characterized by a positive representing measure for its
moment sequence; for a contraction the representing support is contained in [0,1].

Exactly one research axiom is contributed by this file.
-/
axiom HAUSDORFF_IFF_WEIGHTED_SHIFT_SUBNORMAL_ANCHOR :
    HausdorffPositive ↔ WeightedShiftSubnormal

end Literature.BergerGellarWallen
end RHGPBKQR
