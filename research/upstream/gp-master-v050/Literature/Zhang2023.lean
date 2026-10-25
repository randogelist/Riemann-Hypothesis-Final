namespace RHGPBKQR

/-- The Riemann Hypothesis proposition used by the literature interface. -/
opaque RiemannHypothesis : Prop

/-- ! Alternating sign `(-1)^n`, kept core-only. -/
def AltSign : Nat → Int
  | 0 => 1
  | n + 1 => - AltSign n

/-- Core-only coefficient transform for the reduced centered Xi logarithmic jet. -/
opaque ReducedXiLogJetOf : (Nat → Int) → (Nat → Int)

/-- Literature centered Xi coefficient sequence. -/
opaque ZhangCenteredXiCoeff : Nat → Int

/-- Literature reduced centered Xi logarithmic jet. -/
def ZhangReducedXiLogJetCoeff : Nat → Int :=
  ReducedXiLogJetOf ZhangCenteredXiCoeff

/-- Reduced Xi-log jet to centered `R = Theta'/Theta` Taylor jet. -/
def ReducedXiLogJetToCenteredRJet (q : Nat → Int) : Nat → Int :=
  fun j => AltSign j * q j

/-- Literature centered R jet. -/
def ZhangCenteredRJetCoeff : Nat → Int :=
  ReducedXiLogJetToCenteredRJet ZhangReducedXiLogJetCoeff

/-- Centered R jet to Zhang raw moments. -/
def CenteredRJetToRawMoment (r : Nat → Int) : Nat → Int :=
  fun k => AltSign (k + 1) * r (k + 1)

/-- Zhang raw centered moments. -/
def ZhangRawMomentCoeff : Nat → Int :=
  CenteredRJetToRawMoment ZhangCenteredRJetCoeff

/-- Zhang's positive scale normalization from equation (3.10). -/
opaque ZhangScaleNormalize : (Nat → Int) → (Nat → Int)

/-- Zhang normalized coefficient sequence. -/
def ZhangNormalizedCoeff : Nat → Int :=
  ZhangScaleNormalize ZhangRawMomentCoeff

/-- Recursive signed finite difference `(-1)^k Δ^k c_n`. -/
def HausdorffDiff (c : Nat → Int) : Nat → Nat → Int
  | n, 0 => c n
  | n, k + 1 => HausdorffDiff c n k - HausdorffDiff c (n + 1) k

/-- Integer nonnegativity carrier. -/
def IntNonnegative (z : Int) : Prop :=
  ∃ m : Nat, z = Int.ofNat m

/-- Complete Hausdorff positivity for an explicit sequence. -/
def SequenceHausdorffPositive (c : Nat → Int) : Prop :=
  ∀ n k : Nat, IntNonnegative (HausdorffDiff c n k)

/-- Zhang's normalized Hausdorff condition. -/
def HausdorffPositive : Prop :=
  SequenceHausdorffPositive ZhangNormalizedCoeff

namespace Literature.Zhang2023

/-
LITERATURE ANCHOR
Ruiming Zhang, "An Application of Hausdorff Moment Problem", arXiv:2303.09396 (2023),
Corollary 6 / equation (3.10).
Exactly one research axiom is contributed by this file.
-/
axiom RH_IFF_HAUSDORFF_ANCHOR :
    RiemannHypothesis ↔ HausdorffPositive

end Literature.Zhang2023
end RHGPBKQR
