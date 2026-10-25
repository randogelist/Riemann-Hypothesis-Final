import RHForward.AtomicMoments

/-!
# RH-forward Gram–Sturm objects on each finite packet

No assertion of positivity for the COMPLETE actual xi/Hausdorff sequence
is made without the infinite divisor identity. All Gram forms here are
finite and manifestly sums of squares.
-/

namespace RHForward

/-- Polynomial feature evaluated on a finite contractive packet. -/
noncomputable def UnitSpectrum.feature {d n : ℕ}
    (s : UnitSpectrum d) (c : Fin n → ℝ) (i : Fin d) : ℝ :=
  ∑ j : Fin n, c j * (s.atom i)^j.val

/-- First Hausdorff localizing Gram quadratic form. -/
noncomputable def UnitSpectrum.gramShifted {d n : ℕ}
    (s : UnitSpectrum d) (c : Fin n → ℝ) : ℝ :=
  ∑ i : Fin d, (s.atom i)^2 * (s.feature c i)^2

/-- Complementary Hausdorff localizing Gram quadratic form. -/
noncomputable def UnitSpectrum.gramComplement {d n : ℕ}
    (s : UnitSpectrum d) (c : Fin n → ℝ) : ℝ :=
  ∑ i : Fin d, s.atom i * (1 - s.atom i) * (s.feature c i)^2

theorem UnitSpectrum.gramShifted_nonneg {d n : ℕ}
    (s : UnitSpectrum d) (c : Fin n → ℝ) :
    0 ≤ s.gramShifted c := by
  unfold UnitSpectrum.gramShifted
  apply Finset.sum_nonneg
  intro i _
  exact mul_nonneg (sq_nonneg _) (sq_nonneg _)

theorem UnitSpectrum.gramComplement_nonneg {d n : ℕ}
    (s : UnitSpectrum d) (c : Fin n → ℝ) :
    0 ≤ s.gramComplement c := by
  unfold UnitSpectrum.gramComplement
  apply Finset.sum_nonneg
  intro i _
  have hi := s.bounded i
  exact mul_nonneg
    (mul_nonneg hi.1 (sub_nonneg.mpr hi.2))
    (sq_nonneg _)

/-- The exact finite Hankel matrix of the packet. -/
noncomputable def UnitSpectrum.hankel {d : ℕ}
    (s : UnitSpectrum d) (n : ℕ) : Matrix (Fin n) (Fin n) ℝ :=
  fun i j => s.moment (i.val + j.val)

/-- The exact shifted Hankel matrix of the packet. -/
noncomputable def UnitSpectrum.shiftedHankel {d : ℕ}
    (s : UnitSpectrum d) (n : ℕ) : Matrix (Fin n) (Fin n) ℝ :=
  fun i j => s.moment (i.val + j.val + 1)

/-- The exact complementary Hausdorff matrix of the packet. -/
noncomputable def UnitSpectrum.complementHankel {d : ℕ}
    (s : UnitSpectrum d) (n : ℕ) : Matrix (Fin n) (Fin n) ℝ :=
  fun i j => s.moment (i.val + j.val) -
    s.moment (i.val + j.val + 1)

theorem UnitSpectrum.hankel_symmetric {d : ℕ}
    (s : UnitSpectrum d) (n : ℕ) (i j : Fin n) :
    s.hankel n i j = s.hankel n j i := by
  unfold UnitSpectrum.hankel
  rw [Nat.add_comm i.val j.val]

theorem UnitSpectrum.shiftedHankel_symmetric {d : ℕ}
    (s : UnitSpectrum d) (n : ℕ) (i j : Fin n) :
    s.shiftedHankel n i j = s.shiftedHankel n j i := by
  unfold UnitSpectrum.shiftedHankel
  rw [Nat.add_comm i.val j.val]

theorem UnitSpectrum.complementHankel_symmetric {d : ℕ}
    (s : UnitSpectrum d) (n : ℕ) (i j : Fin n) :
    s.complementHankel n i j = s.complementHankel n j i := by
  unfold UnitSpectrum.complementHankel
  rw [Nat.add_comm i.val j.val]

/-- RH => finite Gram localizing sums of squares for every actual zero packet. -/
theorem RH_TO_FINITE_GRAM {d n : ℕ}
    (hRH : _root_.RiemannHypothesis)
    (p : NativeZeroPacket d) (a : ℝ) (ha : 0 < a)
    (coeff : Fin n → ℝ) :
    0 ≤ ((criticalPacket_of_RH hRH p).toUnitSpectrum a ha).gramShifted coeff ∧
    0 ≤ ((criticalPacket_of_RH hRH p).toUnitSpectrum a ha).gramComplement coeff := by
  exact ⟨UnitSpectrum.gramShifted_nonneg _ _,
    UnitSpectrum.gramComplement_nonneg _ _⟩

end RHForward
