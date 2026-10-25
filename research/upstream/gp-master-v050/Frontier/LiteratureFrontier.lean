import Literature.Zhang2023
import Literature.Sokal2020
import Literature.BergerGellarWallen
import Literature.Agler1985

namespace RHGPBKQR.Frontier

open RHGPBKQR

/--
!!! LITERATURE FRONTIER
The strongest literature classification used by the project.
No theorem is assumed here; the proposition is proved in
`Derivations/LiteratureFrontierDerivation.lean` from the four isolated anchors.
-/
def LiteratureFrontier : Prop :=
  RiemannHypothesis ↔
    (HausdorffPositive ∧ WallAdmissible ∧
     WeightedShiftSubnormal ∧ WeightedShiftCompletelyHypercontractive)

end RHGPBKQR.Frontier
