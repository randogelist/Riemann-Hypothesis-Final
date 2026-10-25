import Master.MasterSource

namespace RHGPBKQR

/--
!!! MINIMAL CONSTRUCTION SOURCE
The smallest presently formalized construction object needed for the RH chain.
All contour/readout/BKQR wrapper data have been removed.  What remains is only:

* one carrier `Q`,
* one nonnegative energy `normSq`,
* one distinguished state `omega`,
* two commuting branches `left/right`,
* one Pythagorean split,
* the GP moment boundary.

Everything else in the current master architecture can be rebuilt from this.
-/
structure MinimalConstructionSource where
  Q : Type
  normSq : Q → Nat
  omega : Q
  left : Q → Q
  right : Q → Q
  commute : ∀ x : Q, left (right x) = right (left x)
  pythagoras : ∀ x : Q,
    normSq x = normSq (left x) + normSq (right x)
  momentBoundary : ∀ n : Nat,
    Int.ofNat (normSq (iterateOp left n omega)) =
      CanonicalGPNormalizedCoeff n

namespace MinimalConstructionSource

/-- ! Generated state `X_{n,k}=R^k L^n Ω`. -/
def state (S : MinimalConstructionSource) (n k : Nat) : S.Q :=
  iterateOp S.right k (iterateOp S.left n S.omega)

/-- ! Natural-valued generated energy. -/
def energy (S : MinimalConstructionSource) (n k : Nat) : Nat :=
  S.normSq (S.state n k)

/-- !! Left recursion follows from commutation. -/
theorem state_left (S : MinimalConstructionSource) (n k : Nat) :
    S.state (n + 1) k = S.left (S.state n k) := by
  unfold state
  simp only [iterateOp]
  exact iterateOp_commute S.left S.right S.commute k
    (iterateOp S.left n S.omega)

/-- !! Right recursion is definitional. -/
theorem state_right (S : MinimalConstructionSource) (n k : Nat) :
    S.state n (k + 1) = S.right (S.state n k) := by
  rfl

/-- !!! Pythagoras gives exact Pascal-Hopf energy splitting. -/
theorem energy_split (S : MinimalConstructionSource) (n k : Nat) :
    S.energy n k = S.energy (n + 1) k + S.energy n (k + 1) := by
  unfold energy
  rw [S.state_left n k, S.state_right n k]
  exact S.pythagoras (S.state n k)

/-- !! Generated boundary is the canonical GP moment sequence. -/
theorem energy_boundary (S : MinimalConstructionSource) (n : Nat) :
    Int.ofNat (S.energy n 0) = CanonicalGPNormalizedCoeff n := by
  exact S.momentBoundary n

end MinimalConstructionSource

namespace Frontier

/-- !!! Smallest presently formalized RH-equivalent construction anchor. -/
def MinimalConstructionAnchor : Prop :=
  Nonempty MinimalConstructionSource

end Frontier
end RHGPBKQR
