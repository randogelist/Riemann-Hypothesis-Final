import SoloboloAdmission.RationalPackets
import SoloboloAdmission.ResidualBudget

/-!
# Hypothetical positive-rational-resolvent admission: abstract limit theorem

Important: the structure records genuinely analytic ALL-POINT convergence and
residual convergence on an open domain. Neither assertion follows from a finite
packet or from checking finitely many packets. This file proves the nontrivial
limit-of-residuals -> division-free ODE transfer, assuming those inputs.
-/
set_option autoImplicit false
noncomputable section
namespace SoloboloAdmission

open Filter
open scoped Topology BigOperators

/-- Positive rational resolvent with possible poles ONLY on the negative
real axis, when the node and mass bounds hold. The sign is the negative
logarithmic derivative in the ODE `Y' + A Y = 0`. -/
def rationalODECoefficient {d : ℕ}
    (P : RationalPacket d) (z : ℂ) : ℂ :=
  - ∑ i : Fin d,
    (P.mass i : ℂ) /
      ((P.node i : ℂ) * z + (9 / 4 : ℂ) * (1 - (P.node i : ℂ)))

/-- A fully specified *hypothetical* admission. The packets are rational, and
`check=true` is decidable, but convergence and global holomorphic gluing are
analytic proofs, not Boolean checks. -/
structure ResidualLimit (Y : ℂ → ℂ) (U : Set ℂ) where
  dimension : ℕ → ℕ
  packet : (n : ℕ) → RationalPacket (dimension n)
  packet_checked : ∀ n, (packet n).check = true
  coefficient : ℂ → ℂ
  coefficient_analytic : AnalyticOnNhd ℂ coefficient U
  resolvent_convergence : ∀ z ∈ U,
    Tendsto (fun n : ℕ => rationalODECoefficient (packet n) z)
      atTop (𝓝 (coefficient z))
  actual_residual_convergence : ∀ z ∈ U,
    Tendsto (fun n : ℕ =>
      deriv Y z + rationalODECoefficient (packet n) z * Y z)
      atTop (𝓝 0)

/-- No axiom: pointwise limits of the concrete finite residuals solve the
actual, division-free analytic ODE on the given domain. -/
theorem ResidualLimit.actual_ode {Y : ℂ → ℂ} {U : Set ℂ}
    (C : ResidualLimit Y U) :
    ∀ z ∈ U, deriv Y z + C.coefficient z * Y z = 0 := by
  intro z hz
  have hlimit : Tendsto
      (fun n : ℕ => deriv Y z + rationalODECoefficient (C.packet n) z * Y z)
      atTop (𝓝 (deriv Y z + C.coefficient z * Y z)) :=
    tendsto_const_nhds.add
      ((C.resolvent_convergence z hz).mul tendsto_const_nhds)
  exact tendsto_nhds_unique hlimit (C.actual_residual_convergence z hz)

end SoloboloAdmission
