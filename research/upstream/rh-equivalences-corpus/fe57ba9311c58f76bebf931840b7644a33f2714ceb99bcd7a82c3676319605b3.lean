import Bridge.StieltjesStripping
import Mathlib

namespace NativeSoloboloContinuant

/-- Reverse-indexed canonical Bernstein row.  The second index is the distance
    from the right edge: `d = N-j`.  The right edge is fixed to the moment
    `c N`, and the remaining entries are solved recursively from the standard
    degree-elevation identity.  No sign or positivity hypothesis occurs here. -/
noncomputable def signedBernsteinRev (c : Nat → ℝ) : (N : Nat) → Nat → ℝ
  | 0 => fun d => if d = 0 then c 0 else 0
  | N + 1 =>
      let prev := signedBernsteinRev c N
      let rec build : Nat → ℝ
        | 0 => c (N + 1)
        | d + 1 =>
            ((((N + 1 : Nat) : ℝ) * prev d) -
              (((N - d + 1 : Nat) : ℝ) * build d)) /
              (((d + 1 : Nat) : ℝ))
      build

@[simp] theorem signedBernsteinRev_zero (c : Nat → ℝ) (N : Nat) :
    signedBernsteinRev c N 0 = c N := by
  cases N <;> rfl

@[simp] theorem signedBernsteinRev_succ_succ
    (c : Nat → ℝ) (N d : Nat) :
    signedBernsteinRev c (N + 1) (d + 1) =
      ((((N + 1 : Nat) : ℝ) * signedBernsteinRev c N d) -
        (((N - d + 1 : Nat) : ℝ) * signedBernsteinRev c (N + 1) d)) /
        (((d + 1 : Nat) : ℝ)) := by
  rfl

/-- !!! Reverse-index form of exact degree elevation. -/
theorem SIGNED_BERNSTEIN_REV_DEGREE_ELEVATION
    (c : Nat → ℝ) (N d : Nat) :
    signedBernsteinRev c N d =
      ((((d + 1 : Nat) : ℝ) / ((N + 1 : Nat) : ℝ)) *
        signedBernsteinRev c (N + 1) (d + 1)) +
      ((((N - d + 1 : Nat) : ℝ) / ((N + 1 : Nat) : ℝ)) *
        signedBernsteinRev c (N + 1) d) := by
  rw [signedBernsteinRev_succ_succ]
  have hN : (((N + 1 : Nat) : ℝ)) ≠ 0 := by positivity
  have hd : (((d + 1 : Nat) : ℝ)) ≠ 0 := by positivity
  field_simp [hN, hd]
  ring

/-- Canonical signed Bernstein row in the usual left-to-right index. -/
noncomputable def signedBernsteinRow (c : Nat → ℝ) (N j : Nat) : ℝ :=
  if h : j ≤ N then signedBernsteinRev c N (N - j) else 0

/-- ! The rightmost row entry is exactly the input moment. -/
@[simp] theorem SIGNED_BERNSTEIN_DIAGONAL
    (c : Nat → ℝ) (N : Nat) :
    signedBernsteinRow c N N = c N := by
  simp [signedBernsteinRow]

/-- !!! Exact standard degree elevation in ordinary row coordinates. -/
theorem SIGNED_BERNSTEIN_DEGREE_ELEVATION
    (c : Nat → ℝ) (N j : Nat) (hj : j ≤ N) :
    signedBernsteinRow c N j =
      ((((N + 1 - j : Nat) : ℝ) / ((N + 1 : Nat) : ℝ)) *
        signedBernsteinRow c (N + 1) j) +
      ((((j + 1 : Nat) : ℝ) / ((N + 1 : Nat) : ℝ)) *
        signedBernsteinRow c (N + 1) (j + 1)) := by
  have hjN1 : j ≤ N + 1 := Nat.le_trans hj (Nat.le_succ N)
  have hj1 : j + 1 ≤ N + 1 := Nat.succ_le_succ hj
  have hsub1 : N + 1 - j = (N - j) + 1 := by omega
  have hsub2 : N + 1 - (j + 1) = N - j := by omega
  have hcoef : N - (N - j) + 1 = j + 1 := by omega
  rw [signedBernsteinRow, dif_pos hj]
  rw [signedBernsteinRow, dif_pos hjN1]
  rw [signedBernsteinRow, dif_pos hj1]
  rw [hsub1, hsub2]
  have h := SIGNED_BERNSTEIN_REV_DEGREE_ELEVATION c N (N - j)
  rw [hcoef] at h
  exact h

/-- The actual canonical signed Bernstein row of the normalized Mathlib-xi
    Widder sequence. -/
noncomputable def actualSignedBernsteinRow (a : ℝ) (N j : Nat) : ℝ :=
  signedBernsteinRow (actualNormalizedWidderMoment a) N j

@[simp] theorem ACTUAL_SIGNED_BERNSTEIN_DIAGONAL (a : ℝ) (N : Nat) :
    actualSignedBernsteinRow a N N = actualNormalizedWidderMoment a N := by
  simp [actualSignedBernsteinRow]

/-- Total variation of one signed Bernstein row. -/
noncomputable def signedBernsteinVariation (c : Nat → ℝ) (N : Nat) : ℝ :=
  ∑ j ∈ Finset.range (N + 1), |signedBernsteinRow c N j|

noncomputable def actualSignedBernsteinVariation (a : ℝ) (N : Nat) : ℝ :=
  signedBernsteinVariation (actualNormalizedWidderMoment a) N

/-- Row variation is nonnegative. -/
theorem SIGNED_BERNSTEIN_VARIATION_NONNEGATIVE
    (c : Nat → ℝ) (N : Nat) :
    0 ≤ signedBernsteinVariation c N := by
  exact Finset.sum_nonneg (fun _ _ => abs_nonneg _)

/-- !!! The moment is dominated by the row variation because it is the
    rightmost Bernstein coefficient. -/
theorem SIGNED_BERNSTEIN_DIAGONAL_ABS_LE_VARIATION
    (c : Nat → ℝ) (N : Nat) :
    |c N| ≤ signedBernsteinVariation c N := by
  have hmem : N ∈ Finset.range (N + 1) := by
    exact Finset.mem_range.mpr (Nat.lt_succ_self N)
  calc
    |c N| = |signedBernsteinRow c N N| := by rw [SIGNED_BERNSTEIN_DIAGONAL]
    _ ≤ ∑ j ∈ Finset.range (N + 1), |signedBernsteinRow c N j| := by
      exact Finset.single_le_sum (fun j _ => abs_nonneg (signedBernsteinRow c N j)) hmem
    _ = signedBernsteinVariation c N := rfl

/-- Actual specialization of the diagonal domination. -/
theorem ACTUAL_WIDDER_ABS_LE_SIGNED_BERNSTEIN_VARIATION
    (a : ℝ) (N : Nat) :
    |actualNormalizedWidderMoment a N| ≤ actualSignedBernsteinVariation a N := by
  exact SIGNED_BERNSTEIN_DIAGONAL_ABS_LE_VARIATION
    (actualNormalizedWidderMoment a) N

/-- The variation increment.  This is deliberately defined without any sign
    assumption; the adjacent-sign/min formula can be attached later using the
    degree-elevation theorem above. -/
noncomputable def signedBernsteinVariationIncrement
    (c : Nat → ℝ) (N : Nat) : ℝ :=
  (signedBernsteinVariation c (N + 1) - signedBernsteinVariation c N) / 2

noncomputable def signedBernsteinCumulativeIncrement
    (c : Nat → ℝ) (N : Nat) : ℝ :=
  ∑ r ∈ Finset.range N, signedBernsteinVariationIncrement c r

/-- !! Exact telescoping of variation increments. -/
theorem SIGNED_BERNSTEIN_VARIATION_TELESCOPES
    (c : Nat → ℝ) (N : Nat) :
    signedBernsteinVariation c N =
      signedBernsteinVariation c 0 +
        2 * signedBernsteinCumulativeIncrement c N := by
  induction N with
  | zero => simp [signedBernsteinCumulativeIncrement]
  | succ N ih =>
      have hstep :
          signedBernsteinVariation c (N + 1) =
            signedBernsteinVariation c N +
              2 * signedBernsteinVariationIncrement c N := by
        unfold signedBernsteinVariationIncrement
        ring
      unfold signedBernsteinCumulativeIncrement at ih ⊢
      rw [Finset.sum_range_succ]
      linarith

/-- The zero row has variation `|c 0|`. -/
@[simp] theorem SIGNED_BERNSTEIN_VARIATION_ZERO (c : Nat → ℝ) :
    signedBernsteinVariation c 0 = |c 0| := by
  simp [signedBernsteinVariation, signedBernsteinRow]

/-- The actual normalized Widder sequence starts at one. -/
@[simp] theorem ACTUAL_NORMALIZED_WIDDER_ZERO (a : ℝ) :
    actualNormalizedWidderMoment a 0 = 1 := by
  rfl

/-- !!! Actual variation ledger. -/
theorem ACTUAL_SIGNED_BERNSTEIN_VARIATION_LEDGER
    (a : ℝ) (N : Nat) :
    actualSignedBernsteinVariation a N =
      1 + 2 * signedBernsteinCumulativeIncrement
        (actualNormalizedWidderMoment a) N := by
  unfold actualSignedBernsteinVariation
  rw [SIGNED_BERNSTEIN_VARIATION_TELESCOPES]
  simp

/-- Lean-friendly subexponential growth for a nonnegative sequence. -/
def NonnegativeSubexponential (v : Nat → ℝ) : Prop :=
  ∀ q : ℝ, 1 < q → ∃ N0 : Nat, ∀ N : Nat, N0 ≤ N → v N ≤ q ^ N

/-- Lean-friendly subexponential absolute growth for an arbitrary real sequence. -/
def AbsoluteSubexponential (u : Nat → ℝ) : Prop :=
  ∀ q : ℝ, 1 < q → ∃ N0 : Nat, ∀ N : Nat, N0 ≤ N → |u N| ≤ q ^ N

/-- !!! Domination by a subexponential nonnegative majorant transfers
    subexponentiality. -/
theorem ABSOLUTE_SUBEXPONENTIAL_OF_DOMINATION
    (u v : Nat → ℝ)
    (hdom : ∀ N, |u N| ≤ v N)
    (hv : NonnegativeSubexponential v) :
    AbsoluteSubexponential u := by
  intro q hq
  obtain ⟨N0, hN0⟩ := hv q hq
  exact ⟨N0, fun N hNN0 => le_trans (hdom N) (hN0 N hNN0)⟩

/-- !!! Subexponential actual row variation forces subexponential actual
    normalized Widder moments. -/
theorem ACTUAL_VARIATION_SUBEXPONENTIAL_IMPLIES_WIDDER_SUBEXPONENTIAL
    (a : ℝ)
    (hV : NonnegativeSubexponential (actualSignedBernsteinVariation a)) :
    AbsoluteSubexponential (actualNormalizedWidderMoment a) := by
  exact ABSOLUTE_SUBEXPONENTIAL_OF_DOMINATION
    (actualNormalizedWidderMoment a)
    (actualSignedBernsteinVariation a)
    (ACTUAL_WIDDER_ABS_LE_SIGNED_BERNSTEIN_VARIATION a)
    hV

/-- The weakened actual signed-Bernstein frontier: row variation needs only be
    subexponential, not uniformly bounded. -/
def ActualBernsteinVariationSubexponential : Prop :=
  ∀ a : ℝ, 0 < a →
    NonnegativeSubexponential (actualSignedBernsteinVariation a)

/-- Equivalent cumulative-increment formulation of the weakened frontier. -/
def ActualCancellationSubexponential : Prop :=
  ∀ a : ℝ, 0 < a →
    NonnegativeSubexponential
      (fun N => 1 + 2 * signedBernsteinCumulativeIncrement
        (actualNormalizedWidderMoment a) N)

/-- !!! The cumulative-increment formulation and row-variation formulation are
    definitionally linked by the exact variation ledger. -/
theorem ACTUAL_CANCELLATION_SUBEXPONENTIAL_IFF_VARIATION_SUBEXPONENTIAL :
    ActualCancellationSubexponential ↔ ActualBernsteinVariationSubexponential := by
  constructor
  · intro h a ha
    have hEq :
        (fun N => 1 + 2 * signedBernsteinCumulativeIncrement
          (actualNormalizedWidderMoment a) N) =
          actualSignedBernsteinVariation a := by
      funext N
      exact (ACTUAL_SIGNED_BERNSTEIN_VARIATION_LEDGER a N).symm
    exact hEq ▸ h a ha
  · intro h a ha
    have hEq :
        actualSignedBernsteinVariation a =
          (fun N => 1 + 2 * signedBernsteinCumulativeIncrement
            (actualNormalizedWidderMoment a) N) := by
      funext N
      exact ACTUAL_SIGNED_BERNSTEIN_VARIATION_LEDGER a N
    exact hEq ▸ h a ha

/-- Global weakened frontier implies subexponential Widder moments at every
    positive anchor. -/
theorem ACTUAL_BERNSTEIN_SUBEXPONENTIAL_IMPLIES_ALL_WIDDER_SUBEXPONENTIAL
    (h : ActualBernsteinVariationSubexponential) :
    ∀ a : ℝ, 0 < a → AbsoluteSubexponential (actualNormalizedWidderMoment a) := by
  intro a ha
  exact ACTUAL_VARIATION_SUBEXPONENTIAL_IMPLIES_WIDDER_SUBEXPONENTIAL a (h a ha)

end NativeSoloboloContinuant
