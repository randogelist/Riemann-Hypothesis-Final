import RHForward.FiniteSturm
import FiniteWitness.NativeXi

/-!
# Precise actual-xi boundary — intentionally NOT declared as proved

Under RH we construct real Cayley factors from each actual zeta zero.
The present modules DO NOT establish that their complete infinite sum equals
the Taylor coefficients of `WitnessSolobolo.actualTheta`.

The missing proof is the actual native xi genus-zero divisor identity with
normal convergence, multiplicity and exceptional-point handling.
Do NOT use an RH-shaped record as a substitute for this identity.
-/

namespace RHForward

/-- Real finite packet data is a theorem consequence of native RH. -/
theorem RH_TO_FINITE_PACKET_CHAIN {d n : ℕ}
    (hRH : _root_.RiemannHypothesis)
    (p : NativeZeroPacket d)
    (a : ℝ) (ha : 0 < a)
    (c : Fin n → ℝ) :
    (∀ i : Fin d,
      (p.zeroAt i).point.re = 1 / 2) ∧
    (∀ m k, 0 ≤ ((criticalPacket_of_RH hRH p).toUnitSpectrum a ha).cell m k) ∧
    (0 ≤ ((criticalPacket_of_RH hRH p).toUnitSpectrum a ha).gramShifted c ∧
      0 ≤ ((criticalPacket_of_RH hRH p).toUnitSpectrum a ha).gramComplement c) := by
  refine ⟨fun i => rh_zero_real_half hRH (p.zeroAt i), ?_, ?_⟩
  · exact RH_TO_FINITE_HAUSDORFF hRH p a ha
  · exact RH_TO_FINITE_GRAM hRH p a ha c

/-- No field here pretends to prove native xi calibration. -/
noncomputable def actualXiQuarterGerm : ℂ → ℂ :=
  WitnessSolobolo.actualGerm

end RHForward

#print axioms RHForward.rh_zero_real_half
#print axioms RHForward.RH_TO_FINITE_HAUSDORFF
#print axioms RHForward.RH_TO_FINITE_GRAM
#print axioms RHForward.RH_TO_FINITE_PACKET_CHAIN
#print axioms RHForward.checked_rational_all_Hausdorff
#print axioms RHForward.RH_TO_FINITE_STURM
