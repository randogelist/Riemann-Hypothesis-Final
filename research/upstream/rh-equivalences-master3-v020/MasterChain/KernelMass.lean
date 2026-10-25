import MasterChain.AnalyticBridges
import MasterChain.Chain
import MasterChain.DensityL2
import Mathlib.MeasureTheory.Integral.Prod
import MasterChain.LaplaceKernel
import MasterChain.DivisorCountability

/-!
# Positive kernel integrability and interchange

The pointwise one-dimensional Laplace calculation and an integrable defect
kernel imply product integrability. Fubini then proves the native kernel-mass
identity. The global identity is not an input.

The scalar section calculation and the SFinite divisor property are supplied
by independently proved modules. The final native theorem requires only the
integrability of the reciprocal-height second moment.
-/

set_option autoImplicit false

noncomputable section

open MeasureTheory Set

namespace MasterChain

instance positiveLebesgue_sfinite : SFinite positiveLebesgue := by
  unfold positiveLebesgue
  infer_instance

/-- Nonnegative sections with an integrable scalar mass determine an
integrable product kernel. This proves the hypothesis needed by Fubini. -/
theorem integrable_positive_kernel_of_section_masses
    {α β : Type*} [MeasurableSpace α] [MeasurableSpace β]
    {μ : Measure α} {ν : Measure β} [SFinite ν]
    {K : α → β → ℝ} {W : α → ℝ}
    (hMeas : AEStronglyMeasurable (Function.uncurry K) (μ.prod ν))
    (hNonneg : ∀ᵐ s ∂μ, ∀ᵐ v ∂ν, 0 ≤ K s v)
    (hSections : ∀ᵐ s ∂μ, Integrable (K s) ν)
    (hValues : ∀ᵐ s ∂μ, (∫ v, K s v ∂ν) = W s)
    (hW : Integrable W μ) :
    Integrable (Function.uncurry K) (μ.prod ν) := by
  apply (integrable_prod_iff hMeas).mpr
  refine ⟨hSections, hW.congr ?_⟩
  filter_upwards [hNonneg, hValues] with s hNs hVs
  change W s = ∫ v, ‖K s v‖ ∂ν
  rw [← hVs]
  apply integral_congr_ae
  filter_upwards [hNs] with v hv
  exact (Real.norm_of_nonneg hv).symm

/-- Fubini after product integrability has been obtained from positive section
masses, rather than assumed as a conclusion-shaped premise. -/
theorem integral_mass_eq_swapped_positive_kernel
    {α β : Type*} [MeasurableSpace α] [MeasurableSpace β]
    {μ : Measure α} {ν : Measure β} [SFinite μ] [SFinite ν]
    {K : α → β → ℝ} {W : α → ℝ}
    (hMeas : AEStronglyMeasurable (Function.uncurry K) (μ.prod ν))
    (hNonneg : ∀ᵐ s ∂μ, ∀ᵐ v ∂ν, 0 ≤ K s v)
    (hSections : ∀ᵐ s ∂μ, Integrable (K s) ν)
    (hValues : ∀ᵐ s ∂μ, (∫ v, K s v ∂ν) = W s)
    (hW : Integrable W μ) :
    (∫ s, W s ∂μ) = ∫ v, (∫ s, K s v ∂μ) ∂ν := by
  have hProd := integrable_positive_kernel_of_section_masses
    hMeas hNonneg hSections hValues hW
  calc
    (∫ s, W s ∂μ) = ∫ s, (∫ v, K s v ∂ν) ∂μ :=
      integral_congr_ae (hValues.mono fun s hs => hs.symm)
    _ = ∫ v, (∫ s, K s v ∂μ) ∂ν := integral_integral_swap hProd

/-- The actual positive two-variable density kernel, including its `2*v` factor. -/
def nativeLaplaceKernel (s : ℂ) (v : ℝ) : ℝ :=
  2 * v * Real.exp (-height s * v) * Real.sin (displacement s * v / 2) ^ 2

theorem nativeLaplaceKernel_continuous :
    Continuous (Function.uncurry nativeLaplaceKernel) := by
  unfold nativeLaplaceKernel Function.uncurry height displacement
  fun_prop

theorem nativeLaplaceKernel_nonneg (s : ℂ) {v : ℝ} (hv : 0 ≤ v) :
    0 ≤ nativeLaplaceKernel s v := by
  unfold nativeLaplaceKernel
  exact mul_nonneg (mul_nonneg (mul_nonneg (by norm_num) hv)
    (Real.exp_pos _).le) (sq_nonneg _)

theorem nativeLaplaceKernel_nonneg_ae (s : ℂ) :
    ∀ᵐ v ∂positiveLebesgue, 0 ≤ nativeLaplaceKernel s v := by
  filter_upwards [ae_restrict_mem measurableSet_Ioi] with v hv
  exact nativeLaplaceKernel_nonneg s (le_of_lt hv)

theorem height_pos_ae_xiDivisor :
    ∀ᵐ s ∂xiDivisorMeasure, 0 < height s := by
  have hH : MeasurableSet H :=
    (isOpen_lt continuous_const Complex.continuous_im).measurableSet
  exact ae_restrict_mem hH

/-- Pulling out the scalar `2*v` is an unconditional Bochner normalization. -/
theorem A_eq_integral_nativeLaplaceKernel (v : ℝ) :
    A v = ∫ s, nativeLaplaceKernel s v ∂xiDivisorMeasure := by
  symm
  simpa only [A, nativeLaplaceKernel, mul_assoc] using
    (integral_const_mul (2 * v) (fun s : ℂ =>
      Real.exp (-height s * v) * Real.sin (displacement s * v / 2) ^ 2)
        (μ := xiDivisorMeasure))

/-- Product integrability follows from the scalar Laplace theorem and an
integrable native defect. No density-integrability premise is needed. -/
theorem nativeLaplaceKernel_integrable_of_scalar_sections
    (hDefect : Integrable defectKernel xiDivisorMeasure)
    (hSections : ∀ s : ℂ, 0 < height s →
      Integrable (nativeLaplaceKernel s) positiveLebesgue)
    (hValues : ∀ s : ℂ, 0 < height s →
      (∫ v, nativeLaplaceKernel s v ∂positiveLebesgue) = defectKernel s) :
    Integrable (Function.uncurry nativeLaplaceKernel)
      (xiDivisorMeasure.prod positiveLebesgue) := by
  apply integrable_positive_kernel_of_section_masses
    nativeLaplaceKernel_continuous.aestronglyMeasurable
    (Filter.Eventually.of_forall nativeLaplaceKernel_nonneg_ae)
    (height_pos_ae_xiDivisor.mono fun s hs => hSections s hs)
    (height_pos_ae_xiDivisor.mono fun s hs => hValues s hs) hDefect

/-- The native kernel-mass identity obtained by a checked change of integration
order. Scalar section identities are the remaining one-dimensional input. -/
theorem kernelMassIdentity_of_scalar_sections
    [SFinite xiDivisorMeasure]
    (hDefect : Integrable defectKernel xiDivisorMeasure)
    (hSections : ∀ s : ℂ, 0 < height s →
      Integrable (nativeLaplaceKernel s) positiveLebesgue)
    (hValues : ∀ s : ℂ, 0 < height s →
      (∫ v, nativeLaplaceKernel s v ∂positiveLebesgue) = defectKernel s) :
    KernelMassIdentity := by
  change (∫ s, defectKernel s ∂xiDivisorMeasure) =
    ∫ v, A v ∂positiveLebesgue
  calc
    (∫ s, defectKernel s ∂xiDivisorMeasure) =
        ∫ v, (∫ s, nativeLaplaceKernel s v ∂xiDivisorMeasure) ∂positiveLebesgue :=
      integral_mass_eq_swapped_positive_kernel
        nativeLaplaceKernel_continuous.aestronglyMeasurable
        (Filter.Eventually.of_forall nativeLaplaceKernel_nonneg_ae)
        (height_pos_ae_xiDivisor.mono fun s hs => hSections s hs)
        (height_pos_ae_xiDivisor.mono fun s hs => hValues s hs) hDefect
    _ = ∫ v, A v ∂positiveLebesgue := by
      apply integral_congr_ae
      exact Filter.Eventually.of_forall fun v =>
        (A_eq_integral_nativeLaplaceKernel v).symm

/-- The same hypotheses also discharge the native density-integrability field. -/
theorem density_integrable_of_scalar_sections
    [SFinite xiDivisorMeasure]
    (hDefect : Integrable defectKernel xiDivisorMeasure)
    (hSections : ∀ s : ℂ, 0 < height s →
      Integrable (nativeLaplaceKernel s) positiveLebesgue)
    (hValues : ∀ s : ℂ, 0 < height s →
      (∫ v, nativeLaplaceKernel s v ∂positiveLebesgue) = defectKernel s) :
    Integrable A positiveLebesgue := by
  have hProd := nativeLaplaceKernel_integrable_of_scalar_sections
    hDefect hSections hValues
  apply hProd.integral_prod_right.congr
  exact Filter.Eventually.of_forall fun v =>
    (A_eq_integral_nativeLaplaceKernel v).symm

/-- The native scalar sections are integrable by the one-dimensional theorem. -/
theorem nativeLaplaceKernel_section_integrable (s : ℂ) (hs : 0 < height s) :
    Integrable (nativeLaplaceKernel s) positiveLebesgue := by
  change Integrable
    (fun v : ℝ => 2 * v * Real.exp (-height s * v) *
      Real.sin (displacement s * v / 2) ^ 2) (volume.restrict (Ioi 0))
  exact laplace_kernel_integrable (displacement s) (height s) hs

/-- The native scalar section mass is the independently defined rational defect. -/
theorem nativeLaplaceKernel_section_mass (s : ℂ) (hs : 0 < height s) :
    (∫ v, nativeLaplaceKernel s v ∂positiveLebesgue) = defectKernel s := by
  simpa only [nativeLaplaceKernel, positiveLebesgue,
    defectKernel_eq_defectValue] using
    integral_laplace_kernel (displacement s) (height s) hs

/-- The actual kernel-mass identity from integrability of the actual defect.
No scalar-identity or sigma-finiteness hypothesis remains. -/
theorem kernelMassIdentity_of_defect_integrable
    (hDefect : Integrable defectKernel xiDivisorMeasure) : KernelMassIdentity :=
  kernelMassIdentity_of_scalar_sections hDefect
    nativeLaplaceKernel_section_integrable nativeLaplaceKernel_section_mass

theorem density_integrable_of_defect_integrable
    (hDefect : Integrable defectKernel xiDivisorMeasure) :
    Integrable A positiveLebesgue :=
  density_integrable_of_scalar_sections hDefect
    nativeLaplaceKernel_section_integrable nativeLaplaceKernel_section_mass

/-- The rational kernel is measurable even at the totalized denominator zeros. -/
theorem defectKernel_measurable : Measurable defectKernel := by
  unfold defectKernel displacement height
  fun_prop

/-- The universal 9/8 envelope transfers reciprocal-second-moment integrability
to defect integrability. No strip-width or RH assumption is used. -/
theorem defect_integrable_of_second_moment
    (hMoment : Integrable (fun s : ℂ => (height s ^ 2)⁻¹) xiDivisorMeasure) :
    Integrable defectKernel xiDivisorMeasure := by
  have hBound := hMoment.const_mul (9 / 8 : ℝ)
  apply hBound.mono' defectKernel_measurable.aestronglyMeasurable
  filter_upwards [height_pos_ae_xiDivisor] with s hs
  rw [Real.norm_of_nonneg (defectKernel_nonneg s)]
  exact defectKernel_le_nine_eighths hs

/-- Native Tonelli/Laplace kernel-mass bridge with one explicit convergence input. -/
theorem kernelMassIdentity_of_second_moment
    (hMoment : Integrable (fun s : ℂ => (height s ^ 2)⁻¹) xiDivisorMeasure) :
    KernelMassIdentity :=
  kernelMassIdentity_of_defect_integrable (defect_integrable_of_second_moment hMoment)

/-- The same convergence input proves native density integrability. -/
theorem density_integrable_of_second_moment
    (hMoment : Integrable (fun s : ℂ => (height s ^ 2)⁻¹) xiDivisorMeasure) :
    Integrable A positiveLebesgue :=
  density_integrable_of_defect_integrable (defect_integrable_of_second_moment hMoment)

/-- Product integrability is also obtained, for use in subsequent transforms. -/
theorem nativeLaplaceKernel_integrable_of_second_moment
    (hMoment : Integrable (fun s : ℂ => (height s ^ 2)⁻¹) xiDivisorMeasure) :
    Integrable (Function.uncurry nativeLaplaceKernel)
      (xiDivisorMeasure.prod positiveLebesgue) :=
  nativeLaplaceKernel_integrable_of_scalar_sections
    (defect_integrable_of_second_moment hMoment)
    nativeLaplaceKernel_section_integrable nativeLaplaceKernel_section_mass

/-- The actual RR mass is the genuine L2 norm squared of its square-root
density. Identification with the separate GP norm still requires Plancherel. -/
theorem C_RR_eq_densityL2_norm_sq_of_second_moment
    (hMoment : Integrable (fun s : ℂ => (height s ^ 2)⁻¹) xiDivisorMeasure) :
    C_RR = ‖densityL2 MasterChain.A_nonneg_ae (density_integrable_of_second_moment hMoment)‖ ^ 2 := by
  calc
    C_RR = densityMass := kernelMassIdentity_of_second_moment hMoment
    _ = ‖densityL2 MasterChain.A_nonneg_ae (density_integrable_of_second_moment hMoment)‖ ^ 2 :=
      (norm_densityL2_sq MasterChain.A_nonneg_ae (density_integrable_of_second_moment hMoment)).symm

end MasterChain
