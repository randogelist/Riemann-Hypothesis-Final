import FiveInduction.ActualXi
import Mathlib.NumberTheory.LSeries.Nonvanishing
import Mathlib.Analysis.Complex.SqrtDeriv
import Mathlib.Analysis.Complex.RemovableSingularity
import Mathlib.Tactic.FunProp
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Analysis.Analytic.IsolatedZeros
import Mathlib.Analysis.Complex.Basic
import Mathlib.Topology.Order.DenselyOrdered
import Mathlib.Tactic.Continuity
import Mathlib.Analysis.SpecialFunctions.Sqrt
import Mathlib.Analysis.Complex.RealDeriv


/-!
Actual Mathlib xi, not an arbitrary RH proposition or model zero predicate.
The completion and nonvanishing proofs adapt the supplied native archives.
-/

set_option autoImplicit false
noncomputable section
namespace FiveInduction.SOSGeometry

def xi (s : ℂ) : ℂ :=
  (1 + s * (s - 1) * completedRiemannZeta₀ s) / 2

def centeredXi (w : ℂ) : ℂ := xi ((1 / 2 : ℂ) + w)

def NontrivialZero (s : ℂ) : Prop :=
  riemannZeta s = 0 ∧
    (¬ ∃ n : ℕ, s = -2 * ((n : ℂ) + 1)) ∧ s ≠ 1

theorem xi_differentiable : Differentiable ℂ xi := by
  intro s
  have hL : DifferentiableAt ℂ completedRiemannZeta₀ s :=
    differentiable_completedZeta₀ s
  unfold xi
  fun_prop

theorem xi_reflection (s : ℂ) : xi (1 - s) = xi s := by
  unfold xi
  rw [completedRiemannZeta₀_one_sub]
  ring

theorem centeredXi_differentiable : Differentiable ℂ centeredXi := by
  intro w
  unfold centeredXi
  exact (xi_differentiable ((1 / 2 : ℂ) + w)).comp w (by fun_prop)

theorem centeredXi_even (w : ℂ) : centeredXi (-w) = centeredXi w := by
  unfold centeredXi
  have h := xi_reflection ((1 / 2 : ℂ) + w)
  have heq : (1 : ℂ) - (1 / 2 + w) = 1 / 2 + -w := by ring
  simpa only [heq] using h

theorem nontrivialZero_ne_zero {s : ℂ} (hs : NontrivialZero s) : s ≠ 0 := by
  intro h
  have hz := hs.1
  rw [h, riemannZeta_zero] at hz
  norm_num at hz

theorem gammaR_ne_zero_of_nontrivialZero {s : ℂ} (hs : NontrivialZero s) :
    s.Gammaℝ ≠ 0 := by
  intro hGamma
  rcases Complex.Gammaℝ_eq_zero_iff.mp hGamma with ⟨n, hn⟩
  cases n with
  | zero =>
      have hs0 : s = 0 := by simpa using hn
      exact nontrivialZero_ne_zero hs hs0
  | succ n =>
      apply hs.2.1
      refine ⟨n, ?_⟩
      simpa [Nat.cast_succ, neg_mul] using hn

theorem completedZeta_zero_of_nontrivialZero {s : ℂ} (hs : NontrivialZero s) :
    completedRiemannZeta s = 0 := by
  have hs0 := nontrivialZero_ne_zero hs
  have hg := gammaR_ne_zero_of_nontrivialZero hs
  have hd : completedRiemannZeta s / s.Gammaℝ = 0 := by
    calc
      _ = riemannZeta s := (riemannZeta_def_of_ne_zero hs0).symm
      _ = 0 := hs.1
  exact (div_eq_zero_iff.mp hd).resolve_right hg

theorem xi_eq_completed {s : ℂ} (hs0 : s ≠ 0) (hs1 : s ≠ 1) :
    xi s = (s * (s - 1) / 2) * completedRiemannZeta s := by
  rw [completedRiemannZeta_eq]
  have h1s : (1 : ℂ) - s ≠ 0 := sub_ne_zero.mpr (Ne.symm hs1)
  unfold xi
  field_simp [hs0, h1s]
  ring

theorem xi_zero_of_nontrivialZero {s : ℂ} (hs : NontrivialZero s) : xi s = 0 := by
  rw [xi_eq_completed (nontrivialZero_ne_zero hs) hs.2.2,
    completedZeta_zero_of_nontrivialZero hs]
  simp

theorem xi_ne_zero_of_one_le_re {s : ℂ} (hs : 1 ≤ s.re) : xi s ≠ 0 := by
  by_cases h1 : s = 1
  · subst s
    norm_num [xi]
  · have hzeta : riemannZeta s ≠ 0 := riemannZeta_ne_zero_of_one_le_re hs
    intro hxi
    apply hzeta
    rw [riemannZeta_eq_mul_completedRiemannZeta₀]
    have hraw : 1 + s * (s - 1) * completedRiemannZeta₀ s = 0 := by
      simpa [xi] using hxi
    have h1ms : (1 : ℂ) - s ≠ 0 := sub_ne_zero.mpr (Ne.symm h1)
    have hnum : s * completedRiemannZeta₀ s - 1 - s / (1 - s) = 0 := by
      calc
        _ = -(1 + s * (s - 1) * completedRiemannZeta₀ s) / (1 - s) := by
          field_simp [h1ms]
          ring
        _ = 0 := by rw [hraw]; simp
    rw [hnum]
    simp

/-- Pointwise even descent; global analyticity is a separate implementation block. -/
def theta (z : ℂ) : ℂ := centeredXi (Complex.sqrt z)

theorem complex_sqrt_sq (z : ℂ) : (Complex.sqrt z) ^ 2 = z := by
  simpa only [Complex.sqrt] using Complex.cpow_ofNat_inv_pow z 2

theorem theta_square (w : ℂ) : theta (w ^ 2) = centeredXi w := by
  have hsq : (Complex.sqrt (w ^ 2)) ^ 2 = w ^ 2 := complex_sqrt_sq _
  rcases (sq_eq_sq_iff_eq_or_eq_neg).mp hsq with h | h
  · simp [theta, h]
  · simpa [theta, h] using centeredXi_even w

theorem theta_one : theta 1 = xi (3 / 2 : ℂ) := by
  have h : (1 / 2 : ℂ) + 1 = 3 / 2 := by ring
  simpa [theta, centeredXi] using congrArg xi h

theorem theta_one_ne_zero : theta 1 ≠ 0 := by
  rw [theta_one]
  apply xi_ne_zero_of_one_le_re
  norm_num

theorem theta_zero_of_nontrivialZero {s : ℂ} (hs : NontrivialZero s) :
    theta ((s - 1 / 2) ^ 2) = 0 := by
  rw [theta_square]
  have hshift : (1 / 2 : ℂ) + (s - 1 / 2) = s := by ring
  simpa [centeredXi, hshift] using xi_zero_of_nontrivialZero hs

end FiveInduction.SOSGeometry


/-!
Entire descent of the ACTUAL centered xi through the square map.

The principal square root is only used where its behavior has been justified.
At a nonzero center z0, sqrt(z0)*sqrt(z/z0) is differentiable at z0, because
z/z0 = 1 there. Its square is z everywhere. The previously proved theta_square
then identifies the resulting local expression with the literal theta.
At zero, continuity and the removable-singularity theorem finish the descent.
No nonvanishing assertion about xi away from the existing positive anchor enters.
-/
set_option autoImplicit false
noncomputable section
open scoped Topology
open Filter
namespace FiveInduction.SOSGeometry

/-- The square root is differentiable at 1, a point of its slit domain. -/
theorem sqrt_differentiableAt_one :
    DifferentiableAt ℂ Complex.sqrt (1 : ℂ) := by
  have hslit : (1 : ℂ) ∈ Complex.slitPlane := by
    exact Or.inl (by norm_num)
  have h : DifferentiableAt ℂ (fun z : ℂ => z ^ (2 : ℂ)⁻¹) (1 : ℂ) :=
    differentiableAt_id.cpow_const hslit
  have hsqrt : Complex.sqrt = (fun z : ℂ => z ^ (2 : ℂ)⁻¹) := by
    funext z
    simp only [Complex.sqrt]
  rw [hsqrt]
  exact h

/-- At the branch point zero, only continuity is needed or claimed. -/
theorem sqrt_continuousAt_zero : ContinuousAt Complex.sqrt (0 : ℂ) := by
  have h : ContinuousAt (fun z : ℂ => z ^ (2 : ℂ)⁻¹) (0 : ℂ) :=
    Complex.continuousAt_cpow_const_of_re_pos
      (Or.inl (by norm_num)) (by norm_num)
  have hsqrt : Complex.sqrt = (fun z : ℂ => z ^ (2 : ℂ)⁻¹) := by
    funext z
    simp only [Complex.sqrt]
  rw [hsqrt]
  exact h

/-- A root normalized around a nonzero center; not a global analytic branch. -/
def normalizedSqrt (z0 z : ℂ) : ℂ :=
  Complex.sqrt z0 * Complex.sqrt (z / z0)

theorem normalizedSqrt_sq {z0 : ℂ} (hz0 : z0 ≠ 0) (z : ℂ) :
    (normalizedSqrt z0 z) ^ 2 = z := by
  rw [normalizedSqrt, mul_pow, complex_sqrt_sq, complex_sqrt_sq]
  field_simp [hz0]

theorem normalizedSqrt_differentiableAt {z0 : ℂ} (hz0 : z0 ≠ 0) :
    DifferentiableAt ℂ (normalizedSqrt z0) z0 := by
  have hdiv : DifferentiableAt ℂ (fun z : ℂ => z / z0) z0 := by
    simpa only [div_eq_mul_inv] using
      (hasDerivAt_mul_const (𝕜 := ℂ) (x := z0) z0⁻¹).differentiableAt
  have hsqrt : DifferentiableAt ℂ Complex.sqrt (z0 / z0) := by
    rw [div_self hz0]
    exact sqrt_differentiableAt_one
  have hcomp : DifferentiableAt ℂ
      (fun z : ℂ => Complex.sqrt (z / z0)) z0 := by
    exact DifferentiableAt.fun_comp'
      (f := fun z : ℂ => z / z0) (g := Complex.sqrt) z0 hsqrt hdiv
  have hmul : DifferentiableAt ℂ
      (fun w : ℂ => Complex.sqrt z0 * w) (Complex.sqrt (z0 / z0)) :=
    (hasDerivAt_const_mul (𝕜 := ℂ)
      (x := Complex.sqrt (z0 / z0)) (Complex.sqrt z0)).differentiableAt
  change DifferentiableAt ℂ
    (fun z : ℂ => Complex.sqrt z0 * Complex.sqrt (z / z0)) z0
  exact DifferentiableAt.fun_comp'
    (f := fun z : ℂ => Complex.sqrt (z / z0))
    (g := fun w : ℂ => Complex.sqrt z0 * w) z0 hmul hcomp

theorem theta_eq_normalizedSqrt {z0 : ℂ} (hz0 : z0 ≠ 0) (z : ℂ) :
    theta z = centeredXi (normalizedSqrt z0 z) := by
  have h := theta_square (normalizedSqrt z0 z)
  simpa only [normalizedSqrt_sq hz0 z] using h

theorem theta_differentiableAt_of_ne_zero {z : ℂ} (hz : z ≠ 0) :
    DifferentiableAt ℂ theta z := by
  have heq : theta = fun w : ℂ => centeredXi (normalizedSqrt z w) := by
    funext w
    exact theta_eq_normalizedSqrt hz w
  rw [heq]
  exact (centeredXi_differentiable (normalizedSqrt z z)).comp z
    (normalizedSqrt_differentiableAt hz)

theorem theta_continuousAt_zero : ContinuousAt theta (0 : ℂ) := by
  change ContinuousAt (fun z : ℂ => centeredXi (Complex.sqrt z)) (0 : ℂ)
  exact (centeredXi_differentiable (Complex.sqrt 0)).continuousAt.comp
    sqrt_continuousAt_zero

theorem theta_analyticAt_zero : AnalyticAt ℂ theta (0 : ℂ) := by
  apply Complex.analyticAt_of_differentiable_on_punctured_nhds_of_continuousAt
  · have hpunct : ∀ᶠ z : ℂ in 𝓝[≠] (0 : ℂ), z ≠ 0 := self_mem_nhdsWithin
    exact hpunct.mono (fun z hz => theta_differentiableAt_of_ne_zero hz)
  · exact theta_continuousAt_zero

theorem theta_differentiable : Differentiable ℂ theta := by
  intro z
  by_cases hz : z = 0
  · subst z
    exact theta_analyticAt_zero.differentiableAt
  · exact theta_differentiableAt_of_ne_zero hz

theorem theta_analyticAt (z : ℂ) : AnalyticAt ℂ theta z :=
  theta_differentiable.analyticAt z

theorem theta_entire : AnalyticOnNhd ℂ theta Set.univ := by
  intro z _
  exact theta_analyticAt z

theorem theta_continuous : Continuous theta :=
  theta_differentiable.continuous

end FiveInduction.SOSGeometry


/-!
A general analytic zero-exclusion theorem behind angular monotonicity.
No assertion about the location of zeros is assumed: the proof uses the identity
principle for analytic functions and the real part of the circle parameter.
-/

noncomputable section
open Set Filter
open scoped Topology ComplexConjugate

namespace FiveInduction.SOSGeometry

/-- Upper semicircle, parametrized by the normalized real coordinate. -/
def circlePoint (r x : ℝ) : ℂ :=
  (r : ℂ) * ((x : ℂ) + Complex.I * (Real.sqrt (1 - x ^ 2) : ℂ))

/-- Squared modulus on a circle, in angular coordinate `x = cos θ`. -/
def angularNormSq (f : ℂ → ℂ) (r x : ℝ) : ℝ :=
  Complex.normSq (f (circlePoint r x))

@[simp] theorem circlePoint_re (r x : ℝ) : (circlePoint r x).re = r * x := by
  simp [circlePoint, Complex.mul_re]

@[simp] theorem circlePoint_im (r x : ℝ) :
    (circlePoint r x).im = r * Real.sqrt (1 - x ^ 2) := by
  simp [circlePoint, Complex.mul_im]

theorem continuous_circlePoint (r : ℝ) : Continuous (circlePoint r) := by
  unfold circlePoint
  continuity

theorem injective_circlePoint {r : ℝ} (hr : r ≠ 0) :
    Function.Injective (circlePoint r) := by
  intro x y h
  have h' := congrArg Complex.re h
  simp only [circlePoint_re] at h'
  exact mul_left_cancel₀ hr h'

/-- A nonconstant continuous injective arc of zeros forces an entire function
    to vanish identically. This is the only analytic uniqueness input. -/
theorem entire_eq_zero_of_zero_arc {f : ℂ → ℂ}
    (hf : AnalyticOnNhd ℂ f univ) {γ : ℝ → ℂ} (hγ : Continuous γ)
    (hinj : Function.Injective γ) {a b : ℝ} (hab : a < b)
    (hz : ∀ x ∈ Icc a b, f (γ x) = 0) : f = 0 := by
  have ht : Tendsto γ (𝓝[>] a) (𝓝[≠] γ a) := by
    refine tendsto_nhdsWithin_iff.mpr ⟨hγ.continuousAt.tendsto.mono_left nhdsWithin_le_nhds, ?_⟩
    filter_upwards [self_mem_nhdsWithin] with x hx
    change γ x ≠ γ a
    exact fun h => (ne_of_gt hx) (hinj h)
  have he : ∀ᶠ x in 𝓝[>] a, f (γ x) = 0 := by
    have hb : ∀ᶠ x in 𝓝[>] a, x < b :=
      nhdsWithin_le_nhds (eventually_lt_nhds hab)
    filter_upwards [self_mem_nhdsWithin, hb] with x hx hxb
    exact hz x ⟨le_of_lt hx, le_of_lt hxb⟩
  exact hf.eq_of_frequently_eq analyticOnNhd_const (ht.frequently he.frequently)

/-- Every point of the closed upper half-plane except zero has this circle
    representation. -/
theorem circlePoint_norm_re_div {z : ℂ} (hz : z ≠ 0) (hi : 0 ≤ z.im) :
    circlePoint ‖z‖ (z.re / ‖z‖) = z := by
  have hn : 0 < ‖z‖ := norm_pos_iff.mpr hz
  have hn0 : ‖z‖ ≠ 0 := ne_of_gt hn
  have hsq : 1 - (z.re / ‖z‖) ^ 2 = (z.im / ‖z‖) ^ 2 := by
    have h := Complex.sq_norm_sub_sq_re z
    field_simp [hn0]
    nlinarith
  have hsqrt : Real.sqrt (1 - (z.re / ‖z‖) ^ 2) = z.im / ‖z‖ := by
    rw [hsq, Real.sqrt_sq (div_nonneg hi hn.le)]
  apply Complex.ext
  · simp only [circlePoint_re]
    field_simp [hn0]
  · simp only [circlePoint_im, hsqrt]
    field_simp [hn0]

end FiveInduction.SOSGeometry


/-! Actual xi strip membership and conjugation symmetry used by QQRH. -/

set_option autoImplicit false
noncomputable section
namespace FiveInduction.SOSGeometry

open ComplexConjugate

theorem xi_zero_mem_critical_strip {s : ℂ} (hs : xi s = 0) :
    0 < s.re ∧ s.re < 1 := by
  constructor
  · by_contra hn
    have hle : s.re ≤ 0 := le_of_not_gt hn
    have hre : 1 ≤ (1 - s).re := by
      simp only [Complex.sub_re, Complex.one_re]
      linarith
    apply xi_ne_zero_of_one_le_re hre
    rw [xi_reflection]
    exact hs
  · by_contra hn
    exact xi_ne_zero_of_one_le_re (le_of_not_gt hn) hs

theorem nontrivialZero_of_xi_zero {s : ℂ} (hs : xi s = 0) :
    NontrivialZero s := by
  have hstrip := xi_zero_mem_critical_strip hs
  have hs1 : s ≠ 1 := by
    intro h
    subst s
    norm_num at hstrip
  have hraw : 1 + s * (s - 1) * completedRiemannZeta₀ s = 0 := by
    simpa [xi] using hs
  have h1ms : (1 : ℂ) - s ≠ 0 := sub_ne_zero.mpr (Ne.symm hs1)
  have hnum : s * completedRiemannZeta₀ s - 1 - s / (1 - s) = 0 := by
    calc
      _ = -(1 + s * (s - 1) * completedRiemannZeta₀ s) / (1 - s) := by
        field_simp [h1ms]
        ring
      _ = 0 := by rw [hraw]; simp
  refine ⟨?_, ?_, hs1⟩
  · rw [riemannZeta_eq_mul_completedRiemannZeta₀, hnum]
    simp
  · rintro ⟨n, hn⟩
    have hre := congrArg Complex.re hn
    simp [Complex.mul_re] at hre
    have hn0 : (0 : ℝ) ≤ n := Nat.cast_nonneg n
    linarith [hstrip.1]

/-- Only zero symmetry is needed for angular zero exclusion. -/
theorem xi_zero_conj {s : ℂ} (hs : xi s = 0) : xi (conj s) = 0 := by
  have hstrip := xi_zero_mem_critical_strip hs
  have hz := nontrivialZero_of_xi_zero hs
  apply xi_zero_of_nontrivialZero
  refine ⟨?_, ?_, ?_⟩
  · rw [riemannZeta_conj, hz.1, map_zero]
  · rintro ⟨n, hn⟩
    have hre := congrArg Complex.re hn
    simp [Complex.mul_re] at hre
    have hn0 : (0 : ℝ) ≤ n := Nat.cast_nonneg n
    linarith [hstrip.1]
  · intro h
    have hre := congrArg Complex.re h
    simp at hre
    linarith [hstrip.2]

theorem theta_zero_conj {z : ℂ} (hz : theta z = 0) : theta (conj z) = 0 := by
  have hx : xi ((1 / 2 : ℂ) + Complex.sqrt z) = 0 := hz
  have hxc := xi_zero_conj hx
  have hsq : (conj (Complex.sqrt z)) ^ 2 = conj z := by
    rw [← map_pow, complex_sqrt_sq]
  rw [← hsq, theta_square]
  change xi ((1 / 2 : ℂ) + conj (Complex.sqrt z)) = 0
  have htwo : conj (2 : ℂ) = (2 : ℂ) := Complex.conj_ofNat 2
  simpa [htwo] using hxc

end FiveInduction.SOSGeometry

namespace FiveInduction.SOSGeometry
noncomputable def angularDerivative (P : ℝ → ℝ → ℝ) (r x : ℝ) : ℝ :=
  derivWithin (P r) (Set.Icc (-1) 1) x
end FiveInduction.SOSGeometry


/-!
The literal squared-modulus angular profile of the actual entire theta.
Only nonnegativity, continuity, and interior differentiability are retained.
-/

set_option autoImplicit false
noncomputable section
namespace FiveInduction.SOSGeometry

def actualProfile : ℝ → ℝ → ℝ := angularNormSq theta

theorem actualProfile_nonnegative_all (r x : ℝ) : 0 ≤ actualProfile r x :=
  Complex.normSq_nonneg _

theorem actualProfile_continuous (r : ℝ) : Continuous (actualProfile r) :=
  Complex.continuous_normSq.comp
    (theta_continuous.comp (continuous_circlePoint r))

theorem actualProfile_interior_differentiable :
    ∀ r : ℝ, 0 < r → DifferentiableOn ℝ (actualProfile r) (Set.Ioo (-1) 1) := by
  intro r hr x hx
  rcases hx with ⟨hx0, hx1⟩
  have hinside : 0 < 1 - x ^ 2 := by
    nlinarith [mul_pos (by linarith : 0 < 1 - x) (by linarith : 0 < 1 + x)]
  have hsqrt : DifferentiableAt ℝ (fun y : ℝ => Real.sqrt (1 - y ^ 2)) x :=
    (differentiableAt_const (1 : ℝ) |>.sub (differentiableAt_id.pow 2)).sqrt
      (ne_of_gt hinside)
  have hcircle : DifferentiableAt ℝ (circlePoint r) x := by
    unfold circlePoint
    fun_prop
  have ht : DifferentiableAt ℝ (fun y => theta (circlePoint r y)) x :=
    ((theta_differentiable (circlePoint r x)).restrictScalars ℝ).comp x hcircle
  have hre : DifferentiableAt ℝ (fun y => (theta (circlePoint r y)).re) x := by
    fun_prop
  have him : DifferentiableAt ℝ (fun y => (theta (circlePoint r y)).im) x := by
    fun_prop
  change DifferentiableWithinAt ℝ
    (fun y => Complex.normSq (theta (circlePoint r y))) (Set.Ioo (-1) 1) x
  have hd : DifferentiableAt ℝ
      (fun y => Complex.normSq (theta (circlePoint r y))) x := by
    simp only [Complex.normSq_apply]
    fun_prop
  exact hd.differentiableWithinAt

end FiveInduction.SOSGeometry


/-!
# Local angular positivity and zero exclusion

This module localizes the existing angular zero-exclusion argument from
`[-1, 1]` to `[a, 1]`. The actual-theta application retains angular positivity
as an explicit hypothesis; it assumes neither RH nor a zero-product identity.
-/

noncomputable section
open Set
open scoped ComplexConjugate

namespace FiveInduction.SOSGeometry

/-- On an increasing squared-modulus arc, a zero cannot occur strictly to the
right of the left endpoint. The proof uses an arc of zeros and analyticity. -/
theorem circle_ne_zero_of_angular_monotone_cutoff {f : ℂ → ℂ}
    (hf : AnalyticOnNhd ℂ f univ) (hne : ∃ w, f w ≠ 0)
    {a r x : ℝ} (hr : 0 < r) (hax : a < x) (hx1 : x ≤ 1)
    (hm : MonotoneOn (angularNormSq f r) (Icc a 1)) :
    f (circlePoint r x) ≠ 0 := by
  intro hz
  have harc : ∀ y ∈ Icc a x, f (circlePoint r y) = 0 := by
    intro y hy
    have hle := hm ⟨hy.1, hy.2.trans hx1⟩ ⟨hax.le, hx1⟩ hy.2
    have hnorm : angularNormSq f r x = 0 := by
      simp [angularNormSq, hz]
    rw [hnorm] at hle
    exact Complex.normSq_eq_zero.mp
      (le_antisymm hle (Complex.normSq_nonneg _))
  have hzero := entire_eq_zero_of_zero_arc hf (continuous_circlePoint r)
    (injective_circlePoint (ne_of_gt hr)) hax harc
  obtain ⟨w, hw⟩ := hne
  exact hw (by rw [hzero]; rfl)

/-- A localized angular monotonicity certificate excludes zeros in the full
conjugation-symmetric sector `a < re z / ‖z‖`. -/
theorem ne_zero_of_angular_monotone_cutoff {f : ℂ → ℂ}
    (hf : AnalyticOnNhd ℂ f univ) (hne : ∃ w, f w ≠ 0)
    (hconj : ∀ z, f z = 0 → f (conj z) = 0)
    {a : ℝ}
    (hm : ∀ r : ℝ, 0 < r → MonotoneOn (angularNormSq f r) (Icc a 1))
    {z : ℂ} (hz0 : z ≠ 0) (hx : a < z.re / ‖z‖) :
    f z ≠ 0 := by
  have hupper : ∀ w : ℂ, w ≠ 0 → 0 ≤ w.im →
      a < w.re / ‖w‖ → f w ≠ 0 := by
    intro w hw0 hwi hwx
    have hn : 0 < ‖w‖ := norm_pos_iff.mpr hw0
    have hx1 : w.re / ‖w‖ ≤ 1 := by
      apply (div_le_iff₀ hn).mpr
      simpa using (abs_le.mp (Complex.abs_re_le_norm w)).2
    have hnv := circle_ne_zero_of_angular_monotone_cutoff hf hne hn hwx hx1
      (hm ‖w‖ hn)
    rw [circlePoint_norm_re_div hw0 hwi] at hnv
    exact hnv
  by_cases hi : 0 ≤ z.im
  · exact hupper z hz0 hi hx
  · intro hz
    have hcz0 : conj z ≠ 0 := by
      intro h
      apply hz0
      have hc := congrArg conj h
      simpa using hc
    have hci : 0 ≤ (conj z).im := by
      simp only [Complex.conj_im]
      linarith
    have hcx : a < (conj z).re / ‖conj z‖ := by
      simpa using hx
    exact hupper (conj z) hcz0 hci hcx (hconj z hz)

/-- The original actual angular derivative is nonnegative above a cutoff.
Only interior angles are required; no endpoint derivative hypothesis is used. -/
def CutoffDerivativeNonnegative (a : ℝ) : Prop :=
  ∀ r : ℝ, 0 < r → ∀ x ∈ Ioo a 1,
    0 ≤ angularDerivative actualProfile r x

/-- Actual interior derivative positivity supplies monotonicity on `[a,1]`.
Continuity at the endpoints comes from the existing entire-theta construction. -/
theorem actualProfile_monotoneOn_cutoff {a : ℝ}
    (ha : -1 ≤ a) (hderiv : CutoffDerivativeNonnegative a)
    (r : ℝ) (hr : 0 < r) :
    MonotoneOn (actualProfile r) (Icc a 1) := by
  have hint : DifferentiableOn ℝ (actualProfile r) (Ioo a 1) := by
    apply (actualProfile_interior_differentiable r hr).mono
    intro x hx
    exact ⟨lt_of_le_of_lt ha hx.1, hx.2⟩
  apply monotoneOn_of_deriv_nonneg (convex_Icc a 1)
    (actualProfile_continuous r).continuousOn
  · simpa only [interior_Icc] using hint
  · intro x hx
    have hxcut : x ∈ Ioo a 1 := by
      simpa only [interior_Icc] using hx
    have hxglobal : x ∈ Ioo (-1 : ℝ) 1 :=
      ⟨lt_of_le_of_lt ha hxcut.1, hxcut.2⟩
    have hd := hderiv r hr x hxcut
    change 0 ≤ derivWithin (actualProfile r) (Icc (-1) 1) x at hd
    rw [derivWithin_of_mem_nhds (Icc_mem_nhds hxglobal.1 hxglobal.2)] at hd
    exact hd

/-- Conditional zero exclusion for the actual Mathlib-backed theta on both
halves of the angular sector. Positivity is the sole research hypothesis. -/
theorem actual_theta_ne_zero_of_angular_cutoff {a : ℝ}
    (ha : -1 ≤ a) (hderiv : CutoffDerivativeNonnegative a)
    {z : ℂ} (hz0 : z ≠ 0) (hx : a < z.re / ‖z‖) :
    theta z ≠ 0 := by
  exact ne_zero_of_angular_monotone_cutoff theta_entire
    ⟨1, theta_one_ne_zero⟩ (fun z hz => theta_zero_conj hz)
    (actualProfile_monotoneOn_cutoff ha hderiv) hz0 hx

end FiveInduction.SOSGeometry
