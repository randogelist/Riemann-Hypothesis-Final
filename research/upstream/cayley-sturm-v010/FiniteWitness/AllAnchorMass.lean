import FiniteWitness.UniformCayleyMass
import FiniteWitness.AnchorTransport

/-!
# Uniform all-anchor finite trace estimates

A ONE-anchor trace-mass budget automatically controls all positive anchors.
The key lower bound is a positive polynomial-square identity, so no
spectral trace convergence / actual-xi assumption enters this proof.
-/

namespace WitnessSolobolo

/-- Elementary harmonic floor identity for the positive anchor denominator.
(a+b) * denominator - a*b = a²(1-t) + b²t >= 0. -/
theorem anchorDenom_harmonic_floor {a b t : ℚ}
    (ha : 0 < a) (hb : 0 < b)
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    a*b ≤ (a+b)*anchorDenom a b t := by
  have heq :
      (a+b)*anchorDenom a b t - a*b =
        a^2*(1-t) + b^2*t := by
    unfold anchorDenom
    ring
  have h0 : 0 ≤ a^2*(1-t) :=
    mul_nonneg (sq_nonneg _) (sub_nonneg.mpr ht1)
  have h1 : 0 ≤ b^2*t := mul_nonneg (sq_nonneg _) ht0
  linarith

/-- The transported eigenvalue is at most a fixed multiple of the
original eigenvalue, independent of rank, depth, and t. -/
theorem anchorTransport_le_mass_scale {a b t : ℚ}
    (ha : 0 < a) (hb : 0 < b)
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    anchorTransport a b t ≤ (1 + b/a) * t := by
  have hd := anchorDenom_pos ha hb ht0 ht1
  have hfloor := anchorDenom_harmonic_floor ha hb ht0 ht1
  have hnum := mul_le_mul_of_nonneg_right hfloor ht0
  have ha_ne : a ≠ 0 := ne_of_gt ha
  unfold anchorTransport
  apply (div_le_iff₀ hd).2
  have hid : (1+b/a)*t*anchorDenom a b t =
      ((a+b)*anchorDenom a b t*t)/a := by
    field_simp
    ring
  rw [hid]
  apply (le_div_iff₀ ha).2
  nlinarith [hnum]

/-- Positive anchor b, with one shared finite spectrum from anchor a. -/
def allAnchorCayleyPowerTrace
    (w : FiniteWitness) (N p : ℕ) (a b : ℚ) : ℚ :=
  ∑ i : Fin (N + 1 + w.rankOffset),
    (cayleyQ (anchorTransport a b (atom w N i))) ^ (p+1)

/-- All-anchor and all-depth trace budget with a constant independent
of N and p. This is fully algebraic. -/
theorem allAnchorCayleyPowerTrace_bound
    (w : FiniteWitness) (N p : ℕ) {a b : ℚ}
    (ha : 0 < a) (hb : 0 < b)
    (h : ∀ i : Fin (N + 1 + w.rankOffset),
      0 ≤ atom w N i ∧ atom w N i ≤ 1) :
    0 ≤ allAnchorCayleyPowerTrace w N p a b ∧
      allAnchorCayleyPowerTrace w N p a b ≤
        4 * (1+b/a) * mass w N := by
  constructor
  · unfold allAnchorCayleyPowerTrace
    apply Finset.sum_nonneg
    intro i hi
    have hunit := anchorTransport_cayley_unit_interval
      ha hb (h i).1 (h i).2
    exact pow_nonneg hunit.1 _
  · calc
      allAnchorCayleyPowerTrace w N p a b ≤
          ∑ i : Fin (N + 1 + w.rankOffset),
            4 * (1+b/a) * atom w N i := by
        unfold allAnchorCayleyPowerTrace
        apply Finset.sum_le_sum
        intro i hi
        have hi' := anchorTransport_unit_interval ha hb (h i).1 (h i).2
        have hq := cayleyQ_unit_interval hi'.1 hi'.2
        have hlinear := anchorTransport_le_mass_scale ha hb (h i).1 (h i).2
        calc
          (cayleyQ (anchorTransport a b (atom w N i))) ^ (p+1) ≤
              cayleyQ (anchorTransport a b (atom w N i)) :=
                power_succ_le_self_of_unit hq.1 hq.2 p
          _ ≤ 4 * anchorTransport a b (atom w N i) :=
                cayleyQ_le_four_mul hi'.1 hi'.2
          _ ≤ 4 * ((1+b/a) * atom w N i) :=
                mul_le_mul_of_nonneg_left hlinear (by norm_num)
          _ = 4 * (1+b/a) * atom w N i := by ring
      _ = 4 * (1+b/a) * mass w N := by
        simp only [mass, Finset.mul_sum]

/-- One Boolean-accepted telescoping witness supplies a bounded trace
for all radii, depths, and layer sizes. No claim of xi-calibration. -/
theorem checked_telescopic_allAnchor_bound
    (c : TelescopicCertificate) (hc : checkTelescopic c = true)
    {a b : ℚ} (ha : 0 < a) (hb : 0 < b)
    (N p : ℕ) :
    0 ≤ allAnchorCayleyPowerTrace (telescopicWitness c) N p a b ∧
      allAnchorCayleyPowerTrace (telescopicWitness c) N p a b ≤
        4 * (1+b/a) := by
  have h := telescopicWitness_allLevelContractive c hc N
  have hbnd := allAnchorCayleyPowerTrace_bound
      (telescopicWitness c) N p ha hb h.1
  constructor
  · exact hbnd.1
  · calc
      allAnchorCayleyPowerTrace (telescopicWitness c) N p a b ≤
          4 * (1+b/a) * mass (telescopicWitness c) N := hbnd.2
      _ ≤ 4 * (1+b/a) * 1 := by
        have hn : 0 ≤ 4 * (1+b/a) := by
          have : 0 ≤ b/a := div_nonneg hb.le ha.le
          positivity
        exact mul_le_mul_of_nonneg_left h.2 hn
      _ = 4 * (1+b/a) := mul_one _

end WitnessSolobolo
