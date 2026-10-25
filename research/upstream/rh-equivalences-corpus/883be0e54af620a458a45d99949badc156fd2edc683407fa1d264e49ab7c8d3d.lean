import Derivations.Hopf.HopfPassivity

namespace RHGPBKQR.Derivations.Hopf

open RHGPBKQR
open RHGPBKQR.Frontier

/-- !!! Pascal-Hopf boundary identity: the `k = 0` edge is exactly the GP jet. -/
theorem PASCAL_HOPF_BOUNDARY (d : OurStrongData) (n : Nat) :
    d.bkqr.table.value n 0 = d.jet.coeff n :=
  d.bkqr.table.boundary n

/-- !!! Pascal-Hopf exact two-child recursion. -/
theorem PASCAL_HOPF_RECURSION (d : OurStrongData) (n k : Nat) :
    d.bkqr.table.value n k =
      d.bkqr.table.value (n + 1) k + d.bkqr.table.value n (k + 1) :=
  d.bkqr.table.split n k

/--
!!! STRONG IDENTITY
Every Pascal-Hopf node is exactly the signed Hausdorff finite difference of its
boundary sequence.
-/
theorem PASCAL_NODE_EQ_HAUSDORFF_DIFF
    {c : Nat → Int} (t : PascalHopfTable c) :
    ∀ n k : Nat, t.value n k = HausdorffDiff c n k := by
  intro n k
  induction k generalizing n with
  | zero =>
      exact t.boundary n
  | succ k ih =>
      rw [HausdorffDiff]
      rw [← ih n, ← ih (n + 1)]
      rw [t.split n k]
      omega

/--
!!! Primitive nonnegative BKQR energy proves complete Hausdorff
finite-difference positivity for its boundary sequence.
-/
theorem BKQR_ENERGY_TO_SEQUENCE_HAUSDORFF
    {c : Nat → Int} (e : BKQREnergyData c) :
    SequenceHausdorffPositive c := by
  intro n k
  refine ⟨e.energy n k, ?_⟩
  calc
    HausdorffDiff c n k = e.table.value n k :=
      (PASCAL_NODE_EQ_HAUSDORFF_DIFF e.table n k).symm
    _ = Int.ofNat (e.energy n k) := rfl

/-- !!! Positive Pascal-Hopf data imply Hausdorff positivity. -/
theorem POSITIVE_PASCAL_TO_SEQUENCE_HAUSDORFF
    {c : Nat → Int} (p : PositivePascalHopfData c) :
    SequenceHausdorffPositive c := by
  intro n k
  have hEq : p.table.value n k = HausdorffDiff c n k :=
    PASCAL_NODE_EQ_HAUSDORFF_DIFF p.table n k
  rw [← hEq]
  exact p.positive n k

/--
!!! Reverse Pascal construction: Hausdorff finite differences themselves form
an exact positive Pascal-Hopf lattice.
-/
def HAUSDORFF_TO_POSITIVE_PASCAL_DATA
    {c : Nat → Int} (h : SequenceHausdorffPositive c) :
    PositivePascalHopfData c where
  value := HausdorffDiff c
  boundary := by
    intro n
    rfl
  split := by
    intro n k
    have hrec :
        HausdorffDiff c n (k + 1) =
          HausdorffDiff c n k - HausdorffDiff c (n + 1) k := rfl
    omega
  positive := h

/-- !!! Hausdorff positivity iff positive Pascal-Hopf realizability. -/
theorem SEQUENCE_HAUSDORFF_IFF_POSITIVE_PASCAL
    {c : Nat → Int} :
    SequenceHausdorffPositive c ↔ Nonempty (PositivePascalHopfData c) := by
  constructor
  · intro h
    exact ⟨HAUSDORFF_TO_POSITIVE_PASCAL_DATA h⟩
  · intro h
    exact Nonempty.elim h POSITIVE_PASCAL_TO_SEQUENCE_HAUSDORFF

/-- ! Chosen natural energy representative of each Hausdorff difference. -/
noncomputable def HausdorffEnergy
    {c : Nat → Int} (h : SequenceHausdorffPositive c) (n k : Nat) : Nat :=
  Classical.choose (h n k)

/-- !! The chosen energy represents the corresponding Hausdorff difference. -/
theorem HAUSDORFF_ENERGY_SPEC
    {c : Nat → Int} (h : SequenceHausdorffPositive c) (n k : Nat) :
    HausdorffDiff c n k = Int.ofNat (HausdorffEnergy h n k) :=
  Classical.choose_spec (h n k)

/--
!!! Reverse BKQR-energy construction: every integer-valued Hausdorff-positive
sequence canonically has a natural-valued Pascal energy lattice (chosen noncomputably
through choice of the nonnegative representatives).
-/
noncomputable def HAUSDORFF_TO_BKQR_ENERGY_DATA
    {c : Nat → Int} (h : SequenceHausdorffPositive c) : BKQREnergyData c where
  energy := HausdorffEnergy h
  boundary := by
    intro n
    have hs := HAUSDORFF_ENERGY_SPEC h n 0
    simpa [HausdorffDiff] using hs.symm
  split := by
    intro n k
    have h0 := HAUSDORFF_ENERGY_SPEC h n k
    have h1 := HAUSDORFF_ENERGY_SPEC h (n + 1) k
    have h2 := HAUSDORFF_ENERGY_SPEC h n (k + 1)
    have hrec :
        HausdorffDiff c n k =
          HausdorffDiff c (n + 1) k + HausdorffDiff c n (k + 1) := by
      have hs :
          HausdorffDiff c n (k + 1) =
            HausdorffDiff c n k - HausdorffDiff c (n + 1) k := rfl
      omega
    rw [h0, h1, h2] at hrec
    change
      Int.ofNat (HausdorffEnergy h n k) =
        Int.ofNat (HausdorffEnergy h (n + 1) k + HausdorffEnergy h n (k + 1)) at hrec
    have hnat := congrArg Int.toNat hrec
    exact hnat

/-- !!! Hausdorff positivity iff natural-valued BKQR energy realizability. -/
theorem SEQUENCE_HAUSDORFF_IFF_BKQR_ENERGY
    {c : Nat → Int} :
    SequenceHausdorffPositive c ↔ Nonempty (BKQREnergyData c) := by
  constructor
  · intro h
    exact ⟨HAUSDORFF_TO_BKQR_ENERGY_DATA h⟩
  · intro h
    exact Nonempty.elim h BKQR_ENERGY_TO_SEQUENCE_HAUSDORFF

end RHGPBKQR.Derivations.Hopf
