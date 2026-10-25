import FiniteWitness.RealAnchorMass

/-!
# Native xi: actual direct central Widder quantities

The source is the literal completed zeta, not an opaque model. The logarithmic
jet is formed at positive real anchors, where analytic nonvanishing is a
separate native lemma in the SOLOBOLO source family. Defining an expression
does not prove its positivity or identification with an arbitrary finite trace.
-/

noncomputable section

namespace WitnessSolobolo

/-- Actual complex logarithmic derivative (totalized only outside its regular
locus). Positive-real regularity is needed for the analytic divisor theorem. -/
def actualThetaR (z : ℂ) : ℂ := deriv actualTheta z / actualTheta z

/-- Actual direct logarithmic-derivative jet at arbitrary positive real anchor. -/
def actualDirectJet (a : ℝ) (n : ℕ) : ℂ :=
  (-1 : ℂ)^n * (a : ℂ)^(n+1) *
    (iteratedDeriv n actualThetaR (a : ℂ)) / (Nat.factorial n : ℂ)

/-- Literal central/Widder combination of the actual xi logarithmic jets:
W_n(a) = 4^(n+1) sum_{j=0}^{n+1} (-1)^j C(n+1,j) d_{n+j}(a).
Only the real part is taken; real-valuedness of the full expression is an
analytic native-binding theorem, not proved by this definition. -/
def actualCentralWidder (a : ℝ) (n : ℕ) : ℝ :=
  ((4 : ℂ)^(n+1) *
      ∑ j ∈ Finset.range (n+2),
        (-1 : ℂ)^j * (Nat.choose (n+1) j : ℂ) *
          actualDirectJet a (n+j)).re

/-- Precise missing actual-xi calibration: all depths and all real anchors.
One approximate layer at each requested accuracy suffices; there is no need
to assume a prechosen rate or all-layer convergence. -/
def AllRealAnchorActualWidderCalibration (w : FiniteWitness) : Prop :=
  ∀ b : ℝ, 0 < b → ∀ p : ℕ, ∀ ε : ℝ, 0 < ε →
    ∃ N : ℕ,
      |allRealAnchorTrace w N p (1/4) b - actualCentralWidder b p| ≤ ε

/-- A calibrated family with the genuine finite mass bound controls every
actual Widder depth at each real anchor, with no Hurwitz step. -/
theorem calibrated_actualWidder_bounded
    (w : FiniteWitness) (hw : AllLevelContractive w)
    (hcal : AllRealAnchorActualWidderCalibration w)
    (b : ℝ) (hb : 0 < b) (p : ℕ) :
    actualCentralWidder b p ≤ 4*max 1 (b/(1/4 : ℝ)) := by
  let C : ℝ := 4*max 1 (b/(1/4 : ℝ))
  by_contra hno
  have hgap : C < actualCentralWidder b p := lt_of_not_ge hno
  let ε : ℝ := (actualCentralWidder b p-C)/2
  have hε : 0 < ε := by dsimp [ε]; linarith
  obtain ⟨N, happrox⟩ := hcal b hb p ε hε
  have hbound : allRealAnchorTrace w N p (1/4) b ≤ C := by
    dsimp [C]
    exact allLevel_allRealAnchorTrace_le w hw N p (by norm_num) hb
  have hleft := (abs_le.mp happrox).1
  dsimp [ε] at hleft
  linarith

end WitnessSolobolo
