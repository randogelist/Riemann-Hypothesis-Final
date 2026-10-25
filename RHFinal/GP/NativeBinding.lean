import RHFinal.GP.KQEndpoints
import RHFinal.Actual.Successor

/-!
# Literal logarithmic-derivative binding and the H3 Cayley-kernel algebra

KQEndpoints proves that both source families use the same entire xi and
principal-square-root theta. The logarithmic derivative below is then
definitionally the same literal derivative quotient.

The second theorem is the polynomial identity from the recovered H3 PDE
patch, adapted to this namespace without its unavailable imports. It does
not transport a PDE to the actual theta observable or its regularized germ.
Neither theorem establishes nonvanishing, Mellin factorization, real/complex
derivative compatibility, positivity of actual moments, or finite admission.
SOURCE_ONLY: native Lean 4.33 compilation and axiom audit remain pending.
-/

namespace RHFinal.GP.NativeBinding

/-- The derivative is literal on both sides, not an independently chosen field. -/
theorem actualLogDerivative_eq_native (z : ℂ) :
    RHFinal.Actual.actualLogDerivative z =
      NativeSolobolo.mathlibSlitThetaPrime z /
        NativeSolobolo.mathlibSlitTheta z := rfl

noncomputable section

/-- Quadratic denominator of the universal Cayley kernel. -/
def kernelQ (a r z : ℂ) : ℂ := (z - a) ^ 2 + 4 * a * r * z

/-- Numerator of K = N/Q. -/
def kernelN (a z : ℂ) : ℂ := 4 * a * z

/-- Formal polynomial derivative of Q with respect to a. -/
def kernelQa (a r z : ℂ) : ℂ := 2 * (a - z) + 4 * r * z

/-- The H3 kernel PDE after clearing Q cubed. This is polynomial algebra
only. Rational differentiation needs Q nonzero; actual-observable and Taylor
coefficient transport remain separate analytic obligations. -/
theorem cayley_widder_pde_cleared (a r z : ℂ) :
    4 * r * (kernelN a z) ^ 3 -
        3 * (kernelN a z) ^ 2 * kernelQ a r z =
      4 * r ^ 2 * (kernelN a z) ^ 3 -
        6 * r * (kernelN a z) ^ 2 * kernelQ a r z +
        2 * kernelN a z * (kernelQ a r z) ^ 2 -
        2 * a * (4 * z * kernelQ a r z -
          kernelN a z * kernelQa a r z) * kernelQ a r z +
        2 * a ^ 2 * (8 * z * kernelQa a r z +
          2 * kernelN a z) * kernelQ a r z -
        4 * a ^ 2 * kernelN a z * (kernelQa a r z) ^ 2 := by
  simp only [kernelN, kernelQ, kernelQa]
  ring

end

end RHFinal.GP.NativeBinding
