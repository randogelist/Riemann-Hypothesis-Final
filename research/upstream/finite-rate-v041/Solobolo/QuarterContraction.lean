import Solobolo.ScalarAdmission

/-!
# Hypothetical SOLOBOLO quarter-admission: universal successor

The forward direction (quarter admission -> RH ledger) is proved by a
geometric induction. The reverse direction uses the clearly named
`TailQuarterRate`, the substantive analytic estimate derived classically
under RH from the Riemann-von Mangoldt zero-counting asymptotic.
-/

namespace Solobolo.HypotheticalRH

/-- Each certified dyadic block gives a 3/4 contraction. -/
theorem quarter_step_ratio (p : DyadicProfile) (n : ℕ)
    (h : (4 : ℝ) * block p n ≥ residual p n) :
    residual p (n + 1) ≤ (3 / 4 : ℝ) * residual p n := by
  dsimp [block] at h
  linarith

/-- No analytic limit theorem is needed for this universal geometric induction. -/
theorem quarter_geometric_induction (p : DyadicProfile) (N : ℕ)
    (hs : ∀ n ≥ N, (4 : ℝ) * block p n ≥ residual p n)
    (k : ℕ) :
    residual p (N + k) ≤ (3 / 4 : ℝ) ^ k * residual p N := by
  induction k with
  | zero => simp
  | succ k ih =>
      have hN : N ≤ N + k := Nat.le_add_right N k
      calc
        residual p (N + (k + 1)) = residual p ((N + k) + 1) := by
          simp [Nat.add_assoc]
        _ ≤ (3 / 4 : ℝ) * residual p (N + k) :=
          quarter_step_ratio p (N + k) (hs (N + k) hN)
        _ ≤ (3 / 4 : ℝ) * ((3 / 4 : ℝ) ^ k * residual p N) :=
          mul_le_mul_of_nonneg_left ih (by norm_num)
        _ = (3 / 4 : ℝ) ^ (k + 1) * residual p N := by
          rw [pow_succ]
          ring

/-- Quarter-admission yields the epsilon-admission, without tail asymptotics. -/
theorem quarterAdmission_implies_epsilonAdmission (p : DyadicProfile) :
    QuarterAdmission p → EpsilonAdmission p := by
  rintro ⟨N, hs⟩ ε hε
  have hden : 0 < residual p N + 1 := by
    have hn := residual_nonneg p N
    linarith
  have hq : (3 / 4 : ℝ) < 1 := by norm_num
  obtain ⟨k, hk⟩ :=
    exists_pow_lt_of_lt_one (show 0 < ε / (residual p N + 1) by positivity) hq
  have hkpos : 0 ≤ (3 / 4 : ℝ) ^ k :=
    pow_nonneg (by norm_num) k
  have hsmall : (3 / 4 : ℝ) ^ k * (residual p N + 1) < ε :=
    (lt_div_iff₀ hden).mp hk
  have hscale :
      (3 / 4 : ℝ) ^ k * residual p N ≤
      (3 / 4 : ℝ) ^ k * (residual p N + 1) :=
    mul_le_mul_of_nonneg_left (by linarith) hkpos
  refine ⟨N + k, ?_⟩
  exact lt_of_le_of_lt (quarter_geometric_induction p N hs k)
    (lt_of_le_of_lt hscale hsmall)

/-- This implication has **no** zero-density or tail-rate premise. -/
theorem quarterAdmission_implies_noOffLineMass (p : DyadicProfile) :
    QuarterAdmission p → NoOffLineMass p := by
  intro h
  exact (epsilonAdmission_iff_noOffLineMass p).mp
    (quarterAdmission_implies_epsilonAdmission p h)

/-- Classical RH-tail rate is precisely what supplies the converse. -/
theorem noOffLineMass_implies_quarterAdmission_of_tailRate
    (p : DyadicProfile) (hrate : TailQuarterRate p) :
    NoOffLineMass p → QuarterAdmission p := by
  intro hz
  obtain ⟨N, hs⟩ := hrate
  refine ⟨N, ?_⟩
  intro n hn
  have hh := hs n hn
  change p.offMass = 0 at hz
  simpa [block_eq_tail_difference, residual, hz] using hh

/-- Exact conditional dyadic equivalence; tail-rate input is not hidden. -/
theorem quarterAdmission_iff_noOffLineMass_of_tailRate
    (p : DyadicProfile) (hrate : TailQuarterRate p) :
    QuarterAdmission p ↔ NoOffLineMass p := by
  constructor
  · exact quarterAdmission_implies_noOffLineMass p
  · exact noOffLineMass_implies_quarterAdmission_of_tailRate p hrate

#print axioms quarterAdmission_implies_noOffLineMass
#print axioms quarterAdmission_iff_noOffLineMass_of_tailRate

end Solobolo.HypotheticalRH
