import Develop.NativeMellinBridge
import Support.AuditPolicy

/-!
D153: consequences of the accepted D152 Mellin bridge and exact finite-row
estimates. This is development scaffolding, not an unconditional RH theorem.
No Lean/checker/Windows runner was executed while preparing this source.
-/

set_option autoImplicit false
set_option maxHeartbeats 400000
noncomputable section
open scoped BigOperators Topology
open Filter

namespace NativeEnergyBridge

theorem nativeXi_anchorGerm : AWPIRH.NativeXiAnchorGerm :=
  AWPIRH.NATIVE_XI_ANCHOR_GERM_OF_MELLIN_GERM
    AWPIRH.NATIVE_MELLIN_ANCHOR_GERM

/-- Actual xi-Widder coefficients, with the original normalization unchanged. -/
def xiCoefficients (n : ℕ) : ℂ := (AWPIRH.xiWidder n 0 : ℂ)

theorem nativeCoefficients_eq_xiCoefficients :
    AWPIRH.nativeCoefficients = xiCoefficients := by
  funext n
  exact AWPIRH.nativeCoefficient_eq_xiWidder nativeXi_anchorGerm n

theorem native_bernsteinCell_eq (N j : ℕ) :
    AWPIRH.bernsteinCell AWPIRH.nativeCoefficients N j =
      AWPIRH.bernsteinCell xiCoefficients N j := by
  rw [nativeCoefficients_eq_xiCoefficients]

theorem native_rowPolynomial_eq (N : ℕ) (eta : ℂ) :
    AWPIRH.rowPolynomial AWPIRH.nativeCoefficients N eta =
      AWPIRH.rowPolynomial xiCoefficients N eta := by
  rw [nativeCoefficients_eq_xiCoefficients]

theorem native_bernsteinEnergy_eq (N : ℕ) :
    AWPIRH.bernsteinEnergy AWPIRH.nativeCoefficients N =
      AWPIRH.bernsteinEnergy xiCoefficients N := by
  rw [nativeCoefficients_eq_xiCoefficients]

theorem native_energy_iff_xi_energy :
    AWPIRH.US_AWPI ↔ AWPIRH.SubexponentialEnergy xiCoefficients := by
  unfold AWPIRH.US_AWPI
  rw [nativeCoefficients_eq_xiCoefficients]

theorem native_product_identity_iff_xi_product_identity :
    AWPIRH.NativeProductCoefficientIdentity ↔
      AWPIRH.XiWidderProductCoefficientIdentity := by
  unfold AWPIRH.NativeProductCoefficientIdentity
    AWPIRH.XiWidderProductCoefficientIdentity
  rw [nativeCoefficients_eq_xiCoefficients]
  rfl

/-- Both remaining research inputs are explicit. This is not a native candidate. -/
theorem nativeRH_of_xi_energy_and_product
    (hEnergy : AWPIRH.SubexponentialEnergy xiCoefficients)
    (hProduct : AWPIRH.XiWidderProductCoefficientIdentity) :
    _root_.RiemannHypothesis := by
  exact AWPIRH.MATHLIB_RH_OF_US_MELLIN_GERM_AND_PRODUCT_GERM
    (native_energy_iff_xi_energy.mpr hEnergy)
    AWPIRH.NATIVE_MELLIN_ANCHOR_GERM hProduct

end NativeEnergyBridge


namespace NativeEnergyBridge

open AWPIRH

def rowVariation (c : ℕ → ℂ) (N : ℕ) : ℝ :=
  ∑ j ∈ Finset.range (N + 1), ‖bernsteinCell c N j‖

theorem rowVariation_nonneg (c : ℕ → ℂ) (N : ℕ) :
    0 ≤ rowVariation c N :=
  Finset.sum_nonneg (fun j _ => norm_nonneg _)

theorem rowVariation_sq_le_energy (c : ℕ → ℂ) (N : ℕ) :
    rowVariation c N ^ 2 ≤ bernsteinEnergy c N := by
  simpa [rowVariation, bernsteinEnergy] using
    finite_sum_sq_bound (Finset.range (N + 1))
      (fun j => ‖bernsteinCell c N j‖)

theorem energy_le_card_mul_rowVariation_sq (c : ℕ → ℂ) (N : ℕ) :
    bernsteinEnergy c N ≤ ((N : ℝ) + 1) * rowVariation c N ^ 2 := by
  have hsq : (∑ j ∈ Finset.range (N + 1), ‖bernsteinCell c N j‖ ^ 2) ≤
      rowVariation c N ^ 2 := by
    calc
      _ ≤ ∑ j ∈ Finset.range (N + 1),
          ‖bernsteinCell c N j‖ * rowVariation c N := by
        apply Finset.sum_le_sum
        intro j hj
        have hjle : ‖bernsteinCell c N j‖ ≤ rowVariation c N :=
          Finset.single_le_sum (fun k _ => norm_nonneg _) hj
        simpa only [pow_two] using
          mul_le_mul_of_nonneg_left hjle (norm_nonneg (bernsteinCell c N j))
      _ = rowVariation c N ^ 2 := by
        rw [← Finset.sum_mul]
        change rowVariation c N * rowVariation c N = rowVariation c N ^ 2
        ring
  exact mul_le_mul_of_nonneg_left hsq (by positivity)

theorem energy_le_of_rowVariation_le {c : ℕ → ℂ} {N : ℕ} {M : ℝ}
    (hM : rowVariation c N ≤ M) :
    bernsteinEnergy c N ≤ ((N : ℝ) + 1) * M ^ 2 := by
  have hs : rowVariation c N ^ 2 ≤ M ^ 2 := by
    have hf : 0 ≤ (M - rowVariation c N) * (M + rowVariation c N) :=
      mul_nonneg (sub_nonneg.mpr hM) (by linarith [rowVariation_nonneg c N])
    nlinarith [hf]
  exact (energy_le_card_mul_rowVariation_sq c N).trans
    (mul_le_mul_of_nonneg_left hs (by positivity))

theorem rowVariation_eventually_le_exp {c : ℕ → ℂ}
    (hUS : SubexponentialEnergy c) {δ : ℝ} (hδ : 0 < δ) :
    ∀ᶠ N : ℕ in atTop, rowVariation c N ≤ Real.exp (δ * (N : ℝ)) := by
  have he := energy_eventually_le_exp hUS (show 0 < 2 * δ by positivity)
  filter_upwards [he] with N hN
  have hs := rowVariation_sq_le_energy c N
  have hexp : Real.exp (2 * δ * (N : ℝ)) =
      Real.exp (δ * (N : ℝ)) ^ 2 := by
    rw [pow_two, ← Real.exp_add]
    congr 1
    ring
  rw [hexp] at hN
  nlinarith [Real.exp_pos (δ * (N : ℝ)), rowVariation_nonneg c N]

/-- A real presentation of the same signed Bernstein cells. -/
def realCell (c : ℕ → ℝ) (N j : ℕ) : ℝ :=
  (N.choose j : ℝ) *
    ∑ k ∈ Finset.range (N - j + 1),
      (-1 : ℝ) ^ k * ((N - j).choose k : ℝ) * c (j + k)

theorem bernsteinCell_ofReal (c : ℕ → ℝ) (N j : ℕ) :
    bernsteinCell (fun n => (c n : ℂ)) N j = (realCell c N j : ℂ) := by
  unfold bernsteinCell realCell
  push_cast <;> simp only [Complex.ofReal_natCast, Complex.ofReal_one]

theorem abs_eq_self_add_twice_negative (x : ℝ) :
    |x| = x + 2 * max (-x) 0 := by
  by_cases hx : 0 ≤ x
  · rw [abs_of_nonneg hx, max_eq_right (by linarith : -x ≤ 0)]
    ring
  · have hx' : x ≤ 0 := le_of_not_ge hx
    rw [abs_of_nonpos hx', max_eq_left (by linarith : 0 ≤ -x)]
    ring

/-- The exact missing cancellation quantity: total negative cell mass. -/
theorem rowVariation_eq_signed_mass (c : ℕ → ℝ) (N : ℕ) :
    rowVariation (fun n => (c n : ℂ)) N =
      c 0 + 2 * ∑ j ∈ Finset.range (N + 1), max (-realCell c N j) 0 := by
  have hsumc : (∑ j ∈ Finset.range (N + 1), (realCell c N j : ℂ)) = (c 0 : ℂ) := by
    calc
      _ = ∑ j ∈ Finset.range (N + 1),
          bernsteinCell (fun n => (c n : ℂ)) N j := by
        apply Finset.sum_congr rfl
        intro j hj
        exact (bernsteinCell_ofReal c N j).symm
      _ = _ := sum_bernsteinCell (fun n => (c n : ℂ)) N
  have hsum : (∑ j ∈ Finset.range (N + 1), realCell c N j) = c 0 := by
    simpa using congrArg Complex.re hsumc
  unfold rowVariation
  calc
    _ = ∑ j ∈ Finset.range (N + 1),
        (realCell c N j + 2 * max (-realCell c N j) 0) := by
      apply Finset.sum_congr rfl
      intro j hj
      rw [bernsteinCell_ofReal, Complex.norm_real, Real.norm_eq_abs]
      exact abs_eq_self_add_twice_negative _
    _ = (∑ j ∈ Finset.range (N + 1), realCell c N j) +
        2 * ∑ j ∈ Finset.range (N + 1), max (-realCell c N j) 0 := by
      rw [Finset.sum_add_distrib, ← Finset.mul_sum]
    _ = _ := by rw [hsum]

def nativeNegativeMass (N : ℕ) : ℝ :=
  ∑ j ∈ Finset.range (N + 1), max (-realCell (fun n => nativeWidder n 0) N j) 0

theorem native_rowVariation_eq_negative_mass (N : ℕ) :
    rowVariation nativeCoefficients N = nativeWidder 0 0 + 2 * nativeNegativeMass N := by
  exact rowVariation_eq_signed_mass (fun n => nativeWidder n 0) N

theorem native_energy_le_negative_mass (N : ℕ) :
    bernsteinEnergy nativeCoefficients N ≤
      ((N : ℝ) + 1) * (nativeWidder 0 0 + 2 * nativeNegativeMass N) ^ 2 := by
  rw [← native_rowVariation_eq_negative_mass]
  exact energy_le_card_mul_rowVariation_sq nativeCoefficients N

theorem native_energy_sandwich (N : ℕ) :
    (nativeWidder 0 0 + 2 * nativeNegativeMass N) ^ 2 ≤
        bernsteinEnergy nativeCoefficients N ∧
      bernsteinEnergy nativeCoefficients N ≤
        ((N : ℝ) + 1) * (nativeWidder 0 0 + 2 * nativeNegativeMass N) ^ 2 := by
  constructor
  · rw [← native_rowVariation_eq_negative_mass]
    exact rowVariation_sq_le_energy nativeCoefficients N
  · exact native_energy_le_negative_mass N

/-- Exact control for a geometric input sequence, without a positivity premise. -/
theorem geometric_row (q η : ℂ) (N : ℕ) :
    rowPolynomial (fun n => q ^ n) N η = (1 + q * (η - 1)) ^ N := by
  rw [rowPolynomial_eq_binomial]
  calc
    _ = ∑ k ∈ Finset.range (N + 1),
        (q * (η - 1)) ^ k * (1 : ℂ) ^ (N - k) * (N.choose k : ℂ) := by
      apply Finset.sum_congr rfl
      intro k hk
      simp only [mul_pow, one_pow, mul_one]
      ring
    _ = (q * (η - 1) + 1) ^ N := (add_pow _ _ _).symm
    _ = (1 + q * (η - 1)) ^ N := by rw [add_comm]

/-- A bounded coefficient sequence can still have exponentially large energies. -/
theorem alternating_energy_lower (N : ℕ) :
    (9 : ℝ) ^ N ≤ bernsteinEnergy (fun n => (-1 : ℂ) ^ n) N := by
  have h := row_norm_sq_le_energy (fun n => (-1 : ℂ) ^ n) N
    (η := (-1 : ℂ)) (by norm_num)
  rw [geometric_row] at h
  have hrow : (1 : ℂ) + (-1) * ((-1) - 1) = 3 := by norm_num
  rw [hrow, norm_pow] at h
  have hnorm : ‖(3 : ℂ)‖ = (3 : ℝ) := by norm_num
  rw [hnorm] at h
  have hpow : ((3 : ℝ) ^ N) ^ 2 = (9 : ℝ) ^ N := by
    rw [← pow_mul, Nat.mul_comm, pow_mul]
    norm_num
  rw [hpow] at h
  exact h

theorem bernsteinCell_neg (c : ℕ → ℂ) (N j : ℕ) :
    bernsteinCell (fun n => -c n) N j = -bernsteinCell c N j := by
  simp [bernsteinCell, mul_neg, Finset.sum_neg_distrib]

theorem bernsteinEnergy_neg (c : ℕ → ℂ) (N : ℕ) :
    bernsteinEnergy (fun n => -c n) N = bernsteinEnergy c N := by
  simp only [bernsteinEnergy, bernsteinCell_neg, norm_neg]

/-- These are the Taylor coefficients of -P'/P for the entire P(r)=1+r. -/
theorem linear_product_control_energy_lower (N : ℕ) :
    (9 : ℝ) ^ N ≤ bernsteinEnergy (fun n => -((-1 : ℂ) ^ n)) N := by
  rw [bernsteinEnergy_neg]
  exact alternating_energy_lower N

end NativeEnergyBridge

namespace NativeEnergyBridge

private theorem log_succ_div_nat_tendsto_zero :
    Tendsto (fun N : ℕ => Real.log ((N : ℝ) + 1) / (N : ℝ))
      atTop (𝓝 0) := by
  have hreal : Tendsto (fun x : ℝ => Real.log x / (x - 1))
      atTop (𝓝 0) := by
    simpa [sub_eq_add_neg] using Real.tendsto_pow_log_div_mul_add_atTop
      (1 : ℝ) (-1 : ℝ) 1 (by norm_num : (1 : ℝ) ≠ 0)
  have hnat : Tendsto (fun N : ℕ => (N : ℝ) + 1) atTop atTop :=
    tendsto_atTop_mono (fun N => by linarith)
      (tendsto_natCast_atTop_atTop : Tendsto (fun N : ℕ => (N : ℝ)) atTop atTop)
  simpa only [Function.comp_def, add_sub_cancel_right] using hreal.comp hnat

/-- Quadratically comparable nonnegative sequences have the same
subexponential growth when the comparison loss is only N+1. -/
theorem energy_limit_iff_variation_limit
    (E L : ℕ → ℝ)
    (hL : ∀ N, 0 ≤ L N)
    (hlower : ∀ N, (L N) ^ 2 ≤ E N)
    (hupper : ∀ N, E N ≤ ((N : ℝ) + 1) * (L N) ^ 2) :
    Tendsto (fun N : ℕ => Real.log (1 + E N) / (N : ℝ)) atTop (𝓝 0) ↔
      Tendsto (fun N : ℕ => Real.log (1 + L N) / (N : ℝ)) atTop (𝓝 0) := by
  have hE : ∀ N, 0 ≤ E N := fun N => le_trans (sq_nonneg _) (hlower N)
  have hposE : ∀ N, 0 < 1 + E N := fun N => by linarith [hE N]
  have hposL : ∀ N, 0 < 1 + L N := fun N => by linarith [hL N]
  have hlogE : ∀ N, 0 ≤ Real.log (1 + E N) :=
    fun N => Real.log_nonneg (by linarith [hE N])
  have hlogL : ∀ N, 0 ≤ Real.log (1 + L N) :=
    fun N => Real.log_nonneg (by linarith [hL N])
  constructor
  · intro hlimE
    have hconst : Tendsto (fun N : ℕ => Real.log 2 / (N : ℝ)) atTop (𝓝 0) :=
      tendsto_const_nhds.div_atTop
        (tendsto_natCast_atTop_atTop : Tendsto (fun N : ℕ => (N : ℝ)) atTop atTop)
    have hbound : ∀ N, Real.log (1 + L N) ≤ Real.log 2 + Real.log (1 + E N) := by
      intro N
      have hraw : 1 + L N ≤ 2 * (1 + E N) := by
        nlinarith [hlower N, sq_nonneg (L N - 1 / 4)]
      have hlog := Real.log_le_log (hposL N) hraw
      rw [Real.log_mul (by norm_num : (2 : ℝ) ≠ 0) (hposE N).ne'] at hlog
      exact hlog
    apply squeeze_zero (fun N => div_nonneg (hlogL N) (Nat.cast_nonneg N))
      (g := fun N : ℕ => Real.log 2 / (N : ℝ) + Real.log (1 + E N) / (N : ℝ))
    · intro N
      simpa only [add_div] using
        (div_le_div_of_nonneg_right (hbound N) (Nat.cast_nonneg N))
    · simpa only [zero_add] using hconst.add hlimE
  · intro hlimL
    have hbound : ∀ N, Real.log (1 + E N) ≤
        Real.log ((N : ℝ) + 1) + 2 * Real.log (1 + L N) := by
      intro N
      have hN : (0 : ℝ) ≤ (N : ℝ) := Nat.cast_nonneg N
      have hNp : (0 : ℝ) < (N : ℝ) + 1 := by positivity
      have hfirst : 1 + E N ≤ ((N : ℝ) + 1) * (1 + (L N) ^ 2) := by
        nlinarith [hupper N]
      have hsecond : 1 + (L N) ^ 2 ≤ (1 + L N) ^ 2 := by
        nlinarith [hL N]
      have hraw : 1 + E N ≤ ((N : ℝ) + 1) * (1 + L N) ^ 2 :=
        hfirst.trans (mul_le_mul_of_nonneg_left hsecond hNp.le)
      have hlog := Real.log_le_log (hposE N) hraw
      rw [Real.log_mul hNp.ne' (pow_ne_zero 2 (hposL N).ne'), Real.log_pow] at hlog
      norm_num only [Nat.cast_ofNat] at hlog
      exact hlog
    apply squeeze_zero (fun N => div_nonneg (hlogE N) (Nat.cast_nonneg N))
      (g := fun N : ℕ => Real.log ((N : ℝ) + 1) / (N : ℝ) +
        2 * (Real.log (1 + L N) / (N : ℝ)))
    · intro N
      have hdiv := div_le_div_of_nonneg_right (hbound N) (Nat.cast_nonneg N)
      simpa only [add_div, mul_div_assoc] using hdiv
    · simpa only [mul_zero, zero_add] using
        log_succ_div_nat_tendsto_zero.add (hlimL.const_mul (2 : ℝ))

end NativeEnergyBridge

namespace NativeEnergyBridge

open AWPIRH

def reciprocalPairParameter (p q : ℂ) : ℂ := (2 - p - q) / 4

/-- The existing symmetric product evaluated on any reciprocal pair. -/
theorem symmetricProduct_reciprocal_pair (p q : ℂ) (hpq : p * q = 1) :
    symmetricProduct (reciprocalPairParameter p q) =
      theta p * theta q / theta 1 ^ 2 := by
  have hroot : ((p - q) / 2) ^ 2 =
      rootDiscriminant (reciprocalPairParameter p q) := by
    unfold rootDiscriminant reciprocalPairParameter
    linear_combination -hpq
  have hp : 1 - 2 * reciprocalPairParameter p q + (p - q) / 2 = p := by
    unfold reciprocalPairParameter
    ring
  have hq : 1 - 2 * reciprocalPairParameter p q - (p - q) / 2 = q := by
    unfold reciprocalPairParameter
    ring
  simpa only [hp, hq] using
    symmetricProduct_eq_of_root_square (reciprocalPairParameter p q) ((p - q) / 2) hroot

def exponentialPairParameter (u : ℂ) : ℂ :=
  reciprocalPairParameter (Complex.exp u) (Complex.exp (-u))

@[simp] theorem exponentialPairParameter_zero :
    exponentialPairParameter 0 = 0 := by
  norm_num [exponentialPairParameter, reciprocalPairParameter]

theorem exponentialPairParameter_neg (u : ℂ) :
    exponentialPairParameter (-u) = exponentialPairParameter u := by
  simp only [exponentialPairParameter, reciprocalPairParameter, neg_neg]
  ring

/-- Exact exponential pullback, before taking local logarithms. -/
theorem symmetricProduct_exponential_pair (u : ℂ) :
    symmetricProduct (exponentialPairParameter u) =
      theta (Complex.exp u) * theta (Complex.exp (-u)) / theta 1 ^ 2 := by
  have hpq : Complex.exp u * Complex.exp (-u) = 1 := by
    rw [← Complex.exp_add]
    simp
  exact symmetricProduct_reciprocal_pair (Complex.exp u) (Complex.exp (-u)) hpq

/-- Generic uniqueness only: the analytic product-jet recurrence must still be
derived for the actual functions before this theorem can identify their values. -/
theorem logWidderTower_unique (base : ℝ → ℝ) (c : ℕ → ℝ → ℝ)
    (hzero : c 0 = base)
    (hsucc : ∀ n : ℕ, c (n + 1) = fun y =>
      2 / (((n : ℝ) + 1) * (2 * (n : ℝ) + 3)) *
        (((n : ℝ) + 1) ^ 2 * c n y - deriv (deriv (c n)) y)) :
    ∀ n : ℕ, c n = logWidderTower base n := by
  intro n
  induction n with
  | zero => simpa only [logWidderTower_zero] using hzero
  | succ n ih =>
      rw [hsucc n, ih]
      rfl

end NativeEnergyBridge

namespace NativeEnergyBridge

theorem subexponentialEnergy_iff_rowVariation (c : ℕ → ℂ) :
    AWPIRH.SubexponentialEnergy c ↔
      Tendsto (fun N : ℕ => Real.log (1 + rowVariation c N) / (N : ℝ))
        atTop (𝓝 0) :=
  energy_limit_iff_variation_limit (AWPIRH.bernsteinEnergy c) (rowVariation c)
    (rowVariation_nonneg c) (rowVariation_sq_le_energy c)
    (energy_le_card_mul_rowVariation_sq c)

/-- Exact reformulation; it does not assert either growth condition. -/
theorem native_energy_iff_xi_variation :
    AWPIRH.US_AWPI ↔
      Tendsto (fun N : ℕ => Real.log (1 + rowVariation xiCoefficients N) / (N : ℝ))
        atTop (𝓝 0) :=
  native_energy_iff_xi_energy.trans
    (subexponentialEnergy_iff_rowVariation xiCoefficients)

theorem native_energy_iff_negative_mass :
    AWPIRH.US_AWPI ↔
      Tendsto (fun N : ℕ =>
        Real.log (1 + (AWPIRH.nativeWidder 0 0 + 2 * nativeNegativeMass N)) / (N : ℝ))
        atTop (𝓝 0) := by
  change AWPIRH.SubexponentialEnergy AWPIRH.nativeCoefficients ↔ _
  simpa only [native_rowVariation_eq_negative_mass] using
    subexponentialEnergy_iff_rowVariation AWPIRH.nativeCoefficients

/-- Explicit two-input reduction. Neither input is proved in this module.
An axiom-audit pass for this implication is not premise-free native RH. -/
theorem nativeRH_of_variation_and_product
    (hVariation : Tendsto
      (fun N : ℕ => Real.log (1 + rowVariation xiCoefficients N) / (N : ℝ))
      atTop (𝓝 0))
    (hProduct : AWPIRH.XiWidderProductCoefficientIdentity) :
    _root_.RiemannHypothesis := by
  exact AWPIRH.MATHLIB_RH_OF_US_MELLIN_GERM_AND_PRODUCT_GERM
    (native_energy_iff_xi_variation.mpr hVariation)
    AWPIRH.NATIVE_MELLIN_ANCHOR_GERM hProduct

end NativeEnergyBridge

run_cmd LeanCandidateAudit.auditAxioms "N01_BRIDGE_NATIVE_COEFFICIENTS" ``NativeEnergyBridge.nativeCoefficients_eq_xiCoefficients
run_cmd LeanCandidateAudit.auditAxioms "N01_BRIDGE_NEGATIVE_MASS" ``NativeEnergyBridge.native_energy_sandwich
run_cmd LeanCandidateAudit.auditAxioms "N01_BRIDGE_GROWTH_CONTROL" ``NativeEnergyBridge.alternating_energy_lower
run_cmd LeanCandidateAudit.auditAxioms "N01_BRIDGE_PRODUCT_PULLBACK" ``NativeEnergyBridge.symmetricProduct_exponential_pair
run_cmd LeanCandidateAudit.auditAxioms "N01_BRIDGE_TOWER_UNIQUENESS" ``NativeEnergyBridge.logWidderTower_unique
run_cmd LeanCandidateAudit.auditAxioms "N01_BRIDGE_VARIATION_EQUIVALENCE" ``NativeEnergyBridge.native_energy_iff_xi_variation
run_cmd LeanCandidateAudit.auditAxioms "N01_BRIDGE_REMAINING_INPUTS" ``NativeEnergyBridge.nativeRH_of_variation_and_product

