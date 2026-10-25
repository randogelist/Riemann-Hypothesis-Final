import AllDepth.ActualXiRealLeibniz
import Mathlib.Data.Nat.Choose.Basic
import Mathlib.Data.Nat.Factorial.Basic

/-!
# v0.1.18 — real Rodrigues factorial normalization, all depths

Bridge from the already-compiled literal actual-xi real higher Leibniz
expansion to the canonical Cayley coefficient of its normalized real Taylor
jets. No spectral representation, RH hypothesis, pole positivity, or
completed-xi Taylor-germ identification is assumed.
-/

namespace KQGPBKQRHilbert.AllDepth

noncomputable section

/-- Cancellation identity in ℕ, avoiding natural-number division. -/
theorem choose_desc_factorial_cross (n j : ℕ) (hj : j ≤ n) :
    (2 * n + 1).choose j * n.descFactorial j * (2 * n + 1 - j).factorial =
      n.choose j * (2 * n + 1).factorial := by
  have hm : j ≤ 2 * n + 1 := by omega
  have hfac : (2 * n + 1).choose j * j.factorial *
      (2 * n + 1 - j).factorial = (2 * n + 1).factorial :=
    Nat.choose_mul_factorial_mul_factorial hm
  calc
    (2 * n + 1).choose j * n.descFactorial j *
        (2 * n + 1 - j).factorial =
      n.choose j * ((2 * n + 1).choose j * j.factorial *
        (2 * n + 1 - j).factorial) := by
          rw [Nat.descFactorial_eq_factorial_mul_choose]
          ring
    _ = n.choose j * (2 * n + 1).factorial := by rw [hfac]

/-- Normalized factorial identity, with all nonzero denominators explicit. -/
theorem choose_desc_factorial_real_div (n j : ℕ) (hj : j ≤ n) :
    (((2 * n + 1).choose j : ℕ) : ℝ) * (n.descFactorial j : ℝ) /
        ((2 * n + 1).factorial : ℝ) =
      (n.choose j : ℝ) / ((2 * n + 1 - j).factorial : ℝ) := by
  have h := choose_desc_factorial_cross n j hj
  have hr :
      (((2 * n + 1).choose j : ℕ) : ℝ) * (n.descFactorial j : ℝ) *
        ((2 * n + 1 - j).factorial : ℝ) =
      (n.choose j : ℝ) * ((2 * n + 1).factorial : ℝ) := by
    exact_mod_cast h
  have hfac : ((2 * n + 1).factorial : ℝ) ≠ 0 := by positivity
  have hfac' : ((2 * n + 1 - j).factorial : ℝ) ≠ 0 := by positivity
  apply (div_eq_div_iff hfac hfac').2
  simpa only [mul_assoc] using hr

/-- Reverse the finite binomial sum j=n-k with no boundary assumptions on v. -/
theorem reflected_binomial_derivative_sum
    (a : ℝ) (v : ℕ → ℝ) (n : ℕ) :
    (∑ j ∈ Finset.range (n + 1),
      (n.choose j : ℝ) * a ^ (n - j) * v (2 * n + 1 - j)) =
    ∑ k ∈ Finset.range (n + 1),
      (n.choose k : ℝ) * a ^ k * v (n + k + 1) := by
  let F : ℕ → ℝ := fun j =>
    (n.choose j : ℝ) * a ^ (n - j) * v (2 * n + 1 - j)
  change (∑ j ∈ Finset.range (n + 1), F j) = _
  rw [← Finset.sum_range_reflect F (n + 1)]
  apply Finset.sum_congr rfl
  intro k hk
  have hkn : k ≤ n := Nat.le_of_lt_succ (Finset.mem_range.mp hk)
  have hshift : n + 1 - 1 - k = n - k := by omega
  have hpower : n - (n - k) = k := by omega
  have hindex : 2 * n + 1 - (n - k) = n + k + 1 := by omega
  have hindex' : 1 + n * 2 - (n - k) = 1 + n + k := by omega
  simp only [F, hshift, Nat.choose_symm hkn] <;>
    simp only [hpower, hindex, hindex'] <;> ring

/-- Factorial-normalized higher Leibniz sum in canonical Cayley indexing.
This holds for arbitrary real functions: no analytic estimates are used. -/
theorem normalized_real_leibniz_sum
    (a : ℝ) (f : ℝ → ℝ) (n : ℕ) :
    (1 / ((2 * n + 1).factorial : ℝ)) *
      (∑ j ∈ Finset.range (n + 1),
        (((2 * n + 1).choose j : ℕ) : ℝ) * (n.descFactorial j : ℝ) *
          a ^ (n - j) * iteratedDeriv (2 * n + 1 - j) f a) =
      ∑ k ∈ Finset.range (n + 1),
        (n.choose k : ℝ) * a ^ k *
          (iteratedDeriv (n + k + 1) f a /
            ((n + k + 1).factorial : ℝ)) := by
  let v : ℕ → ℝ := fun j => iteratedDeriv j f a / (j.factorial : ℝ)
  calc
    (1 / ((2 * n + 1).factorial : ℝ)) *
      (∑ j ∈ Finset.range (n + 1),
        (((2 * n + 1).choose j : ℕ) : ℝ) * (n.descFactorial j : ℝ) *
          a ^ (n - j) * iteratedDeriv (2 * n + 1 - j) f a) =
      ∑ j ∈ Finset.range (n + 1),
        (n.choose j : ℝ) * a ^ (n - j) * v (2 * n + 1 - j) := by
        rw [Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro j hj
        have hjle : j ≤ n := Nat.le_of_lt_succ (Finset.mem_range.mp hj)
        have hweight := choose_desc_factorial_real_div n j hjle
        change
          (1 / ((2 * n + 1).factorial : ℝ)) *
             (((2 * n + 1).choose j : ℕ) : ℝ) * (n.descFactorial j : ℝ) *
               a ^ (n - j) * iteratedDeriv (2 * n + 1 - j) f a =
           (n.choose j : ℝ) * a ^ (n - j) *
             (iteratedDeriv (2 * n + 1 - j) f a /
               ((2 * n + 1 - j).factorial : ℝ))
        calc
          _ =
             ((((2 * n + 1).choose j : ℕ) : ℝ) * (n.descFactorial j : ℝ) /
               ((2 * n + 1).factorial : ℝ)) *
               a ^ (n - j) * iteratedDeriv (2 * n + 1 - j) f a := by ring
          _ = ((n.choose j : ℝ) / ((2 * n + 1 - j).factorial : ℝ)) *
                a ^ (n - j) * iteratedDeriv (2 * n + 1 - j) f a := by
                  rw [hweight]
          _ = _ := by ring
    _ = ∑ k ∈ Finset.range (n + 1),
          (n.choose k : ℝ) * a ^ k * v (n + k + 1) :=
            reflected_binomial_derivative_sum a v n
    _ = _ := rfl

/-- A sign/power conversion valid at all depths and all real anchors. -/
theorem widder_rodrigues_scale (a : ℝ) (n : ℕ) :
    (-1 : ℝ) ^ n * (4 * a) ^ (n + 1) =
      4 * a * (-4 * a) ^ n := by
  rw [pow_succ, show (-4 * a : ℝ) = -(4 * a) by ring, neg_pow]
  ring

/-- Genuine xi direct Widder derivatives, rewritten in normalized binomial
Taylor form for EVERY n. The only domain input is the existing regular anchor. -/
theorem actual_xi_real_rodrigues_normalized
    (a : ℝ) (ha : a ∈ NativeSoloboloNegativity.xiRegularAnchors)
    (n : ℕ) :
    NativeSoloboloNegativity.xiWidderDirect a n =
      4 * a * (-4 * a) ^ n *
        (∑ k ∈ Finset.range (n + 1),
          (n.choose k : ℝ) * a ^ k *
          (iteratedDeriv (n + k + 1)
            (fun t : ℝ => t * NativeSoloboloNegativity.xiR t) a /
              ((n + k + 1).factorial : ℝ))) := by
  let f : ℝ → ℝ := fun t => t * NativeSoloboloNegativity.xiR t
  have hraw := actual_xi_widder_direct_finite_leibniz a ha n
  have hnormal := normalized_real_leibniz_sum a f n
  calc
    NativeSoloboloNegativity.xiWidderDirect a n =
        ((-1 : ℝ) ^ n * (4 * a) ^ (n + 1)) *
        ((1 / ((2 * n + 1).factorial : ℝ)) *
          (∑ j ∈ Finset.range (n + 1),
            (((2 * n + 1).choose j : ℕ) : ℝ) * (n.descFactorial j : ℝ) *
            a ^ (n - j) * iteratedDeriv (2 * n + 1 - j) f a)) := by
              rw [hraw]
              dsimp [f]
              ring
    _ = (4 * a * (-4 * a) ^ n) *
        (∑ k ∈ Finset.range (n + 1),
          (n.choose k : ℝ) * a ^ k *
            (iteratedDeriv (n + k + 1) f a /
              ((n + k + 1).factorial : ℝ))) := by
          rw [widder_rodrigues_scale a n, hnormal]
    _ = _ := rfl

/-- Real-to-complex coercion of the fully normalized formula, identifying
it with the canonical Cayley coefficients of actual xi real Taylor inputs. -/
theorem actual_xi_canonical_cayley_coefficients
    (a : ℝ) (ha : a ∈ NativeSoloboloNegativity.xiRegularAnchors)
    (n : ℕ) :
    canonicalCayleyCoefficient a (actualXiRealTaylorInput a) n =
      (NativeSoloboloNegativity.xiWidderDirect a n : ℂ) := by
  rw [actual_xi_real_rodrigues_normalized a ha n]
  unfold canonicalCayleyCoefficient actualXiRealTaylorInput
  push_cast
  ring

/-- Discharge the v0.1.16 research interface, without assuming a witness. -/
theorem actualXiRealRodriguesCompatibility_proven :
    ActualXiRealRodriguesCompatibility := by
  intro a ha n
  calc
    polynomialRodriguesCoefficient a
        (localTaylorInterpolant a (actualXiRealTaylorInput a) (2 * n + 2)) n =
      canonicalCayleyCoefficient a (actualXiRealTaylorInput a) n :=
        (actual_xi_finite_interpolant_rodrigues a n).symm
    _ = (NativeSoloboloNegativity.xiWidderDirect a n : ℂ) :=
      actual_xi_canonical_cayley_coefficients a ha n

/-- Actual xi Widder coefficients equal their finite canonical Cayley
coefficient at every regular positive anchor and every depth. -/
theorem actual_xi_all_depth_finite_cayley_coefficients
    (a : ℝ) (ha : a ∈ NativeSoloboloNegativity.xiRegularAnchors)
    (n : ℕ) :
    canonicalCayleyCoefficient a (actualXiRealTaylorInput a) n =
      (NativeSoloboloNegativity.xiWidderMoment a n : ℂ) := by
  exact real_rodrigues_compatibility_implies_actual_widder_coefficients
    actualXiRealRodriguesCompatibility_proven a ha n

end
end KQGPBKQRHilbert.AllDepth
