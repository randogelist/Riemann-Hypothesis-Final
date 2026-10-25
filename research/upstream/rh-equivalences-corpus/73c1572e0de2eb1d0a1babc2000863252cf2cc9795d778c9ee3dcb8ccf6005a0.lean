import Derivations.ActualXiEnergy
import Derivations.HilbertJetRecovery
import Derivations.WeakEnergyGrowth

namespace NativeSolobolo.SignedBernstein

open scoped BigOperators
open Filter Topology

noncomputable def actualWeakEnergy : ℕ → ℝ := weakEnergy xiJet
noncomputable def actualWeakVector : ℕ → WeakHilbert := weakPartialVector xiJet

/-- The new estimate is a named proposition, not a field that is automatically filled. -/
def ActualWeakEnergyBound : Prop := WeakEnergyBound xiJet

def ActualWeakEnergySummable : Prop := WeakEnergySummable xiJet

theorem ACTUAL_WEAK_ENERGY_BOUND_IFF_SUMMABLE :
    ActualWeakEnergyBound ↔ ActualWeakEnergySummable :=
  WEAK_ENERGY_BOUND_IFF_SUMMABLE xiJet

/-- Entirely unconditional finite vector norm computation. -/
theorem ACTUAL_WEAK_VECTOR_NORM_SQ (M : ℕ) :
    ‖actualWeakVector M‖ ^ 2 = actualWeakEnergy M :=
  WEAK_PARTIAL_VECTOR_NORM_SQ xiJet M

/-- Entirely unconditional, all-order finite reconstruction of the genuine xiJet. -/
theorem ACTUAL_WEAK_VECTOR_RECOVERS_XI_JET (M n : ℕ) (hn : n ≤ M) :
    inner ℝ (actualWeakVector M) (monomialProbe n) = xiJet n :=
  WEAK_PARTIAL_VECTOR_RECOVERS_JET xiJet M n hn

theorem ACTUAL_WEAK_VECTOR_RECOVERS_BERNSTEIN (M N j : ℕ)
    (hNM : N ≤ M) (hj : j ≤ N) :
    inner ℝ (actualWeakVector M) (bernsteinCellProbe N j) = coeff xiJet N j :=
  WEAK_PARTIAL_VECTOR_BERNSTEIN_PAIRING xiJet M N j hNM hj

/-- Precise existence criterion: the prescribed infinite vector exists iff
its explicit actual coordinate-energy sums are bounded. -/
theorem ACTUAL_WEAK_ENERGY_IFF_HILBERT_VECTOR_EXISTS :
    ActualWeakEnergyBound ↔
      ∃ u : WeakHilbert, ∀ k, u k = weakCoordinate xiJet k :=
  WEAK_ENERGY_IFF_HILBERT_VECTOR_EXISTS xiJet

/-- The estimate is kept as a hypothesis; the vector, convergence and all-order
xiJet identification are constructed from it. -/
theorem ACTUAL_WEAK_BOUND_CONSTRUCTS_LIMIT
    (h : ActualWeakEnergyBound) :
    ∃ u : WeakHilbert,
      Tendsto actualWeakVector atTop (𝓝 u) ∧
      (∀ n : ℕ, inner ℝ u (monomialProbe n) = xiJet n) ∧
      ‖u‖ ^ 2 = ∑' k : ℕ, weakEnergyTerm xiJet k := by
  have hs : WeakEnergySummable xiJet :=
    (WEAK_ENERGY_BOUND_IFF_SUMMABLE xiJet).1 h
  refine ⟨weakLimitVector xiJet hs, ?_, ?_, ?_⟩
  · exact WEAK_PARTIAL_VECTORS_CONVERGE xiJet hs
  · exact WEAK_LIMIT_VECTOR_RECOVERS_JET xiJet hs
  · exact WEAK_LIMIT_VECTOR_NORM_SQ xiJet hs

/-- Polynomial control of modalEnergy is fully derived from the weak estimate. -/
theorem ACTUAL_WEAK_BOUND_IMPLIES_MODAL_GROWTH
    (h : ActualWeakEnergyBound) :
    ∃ B : ℝ, 0 ≤ B ∧ ∀ N : ℕ,
      modalEnergy xiJet N ≤ B * ((N : ℝ) + 1) ^ 5 := by
  obtain ⟨B, hB⟩ := h
  exact ⟨B, (WEAK_ENERGY_NONNEG xiJet 0).trans (hB 0),
    WEAK_BOUND_IMPLIES_MODAL_POLYNOMIAL xiJet B hB⟩

/-- All-depth row transfer is conditional on the separately displayed spectral
identity, which the old package proves only up to depth six. -/
theorem ACTUAL_WEAK_BOUND_AND_DIAGONALIZATION_IMPLIES_POLYNOMIAL_ENERGY
    (h : ActualWeakEnergyBound) (hdiag : AllDepthDiagonalization xiJet) :
    ActualPolynomialEnergyBound :=
  WEAK_BOUND_AND_DIAGONALIZATION_IMPLIES_POLYNOMIAL_ENERGY xiJet h hdiag

theorem ACTUAL_WEAK_BOUND_AND_DIAGONALIZATION_IMPLIES_ABSOLUTE_ROW_SERIES
    (h : ActualWeakEnergyBound) (hdiag : AllDepthDiagonalization xiJet)
    (z v : ℂ) (hz : ‖z‖ ≤ 1) (hv : ‖v‖ < 1) :
    Summable (fun N : ℕ => ‖actualRowPolynomial N z * v ^ N‖) :=
  WEAK_BOUND_AND_DIAGONALIZATION_IMPLIES_ABSOLUTE_ROW_SERIES xiJet h hdiag z v hz hv

/-- At the already verified depths no spectral-identity hypothesis is needed. -/
theorem ACTUAL_WEAK_BOUND_LOW_DEPTH_ROW_GROWTH
    (B : ℝ) (hB : ∀ M : ℕ, actualWeakEnergy M ≤ B)
    (N : ℕ) (hN : N ≤ 6) :
    actualRowEnergy N ≤ B * ((N : ℝ) + 1) ^ 5 := by
  rw [ACTUAL_XI_LOW_DEPTH_LEGENDRE N hN]
  exact WEAK_BOUND_IMPLIES_MODAL_POLYNOMIAL xiJet B hB N

end NativeSolobolo.SignedBernstein
