import FiniteWitness.PositiveSyntax

/-!
# Nontrivial globally certified rational spectra

This checks an entire infinite family, not just a finite seed. The checker
accepts a rational scale in [0,1]. The generated atoms telescope, so every
finite layer has all spectral atoms in [0,1] and total mass at most 1.

Crucially, this theorem does NOT identify these toy atoms with actual xi.
-/

namespace WitnessSolobolo

/-- The basic nonnegative rational atom. -/
def telescopicBase (i : ℕ) : ℚ :=
  1 / ((i : ℚ) + 1) - 1 / ((i : ℚ) + 2)

theorem telescopicBase_nonneg (i : ℕ) : 0 ≤ telescopicBase i := by
  have h := (Nat.one_div_le_one_div (α := ℚ) (Nat.le_succ i))
  have h' : (1 : ℚ) / ((i : ℚ) + 2) ≤ 1 / ((i : ℚ) + 1) := by
    simpa [Nat.cast_add, add_assoc] using h
  exact sub_nonneg.mpr h'

theorem telescopicBase_le_one (i : ℕ) : telescopicBase i ≤ 1 := by
  have h := (Nat.one_div_le_one_div (α := ℚ) (Nat.zero_le i))
  have h' : (1 : ℚ) / ((i : ℚ) + 1) ≤ 1 := by
    simpa using h
  have hn : 0 ≤ (1 : ℚ) / ((i : ℚ) + 2) := by positivity
  dsimp [telescopicBase]
  linarith

/-- Exact telescope of the rational spectral atoms. -/
theorem telescopicBase_sum (n : ℕ) :
    (∑ i ∈ Finset.range n, telescopicBase i) =
      1 - 1 / ((n : ℚ) + 1) := by
  simpa [telescopicBase, Nat.cast_add, add_assoc] using
    (rational_debit_telescope (fun i : ℕ => (1 : ℚ) / ((i : ℚ) + 1)) n)

/-- A finite rational certificate for an infinite family of spectra. -/
structure TelescopicCertificate where
  scale : ℚ
  deriving Repr

def checkTelescopic (c : TelescopicCertificate) : Bool :=
  decide (0 ≤ c.scale ∧ c.scale ≤ 1)

theorem checkTelescopic_sound (c : TelescopicCertificate)
    (hc : checkTelescopic c = true) :
    0 ≤ c.scale ∧ c.scale ≤ 1 := by
  exact of_decide_eq_true hc

def telescopicAtom (c : TelescopicCertificate) (i : ℕ) : ℚ :=
  c.scale * telescopicBase i

theorem telescopicAtom_unit_interval (c : TelescopicCertificate)
    (hc : checkTelescopic c = true) (i : ℕ) :
    0 ≤ telescopicAtom c i ∧ telescopicAtom c i ≤ 1 := by
  have hs := checkTelescopic_sound c hc
  have hb0 := telescopicBase_nonneg i
  have hb1 := telescopicBase_le_one i
  constructor
  · exact mul_nonneg hs.1 hb0
  · calc
      telescopicAtom c i = c.scale * telescopicBase i := rfl
      _ ≤ 1 * telescopicBase i := mul_le_mul_of_nonneg_right hs.2 hb0
      _ = telescopicBase i := one_mul _
      _ ≤ 1 := hb1

theorem telescopicAtom_sum_le_one (c : TelescopicCertificate)
    (hc : checkTelescopic c = true) (n : ℕ) :
    (∑ i ∈ Finset.range n, telescopicAtom c i) ≤ 1 := by
  have hs := checkTelescopic_sound c hc
  have hbase : (∑ i ∈ Finset.range n, telescopicBase i) ≤ 1 := by
    rw [telescopicBase_sum]
    have hnonneg : 0 ≤ (1 : ℚ) / ((n : ℚ) + 1) := by positivity
    linarith
  calc
    (∑ i ∈ Finset.range n, telescopicAtom c i) =
        c.scale * (∑ i ∈ Finset.range n, telescopicBase i) := by
          simp [telescopicAtom, Finset.mul_sum]
    _ ≤ c.scale * 1 := mul_le_mul_of_nonneg_left hbase hs.1
    _ = c.scale := mul_one _
    _ ≤ 1 := hs.2

/-- Compile the mathematical family into the v0.1 finite rational syntax. -/
def telescopicWitness (c : TelescopicCertificate) : FiniteWitness where
  baseDepth := 0
  rankOffset := 0
  atomRule := .mul (.lit c.scale)
    (.add (.div (.lit 1) (.add .slot (.lit 1)))
      (.mul (.lit (-1)) (.div (.lit 1) (.add .slot (.lit 2)))))
  certificate := []

theorem atom_telescopicWitness (c : TelescopicCertificate)
    (N : ℕ) (i : Fin (N + 1 + (telescopicWitness c).rankOffset)) :
    atom (telescopicWitness c) N i = telescopicAtom c i.val := by
  simp [atom, telescopicWitness, RatTerm.eval, telescopicAtom, telescopicBase]
  ring

/-- TRUE universal checker soundness: all generated layers are contractions. -/
theorem telescopicWitness_allLevelContractive (c : TelescopicCertificate)
    (hc : checkTelescopic c = true) :
    AllLevelContractive (telescopicWitness c) := by
  intro N
  constructor
  · intro i
    rw [atom_telescopicWitness]
    exact telescopicAtom_unit_interval c hc i.val
  · unfold mass
    simp_rw [atom_telescopicWitness]
    rw [Fin.sum_univ_eq_sum_range (telescopicAtom c) (N + 1)]
    exact telescopicAtom_sum_le_one c hc (N + 1)

/-- An actual, accepted, nonzero finite certificate for UNIVERSAL algebra only. -/
def exampleTelescopic : TelescopicCertificate := ⟨1 / 2⟩

example : checkTelescopic exampleTelescopic = true := by decide

end WitnessSolobolo
