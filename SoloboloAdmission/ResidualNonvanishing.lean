import SoloboloAdmission.NativeODE
import Mathlib.Analysis.Complex.LocallyUniformLimit
import Mathlib.Analysis.Calculus.IteratedDeriv.Lemmas

/-!
# A single locally uniform residual condition excludes actual zeros

This module does not assume a limiting ODE coefficient.  If every `A n` is
holomorphic on an open set and `Y' + A n * Y` tends locally uniformly to zero,
then an entire `Y` that is nonzero at one anchor cannot vanish on that set.

The reason is local: at a zero of order `k + 1`, every residual has the same
nonzero `k`th derivative.  Locally uniform holomorphic convergence forces that
derivative to converge to zero, a contradiction.

This is a source proof prepared against the local Mathlib 4.33 API.  Native
elaboration and endpoint axiom checks are separate publication checks.
-/

set_option autoImplicit false
noncomputable section

namespace SoloboloAdmission

open Filter
open scoped Topology

/-- Holomorphic locally uniform convergence to zero also holds after every
fixed number of derivatives.  The number of derivatives is not bounded in the
statement, but is fixed before taking the limit. -/
theorem locallyUniform_zero_iteratedDeriv
    {F : ℕ → ℂ → ℂ} {U : Set ℂ}
    (hU : IsOpen U)
    (hF : ∀ n, AnalyticOnNhd ℂ (F n) U)
    (hlim : TendstoLocallyUniformlyOn F (fun _ => 0) atTop U)
    (k : ℕ) :
    TendstoLocallyUniformlyOn
      (fun n => iteratedDeriv k (F n)) (fun _ => 0) atTop U := by
  induction k with
  | zero => simpa only [iteratedDeriv_zero] using hlim
  | succ k ih =>
      have hd : ∀ n, DifferentiableOn ℂ (iteratedDeriv k (F n)) U := by
        intro n
        have ha : AnalyticOnNhd ℂ (iteratedDeriv k (F n)) U := by
          simpa only [iteratedDeriv_eq_iterate] using (hF n).iterated_deriv k
        exact ha.differentiableOn
      have hzero_deriv : deriv (fun _ : ℂ => (0 : ℂ)) = (fun _ => 0) := by
        funext w
        exact deriv_const w 0
      simpa only [Function.comp_def, iteratedDeriv_succ, hzero_deriv] using
        ih.deriv (Filter.Eventually.of_forall hd) hU

/-- A locally uniform limit of actual division-free residuals excludes zeros.
There is no unknown limiting coefficient and no global zero enumeration in
the hypotheses.  `U` need only be open; it need not contain the anchor `1` or
be connected, because the entire function has finite order at every point. -/
theorem entire_nonvanishing_of_locallyUniform_residual
    {Y : ℂ → ℂ} {A : ℕ → ℂ → ℂ} {U : Set ℂ}
    (hY : AnalyticOnNhd ℂ Y Set.univ)
    (hY1 : Y 1 ≠ 0)
    (hU : IsOpen U)
    (hA : ∀ n, AnalyticOnNhd ℂ (A n) U)
    (hres : TendstoLocallyUniformlyOn
      (fun n z => deriv Y z + A n z * Y z) (fun _ => 0) atTop U) :
    ∀ z ∈ U, Y z ≠ 0 := by
  intro z hz hzero
  have hYz : AnalyticAt ℂ Y z := hY z (Set.mem_univ _)
  have horderone : analyticOrderAt Y 1 = 0 :=
    (hY 1 (Set.mem_univ _)).analyticOrderAt_eq_zero.mpr hY1
  have hfiniteone : analyticOrderAt Y 1 ≠ ⊤ := by simp [horderone]
  have hfinite : analyticOrderAt Y z ≠ ⊤ :=
    hY.analyticOrderAt_ne_top_of_isPreconnected
      isPreconnected_univ (Set.mem_univ _) (Set.mem_univ _) hfiniteone
  obtain ⟨m, hm⟩ := ENat.ne_top_iff_exists.mp hfinite
  have horder : analyticOrderAt Y z = (m : ℕ∞) := hm.symm
  cases m with
  | zero =>
      exact (hYz.analyticOrderAt_eq_zero.mp horder) hzero
  | succ k =>
      have hnonzero : iteratedDeriv (k + 1) Y z ≠ 0 :=
        ((analyticOrderAt_eq_nat_iff_iteratedDeriv_eq_zero hYz).mp horder).2
      have hres_analytic : ∀ n,
          AnalyticOnNhd ℂ (fun w => deriv Y w + A n w * Y w) U := by
        intro n w hw
        exact (hY w (Set.mem_univ _)).deriv.add
          ((hA n w hw).mul (hY w (Set.mem_univ _)))
      have hres_deriv (n : ℕ) :
          iteratedDeriv k (fun w => deriv Y w + A n w * Y w) z =
            iteratedDeriv (k + 1) Y z := by
        have hp : AnalyticAt ℂ (fun w => A n w * Y w) z :=
          (hA n z hz).mul hYz
        have hprod_order : ((k + 1 : ℕ) : ℕ∞) ≤
            analyticOrderAt (fun w => A n w * Y w) z := by
          rw [analyticOrderAt_mul (hA n z hz) hYz, horder]
          simpa only [zero_add] using add_le_add_right
            (show (0 : ℕ∞) ≤ analyticOrderAt (A n) z from bot_le)
            ((k + 1 : ℕ) : ℕ∞)
        have hprod_zero : iteratedDeriv k (fun w => A n w * Y w) z = 0 :=
          (natCast_le_analyticOrderAt_iff_iteratedDeriv_eq_zero hp).mp
            hprod_order k (Nat.lt_succ_self k)
        change iteratedDeriv k (deriv Y + (fun w => A n w * Y w)) z = _
        rw [iteratedDeriv_add hYz.deriv.contDiffAt hp.contDiffAt, hprod_zero,
          add_zero, ← iteratedDeriv_succ']
      have hlim : Tendsto
          (fun n => iteratedDeriv k
            (fun w => deriv Y w + A n w * Y w) z)
          atTop (𝓝 (0 : ℂ)) :=
        (locallyUniform_zero_iteratedDeriv hU hres_analytic hres k).tendsto_at hz
      have hlim_const : Tendsto
          (fun _ : ℕ => iteratedDeriv (k + 1) Y z) atTop (𝓝 (0 : ℂ)) := by
        simpa only [hres_deriv] using hlim
      exact hnonzero (tendsto_nhds_unique tendsto_const_nhds hlim_const)

end SoloboloAdmission

#print axioms SoloboloAdmission.entire_nonvanishing_of_locallyUniform_residual
