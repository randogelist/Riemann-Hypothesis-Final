import FiniteWitness.TelescopicSpectrum

/-!
# Finite rational Gram-factor certificate for ODD_ZETA / ZETA_HYPERBOLIC

The checker verifies an exact finite matrix-entry factorization against the
rational target. This is a genuine finite algebra check, not an assumption
that the actual zeta/xi Gram matrix has already been factored.
-/

namespace WitnessSolobolo

/-- Finite rational Gram factorization data, with explicit target matrix. -/
structure RationalGramCertificate (rows cols : ℕ) where
  target : Matrix (Fin cols) (Fin cols) ℚ
  factor : Matrix (Fin rows) (Fin cols) ℚ

/-- A decidable, finite check of EVERY matrix entry. -/
def checkGram {rows cols : ℕ} (c : RationalGramCertificate rows cols) : Bool :=
  decide (∀ i j : Fin cols,
    c.target i j = ∑ k : Fin rows, c.factor k i * c.factor k j)

/-- No proof-valued hypothesis is hidden in the Gram witness. -/
theorem checkGram_sound {rows cols : ℕ}
    (c : RationalGramCertificate rows cols)
    (hc : checkGram c = true) :
    ∀ i j : Fin cols,
      c.target i j = ∑ k : Fin rows, c.factor k i * c.factor k j := by
  exact of_decide_eq_true hc

/-- The factor produces an exact rational sum of squares. -/
def gramSquareEnergy {rows cols : ℕ}
    (c : RationalGramCertificate rows cols) (v : Fin cols → ℚ) : ℚ :=
  ∑ k : Fin rows, (∑ i : Fin cols, c.factor k i * v i) ^ 2

/-- The Gram readout is nonnegative for EVERY rational test vector. -/
theorem gramSquareEnergy_nonneg {rows cols : ℕ}
    (c : RationalGramCertificate rows cols) (v : Fin cols → ℚ) :
    0 ≤ gramSquareEnergy c v := by
  unfold gramSquareEnergy
  apply Finset.sum_nonneg
  intro k hk
  exact sq_nonneg _

/-- A checker can verify that a submitted factor reproduces GP Hankel data. -/
def checkGPHankelFactor (Y : ℕ) {rows cols : ℕ}
    (L : Matrix (Fin rows) (Fin cols) ℚ) : Bool :=
  checkGram ({ target := gpHankel Y cols, factor := L } :
    RationalGramCertificate rows cols)

theorem checkGPHankelFactor_sound (Y : ℕ) {rows cols : ℕ}
    (L : Matrix (Fin rows) (Fin cols) ℚ)
    (h : checkGPHankelFactor Y L = true) :
    ∀ i j : Fin cols,
      gpHankel Y cols i j = ∑ k : Fin rows, L k i * L k j := by
  exact checkGram_sound _ h

end WitnessSolobolo
