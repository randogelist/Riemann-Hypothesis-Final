import AllDepth.CayleyTaylorAndPole

/-!
# Root-free symmetric Cayley Taylor geometry (all depths)

For the SOLOBOLO conjugate pair `z₊, z₋`, set `u = z₊ - a`, `v = z₋ - a`.
Their symmetric coordinates are exactly `u+v = -4*a*r`, `u*v = 4*a²*r`.

The recurrence below constructs (u^(n+1)-v^(n+1))/(u-v) without
introducing square roots, divided-by-zero cases, or any analytic hypothesis.
It is the polynomial algebra needed for the *actual* Θ Cauchy jet expansion.

No unproved ξ moment calibration or RH assumption is used here.
-/

namespace KQGPBKQRHilbert.AllDepth

open NativeSolobolo NativeSolobolo.Derivations.Geometry

noncomputable section

/-- Symmetric divided-power recurrence. The second component computes
    `(u^(n+1)-v^(n+1))/(u-v)` from the elementary symmetric invariants
    `s=u+v`, `p=u*v` without requiring `u ≠ v`. -/
def symmetricPowerPair (s p : ℂ) : ℕ → ℂ × ℂ
  | 0 => (0, 1)
  | n + 1 =>
      let x := symmetricPowerPair s p n
      (x.2, s * x.2 - p * x.1)

/-- Exact polynomial divided-difference identity, valid even when u=v. -/
theorem symmetricPowerPair_identity (u v : ℂ) (n : ℕ) :
    (u - v) * (symmetricPowerPair (u + v) (u * v) n).1 = u ^ n - v ^ n ∧
    (u - v) * (symmetricPowerPair (u + v) (u * v) n).2 =
      u ^ (n + 1) - v ^ (n + 1) := by
  induction n with
  | zero =>
      constructor <;> simp [symmetricPowerPair]
  | succ n ih =>
      rcases ih with ⟨hprev, hcur⟩
      constructor
      · change (u - v) * (symmetricPowerPair (u + v) (u * v) n).2 =
          u ^ (n + 1) - v ^ (n + 1)
        exact hcur
      · change
          (u - v) *
            ((u + v) * (symmetricPowerPair (u + v) (u * v) n).2 -
              (u * v) * (symmetricPowerPair (u + v) (u * v) n).1) =
          u ^ ((n + 1) + 1) - v ^ ((n + 1) + 1)
        calc
          _ = (u + v) *
                ((u - v) * (symmetricPowerPair (u + v) (u * v) n).2) -
              (u * v) *
                ((u - v) * (symmetricPowerPair (u + v) (u * v) n).1) := by ring
          _ = (u + v) * (u ^ (n + 1) - v ^ (n + 1)) -
              (u * v) * (u ^ n - v ^ n) := by rw [hprev, hcur]
          _ = u ^ ((n + 1) + 1) - v ^ ((n + 1) + 1) := by
            rw [pow_succ u (n + 1), pow_succ v (n + 1),
              pow_succ u n, pow_succ v n]
            ring

/-- Linear root-free coordinate for Cayley points shifted by a. -/
theorem cayley_shifted_pair_sum (a r : ℝ) :
    (cayleyPointPlus a r - (a : ℂ)) +
        (cayleyPointMinus a r - (a : ℂ)) = ((-4 * a * r : ℝ) : ℂ) := by
  calc
    (cayleyPointPlus a r - (a : ℂ)) +
        (cayleyPointMinus a r - (a : ℂ)) =
      (cayleyPointPlus a r + cayleyPointMinus a r) - 2 * (a : ℂ) := by ring
    _ = ((2 * a * (1 - 2 * r) : ℝ) : ℂ) - 2 * (a : ℂ) := by
      rw [CAYLEY_PAIR_SUM]
    _ = ((-4 * a * r : ℝ) : ℂ) := by push_cast; ring

/-- Quadratic root-free coordinate for shifted conjugate Cayley points. -/
theorem cayley_shifted_pair_product (a r : ℝ)
    (ha : 0 ≤ a) (hr0 : 0 ≤ r) (hr1 : r ≤ 1) :
    (cayleyPointPlus a r - (a : ℂ)) *
        (cayleyPointMinus a r - (a : ℂ)) = ((4 * a ^ 2 * r : ℝ) : ℂ) := by
  calc
    (cayleyPointPlus a r - (a : ℂ)) *
        (cayleyPointMinus a r - (a : ℂ)) =
      cayleyPointPlus a r * cayleyPointMinus a r -
        (a : ℂ) * (cayleyPointPlus a r + cayleyPointMinus a r) +
        (a : ℂ) ^ 2 := by ring
    _ = ((a ^ 2 : ℝ) : ℂ) -
        (a : ℂ) * ((2 * a * (1 - 2 * r) : ℝ) : ℂ) + (a : ℂ) ^ 2 := by
      rw [CAYLEY_PAIR_PRODUCT a r ha hr0 hr1, CAYLEY_PAIR_SUM]
    _ = ((4 * a ^ 2 * r : ℝ) : ℂ) := by push_cast; ring

/-- The root-free polynomial divided difference of the shifted power
    `(z-a)^(n+1)` at the two Cayley points. -/
def shiftedCayleyDividedPower (a r : ℝ) (n : ℕ) : ℂ :=
  (symmetricPowerPair ((-4 * a * r : ℝ) : ℂ)
      ((4 * a ^ 2 * r : ℝ) : ℂ) n).2

/-- Algebraic identification at every depth, without division by the
    vanishing Cayley point separation at r=0. -/
theorem shifted_cayley_power_difference (a r : ℝ)
    (ha : 0 ≤ a) (hr0 : 0 ≤ r) (hr1 : r ≤ 1)
    (n : ℕ) :
    (cayleyPointPlus a r - cayleyPointMinus a r) *
        shiftedCayleyDividedPower a r n =
      (cayleyPointPlus a r - (a : ℂ)) ^ (n + 1) -
        (cayleyPointMinus a r - (a : ℂ)) ^ (n + 1) := by
  let u : ℂ := cayleyPointPlus a r - (a : ℂ)
  let v : ℂ := cayleyPointMinus a r - (a : ℂ)
  have hs : u + v = ((-4 * a * r : ℝ) : ℂ) :=
    cayley_shifted_pair_sum a r
  have hp : u * v = ((4 * a ^ 2 * r : ℝ) : ℂ) :=
    cayley_shifted_pair_product a r ha hr0 hr1
  have hid := (symmetricPowerPair_identity u v n).2
  rw [hs, hp] at hid
  change (u - v) * shiftedCayleyDividedPower a r n =
    u ^ (n + 1) - v ^ (n + 1) at hid
  convert hid using 1 <;> dsimp [u, v] <;> ring

/-- A finite analytic Taylor jet with arbitrary coefficients; the j=0
    constant term cancels in the divided difference. -/
def finiteShiftedCayleyJet
    (a r : ℝ) (c : ℕ → ℂ) (N : ℕ) : ℂ :=
  (4 * (a : ℂ)) *
    ∑ j ∈ Finset.range N, c (j + 1) * shiftedCayleyDividedPower a r j

/-- The finite Taylor divided difference agrees identically with its
    root-free polynomial model. This is the algebraic core of B1. -/
theorem finite_shifted_cayley_jet_identity
    (a r : ℝ) (c : ℕ → ℂ) (N : ℕ)
    (ha : 0 ≤ a) (hr0 : 0 ≤ r) (hr1 : r ≤ 1) :
    (cayleyPointPlus a r - cayleyPointMinus a r) *
        finiteShiftedCayleyJet a r c N =
      (4 * (a : ℂ)) *
        ∑ j ∈ Finset.range N,
          c (j + 1) *
            ((cayleyPointPlus a r - (a : ℂ)) ^ (j + 1) -
              (cayleyPointMinus a r - (a : ℂ)) ^ (j + 1)) := by
  have hs :
      (cayleyPointPlus a r - cayleyPointMinus a r) *
          (∑ j ∈ Finset.range N,
            c (j + 1) * shiftedCayleyDividedPower a r j) =
        ∑ j ∈ Finset.range N,
          c (j + 1) *
            ((cayleyPointPlus a r - (a : ℂ)) ^ (j + 1) -
              (cayleyPointMinus a r - (a : ℂ)) ^ (j + 1)) := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro j hj
    calc
      (cayleyPointPlus a r - cayleyPointMinus a r) *
          (c (j + 1) * shiftedCayleyDividedPower a r j) =
        c (j + 1) *
          ((cayleyPointPlus a r - cayleyPointMinus a r) *
            shiftedCayleyDividedPower a r j) := by ring
      _ = c (j + 1) *
            ((cayleyPointPlus a r - (a : ℂ)) ^ (j + 1) -
              (cayleyPointMinus a r - (a : ℂ)) ^ (j + 1)) := by
        rw [shifted_cayley_power_difference a r ha hr0 hr1 j]
  calc
    (cayleyPointPlus a r - cayleyPointMinus a r) *
        finiteShiftedCayleyJet a r c N =
      (4 * (a : ℂ)) *
        ((cayleyPointPlus a r - cayleyPointMinus a r) *
          (∑ j ∈ Finset.range N,
            c (j + 1) * shiftedCayleyDividedPower a r j)) := by
          unfold finiteShiftedCayleyJet
          ring
    _ = _ := by rw [hs]

end
end KQGPBKQRHilbert.AllDepth
