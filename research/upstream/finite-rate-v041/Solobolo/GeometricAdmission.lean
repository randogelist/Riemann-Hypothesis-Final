import Solobolo.QuarterContraction

/-!
# A third hypothetical admission: one uniform geometric tail

This strengthens the abstract epsilon criterion but needs the explicit
analytic tail-quarter-rate hypothesis for its reverse implication.
No finite witness and no actual-zero identification is used.
-/

namespace Solobolo.HypotheticalRH

/-- A uniform geometric residual bound starting at some finite stage. -/
def GeometricAdmission (p : DyadicProfile) : Prop :=
  ∃ N : ℕ, ∃ C : ℝ, 0 ≤ C ∧ ∀ k : ℕ,
    residual p (N + k) ≤ C * (3 / 4 : ℝ) ^ k

/-- Quarter admission already gives this geometric bound by induction. -/
theorem quarterAdmission_implies_geometricAdmission (p : DyadicProfile) :
    QuarterAdmission p → GeometricAdmission p := by
  rintro ⟨N, hs⟩
  exact ⟨N, residual p N, residual_nonneg p N,
    quarter_geometric_induction p N hs⟩

/-- The geometric bound forces arbitrarily small residuals. -/
theorem geometricAdmission_implies_epsilonAdmission (p : DyadicProfile) :
    GeometricAdmission p → EpsilonAdmission p := by
  rintro ⟨N, C, hC, hs⟩ ε hε
  have hden : 0 < C + 1 := by linarith
  obtain ⟨k, hk⟩ := exists_pow_lt_of_lt_one
    (show 0 < ε / (C + 1) by positivity)
    (show (3 / 4 : ℝ) < 1 by norm_num)
  have hpower : 0 ≤ (3 / 4 : ℝ) ^ k :=
    pow_nonneg (by norm_num) k
  have hbound : (3 / 4 : ℝ) ^ k * (C + 1) < ε :=
    (lt_div_iff₀ hden).mp hk
  refine ⟨N + k, ?_⟩
  have hh := hs k
  nlinarith [mul_nonneg hpower (show 0 ≤ 1 by norm_num)]

/-- No-offline-mass iff the strong geometric admission, once the
    specifically named analytic tail-quarter-rate is available. -/
theorem geometricAdmission_iff_noOffLineMass_of_tailRate
    (p : DyadicProfile) (hrate : TailQuarterRate p) :
    GeometricAdmission p ↔ NoOffLineMass p := by
  constructor
  · intro h
    exact (epsilonAdmission_iff_noOffLineMass p).mp
      (geometricAdmission_implies_epsilonAdmission p h)
  · intro h
    exact quarterAdmission_implies_geometricAdmission p
      (noOffLineMass_implies_quarterAdmission_of_tailRate p hrate h)

#print axioms geometricAdmission_iff_noOffLineMass_of_tailRate

end Solobolo.HypotheticalRH
