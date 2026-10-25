import Literature.Zhang2023

namespace RHGPBKQR

/-- Wall/Sokal admissibility of the normalized Hausdorff continued fraction. -/
opaque WallAdmissible : Prop

namespace Literature.Sokal2020

/-
LITERATURE ANCHOR
Alan D. Sokal, "Wall's continued-fraction characterization of Hausdorff moment
sequences: A conceptual proof", Proc. Amer. Math. Soc. 148 (2020), 2111-2116.
DOI: 10.1090/proc/14884; arXiv:1903.12455.

Exactly one research axiom is contributed by this file.
-/
axiom HAUSDORFF_IFF_WALL_ANCHOR :
    HausdorffPositive ↔ WallAdmissible

end Literature.Sokal2020
end RHGPBKQR
