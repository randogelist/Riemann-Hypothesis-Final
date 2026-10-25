import AngularRegularity.Derivative

/-!
# The logarithmic slope on the nonzero locus

The logarithmic quotient is used only with an explicit nonzero-value
hypothesis.  On that locus it has the same sign as the angular derivative.
The derivative formula without division by `f` remains in `Derivative.lean`.
These identities make no global sign or nonvanishing claim.
-/

set_option autoImplicit false
noncomputable section

open Set
open scoped Topology

namespace AngularRegularity

def logSlope (f : ℂ → ℂ) (r x : ℝ) : ℝ :=
  (circlePoint r x * deriv f (circlePoint r x) /
    f (circlePoint r x)).im

def regularDomain (f : ℂ → ℂ) : Set (ℝ × ℝ) :=
  {p | p ∈ domain ∧ f (circlePoint p.1 p.2) ≠ 0}

@[simp] theorem mem_regularDomain {f : ℂ → ℂ} {p : ℝ × ℝ} :
    p ∈ regularDomain f ↔ p ∈ domain ∧ f (circlePoint p.1 p.2) ≠ 0 :=
  Iff.rfl

theorem isOpen_regularDomain {f : ℂ → ℂ} (hf : Continuous f) :
    IsOpen (regularDomain f) := by
  change IsOpen (domain ∩
    (fun p : ℝ × ℝ => f (circlePoint p.1 p.2)) ⁻¹' ({0}ᶜ : Set ℂ))
  exact isOpen_domain.inter
    (isClosed_singleton.isOpen_compl.preimage (hf.comp continuous_circlePoint_joint))

/-- The only cancellation used in the logarithmic-derivative formula. -/
theorem im_mul_star_eq_normSq_mul_im_div (a v : ℂ) (hv : v ≠ 0) :
    (a * star v).im = Complex.normSq v * (a / v).im := by
  have hnorm : (Complex.normSq v : ℂ) = v * star v := by
    apply Complex.ext <;>
      simp [Complex.normSq_apply, Complex.mul_re, Complex.mul_im,
        Complex.star_def] <;>
      ring
  have hmul : a * star v = (Complex.normSq v : ℂ) * (a / v) := by
    rw [hnorm]
    field_simp [hv] <;> ring
  simpa [Complex.mul_im] using congrArg Complex.im hmul

/-- At a nonzero value the derivative is a positive scalar times the
imaginary part of the radial logarithmic derivative. -/
theorem angularDerivative_eq_logSlope_mul {f : ℂ → ℂ} {r x : ℝ}
    (hf : DifferentiableAt ℂ f (circlePoint r x))
    (hx : x ∈ Set.Ioo (-1 : ℝ) 1)
    (hv : f (circlePoint r x) ≠ 0) :
    angularDerivative f r x =
      (2 * profile f r x / Real.sqrt (1 - x ^ 2)) * logSlope f r x := by
  rw [angularDerivative_eq_slopeFormula hf hx]
  unfold slopeFormula
  rw [im_mul_star_eq_normSq_mul_im_div
    (circlePoint r x * deriv f (circlePoint r x))
    (f (circlePoint r x)) hv]
  unfold profile logSlope
  ring

theorem logSlope_factor_pos {f : ℂ → ℂ} {r x : ℝ}
    (hx : x ∈ Set.Ioo (-1 : ℝ) 1)
    (hv : f (circlePoint r x) ≠ 0) :
    0 < 2 * profile f r x / Real.sqrt (1 - x ^ 2) :=
  div_pos (mul_pos (by norm_num) ((profile_pos_iff f r x).2 hv))
    (sqrt_one_sub_sq_pos hx)

theorem angularDerivative_eq_zero_iff_logSlope_eq_zero
    {f : ℂ → ℂ} {r x : ℝ}
    (hf : DifferentiableAt ℂ f (circlePoint r x))
    (hx : x ∈ Set.Ioo (-1 : ℝ) 1)
    (hv : f (circlePoint r x) ≠ 0) :
    angularDerivative f r x = 0 ↔ logSlope f r x = 0 := by
  rw [angularDerivative_eq_logSlope_mul hf hx hv]
  constructor
  · intro hz
    exact (mul_eq_zero.mp hz).resolve_left (ne_of_gt (logSlope_factor_pos hx hv))
  · intro hz
    rw [hz, mul_zero]

theorem angularDerivative_pos_iff_logSlope_pos {f : ℂ → ℂ} {r x : ℝ}
    (hf : DifferentiableAt ℂ f (circlePoint r x))
    (hx : x ∈ Set.Ioo (-1 : ℝ) 1)
    (hv : f (circlePoint r x) ≠ 0) :
    0 < angularDerivative f r x ↔ 0 < logSlope f r x := by
  rw [angularDerivative_eq_logSlope_mul hf hx hv]
  have hfactor := logSlope_factor_pos hx hv
  constructor
  · intro h
    by_contra hsign
    have hle : logSlope f r x ≤ 0 := le_of_not_gt hsign
    have hproduct :
        (2 * profile f r x / Real.sqrt (1 - x ^ 2)) * logSlope f r x ≤ 0 :=
      mul_nonpos_of_nonneg_of_nonpos hfactor.le hle
    exact (not_le_of_gt h) hproduct
  · intro h
    exact mul_pos hfactor h

theorem angularDerivative_neg_iff_logSlope_neg {f : ℂ → ℂ} {r x : ℝ}
    (hf : DifferentiableAt ℂ f (circlePoint r x))
    (hx : x ∈ Set.Ioo (-1 : ℝ) 1)
    (hv : f (circlePoint r x) ≠ 0) :
    angularDerivative f r x < 0 ↔ logSlope f r x < 0 := by
  rw [angularDerivative_eq_logSlope_mul hf hx hv]
  have hfactor := logSlope_factor_pos hx hv
  constructor
  · intro h
    by_contra hsign
    have hge : 0 ≤ logSlope f r x := le_of_not_gt hsign
    have hproduct :
        0 ≤ (2 * profile f r x / Real.sqrt (1 - x ^ 2)) * logSlope f r x :=
      mul_nonneg hfactor.le hge
    exact (not_le_of_gt h) hproduct
  · intro h
    exact mul_neg_of_pos_of_neg hfactor h

/-- The zero case is retained explicitly instead of being cancelled from
the logarithmic derivative. -/
theorem angularDerivative_eq_zero_iff_value_eq_zero_or_logSlope_eq_zero
    {f : ℂ → ℂ} {r x : ℝ}
    (hf : DifferentiableAt ℂ f (circlePoint r x))
    (hx : x ∈ Set.Ioo (-1 : ℝ) 1) :
    angularDerivative f r x = 0 ↔
      f (circlePoint r x) = 0 ∨ logSlope f r x = 0 := by
  by_cases hv : f (circlePoint r x) = 0
  · simp [hv, angularDerivative_eq_zero_of_value_eq_zero hf hx hv]
  · simpa only [hv, false_or] using
      angularDerivative_eq_zero_iff_logSlope_eq_zero hf hx hv

/-- Generic continuity inputs suffice; regularity means the denominator
is explicitly nonzero at every point under consideration. -/
theorem continuousOn_logSlope_of_continuous {f : ℂ → ℂ}
    (hf : Continuous f) (hdf : Continuous (deriv f)) :
    ContinuousOn (fun p : ℝ × ℝ => logSlope f p.1 p.2) (regularDomain f) := by
  have hv : Continuous (fun p : ℝ × ℝ => f (circlePoint p.1 p.2)) :=
    hf.comp continuous_circlePoint_joint
  have hn : Continuous (fun p : ℝ × ℝ =>
      circlePoint p.1 p.2 * deriv f (circlePoint p.1 p.2)) :=
    continuous_circlePoint_joint.mul (hdf.comp continuous_circlePoint_joint)
  intro p hp
  have hq : ContinuousAt (fun q : ℝ × ℝ =>
      circlePoint q.1 q.2 * deriv f (circlePoint q.1 q.2) /
        f (circlePoint q.1 q.2)) p :=
    hn.continuousAt.div hv.continuousAt hp.2
  exact (Complex.continuous_im.continuousAt.comp hq).continuousWithinAt

/-- Entire differentiability supplies both continuity inputs. -/
theorem continuousOn_logSlope {f : ℂ → ℂ} (hf : Differentiable ℂ f) :
    ContinuousOn (fun p : ℝ × ℝ => logSlope f p.1 p.2) (regularDomain f) :=
  continuousOn_logSlope_of_continuous hf.continuous hf.deriv.continuous

end AngularRegularity
