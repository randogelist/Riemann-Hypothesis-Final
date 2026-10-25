import Frontier.OurFrontier

namespace RHGPBKQR

/--
!!! Zhang 2023 equation (3.6): the centered Xi Taylor coefficients are positive
moments of Riemann's positive Phi-kernel.  The analytic equality is a
citation-pinned landing identity; the common coefficient sequence itself lives
in the Zhang-free core.
-/
opaque Zhang2023PhiMomentIdentity : Prop

/-- !!! Zhang 2023 equation (3.7): raw moments from the centered logarithmic derivative. -/
opaque Zhang2023RawMomentDerivativeIdentity : Prop

/-- !! Zhang 2023 equation (3.9): raw-moment recurrence in centered Xi coefficients. -/
opaque Zhang2023RawMomentRecurrenceIdentity : Prop

/-- !!! One-paper Zhang-2023 literature bundle. -/
structure Zhang2023LiteraturePackage : Prop where
  phiMomentIdentity : Zhang2023PhiMomentIdentity
  rawMomentDerivativeIdentity : Zhang2023RawMomentDerivativeIdentity
  rawMomentRecurrenceIdentity : Zhang2023RawMomentRecurrenceIdentity
  rhIffHausdorff : RiemannHypothesis ↔ HausdorffPositive

namespace Literature.Zhang2023

/-
LITERATURE ANCHOR
Ruiming Zhang, "An Application of Hausdorff Moment Problem", arXiv:2303.09396
(2023), equations (3.6)-(3.10), especially Corollary 6.
Exactly one research axiom is contributed by this paper.
-/
axiom ZHANG2023_FRONTIER_ANCHOR : Zhang2023LiteraturePackage

/-- !!! Zhang 2023: positive Phi-moment expansion of the centered Xi slice. -/
theorem PHI_MOMENT_IDENTITY_ANCHOR : Zhang2023PhiMomentIdentity :=
  ZHANG2023_FRONTIER_ANCHOR.phiMomentIdentity

/-- !!! Zhang 2023: raw moments from the centered logarithmic derivative. -/
theorem RAW_MOMENT_DERIVATIVE_IDENTITY_ANCHOR : Zhang2023RawMomentDerivativeIdentity :=
  ZHANG2023_FRONTIER_ANCHOR.rawMomentDerivativeIdentity

/-- !! Zhang 2023: raw-moment recurrence in Xi Taylor coefficients. -/
theorem RAW_MOMENT_RECURRENCE_IDENTITY_ANCHOR : Zhang2023RawMomentRecurrenceIdentity :=
  ZHANG2023_FRONTIER_ANCHOR.rawMomentRecurrenceIdentity

/-- !!! Zhang 2023 Corollary 6: RH iff scaled Hausdorff positivity. -/
theorem RH_IFF_HAUSDORFF_ANCHOR :
    RiemannHypothesis ↔ HausdorffPositive :=
  ZHANG2023_FRONTIER_ANCHOR.rhIffHausdorff

end Literature.Zhang2023
end RHGPBKQR
