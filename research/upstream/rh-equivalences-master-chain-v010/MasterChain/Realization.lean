import MasterChain.Chain
import MasterChain.DensityL2

/-! The actual square-root density as a mathlib Hilbert vector.
The Hardy-space identification is supplied only through MASTER_2. -/

noncomputable section
open MeasureTheory

namespace MasterChain

def xiDensityVector (hMass : Integrable A positiveLebesgue) :
    Lp ℝ 2 positiveLebesgue := densityL2 A_nonneg_ae hMass

theorem xiDensityVector_norm_sq (hMass : Integrable A positiveLebesgue) :
    ‖xiDensityVector hMass‖ ^ 2 = densityMass :=
  norm_densityL2_sq A_nonneg_ae hMass

theorem master_2_hilbert_identification
    (h2 : MASTER_2) (hMass : Integrable A positiveLebesgue) :
    C_RR = ‖xiDensityVector hMass‖ ^ 2 ∧
    gpEnergy V = ‖xiDensityVector hMass‖ ^ 2 := by
  rw [xiDensityVector_norm_sq]
  exact ⟨(master_2_defect_eq_energy h2).trans
      (master_2_mass_eq_energy h2).symm,
    (master_2_mass_eq_energy h2).symm⟩

theorem master_3_iff_xiDensityVector_zero
    (h2 : MASTER_2) (hMass : Integrable A positiveLebesgue) :
    MASTER_3 ↔ xiDensityVector hMass = 0 := by
  exact (master_3_iff_mass_zero h2).trans
    (densityL2_eq_zero_iff_mass A_nonneg_ae hMass).symm

end MasterChain
