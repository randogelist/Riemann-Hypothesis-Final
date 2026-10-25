import Solobolo.ScalarProfile

/-!
# Positive contribution of an individual off-line conjugate pair

At radius a = 1/4 the logarithmic derivative of the centered xi-product
receives 2 Re(1/(a + (gamma - i*delta)^2)) from an off-line pair.
This file proves positivity of the explicit real expression for any
nontrivial-strip displacement |delta| <= 1/2 and gamma > 0.
This does NOT yet formalize the full xi zero-product decomposition.
-/

namespace Solobolo.HypotheticalRH

def offPairMass (gamma delta : ℝ) : ℝ :=
  (2 * (gamma ^ 2 + (1 / 4 : ℝ) - delta ^ 2)) /
  ((gamma ^ 2 + (1 / 4 : ℝ) - delta ^ 2) ^ 2 +
   (2 * gamma * delta) ^ 2)

/-- No cancellation by a genuine off-line conjugate zero pair. -/
theorem offPairMass_pos (gamma delta : ℝ)
    (hgamma : 0 < gamma)
    (hlo : -(1 / 2 : ℝ) ≤ delta)
    (hhi : delta ≤ (1 / 2 : ℝ)) :
    0 < offPairMass gamma delta := by
  have hp : 0 ≤ (delta + (1 / 2 : ℝ)) * ((1 / 2 : ℝ) - delta) :=
    mul_nonneg (by linarith) (by linarith)
  have hg2 : 0 < gamma ^ 2 := sq_pos_of_pos hgamma
  have hu : 0 < gamma ^ 2 + (1 / 4 : ℝ) - delta ^ 2 := by
    nlinarith
  have hden :
      0 < (gamma ^ 2 + (1 / 4 : ℝ) - delta ^ 2) ^ 2 +
            (2 * gamma * delta) ^ 2 := by
    have hbase : 0 < (gamma ^ 2 + (1 / 4 : ℝ) - delta ^ 2) ^ 2 :=
      sq_pos_of_pos hu
    nlinarith [sq_nonneg (2 * gamma * delta)]
  unfold offPairMass
  exact div_pos (by linarith) hden

#print axioms offPairMass_pos

end Solobolo.HypotheticalRH
