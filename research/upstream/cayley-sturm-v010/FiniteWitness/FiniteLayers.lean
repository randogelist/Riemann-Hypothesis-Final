import FiniteWitness.TraceInduction

/-!
# Actual-ξ finite coefficient layers

`elementary` is the exact elementary symmetric coefficient of a diagonal
finite rational positive spectrum. No spectral positivity axiom is inserted.
`UniversalCalibration` is NOT established by the seed checker.
-/

namespace WitnessSolobolo

/-- Finite elementary symmetric coefficient; all terms are rational. -/
def elementary (w : FiniteWitness) (N j : ℕ) : ℚ :=
  ∑ S ∈ (Finset.univ : Finset (Fin (N + 1 + w.rankOffset))).powersetCard j,
    ∏ i ∈ S, atom w N i

/-- Nonnegative atoms imply all finite elementary coefficients are nonnegative. -/
theorem elementary_nonneg (w : FiniteWitness) (N j : ℕ)
    (h : ∀ i : Fin (N + 1 + w.rankOffset), 0 ≤ atom w N i) :
    0 ≤ elementary w N j := by
  unfold elementary
  apply Finset.sum_nonneg
  intro S hS
  apply Finset.prod_nonneg
  intro i hi
  exact h i

/-- The finite seed checker establishes nonnegative elementary coefficients
at all depths it actually checks. -/
theorem checked_seed_elementary_nonneg
    (w : FiniteWitness) (hw : checkSeed w = true)
    (N : Fin (w.baseDepth + 1)) (j : ℕ) :
    0 ≤ elementary w N.val j := by
  apply elementary_nonneg
  intro i
  exact ((checkSeed_sound w hw N).1 i).1

/-- All-level finite spectral contractivity: still to be derived from an
actual finite universal successor certificate. -/
def AllLevelContractive (w : FiniteWitness) : Prop :=
  ∀ N : ℕ,
    (∀ i : Fin (N + 1 + w.rankOffset),
      0 ≤ atom w N i ∧ atom w N i ≤ 1) ∧
    mass w N ≤ 1

/-- Actual-xi coefficient calibration, deliberately referring to
`actualCoefficient` rather than an opaque sequence named xi. -/
def AllDepthCalibration (w : FiniteWitness) : Prop :=
  ∀ N j : ℕ, j ≤ N →
    (Nat.factorial j : ℝ) *
      |(elementary w N j : ℝ) - actualCoefficient j| ≤
        (1 / 2 : ℝ) ^ N

/-- Combined criterion that a future finite certificate must imply. -/
def AllDepthActualLayer (w : FiniteWitness) : Prop :=
  AllLevelContractive w ∧ AllDepthCalibration w

/-- Positivity survives arbitrarily close positive approximants.
This is a CLOSED elementary limit theorem, independent of RH. -/
theorem nonneg_of_arbitrary_positive_approx
    (x : ℝ)
    (h : ∀ ε : ℝ, 0 < ε →
      ∃ q : ℝ, 0 ≤ q ∧ |q - x| ≤ ε) :
    0 ≤ x := by
  by_contra hn
  have hx : x < 0 := lt_of_not_ge hn
  have he : 0 < -x / 2 := by linarith
  obtain ⟨q, hq, hbound⟩ := h (-x / 2) he
  have hright := (abs_le.mp hbound).2
  linarith

end WitnessSolobolo
