import FiveInduction.MainChain
import FiveInduction.SOSInput
import FiveInduction.ProjectionInput
import FiveInduction.SchurInput
import FiveInduction.NormalizedInputs

/-!
Five explicit research inputs and five proved conditional RH endpoints.
The disjunction permits any one route. No input witness is constructed here.
-/

namespace FiveInduction.InputChain

variable (E : Type*) [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-- Any single complete realization is sufficient; all five are not required. -/
def AnyInput : Prop :=
  SOSInput.SOSXiRealization ∨
  ProjectionInput.ProjectionXiRealization E ∨
  SchurInput.SchurXiRealization ∨
  NormalizedInputs.SturmInput ∨
  NormalizedInputs.DifferentialInput

theorem RH_OF_ANY_INPUT (h : AnyInput E) : RiemannHypothesis := by
  rcases h with h | h | h | h | h
  · exact SOSInput.RH_OF_SOS_REALIZATION h
  · exact ProjectionInput.RH_OF_PROJECTION_REALIZATION h
  · exact SchurInput.RH_OF_SCHUR_REALIZATION h
  · exact NormalizedInputs.RH_OF_STURM_INPUT h
  · exact NormalizedInputs.RH_OF_DIFFERENTIAL_INPUT h

/-- The five implications themselves are unconditional theorems. -/
theorem FIVE_INPUT_ENDPOINTS :
    (SOSInput.SOSXiRealization → RiemannHypothesis) ∧
    (ProjectionInput.ProjectionXiRealization E → RiemannHypothesis) ∧
    (SchurInput.SchurXiRealization → RiemannHypothesis) ∧
    (NormalizedInputs.SturmInput → RiemannHypothesis) ∧
    (NormalizedInputs.DifferentialInput → RiemannHypothesis) :=
  ⟨SOSInput.RH_OF_SOS_REALIZATION,
    ProjectionInput.RH_OF_PROJECTION_REALIZATION,
    SchurInput.RH_OF_SCHUR_REALIZATION,
    NormalizedInputs.RH_OF_STURM_INPUT,
    NormalizedInputs.RH_OF_DIFFERENTIAL_INPUT⟩

end FiveInduction.InputChain
