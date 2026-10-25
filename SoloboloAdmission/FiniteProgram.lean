import SoloboloAdmission.RationalPackets

/-!
# Finite rational PROGRAM syntax for SOLOBOLO candidate spectra

`RatExpr` is an inductive finite syntax tree. Evaluation takes an order `n`
and finite index `i` and terminates by structural recursion. Every emitted
packet is positive by construction, at EVERY order, without a proof premise.

This is a structural model certificate, NOT actual xi calibration.
-/
set_option autoImplicit false

namespace SoloboloAdmission

/-- Finite syntax: rational operations and a rational branch test. -/
inductive RatExpr where
  | literal (q : ℚ)
  | depth
  | index
  | add (x y : RatExpr)
  | sub (x y : RatExpr)
  | mul (x y : RatExpr)
  | neg (x : RatExpr)
  | inv (x : RatExpr)
  | pow (x : RatExpr) (k : ℕ)
  | selectLE (lhs rhs yes no : RatExpr)
  deriving Repr

/-- Total, finite rational evaluation of a finite syntax tree. -/
def RatExpr.eval : RatExpr → ℕ → ℕ → ℚ
  | .literal q, _, _ => q
  | .depth, n, _ => (n : ℚ)
  | .index, _, i => (i : ℚ)
  | .add x y, n, i => x.eval n i + y.eval n i
  | .sub x y, n, i => x.eval n i - y.eval n i
  | .mul x y, n, i => x.eval n i * y.eval n i
  | .neg x, n, i => -(x.eval n i)
  | .inv x, n, i => (x.eval n i)⁻¹
  | .pow x k, n, i => (x.eval n i) ^ k
  | .selectLE x y z w, n, i =>
      if x.eval n i ≤ y.eval n i then z.eval n i else w.eval n i

/-- Finite data: the rank grows with `n`; nodes and masses are generated
by the SAME finite rational formulas at every n. -/
structure FiniteProgram where
  additionalRank : ℕ
  nodeExpr : RatExpr
  massExpr : RatExpr
  deriving Repr

def FiniteProgram.dimension (P : FiniteProgram) (n : ℕ) : ℕ :=
  n + P.additionalRank + 1

/-- Map ANY rational parameter x to the positive-contraction node
`x²/(1+x²)`; map mass y to `y²`. No hidden sign oracle. -/
def FiniteProgram.emit (P : FiniteProgram) (n : ℕ) :
    RationalPacket (P.dimension n) where
  node i :=
    let x : ℚ := P.nodeExpr.eval n i.val
    x ^ 2 / (1 + x ^ 2)
  mass i := (P.massExpr.eval n i.val) ^ 2

/-- The finite algebraic step holds without RH and without induction assumptions. -/
theorem FiniteProgram.emit_valid (P : FiniteProgram) (n : ℕ) :
    (P.emit n).Valid := by
  intro i
  let x : ℚ := P.nodeExpr.eval n i.val
  have hx : 0 ≤ x ^ 2 := sq_nonneg x
  have hd : 0 < 1 + x ^ 2 := by positivity
  have h0 : 0 ≤ x ^ 2 / (1 + x ^ 2) :=
    div_nonneg hx (le_of_lt hd)
  have h1 : x ^ 2 / (1 + x ^ 2) ≤ 1 :=
    (div_le_iff₀ hd).2 (by nlinarith)
  have hm : 0 ≤ (P.massExpr.eval n i.val) ^ 2 := sq_nonneg _
  change 0 ≤ x ^ 2 / (1 + x ^ 2) ∧
    x ^ 2 / (1 + x ^ 2) ≤ 1 ∧
    0 ≤ (P.massExpr.eval n i.val) ^ 2
  exact ⟨h0, h1, hm⟩

/-- Kernel-soundness of the terminating rational checker, at EVERY depth. -/
theorem FiniteProgram.emit_check (P : FiniteProgram) (n : ℕ) :
    (P.emit n).check = true := by
  simp [RationalPacket.check, P.emit_valid n]

/-- One finite executable smoke check, deliberately NOT an RH checker. -/
def FiniteProgram.smoke (P : FiniteProgram) (K : ℕ) : Bool :=
  decide (∀ i : Fin (K + 1), (P.emit i.val).check = true)

theorem FiniteProgram.smoke_true (P : FiniteProgram) (K : ℕ) :
    P.smoke K = true := by
  simp [FiniteProgram.smoke, P.emit_check]

theorem FiniteProgram.smoke_sound (P : FiniteProgram)
    {K n : ℕ} (h : P.smoke K = true) (hn : n ≤ K) :
    (P.emit n).check = true := by
  have hall : ∀ i : Fin (K + 1), (P.emit i.val).check = true := by
    simpa [FiniteProgram.smoke] using h
  exact hall ⟨n, Nat.lt_succ_of_le hn⟩

/-- From one finite generator, EVERY emitted finite spectral model has all
SOLOBOLO-shaped kernel moments nonnegative. This is NOT the actual xi tower. -/
noncomputable def FiniteProgram.modelMoment (P : FiniteProgram)
    (n : ℕ) (a : ℝ) (k : ℕ) : ℝ :=
  ((P.emit n).toRealSpectrum (P.emit_check n)).moment a k

theorem FiniteProgram.modelMoment_nonneg (P : FiniteProgram)
    (n : ℕ) {a : ℝ} (ha : 0 < a) (k : ℕ) :
    0 ≤ P.modelMoment n a k := by
  exact (P.emit n).all_model_depths_nonnegative (P.emit_check n) ha k

theorem FiniteProgram.modelMoment_succ_le (P : FiniteProgram)
    (n : ℕ) {a : ℝ} (ha : 0 < a) (k : ℕ) :
    P.modelMoment n a (k + 1) ≤ P.modelMoment n a k := by
  exact (P.emit n).all_model_depths_monotone (P.emit_check n) ha k

end SoloboloAdmission
