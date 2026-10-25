import MasterChain.Hardy

/-! Explicit analytic obligations. These are propositions, not axioms. -/
noncomputable section
open MeasureTheory
namespace MasterChain

/-- Finiteness and integrability, kept separate from the representation identities. -/
structure NativeIntegrability : Prop where
  xi_half_ne_zero : xi (1 / 2 : ℂ) ≠ 0
  c1_integrable : Integrable (fun s : ℂ => 1 / height s ^ 2) xiDivisorMeasure
  defect_integrable : Integrable defectKernel xiDivisorMeasure
  density_kernel_integrable : ∀ v : ℝ, 0 < v →
    Integrable (fun s : ℂ => Real.exp (-height s * v) *
      Real.sin (displacement s * v / 2) ^ 2) xiDivisorMeasure
  density_integrable : Integrable A positiveLebesgue
  readout_integrable : Integrable
    (fun v : ℝ => Real.exp (-(3 : ℝ) * v / 2) * g v) positiveLebesgue
  laplace_integrable : ∀ u : ℂ, u ∈ GPDomain →
    Integrable (fun v : ℝ => Complex.exp (-(u + 1 / 2) * (v : ℂ)) *
      (g v : ℂ)) positiveLebesgue

/-- The actual-xi Hadamard/reciprocal-square trace decomposition to be bound. -/
def TraceDecomposition : Prop := c1 = kappa + C_RR

/-- The Tonelli and elementary Laplace-kernel identity to be bound. -/
def KernelMassIdentity : Prop := C_RR = densityMass

/-- The actual Laplace–Plancherel realization, including its boundary trace. -/
def LaplacePlancherel : Prop :=
  GPAdmissible V ∧ ∃ b : ℝ → ℂ,
    IsL2BoundaryTrace V b ∧
    densityMass = boundaryEnergy b ∧
    boundaryEnergy b = gpEnergy V

end MasterChain
