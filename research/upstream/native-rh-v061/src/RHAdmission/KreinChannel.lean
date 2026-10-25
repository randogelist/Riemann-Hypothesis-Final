import RHAdmission.NativeZeros

/-!
# Concrete two-mode Krein channel

The block has eigenvalues `(gain, gain⁻¹)` and preserves an indefinite
cross-pairing unconditionally. Positive-Hilbert passivity is a genuinely
stronger hypothesis and will be made equivalent to native RH separately.
-/

namespace RHAdmission

/-- A real two-mode channel vector. -/
abbrev ChannelVec := ℝ × ℝ

/-- Hyperbolic two-mode evolution at an actual spectral label. -/
def channelStep (s : ℂ) (v : ChannelVec) : ChannelVec :=
  (channelGain s * v.1, (channelGain s)⁻¹ * v.2)

/-- The symmetric indefinite Krein pairing. -/
def kreinPair (v w : ChannelVec) : ℝ := v.1 * w.2 + v.2 * w.1

/-- Exact unconditional Krein preservation (no RH assumption). -/
theorem channelStep_preserves_krein (s : ℂ) (v w : ChannelVec) :
    kreinPair (channelStep s v) (channelStep s w) = kreinPair v w := by
  have hg := channelGain_ne_zero s
  simp only [kreinPair, channelStep]
  field_simp [hg]
  ring

/-- On the critical line, the block is the identity. -/
theorem channelStep_of_critical (s : ℂ) (hs : s.re = 1 / 2)
    (v : ChannelVec) : channelStep s v = v := by
  have hg := (channelGain_eq_one_iff s).mpr hs
  simp [channelStep, hg]

/-- Completely explicit iteration; there is no model-dependent recurrence. -/
def channelIterate (s : ℂ) : ℕ → ChannelVec → ChannelVec
  | 0, v => v
  | n + 1, v => channelStep s (channelIterate s n v)

/-- The two-mode Krein conservation law propagates through every depth. -/
theorem channelIterate_preserves_krein (s : ℂ) (n : ℕ)
    (v w : ChannelVec) :
    kreinPair (channelIterate s n v) (channelIterate s n w) =
      kreinPair v w := by
  induction n with
  | zero => rfl
  | succ n ih =>
      change kreinPair (channelStep s (channelIterate s n v))
        (channelStep s (channelIterate s n w)) = kreinPair v w
      rw [channelStep_preserves_krein, ih]

end RHAdmission
