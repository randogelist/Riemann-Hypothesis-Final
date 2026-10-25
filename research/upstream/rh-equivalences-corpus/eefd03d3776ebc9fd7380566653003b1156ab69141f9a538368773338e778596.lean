import AWPI.PhiRH.NativeRHGlobalNormalForm
import AWPI.PhiRH.NativeRHLiteralDefects
import AWPI.PhiRH.NativeNegativeNatZeros
import AWPI.PhiRH.NativeRHExactWaist
import AWPI.PhiRH.NativeEtaPhi
import AWPI.PhiRH.NativeS1Exact

namespace AWPI.PhiRH.NativeRHOneSidedReflection

open AWPI.PhiRH
open AWPI.PhiRH.Model
open AWPI.PhiRH.MathlibBridge
open AWPI.PhiRH.NativeNegativeNatZeros
open AWPI.PhiRH.NativePhiZeroBridge
open AWPI.PhiRH.NativeEtaPhi
open AWPI.PhiRH.NativeS1Exact
open AWPI.PhiRH.NativePassivityCore
open AWPI.PhiRH.NativeRHExactWaist
open AWPI.PhiRH.NativeRHAlgebraicWaist
open AWPI.PhiRH.NativeRHLiteralDefects
open AWPI.PhiRH.DyadicScale

/--
Native functional-equation reflection preserves the project's
nontrivial-zeta-zero predicate.
-/
theorem nontrivialZetaZero_one_sub
    (rho : ℂ)
    (hz : NontrivialZetaZero rho) :
    NontrivialZetaZero (1 - rho) := by

  have hstrip :
      0 < rho.re ∧ rho.re < 1 :=
    native_nontrivialZetaZero_mem_openStrip rho hz

  have hNotNegNat :
      ∀ n : ℕ, rho ≠ -(n : ℂ) := by
    intro n hn
    have hre :
        rho.re = -(n : ℝ) := by
      simpa using congrArg Complex.re hn
    have hn0 : 0 ≤ (n : ℝ) :=
      Nat.cast_nonneg n
    linarith

  have hne1 :
      rho ≠ (1 : ℂ) := by
    intro h
    have hre :
        rho.re = 1 := by
      simpa using congrArg Complex.re h
    linarith

  have hrefZero :
      riemannZeta (1 - rho) = 0 := by
    rw [riemannZeta_one_sub hNotNegNat hne1]
    rw [hz.1]
    ring

  refine ⟨hrefZero, ?_, ?_⟩

  · intro htrivial
    rcases htrivial with ⟨n, hn⟩

    have hre :
        1 - rho.re =
          -2 * ((n : ℝ) + 1) := by
      simpa using congrArg Complex.re hn

    have hn0 :
        0 ≤ (n : ℝ) :=
      Nat.cast_nonneg n

    linarith

  · intro hOne

    have hre :
        1 - rho.re = 1 := by
      simpa using congrArg Complex.re hOne

    linarith

/--
Reflection also preserves the concrete internal Phi_eta-zero set.
-/
theorem phiZero_one_sub
    (rho : ℂ)
    (hz : PhiZero phiEta rho) :
    PhiZero phiEta (1 - rho) := by

  have hzeta :
      NontrivialZetaZero rho :=
    phiZero_to_nontrivialZetaZero rho hz

  have href :
      NontrivialZetaZero (1 - rho) :=
    nontrivialZetaZero_one_sub rho hzeta

  exact
    zetaZero_to_phiZero_of_literalS1
      phiEta
      phiEta_literalS1ValueIdentity
      (1 - rho)
      href

/--
The plus dyadic inequality is exactly Re rho ≤ 1/2.
-/
theorem plus_literal_iff_re_le_half
    (rho : ℂ) :
    dyadicScale
        (2 * (rho.re - (1 / 2 : ℝ))) ≤ 1
      ↔
    rho.re ≤ (1 / 2 : ℝ) := by

  rw [← canonical_gainPlus_eq]
  rw [gainPlus_le_one_iff_centered_nonpos]
  rw [canonical_centered_eq]

  constructor <;> intro h <;> linarith

/--
The minus dyadic inequality is exactly 1/2 ≤ Re rho.
-/
theorem minus_literal_iff_half_le_re
    (rho : ℂ) :
    dyadicScale
        (-2 * (rho.re - (1 / 2 : ℝ))) ≤ 1
      ↔
    (1 / 2 : ℝ) ≤ rho.re := by

  rw [← canonical_gainMinus_eq]
  rw [gainMinus_le_one_iff_centered_nonneg]
  rw [canonical_centered_eq]

  constructor <;> intro h <;> linarith

def GlobalPlusDyadicContraction : Prop :=
  ∀ rho : ℂ,
    PhiZero phiEta rho →
      dyadicScale
        (2 * (rho.re - (1 / 2 : ℝ))) ≤ 1

def GlobalMinusDyadicContraction : Prop :=
  ∀ rho : ℂ,
    PhiZero phiEta rho →
      dyadicScale
        (-2 * (rho.re - (1 / 2 : ℝ))) ≤ 1

/--
By reflection symmetry, the PLUS contraction alone already implies RH.
-/
theorem GLOBAL_PLUS_DYADIC_CONTRACTION_IFF_MATHLIB_RH :
    GlobalPlusDyadicContraction ↔
      RiemannHypothesis := by

  constructor

  · intro hPlus

    apply CANONICAL_INTERNAL_RH_IFF_MATHLIB_RH.mp

    intro rho hz

    have hUpper :
        rho.re ≤ (1 / 2 : ℝ) :=
      (plus_literal_iff_re_le_half rho).1
        (hPlus rho hz)

    have hzRef :
        PhiZero phiEta (1 - rho) :=
      phiZero_one_sub rho hz

    have hRefUpper :
        (1 - rho).re ≤ (1 / 2 : ℝ) :=
      (plus_literal_iff_re_le_half (1 - rho)).1
        (hPlus (1 - rho) hzRef)

    have hLower :
        (1 / 2 : ℝ) ≤ rho.re := by
      have h :
          1 - rho.re ≤ (1 / 2 : ℝ) := by
        simpa using hRefUpper
      linarith

    change rho.re = (1 / 2 : ℝ)
    exact le_antisymm hUpper hLower

  · intro hRH

    have hInternal :
        canonicalModel.RH :=
      CANONICAL_INTERNAL_RH_IFF_MATHLIB_RH.mpr hRH

    intro rho hz

    have hre :
        rho.re = (1 / 2 : ℝ) :=
      hInternal rho hz

    exact
      (plus_literal_iff_re_le_half rho).2
        (le_of_eq hre)

/--
By the same reflection symmetry, the MINUS contraction alone already implies RH.
-/
theorem GLOBAL_MINUS_DYADIC_CONTRACTION_IFF_MATHLIB_RH :
    GlobalMinusDyadicContraction ↔
      RiemannHypothesis := by

  constructor

  · intro hMinus

    apply CANONICAL_INTERNAL_RH_IFF_MATHLIB_RH.mp

    intro rho hz

    have hLower :
        (1 / 2 : ℝ) ≤ rho.re :=
      (minus_literal_iff_half_le_re rho).1
        (hMinus rho hz)

    have hzRef :
        PhiZero phiEta (1 - rho) :=
      phiZero_one_sub rho hz

    have hRefLower :
        (1 / 2 : ℝ) ≤ (1 - rho).re :=
      (minus_literal_iff_half_le_re (1 - rho)).1
        (hMinus (1 - rho) hzRef)

    have hUpper :
        rho.re ≤ (1 / 2 : ℝ) := by
      have h :
          (1 / 2 : ℝ) ≤ 1 - rho.re := by
        simpa using hRefLower
      linarith

    change rho.re = (1 / 2 : ℝ)
    exact le_antisymm hUpper hLower

  · intro hRH

    have hInternal :
        canonicalModel.RH :=
      CANONICAL_INTERNAL_RH_IFF_MATHLIB_RH.mpr hRH

    intro rho hz

    have hre :
        rho.re = (1 / 2 : ℝ) :=
      hInternal rho hz

    exact
      (minus_literal_iff_half_le_re rho).2
        (le_of_eq hre.symm)

end AWPI.PhiRH.NativeRHOneSidedReflection