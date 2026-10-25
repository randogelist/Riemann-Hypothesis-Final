import MasterChain.Statements
import MasterChain.PositiveReadout
import Mathlib.Tactic.Linarith

/-!
# Checked implications; no assumed vanishing

These theorems expose every representation hypothesis. They do not assert that
the analytic bridge propositions have already been proved for the actual xi.
-/

noncomputable section
open MeasureTheory

namespace MasterChain

theorem master_2_of_analytic_bridges
    (hKernel : KernelMassIdentity) (hLaplace : LaplacePlancherel) : MASTER_2 := by
  rcases hLaplace with ⟨hGP, b, hTrace, hMass, hEnergy⟩
  exact ⟨hGP, b, hTrace, hKernel, hMass, hEnergy⟩

theorem master_2_defect_eq_energy (h2 : MASTER_2) : C_RR = gpEnergy V := by
  rcases h2 with ⟨_, b, _, hC, hM, hE⟩
  exact hC.trans (hM.trans hE)

theorem master_2_mass_eq_energy (h2 : MASTER_2) : densityMass = gpEnergy V := by
  rcases h2 with ⟨_, b, _, _, hM, hE⟩
  exact hM.trans hE

theorem master_1_of_trace_and_master_2
    (hTrace : TraceDecomposition) (h2 : MASTER_2) : MASTER_1 := by
  change c1 = kappa + gpEnergy V
  change c1 = kappa + C_RR at hTrace
  rw [hTrace, master_2_defect_eq_energy h2]

/-- MASTER_1 can be built from the primitive bridges without assuming MASTER_2. -/
theorem master_1_of_analytic_bridges
    (hTrace : TraceDecomposition) (hKernel : KernelMassIdentity)
    (hLaplace : LaplacePlancherel) : MASTER_1 := by
  exact master_1_of_trace_and_master_2 hTrace
    (master_2_of_analytic_bridges hKernel hLaplace)

theorem master_3_iff_c1_eq_kappa (h1 : MASTER_1) :
    MASTER_3 ↔ c1 = kappa := by
  change c1 = kappa + gpEnergy V at h1
  change gpEnergy V = 0 ↔ c1 = kappa
  constructor <;> intro h <;> linarith

theorem master_3_iff_defect_zero (h2 : MASTER_2) : MASTER_3 ↔ C_RR = 0 := by
  change gpEnergy V = 0 ↔ C_RR = 0
  rw [master_2_defect_eq_energy h2]

theorem master_3_iff_mass_zero (h2 : MASTER_2) : MASTER_3 ↔ densityMass = 0 := by
  change gpEnergy V = 0 ↔ densityMass = 0
  rw [master_2_mass_eq_energy h2]

theorem A_nonneg_ae : ∀ᵐ v ∂positiveLebesgue, 0 ≤ A v := by
  filter_upwards [ae_restrict_mem measurableSet_Ioi] with v hv
  exact A_nonneg (le_of_lt hv)

theorem scalarReadout_zero_iff_mass_zero
    (hMass : Integrable A positiveLebesgue)
    (hReadout : Integrable
      (fun v : ℝ => Real.exp (-(3 : ℝ) * v / 2) * g v) positiveLebesgue) :
    scalarReadout = 0 ↔ densityMass = 0 := by
  exact evaluation_one_eq_zero_iff_mass A_nonneg_ae hMass hReadout

theorem master_3_iff_scalarReadout_zero
    (h2 : MASTER_2) (hInt : NativeIntegrability) :
    MASTER_3 ↔ scalarReadout = 0 := by
  exact (master_3_iff_mass_zero h2).trans
    (scalarReadout_zero_iff_mass_zero hInt.density_integrable
      hInt.readout_integrable).symm

theorem master_3_iff_V_one_zero
    (h2 : MASTER_2) (hInt : NativeIntegrability) :
    MASTER_3 ↔ V 1 = 0 := by
  rw [master_3_iff_scalarReadout_zero h2 hInt, V_one_eq_scalarReadout]
  simp

theorem c1_ge_kappa (h1 : MASTER_1) (h2 : MASTER_2) : kappa ≤ c1 := by
  have hE := gpEnergy_nonneg h2.1
  change c1 = kappa + gpEnergy V at h1
  linarith

/-- One theorem collects the equivalences; none of its conclusions asserts vanishing. -/
theorem master_chain_equivalences
    (h1 : MASTER_1) (h2 : MASTER_2) (hInt : NativeIntegrability) :
    (MASTER_3 ↔ c1 = kappa) ∧
    (MASTER_3 ↔ C_RR = 0) ∧
    (MASTER_3 ↔ densityMass = 0) ∧
    (MASTER_3 ↔ V 1 = 0) := by
  exact ⟨master_3_iff_c1_eq_kappa h1,
    master_3_iff_defect_zero h2, master_3_iff_mass_zero h2,
    master_3_iff_V_one_zero h2 hInt⟩

end MasterChain
