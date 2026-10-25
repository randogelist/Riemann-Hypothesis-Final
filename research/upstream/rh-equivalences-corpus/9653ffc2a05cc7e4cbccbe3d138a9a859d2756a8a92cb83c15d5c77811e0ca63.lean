import PositivityPremise.LiteralZeta
import PositivityPremise.Tail
import AngularMaster.ComplexScaleProduct
import AngularMaster.ZeroFreeSeed
import Mathlib
import Support.AuditPolicy

/-!
Source-only development. No Lean process was run while preparing this file.

The index keeps individual canonical zero occurrences. Every occurrence has
weight one; analytic multiplicity is retained by repeated occurrences, rather
than by grouping occurrences into a separate weighted support type.

This constructs the support binding needed by the RR equivalence. It does not
prove the all-height defect bound or native RH.
-/

set_option autoImplicit false
noncomputable section

open scoped ComplexConjugate
open OverflowResidueRH

namespace NativeRRBinding

abbrev UpperOccurrence :=
  {i : EntireXiPullbackZeroOccurrence //
    0 < (entireXiPullbackZeroOccurrenceLoc i).re}

def location (i : UpperOccurrence) : ℂ :=
  entireXiPullbackZeroOccurrenceLoc i.val

def rho (i : UpperOccurrence) : ℂ := (1 / 2 : ℂ) + Complex.I * location i
def gamma (i : UpperOccurrence) : ℝ := (location i).re
def delta (i : UpperOccurrence) : ℝ := -(location i).im

theorem gamma_positive (i : UpperOccurrence) : 0 < gamma i := i.property

theorem rho_im (i : UpperOccurrence) : (rho i).im = gamma i := by
  simp [rho, gamma, Complex.mul_im]

theorem rho_re_centered (i : UpperOccurrence) :
    (rho i).re - 1 / 2 = delta i := by
  change ((1 / 2 : ℂ) + Complex.I * location i).re - 1 / 2 = -(location i).im
  rw [critical_shift_re]
  ring

theorem location_is_zero (i : UpperOccurrence) : EntireXiPullback (location i) = 0 :=
  entireXiPullbackZeroOccurrenceLoc_is_zero i.val

theorem rho_xi_zero (i : UpperOccurrence) : AWPIRH.xi (rho i) = 0 := by
  rw [← AngularMaster.external_entireRiemannXi_eq_actual_xi]
  exact location_is_zero i

theorem rho_nontrivial (i : UpperOccurrence) :
    PositivityPremise.NontrivialZetaZero (rho i) := by
  have h := entireRiemannXi_eq_zero_iff_mathlib_nontrivial_zeta_zero.mp
    (show entireRiemannXi (rho i) = 0 from location_is_zero i)
  exact h

theorem gamma_gt_one (i : UpperOccurrence) : 1 < gamma i := by
  have h := AngularMaster.actual_xi_zero_one_lt_abs_im (rho_xi_zero i)
  rw [rho_im, abs_of_pos (gamma_positive i)] at h
  exact h

theorem gamma_sq_ge_one (i : UpperOccurrence) : 1 ≤ gamma i ^ 2 := by
  nlinarith [gamma_gt_one i, sq_nonneg (gamma i - 1)]

theorem delta_sq_le_quarter (i : UpperOccurrence) : delta i ^ 2 ≤ (1 / 4 : ℝ) := by
  have h := abs_lt.mp (entireXiPullback_zero_im_abs_lt_half (location_is_zero i))
  have hprod : 0 ≤ ((1 / 2 : ℝ) - (location i).im) *
      ((1 / 2 : ℝ) + (location i).im) :=
    mul_nonneg (by linarith [h.2]) (by linarith [h.1])
  dsimp [delta]
  nlinarith

theorem location_norm_sq (i : UpperOccurrence) :
    ‖location i‖ ^ 2 = gamma i ^ 2 + delta i ^ 2 := by
  rw [← Complex.normSq_eq_norm_sq, Complex.normSq_apply]
  dsimp [gamma, delta]
  ring

/-- Ordinary inverse-height mass is bounded by the already summable canonical
inverse-norm mass. The constant 5/4 uses only the strip and height > 1. -/
theorem height_mass_le_norm_mass (i : UpperOccurrence) :
    1 / gamma i ^ 2 ≤ (5 / 4 : ℝ) * (‖location i‖ ^ 2)⁻¹ := by
  have hg : 0 < gamma i ^ 2 := sq_pos_of_pos (gamma_positive i)
  have hnorm : 0 < ‖location i‖ ^ 2 := by
    rw [location_norm_sq]
    positivity
  have hg1 := gamma_sq_ge_one i
  rw [← div_eq_mul_inv]
  apply (div_le_div_iff₀ hg hnorm).2
  rw [location_norm_sq]
  nlinarith [delta_sq_le_quarter i]

theorem height_mass_summable : Summable (fun i : UpperOccurrence => 1 / gamma i ^ 2) := by
  have hnorm : Summable (fun i : UpperOccurrence => (‖location i‖ ^ 2)⁻¹) :=
    entireXiPullbackCanonicalZeroDistributionFromTheta.inv_sq_summable.subtype _
  exact Summable.of_nonneg_of_le
    (fun i => by positivity) height_mass_le_norm_mass (hnorm.mul_left (5 / 4 : ℝ))

theorem defect_le_height_mass (i : UpperOccurrence) :
    PositivityPremise.defect 1 (delta i) (gamma i) ≤ 1 / gamma i ^ 2 := by
  have hgd : delta i ^ 2 ≤ gamma i ^ 2 := by
    linarith [delta_sq_le_quarter i, gamma_sq_ge_one i]
  have htrace : 0 ≤ (1 : ℝ) * (gamma i ^ 2 - delta i ^ 2) /
      (gamma i ^ 2 + delta i ^ 2) ^ 2 :=
    div_nonneg (mul_nonneg zero_le_one (sub_nonneg.mpr hgd)) (sq_nonneg _)
  have hidentity := PositivityPremise.defect_identity
    (m := (1 : ℝ)) (delta := delta i) (gamma_positive i)
  linarith

theorem defect_summable :
    Summable (fun i : UpperOccurrence => PositivityPremise.defect 1 (delta i) (gamma i)) :=
  Summable.of_nonneg_of_le
    (fun i => PositivityPremise.defect_nonneg (by norm_num) (gamma_positive i))
    defect_le_height_mass height_mass_summable

def actualData : PositivityPremise.ZeroData UpperOccurrence where
  multiplicity := fun _ => 1
  delta := delta
  gamma := gamma
  multiplicity_pos := fun _ => Nat.zero_lt_one
  gamma_pos := gamma_positive
  strip := delta_sq_le_quarter
  summable_mass := by simpa using height_mass_summable
  summable_defect := by simpa using defect_summable

/-- Every positive-height nontrivial zeta zero is represented by a canonical
occurrence. The choice selects an occurrence; it is not a simplicity claim. -/
theorem upper_zero_represented {s : ℂ}
    (hs : PositivityPremise.NontrivialZetaZero s) (him : 0 < s.im) :
    ∃ i : UpperOccurrence, rho i = s := by
  let w : ℂ := -Complex.I * (s - (1 / 2 : ℂ))
  have hwre : w.re = s.im := by simp [w, Complex.mul_re]
  have hshift : (1 / 2 : ℂ) + Complex.I * w = s := by
    dsimp [w]
    calc
      _ = (1 / 2 : ℂ) - (Complex.I * Complex.I) * (s - 1 / 2) := by ring
      _ = s := by rw [Complex.I_mul_I]; ring
  have hwzero : EntireXiPullback w = 0 := by
    unfold EntireXiPullback
    rw [hshift]
    exact entireRiemannXi_eq_zero_iff_mathlib_nontrivial_zeta_zero.mpr hs
  have hwne : w ≠ 0 := by
    intro h
    have hreal := congrArg Complex.re h
    rw [hwre] at hreal
    simpa using (ne_of_gt him) hreal
  obtain ⟨j, hj⟩ := entireXiPullbackZeroOccurrenceLoc_exhaustive hwzero hwne
  have hjpos : 0 < (entireXiPullbackZeroOccurrenceLoc j).re := by
    rw [hj, hwre]
    exact him
  refine ⟨⟨j, hjpos⟩, ?_⟩
  change (1 / 2 : ℂ) + Complex.I * entireXiPullbackZeroOccurrenceLoc j = s
  rw [hj]
  exact hshift

theorem nontrivial_star {s : ℂ} (hs : PositivityPremise.NontrivialZetaZero s) :
    PositivityPremise.NontrivialZetaZero (star s) := by
  have hxi : AWPIRH.xi s = 0 := by
    rw [← AngularMaster.external_entireRiemannXi_eq_actual_xi]
    exact entireRiemannXi_eq_zero_iff_mathlib_nontrivial_zeta_zero.mpr hs
  have hstarxi : AWPIRH.xi (star s) = 0 := by
    simpa only [Complex.star_def, AngularMaster.actual_xi_conj, hxi, map_zero]
  rw [← AngularMaster.external_entireRiemannXi_eq_actual_xi] at hstarxi
  exact entireRiemannXi_eq_zero_iff_mathlib_nontrivial_zeta_zero.mp hstarxi

def actualBinding : PositivityPremise.ZetaBinding actualData where
  rho := rho
  sound := rho_nontrivial
  gamma_eq := fun i => (rho_im i).symm
  delta_eq := fun i => (rho_re_centered i).symm
  complete := by
    intro s hs
    by_cases him : 0 < s.im
    · obtain ⟨i, hi⟩ := upper_zero_represented hs him
      exact ⟨i, Or.inl hi.symm⟩
    · have hxi : AWPIRH.xi s = 0 := by
        rw [← AngularMaster.external_entireRiemannXi_eq_actual_xi]
        exact entireRiemannXi_eq_zero_iff_mathlib_nontrivial_zeta_zero.mpr hs
      have hheight := AngularMaster.actual_xi_zero_one_lt_abs_im hxi
      have hneg : s.im < 0 := by
        rw [abs_of_nonpos (le_of_not_gt him)] at hheight
        linarith
      have hstarpos : 0 < (star s).im := by
        simpa only [Complex.star_def, Complex.conj_im] using neg_pos.mpr hneg
      obtain ⟨i, hi⟩ := upper_zero_represented (nontrivial_star hs) hstarpos
      refine ⟨i, Or.inr ?_⟩
      rw [hi]
      simp

theorem actual_binding_exists :
    ∃ D : PositivityPremise.ZeroData UpperOccurrence,
      Nonempty (PositivityPremise.ZetaBinding D) :=
  ⟨actualData, ⟨actualBinding⟩⟩

/-- Fully bound actual defect, with no hypothetical enumeration argument. -/
theorem actual_defect_zero_iff_nativeRH : actualData.C = 0 ↔ _root_.RiemannHypothesis :=
  actualData.C_eq_zero_iff_onLine.trans actualBinding.onLine_iff_riemannHypothesis

theorem actual_all_height_bound_iff_nativeRH :
    PositivityPremise.PositivityPremise actualData.C actualData.c1 ↔
      _root_.RiemannHypothesis :=
  PositivityPremise.POSITIVITY_PREMISE_IFF_RH actualBinding

end NativeRRBinding

namespace NativeRRPrefix

variable {ι : Type*} (D : PositivityPremise.ZeroData ι)

theorem prefix_le_total (T : ℝ) : D.prefix T ≤ D.C := by
  rw [D.C_eq_prefix_add_tail T]
  exact le_add_of_nonneg_right (D.tail_nonneg T)

theorem prefix_approximation {T : ℝ} (hT : 0 < T) :
    0 ≤ D.C - D.prefix T ∧
      D.C - D.prefix T ≤ 3 * D.c1 / (4 * T ^ 2) := by
  have hsplit := D.C_eq_prefix_add_tail T
  have htail := D.tail_upper_bound hT
  have hnonneg := D.tail_nonneg T
  constructor <;> linarith

theorem contribution_le_prefix (i : ι) {T : ℝ} (hi : D.gamma i ≤ T) :
    D.contribution i ≤ D.prefix T := by
  classical
  have h := (D.summable_prefix T).le_tsum i
    (fun j _ => Set.indicator_nonneg (fun k _ => D.contribution_nonneg k) j)
  have hi_mem : i ∈ ({j | D.gamma j ≤ T} : Set ι) := hi
  rw [Set.indicator_of_mem hi_mem] at h
  exact h

theorem prefix_zero_iff_verified (T : ℝ) :
    D.prefix T = 0 ↔ ∀ i, D.gamma i ≤ T → D.delta i = 0 := by
  classical
  constructor
  · intro hzero i hi
    apply (PositivityPremise.defect_eq_zero_iff
      (D.multiplicity_real_pos i) (D.gamma_pos i)).mp
    apply le_antisymm
    · have h := contribution_le_prefix D i hi
      rw [hzero] at h
      exact h
    · exact D.contribution_nonneg i
  · intro h
    have hz : ∀ i : ι,
        ({j | D.gamma j ≤ T} : Set ι).indicator D.contribution i = 0 := by
      intro i
      by_cases hi : i ∈ ({j | D.gamma j ≤ T} : Set ι)
      · rw [Set.indicator_of_mem hi]
        exact (PositivityPremise.defect_eq_zero_iff
          (D.multiplicity_real_pos i) (D.gamma_pos i)).mpr (h i hi)
      · exact Set.indicator_of_notMem hi _
    unfold PositivityPremise.ZeroData.prefix
    simp only [hz, tsum_zero]

/-- Any single off-line occurrence rules out the desired all-height bound at
some finite cutoff, even though the tail estimate remains valid there. -/
theorem exists_height_full_bound_fails (i : ι) (hi : D.delta i ≠ 0) :
    ∃ T : ℝ, 1 ≤ T ∧ 3 * D.c1 / (4 * T ^ 2) < D.C := by
  by_contra h
  push_neg at h
  have hbound : PositivityPremise.PositivityPremise D.C D.c1 := by
    intro T hT
    exact ⟨D.C_nonneg, h T hT⟩
  exact hi ((D.positivityPremise_iff_onLine.mp hbound) i)

end NativeRRPrefix

run_cmd LeanCandidateAudit.auditAxioms "N03_BINDING_HEIGHT_MASS" ``NativeRRBinding.height_mass_summable
run_cmd LeanCandidateAudit.auditAxioms "N03_BINDING_DEFECT_SUMMABLE" ``NativeRRBinding.defect_summable
run_cmd LeanCandidateAudit.auditAxioms "N03_BINDING_ACTUAL_SUPPORT" ``NativeRRBinding.actual_binding_exists
run_cmd LeanCandidateAudit.auditAxioms "N03_BINDING_NATIVE_EQUIVALENCE" ``NativeRRBinding.actual_defect_zero_iff_nativeRH
run_cmd LeanCandidateAudit.auditAxioms "N03_BINDING_PREFIX_VERIFICATION" ``NativeRRPrefix.prefix_zero_iff_verified
run_cmd LeanCandidateAudit.auditAxioms "N03_BINDING_FULL_BOUND_OBSTRUCTION" ``NativeRRPrefix.exists_height_full_bound_fails
