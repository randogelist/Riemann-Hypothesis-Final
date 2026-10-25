import Derivations.HilbertJetRecovery
import Derivations.ActualXiWeakHilbert
import Mathlib.Analysis.InnerProductSpace.Dual

set_option maxHeartbeats 1600000
set_option maxRecDepth 2048

namespace NativeSolobolo.SignedBernstein

open scoped BigOperators

/-- Exact bounded-dual characterization in the already-constructed coordinate
Hilbert space.  No integral graph-norm identification is used or claimed. -/
theorem WEAK_BOUND_IFF_BOUNDED_LEGENDRE_FUNCTIONAL (s : ℕ → ℝ) :
    WeakEnergyBound s ↔
      ∃ L : WeakHilbert →L[ℝ] ℝ,
        ∀ k : ℕ, L (legendreProbe k) = legendreMode s k := by
  constructor
  · intro h
    have hs : WeakEnergySummable s := (WEAK_ENERGY_BOUND_IFF_SUMMABLE s).1 h
    refine ⟨InnerProductSpace.toDual ℝ WeakHilbert (weakLimitVector s hs), ?_⟩
    intro k
    simpa only [InnerProductSpace.toDual_apply_apply] using
      WEAK_LIMIT_VECTOR_LEGENDRE_PAIRING s hs k
  · rintro ⟨L, hL⟩
    let u : WeakHilbert := (InnerProductSpace.toDual ℝ WeakHilbert).symm L
    apply (WEAK_ENERGY_IFF_HILBERT_VECTOR_EXISTS s).2
    refine ⟨u, ?_⟩
    intro k
    have hu : inner ℝ u (legendreProbe k) = legendreMode s k := by
      change inner ℝ ((InnerProductSpace.toDual ℝ WeakHilbert).symm L)
        (legendreProbe k) = legendreMode s k
      rw [InnerProductSpace.toDual_symm_apply]
      exact hL k
    rw [INNER_LEGENDRE_PROBE] at hu
    have hnz : Real.sqrt (weakWeight k) ≠ 0 :=
      ne_of_gt (Real.sqrt_pos.2 (WEAK_WEIGHT_POS k))
    have hcoord := (div_eq_iff hnz).1 hu
    change u k = Real.sqrt (weakWeight k) * legendreMode s k
    rw [hcoord]
    ring

/-- Triangular inversion forces any linear functional matching the monomial
probes to match the explicit Legendre transform as well. -/
theorem MONOMIAL_FUNCTIONAL_RECOVERS_LEGENDRE
    (s : ℕ → ℝ) (L : WeakHilbert →L[ℝ] ℝ)
    (hs : ∀ n : ℕ, L (monomialProbe n) = s n) (k : ℕ) :
    L (legendreProbe k) = legendreMode s k := by
  have hmono : L (monomialProbe k) =
      (legendreLeading k)⁻¹ *
        (L (legendreProbe k) -
          ∑ j : Fin k, legendreCoefficient k j.val * L (monomialProbe j.val)) := by
    conv_lhs => rw [monomialProbe]
    simp only [map_smul, map_sub, map_sum, smul_eq_mul]
  simp_rw [hs] at hmono
  have hnz := LEGENDRE_LEADING_NE_ZERO k
  field_simp [hnz] at hmono
  rw [LEGENDRE_MODE_TRIANGULAR]
  nlinarith

/-- This removes the need to prescribe coordinates when constructing a dual:
matching the actual monomial probes is an equivalent bounded-functional target. -/
theorem WEAK_BOUND_IFF_BOUNDED_JET_FUNCTIONAL (s : ℕ → ℝ) :
    WeakEnergyBound s ↔
      ∃ L : WeakHilbert →L[ℝ] ℝ,
        ∀ n : ℕ, L (monomialProbe n) = s n := by
  constructor
  · intro h
    have hs : WeakEnergySummable s := (WEAK_ENERGY_BOUND_IFF_SUMMABLE s).1 h
    refine ⟨InnerProductSpace.toDual ℝ WeakHilbert (weakLimitVector s hs), ?_⟩
    intro n
    simpa only [InnerProductSpace.toDual_apply_apply] using
      WEAK_LIMIT_VECTOR_RECOVERS_JET s hs n
  · rintro ⟨L, hL⟩
    exact (WEAK_BOUND_IFF_BOUNDED_LEGENDRE_FUNCTIONAL s).2
      ⟨L, MONOMIAL_FUNCTIONAL_RECOVERS_LEGENDRE s L hL⟩

theorem ACTUAL_US_IFF_BOUNDED_JET_FUNCTIONAL :
    ActualWeakEnergyBound ↔
      ∃ L : WeakHilbert →L[ℝ] ℝ,
        ∀ n : ℕ, L (monomialProbe n) = xiJet n := by
  exact WEAK_BOUND_IFF_BOUNDED_JET_FUNCTIONAL xiJet

end NativeSolobolo.SignedBernstein
