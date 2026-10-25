import Mathlib

/-!
# Actual native ξ/Θ binding

This is the actual Mathlib `completedRiemannZeta₀`, not a freely chosen model.
The complex square root specifies a local germ at the positive anchor; global
entireness of the descended Θ and its zero correspondence are NOT proved here.
-/

noncomputable section

namespace WitnessSolobolo

/-- Classical entire completion, normalized by ξ(1)=1/2. -/
def actualXi (s : ℂ) : ℂ :=
  (1 + s * (s - 1) * completedRiemannZeta₀ s) / 2

/-- Square-descent expression of the centered completed ξ function. -/
def actualTheta (z : ℂ) : ℂ :=
  actualXi ((1 : ℂ) / 2 + Complex.sqrt z)

/-- Fixed anchor `a = 1/4`. -/
def anchor : ℂ := (1 : ℂ) / 4

/-- Actual normalized local germ in the affine variable `z`. -/
def actualGerm (z : ℂ) : ℂ :=
  actualTheta (anchor * (1 + z)) / actualTheta anchor

/-- Actual Taylor jet. Its real-valuedness and Taylor-series reconstruction
are analytical obligations, rather than definitional assumptions. -/
def actualComplexCoefficient (n : ℕ) : ℂ :=
  iteratedDeriv n actualGerm 0 / (Nat.factorial n : ℂ)

/-- Real part of the actual Taylor coefficient, the target of rational layers. -/
def actualCoefficient (n : ℕ) : ℝ :=
  (actualComplexCoefficient n).re

end WitnessSolobolo
