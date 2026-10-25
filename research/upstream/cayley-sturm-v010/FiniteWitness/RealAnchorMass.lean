import FiniteWitness.CheckedDebitBudget

/-!
# All-real-anchor extension of the finite rational spectrum

The matrix/eigenvalues remain rational, but the evaluation anchor b is any
positive real. This is needed for the matched radius of an unknown zeta zero;
restricting only to rational b would lose the simplest extremal-pole argument.
-/

namespace WitnessSolobolo

/-- Real anchor transport of a rational spectral atom. -/
def realAnchorDenom (a b t : ℝ) : ℝ := a+(b-a)*t

def realAnchorMap (a b t : ℝ) : ℝ := b*t/realAnchorDenom a b t

def realCayleyQ (t : ℝ) : ℝ := 4*t*(1-t)

theorem realAnchorDenom_pos {a b t : ℝ}
    (ha : 0 < a) (hb : 0 < b) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    0 < realAnchorDenom a b t := by
  have heq : realAnchorDenom a b t = a*(1-t)+b*t := by
    unfold realAnchorDenom
    ring
  rw [heq]
  by_cases ht : t = 0
  · simp [ht, ha]
  · have htp : 0 < t := lt_of_le_of_ne ht0 (Ne.symm ht)
    have hleft : 0 ≤ a*(1-t) :=
      mul_nonneg ha.le (sub_nonneg.mpr ht1)
    have hright : 0 < b*t := mul_pos hb htp
    linarith

theorem realAnchorMap_unit {a b t : ℝ}
    (ha : 0 < a) (hb : 0 < b) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    0 ≤ realAnchorMap a b t ∧ realAnchorMap a b t ≤ 1 := by
  have hd := realAnchorDenom_pos ha hb ht0 ht1
  have hn : 0 ≤ b*t := mul_nonneg hb.le ht0
  constructor
  · exact div_nonneg hn hd.le
  · unfold realAnchorMap
    apply (div_le_iff₀ hd).2
    have hh : 0 ≤ a*(1-t) :=
      mul_nonneg ha.le (sub_nonneg.mpr ht1)
    unfold realAnchorDenom
    nlinarith

/-- Real version of the sharp anchor coefficient max(1,b/a). -/
theorem realAnchorMap_le_sharp {a b t : ℝ}
    (ha : 0 < a) (hb : 0 < b) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    realAnchorMap a b t ≤ max 1 (b/a)*t := by
  have hd := realAnchorDenom_pos ha hb ht0 ht1
  by_cases hab : a ≤ b
  · have hmax : 1 ≤ b/a := (le_div_iff₀ ha).2 (by nlinarith)
    rw [max_eq_right hmax]
    have hden : a ≤ realAnchorDenom a b t := by
      have hm : 0 ≤ (b-a)*t :=
        mul_nonneg (sub_nonneg.mpr hab) ht0
      unfold realAnchorDenom
      linarith
    have hfactor : 0 ≤ b*t/a :=
      div_nonneg (mul_nonneg hb.le ht0) ha.le
    have hm := mul_le_mul_of_nonneg_left hden hfactor
    have heq : (b*t/a)*a = b*t := by
      field_simp
      ring
    rw [heq] at hm
    unfold realAnchorMap
    apply (div_le_iff₀ hd).2
    calc
      b*t ≤ (b*t/a)*realAnchorDenom a b t := hm
      _ = (b/a*t)*realAnchorDenom a b t := by ring
  · have hba : b ≤ a := le_of_not_ge hab
    have hmax : b/a ≤ 1 := (div_le_iff₀ ha).2 (by nlinarith)
    rw [max_eq_left hmax, one_mul]
    have hden : b ≤ realAnchorDenom a b t := by
      have hh : 0 ≤ (a-b)*(1-t) :=
        mul_nonneg (sub_nonneg.mpr hba) (sub_nonneg.mpr ht1)
      unfold realAnchorDenom
      nlinarith
    have hm := mul_le_mul_of_nonneg_left hden ht0
    unfold realAnchorMap
    apply (div_le_iff₀ hd).2
    nlinarith

theorem realCayleyQ_unit {t : ℝ} (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    0 ≤ realCayleyQ t ∧ realCayleyQ t ≤ 1 := by
  have h0 : 0 ≤ 4*t*(1-t) :=
    mul_nonneg (mul_nonneg (by norm_num) ht0) (sub_nonneg.mpr ht1)
  have hs : 0 ≤ (1-2*t)^2 := sq_nonneg _
  unfold realCayleyQ
  constructor
  · exact h0
  · nlinarith

theorem realCayleyQ_power_bound {t : ℝ}
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) (p : ℕ) :
    (realCayleyQ t)^(p+1) ≤ 4*t := by
  have hq := realCayleyQ_unit ht0 ht1
  have hpow : (realCayleyQ t)^p ≤ 1 :=
    pow_le_one₀ hq.1 hq.2
  have hbase : realCayleyQ t ≤ 4*t := by
    unfold realCayleyQ
    calc
      4*t*(1-t) ≤ 4*t*1 :=
        mul_le_mul_of_nonneg_left (by linarith) (by positivity)
      _ = 4*t := by ring
  calc
    (realCayleyQ t)^(p+1) = (realCayleyQ t)^p * realCayleyQ t :=
      pow_succ _ _
    _ ≤ 1*realCayleyQ t := mul_le_mul_of_nonneg_right hpow hq.1
    _ = realCayleyQ t := one_mul _
    _ ≤ 4*t := hbase

/-- All real positive anchors; rank and atoms still come from one rational
finite witness generator. -/
def allRealAnchorTrace
    (w : FiniteWitness) (N p : ℕ) (a b : ℝ) : ℝ :=
  ∑ i : Fin (N+1+w.rankOffset),
    (realCayleyQ (realAnchorMap a b ((atom w N i : ℚ) : ℝ)))^(p+1)

/-- Rank-independent all-real-anchor estimate, using only finite contraction. -/
theorem allRealAnchorTrace_bound
    (w : FiniteWitness) (N p : ℕ) {a b : ℝ}
    (ha : 0 < a) (hb : 0 < b)
    (h : ∀ i : Fin (N+1+w.rankOffset),
      0 ≤ atom w N i ∧ atom w N i ≤ 1) :
    0 ≤ allRealAnchorTrace w N p a b ∧
    allRealAnchorTrace w N p a b ≤
      4*max 1 (b/a)*((mass w N : ℚ) : ℝ) := by
  constructor
  · unfold allRealAnchorTrace
    apply Finset.sum_nonneg
    intro i hi
    have h0 : (0:ℝ) ≤ (atom w N i : ℚ) := by exact_mod_cast (h i).1
    have h1 : ((atom w N i : ℚ) : ℝ) ≤ 1 := by exact_mod_cast (h i).2
    have hu := realAnchorMap_unit ha hb h0 h1
    exact pow_nonneg (realCayleyQ_unit hu.1 hu.2).1 _
  · calc
      allRealAnchorTrace w N p a b ≤
        ∑ i : Fin (N+1+w.rankOffset),
          4*max 1 (b/a)*((atom w N i : ℚ) : ℝ) := by
        unfold allRealAnchorTrace
        apply Finset.sum_le_sum
        intro i hi
        have h0 : (0:ℝ) ≤ ((atom w N i : ℚ) : ℝ) :=
          by exact_mod_cast (h i).1
        have h1 : ((atom w N i : ℚ) : ℝ) ≤ 1 :=
          by exact_mod_cast (h i).2
        have hu := realAnchorMap_unit ha hb h0 h1
        have hsharp := realAnchorMap_le_sharp ha hb h0 h1
        calc
          (realCayleyQ (realAnchorMap a b ((atom w N i : ℚ) : ℝ)))^(p+1) ≤
              4*realAnchorMap a b ((atom w N i : ℚ) : ℝ) :=
            realCayleyQ_power_bound hu.1 hu.2 p
          _ ≤ 4*(max 1 (b/a)*((atom w N i : ℚ) : ℝ)) :=
            mul_le_mul_of_nonneg_left hsharp (by norm_num)
          _ = 4*max 1 (b/a)*((atom w N i : ℚ) : ℝ) := by ring
      _ = 4*max 1 (b/a)*((mass w N : ℚ) : ℝ) := by
        rw [← Finset.mul_sum]
        congr 1
        simp only [mass]
        norm_cast

/-- The original rational mass certificate yields a concrete upper bound for
ALL REAL anchors, even an unknown irrational radius chosen by an off-line zero. -/
theorem allLevel_allRealAnchorTrace_le
    (w : FiniteWitness) (hw : AllLevelContractive w)
    (N p : ℕ) {a b : ℝ} (ha : 0<a) (hb : 0<b) :
    allRealAnchorTrace w N p a b ≤ 4*max 1 (b/a) := by
  have hc := (allRealAnchorTrace_bound w N p ha hb (hw N).1).2
  have hm : ((mass w N : ℚ) : ℝ) ≤ 1 := by
    exact_mod_cast (hw N).2
  have hmax : 0 ≤ (4:ℝ)*max 1 (b/a) := by
    have : 0 ≤ max (1:ℝ) (b/a) :=
      le_trans (by norm_num) (le_max_left _ _)
    positivity
  calc
    allRealAnchorTrace w N p a b ≤
      4*max 1 (b/a)*((mass w N : ℚ) : ℝ) := hc
    _ ≤ 4*max 1 (b/a)*1 := mul_le_mul_of_nonneg_left hm hmax
    _ = 4*max 1 (b/a) := mul_one _

end WitnessSolobolo
