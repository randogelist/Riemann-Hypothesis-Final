import Derivations.BKQR.BKQRGram
import Derivations.GP.GPJet

namespace RHGPBKQR.Derivations.BKQR

open RHGPBKQR

/--
!!! COMPLETED-SLICE NORMALIZATION BRIDGE
The BKQR table proves Hausdorff positivity for the scaled GP-centered jet.
The completed GP normalization reconstructs the centered R jet, then the
universal Zhang transform and common scaling identify that sequence with
Zhang's literature sequence.  No literature theorem is used here.
-/
theorem CENTERED_STRONG_DATA_TO_HAUSDORFF
    (d : OurStrongData) :
    HausdorffPositive := by
  have hSeq : SequenceHausdorffPositive d.jet.coeff :=
    BKQR_TO_SEQUENCE_HAUSDORFF d
  have hEq : d.jet.coeff = ZhangNormalizedCoeff :=
    RHGPBKQR.Derivations.GP.GP_SCALED_JET_EQ_ZHANG_NORMALIZED d
  rw [hEq] at hSeq
  exact hSeq


/--
!! A signed Hausdorff cell of order `k` only depends on the coefficient window
`n, ..., n+k`.  Equality of two sequences through that cutoff therefore gives
equality of the corresponding cell.
-/
theorem HAUSDORFF_DIFF_CONGR_UP_TO
    {a b : Nat → Int} (cutoff n k : Nat)
    (h : ∀ j : Nat, j ≤ cutoff → a j = b j)
    (hbound : n + k ≤ cutoff) :
    HausdorffDiff a n k = HausdorffDiff b n k := by
  induction k generalizing n with
  | zero =>
      exact h n (by omega)
  | succ k ih =>
      calc
        HausdorffDiff a n (k + 1) =
            HausdorffDiff a n k - HausdorffDiff a (n + 1) k := rfl
        _ = HausdorffDiff b n k - HausdorffDiff b (n + 1) k := by
          rw [ih n (by omega), ih (n + 1) (by omega)]
        _ = HausdorffDiff b n (k + 1) := rfl

/--
!!! TRACE-RESOLVENT -> HAUSDORFF.
Finite-stage BKQR trace-resolvent cells are nonnegative energies.  Finite-jet
convergence transports each fixed cell to the completed GP/Zhang limit.
-/
theorem TRACE_RESOLVENT_APPROX_TO_SEQUENCE_HAUSDORFF
    {c : Nat → Int} (d : BKQRTraceResolventApproxData c) :
    SequenceHausdorffPositive c := by
  intro n k
  obtain ⟨Y0, hY0⟩ := d.finiteJet (n + k)
  have hCoeff : ∀ j : Nat, j ≤ n + k → d.coeff Y0 j = c j :=
    hY0 Y0 (Nat.le_refl Y0)
  have hCell :
      HausdorffDiff (d.coeff Y0) n k = HausdorffDiff c n k :=
    HAUSDORFF_DIFF_CONGR_UP_TO (n + k) n k hCoeff (Nat.le_refl (n + k))
  refine ⟨d.energy Y0 n k, ?_⟩
  calc
    HausdorffDiff c n k = HausdorffDiff (d.coeff Y0) n k := hCell.symm
    _ = Int.ofNat (d.energy Y0 n k) := d.stageSquare Y0 n k

/--
!! Reverse core-only model: a Hausdorff-positive sequence gives a constant
trace-resolvent coefficient tower.  This direction is only for atlas equivalence;
the research direction is the constructive finite BKQR approximation above.
-/
noncomputable def HAUSDORFF_TO_TRACE_RESOLVENT_APPROX_DATA
    {c : Nat → Int} (h : SequenceHausdorffPositive c) :
    BKQRTraceResolventApproxData c where
  coeff := fun _ => c
  energy := fun _ n k => RHGPBKQR.Derivations.Hopf.HausdorffEnergy h n k
  stageSquare := by
    intro Y n k
    exact RHGPBKQR.Derivations.Hopf.HAUSDORFF_ENERGY_SPEC h n k
  finiteJet := by
    intro cutoff
    refine ⟨0, ?_⟩
    intro Y hY n hn
    rfl

/-- !!! Hausdorff positivity iff the core trace-resolvent approximation anchor exists. -/
theorem SEQUENCE_HAUSDORFF_IFF_TRACE_RESOLVENT_APPROX
    {c : Nat → Int} :
    SequenceHausdorffPositive c ↔ Nonempty (BKQRTraceResolventApproxData c) := by
  constructor
  · intro h
    exact ⟨HAUSDORFF_TO_TRACE_RESOLVENT_APPROX_DATA h⟩
  · intro h
    exact Nonempty.elim h TRACE_RESOLVENT_APPROX_TO_SEQUENCE_HAUSDORFF

end RHGPBKQR.Derivations.BKQR
