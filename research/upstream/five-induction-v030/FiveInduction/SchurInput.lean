import FiveInduction.Schur
import FiveInduction.CayleyBridge
import FiveInduction.DiskTransfer
import Mathlib.Analysis.Analytic.Polynomial

/-!
# The Schur input statement and its conditional RH endpoint

The paired polynomial recurrence and its closed-disk nonvanishing are proved
in `Schur`. The sole analytic input here is local uniform convergence of that
same recurrence to the actual normalized Cayley transform of xi. No witness
for this realization proposition is asserted.
-/

namespace FiveInduction.SchurInput

open Filter Set
open scoped Topology

noncomputable section

/-- The functions in the concrete Schur recurrence are entire polynomials. -/
theorem schur_differentiable (a : ℕ → ℝ) (n : ℕ) :
    Differentiable ℂ (Schur.p a n) := by
  intro z
  have hp : AnalyticAt ℂ (fun w => (Schur.pPoly a n).eval w) z :=
    AnalyticOnNhd.eval_polynomial (Schur.pPoly a n) _ (Set.mem_univ z)
  simpa only [Schur.pPoly_eval] using hp.differentiableAt

/-- Exact open input: admissible real Schur parameters realizing actual xi. -/
def SchurXiRealization : Prop :=
  ∃ a : ℕ → ℝ, (∀ n, |a n| < 1) ∧
    TendstoLocallyUniformlyOn (Schur.p a) CayleyBridge.F atTop
      CayleyBridge.unitDisk

/-- The preservation theorem and analytic limit transfer close the Schur route. -/
theorem RH_OF_SCHUR_CONVERGENCE (a : ℕ → ℝ) (ha : ∀ n, |a n| < 1)
    (hconv : TendstoLocallyUniformlyOn (Schur.p a) CayleyBridge.F atTop
      CayleyBridge.unitDisk) : RiemannHypothesis := by
  apply CayleyBridge.RH_OF_CAYLEY_NONZERO
  apply DiskTransfer.nonzero_on_unitDisk_of_locally_uniform_limit
    (F := Schur.p a)
  · intro n
    exact (schur_differentiable a n).differentiableOn
  · intro n z hz
    have hnorm : ‖z‖ < 1 := by
      simpa only [Metric.mem_ball, dist_zero_right] using hz
    exact Schur.closedDisk_nonzero a ha n z hnorm.le
  · exact CayleyBridge.differentiableOn_F
  · rw [CayleyBridge.F_zero]
    exact one_ne_zero
  · exact hconv

/-- The existence of one complete Schur realization suffices for literal RH. -/
theorem RH_OF_SCHUR_REALIZATION (h : SchurXiRealization) : RiemannHypothesis := by
  obtain ⟨a, ha, hconv⟩ := h
  exact RH_OF_SCHUR_CONVERGENCE a ha hconv

end

end FiveInduction.SchurInput
