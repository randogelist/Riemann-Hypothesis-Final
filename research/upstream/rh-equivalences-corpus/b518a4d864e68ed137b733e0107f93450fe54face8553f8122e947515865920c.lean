import Mathlib.NumberTheory.LSeries.Nonvanishing

namespace ConstructiveWeakRH

/-- The literal nontrivial-zero predicate used by Mathlib's
`RiemannHypothesis`: an actual zeta zero, excluding the trivial negative-even
zeros and the pole at one. -/
def NontrivialZetaZero (rho : ℂ) : Prop :=
  riemannZeta rho = 0 ∧
    (¬ ∃ n : ℕ, rho = -2 * ((n : ℂ) + 1)) ∧
    rho ≠ 1

/-- Membership in the open critical strip. -/
def InOpenCriticalStrip (rho : ℂ) : Prop :=
  0 < rho.re ∧ rho.re < 1

/-- A literal nontrivial zeta zero is not the complex number zero. -/
theorem nontrivialZetaZero_ne_zero
    {rho : ℂ} (hz : NontrivialZetaZero rho) : rho ≠ 0 := by
  intro hrho
  subst rho
  have hzero := hz.1
  rw [riemannZeta_zero] at hzero
  norm_num at hzero

/-- Zero-freeness on `Re(s) ≥ 1` gives the strict right-hand boundary of the
critical strip. -/
theorem nontrivialZetaZero_re_lt_one
    {rho : ℂ} (hz : NontrivialZetaZero rho) : rho.re < 1 := by
  by_contra hnot
  have hge : 1 ≤ rho.re := le_of_not_gt hnot
  exact (riemannZeta_ne_zero_of_one_le_re hge) hz.1

/-- The completed-zeta functional equation reflects every literal nontrivial
zero across `Re(s)=1/2`. -/
theorem nontrivialZetaZero_one_sub
    {rho : ℂ} (hz : NontrivialZetaZero rho) :
    NontrivialZetaZero (1 - rho) := by
  have hrho0 : rho ≠ 0 := nontrivialZetaZero_ne_zero hz
  have hGamma : rho.Gammaℝ ≠ 0 := by
    intro hGamma0
    rcases Complex.Gammaℝ_eq_zero_iff.mp hGamma0 with ⟨n, hn⟩
    cases n with
    | zero =>
        apply hrho0
        simpa using hn
    | succ n =>
        apply hz.2.1
        refine ⟨n, ?_⟩
        calc
          rho = -(2 * (↑(Nat.succ n) : ℂ)) := hn
          _ = -2 * ((n : ℂ) + 1) := by
            push_cast
            ring
  have hdef := riemannZeta_def_of_ne_zero hrho0
  rw [hz.1] at hdef
  have hcompleted : completedRiemannZeta rho = 0 := by
    have hdiv : completedRiemannZeta rho / rho.Gammaℝ = 0 := hdef.symm
    exact (div_eq_zero_iff.mp hdiv).resolve_right hGamma
  have hrefCompleted : completedRiemannZeta (1 - rho) = 0 := by
    rw [completedRiemannZeta_one_sub rho]
    exact hcompleted
  have href0 : 1 - rho ≠ 0 := by
    intro h
    apply hz.2.2
    calc
      rho = 1 - (1 - rho) := by ring
      _ = 1 - 0 := by rw [h]
      _ = 1 := by ring
  have hrefZeta : riemannZeta (1 - rho) = 0 := by
    rw [riemannZeta_def_of_ne_zero href0, hrefCompleted, zero_div]
  have hrefTrivial : ¬ ∃ n : ℕ, 1 - rho = -2 * ((n : ℂ) + 1) := by
    rintro ⟨n, hn⟩
    have hreEq := congrArg Complex.re hn
    have hn0 : (0 : ℝ) ≤ (n : ℝ) := by positivity
    have hre : 1 ≤ rho.re := by
      simp at hreEq
      linarith
    exact (riemannZeta_ne_zero_of_one_le_re hre) hz.1
  have href1 : 1 - rho ≠ 1 := by
    intro h
    apply hrho0
    calc
      rho = 1 - (1 - rho) := by ring
      _ = 1 - 1 := by rw [h]
      _ = 0 := by ring
  exact ⟨hrefZeta, hrefTrivial, href1⟩

/-- Reflection plus the same right-half-plane zero-free theorem gives the
strict left-hand boundary of the critical strip. -/
theorem nontrivialZetaZero_re_pos
    {rho : ℂ} (hz : NontrivialZetaZero rho) : 0 < rho.re := by
  have href : NontrivialZetaZero (1 - rho) :=
    nontrivialZetaZero_one_sub hz
  have hrefLt : (1 - rho : ℂ).re < 1 :=
    nontrivialZetaZero_re_lt_one href
  simp at hrefLt
  linarith

/-- Constructive weak RH at one supplied literal nontrivial zero: the zero lies
strictly inside the classical critical strip. No RH/passivity/BKQR hypothesis is
used. -/
theorem constructiveWeakRHAt
    {rho : ℂ} (hz : NontrivialZetaZero rho) :
    InOpenCriticalStrip rho := by
  exact ⟨nontrivialZetaZero_re_pos hz, nontrivialZetaZero_re_lt_one hz⟩

/-- Universal pointwise formulation: every supplied literal nontrivial zeta zero
lies in the open critical strip. This is critical-strip localization, not the
Riemann Hypothesis (which would require `rho.re = 1/2`). -/
theorem constructiveWeakRH :
    ∀ rho : ℂ, NontrivialZetaZero rho → InOpenCriticalStrip rho := by
  intro rho hz
  exact constructiveWeakRHAt hz

end ConstructiveWeakRH
