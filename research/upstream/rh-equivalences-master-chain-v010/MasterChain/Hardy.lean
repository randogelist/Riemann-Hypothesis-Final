import MasterChain.NativeObjects
import Mathlib.Order.ConditionallyCompleteLattice.Basic
import Mathlib.Tactic.Positivity

/-!
# The independent Hardy realization

The GP energy is the supremum of the actual vertical-line energies of a
holomorphic function. It is NOT defined as the density mass or the RR defect.
`GPAdmissible` records the hypotheses needed for this real supremum to be a
genuine finite squared Hardy norm. In particular, the totalized real `sSup`
and Bochner integrals are never used as substitutes for these hypotheses.
-/

noncomputable section
open MeasureTheory Filter Set
open scoped Topology

namespace MasterChain

def GPDomain : Set ℂ := {u | -(1 / 2 : ℝ) < u.re}

def verticalPoint (ε y : ℝ) : ℂ :=
  ((-(1 / 2 : ℝ) + ε : ℝ) : ℂ) + (y : ℂ) * Complex.I

def lineEnergy (f : ℂ → ℂ) (ε : ℝ) : ℝ :=
  (1 / (2 * Real.pi)) * ∫ y : ℝ, ‖f (verticalPoint ε y)‖ ^ 2

def lineEnergies (f : ℂ → ℂ) : Set ℝ :=
  lineEnergy f '' Set.Ioi 0

/-- Squared Hardy norm when `GPAdmissible f` holds. -/
def gpEnergy (f : ℂ → ℂ) : ℝ := sSup (lineEnergies f)

structure GPAdmissible (f : ℂ → ℂ) : Prop where
  holomorphic : DifferentiableOn ℂ f GPDomain
  line_integrable : ∀ ε : ℝ, 0 < ε →
    Integrable (fun y : ℝ => ‖f (verticalPoint ε y)‖ ^ 2)
  bounded_energy : BddAbove (lineEnergies f)

def boundaryEnergy (b : ℝ → ℂ) : ℝ :=
  (1 / (2 * Real.pi)) * ∫ y : ℝ, ‖b y‖ ^ 2

def boundaryDistance (f : ℂ → ℂ) (b : ℝ → ℂ) (ε : ℝ) : ℝ :=
  ∫ y : ℝ, ‖f (verticalPoint ε y) - b y‖ ^ 2

/-- A genuine L² boundary trace, approached from inside the GP half-plane. -/
structure IsL2BoundaryTrace (f : ℂ → ℂ) (b : ℝ → ℂ) : Prop where
  boundary_integrable : Integrable (fun y : ℝ => ‖b y‖ ^ 2)
  difference_integrable : ∀ ε : ℝ, 0 < ε →
    Integrable (fun y : ℝ => ‖f (verticalPoint ε y) - b y‖ ^ 2)
  approaches : Tendsto (boundaryDistance f b)
    (nhdsWithin 0 (Set.Ioi 0)) (nhds 0)

theorem lineEnergy_nonneg (f : ℂ → ℂ) (ε : ℝ) : 0 ≤ lineEnergy f ε := by
  apply mul_nonneg
  · positivity
  · exact integral_nonneg fun _ => sq_nonneg _

theorem boundaryEnergy_nonneg (b : ℝ → ℂ) : 0 ≤ boundaryEnergy b := by
  apply mul_nonneg
  · positivity
  · exact integral_nonneg fun _ => sq_nonneg _

theorem lineEnergy_le_gpEnergy {f : ℂ → ℂ} (hf : GPAdmissible f)
    {ε : ℝ} (hε : 0 < ε) : lineEnergy f ε ≤ gpEnergy f := by
  exact le_csSup hf.bounded_energy ⟨ε, hε, rfl⟩

theorem gpEnergy_nonneg {f : ℂ → ℂ} (hf : GPAdmissible f) :
    0 ≤ gpEnergy f := by
  exact (lineEnergy_nonneg f 1).trans (lineEnergy_le_gpEnergy hf (by norm_num))

end MasterChain
