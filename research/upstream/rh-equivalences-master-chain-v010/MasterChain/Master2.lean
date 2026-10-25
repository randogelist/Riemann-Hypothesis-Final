import MasterChain.Hardy

/-! MASTER_2 is a separate proposition. The existential boundary trace and
Hardy admissibility prevent an informal boundary evaluation from being treated
as an established L2 trace. It imports neither MASTER_1 nor MASTER_3. -/
namespace MasterChain

def MASTER_2 : Prop :=
  GPAdmissible V ∧ ∃ b : ℝ → ℂ,
    IsL2BoundaryTrace V b ∧
    C_RR = densityMass ∧
    densityMass = boundaryEnergy b ∧
    boundaryEnergy b = gpEnergy V

end MasterChain
