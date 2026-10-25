import AllDepth.ActualPoleClosure

/-!
# All-depth radius-one summability and a genuine superunit growth obstruction

Two independent, purely analytic facts, WITHOUT assuming RH:

1. The all-depth subexponential envelope gives ABSOLUTE summability of
   the actual Xi-Widder radial coefficient series at every 0 <= r < 1.
   This proves convergence of the formal power series on real radii.
   It does not identify the series with SOLOBOLO's actual Theta observable.

2. A fixed superunit Cayley channel, if genuinely bounded below in ABSOLUTE
   coefficient magnitude by a positive multiple of q^n, defeats all b^n
   envelopes with b < q. The required lower bound is NOT a consequence of
   an off-line zero by itself. Its derivation requires noncancellation or the
   analytic continuation/pole argument, still outstanding.

No use of 2^k or Mersenne powers. No new axiom, sorry or research axiom.
-/

namespace KQGPBKQRHilbert.AllDepth

/-- Root-test direction: all-depth subexponential coefficient bounds
    imply absolute summability of the radial power series at EVERY real
    radius in the open unit disk. The coefficients may have either sign. -/
theorem subexp_radial_absolute_summable
    (W : ℝ → ℕ → ℝ) (a r : ℝ)
    (hsub : SubexponentialAt W a)
    (hr0 : 0 ≤ r) (hr1 : r < 1) :
    Summable (fun n : ℕ => |W a n * r ^ n|) := by
  let b : ℝ := (3 - r) / 2
  have hb : 1 < b := by
    dsimp [b]
    linarith
  have hb0 : 0 ≤ b := le_of_lt (lt_trans (by norm_num : (0 : ℝ) < 1) hb)
  have hbr0 : 0 ≤ b * r := mul_nonneg hb0 hr0
  have hfactor : 0 < (1 - r) * (2 - r) := by
    apply mul_pos <;> linarith
  have hbr1 : b * r < 1 := by
    dsimp [b]
    nlinarith
  obtain ⟨C, hC, hbound⟩ := hsub b hb
  have hgeo : Summable (fun n : ℕ => (b * r) ^ n) :=
    summable_geometric_of_lt_one hbr0 hbr1
  have hmajor : Summable (fun n : ℕ => C * (b * r) ^ n) :=
    hgeo.mul_left C
  refine hmajor.of_nonneg_of_le (fun n => abs_nonneg _) ?_
  intro n
  have hrpow : 0 ≤ r ^ n := pow_nonneg hr0 n
  calc
    |W a n * r ^ n| = |W a n| * r ^ n := by
      rw [abs_mul, abs_pow, abs_of_nonneg hr0]
    _ ≤ (C * b ^ n) * r ^ n :=
      mul_le_mul_of_nonneg_right (hbound n) hrpow
    _ = C * (b * r) ^ n := by rw [mul_pow]; ring

/-- Apply the radial root-test direction to SOLOBOLO's actual recursive
    ξ-Widder moments. The only hypothesis is the STILL-OPEN actual-xi
    subexponential estimate. -/
theorem actual_xi_radial_absolute_summable
    (hsub : ActualXiSubexponential)
    (a r : ℝ) (ha : 0 < a) (hr0 : 0 ≤ r) (hr1 : r < 1) :
    Summable (fun n : ℕ =>
      |NativeSoloboloNegativity.xiWidderMoment a n * r ^ n|) :=
  subexp_radial_absolute_summable _ a r (hsub a ha) hr0 hr1


/-- Complex disk root test: no Mersenne restriction. The entire complex
    Cayley coefficient power series is summable for every `‖z‖ < 1`.
    Identification with the actual Theta observable is a DIFFERENT problem. -/
theorem subexp_complex_disk_series_summable
    (W : ℝ → ℕ → ℝ) (a : ℝ)
    (hsub : SubexponentialAt W a)
    (z : ℂ) (hz : ‖z‖ < 1) :
    Summable (fun n : ℕ => (W a n : ℂ) * z ^ n) := by
  have habs := subexp_radial_absolute_summable W a ‖z‖
    hsub (norm_nonneg z) hz
  apply summable_norm_iff.mp
  have hpointwise (n : ℕ) :
      ‖(W a n : ℂ) * z ^ n‖ = |W a n * ‖z‖ ^ n| := by
    calc
      ‖(W a n : ℂ) * z ^ n‖ = |W a n| * ‖z‖ ^ n := by
        rw [norm_mul, norm_pow, Complex.norm_real, Real.norm_eq_abs]
      _ = |W a n * ‖z‖ ^ n| := by
        rw [abs_mul, abs_pow, abs_of_nonneg (norm_nonneg z)]
  simpa only [hpointwise] using habs

/-- Actual Xi-Widder complex power series converges if the main
    still-open `ActualXiSubexponential` predicate is supplied. -/
theorem actual_xi_complex_disk_series_summable
    (hsub : ActualXiSubexponential)
    (a : ℝ) (ha : 0 < a)
    (z : ℂ) (hz : ‖z‖ < 1) :
    Summable (fun n : ℕ =>
      (NativeSoloboloNegativity.xiWidderMoment a n : ℂ) * z ^ n) :=
  subexp_complex_disk_series_summable _ a (hsub a ha) z hz

/-- An honest geometric growth obstruction. The bound is assumed for
    ALL n; it is not obtained merely by naming a zero. -/
theorem superunit_lower_bound_forces_growth
    (W : ℕ → ℝ)
    (q w b C : ℝ)
    (hw : 0 < w) (hb : 0 < b) (hbq : b < q)
    (hdom : ∀ n : ℕ, w * q ^ n ≤ |W n|) :
    ∃ n : ℕ, C * b ^ n < |W n| := by
  have hratio : 1 < q / b := (one_lt_div hb).mpr hbq
  obtain ⟨n, hn⟩ := pow_unbounded_of_one_lt (C / w) hratio
  have hbpow : 0 < b ^ n := pow_pos hb n
  have hscaled : (C / w) * b ^ n < (q / b) ^ n * b ^ n :=
    mul_lt_mul_of_pos_right hn hbpow
  have hscaled' : w * ((C / w) * b ^ n) <
      w * ((q / b) ^ n * b ^ n) := mul_lt_mul_of_pos_left hscaled hw
  have hleft : w * ((C / w) * b ^ n) = C * b ^ n := by
    field_simp [ne_of_gt hw]
  have hright : w * ((q / b) ^ n * b ^ n) = w * q ^ n := by
    rw [div_pow]
    field_simp [ne_of_gt hb]
  refine ⟨n, ?_⟩
  calc
    C * b ^ n = w * ((C / w) * b ^ n) := hleft.symm
    _ < w * ((q / b) ^ n * b ^ n) := hscaled'
    _ = w * q ^ n := hright
    _ ≤ |W n| := hdom n

/-- Optional stronger sufficient condition: a positive lower bound
    which rules out channel cancellation for ALL depths. This is NOT
    provided by the abstract centered-zero structure. -/
def OffLineChannelDomination
    (X : NativeSolobolo.CenteredXiGeometry)
    (W : ℝ → ℕ → ℝ) : Prop :=
  ∀ z : X.Zero, X.beta z ≠ 0 →
    ∃ w : ℝ, 0 < w ∧
      ∀ n : ℕ, w * (X.cayleyQ z) ^ n ≤ |W (X.anchor z) n|

/-- Strong noncancellation at every off-line channel would establish
    the previously open CanonicalPoleGrowth predicate. -/
theorem domination_implies_canonical_pole_growth
    (X : NativeSolobolo.CenteredXiGeometry)
    (W : ℝ → ℕ → ℝ)
    (hdom : OffLineChannelDomination X W) :
    CanonicalPoleGrowth X W := by
  intro z hz b hb hbq C _hC
  obtain ⟨w, hw, hwbound⟩ := hdom z hz
  exact superunit_lower_bound_forces_growth
    (fun n => W (X.anchor z) n) (X.cayleyQ z) w b C
    hw (lt_trans (by norm_num : (0 : ℝ) < 1) hb) hbq hwbound

/-- A precise alternative conditional closure. In particular, this DOES
    NOT prove the actual-xi estimate or the domination hypothesis. -/
theorem subexp_and_domination_imply_centered_RH
    (X : NativeSolobolo.CenteredXiGeometry)
    (W : ℝ → ℕ → ℝ)
    (hsub : Subexponential W)
    (hdom : OffLineChannelDomination X W) :
    NativeSolobolo.RiemannHypothesis X :=
  subexponential_excludes_offline_zero X W hsub
    (domination_implies_canonical_pole_growth X W hdom)

end KQGPBKQRHilbert.AllDepth
