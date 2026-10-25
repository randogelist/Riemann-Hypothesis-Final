import Mathlib

/-!
# GP7.FiniteDyadic

An unconditional, fully finite dyadic polylogarithm identity over ℚ.
Its analytic infinite-series/jet limit is kept separate and is NOT claimed
as a Lean theorem by this module.
-/

namespace GP7

private def term (n : ℕ) : ℚ := 1 / (((n + 1 : ℕ) : ℚ) ^ 7)
private def oddTerm (n : ℕ) : ℚ := 1 / (((2 * n + 1 : ℕ) : ℚ) ^ 7)
private def evenTerm (n : ℕ) : ℚ := 1 / (((2 * n + 2 : ℕ) : ℚ) ^ 7)

/-- Finite odd-even Dirichlet sum. -/
def etaPairPartial (N : ℕ) : ℚ :=
  ∑ n ∈ Finset.range N, (oddTerm n - evenTerm n)

/-- Finite paired nonalternating Dirichlet sum. -/
def zetaPairPartial (N : ℕ) : ℚ :=
  ∑ n ∈ Finset.range N, (oddTerm n + evenTerm n)

/-- Finite ordinary Dirichlet sum. -/
def zetaPartial (N : ℕ) : ℚ :=
  ∑ n ∈ Finset.range N, term n

private theorem even_term_eq (n : ℕ) :
    evenTerm n = (1 / 128 : ℚ) * term n := by
  have hcast : ((2 * n + 2 : ℕ) : ℚ) = 2 * ((n + 1 : ℕ) : ℚ) := by
    push_cast
    ring
  have hne : ((n + 1 : ℕ) : ℚ) ≠ 0 := by exact_mod_cast Nat.succ_ne_zero n
  unfold evenTerm term
  rw [hcast]
  field_simp
  ring

/-- An exact dyadic identity at every finite level; no analytic premises. -/
theorem finite_dyadic_pair (N : ℕ) :
    etaPairPartial N = zetaPairPartial N - (1 / 64 : ℚ) * zetaPartial N := by
  calc
    etaPairPartial N =
        ∑ n ∈ Finset.range N,
          ((oddTerm n + evenTerm n) - (1 / 64 : ℚ) * term n) := by
      unfold etaPairPartial
      apply Finset.sum_congr rfl
      intro n hn
      rw [even_term_eq]
      ring
    _ = zetaPairPartial N - (1 / 64 : ℚ) * zetaPartial N := by
      simp [zetaPairPartial, zetaPartial, Finset.sum_sub_distrib, Finset.mul_sum]

end GP7
