import FiveInduction.SOS
import FiveInduction.Projection
import FiveInduction.Schur
import FiveInduction.Sturm
import FiveInduction.Differential

/-!
# The five concrete induction chains

Every field below is data or an elementary parameter constraint. In particular,
there is no field asserting preservation, root location, or an RH conclusion.
The universal invariants are derived from the five concrete recurrences.
-/

namespace FiveInduction

noncomputable section

variable (E : Type*) [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-- Parameters of the five actual recurrences, with elementary guards. -/
structure DesignData where
  delta : ℝ
  delta_pos : 0 < delta
  kappa : ℕ → ℝ
  kappa_pos : ∀ n, 0 < kappa n
  sosA : ℕ → Polynomial ℝ
  sosB : ℕ → Polynomial ℝ
  initialVector : E
  projectionVector : ℕ → E
  projectionVector_ne : ∀ n, projectionVector n ≠ 0
  schurParameter : ℕ → ℝ
  schurParameter_lt : ∀ n, |schurParameter n| < 1
  jacobiParameter : ℕ → ℝ
  jacobiParameter_pos : ∀ n, 0 < jacobiParameter (n + 1)
  rootInsertion : ℕ → ℝ
  rootInsertion_pos : ∀ n, 0 < rootInsertion n
  derivativeWeight : ℕ → ℝ
  derivativeWeight_nonneg : ∀ n, 0 ≤ derivativeWeight n

variable {E}

/-- Exactly the five desired invariants at stage n. -/
def StageInvariant (D : DesignData E) (n : ℕ) : Prop :=
  (∀ x ∈ Set.Icc (-1 : ℝ) 1,
    0 < (SOS.sequence D.delta D.kappa D.sosA D.sosB n).eval x) ∧
  (‖Projection.trajectory D.projectionVector D.initialVector n‖ ^ 2 ≤
    ‖D.initialVector‖ ^ 2) ∧
  (∀ z : ℂ, ‖z‖ ≤ 1 → Schur.p D.schurParameter n z ≠ 0) ∧
  (∀ z : ℂ, z.im ≠ 0 → Sturm.value D.jacobiParameter n z ≠ 0) ∧
  Differential.NegativeRealRoots
    (Differential.family D.rootInsertion D.derivativeWeight n)

/-- All five induction chains are inhabited by proved invariants, at every stage. -/
theorem FIVE_INDUCTION_CHAIN (D : DesignData E) (n : ℕ) : StageInvariant D n := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · exact SOS.all_positive D.delta D.kappa D.sosA D.sosB
      D.delta_pos D.kappa_pos n
  · exact Projection.trajectory_norm_sq_le D.projectionVector D.initialVector
      D.projectionVector_ne n
  · exact Schur.closedDisk_nonzero D.schurParameter D.schurParameter_lt n
  · exact Sturm.all_nonreal_nonzero D.jacobiParameter D.jacobiParameter_pos n
  · exact Differential.family_negative_real_roots D.rootInsertion D.derivativeWeight
      D.rootInsertion_pos D.derivativeWeight_nonneg n

theorem BASE_CERTIFICATE (D : DesignData E) : StageInvariant D 0 :=
  FIVE_INDUCTION_CHAIN D 0

/-- Preservation follows from the concrete induction proofs, with no assumed step law. -/
theorem PROVED_SUCCESSOR (D : DesignData E) (n : ℕ)
    (_previous : StageInvariant D n) : StageInvariant D (n + 1) :=
  FIVE_INDUCTION_CHAIN D (n + 1)

/-- A fully specified example; its existence makes no claim about actual xi. -/
def exampleData : DesignData ℝ where
  delta := 1
  delta_pos := by norm_num
  kappa := fun _ => 1
  kappa_pos := by intro n; norm_num
  sosA := fun _ => 0
  sosB := fun _ => 0
  initialVector := 1
  projectionVector := fun _ => 1
  projectionVector_ne := by intro n; norm_num
  schurParameter := fun _ => 1 / 2
  schurParameter_lt := by intro n; norm_num
  jacobiParameter := fun _ => 1
  jacobiParameter_pos := by intro n; norm_num
  rootInsertion := fun _ => 1
  rootInsertion_pos := by intro n; norm_num
  derivativeWeight := fun _ => 1
  derivativeWeight_nonneg := by intro n; norm_num

theorem EXAMPLE_ALL_STAGES (n : ℕ) : StageInvariant exampleData n :=
  FIVE_INDUCTION_CHAIN exampleData n

end
end FiveInduction
