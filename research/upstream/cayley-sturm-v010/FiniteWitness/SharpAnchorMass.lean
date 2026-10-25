import FiniteWitness.AllAnchorMass

/-!
# Sharp one-anchor → all-anchor finite spectral control

Improvement: replace the previous budget 4(1+b/a) by 4 max(1,b/a).
All conclusions are exact rational inequalities for the *same* finite spectrum.
No real-zero, xi-identification, or RH hypothesis enters.
-/

namespace WitnessSolobolo

/-- The denominator is above the source anchor when a ≤ b. -/
theorem anchorDenom_ge_source {a b t : ℚ}
    (hab : a ≤ b) (ht : 0 ≤ t) :
    a ≤ anchorDenom a b t := by
  have h : 0 ≤ (b-a)*t :=
    mul_nonneg (sub_nonneg.mpr hab) ht
  unfold anchorDenom
  linarith

/-- The denominator is above the target anchor when b ≤ a. -/
theorem anchorDenom_ge_target {a b t : ℚ}
    (hba : b ≤ a) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    b ≤ anchorDenom a b t := by
  have h : 0 ≤ (a-b)*(1-t) :=
    mul_nonneg (sub_nonneg.mpr hba) (sub_nonneg.mpr ht1)
  unfold anchorDenom
  nlinarith

/-- The optimal simple mass-scale coefficient is max(1,b/a). -/
theorem anchorTransport_le_sharp {a b t : ℚ}
    (ha : 0 < a) (hb : 0 < b)
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    anchorTransport a b t ≤ max 1 (b/a)*t := by
  have hd : 0 < anchorDenom a b t :=
    anchorDenom_pos ha hb ht0 ht1
  by_cases hab : a ≤ b
  · have hcoef : 1 ≤ b/a := (le_div_iff₀ ha).2 (by nlinarith)
    rw [max_eq_right hcoef]
    have hden := anchorDenom_ge_source hab ht0
    have hnon : 0 ≤ b*t/a :=
      div_nonneg (mul_nonneg hb.le ht0) ha.le
    have hm := mul_le_mul_of_nonneg_left hden hnon
    have heq : (b*t/a)*a = b*t := by
      field_simp
      ring
    rw [heq] at hm
    unfold anchorTransport
    apply (div_le_iff₀ hd).2
    calc
      b*t ≤ (b*t/a)*anchorDenom a b t := hm
      _ = (b/a*t)*anchorDenom a b t := by ring
  · have hba : b ≤ a := le_of_not_ge hab
    have hcoef : b/a ≤ 1 := (div_le_iff₀ ha).2 (by nlinarith)
    rw [max_eq_left hcoef, one_mul]
    have hden := anchorDenom_ge_target hba ht0 ht1
    have hm := mul_le_mul_of_nonneg_left hden ht0
    unfold anchorTransport
    apply (div_le_iff₀ hd).2
    nlinarith

/-- Sharp all-anchor bound, uniform in finite rank and every power. -/
theorem allAnchorCayleyPowerTrace_sharp_bound
    (w : FiniteWitness) (N p : ℕ) {a b : ℚ}
    (ha : 0 < a) (hb : 0 < b)
    (h : ∀ i : Fin (N+1+w.rankOffset),
      0 ≤ atom w N i ∧ atom w N i ≤ 1) :
    0 ≤ allAnchorCayleyPowerTrace w N p a b ∧
    allAnchorCayleyPowerTrace w N p a b ≤
      4*max 1 (b/a)*mass w N := by
  have h0 := (allAnchorCayleyPowerTrace_bound w N p ha hb h).1
  refine ⟨h0, ?_⟩
  calc
    allAnchorCayleyPowerTrace w N p a b ≤
        ∑ i : Fin (N+1+w.rankOffset),
          4*max 1 (b/a)*atom w N i := by
      unfold allAnchorCayleyPowerTrace
      apply Finset.sum_le_sum
      intro i hi
      have hu := anchorTransport_unit_interval ha hb (h i).1 (h i).2
      have hq := cayleyQ_unit_interval hu.1 hu.2
      have hs := anchorTransport_le_sharp ha hb (h i).1 (h i).2
      calc
        (cayleyQ (anchorTransport a b (atom w N i)))^(p+1) ≤
          cayleyQ (anchorTransport a b (atom w N i)) :=
            power_succ_le_self_of_unit hq.1 hq.2 p
        _ ≤ 4*anchorTransport a b (atom w N i) :=
            cayleyQ_le_four_mul hu.1 hu.2
        _ ≤ 4*(max 1 (b/a)*atom w N i) :=
            mul_le_mul_of_nonneg_left hs (by norm_num)
        _ = 4*max 1 (b/a)*atom w N i := by ring
    _ = 4*max 1 (b/a)*mass w N := by
      simp only [mass, Finset.mul_sum]

end WitnessSolobolo
