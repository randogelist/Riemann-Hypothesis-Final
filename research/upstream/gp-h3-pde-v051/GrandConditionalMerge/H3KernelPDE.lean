import GrandConditionalMerge.H3ActualZero

/-!
# Universal Cayley kernel: algebraic Widder PDE and recursion uniqueness

The cleared-denominator identity is entirely algebraic and hence does not
assume RH, the Theta/Widder Taylor binding, or any positivity of actual Xi.
The analytic task is to transport this kernel PDE to the literal Theta Cayley
observable, including its real anchor derivative and regular germ at r=0.
-/

namespace GrandConditionalMerge

noncomputable section

/-- Quadratic denominator of the universal complex Cayley kernel. -/
def h3KernelQ (a r z : ℂ) : ℂ := (z - a)^2 + 4 * a * r * z

/-- Numerator of the kernel `K = N/Q`. -/
def h3KernelN (a z : ℂ) : ℂ := 4 * a * z

/-- Formal partial derivative `∂_a Q`. -/
def h3KernelQa (a r z : ℂ) : ℂ := 2 * (a - z) + 4 * r * z

/--
After multiplying by Q^3, this is the exact polynomial form of
(2*r*∂r+3)∂r K = 2*((r*∂r+1)^2-a*∂a-a^2*∂a^2) K,
where K(a,r;z) = 4*a*z / ((z-a)^2 + 4*a*r*z).

This lemma has **no nonvanishing or analyticity hypotheses**: it is a
polynomial identity. To obtain the rational PDE, separately require Q ≠ 0
and justify the quotient differentiation rules.
-/
theorem h3_cayley_widder_pde_cleared (a r z : ℂ) :
    4 * r * (h3KernelN a z)^3 -
        3 * (h3KernelN a z)^2 * h3KernelQ a r z =
      4 * r^2 * (h3KernelN a z)^3 -
        6 * r * (h3KernelN a z)^2 * h3KernelQ a r z +
        2 * h3KernelN a z * (h3KernelQ a r z)^2 -
        2 * a * (4 * z * h3KernelQ a r z -
          h3KernelN a z * h3KernelQa a r z) * h3KernelQ a r z +
        2 * a^2 * (8 * z * h3KernelQa a r z +
          2 * h3KernelN a z) * h3KernelQ a r z -
        4 * a^2 * h3KernelN a z * (h3KernelQa a r z)^2 := by
  simp only [h3KernelN, h3KernelQ, h3KernelQa]
  ring

/-- Coefficients satisfying exactly the pre-existing SOLOBOLO Widder
    recurrence and base term are the actual xiWidderMoment at every depth. -/
theorem h3_widder_coefficient_recursion_unique
    (c : ℕ → ℝ → ℝ)
    (hzero : c 0 = NativeSoloboloNegativity.xiWidderBase)
    (hstep : ∀ n : ℕ, c (n + 1) =
      (fun a => NativeSoloboloNegativity.widderStep n (c n) a)) :
    ∀ n : ℕ, c n =
      (fun a => NativeSoloboloNegativity.xiWidderMoment a n) := by
  intro n
  induction n with
  | zero =>
      simpa only [NativeSoloboloNegativity.xiWidderMoment,
        NativeSoloboloNegativity.widderTower] using hzero
  | succ n ih =>
      rw [hstep n, ih]
      rfl

end
end GrandConditionalMerge
