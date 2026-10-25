import RHAdmission.FinalChain

/-!
# Cross-inference 1: native zero labels to ONE scalar inequality

This is an equivalence for the real Mathlib RiemannHypothesis. The
algebraic Cayley gain is zero-indexed, not an identified Mellin operator.
There is no existence proof for an independent finite witness.
-/

namespace RHAdmission

/-- Only the expanding eigenvalue needs to be tested. -/
def ScalarChannelAdmission : Prop :=
  ∀ s : ℂ, ActualNontrivialZero s → channelGain s ≤ 1

/-- A scalar one-sided channel inequality already forces native RH. -/
theorem scalar_admission_implies_native_RH
    (h : ScalarChannelAdmission) : _root_.RiemannHypothesis := by
  intro s hz hn hne
  have hg : channelGain s = 1 :=
    le_antisymm (h s ⟨hz, hn, hne⟩) (channelGain_one_le s)
  exact (channelGain_eq_one_iff s).mp hg

/-- Native RH forces the scalar channel to be exactly neutral. -/
theorem native_RH_implies_scalar_admission
    (hRH : _root_.RiemannHypothesis) : ScalarChannelAdmission := by
  intro s hz
  have hc := hRH s hz.1 hz.2.1 hz.2.2
  exact le_of_eq ((channelGain_eq_one_iff s).mpr hc)

/-- This equivalence makes clear that scalar passivity is NOT a finite witness. -/
theorem SCALAR_CHANNEL_ADMISSION_IFF_NATIVE_RH :
    ScalarChannelAdmission ↔ _root_.RiemannHypothesis :=
  ⟨scalar_admission_implies_native_RH, native_RH_implies_scalar_admission⟩

end RHAdmission
