import FiniteWitness.ComplexCalibration

/-!
# SOLOBOLO cofinal coefficient calibration

A cofinal subsequence of finite positive spectra is sufficient for
coefficient-level consequences. Crucially, we compare *complex* actual xi
Taylor jets, and the same generated spectrum is used for all j at each N.

All theorem conclusions in this file are elementary consequences of the
EXPLICIT calibration hypothesis. This module does not prove that hypothesis.
-/

noncomputable section

namespace WitnessSolobolo

/-- For arbitrarily large levels, *one* finite spectral layer matches all
complex actual-xi Taylor coefficients in its finite prefix. -/
def CofinalComplexCalibration (w : FiniteWitness) : Prop :=
  ∀ K : ℕ, ∃ N : ℕ, K ≤ N ∧
    ∀ j : ℕ, j ≤ N →
      (Nat.factorial j : ℝ) *
        ‖(elementary w N j : ℂ) - actualComplexCoefficient j‖ ≤
          (1 / 2 : ℝ) ^ N

/-- The cofinal counterpart of the full-depth layer predicate. -/
def CofinalComplexLayer (w : FiniteWitness) : Prop :=
  AllLevelContractive w ∧ CofinalComplexCalibration w

/-- Full-depth calibration is stronger than cofinal calibration. -/
theorem allDepthComplexCalibration_implies_cofinal
    (w : FiniteWitness) (h : AllDepthComplexCalibration w) :
    CofinalComplexCalibration w := by
  intro K
  exact ⟨K, le_rfl, fun j hj => h K j hj⟩

private theorem half_pow_antitone {m n : ℕ} (hmn : m ≤ n) :
    (1 / 2 : ℝ) ^ n ≤ (1 / 2 : ℝ) ^ m := by
  have heq : n = m + (n - m) := by omega
  rw [heq, pow_add]
  have hn : 0 ≤ (1 / 2 : ℝ) ^ m := pow_nonneg (by norm_num) _
  have hk : (1 / 2 : ℝ) ^ (n - m) ≤ 1 :=
    pow_le_one₀ (by norm_num) (by norm_num)
  calc
    (1 / 2 : ℝ) ^ m * (1 / 2 : ℝ) ^ (n - m) ≤
        (1 / 2 : ℝ) ^ m * 1 := mul_le_mul_of_nonneg_left hk hn
    _ = (1 / 2 : ℝ) ^ m := mul_one _

private theorem norm_le_factorial_norm (j : ℕ) (z : ℂ) :
    ‖z‖ ≤ (Nat.factorial j : ℝ) * ‖z‖ := by
  have hpos : 0 < Nat.factorial j := Nat.factorial_pos j
  have hnat : 1 ≤ Nat.factorial j := by omega
  have hf : (1 : ℝ) ≤ (Nat.factorial j : ℝ) := by exact_mod_cast hnat
  have hz : 0 ≤ ‖z‖ := norm_nonneg _
  nlinarith

/-- Cofinal full-complex calibration forces every actual Taylor coefficient
at the chosen positive anchor to be real. -/
theorem cofinalCalibration_actual_im_eq_zero
    (w : FiniteWitness) (h : CofinalComplexCalibration w) (j : ℕ) :
    (actualComplexCoefficient j).im = 0 := by
  by_contra hne
  have hp : 0 < |(actualComplexCoefficient j).im| := abs_pos.mpr hne
  obtain ⟨M, hM⟩ := exists_pow_lt_of_lt_one hp (by norm_num : (1 / 2 : ℝ) < 1)
  obtain ⟨N, hN, hc⟩ := h (max j M)
  have hj : j ≤ N := (le_max_left j M).trans hN
  have hMN : M ≤ N := (le_max_right j M).trans hN
  let z : ℂ := (elementary w N j : ℂ) - actualComplexCoefficient j
  have hi : |(actualComplexCoefficient j).im| ≤ ‖z‖ := by
    simpa [z] using (Complex.abs_im_le_norm z)
  have hnorm : ‖z‖ ≤ (1 / 2 : ℝ) ^ N := by
    calc
      ‖z‖ ≤ (Nat.factorial j : ℝ) * ‖z‖ := norm_le_factorial_norm j z
      _ ≤ (1 / 2 : ℝ) ^ N := hc j hj
  have hbound : |(actualComplexCoefficient j).im| ≤ (1 / 2 : ℝ) ^ M :=
    (hi.trans hnorm).trans (half_pow_antitone hMN)
  exact (not_lt_of_ge hbound) hM

/-- Cofinal calibration by nonnegative finite spectra forces nonnegative
real parts of the actual Taylor coefficients. This is a necessary condition,
not by itself an RH criterion. -/
theorem cofinalCalibration_actual_re_nonneg
    (w : FiniteWitness) (hMass : AllLevelContractive w)
    (h : CofinalComplexCalibration w) (j : ℕ) :
    0 ≤ actualCoefficient j := by
  apply nonneg_of_arbitrary_positive_approx
  intro ε hε
  obtain ⟨M, hM⟩ := exists_pow_lt_of_lt_one hε (by norm_num : (1 / 2 : ℝ) < 1)
  obtain ⟨N, hN, hc⟩ := h (max j M)
  have hj : j ≤ N := (le_max_left j M).trans hN
  have hMN : M ≤ N := (le_max_right j M).trans hN
  have hnonneg : 0 ≤ elementary w N j := by
    apply elementary_nonneg
    intro i
    exact ((hMass N).1 i).1
  have hreal : 0 ≤ (elementary w N j : ℝ) := by exact_mod_cast hnonneg
  let z : ℂ := (elementary w N j : ℂ) - actualComplexCoefficient j
  have hre : |(elementary w N j : ℝ) - actualCoefficient j| ≤ ‖z‖ := by
    simpa [z, actualCoefficient] using (Complex.abs_re_le_norm z)
  have hnorm : ‖z‖ ≤ (1 / 2 : ℝ) ^ N := by
    calc
      ‖z‖ ≤ (Nat.factorial j : ℝ) * ‖z‖ := norm_le_factorial_norm j z
      _ ≤ (1 / 2 : ℝ) ^ N := hc j hj
  refine ⟨(elementary w N j : ℝ), hreal, ?_⟩
  exact (hre.trans hnorm).trans ((half_pow_antitone hMN).trans hM.le)

/-- What is ALREADY obtained from a cofinal calibrated positive spectrum,
without using Hurwitz, pole geometry, or RH. -/
theorem cofinalComplexLayer_actual_coefficient_consequences
    (w : FiniteWitness) (h : CofinalComplexLayer w) (j : ℕ) :
    (actualComplexCoefficient j).im = 0 ∧ 0 ≤ actualCoefficient j := by
  exact ⟨cofinalCalibration_actual_im_eq_zero w h.2 j,
    cofinalCalibration_actual_re_nonneg w h.1 h.2 j⟩

end WitnessSolobolo
