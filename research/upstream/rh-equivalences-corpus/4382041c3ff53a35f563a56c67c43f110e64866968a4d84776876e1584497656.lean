namespace RHGPBKQR

/-- The Riemann Hypothesis proposition used by the common core/literature interface. -/
opaque RiemannHypothesis : Prop

/-- ! Alternating sign `(-1)^n`, kept core-only. -/
def AltSign : Nat → Int
  | 0 => 1
  | n + 1 => - AltSign n

/--
!! Formal coefficient transform extracting the reduced centered odd logarithmic
jet from a completed centered Xi-slice coefficient sequence.
-/
opaque ReducedXiLogJetOf : (Nat → Int) → (Nat → Int)

/-- Common centered Xi coefficient sequence.  This is mathematical data, not a literature axiom. -/
opaque ZhangCenteredXiCoeff : Nat → Int

/-- !! Common/Xi reduced odd logarithmic jet. -/
def ZhangReducedXiLogJetCoeff : Nat → Int :=
  ReducedXiLogJetOf ZhangCenteredXiCoeff

/-- !! Reduced centered Xi-log jet to centered `R = Theta'/Theta` jet. -/
def ReducedXiLogJetToCenteredRJet (q : Nat → Int) : Nat → Int :=
  fun j => AltSign j * q j

/-- !! Common centered Taylor jet `r_j = R^(j)(0)/j!`. -/
def ZhangCenteredRJetCoeff : Nat → Int :=
  ReducedXiLogJetToCenteredRJet ZhangReducedXiLogJetCoeff

/-- !! Universal centered-R-jet to raw-moment transform. -/
def CenteredRJetToRawMoment (r : Nat → Int) : Nat → Int :=
  fun k => AltSign (k + 1) * r (k + 1)

/-- Common raw centered moment sequence. -/
def ZhangRawMomentCoeff : Nat → Int :=
  CenteredRJetToRawMoment ZhangCenteredRJetCoeff

/-- Common scale normalization `m_k ↦ m_k / L^k` used at the Zhang landing. -/
opaque ZhangScaleNormalize : (Nat → Int) → (Nat → Int)

/-- Common scale-normalized coefficient sequence. -/
def ZhangNormalizedCoeff : Nat → Int :=
  ZhangScaleNormalize ZhangRawMomentCoeff

/-- Recursive signed finite difference: `(-1)^k Δ^k c_n`. -/
def HausdorffDiff (c : Nat → Int) : Nat → Nat → Int
  | n, 0 => c n
  | n, k + 1 => HausdorffDiff c n k - HausdorffDiff c (n + 1) k

/-- Core-only positivity carrier. -/
def IntNonnegative (z : Int) : Prop :=
  ∃ m : Nat, z = Int.ofNat m

/-- Complete Hausdorff finite-difference positivity for an explicit sequence. -/
def SequenceHausdorffPositive (c : Nat → Int) : Prop :=
  ∀ n k : Nat, IntNonnegative (HausdorffDiff c n k)

/-- The common Hausdorff landing predicate. -/
def HausdorffPositive : Prop :=
  SequenceHausdorffPositive ZhangNormalizedCoeff


/--
!! Core-only completed GP normalization.
The completed GP object is normalized by `G(1,s)=Xi(s)`; at coefficient level
this means that its distinguished centered `u = 1` slice is the centered Xi
coefficient sequence.  This is a framework normalization, not an additional
research axiom.
-/
def GPCompletedXiSliceCoeff : Nat → Int :=
  ZhangCenteredXiCoeff

/-- ! Canonical completed-GP centered R jet. -/
def CanonicalGPCenteredRJet : Nat → Int :=
  ReducedXiLogJetToCenteredRJet (ReducedXiLogJetOf GPCompletedXiSliceCoeff)

/-- ! Canonical completed-GP raw moment sequence. -/
def CanonicalGPRawMoment : Nat → Int :=
  CenteredRJetToRawMoment CanonicalGPCenteredRJet

/-- !! Canonical completed-GP normalized Hausdorff coefficient sequence. -/
def CanonicalGPNormalizedCoeff : Nat → Int :=
  ZhangScaleNormalize CanonicalGPRawMoment

/-- ! Contour-gauge certificate data. -/
structure GPContourGaugeData where
  mode : Nat → Int
  rhSlice : Int
  zeroMode : mode 0 = rhSlice

namespace GPContourGaugeData

/-- !! Distinguished completed `u = 1` GP slice. -/
def completedSliceCoeff (_g : GPContourGaugeData) : Nat → Int :=
  GPCompletedXiSliceCoeff

/-- !! Reduced centered logarithmic jet extracted from the completed GP slice. -/
def reducedXiLogJet (g : GPContourGaugeData) : Nat → Int :=
  ReducedXiLogJetOf g.completedSliceCoeff

/-- !! Centered `R` jet reconstructed from the reduced centered Xi-log jet. -/
def centeredRJet (g : GPContourGaugeData) : Nat → Int :=
  ReducedXiLogJetToCenteredRJet g.reducedXiLogJet

end GPContourGaugeData

/-- !! GP shift-ladder certificate. -/
structure GPShiftLadderData (g : GPContourGaugeData) where
  shifted : Nat → Int
  modeShift : ∀ n : Nat, g.mode n = shifted n

/--
!! Centered GP jet.  The `R` jet is reconstructed from the completed GP slice.
-/
structure GPJetData {g : GPContourGaugeData} (l : GPShiftLadderData g) where
  coeff : Nat → Int
  jetShift : ∀ n : Nat, CenteredRJetToRawMoment g.centeredRJet n = l.shifted n
  normalized : coeff = ZhangScaleNormalize (CenteredRJetToRawMoment g.centeredRJet)

/--
!! Pascal-Hopf table.  This is the signed boundary/recursion object.
-/
structure PascalHopfTable (c : Nat → Int) where
  value : Nat → Nat → Int
  boundary : ∀ n : Nat, value n 0 = c n
  split : ∀ n k : Nat, value n k = value (n + 1) k + value n (k + 1)

/--
!!! Positive Pascal-Hopf realization.  This is the first extended RH anchor:
the Pascal recursion is exact and every node lies in the nonnegative integer cone.
-/
structure PositivePascalHopfData (c : Nat → Int) where
  value : Nat → Nat → Int
  boundary : ∀ n : Nat, value n 0 = c n
  split : ∀ n k : Nat, value n k = value (n + 1) k + value n (k + 1)
  positive : ∀ n k : Nat, IntNonnegative (value n k)

namespace PositivePascalHopfData

/-- !! Forget positivity and retain the exact Pascal-Hopf table. -/
def table {c : Nat → Int} (p : PositivePascalHopfData c) : PascalHopfTable c where
  value := p.value
  boundary := p.boundary
  split := p.split

end PositivePascalHopfData

/--
!!! Primitive BKQR energy realization.
The hard constructive form is an `Nat`-valued energy lattice whose integer image
has exactly the GP boundary and Pascal-Hopf splitting law.
-/
structure BKQREnergyData (c : Nat → Int) where
  energy : Nat → Nat → Nat
  boundary : ∀ n : Nat, Int.ofNat (energy n 0) = c n
  split : ∀ n k : Nat,
    energy n k = energy (n + 1) k + energy n (k + 1)

namespace BKQREnergyData

/-- !!! The primitive nonnegative BKQR energy generates the signed Pascal table. -/
def table {c : Nat → Int} (e : BKQREnergyData c) : PascalHopfTable c where
  value := fun n k => Int.ofNat (e.energy n k)
  boundary := e.boundary
  split := by
    intro n k
    have h := congrArg Int.ofNat (e.split n k)
    exact h

/-- !!! The primitive BKQR energy also generates a positive Pascal-Hopf datum. -/
def positiveTable {c : Nat → Int} (e : BKQREnergyData c) : PositivePascalHopfData c where
  value := fun n k => Int.ofNat (e.energy n k)
  boundary := e.boundary
  split := by
    intro n k
    have h := congrArg Int.ofNat (e.split n k)
    exact h
  positive := by
    intro n k
    exact ⟨e.energy n k, rfl⟩

end BKQREnergyData


/--
!!! Finite BKQR trace-resolvent approximation data, in the core-only coefficient shadow.
`coeff Y` is the Taylor/moment coefficient sequence of the finite BKQR
trace-resolvent at stage `Y`.  Every finite-stage Hausdorff cell is a genuine
nonnegative energy, and every finite target jet eventually agrees with the
canonical GP/Zhang jet.  In the analytic layer the last field is replaced by
local-uniform resolvent convergence plus Cauchy coefficient convergence.
-/
structure BKQRTraceResolventApproxData (c : Nat → Int) where
  coeff : Nat → Nat → Int
  energy : Nat → Nat → Nat → Nat
  stageSquare : ∀ Y n k : Nat,
    HausdorffDiff (coeff Y) n k = Int.ofNat (energy Y n k)
  finiteJet : ∀ cutoff : Nat, ∃ Y0 : Nat,
    ∀ Y : Nat, Y0 ≤ Y → ∀ n : Nat, n ≤ cutoff → coeff Y n = c n

/-- Concrete core-only Pascal/Hausdorff certificate. -/
def ConcreteHausdorff (c : Nat → Int) : Prop :=
  Nonempty (BKQREnergyData c)

/-- !! BKQR Gram realization is the primitive energy lattice. -/
abbrev BKQRGramData (c : Nat → Int) := BKQREnergyData c

/-- !!! BKQR contraction realization; contraction is derived from Pascal splitting. -/
abbrev BKQRContractionData (c : Nat → Int) := BKQREnergyData c

/-- !!! Internal data bundle. -/
structure OurStrongData where
  contour : GPContourGaugeData
  ladder : GPShiftLadderData contour
  jet : GPJetData ladder
  bkqr : BKQRContractionData jet.coeff

/-- ! Canonical core-only contour realization of the completed GP slice. -/
def CanonicalGPContour : GPContourGaugeData where
  mode := CanonicalGPRawMoment
  rhSlice := CanonicalGPRawMoment 0
  zeroMode := rfl

/-- ! Canonical core-only GP shift ladder. -/
def CanonicalGPShiftLadder : GPShiftLadderData CanonicalGPContour where
  shifted := CanonicalGPRawMoment
  modeShift := by intro n; rfl

/-- !! Canonical core-only GP jet. -/
def CanonicalGPJet : GPJetData CanonicalGPShiftLadder where
  coeff := CanonicalGPNormalizedCoeff
  jetShift := by intro n; rfl
  normalized := rfl

/-- !! A BKQR energy realization of the canonical GP jet gives full strong data. -/
def CanonicalOurStrongData
    (e : BKQREnergyData CanonicalGPNormalizedCoeff) : OurStrongData where
  contour := CanonicalGPContour
  ladder := CanonicalGPShiftLadder
  jet := CanonicalGPJet
  bkqr := e

namespace Frontier

/-- !!! Extended anchor: complete Hausdorff positivity of the canonical GP jet. -/
def GPJetHausdorffAnchor : Prop :=
  SequenceHausdorffPositive CanonicalGPNormalizedCoeff

/-- !!! Extended anchor: existence of a positive Pascal-Hopf realization. -/
def PascalHopfAnchor : Prop :=
  Nonempty (PositivePascalHopfData CanonicalGPNormalizedCoeff)

/-- !!! Extended anchor: existence of a natural-valued BKQR energy realization. -/
def BKQREnergyAnchor : Prop :=
  Nonempty (BKQREnergyData CanonicalGPNormalizedCoeff)


/--
!!! Extended anchor: finite positive BKQR trace-resolvents converge coefficientwise
to the canonical completed-GP/Zhang jet.
-/
def BKQRTraceResolventApproxAnchor : Prop :=
  Nonempty (BKQRTraceResolventApproxData CanonicalGPNormalizedCoeff)

/--
!!! OUR FRONTIER — constructive BKQR energy realization form.
All calibration from the completed GP slice to Zhang is definitional/derived.
The research attack surface is the explicit construction of this strong data.
-/
def OurFrontier : Prop :=
  Nonempty OurStrongData

end Frontier
end RHGPBKQR
