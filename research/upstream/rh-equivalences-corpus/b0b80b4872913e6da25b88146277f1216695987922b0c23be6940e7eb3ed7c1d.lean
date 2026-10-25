import AWPI.PhiRH.NativePassivityCore

namespace AWPI.PhiRH.NativeRHExactWaist

open AWPI.PhiRH
open AWPI.PhiRH.Model
open AWPI.PhiRH.MathlibBridge
open AWPI.PhiRH.NativePhiZeroBridge
open AWPI.PhiRH.NativeS1Exact
open AWPI.PhiRH.NativeEtaPhi
open AWPI.PhiRH.NativePassivityCore

/--
Every internal Phi-zero is a genuine nontrivial Mathlib zeta zero.
This uses the independently derived literal S1 factorization and the
kernel-derived nonvanishing of the literal S1 prefactor.
-/
theorem phiZero_to_nontrivialZetaZero
    (rho : ℂ)
    (hPhi : PhiZero phiEta rho) :
    NontrivialZetaZero rho := by

  have hstrip :
      InCriticalStrip rho :=
    hPhi.1

  have hne1 :
      rho ≠ (1 : ℂ) := by
    intro h
    subst rho
    norm_num [InCriticalStrip] at hstrip

  have hfactor :
      phiEta rho =
        literalS1Prefactor rho *
          riemannZeta rho :=
    phiEta_eq_literalS1_mul_zeta
      rho hne1

  have hpref :
      literalS1Prefactor rho ≠ 0 :=
    literalS1Prefactor_ne_zero
      rho hstrip

  have hprod :
      literalS1Prefactor rho *
          riemannZeta rho = 0 := by
    rw [← hfactor]
    exact hPhi.2

  have hzeta :
      riemannZeta rho = 0 :=
    (mul_eq_zero.mp hprod).resolve_left hpref

  have htrivial :
      ¬ ∃ n : ℕ,
        rho = -2 * ((n : ℂ) + 1) := by

    rintro ⟨n, hn⟩

    have hre :=
      congrArg Complex.re hn

    have hn0 :
        (0 : ℝ) ≤ (n : ℝ) := by
      positivity

    simp at hre

    linarith [hstrip.1]

  exact
    ⟨hzeta, htrivial, hne1⟩

/--
Mathlib RH implies the internal canonical-model RH predicate.
-/
theorem mathlibRH_implies_canonicalInternalRH
    (hRH : RiemannHypothesis) :
    canonicalModel.RH := by

  intro rho hPhi

  have hz :
      NontrivialZetaZero rho :=
    phiZero_to_nontrivialZetaZero
      rho hPhi

  change rho.re = (1 / 2 : ℝ)

  exact
    hRH rho
      hz.1
      hz.2.1
      hz.2.2

/--
Internal canonical-model RH implies Mathlib's native RH.
-/
theorem canonicalInternalRH_implies_mathlibRH
    (hInternal : canonicalModel.RH) :
    RiemannHypothesis := by

  intro rho hz htrivial hne1

  have hzNT :
      NontrivialZetaZero rho :=
    ⟨hz, htrivial, hne1⟩

  have hPhi :
      PhiZero phiEta rho :=
    zetaZero_to_phiZero_of_literalS1
      phiEta
      phiEta_literalS1ValueIdentity
      rho
      hzNT

  have hcrit :=
    hInternal rho hPhi

  change rho.re = (1 / 2 : ℝ) at hcrit

  exact hcrit

/--
The internal canonical-model RH predicate is exactly Mathlib RH.
-/
theorem CANONICAL_INTERNAL_RH_IFF_MATHLIB_RH :
    canonicalModel.RH ↔
      RiemannHypothesis := by

  constructor

  · exact
      canonicalInternalRH_implies_mathlibRH

  · exact
      mathlibRH_implies_canonicalInternalRH

/--
Final logical waist:

    exact two-sided passivity
      ↔ Mathlib RiemannHypothesis.

There are no project axioms or hidden source assumptions in this theorem.
-/
theorem EXACT_TWO_SIDED_PASSIVITY_IFF_MATHLIB_RH :
    ExactTwoSidedPassivity canonicalModel ↔
      RiemannHypothesis := by

  exact
    CANONICAL_PASSIVITY_IFF_INTERNAL_RH.trans
      CANONICAL_INTERNAL_RH_IFF_MATHLIB_RH

/--
Expanded form of the exact two defect-sign condition.
-/
def CanonicalTwoDefectSigns : Prop :=
  ∀ rho : ℂ,
    PhiZero phiEta rho →
      canonicalModel.exactPlusDefect rho ≤ 0 ∧
      canonicalModel.exactMinusDefect rho ≤ 0

theorem canonicalTwoDefectSigns_iff_passivity :
    CanonicalTwoDefectSigns ↔
      ExactTwoSidedPassivity canonicalModel := by

  rfl

theorem CANONICAL_TWO_DEFECT_SIGNS_IFF_MATHLIB_RH :
    CanonicalTwoDefectSigns ↔
      RiemannHypothesis := by

  exact
    canonicalTwoDefectSigns_iff_passivity.trans
      EXACT_TWO_SIDED_PASSIVITY_IFF_MATHLIB_RH

end AWPI.PhiRH.NativeRHExactWaist