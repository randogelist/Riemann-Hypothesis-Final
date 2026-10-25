import FiniteWitness.TraceInduction

/-!
# SOLOBOLO rational anchor transport

For actual RH-zero scale λ, u_a = a/(a+λ). Algebraically,
  u_b = b*u_a / (a+(b-a)*u_a).
The following statements are proved for every rational positive contraction;
identification of a finite spectrum with the *actual* theta zeros is NOT here.
-/

namespace WitnessSolobolo

/-- Denominator for change of spectral anchor a -> b. -/
def anchorDenom (a b t : ℚ) : ℚ := a + (b - a) * t

/-- Möbius transport of a contraction between two positive anchors. -/
def anchorTransport (a b t : ℚ) : ℚ := b * t / anchorDenom a b t

/-- The transformed denominator is a positive convex combination. -/
theorem anchorDenom_pos {a b t : ℚ}
    (ha : 0 < a) (hb : 0 < b) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    0 < anchorDenom a b t := by
  have hid : anchorDenom a b t = a * (1 - t) + b * t := by
    unfold anchorDenom
    ring
  rw [hid]
  by_cases hzero : t = 0
  · simp [hzero, ha]
  · have htp : 0 < t := lt_of_le_of_ne ht0 (Ne.symm hzero)
    have hleft : 0 ≤ a * (1 - t) :=
      mul_nonneg ha.le (sub_nonneg.mpr ht1)
    have hright : 0 < b * t := mul_pos hb htp
    linarith

/-- Anchor transport preserves the closed interval [0,1]. -/
theorem anchorTransport_unit_interval {a b t : ℚ}
    (ha : 0 < a) (hb : 0 < b) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    0 ≤ anchorTransport a b t ∧ anchorTransport a b t ≤ 1 := by
  have hd : 0 < anchorDenom a b t := anchorDenom_pos ha hb ht0 ht1
  have hn : 0 ≤ b * t := mul_nonneg hb.le ht0
  constructor
  · exact div_nonneg hn hd.le
  · apply (div_le_iff₀ hd).2
    change b * t ≤ anchorDenom a b t
    have hh : 0 ≤ a * (1 - t) :=
      mul_nonneg ha.le (sub_nonneg.mpr ht1)
    unfold anchorDenom
    nlinarith

/-- A positive anchor acts as the identity when source and target agree. -/
theorem anchorTransport_self {a t : ℚ} (ha : 0 < a) :
    anchorTransport a a t = t := by
  have hne : a ≠ 0 := ne_of_gt ha
  simp [anchorTransport, anchorDenom, hne]

/-- Change of anchor is functorial on positive contractive spectra. -/
theorem anchorTransport_comp {a b c t : ℚ}
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    anchorTransport b c (anchorTransport a b t) =
      anchorTransport a c t := by
  have hab : anchorDenom a b t ≠ 0 :=
    ne_of_gt (anchorDenom_pos ha hb ht0 ht1)
  have hac : anchorDenom a c t ≠ 0 :=
    ne_of_gt (anchorDenom_pos ha hc ht0 ht1)
  have ht' := anchorTransport_unit_interval ha hb ht0 ht1
  have hbc : anchorDenom b c (anchorTransport a b t) ≠ 0 :=
    ne_of_gt (anchorDenom_pos hb hc ht'.1 ht'.2)
  unfold anchorTransport anchorDenom at *
  field_simp
  ring

/-- Transported finite Cayley atoms remain nonnegative contractions. -/
theorem anchorTransport_cayley_unit_interval {a b t : ℚ}
    (ha : 0 < a) (hb : 0 < b) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    0 ≤ cayleyQ (anchorTransport a b t) ∧
      cayleyQ (anchorTransport a b t) ≤ 1 := by
  have ht := anchorTransport_unit_interval ha hb ht0 ht1
  exact cayleyQ_unit_interval ht.1 ht.2

/-- A single finite spectrum provides a whole family of positive-anchor
SOLOBOLO Mersenne traces, without changing the selected atoms. -/
def transportedCayleyTrace
    (w : FiniteWitness) (N k : ℕ) (a b : ℚ) : ℚ :=
  ∑ i : Fin (N + 1 + w.rankOffset),
    (cayleyQ (anchorTransport a b (atom w N i))) ^ (2 ^ k)

/-- Every transported positive-anchor trace is contractive along Mersenne
depths. No additional per-anchor spectra are chosen. -/
theorem transportedCayleyTrace_step
    (w : FiniteWitness) (N k : ℕ) {a b : ℚ}
    (ha : 0 < a) (hb : 0 < b)
    (h : ∀ i : Fin (N + 1 + w.rankOffset),
      0 ≤ atom w N i ∧ atom w N i ≤ 1) :
    transportedCayleyTrace w N (k + 1) a b ≤
      transportedCayleyTrace w N k a b := by
  unfold transportedCayleyTrace
  apply Finset.sum_le_sum
  intro i hi
  have ht := anchorTransport_cayley_unit_interval ha hb (h i).1 (h i).2
  exact scalar_mersenne_step ht.1 ht.2 k

end WitnessSolobolo
