import AWPI.PhiRH.JetLeafDisassembly
import Mathlib.Analysis.SpecialFunctions.Pow.Asymptotics

namespace AWPI.PhiRH.TailDecayDisassembly

open AWPI.PhiRH
open AWPI.PhiRH.MathlibBridge
open AWPI.PhiRH.RocqPortModel
open AWPI.PhiRH.JetLeafDisassembly
open Filter

/-- Rocq alternating sign used by the literal Phi cells. -/
def altSign : ℕ → ℝ
  | 0 => 1
  | n + 1 => - altSign n

/-- Literal Phi base `2*n + u + 1`. -/
def phiBase (n : ℕ) (u : ℝ) : ℝ :=
  2 * (n : ℝ) + u + 1

/-- Real coordinate of the literal Phi kernel. -/
noncomputable def phiKernelRe (sigma tau x : ℝ) : ℝ :=
  x ^ (-sigma) * Real.cos (tau * Real.log x)

/-- Imaginary coordinate of the literal Phi kernel. -/
noncomputable def phiKernelIm (sigma tau x : ℝ) : ℝ :=
  -(x ^ (-sigma) * Real.sin (tau * Real.log x))

/-- Literal finite Phi cell, real coordinate. -/
noncomputable def phiCellRe (n : ℕ) (u sigma tau : ℝ) : ℝ :=
  4 * altSign n * phiKernelRe sigma tau (phiBase n u)

/-- Literal finite Phi cell, imaginary coordinate. -/
noncomputable def phiCellIm (n : ℕ) (u sigma tau : ℝ) : ℝ :=
  4 * altSign n * phiKernelIm sigma tau (phiBase n u)

/-- Literal finite Phi prefix, real coordinate. -/
noncomputable def phiPrefixRe : ℕ → ℝ → ℝ → ℝ → ℝ
  | 0, _, _, _ => 0
  | n + 1, u, sigma, tau =>
      phiPrefixRe n u sigma tau + phiCellRe n u sigma tau

/-- Literal finite Phi prefix, imaginary coordinate. -/
noncomputable def phiPrefixIm : ℕ → ℝ → ℝ → ℝ → ℝ
  | 0, _, _, _ => 0
  | n + 1, u, sigma, tau =>
      phiPrefixIm n u sigma tau + phiCellIm n u sigma tau

/-- Finite real shift residual from the Rocq Phi chain. -/
noncomputable def finitePhiShiftResidualRe
    (N : ℕ) (u sigma tau : ℝ) : ℝ :=
  phiPrefixRe N u sigma tau + phiPrefixRe N (u + 2) sigma tau -
    4 * phiKernelRe sigma tau (u + 1)

/-- Finite imaginary shift residual from the Rocq Phi chain. -/
noncomputable def finitePhiShiftResidualIm
    (N : ℕ) (u sigma tau : ℝ) : ℝ :=
  phiPrefixIm N u sigma tau + phiPrefixIm N (u + 2) sigma tau -
    4 * phiKernelIm sigma tau (u + 1)

@[simp] theorem abs_altSign (n : ℕ) : |altSign n| = (1 : ℝ) := by
  induction n with
  | zero => simp [altSign]
  | succ n ih => simp [altSign, ih]

theorem phiBase_shift (n : ℕ) (u : ℝ) :
    phiBase n (u + 2) = phiBase (n + 1) u := by
  simp [phiBase, Nat.cast_add, Nat.cast_one]
  ring

theorem phiCellRe_shift (n : ℕ) (u sigma tau : ℝ) :
    phiCellRe n (u + 2) sigma tau = -phiCellRe (n + 1) u sigma tau := by
  unfold phiCellRe
  rw [phiBase_shift]
  simp [altSign]

theorem phiCellIm_shift (n : ℕ) (u sigma tau : ℝ) :
    phiCellIm n (u + 2) sigma tau = -phiCellIm (n + 1) u sigma tau := by
  unfold phiCellIm
  rw [phiBase_shift]
  simp [altSign]

theorem phiPrefixRe_shift_telescopes (N : ℕ) (u sigma tau : ℝ) :
    phiPrefixRe N u sigma tau + phiPrefixRe N (u + 2) sigma tau =
      phiCellRe 0 u sigma tau - phiCellRe N u sigma tau := by
  induction N with
  | zero => simp [phiPrefixRe]
  | succ n ih =>
      simp only [phiPrefixRe]
      rw [phiCellRe_shift]
      calc
        (phiPrefixRe n u sigma tau + phiCellRe n u sigma tau) +
            (phiPrefixRe n (u + 2) sigma tau + -phiCellRe (n + 1) u sigma tau) =
            (phiPrefixRe n u sigma tau + phiPrefixRe n (u + 2) sigma tau) +
              phiCellRe n u sigma tau - phiCellRe (n + 1) u sigma tau := by ring
        _ = phiCellRe 0 u sigma tau - phiCellRe (n + 1) u sigma tau := by
          rw [ih]
          ring

theorem phiPrefixIm_shift_telescopes (N : ℕ) (u sigma tau : ℝ) :
    phiPrefixIm N u sigma tau + phiPrefixIm N (u + 2) sigma tau =
      phiCellIm 0 u sigma tau - phiCellIm N u sigma tau := by
  induction N with
  | zero => simp [phiPrefixIm]
  | succ n ih =>
      simp only [phiPrefixIm]
      rw [phiCellIm_shift]
      calc
        (phiPrefixIm n u sigma tau + phiCellIm n u sigma tau) +
            (phiPrefixIm n (u + 2) sigma tau + -phiCellIm (n + 1) u sigma tau) =
            (phiPrefixIm n u sigma tau + phiPrefixIm n (u + 2) sigma tau) +
              phiCellIm n u sigma tau - phiCellIm (n + 1) u sigma tau := by ring
        _ = phiCellIm 0 u sigma tau - phiCellIm (n + 1) u sigma tau := by
          rw [ih]
          ring

theorem phiCellRe_zero (u sigma tau : ℝ) :
    phiCellRe 0 u sigma tau = 4 * phiKernelRe sigma tau (u + 1) := by
  simp [phiCellRe, altSign, phiBase]

theorem phiCellIm_zero (u sigma tau : ℝ) :
    phiCellIm 0 u sigma tau = 4 * phiKernelIm sigma tau (u + 1) := by
  simp [phiCellIm, altSign, phiBase]

@[simp] theorem finitePhiShiftResidualRe_eq_neg_terminal
    (N : ℕ) (u sigma tau : ℝ) :
    finitePhiShiftResidualRe N u sigma tau = -phiCellRe N u sigma tau := by
  unfold finitePhiShiftResidualRe
  rw [phiPrefixRe_shift_telescopes, phiCellRe_zero]
  ring

@[simp] theorem finitePhiShiftResidualIm_eq_neg_terminal
    (N : ℕ) (u sigma tau : ℝ) :
    finitePhiShiftResidualIm N u sigma tau = -phiCellIm N u sigma tau := by
  unfold finitePhiShiftResidualIm
  rw [phiPrefixIm_shift_telescopes, phiCellIm_zero]
  ring

/-- Canonical `u = 1` real Phi residual. -/
noncomputable def actualResidualRe (N : ℕ) (sigma tau : ℝ) : ℝ :=
  finitePhiShiftResidualRe N 1 sigma tau

/-- Canonical `u = 1` imaginary Phi residual. -/
noncomputable def actualResidualIm (N : ℕ) (sigma tau : ℝ) : ℝ :=
  finitePhiShiftResidualIm N 1 sigma tau

/-- Literal normalized KQ source pair: dyadic unit rotation of the actual Phi residual. -/
noncomputable def actualKQSourcePair (N : ℕ) (sigma tau : ℝ) : C2 :=
  c2Mul (normalizedDyadicMultiplier sigma tau)
    (actualResidualRe N sigma tau, actualResidualIm N sigma tau)

noncomputable def actualKQPlusSource (N : ℕ) (sigma tau : ℝ) : ℝ :=
  (actualKQSourcePair N sigma tau).1

noncomputable def actualKQMinusSource (N : ℕ) (sigma tau : ℝ) : ℝ :=
  (actualKQSourcePair N sigma tau).2

/-- At canonical shift `u = 1`, the Phi base escapes to `+∞`. -/
theorem phiBase_one_tendsto_atTop :
    Tendsto (fun n : ℕ => phiBase n 1) atTop atTop := by
  refine Filter.tendsto_atTop_mono (f := fun n : ℕ => (n : ℝ)) ?_ tendsto_natCast_atTop_atTop
  intro n
  have hn : (0 : ℝ) ≤ (n : ℝ) := by positivity
  simp only [phiBase]
  nlinarith

/-- Positive real exponent gives radial Phi-kernel decay. -/
theorem phiRadial_one_tendsto_zero
    (sigma : ℝ) (hsigma : 0 < sigma) :
    Tendsto (fun n : ℕ => (phiBase n 1) ^ (-sigma))
      atTop (nhds (0 : ℝ)) := by
  change Tendsto
    ((fun x : ℝ => x ^ (-sigma)) ∘ (fun n : ℕ => phiBase n 1))
    atTop (nhds (0 : ℝ))
  exact (tendsto_rpow_neg_atTop hsigma).comp phiBase_one_tendsto_atTop

/-- Uniform real terminal-cell bound by the radial factor. -/
theorem norm_phiCellRe_le_radial
    (n : ℕ) (sigma tau : ℝ) :
    ‖phiCellRe n 1 sigma tau‖ ≤
      4 * (phiBase n 1) ^ (-sigma) := by
  have hbase : 0 < phiBase n 1 := by
    simp [phiBase]
    positivity
  have hp : 0 ≤ (phiBase n 1) ^ (-sigma) :=
    (Real.rpow_pos_of_pos hbase _).le
  have hc : |Real.cos (tau * Real.log (phiBase n 1))| ≤ (1 : ℝ) :=
    Real.abs_cos_le_one _
  have hfac : 0 ≤ 4 * (phiBase n 1) ^ (-sigma) := by positivity
  rw [Real.norm_eq_abs]
  calc
    |phiCellRe n 1 sigma tau| =
        (4 * (phiBase n 1) ^ (-sigma)) *
          |Real.cos (tau * Real.log (phiBase n 1))| := by
            simp [phiCellRe, phiKernelRe, abs_mul, abs_altSign,
              abs_of_nonneg hp, mul_assoc]
    _ ≤ (4 * (phiBase n 1) ^ (-sigma)) * 1 :=
      mul_le_mul_of_nonneg_left hc hfac
    _ = 4 * (phiBase n 1) ^ (-sigma) := by ring

/-- Uniform imaginary terminal-cell bound by the same radial factor. -/
theorem norm_phiCellIm_le_radial
    (n : ℕ) (sigma tau : ℝ) :
    ‖phiCellIm n 1 sigma tau‖ ≤
      4 * (phiBase n 1) ^ (-sigma) := by
  have hbase : 0 < phiBase n 1 := by
    simp [phiBase]
    positivity
  have hp : 0 ≤ (phiBase n 1) ^ (-sigma) :=
    (Real.rpow_pos_of_pos hbase _).le
  have hs : |Real.sin (tau * Real.log (phiBase n 1))| ≤ (1 : ℝ) :=
    Real.abs_sin_le_one _
  have hfac : 0 ≤ 4 * (phiBase n 1) ^ (-sigma) := by positivity
  rw [Real.norm_eq_abs]
  calc
    |phiCellIm n 1 sigma tau| =
        (4 * (phiBase n 1) ^ (-sigma)) *
          |Real.sin (tau * Real.log (phiBase n 1))| := by
            simp [phiCellIm, phiKernelIm, abs_mul, abs_neg, abs_altSign,
              abs_of_nonneg hp, mul_assoc]
    _ ≤ (4 * (phiBase n 1) ^ (-sigma)) * 1 :=
      mul_le_mul_of_nonneg_left hs hfac
    _ = 4 * (phiBase n 1) ^ (-sigma) := by ring

theorem phiCellRe_one_tendsto_zero
    (sigma tau : ℝ) (hsigma : 0 < sigma) :
    Tendsto (fun n : ℕ => phiCellRe n 1 sigma tau)
      atTop (nhds (0 : ℝ)) := by
  apply squeeze_zero_norm
  · intro n
    exact norm_phiCellRe_le_radial n sigma tau
  · have hrad := phiRadial_one_tendsto_zero sigma hsigma
    simpa using tendsto_const_nhds.mul hrad

theorem phiCellIm_one_tendsto_zero
    (sigma tau : ℝ) (hsigma : 0 < sigma) :
    Tendsto (fun n : ℕ => phiCellIm n 1 sigma tau)
      atTop (nhds (0 : ℝ)) := by
  apply squeeze_zero_norm
  · intro n
    exact norm_phiCellIm_le_radial n sigma tau
  · have hrad := phiRadial_one_tendsto_zero sigma hsigma
    simpa using tendsto_const_nhds.mul hrad

theorem actualResidualRe_tendsto_zero
    (sigma tau : ℝ) (hsigma : 0 < sigma) :
    Tendsto (fun n : ℕ => actualResidualRe n sigma tau)
      atTop (nhds (0 : ℝ)) := by
  simpa [actualResidualRe] using (phiCellRe_one_tendsto_zero sigma tau hsigma).neg

theorem actualResidualIm_tendsto_zero
    (sigma tau : ℝ) (hsigma : 0 < sigma) :
    Tendsto (fun n : ℕ => actualResidualIm n sigma tau)
      atTop (nhds (0 : ℝ)) := by
  simpa [actualResidualIm] using (phiCellIm_one_tendsto_zero sigma tau hsigma).neg

/-- The literal plus KQ source tends to zero for every positive real exponent. -/
theorem actualKQPlusSource_tendsto_zero
    (sigma tau : ℝ) (hsigma : 0 < sigma) :
    Tendsto (fun n : ℕ => actualKQPlusSource n sigma tau)
      atTop (nhds (0 : ℝ)) := by
  have hre := actualResidualRe_tendsto_zero sigma tau hsigma
  have him := actualResidualIm_tendsto_zero sigma tau hsigma
  have hcos : Tendsto (fun _ : ℕ => Real.cos (dyadicPhase tau)) atTop
      (nhds (Real.cos (dyadicPhase tau))) := tendsto_const_nhds
  have hnegSin : Tendsto (fun _ : ℕ => -Real.sin (dyadicPhase tau)) atTop
      (nhds (-Real.sin (dyadicPhase tau))) := tendsto_const_nhds
  have h1 : Tendsto
      (fun n : ℕ => Real.cos (dyadicPhase tau) * actualResidualRe n sigma tau)
      atTop (nhds (0 : ℝ)) := by
    simpa using hcos.mul hre
  have h2 : Tendsto
      (fun n : ℕ => (-Real.sin (dyadicPhase tau)) * actualResidualIm n sigma tau)
      atTop (nhds (0 : ℝ)) := by
    simpa using hnegSin.mul him
  simpa [actualKQPlusSource, actualKQSourcePair, c2Mul,
    normalizedDyadicMultiplier] using h1.sub h2

/-- The literal minus KQ source tends to zero for every positive real exponent. -/
theorem actualKQMinusSource_tendsto_zero
    (sigma tau : ℝ) (hsigma : 0 < sigma) :
    Tendsto (fun n : ℕ => actualKQMinusSource n sigma tau)
      atTop (nhds (0 : ℝ)) := by
  have hre := actualResidualRe_tendsto_zero sigma tau hsigma
  have him := actualResidualIm_tendsto_zero sigma tau hsigma
  have hcos : Tendsto (fun _ : ℕ => Real.cos (dyadicPhase tau)) atTop
      (nhds (Real.cos (dyadicPhase tau))) := tendsto_const_nhds
  have hnegSin : Tendsto (fun _ : ℕ => -Real.sin (dyadicPhase tau)) atTop
      (nhds (-Real.sin (dyadicPhase tau))) := tendsto_const_nhds
  have h1 : Tendsto
      (fun n : ℕ => Real.cos (dyadicPhase tau) * actualResidualIm n sigma tau)
      atTop (nhds (0 : ℝ)) := by
    simpa using hcos.mul him
  have h2 : Tendsto
      (fun n : ℕ => (-Real.sin (dyadicPhase tau)) * actualResidualRe n sigma tau)
      atTop (nhds (0 : ℝ)) := by
    simpa using hnegSin.mul hre
  simpa [actualKQMinusSource, actualKQSourcePair, c2Mul,
    normalizedDyadicMultiplier, add_comm] using h1.add h2

/-- A real sequence tending to zero has its literal square eventually below
    every positive epsilon. -/
theorem square_eventually_le_of_tendsto_zero
    (f : ℕ → ℝ)
    (hf : Tendsto f atTop (nhds (0 : ℝ)))
    (eps : ℝ) (heps : 0 < eps) :
    ∃ N : ℕ, ∀ n : ℕ, N ≤ n → f n * f n ≤ eps := by
  have hsq : Tendsto (fun n : ℕ => f n * f n) atTop (nhds (0 : ℝ)) := by
    simpa using hf.mul hf
  have hev : ∀ᶠ n : ℕ in atTop, f n * f n < eps :=
    hsq.eventually (Iio_mem_nhds heps)
  rcases (eventually_atTop.1 hev) with ⟨N, hN⟩
  exact ⟨N, fun n hn => le_of_lt (hN n hn)⟩

/-- The old joint two-sided KQ tail-decay leaf is kernel-derived from the
    single lower analytic fact `0 < rho.re`. -/
theorem jointTailDecay_of_positiveRealPart
    (rho : ℂ) (positiveRealPart : 0 < rho.re)
    (eps : ℝ) (heps : 0 < eps) :
    ∃ n : ℕ,
      actualKQPlusSource n rho.re rho.im *
          actualKQPlusSource n rho.re rho.im ≤ eps ∧
      actualKQMinusSource n rho.re rho.im *
          actualKQMinusSource n rho.re rho.im ≤ eps := by
  rcases square_eventually_le_of_tendsto_zero
      (fun n : ℕ => actualKQPlusSource n rho.re rho.im)
      (actualKQPlusSource_tendsto_zero rho.re rho.im positiveRealPart)
      eps heps with ⟨Np, hNp⟩
  rcases square_eventually_le_of_tendsto_zero
      (fun n : ℕ => actualKQMinusSource n rho.re rho.im)
      (actualKQMinusSource_tendsto_zero rho.re rho.im positiveRealPart)
      eps heps with ⟨Nm, hNm⟩
  refine ⟨max Np Nm, ?_, ?_⟩
  · exact hNp (max Np Nm) (Nat.le_max_left Np Nm)
  · exact hNm (max Np Nm) (Nat.le_max_right Np Nm)

/--
The v0.2.5 joint-tail leaf is removed.  The actual KQ sources are fixed to the
Rocq normalized dyadic rotation of the actual finite-Phi shift residuals, and
their common squared-tail decay is derived from the same positive-real-part
leaf already used on the jet side.

Seven explicit lower leaves remain:
  1. positive real part at every nontrivial zeta zero;
  2. shifted-slice norm-squared positivity;
  3. transverse norm-squared identity;
  4. plus jet-scale nonvanishing;
  5. minus jet-scale nonvanishing;
  6. plus exact-to-negative-square-plus-tail upper bound;
  7. minus exact-to-negative-square-plus-tail upper bound.
-/
theorem MATHLIB_RH_OF_SEVEN_LOWER_FORWARD_LEAVES
    (plusJetScale minusJetScale phiTransverseJet shiftedPhiNorm2 : ℂ → ℝ)
    (finitePlusSquare finiteMinusSquare : ℕ → ℂ → ℝ)
    (positiveRealPart :
      ∀ rho : ℂ, NontrivialZetaZero rho → 0 < rho.re)
    (shiftedPhiNorm2Positive :
      ∀ rho : ℂ, NontrivialZetaZero rho → 0 < shiftedPhiNorm2 rho)
    (transverseNorm2Identity :
      ∀ rho : ℂ, NontrivialZetaZero rho →
        phiTransverseJet rho = rhoNorm2 rho * shiftedPhiNorm2 rho)
    (plusJetScaleNonzero :
      ∀ rho : ℂ, NontrivialZetaZero rho → plusJetScale rho ≠ 0)
    (minusJetScaleNonzero :
      ∀ rho : ℂ, NontrivialZetaZero rho → minusJetScale rho ≠ 0)
    (plusExactToNegativeSquareTailUpper :
      ∀ (n : ℕ) (rho : ℂ), NontrivialZetaZero rho →
        scale2 (2 * (rho.re - (1 / 2 : ℝ))) *
              (jetPlus plusJetScale phiTransverseJet rho) ^ 2 -
            (jetPlus plusJetScale phiTransverseJet rho) ^ 2 ≤
          -(finitePlusSquare n rho) ^ 2 +
            actualKQPlusSource n rho.re rho.im *
              actualKQPlusSource n rho.re rho.im)
    (minusExactToNegativeSquareTailUpper :
      ∀ (n : ℕ) (rho : ℂ), NontrivialZetaZero rho →
        scale2 (-2 * (rho.re - (1 / 2 : ℝ))) *
              (jetMinus minusJetScale phiTransverseJet rho) ^ 2 -
            (jetMinus minusJetScale phiTransverseJet rho) ^ 2 ≤
          -(finiteMinusSquare n rho) ^ 2 +
            actualKQMinusSource n rho.re rho.im *
              actualKQMinusSource n rho.re rho.im) :
    RiemannHypothesis := by
  apply JetLeafDisassembly.MATHLIB_RH_OF_EIGHT_LOWER_FORWARD_LEAVES
    plusJetScale minusJetScale phiTransverseJet shiftedPhiNorm2
    actualKQPlusSource actualKQMinusSource
    finitePlusSquare finiteMinusSquare
  · exact positiveRealPart
  · exact shiftedPhiNorm2Positive
  · exact transverseNorm2Identity
  · exact plusJetScaleNonzero
  · exact minusJetScaleNonzero
  · exact plusExactToNegativeSquareTailUpper
  · exact minusExactToNegativeSquareTailUpper
  · intro rho eps hz heps
    exact jointTailDecay_of_positiveRealPart rho (positiveRealPart rho hz) eps heps

end AWPI.PhiRH.TailDecayDisassembly
