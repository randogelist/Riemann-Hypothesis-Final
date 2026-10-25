import RHForward.CayleyReal

/-!
# RH => actual nontrivial zeta zeros lie on the critical line

The predicate uses Mathlib's LITERAL riemannZeta and Mathlib's LITERAL
`_root_.RiemannHypothesis`. Its hypotheses cannot be satisfied by a free model.
-/

namespace RHForward

structure NativeNontrivialZero where
  point : ℂ
  zero : riemannZeta point = 0
  notTrivial : ¬ ∃ n : ℕ, point = -2 * ((n : ℂ) + 1)
  notOne : point ≠ 1

/-- Native RH directly fixes the real part of each actual nontrivial zero. -/
theorem rh_zero_real_half
    (hRH : _root_.RiemannHypothesis)
    (z : NativeNontrivialZero) :
    z.point.re = 1 / 2 := by
  exact hRH z.point z.zero z.notTrivial z.notOne

theorem rh_zero_centered_real
    (hRH : _root_.RiemannHypothesis)
    (z : NativeNontrivialZero) :
    z.point.re - 1 / 2 = 0 := by
  rw [rh_zero_real_half hRH z]
  ring

/-- The COMPLEX zero scale, with off-line real displacement retained. -/
noncomputable def complexZeroScale (z : NativeNontrivialZero) : ℂ :=
  ((z.point.im : ℂ) - Complex.I * ((z.point.re - (1 / 2 : ℝ)) : ℂ))^2

/-- Under native RH, the true complex scale reduces to a real square. -/
theorem rh_complexZeroScale_eq
    (hRH : _root_.RiemannHypothesis)
    (z : NativeNontrivialZero) :
    complexZeroScale z = (z.point.im : ℂ)^2 := by
  have hz := rh_zero_centered_real hRH z
  simp [complexZeroScale, hz]

/-- An arbitrary finite list of GENUINE native zeta zeros. -/
structure NativeZeroPacket (d : ℕ) where
  zeroAt : Fin d → NativeNontrivialZero

/-- The RH-specialized packet still retains the actual zero at every slot. -/
structure CriticalZeroPacket (d : ℕ) where
  source : NativeZeroPacket d
  critical : ∀ i : Fin d, (source.zeroAt i).point.re = 1 / 2

/-- RH supplies criticality at every entry of every finite native packet. -/
def criticalPacket_of_RH {d : ℕ}
    (hRH : _root_.RiemannHypothesis)
    (p : NativeZeroPacket d) : CriticalZeroPacket d where
  source := p
  critical := fun i => rh_zero_real_half hRH (p.zeroAt i)

end RHForward
