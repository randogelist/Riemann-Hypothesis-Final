import SoloboloAdmission.RationalCheck
import SoloboloAdmission.CayleyKernel

/-!
Rational packets yield genuinely nonnegative finite model Cayley towers.
This does NOT establish calibration to the actual xi-Widder tower.
-/
set_option autoImplicit false
noncomputable section
namespace SoloboloAdmission

def RationalPacket.toRealSpectrum {d : ℕ}
    (P : RationalPacket d) (h : P.check = true) : RealSpectrum d where
  node i := (P.node i : ℝ)
  mass i := (P.mass i : ℝ)
  node_bounds i := by
    have hnode := P.check_sound h i
    constructor
    · exact_mod_cast hnode.1
    · exact_mod_cast hnode.2.1
  mass_nonneg i := by
    have hnode := P.check_sound h i
    exact_mod_cast hnode.2.2

theorem RationalPacket.all_model_depths_nonnegative {d : ℕ}
    (P : RationalPacket d) (h : P.check = true)
    {a : ℝ} (ha : 0 < a) (n : ℕ) :
    0 ≤ (P.toRealSpectrum h).moment a n :=
  (P.toRealSpectrum h).moment_nonneg ha n

theorem RationalPacket.all_model_depths_monotone {d : ℕ}
    (P : RationalPacket d) (h : P.check = true)
    {a : ℝ} (ha : 0 < a) (n : ℕ) :
    (P.toRealSpectrum h).moment a (n + 1) ≤
      (P.toRealSpectrum h).moment a n :=
  (P.toRealSpectrum h).moment_succ_le ha n

end SoloboloAdmission
