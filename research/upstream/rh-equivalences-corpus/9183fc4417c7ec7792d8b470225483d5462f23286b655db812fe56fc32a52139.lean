import Literature.Zhang2023

namespace RHGPBKQR

/--
!! Zhang 2022 equation (3.11):
`f(x) = xi(1/2 + sqrt(x))` is the genus-zero entire function obtained from Xi.
-/
opaque Zhang2022XiSquareRootEntireIdentity : Prop

/--
!!! Zhang 2022 equations (1.8)-(1.9): the complete-monotonicity hierarchy is
expressed by the differential operators `G_k^(m)` and their recursion.
-/
opaque Zhang2022CMOperatorIdentity : Prop

/--
!!! Zhang 2022 equation (2.15): the logarithmic derivative is the Laplace /
Stieltjes transform of the heat-kernel measure,
`f'(x)/f(x) = ∫_0^∞ e^(-xt) Theta(t) dt = ∫_0^∞ dmu(y)/(x+y)`.
-/
opaque Zhang2022ResolventLaplaceIdentity : Prop

/--
!!! Zhang 2022 Corollary 4, equation (3.12): existence of one derivative order
`m` for which every `G_k^(m)` is completely monotone on `(0,∞)`.
-/
opaque Zhang2022CompleteMonotonicityHierarchy : Prop

/-- !!! One-paper bundle for the 2022 continuous/Widder landing zone. -/
structure Zhang2022LiteraturePackage : Prop where
  xiSquareRootEntireIdentity : Zhang2022XiSquareRootEntireIdentity
  cmOperatorIdentity : Zhang2022CMOperatorIdentity
  resolventLaplaceIdentity : Zhang2022ResolventLaplaceIdentity
  rhIffCompleteMonotonicity :
    RiemannHypothesis ↔ Zhang2022CompleteMonotonicityHierarchy

namespace Literature.Zhang2022

/-
LITERATURE ANCHOR
Ruiming Zhang, "On Certain Genus 0 Entire Functions", arXiv:2206.05104,
Theorem 1, Lemma 3, and Corollary 4, especially equations (1.8)-(1.9),
(2.15), and (3.11)-(3.12).
Exactly one research axiom is contributed by this paper.
-/
axiom ZHANG2022_FRONTIER_ANCHOR : Zhang2022LiteraturePackage

/-- !! Zhang 2022: square-root Xi transform. -/
theorem XI_SQRT_ENTIRE_IDENTITY_ANCHOR : Zhang2022XiSquareRootEntireIdentity :=
  ZHANG2022_FRONTIER_ANCHOR.xiSquareRootEntireIdentity

/-- !!! Zhang 2022: CM operator/recursion identity. -/
theorem CM_OPERATOR_IDENTITY_ANCHOR : Zhang2022CMOperatorIdentity :=
  ZHANG2022_FRONTIER_ANCHOR.cmOperatorIdentity

/-- !!! Zhang 2022: Laplace/Stieltjes logarithmic-derivative identity. -/
theorem RESOLVENT_LAPLACE_IDENTITY_ANCHOR : Zhang2022ResolventLaplaceIdentity :=
  ZHANG2022_FRONTIER_ANCHOR.resolventLaplaceIdentity

/-- !!! Zhang 2022: RH iff the continuous complete-monotonicity hierarchy. -/
theorem RH_IFF_COMPLETE_MONOTONICITY_ANCHOR :
    RiemannHypothesis ↔ Zhang2022CompleteMonotonicityHierarchy :=
  ZHANG2022_FRONTIER_ANCHOR.rhIffCompleteMonotonicity

end Literature.Zhang2022
end RHGPBKQR
