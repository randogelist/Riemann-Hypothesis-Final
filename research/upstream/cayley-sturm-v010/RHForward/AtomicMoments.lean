import RHForward.NativeZeros

/-!
# Positive Cayley packets and complete finite Hausdorff cells

Finite sums ONLY. These theorems do not silently identify a finite packet
with the complete divisor of xi. The actual infinite identification is
recorded separately as the unresolved analytic boundary.
-/

namespace RHForward

/-- Every finite positive contraction spectrum gives all Hausdorff cells. -/
structure UnitSpectrum (d : ℕ) where
  atom : Fin d → ℝ
  bounded : ∀ i : Fin d, 0 ≤ atom i ∧ atom i ≤ 1

/-- Finite moment corresponding to the logarithmic derivative of a determinant. -/
noncomputable def UnitSpectrum.moment {d : ℕ}
    (s : UnitSpectrum d) (k : ℕ) : ℝ :=
  ∑ i : Fin d, (s.atom i)^(k + 1)

/-- Hausdorff cell; in a finite positive packet it is manifestly nonnegative. -/
noncomputable def UnitSpectrum.cell {d : ℕ}
    (s : UnitSpectrum d) (n k : ℕ) : ℝ :=
  ∑ i : Fin d, (s.atom i)^(n + 1) * (1 - s.atom i)^k

theorem UnitSpectrum.cell_nonneg {d : ℕ}
    (s : UnitSpectrum d) (n k : ℕ) : 0 ≤ s.cell n k := by
  unfold UnitSpectrum.cell
  apply Finset.sum_nonneg
  intro i _
  exact mul_nonneg (pow_nonneg (s.bounded i).1 _)
    (pow_nonneg (sub_nonneg.mpr (s.bounded i).2) _)

theorem UnitSpectrum.moment_nonneg {d : ℕ}
    (s : UnitSpectrum d) (n : ℕ) : 0 ≤ s.moment n := by
  unfold UnitSpectrum.moment
  exact Finset.sum_nonneg (fun i _ => pow_nonneg (s.bounded i).1 _)

/-- The exact Pascal splitting is also an all-depth universal induction rule. -/
theorem UnitSpectrum.cell_split {d : ℕ}
    (s : UnitSpectrum d) (n k : ℕ) :
    s.cell n k = s.cell (n + 1) k + s.cell n (k + 1) := by
  unfold UnitSpectrum.cell
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro i _
  have hh : s.atom i + (1 - s.atom i) = 1 := by ring
  calc
    (s.atom i)^(n + 1) * (1 - s.atom i)^k =
        (s.atom i)^(n + 1) * (1 - s.atom i)^k *
          (s.atom i + (1 - s.atom i)) := by rw [hh]; ring
    _ = (s.atom i)^(n + 1 + 1) * (1 - s.atom i)^k +
          (s.atom i)^(n + 1) * (1 - s.atom i)^(k + 1) := by
      simp only [pow_succ]
      ring

/-- The full finite Hausdorff hierarchy follows without another premise. -/
theorem UnitSpectrum.all_cells {d : ℕ}
    (s : UnitSpectrum d) :
    ∀ n k : ℕ, 0 ≤ s.cell n k := by
  intro n k
  exact s.cell_nonneg n k

/-- Cayley moments decrease in depth on every shared finite spectrum. -/
theorem UnitSpectrum.moment_succ_le {d : ℕ}
    (s : UnitSpectrum d) (n : ℕ) :
    s.moment (n + 1) ≤ s.moment n := by
  unfold UnitSpectrum.moment
  apply Finset.sum_le_sum
  intro i _
  have hi := s.bounded i
  calc
    (s.atom i)^(n + 1 + 1) = (s.atom i)^(n + 1) * s.atom i := by
      rw [pow_succ]
    _ ≤ (s.atom i)^(n + 1) * 1 :=
      mul_le_mul_of_nonneg_left hi.2 (pow_nonneg hi.1 _)
    _ = (s.atom i)^(n + 1) := by ring

/-- Mersenne cofinal trace monotonicity from one common finite spectrum. -/
noncomputable def UnitSpectrum.mersenneTrace {d : ℕ}
    (s : UnitSpectrum d) (k : ℕ) : ℝ :=
  ∑ i : Fin d, (s.atom i)^(2^k)

theorem UnitSpectrum.mersenneTrace_step {d : ℕ}
    (s : UnitSpectrum d) (k : ℕ) :
    s.mersenneTrace (k + 1) ≤ s.mersenneTrace k := by
  unfold UnitSpectrum.mersenneTrace
  apply Finset.sum_le_sum
  intro i _
  have hi := s.bounded i
  have hpow0 : 0 ≤ (s.atom i)^(2^k) := pow_nonneg hi.1 _
  have hpow1 : (s.atom i)^(2^k) ≤ 1 := by
    have hpow : ∀ m : ℕ, (s.atom i)^m ≤ 1 := by
      intro m
      induction m with
      | zero => simp
      | succ m ih =>
        calc
          (s.atom i)^(m+1) = (s.atom i)^m * s.atom i := pow_succ _ _
          _ ≤ (s.atom i)^m * 1 :=
            mul_le_mul_of_nonneg_left hi.2 (pow_nonneg hi.1 _)
          _ = (s.atom i)^m := mul_one _
          _ ≤ 1 := ih
    exact hpow _
  calc
    (s.atom i)^(2^(k + 1)) = ((s.atom i)^(2^k))^2 := by
      rw [pow_succ, pow_mul]
    _ = (s.atom i)^(2^k) * (s.atom i)^(2^k) := pow_two _
    _ ≤ (s.atom i)^(2^k) * 1 :=
      mul_le_mul_of_nonneg_left hpow1 hpow0
    _ = (s.atom i)^(2^k) := by ring

/-- The finite spectrum obtained FROM RH and genuine zeta zero occurrences. -/
noncomputable def CriticalZeroPacket.toUnitSpectrum {d : ℕ}
    (p : CriticalZeroPacket d) (a : ℝ) (ha : 0 < a) :
    UnitSpectrum d where
  atom := fun i => cayleyQ
    (cayleyU a ((p.source.zeroAt i).point.im^2))
  bounded := by
    intro i
    exact real_scale_cayley_contracts ha (sq_nonneg _)

/-- RH => all finite actual-zero Cayley Hausdorff cells. -/
theorem RH_TO_FINITE_HAUSDORFF {d : ℕ}
    (hRH : _root_.RiemannHypothesis)
    (p : NativeZeroPacket d) (a : ℝ) (ha : 0 < a) :
    ∀ n k, 0 ≤
      ((criticalPacket_of_RH hRH p).toUnitSpectrum a ha).cell n k := by
  intro n k
  exact UnitSpectrum.cell_nonneg _ n k

/-- RH => cofinal trace contraction on EVERY finite genuine-zero packet. -/
theorem RH_TO_FINITE_MERSENNE {d : ℕ}
    (hRH : _root_.RiemannHypothesis)
    (p : NativeZeroPacket d) (a : ℝ) (ha : 0 < a) :
    ∀ k,
      ((criticalPacket_of_RH hRH p).toUnitSpectrum a ha).mersenneTrace (k+1) ≤
      ((criticalPacket_of_RH hRH p).toUnitSpectrum a ha).mersenneTrace k := by
  intro k
  exact UnitSpectrum.mersenneTrace_step _ k

end RHForward
