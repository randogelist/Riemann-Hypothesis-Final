import RHMaster.AngularCoverage
import AngularMaster.ConjugateFactor
import Support.AuditPolicy

/-!
Source-only N02 development. No assertion of the residual positivity condition.
The first result closes the previously omitted cutoff boundary by continuity.
The factor algebra identifies the exact sign balance a further estimate needs.
-/

set_option autoImplicit false
noncomputable section
open Set Filter
open scoped Topology BigOperators ComplexConjugate

namespace NativeAngularResidualDevelopment

/-- The endpoint of the already proved sector is included by continuity. -/
theorem actualAngularSlope_nonnegative_at_cutoff {r : ℝ} (hr : 0 < r) :
    0 ≤ AngularRegularity.actualAngularSlope r (-(84 / 85 : ℝ)) := by
  by_contra hn
  have hneg : AngularRegularity.actualAngularSlope r (-(84 / 85 : ℝ)) < 0 :=
    lt_of_not_ge hn
  have hc : ContinuousAt (AngularRegularity.actualAngularSlope r)
      (-(84 / 85 : ℝ)) :=
    AngularRegularity.angularSlope_continuousAt AWPIRH.theta_differentiable
      (by norm_num)
  obtain ⟨ε, hε, hnear⟩ := AngularRegularity.negative_witness_two_sided
    (A := fun t (_ : ℝ) => AngularRegularity.actualAngularSlope r t)
    (c := 0) hc hneg
  let δ : ℝ := min ε 1 / 2
  have hδ : 0 < δ := by
    dsimp [δ]
    exact div_pos (lt_min_iff.mpr ⟨hε, by norm_num⟩) (by norm_num)
  have hδε : δ < ε := by
    have hm := min_le_left ε (1 : ℝ)
    dsimp [δ]
    linarith
  have hδone : δ ≤ 1 / 2 := by
    have hm := min_le_right ε (1 : ℝ)
    dsimp [δ]
    linarith
  have hright := (hnear δ (by rw [abs_of_pos hδ]; exact hδε)).2
  have hnonneg :=
    RHMaster.actualAngularSlope_nonnegative_above_neg_eightyfour_eightyfive
      hr (x := -(84 / 85 : ℝ) + δ) (by linarith) (by linarith)
  exact (not_lt_of_ge hnonneg) hright

theorem actualAngularSlope_nonnegative_on_closed_sector
    {r x : ℝ} (hr : 0 < r) (hx : -(84 / 85 : ℝ) ≤ x) (hx1 : x < 1) :
    0 ≤ AngularRegularity.actualAngularSlope r x := by
  rcases eq_or_lt_of_le hx with heq | hlt
  · rw [← heq]
    exact actualAngularSlope_nonnegative_at_cutoff hr
  · exact RHMaster.actualAngularSlope_nonnegative_above_neg_eightyfour_eightyfive
      hr hlt hx1

/-- The remaining region can use a strict angular inequality. -/
def StrictAngularResidualNonnegative : Prop :=
  ∀ r : ℝ, (255 / 7 : ℝ) < r → ∀ x : ℝ,
    -1 < x → x < -(84 / 85 : ℝ) →
      0 ≤ AngularRegularity.actualAngularSlope r x

theorem angularResidual_iff_strict :
    RHMaster.AngularResidualNonnegative ↔ StrictAngularResidualNonnegative := by
  constructor
  · intro h r hr x hx0 hx
    exact h r hr x ⟨hx0, by linarith⟩ hx.le
  · intro h r hr x hx hcut
    rcases lt_or_eq_of_le hcut with hlt | heq
    · exact h r hr x hx.1 hlt
    · rw [heq]
      exact actualAngularSlope_nonnegative_at_cutoff (by linarith)

theorem native_RH_iff_strictAngularResidual :
    _root_.RiemannHypothesis ↔ StrictAngularResidualNonnegative :=
  RHMaster.native_RH_iff_angularResidualNonnegative.trans angularResidual_iff_strict

/-- Compact exact derivative; positivity of the factor is separate. -/
theorem factor_derivative (q c x : ℝ) :
    deriv (AngularMaster.conjugateFactorPolynomial q c) x =
      4 * q * (2 * q * x - c * (1 + q ^ 2)) := by
  rw [AngularMaster.deriv_conjugateFactorPolynomial]
  ring

/-- The constant-radius obstruction is an explicit algebraic one. -/
theorem resonant_factor_value (c : ℝ) :
    AngularMaster.conjugateFactorPolynomial 1 c ((c - 1) / 2) = (c + 1) ^ 2 := by
  unfold AngularMaster.conjugateFactorPolynomial
  ring

theorem resonant_factor_derivative (c : ℝ) :
    deriv (AngularMaster.conjugateFactorPolynomial 1 c) ((c - 1) / 2) =
      -4 * (c + 1) := by
  rw [factor_derivative]
  ring

/-- Off-axis factors have positive values with strictly negative angular slope. -/
theorem off_axis_factor_negative_witness {c : ℝ} (hc0 : -1 < c) (hc1 : c < 1) :
    ∃ x ∈ Ioo (-1 : ℝ) 1,
      0 < AngularMaster.conjugateFactorPolynomial 1 c x ∧
        deriv (AngularMaster.conjugateFactorPolynomial 1 c) x < 0 := by
  refine ⟨(c - 1) / 2, ⟨by linarith, by linarith⟩, ?_, ?_⟩
  · rw [resonant_factor_value]
    exact sq_pos_of_pos (by linarith)
  · rw [resonant_factor_derivative]
    linarith

/-- Exact radial endpoint factorization, for S = g^2+h^2. -/
theorem radial_endpoint_factorization (g h r : ℝ) :
    (g ^ 2 - h ^ 2) * ((g ^ 2 + h ^ 2) ^ 2 + r ^ 2) -
        2 * r * (g ^ 2 + h ^ 2) ^ 2 =
      ((g - h) * (g ^ 2 + h ^ 2) - (g + h) * r) *
        ((g + h) * (g ^ 2 + h ^ 2) - (g - h) * r) := by
  ring

/-- Moving away from x=-1 adds a nonnegative term to the numerator. -/
theorem angular_numerator_decomposition (g h r x : ℝ) :
    (g ^ 2 - h ^ 2) * ((g ^ 2 + h ^ 2) ^ 2 + r ^ 2) +
        2 * r * (g ^ 2 + h ^ 2) ^ 2 * x =
      ((g - h) * (g ^ 2 + h ^ 2) - (g + h) * r) *
        ((g + h) * (g ^ 2 + h ^ 2) - (g - h) * r) +
      2 * r * (g ^ 2 + h ^ 2) ^ 2 * (x + 1) := by
  ring

/-- A concrete obstruction respecting c=-84/85 and the residual angle. -/
theorem residual_factor_counterexample :
    AngularMaster.conjugateFactorPolynomial 1 (-(84 / 85 : ℝ))
        (-(169 / 170 : ℝ)) = 1 / 7225 ∧
      deriv (AngularMaster.conjugateFactorPolynomial 1 (-(84 / 85 : ℝ)))
        (-(169 / 170 : ℝ)) = -(4 / 85 : ℝ) := by
  constructor
  · norm_num [AngularMaster.conjugateFactorPolynomial]
  · rw [factor_derivative]
    norm_num

/-- A cutoff may depend on r; the vertex inequality is the full requirement. -/
theorem pair_monotoneOn_of_vertex {q c a : ℝ} (hq : 0 ≤ q)
    (hv : 0 ≤ 2 * q * a - c * (1 + q ^ 2)) :
    MonotoneOn (AngularMaster.conjugateFactorPolynomial q c) (Ici a) := by
  intro x hx y hy hxy
  have hbracket : 0 ≤ q * ((x - a) + (y - a)) +
      (2 * q * a - c * (1 + q ^ 2)) :=
    add_nonneg (mul_nonneg hq (by change a ≤ x at hx; change a ≤ y at hy; linarith)) hv
  have hdiff : 0 ≤ AngularMaster.conjugateFactorPolynomial q c y -
      AngularMaster.conjugateFactorPolynomial q c x := by
    calc
      _ = (y - x) * (4 * q * (q * ((x - a) + (y - a)) +
          (2 * q * a - c * (1 + q ^ 2)))) := by
            unfold AngularMaster.conjugateFactorPolynomial
            ring
      _ ≥ 0 := mul_nonneg (sub_nonneg.mpr hxy) (mul_nonneg (by positivity) hbracket)
  exact sub_nonneg.mp hdiff

/-- Sum of nonnegative terms behind the curved cutoff r(x+1)>=84/167. -/
theorem curved_numerator_identity (S h r x : ℝ) :
    (S - 2 * h ^ 2) * (S ^ 2 + r ^ 2) + 2 * r * S ^ 2 * x =
      (S - 169 / 4) * (S - r) ^ 2 + (167 * (S - r) + 2 * S) ^ 2 / 668 +
      (1 / 2 - 2 * h ^ 2) * (S ^ 2 + r ^ 2) +
      2 * S ^ 2 * (r * (x + 1) - 84 / 167) := by
  ring

theorem curved_vertex_nonnegative {S h r x : ℝ} (hS : (169 / 4 : ℝ) ≤ S)
    (hh : h ^ 2 ≤ 1 / 4) (hx : (84 / 167 : ℝ) ≤ r * (x + 1)) :
    0 ≤ 2 * (r / S) * x - ((2 * h ^ 2 - S) / S) * (1 + (r / S) ^ 2) := by
  have hSpos : 0 < S := by linarith
  have hS0 : S ≠ 0 := ne_of_gt hSpos
  have hN : 0 ≤ (S - 2 * h ^ 2) * (S ^ 2 + r ^ 2) + 2 * r * S ^ 2 * x := by
    rw [curved_numerator_identity]
    have hS1 : 0 ≤ S - 169 / 4 := by linarith
    have hhalf : 0 ≤ 1 / 2 - 2 * h ^ 2 := by linarith
    have hxx : 0 ≤ r * (x + 1) - 84 / 167 := by linarith
    positivity
  have hid : 2 * (r / S) * x - ((2 * h ^ 2 - S) / S) * (1 + (r / S) ^ 2) =
      ((S - 2 * h ^ 2) * (S ^ 2 + r ^ 2) + 2 * r * S ^ 2 * x) / S ^ 3 := by
    field_simp [hS0] <;> ring
  rw [hid]
  exact div_nonneg hN (by positivity)

def curvedCutoff (r : ℝ) : ℝ := -1 + (84 / 167) / r

theorem curvedCutoff_mul (r : ℝ) (hr : r ≠ 0) : r * (curvedCutoff r + 1) = 84 / 167 := by
  unfold curvedCutoff
  field_simp [hr] <;> ring

theorem curvedCutoff_lower {r : ℝ} (hr : 0 < r) : -1 < curvedCutoff r := by
  unfold curvedCutoff
  have : 0 < (84 / 167 : ℝ) / r := div_pos (by norm_num) hr
  linarith

/-- General complex-pair transport using only strip half-width and height. -/
theorem normSq_pair_monotoneOn_curved {w : ℂ}
    (hre : |w.re| ≤ (1 / 2 : ℝ)) (him : (13 / 2 : ℝ) ≤ |w.im|)
    {r : ℝ} (hr : 0 < r) :
    MonotoneOn (fun x => Complex.normSq
      ((1 - AngularMaster.circlePoint r x / w ^ 2) *
        (1 - AngularMaster.circlePoint r x / conj (w ^ 2))))
      (Icc (curvedCutoff r) 1) := by
  have hw : w ≠ 0 := by
    intro hw
    simp only [hw, Complex.zero_im, abs_zero] at him
    norm_num at him
  have hw2 : w ^ 2 ≠ 0 := pow_ne_zero 2 hw
  have hn : ‖w ^ 2‖ = |w.im| ^ 2 + |w.re| ^ 2 := by
    rw [AngularMaster.norm_square_eq_re_sq_add_im_sq, sq_abs, sq_abs]
    ring
  have hreal : (w ^ 2).re =
      2 * |w.re| ^ 2 - (|w.im| ^ 2 + |w.re| ^ 2) := by
    rw [AngularMaster.square_re_eq_re_sq_sub_im_sq, sq_abs, sq_abs]
    ring
  have hS : (169 / 4 : ℝ) ≤ |w.im| ^ 2 + |w.re| ^ 2 := by
    nlinarith [sq_nonneg |w.re|]
  have hh : |w.re| ^ 2 ≤ (1 / 4 : ℝ) := by
    nlinarith [abs_nonneg w.re]
  have hv : 0 ≤ 2 * (r / ‖w ^ 2‖) * curvedCutoff r -
      ((w ^ 2).re / ‖w ^ 2‖) * (1 + (r / ‖w ^ 2‖) ^ 2) := by
    rw [hn, hreal]
    exact curved_vertex_nonnegative hS hh (by rw [curvedCutoff_mul r (ne_of_gt hr)])
  have hm := pair_monotoneOn_of_vertex (div_nonneg hr.le (norm_nonneg _)) hv
  intro x hx y hy hxy
  have hxg : x ∈ Icc (-1 : ℝ) 1 :=
    ⟨(curvedCutoff_lower hr).le.trans hx.1, hx.2⟩
  have hyg : y ∈ Icc (-1 : ℝ) 1 :=
    ⟨(curvedCutoff_lower hr).le.trans hy.1, hy.2⟩
  change Complex.normSq
      ((1 - AngularMaster.circlePoint r x / w ^ 2) *
        (1 - AngularMaster.circlePoint r x / conj (w ^ 2))) ≤
    Complex.normSq
      ((1 - AngularMaster.circlePoint r y / w ^ 2) *
        (1 - AngularMaster.circlePoint r y / conj (w ^ 2)))
  rw [AngularMaster.normSq_conjugateFactor_circle hw2 r x hxg,
    AngularMaster.normSq_conjugateFactor_circle hw2 r y hyg]
  exact hm hx.1 hy.1 hxy

theorem actualSymmetricFactor_monotoneOn_curved
    (i : AngularMaster.ActualPairIndex) {r : ℝ} (hr : 0 < r) :
    MonotoneOn (AngularMaster.actualSymmetricFactor i r) (Icc (curvedCutoff r) 1) := by
  let z := -AngularMaster.actualComplexScale i
  let w := Complex.sqrt z
  have hsq : w ^ 2 = z := AWPIRH.complex_sqrt_sq z
  have hxi : AWPIRH.xi ((1 / 2 : ℂ) + w) = 0 :=
    AngularMaster.actual_theta_neg_complexScale_zero i
  have hstrip := AngularMaster.xi_zero_mem_critical_strip hxi
  have hwre : |w.re| ≤ (1 / 2 : ℝ) := by
    apply abs_le.mpr
    norm_num [Complex.add_re] at hstrip
    constructor <;> linarith
  have hwim : (13 / 2 : ℝ) ≤ |w.im| := by
    have h := AngularMaster.actual_xi_zero_thirteen_halves_lt_abs_im hxi
    simpa using h.le
  have hm := normSq_pair_monotoneOn_curved hwre hwim hr
  rw [hsq] at hm
  have heq (x : ℝ) : AngularMaster.actualSymmetricFactor i r x =
      Complex.normSq ((1 - AngularMaster.circlePoint r x / z) *
        (1 - AngularMaster.circlePoint r x / conj z)) := by
    simpa only [AngularMaster.actualSymmetricFactor, z, div_neg, sub_neg_eq_add] using
      AngularMaster.normSq_symmetricFactor_eq_conjugateFactor z
        (AngularMaster.circlePoint r x)
  intro x hx y hy hxy
  rw [heq, heq]
  exact hm hx hy hxy

theorem actualProfile_monotoneOn_curved {r : ℝ} (hr : 0 < r) :
    MonotoneOn (AngularMaster.actualProfile r) (Icc (curvedCutoff r) 1) := by
  obtain ⟨c, hc, hp⟩ := AngularMaster.actualProfile_sq_symmetric_product_values
  intro x hx y hy hxy
  have hxg : x ∈ AngularMaster.angularInterval :=
    ⟨(curvedCutoff_lower hr).le.trans hx.1, hx.2⟩
  have hyg : y ∈ AngularMaster.angularInterval :=
    ⟨(curvedCutoff_lower hr).le.trans hy.1, hy.2⟩
  have hsq : (AngularMaster.actualProfile r x) ^ 2 ≤
      (AngularMaster.actualProfile r y) ^ 2 := by
    apply le_of_tendsto_of_tendsto' (hp r hr x hxg) (hp r hr y hyg)
    intro s
    apply mul_le_mul_of_nonneg_left ?_ (hc r hr)
    apply Finset.prod_le_prod
    · intro i hi
      exact AngularMaster.actualSymmetricFactor_nonnegative i r x
    · intro i hi
      exact actualSymmetricFactor_monotoneOn_curved i hr hx hy hxy
  exact (sq_le_sq₀ (AngularMaster.actualProfile_nonnegative_all r x)
    (AngularMaster.actualProfile_nonnegative_all r y)).mp hsq

theorem actualAngularSlope_nonnegative_above_curved
    {r x : ℝ} (hr : 0 < r) (hx : curvedCutoff r < x) (hx1 : x < 1) :
    0 ≤ AngularRegularity.actualAngularSlope r x := by
  have hm := actualProfile_monotoneOn_curved hr
  have hd : 0 ≤ derivWithin (AngularMaster.actualProfile r)
      (Icc (curvedCutoff r) 1) x := hm.derivWithin_nonneg
  rw [derivWithin_of_mem_nhds (Icc_mem_nhds hx hx1)] at hd
  exact hd

/-- Above radius 7140/167, the new sector extends the old constant cutoff. -/
theorem curvedCutoff_lt_old_of_large_radius {r : ℝ} (hr : (7140 / 167 : ℝ) < r) :
    curvedCutoff r < -(84 / 85 : ℝ) := by
  have hr0 : 0 < r := by linarith
  have hinv : (84 / 167 : ℝ) / r < (1 / 85 : ℝ) := by
    apply (div_lt_iff₀ hr0).mpr
    nlinarith
  unfold curvedCutoff
  linarith

/-- Exact remaining domain after both constant and curved sector estimates. -/
def CurvedAngularResidualNonnegative : Prop :=
  ∀ r : ℝ, (255 / 7 : ℝ) < r → ∀ x : ℝ,
    -1 < x → x < -(84 / 85 : ℝ) → x ≤ curvedCutoff r →
      0 ≤ AngularRegularity.actualAngularSlope r x

theorem strictResidual_iff_curvedResidual :
    StrictAngularResidualNonnegative ↔ CurvedAngularResidualNonnegative := by
  constructor
  · intro h r hr x hx hcut hcurve
    exact h r hr x hx hcut
  · intro h r hr x hx hcut
    by_cases hcurve : curvedCutoff r < x
    · exact actualAngularSlope_nonnegative_above_curved (by linarith) hcurve
        (by linarith)
    · exact h r hr x hx hcut (le_of_not_gt hcurve)

theorem native_RH_iff_curvedAngularResidual :
    _root_.RiemannHypothesis ↔ CurvedAngularResidualNonnegative :=
  native_RH_iff_strictAngularResidual.trans strictResidual_iff_curvedResidual

end NativeAngularResidualDevelopment

run_cmd LeanCandidateAudit.auditAxioms "N02_RESIDUAL_CLOSED_SECTOR" ``NativeAngularResidualDevelopment.actualAngularSlope_nonnegative_on_closed_sector
run_cmd LeanCandidateAudit.auditAxioms "N02_RESIDUAL_FACTOR_OBSTRUCTION" ``NativeAngularResidualDevelopment.off_axis_factor_negative_witness
run_cmd LeanCandidateAudit.auditAxioms "N02_RESIDUAL_CURVED_NUMERATOR" ``NativeAngularResidualDevelopment.curved_numerator_identity
run_cmd LeanCandidateAudit.auditAxioms "N02_RESIDUAL_CURVED_SECTOR" ``NativeAngularResidualDevelopment.actualAngularSlope_nonnegative_above_curved
run_cmd LeanCandidateAudit.auditAxioms "N02_RESIDUAL_CURVED_IMPROVEMENT" ``NativeAngularResidualDevelopment.curvedCutoff_lt_old_of_large_radius
run_cmd LeanCandidateAudit.auditAxioms "N02_RESIDUAL_REMAINING_EQUIVALENCE" ``NativeAngularResidualDevelopment.native_RH_iff_curvedAngularResidual
