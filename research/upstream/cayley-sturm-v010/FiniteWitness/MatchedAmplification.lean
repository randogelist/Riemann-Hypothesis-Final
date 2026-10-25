import FiniteWitness.CheckedDebitBudget

/-!
# QQRH × SOLOBOLO matched-radius spectral amplification

For an actual xi zero rho=1/2+beta+i*gamma, gamma ≠ 0, the associated
complex theta scale has modulus L=gamma²+beta². Its Cayley factor satisfies
  |q_a| = 4aL / ((a-L)²+4a gamma²).
The following finite ordered-field algebra isolates the exact peak. No
unproved zeta-zero property is used to establish these REAL inequalities.
-/

namespace WitnessSolobolo

def channelScale (beta gamma : ℝ) : ℝ := gamma^2+beta^2

def channelMagnitude (a beta gamma : ℝ) : ℝ :=
  4*a*channelScale beta gamma /
    ((a-channelScale beta gamma)^2 + 4*a*gamma^2)

def channelPeak (beta gamma : ℝ) : ℝ :=
  channelScale beta gamma / gamma^2

/-- Modulus is maximized by the matched positive radius a = gamma²+beta². -/
theorem channelMagnitude_le_peak
    {a beta gamma : ℝ} (ha : 0 < a) (hgamma : gamma ≠ 0) :
    channelMagnitude a beta gamma ≤ channelPeak beta gamma := by
  have hg : 0 < gamma^2 := sq_pos_of_ne_zero hgamma
  have hL : 0 < channelScale beta gamma := by
    unfold channelScale
    nlinarith [sq_nonneg beta]
  have hprod : 0 < a*gamma^2 := mul_pos ha hg
  have hden : 0 < (a-channelScale beta gamma)^2 + 4*a*gamma^2 := by
    nlinarith [sq_nonneg (a-channelScale beta gamma)]
  unfold channelMagnitude channelPeak
  apply (div_le_div_iff₀ hden hg).2
  have hsq : 0 ≤ channelScale beta gamma *
      (a-channelScale beta gamma)^2 :=
    mul_nonneg hL.le (sq_nonneg _)
  nlinarith

/-- The exact matched radius attains the upper bound. -/
theorem channelMagnitude_matched
    {beta gamma : ℝ} (hgamma : gamma ≠ 0) :
    channelMagnitude (channelScale beta gamma) beta gamma =
      channelPeak beta gamma := by
  have hg : 0 < gamma^2 := sq_pos_of_ne_zero hgamma
  have hL : 0 < channelScale beta gamma := by
    unfold channelScale
    nlinarith [sq_nonneg beta]
  have hden : (4*channelScale beta gamma*gamma^2) ≠ 0 := by
    positivity
  unfold channelMagnitude channelPeak
  have hdeneq :
      (channelScale beta gamma - channelScale beta gamma)^2 +
        4*channelScale beta gamma*gamma^2 =
        4*channelScale beta gamma*gamma^2 := by ring
  rw [hdeneq]
  field_simp
  ring

/-- An off-line displacement beta ≠ 0 yields amplification strictly above 1. -/
theorem channelPeak_gt_one
    {beta gamma : ℝ} (hbeta : beta ≠ 0) (hgamma : gamma ≠ 0) :
    1 < channelPeak beta gamma := by
  have hg : 0 < gamma^2 := sq_pos_of_ne_zero hgamma
  have hb : 0 < beta^2 := sq_pos_of_ne_zero hbeta
  unfold channelPeak channelScale
  apply (lt_div_iff₀ hg).2
  nlinarith

end WitnessSolobolo
