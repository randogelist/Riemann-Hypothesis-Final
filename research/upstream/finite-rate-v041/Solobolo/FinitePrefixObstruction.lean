import Solobolo.FiniteStartAdmission

/-!
# Why finite numerical prefix tests do NOT yield RH witness soundness

At every finite observation depth N there exist two abstract SOLOBOLO
spectral ledgers with identical residuals at indices 0,...,N but opposite
answers to the off-line mass question. Thus a Boolean check that depends
ONLY on a fixed prefix cannot be both sound and complete for these ledgers.
A genuine finite RH witness must encode a certified UNIFORM theorem.
-/

namespace Solobolo.HypotheticalRH

/-- A zero-offline-mass ledger, residual 1 through depth N and then zero. -/
def prefixZeroMassProfile (N : ℕ) : DyadicProfile where
  offMass := 0
  tail := fun n => if n ≤ N then 1 else 0
  offMass_nonneg := by norm_num
  tail_nonneg := by
    intro n
    split_ifs <;> norm_num
  tail_step_le := by
    intro n
    change (if n + 1 ≤ N then (1 : ℝ) else 0) ≤
      (if n ≤ N then (1 : ℝ) else 0)
    split_ifs <;> norm_num <;> omega
  tail_small := by
    intro ε hε
    refine ⟨N + 1, ?_⟩
    have hn : ¬ N + 1 ≤ N := by omega
    simpa [hn] using hε

/-- A strictly positive off-line floor, residual constantly one. -/
def prefixPositiveMassProfile : DyadicProfile where
  offMass := 1
  tail := fun _ => 0
  offMass_nonneg := by norm_num
  tail_nonneg := by intro _; norm_num
  tail_step_le := by intro _; norm_num
  tail_small := by
    intro ε hε
    exact ⟨0, by simpa using hε⟩

theorem prefixZeroMassProfile_noOffLineMass (N : ℕ) :
    NoOffLineMass (prefixZeroMassProfile N) := by
  rfl

theorem prefixPositiveMassProfile_not_noOffLineMass :
    ¬ NoOffLineMass prefixPositiveMassProfile := by
  norm_num [NoOffLineMass, prefixPositiveMassProfile]

/-- The two opposite ledgers have the same first N+1 observations. -/
theorem prefix_residuals_agree (N n : ℕ) (hn : n ≤ N) :
    residual (prefixZeroMassProfile N) n =
      residual prefixPositiveMassProfile n := by
  simp [residual, prefixZeroMassProfile, prefixPositiveMassProfile, hn]

/-- No fixed-depth boolean classifier of residual values can decide no-offline
mass for all admissible abstract ledgers. -/
theorem no_finite_prefix_decider (N : ℕ)
    (f : (Fin (N + 1) → ℝ) → Bool)
    (hsound : ∀ p : DyadicProfile,
      f (fun j => residual p j.val) = true → NoOffLineMass p)
    (hcomplete : ∀ p : DyadicProfile,
      NoOffLineMass p → f (fun j => residual p j.val) = true) : False := by
  have hfun :
      (fun j : Fin (N + 1) => residual (prefixZeroMassProfile N) j.val) =
      (fun j : Fin (N + 1) => residual prefixPositiveMassProfile j.val) := by
    funext j
    exact prefix_residuals_agree N j.val (Nat.lt_succ_iff.mp j.isLt)
  have hgood := hcomplete (prefixZeroMassProfile N)
    (prefixZeroMassProfile_noOffLineMass N)
  rw [hfun] at hgood
  exact prefixPositiveMassProfile_not_noOffLineMass
    (hsound prefixPositiveMassProfile hgood)

#print axioms no_finite_prefix_decider

end Solobolo.HypotheticalRH
