import Core.ActualXiJet
import Derivations.FinitePackets

namespace NativeSolobolo.SignedBernstein

open scoped BigOperators

noncomputable def actualCoeff : ℕ → ℕ → ℝ := coeff xiJet
noncomputable def actualRowMass : ℕ → ℝ := rowMass xiJet
noncomputable def actualRowCancellation : ℕ → ℝ := rowCancellation xiJet
noncomputable def actualPacket : ℕ → ℂ → ℂ := normalizedPacket xiJet

/-- The remaining analytic budget is named but is not asserted. -/
def ActualUniformRowBound : Prop := UniformRowBound xiJet

def ActualCancellationSummable : Prop := Summable actualRowCancellation

/-- No model, derivative oracle, or positivity hypothesis occurs in this specialization. -/
theorem ACTUAL_XI_COEFFICIENT_FORMULA (N j : ℕ) :
    actualCoeff N j = (N.choose j : ℝ) *
      ∑ k ∈ Finset.range (N - j + 1),
        ((N - j).choose k : ℝ) * (-1 : ℝ) ^ k * xiJet (j + k) :=
  COEFFICIENT_EXPLICIT xiJet N j

theorem ACTUAL_XI_ROW_MASS_LEDGER (N : ℕ) :
    actualRowMass N = |xiJet 0| + 2 *
      ∑ r ∈ Finset.range N, actualRowCancellation r :=
  ROW_MASS_LEDGER xiJet N

theorem ACTUAL_XI_ROW_MASS_REFINEMENT (N : ℕ) :
    actualRowMass (N + 1) = actualRowMass N + 2 * actualRowCancellation N :=
  ROW_MASS_REFINEMENT xiJet N

theorem ACTUAL_XI_ROW_MASS_MONOTONE : Monotone actualRowMass :=
  ROW_MASS_MONOTONE xiJet

/-- Equivalence of the two explicit budget obligations, not a proof of either obligation. -/
theorem ACTUAL_XI_BUDGET_IFF_CANCELLATION_SUMMABLE :
    ActualUniformRowBound ↔ ActualCancellationSummable :=
  ROW_BOUND_IFF_CANCELLATION_SUMMABLE xiJet

theorem ACTUAL_PACKET_CENTER (N : ℕ) :
    actualPacket N 0 = 4 * (actualCurvatureKernel 1 : ℂ) := by
  change normalizedPacket xiJet N 0 = _
  rw [NORMALIZED_PACKET_AT_ZERO, XI_JET_ZERO]

theorem ACTUAL_PACKET_LOCAL_BOUND (N : ℕ) (z : ℂ)
    (hz : ‖Complex.exp z - 1‖ < 1) :
    ‖actualPacket N z‖ ≤
      ‖4 * Complex.exp (z / 4)‖ *
        (actualRowMass N * (1 / (1 - ‖Complex.exp z - 1‖) ^ 2)) :=
  NORMALIZED_PACKET_LOCAL_BOUND xiJet N z hz

/-- Conditional estimate after the concrete cancellation series has been bounded. -/
theorem ACTUAL_ROW_MASS_BOUND_FROM_SUMMABILITY
    (h : ActualCancellationSummable) (N : ℕ) :
    actualRowMass N ≤ |xiJet 0| + 2 * ∑' r, actualRowCancellation r :=
  ROW_MASS_LE_TOTAL_CANCELLATION xiJet h N

end NativeSolobolo.SignedBernstein
