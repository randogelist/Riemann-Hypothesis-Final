import Mathlib.NumberTheory.LSeries.RiemannZeta
import Mathlib.Tactic

namespace RHGPNativeReserveReduction

set_option autoImplicit false

noncomputable section

/-!
Native Lean 4 / mathlib axiomatic RH anchor guided by the passing Rocq
pointwise two-interface reduction.

Claim boundary:
* the theorem graph below proves Mathlib's `RiemannHypothesis` from exactly two
  explicit open interfaces;
* the two open interfaces are declared as axioms only at the final instantiation;
* no global zero enumeration is used by the reduction.
-/

/-- Critical-line real coordinate. -/
def criticalHalf : ℝ := (1 : ℝ) / 2

/-- Gap reserve from the Rocq collision ledger. -/
def gapReserve (a : ℝ) : ℝ := a * a / 4

/-- Explicit convergence-to-zero predicate used for collision-opening reserves. -/
def SeqTendsToZero (u : ℕ → ℝ) : Prop :=
  ∀ ε : ℝ, 0 < ε → ∃ N : ℕ, ∀ n : ℕ, N ≤ n → |u n| < ε

/--
Actual mathlib zeta nontrivial-zero predicate in real/imaginary coordinates.
The underlying complex zero is retained as a witness, avoiding reconstruction
rewrites between `s` and `(s.re, s.im)`.
-/
def ActualNontrivialZero (β γ : ℝ) : Prop :=
  ∃ s : ℂ,
    s.re = β ∧
    s.im = γ ∧
    riemannZeta s = 0 ∧
    (¬ ∃ n : ℕ, s = -2 * (↑n + 1)) ∧
    s ≠ 1

/-- Coordinatewise pointwise RH statement. -/
def RHPointwise (NontrivialZero : ℝ → ℝ → Prop) : Prop :=
  ∀ β γ : ℝ, NontrivialZero β γ → β = criticalHalf

/-- Centered-Xi imaginary offset corresponding to `Re(s) - 1/2`. -/
def xiImaginaryOffset (β : ℝ) : ℝ := criticalHalf - β

/-- One finite heat-zero branch attached to one zeta zero. -/
structure PointwiseHeatBranch
    (HeatZero : ℝ → ℝ → ℝ → Prop) (β γ : ℝ) where
  safeTime : ℝ
  realPart : ℝ → ℝ
  imagPart : ℝ → ℝ
  safeTimePositive : 0 < safeTime
  onZeroLocus : ∀ t : ℝ, 0 ≤ t → t ≤ safeTime →
    HeatZero t (realPart t) (imagPart t)
  initialReal : realPart 0 = γ
  initialImag : imagPart 0 = xiImaginaryOffset β
  safeImag : imagPart safeTime = 0

/-- Continuation before safe-time reality is imposed. -/
structure PointwiseZeroContinuation
    (HeatZero : ℝ → ℝ → ℝ → Prop)
    (β γ safeThreshold : ℝ) where
  safeTime : ℝ
  realPart : ℝ → ℝ
  imagPart : ℝ → ℝ
  safeTimePositive : 0 < safeTime
  reachesSafeRegime : safeThreshold ≤ safeTime
  onZeroLocus : ∀ t : ℝ, 0 ≤ t → t ≤ safeTime →
    HeatZero t (realPart t) (imagPart t)
  initialReal : realPart 0 = γ
  initialImag : imagPart 0 = xiImaginaryOffset β

/-- Every heat-family zero is real from `T` onward. -/
def AllZerosRealFrom
    (HeatZero : ℝ → ℝ → ℝ → Prop) (T : ℝ) : Prop :=
  ∀ t x y : ℝ, T ≤ t → HeatZero t x y → y = 0

/-- Safe-time reality converts a finite continuation into a pointwise heat branch. -/
def continuationToHeatBranch
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    {β γ safeThreshold : ℝ}
    (C : PointwiseZeroContinuation HeatZero β γ safeThreshold)
    (hSafe : AllZerosRealFrom HeatZero safeThreshold) :
    PointwiseHeatBranch HeatZero β γ where
  safeTime := C.safeTime
  realPart := C.realPart
  imagPart := C.imagPart
  safeTimePositive := C.safeTimePositive
  onZeroLocus := C.onZeroLocus
  initialReal := C.initialReal
  initialImag := C.initialImag
  safeImag := by
    apply hSafe C.safeTime (C.realPart C.safeTime) (C.imagPart C.safeTime)
    · exact C.reachesSafeRegime
    · exact C.onZeroLocus C.safeTime (le_of_lt C.safeTimePositive) le_rfl

/-- Local outgoing real-pair opening at a putative collision. -/
structure CollisionOpening
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    (B : PointwiseHeatBranch HeatZero β γ) where
  gap : ℕ → ℝ
  reserveVanishes : SeqTendsToZero (fun n => gapReserve (gap n))

/-- Local heat normal form / remainder certificate. -/
def HeatJetRemainderCertificate
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    (B : PointwiseHeatBranch HeatZero β γ) : Prop :=
  β ≠ criticalHalf → Nonempty (CollisionOpening B)

/-- GP/BKQR uniform reserve margin on every opening prefix. -/
def GPBKQRUniformOpeningReserveMargin
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    (B : PointwiseHeatBranch HeatZero β γ) : Prop :=
  ∀ O : CollisionOpening B,
    ∃ ε : ℝ, 0 < ε ∧ ∀ n : ℕ, ε ≤ gapReserve (O.gap n)

/-- The reserve floor cannot coexist with a reserve sequence converging to zero. -/
theorem UNIFORM_RESERVE_FLOOR_EXCLUDES_COLLISION_OPENING
    {u : ℕ → ℝ} (hZero : SeqTendsToZero u)
    {ε : ℝ} (hε : 0 < ε) (hFloor : ∀ n : ℕ, ε ≤ u n) : False := by
  have hHalf : 0 < ε / 2 := by linarith
  obtain ⟨N, hN⟩ := hZero (ε / 2) hHalf
  have hAbs : |u N| < ε / 2 := hN N le_rfl
  have hUpper : u N < ε / 2 := lt_of_le_of_lt (le_abs_self (u N)) hAbs
  have hLower : ε ≤ u N := hFloor N
  linarith

/-- Local Xi collision opening plus GP/BKQR reserve margin forces `β = 1/2`. -/
theorem HEAT_JET_PLUS_GP_MARGIN_IMPLIES_CRITICAL_LINE
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    (B : PointwiseHeatBranch HeatZero β γ)
    (hJet : HeatJetRemainderCertificate B)
    (hMargin : GPBKQRUniformOpeningReserveMargin B) :
    β = criticalHalf := by
  by_contra hOff
  unfold HeatJetRemainderCertificate at hJet
  unfold GPBKQRUniformOpeningReserveMargin at hMargin
  obtain ⟨O⟩ := hJet hOff
  obtain ⟨ε, hε, hFloor⟩ := hMargin O
  exact UNIFORM_RESERVE_FLOOR_EXCLUDES_COLLISION_OPENING
    O.reserveVanishes hε hFloor

/-- Complete Xi-side pointwise analytic package from the Rocq reduction. -/
structure XiAnalyticPointwisePackage
    (NontrivialZero : ℝ → ℝ → Prop)
    (HeatZero : ℝ → ℝ → ℝ → Prop)
    (safeThreshold : ℝ)
    (EscapeEvent : ℝ → ℝ → Prop) : Prop where
  continuationOrEscape : ∀ β γ : ℝ, NontrivialZero β γ →
    Nonempty (PointwiseZeroContinuation HeatZero β γ safeThreshold) ∨ EscapeEvent β γ
  noEscape : ∀ β γ : ℝ, NontrivialZero β γ → ¬ EscapeEvent β γ
  safeReality : AllZerosRealFrom HeatZero safeThreshold
  heatJet : ∀ β γ : ℝ, (B : PointwiseHeatBranch HeatZero β γ) →
    NontrivialZero β γ → HeatJetRemainderCertificate B

/-- The single GP/BKQR research interface left by the Rocq compression. -/
structure GPBKQRPointwiseReservePackage
    (NontrivialZero : ℝ → ℝ → Prop)
    (HeatZero : ℝ → ℝ → ℝ → Prop) : Prop where
  margin : ∀ β γ : ℝ, (B : PointwiseHeatBranch HeatZero β γ) →
    NontrivialZero β γ → GPBKQRUniformOpeningReserveMargin B

/-- The Xi package produces a branch for every covered zero. -/
theorem XI_ANALYTIC_PACKAGE_CONSTRUCTS_POINTWISE_BRANCH_COVERAGE
    {NontrivialZero : ℝ → ℝ → Prop}
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    {safeThreshold : ℝ}
    {EscapeEvent : ℝ → ℝ → Prop}
    (hXi : XiAnalyticPointwisePackage NontrivialZero HeatZero safeThreshold EscapeEvent)
    {β γ : ℝ} (hZero : NontrivialZero β γ) :
    Nonempty (PointwiseHeatBranch HeatZero β γ) := by
  rcases hXi.continuationOrEscape β γ hZero with hCont | hEsc
  · obtain ⟨C⟩ := hCont
    exact ⟨continuationToHeatBranch C hXi.safeReality⟩
  · exact False.elim (hXi.noEscape β γ hZero hEsc)

/-- Exact two-interface pointwise closure, mirroring the passing Rocq theorem. -/
theorem TWO_INTERFACE_POINTWISE_CLOSURE
    {NontrivialZero : ℝ → ℝ → Prop}
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    {safeThreshold : ℝ}
    {EscapeEvent : ℝ → ℝ → Prop}
    (hXi : XiAnalyticPointwisePackage NontrivialZero HeatZero safeThreshold EscapeEvent)
    (hGP : GPBKQRPointwiseReservePackage NontrivialZero HeatZero) :
    RHPointwise NontrivialZero := by
  intro β γ hZero
  obtain ⟨B⟩ := XI_ANALYTIC_PACKAGE_CONSTRUCTS_POINTWISE_BRANCH_COVERAGE hXi hZero
  exact HEAT_JET_PLUS_GP_MARGIN_IMPLIES_CRITICAL_LINE
    B (hXi.heatJet β γ B hZero) (hGP.margin β γ B hZero)

/-- Actual coordinatewise closure implies Mathlib's literal `RiemannHypothesis`. -/
theorem ACTUAL_POINTWISE_CLOSURE_IMPLIES_MATHLIB_RH
    (hPointwise : RHPointwise ActualNontrivialZero) : RiemannHypothesis := by
  intro s hz htrivial hone
  exact hPointwise s.re s.im ⟨s, rfl, rfl, hz, htrivial, hone⟩

/-- Mathlib RH also gives the coordinatewise formulation, so the binding is exact. -/
theorem MATHLIB_RH_IMPLIES_ACTUAL_POINTWISE_CLOSURE
    (hRH : RiemannHypothesis) : RHPointwise ActualNontrivialZero := by
  intro β γ hZero
  rcases hZero with ⟨s, hre, him, hz, htrivial, hone⟩
  have hs : s.re = (1 : ℝ) / 2 := hRH s hz htrivial hone
  calc
    β = s.re := hre.symm
    _ = (1 : ℝ) / 2 := hs
    _ = criticalHalf := rfl

/-- Exact binding between the pointwise wrapper and Mathlib's RH definition. -/
theorem ACTUAL_POINTWISE_CLOSURE_IFF_MATHLIB_RH :
    RHPointwise ActualNontrivialZero ↔ RiemannHypothesis := by
  constructor
  · exact ACTUAL_POINTWISE_CLOSURE_IMPLIES_MATHLIB_RH
  · exact MATHLIB_RH_IMPLIES_ACTUAL_POINTWISE_CLOSURE

/-! ## Direct field-gap support, mirrored from the passing Rocq field readout -/

/-- Right-minus-left exterior Cauchy field difference. -/
def exteriorFieldDifference (left right : ℝ) : ℝ := right - left

/-- Canonical field excess `η = -a ΔF - 2`. -/
def fieldExcess (a left right : ℝ) : ℝ :=
  -a * exteriorFieldDifference left right - 2

/-- Scaled gap velocity `a a' = 4 + 2 a ΔF`. -/
def scaledGapVelocityFromFields (a left right : ℝ) : ℝ :=
  4 + 2 * a * exteriorFieldDifference left right

/-- Gap-reserve rate `(a a')/2`. -/
def reserveRateFromFields (a left right : ℝ) : ℝ :=
  scaledGapVelocityFromFields a left right / 2

/-- Direct exterior fields give the canonical scaled gap-velocity/excess identity. -/
theorem DIRECT_EXTERIOR_FIELDS_GIVE_CANONICAL_SCALED_GAP_VELOCITY
    (a left right : ℝ) :
    scaledGapVelocityFromFields a left right = -2 * fieldExcess a left right := by
  unfold scaledGapVelocityFromFields fieldExcess exteriorFieldDifference
  ring

/-- The canonical field excess is minus one half of scaled gap velocity. -/
theorem FIELD_EXCESS_IS_NEGATIVE_HALF_SCALED_GAP_VELOCITY
    (a left right : ℝ) :
    fieldExcess a left right = -scaledGapVelocityFromFields a left right / 2 := by
  unfold scaledGapVelocityFromFields fieldExcess exteriorFieldDifference
  ring

/-- Direct field readout gives the exact reserve-rate law `R' = -η`. -/
theorem XI_PAIR_FIELD_READOUT_GIVES_RESERVE_RATE_MINUS_EXCESS
    (a left right : ℝ) :
    reserveRateFromFields a left right = -fieldExcess a left right := by
  unfold reserveRateFromFields scaledGapVelocityFromFields fieldExcess exteriorFieldDifference
  ring


/-! ## Native GP/BKQR reserve reduction: no research axioms declared -/

/--
Exact discrete excess increment on one collision-opening prefix.
This is the discrete Lean mirror of `R' = -η` integrated over one step.
-/
structure ExactGapExcessLedger
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    (O : CollisionOpening B) where
  excess : ℕ → ℝ
  reserveIncrement : ∀ n : ℕ,
    gapReserve (O.gap (n + 1)) = gapReserve (O.gap n) - excess n

/--
A cumulative paid-excess budget with a fixed positive slack below the initial
reserve.  This is data for one opening, not an axiom.
-/
def CumulativePaidExcessBudget
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    {O : CollisionOpening B}
    (L : ExactGapExcessLedger O) : Prop :=
  ∃ paid : ℕ → ℝ, ∃ ε : ℝ,
    0 < ε ∧
    (∀ n : ℕ, L.excess n ≤ paid n) ∧
    (∀ n : ℕ, 0 ≤ paid n) ∧
    (∀ n : ℕ,
      Finset.sum (Finset.range n) paid ≤ gapReserve (O.gap 0) - ε)

/-- Exact excess increments telescope to the prefix reserve identity. -/
theorem EXACT_EXCESS_INCREMENT_TELESCOPES
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    {O : CollisionOpening B}
    (L : ExactGapExcessLedger O) :
    ∀ n : ℕ,
      gapReserve (O.gap n) =
        gapReserve (O.gap 0) - Finset.sum (Finset.range n) L.excess := by
  intro n
  induction n with
  | zero => simp
  | succ n ih =>
      calc
        gapReserve (O.gap (Nat.succ n)) =
            gapReserve (O.gap n) - L.excess n := by
              simpa [Nat.succ_eq_add_one] using L.reserveIncrement n
        _ = (gapReserve (O.gap 0) - Finset.sum (Finset.range n) L.excess) -
              L.excess n := by rw [ih]
        _ = gapReserve (O.gap 0) -
              Finset.sum (Finset.range (Nat.succ n)) L.excess := by
              rw [Finset.sum_range_succ]
              ring

/-- Stepwise excess domination implies domination of every cumulative prefix. -/
theorem EXCESS_PREFIX_LE_PAID_PREFIX
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    {O : CollisionOpening B}
    (L : ExactGapExcessLedger O)
    (paid : ℕ → ℝ)
    (hEnvelope : ∀ n : ℕ, L.excess n ≤ paid n) :
    ∀ n : ℕ,
      (Finset.sum (Finset.range n) L.excess) ≤
      Finset.sum (Finset.range n) paid := by
  intro n
  exact Finset.sum_le_sum (fun k _hk => hEnvelope k)

/--
The cumulative paid-excess budget gives a uniform positive reserve floor on the
same collision-opening prefixes.
-/
theorem CUMULATIVE_PAID_EXCESS_GIVES_UNIFORM_RESERVE_FLOOR
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    {O : CollisionOpening B}
    (L : ExactGapExcessLedger O)
    (hBudget : CumulativePaidExcessBudget L) :
    ∃ ε : ℝ, 0 < ε ∧ ∀ n : ℕ, ε ≤ gapReserve (O.gap n) := by
  rcases hBudget with ⟨paid, ε, hε, hEnvelope, _hPaidNonneg, hPrefix⟩
  refine ⟨ε, hε, ?_⟩
  intro n
  have hExcessPaid :
      (Finset.sum (Finset.range n) L.excess) ≤
        Finset.sum (Finset.range n) paid :=
    EXCESS_PREFIX_LE_PAID_PREFIX L paid hEnvelope n
  have hPaidCap :
      Finset.sum (Finset.range n) paid ≤ gapReserve (O.gap 0) - ε :=
    hPrefix n
  have hTel := EXACT_EXCESS_INCREMENT_TELESCOPES L n
  calc
    ε ≤ gapReserve (O.gap 0) - Finset.sum (Finset.range n) paid := by linarith
    _ ≤ gapReserve (O.gap 0) - Finset.sum (Finset.range n) L.excess := by linarith
    _ = gapReserve (O.gap n) := hTel.symm

/-- The exact ledger plus paid-excess budget constructs the opening margin. -/
theorem NATIVE_LEDGER_CONSTRUCTS_OPENING_RESERVE_MARGIN
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    (O : CollisionOpening B)
    (L : ExactGapExcessLedger O)
    (hBudget : CumulativePaidExcessBudget L) :
    ∃ ε : ℝ, 0 < ε ∧ ∀ n : ℕ, ε ≤ gapReserve (O.gap n) :=
  CUMULATIVE_PAID_EXCESS_GIVES_UNIFORM_RESERVE_FLOOR L hBudget

/--
Native theorem-level GP/BKQR input: every covered opening carries an exact
excess ledger and cumulative paid-excess budget.  No axiom is declared here.
-/
def NativeGPBKQRLedgerPackage
    (NontrivialZero : ℝ → ℝ → Prop)
    (HeatZero : ℝ → ℝ → ℝ → Prop) : Prop :=
  ∀ β γ : ℝ, (B : PointwiseHeatBranch HeatZero β γ) →
    NontrivialZero β γ →
    ∀ O : CollisionOpening B,
      ∃ L : ExactGapExcessLedger O, CumulativePaidExcessBudget L

/--
The native exact-ledger package theoremically constructs the older GP/BKQR
uniform-opening-reserve package.
-/
theorem NATIVE_LEDGER_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE
    {NontrivialZero : ℝ → ℝ → Prop}
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    (hNative : NativeGPBKQRLedgerPackage NontrivialZero HeatZero) :
    GPBKQRPointwiseReservePackage NontrivialZero HeatZero := by
  refine ⟨?_⟩
  intro β γ B hZero
  unfold GPBKQRUniformOpeningReserveMargin
  intro O
  obtain ⟨L, hBudget⟩ := hNative β γ B hZero O
  exact NATIVE_LEDGER_CONSTRUCTS_OPENING_RESERVE_MARGIN O L hBudget

/--
Pure native theorem: Xi analytic package plus the exact GP/BKQR ledger package
implies the abstract pointwise RH statement.  No research axioms occur in this
file.
-/
theorem XI_PLUS_NATIVE_LEDGER_IMPLIES_POINTWISE_RH
    {NontrivialZero : ℝ → ℝ → Prop}
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    {safeThreshold : ℝ}
    {EscapeEvent : ℝ → ℝ → Prop}
    (hXi : XiAnalyticPointwisePackage NontrivialZero HeatZero safeThreshold EscapeEvent)
    (hNative : NativeGPBKQRLedgerPackage NontrivialZero HeatZero) :
    RHPointwise NontrivialZero := by
  exact TWO_INTERFACE_POINTWISE_CLOSURE hXi
    (NATIVE_LEDGER_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE hNative)

/-- Native theorem landing on Mathlib's literal `RiemannHypothesis`. -/
theorem ACTUAL_XI_PLUS_NATIVE_LEDGER_IMPLIES_MATHLIB_RH
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    {safeThreshold : ℝ}
    {EscapeEvent : ℝ → ℝ → Prop}
    (hXi : XiAnalyticPointwisePackage
      ActualNontrivialZero HeatZero safeThreshold EscapeEvent)
    (hNative : NativeGPBKQRLedgerPackage ActualNontrivialZero HeatZero) :
    RiemannHypothesis := by
  apply ACTUAL_POINTWISE_CLOSURE_IMPLIES_MATHLIB_RH
  exact XI_PLUS_NATIVE_LEDGER_IMPLIES_POINTWISE_RH hXi hNative


/-! ## Canonical positive-excess reduction -/

/-- Canonical nonnegative payment attached to one signed excess increment. -/
def positivePart (x : ℝ) : ℝ := max x 0

/-- Every signed excess is bounded by its canonical positive part. -/
theorem EXCESS_LE_POSITIVE_PART (x : ℝ) : x ≤ positivePart x := by
  unfold positivePart
  exact le_max_left x 0

/-- The canonical positive part is nonnegative. -/
theorem POSITIVE_PART_NONNEGATIVE (x : ℝ) : 0 ≤ positivePart x := by
  unfold positivePart
  exact le_max_right x 0

/--
Exact field-level gap-square increment.  This is the direct discrete form of
`d(a^2)/dt = -4 η` from the passing Rocq field-gap anchor.
-/
structure ExactFieldGapSquareIncrement
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    (O : CollisionOpening B) where
  leftField : ℕ → ℝ
  rightField : ℕ → ℝ
  gapSquareIncrement : ∀ n : ℕ,
    O.gap (n + 1) * O.gap (n + 1) =
      O.gap n * O.gap n -
        4 * fieldExcess (O.gap n) (leftField n) (rightField n)

/--
The exact gap-square increment natively constructs the reserve/excess ledger.
No payment or capacity assumption is used here.
-/
def FIELD_GAP_SQUARE_INCREMENT_CONSTRUCTS_EXACT_EXCESS_LEDGER
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    {O : CollisionOpening B}
    (F : ExactFieldGapSquareIncrement O) : ExactGapExcessLedger O where
  excess n := fieldExcess (O.gap n) (F.leftField n) (F.rightField n)
  reserveIncrement n := by
    unfold gapReserve
    nlinarith [F.gapSquareIncrement n]

/--
The only quantitative budget needed after choosing the canonical payment
`(η_n)_+`: every positive-excess prefix stays strictly below initial reserve.
-/
def PositiveExcessPrefixBudget
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    {O : CollisionOpening B}
    (L : ExactGapExcessLedger O) : Prop :=
  ∃ ε : ℝ,
    0 < ε ∧
    ∀ n : ℕ,
      Finset.sum (Finset.range n) (fun k => positivePart (L.excess k)) ≤
        gapReserve (O.gap 0) - ε

/--
Canonical positive-part payment constructs the older cumulative paid-excess
budget automatically.
-/
theorem POSITIVE_EXCESS_PREFIX_BUDGET_CONSTRUCTS_PAID_BUDGET
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    {O : CollisionOpening B}
    (L : ExactGapExcessLedger O)
    (hPositive : PositiveExcessPrefixBudget L) :
    CumulativePaidExcessBudget L := by
  rcases hPositive with ⟨ε, hε, hPrefix⟩
  refine ⟨(fun n => positivePart (L.excess n)), ε, hε, ?_, ?_, ?_⟩
  · intro n
    exact EXCESS_LE_POSITIVE_PART (L.excess n)
  · intro n
    exact POSITIVE_PART_NONNEGATIVE (L.excess n)
  · intro n
    exact hPrefix n

/--
Field gap-square realization plus the positive-excess prefix bound yields the
uniform reserve floor directly.
-/
theorem FIELD_INCREMENT_PLUS_POSITIVE_EXCESS_BUDGET_GIVES_RESERVE_FLOOR
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    {O : CollisionOpening B}
    (F : ExactFieldGapSquareIncrement O)
    (hPositive : PositiveExcessPrefixBudget
      (FIELD_GAP_SQUARE_INCREMENT_CONSTRUCTS_EXACT_EXCESS_LEDGER F)) :
    ∃ ε : ℝ, 0 < ε ∧ ∀ n : ℕ, ε ≤ gapReserve (O.gap n) := by
  let L : ExactGapExcessLedger O :=
    FIELD_GAP_SQUARE_INCREMENT_CONSTRUCTS_EXACT_EXCESS_LEDGER F
  have hPaid : CumulativePaidExcessBudget L := by
    exact POSITIVE_EXCESS_PREFIX_BUDGET_CONSTRUCTS_PAID_BUDGET L hPositive
  exact CUMULATIVE_PAID_EXCESS_GIVES_UNIFORM_RESERVE_FLOOR L hPaid

/--
Smaller native GP/BKQR input: actual field-level gap-square increments plus a
strict bound on cumulative positive excess.  No arbitrary paid sequence remains.
-/
def NativeFieldPositiveExcessPackage
    (NontrivialZero : ℝ → ℝ → Prop)
    (HeatZero : ℝ → ℝ → ℝ → Prop) : Prop :=
  ∀ β γ : ℝ, (B : PointwiseHeatBranch HeatZero β γ) →
    NontrivialZero β γ →
    ∀ O : CollisionOpening B,
      ∃ F : ExactFieldGapSquareIncrement O,
        PositiveExcessPrefixBudget
          (FIELD_GAP_SQUARE_INCREMENT_CONSTRUCTS_EXACT_EXCESS_LEDGER F)

/--
The smaller field/positive-excess package theoremically constructs the previous
native exact-ledger package.
-/
theorem FIELD_POSITIVE_EXCESS_PACKAGE_CONSTRUCTS_NATIVE_LEDGER_PACKAGE
    {NontrivialZero : ℝ → ℝ → Prop}
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    (hField : NativeFieldPositiveExcessPackage NontrivialZero HeatZero) :
    NativeGPBKQRLedgerPackage NontrivialZero HeatZero := by
  intro β γ B hZero O
  obtain ⟨F, hPositive⟩ := hField β γ B hZero O
  let L : ExactGapExcessLedger O :=
    FIELD_GAP_SQUARE_INCREMENT_CONSTRUCTS_EXACT_EXCESS_LEDGER F
  refine ⟨L, ?_⟩
  exact POSITIVE_EXCESS_PREFIX_BUDGET_CONSTRUCTS_PAID_BUDGET L hPositive

/--
The smaller native field/positive-excess package constructs the old reserve
package with no research axiom declarations.
-/
theorem FIELD_POSITIVE_EXCESS_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE
    {NontrivialZero : ℝ → ℝ → Prop}
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    (hField : NativeFieldPositiveExcessPackage NontrivialZero HeatZero) :
    GPBKQRPointwiseReservePackage NontrivialZero HeatZero := by
  exact NATIVE_LEDGER_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE
    (FIELD_POSITIVE_EXCESS_PACKAGE_CONSTRUCTS_NATIVE_LEDGER_PACKAGE hField)

/-- Native pointwise RH theorem using the reduced GP/BKQR input. -/
theorem XI_PLUS_FIELD_POSITIVE_EXCESS_IMPLIES_POINTWISE_RH
    {NontrivialZero : ℝ → ℝ → Prop}
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    {safeThreshold : ℝ}
    {EscapeEvent : ℝ → ℝ → Prop}
    (hXi : XiAnalyticPointwisePackage NontrivialZero HeatZero safeThreshold EscapeEvent)
    (hField : NativeFieldPositiveExcessPackage NontrivialZero HeatZero) :
    RHPointwise NontrivialZero := by
  exact TWO_INTERFACE_POINTWISE_CLOSURE hXi
    (FIELD_POSITIVE_EXCESS_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE hField)

/-- Native theorem landing on Mathlib RH from the reduced GP/BKQR input. -/
theorem ACTUAL_XI_PLUS_FIELD_POSITIVE_EXCESS_IMPLIES_MATHLIB_RH
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    {safeThreshold : ℝ}
    {EscapeEvent : ℝ → ℝ → Prop}
    (hXi : XiAnalyticPointwisePackage
      ActualNontrivialZero HeatZero safeThreshold EscapeEvent)
    (hField : NativeFieldPositiveExcessPackage ActualNontrivialZero HeatZero) :
    RiemannHypothesis := by
  apply ACTUAL_POINTWISE_CLOSURE_IMPLIES_MATHLIB_RH
  exact XI_PLUS_FIELD_POSITIVE_EXCESS_IMPLIES_POINTWISE_RH hXi hField


/-! ## Native BKQR capacity reduction -/

/--
A single scalar capacity ceiling for all canonical positive-excess prefixes.
The strict comparison with the initial reserve will generate the slack
`epsilon = R_0 - C` natively.
-/
def PositiveExcessCapacityCeiling
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    {O : CollisionOpening B}
    (L : ExactGapExcessLedger O) : Prop :=
  ∃ C : ℝ,
    (∀ n : ℕ,
      Finset.sum (Finset.range n) (fun k => positivePart (L.excess k)) ≤ C) ∧
    C < gapReserve (O.gap 0)

/--
A capacity ceiling strictly below the initial reserve automatically constructs
exactly the positive-excess prefix budget required by the previous reduction.
-/
theorem CAPACITY_CEILING_CONSTRUCTS_POSITIVE_EXCESS_PREFIX_BUDGET
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    {O : CollisionOpening B}
    (L : ExactGapExcessLedger O)
    (hCapacity : PositiveExcessCapacityCeiling L) :
    PositiveExcessPrefixBudget L := by
  rcases hCapacity with ⟨C, hPrefix, hStrict⟩
  refine ⟨gapReserve (O.gap 0) - C, ?_, ?_⟩
  · linarith
  · intro n
    have h := hPrefix n
    linarith

/--
BKQR-style per-prefix capacity majorant.  The canonical positive excess is
majorized pointwise by a capacity channel, whose cumulative prefix is bounded
by one scalar `bound` lying strictly below the initial gap reserve.
-/
structure GPBKQRCapacityMajorant
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    {O : CollisionOpening B}
    (L : ExactGapExcessLedger O) where
  capacity : ℕ → ℝ
  positiveExcessLeCapacity : ∀ n : ℕ,
    positivePart (L.excess n) ≤ capacity n
  bound : ℝ
  prefixCapacityLeBound : ∀ n : ℕ,
    Finset.sum (Finset.range n) capacity ≤ bound
  boundBelowInitialReserve : bound < gapReserve (O.gap 0)

/-- Pointwise capacity domination lifts to every finite prefix. -/
theorem POSITIVE_EXCESS_PREFIX_LE_CAPACITY_PREFIX
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    {O : CollisionOpening B}
    {L : ExactGapExcessLedger O}
    (M : GPBKQRCapacityMajorant L) :
    ∀ n : ℕ,
      Finset.sum (Finset.range n) (fun k => positivePart (L.excess k)) ≤
        Finset.sum (Finset.range n) M.capacity := by
  intro n
  exact Finset.sum_le_sum (fun k _hk => M.positiveExcessLeCapacity k)

/-- BKQR capacity majorization constructs the scalar positive-excess ceiling. -/
theorem CAPACITY_MAJORANT_CONSTRUCTS_POSITIVE_EXCESS_CAPACITY_CEILING
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    {O : CollisionOpening B}
    {L : ExactGapExcessLedger O}
    (M : GPBKQRCapacityMajorant L) :
    PositiveExcessCapacityCeiling L := by
  refine ⟨M.bound, ?_, M.boundBelowInitialReserve⟩
  intro n
  exact le_trans
    (POSITIVE_EXCESS_PREFIX_LE_CAPACITY_PREFIX M n)
    (M.prefixCapacityLeBound n)

/-- BKQR capacity majorization constructs the previous strict prefix budget. -/
theorem CAPACITY_MAJORANT_CONSTRUCTS_POSITIVE_EXCESS_PREFIX_BUDGET
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    {O : CollisionOpening B}
    (L : ExactGapExcessLedger O)
    (M : GPBKQRCapacityMajorant L) :
    PositiveExcessPrefixBudget L := by
  exact CAPACITY_CEILING_CONSTRUCTS_POSITIVE_EXCESS_PREFIX_BUDGET L
    (CAPACITY_MAJORANT_CONSTRUCTS_POSITIVE_EXCESS_CAPACITY_CEILING M)

/--
Exact field gap-square increments plus a BKQR capacity majorant yield the
uniform positive reserve floor, with all telescope/payment/slack steps native.
-/
theorem FIELD_INCREMENT_PLUS_CAPACITY_MAJORANT_GIVES_RESERVE_FLOOR
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    {O : CollisionOpening B}
    (F : ExactFieldGapSquareIncrement O)
    (M : GPBKQRCapacityMajorant
      (FIELD_GAP_SQUARE_INCREMENT_CONSTRUCTS_EXACT_EXCESS_LEDGER F)) :
    ∃ ε : ℝ, 0 < ε ∧ ∀ n : ℕ, ε ≤ gapReserve (O.gap n) := by
  let L : ExactGapExcessLedger O :=
    FIELD_GAP_SQUARE_INCREMENT_CONSTRUCTS_EXACT_EXCESS_LEDGER F
  have hPositive : PositiveExcessPrefixBudget L := by
    exact CAPACITY_MAJORANT_CONSTRUCTS_POSITIVE_EXCESS_PREFIX_BUDGET L M
  exact FIELD_INCREMENT_PLUS_POSITIVE_EXCESS_BUDGET_GIVES_RESERVE_FLOOR F hPositive

/--
Reduced theorem-level GP input: actual field increments and a BKQR capacity
majorant.  The strict positive-excess budget is no longer primitive.
-/
def NativeFieldCapacityPackage
    (NontrivialZero : ℝ → ℝ → Prop)
    (HeatZero : ℝ → ℝ → ℝ → Prop) : Prop :=
  ∀ β γ : ℝ, (B : PointwiseHeatBranch HeatZero β γ) →
    NontrivialZero β γ →
    ∀ O : CollisionOpening B,
      ∃ F : ExactFieldGapSquareIncrement O,
        Nonempty (GPBKQRCapacityMajorant
          (FIELD_GAP_SQUARE_INCREMENT_CONSTRUCTS_EXACT_EXCESS_LEDGER F))

/-- The capacity package constructs the previous field-positive-excess package. -/
theorem FIELD_CAPACITY_PACKAGE_CONSTRUCTS_FIELD_POSITIVE_EXCESS_PACKAGE
    {NontrivialZero : ℝ → ℝ → Prop}
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    (hCapacity : NativeFieldCapacityPackage NontrivialZero HeatZero) :
    NativeFieldPositiveExcessPackage NontrivialZero HeatZero := by
  intro β γ B hZero O
  obtain ⟨F, ⟨M⟩⟩ := hCapacity β γ B hZero O
  refine ⟨F, ?_⟩
  exact CAPACITY_MAJORANT_CONSTRUCTS_POSITIVE_EXCESS_PREFIX_BUDGET
    (FIELD_GAP_SQUARE_INCREMENT_CONSTRUCTS_EXACT_EXCESS_LEDGER F) M

/-- The capacity package natively constructs the old GP/BKQR reserve package. -/
theorem FIELD_CAPACITY_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE
    {NontrivialZero : ℝ → ℝ → Prop}
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    (hCapacity : NativeFieldCapacityPackage NontrivialZero HeatZero) :
    GPBKQRPointwiseReservePackage NontrivialZero HeatZero := by
  refine ⟨?_⟩
  intro β γ B hZero
  unfold GPBKQRUniformOpeningReserveMargin
  intro O
  obtain ⟨F, ⟨M⟩⟩ := hCapacity β γ B hZero O
  exact FIELD_INCREMENT_PLUS_CAPACITY_MAJORANT_GIVES_RESERVE_FLOOR F M

/-- Native pointwise RH theorem from Xi analytics plus the reduced capacity input. -/
theorem XI_PLUS_FIELD_CAPACITY_IMPLIES_POINTWISE_RH
    {NontrivialZero : ℝ → ℝ → Prop}
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    {safeThreshold : ℝ}
    {EscapeEvent : ℝ → ℝ → Prop}
    (hXi : XiAnalyticPointwisePackage NontrivialZero HeatZero safeThreshold EscapeEvent)
    (hCapacity : NativeFieldCapacityPackage NontrivialZero HeatZero) :
    RHPointwise NontrivialZero := by
  exact TWO_INTERFACE_POINTWISE_CLOSURE hXi
    (FIELD_CAPACITY_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE hCapacity)

/-- Native Mathlib RH theorem from Xi analytics plus the reduced capacity input. -/
theorem ACTUAL_XI_PLUS_FIELD_CAPACITY_IMPLIES_MATHLIB_RH
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    {safeThreshold : ℝ}
    {EscapeEvent : ℝ → ℝ → Prop}
    (hXi : XiAnalyticPointwisePackage
      ActualNontrivialZero HeatZero safeThreshold EscapeEvent)
    (hCapacity : NativeFieldCapacityPackage ActualNontrivialZero HeatZero) :
    RiemannHypothesis := by
  apply ACTUAL_POINTWISE_CLOSURE_IMPLIES_MATHLIB_RH
  exact XI_PLUS_FIELD_CAPACITY_IMPLIES_POINTWISE_RH hXi hCapacity



/-! ## Native global GP/BKQR storage reduction -/

/--
Global GP/BKQR storage data.  There is no arbitrary prefix bound and no
separate scalar capacity ceiling: the total summable storage itself is the
canonical bound.  Nonnegativity of the capacity channel is derived from the
pointwise domination of the nonnegative positive excess.
-/
structure GPBKQRGlobalStorage
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    {O : CollisionOpening B}
    (L : ExactGapExcessLedger O) where
  capacity : ℕ → ℝ
  positiveExcessLeCapacity : ∀ n : ℕ,
    positivePart (L.excess n) ≤ capacity n
  capacitySummable : Summable capacity
  totalCapacityBelowInitialReserve :
    (∑' n : ℕ, capacity n) < gapReserve (O.gap 0)

/-- Capacity nonnegativity is automatic from domination of positive excess. -/
theorem GLOBAL_STORAGE_CAPACITY_NONNEGATIVE
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    {O : CollisionOpening B}
    {L : ExactGapExcessLedger O}
    (S : GPBKQRGlobalStorage L) (n : ℕ) :
    0 ≤ S.capacity n := by
  exact le_trans (POSITIVE_PART_NONNEGATIVE (L.excess n))
    (S.positiveExcessLeCapacity n)

/--
Every finite capacity prefix is bounded by the single global stored capacity.
This is a pure mathlib infinite-sum theorem once summability and nonnegativity
are available.
-/
theorem GLOBAL_STORAGE_PREFIX_CAPACITY_LE_TOTAL
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    {O : CollisionOpening B}
    {L : ExactGapExcessLedger O}
    (S : GPBKQRGlobalStorage L) (n : ℕ) :
    Finset.sum (Finset.range n) S.capacity ≤ ∑' k : ℕ, S.capacity k := by
  exact Summable.sum_le_tsum (Finset.range n)
    (fun i _hi => GLOBAL_STORAGE_CAPACITY_NONNEGATIVE S i)
    S.capacitySummable

/--
The global storage object natively constructs the previous prefix-capacity
majorant, with bound chosen canonically as the total infinite storage.
-/
theorem GLOBAL_STORAGE_CONSTRUCTS_CAPACITY_MAJORANT
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    {O : CollisionOpening B}
    {L : ExactGapExcessLedger O}
    (S : GPBKQRGlobalStorage L) :
    Nonempty (GPBKQRCapacityMajorant L) := by
  refine ⟨{
    capacity := S.capacity
    positiveExcessLeCapacity := S.positiveExcessLeCapacity
    bound := ∑' k : ℕ, S.capacity k
    prefixCapacityLeBound := ?_
    boundBelowInitialReserve := S.totalCapacityBelowInitialReserve
  }⟩
  intro n
  exact GLOBAL_STORAGE_PREFIX_CAPACITY_LE_TOTAL S n

/-- Global storage therefore gives the uniform gap-reserve floor. -/
theorem FIELD_INCREMENT_PLUS_GLOBAL_STORAGE_GIVES_RESERVE_FLOOR
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    {O : CollisionOpening B}
    (F : ExactFieldGapSquareIncrement O)
    (S : GPBKQRGlobalStorage
      (FIELD_GAP_SQUARE_INCREMENT_CONSTRUCTS_EXACT_EXCESS_LEDGER F)) :
    ∃ ε : ℝ, 0 < ε ∧ ∀ n : ℕ, ε ≤ gapReserve (O.gap n) := by
  obtain ⟨M⟩ := GLOBAL_STORAGE_CONSTRUCTS_CAPACITY_MAJORANT S
  exact FIELD_INCREMENT_PLUS_CAPACITY_MAJORANT_GIVES_RESERVE_FLOOR F M

/--
Reduced theorem-level GP input: actual field increment plus one global
summable storage channel whose total mass is below the initial reserve.
-/
def NativeFieldGlobalStoragePackage
    (NontrivialZero : ℝ → ℝ → Prop)
    (HeatZero : ℝ → ℝ → ℝ → Prop) : Prop :=
  ∀ β γ : ℝ, (B : PointwiseHeatBranch HeatZero β γ) →
    NontrivialZero β γ →
    ∀ O : CollisionOpening B,
      ∃ F : ExactFieldGapSquareIncrement O,
        Nonempty (GPBKQRGlobalStorage
          (FIELD_GAP_SQUARE_INCREMENT_CONSTRUCTS_EXACT_EXCESS_LEDGER F))

/-- Global storage natively constructs the previous field-capacity package. -/
theorem GLOBAL_STORAGE_PACKAGE_CONSTRUCTS_FIELD_CAPACITY_PACKAGE
    {NontrivialZero : ℝ → ℝ → Prop}
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    (hStorage : NativeFieldGlobalStoragePackage NontrivialZero HeatZero) :
    NativeFieldCapacityPackage NontrivialZero HeatZero := by
  intro β γ B hZero O
  obtain ⟨F, ⟨S⟩⟩ := hStorage β γ B hZero O
  refine ⟨F, ?_⟩
  exact GLOBAL_STORAGE_CONSTRUCTS_CAPACITY_MAJORANT S

/-- Global storage natively constructs the old GP/BKQR reserve package. -/
theorem GLOBAL_STORAGE_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE
    {NontrivialZero : ℝ → ℝ → Prop}
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    (hStorage : NativeFieldGlobalStoragePackage NontrivialZero HeatZero) :
    GPBKQRPointwiseReservePackage NontrivialZero HeatZero := by
  exact FIELD_CAPACITY_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE
    (GLOBAL_STORAGE_PACKAGE_CONSTRUCTS_FIELD_CAPACITY_PACKAGE hStorage)

/-- Native pointwise RH from Xi analytics plus global GP/BKQR storage. -/
theorem XI_PLUS_GLOBAL_STORAGE_IMPLIES_POINTWISE_RH
    {NontrivialZero : ℝ → ℝ → Prop}
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    {safeThreshold : ℝ}
    {EscapeEvent : ℝ → ℝ → Prop}
    (hXi : XiAnalyticPointwisePackage NontrivialZero HeatZero safeThreshold EscapeEvent)
    (hStorage : NativeFieldGlobalStoragePackage NontrivialZero HeatZero) :
    RHPointwise NontrivialZero := by
  exact TWO_INTERFACE_POINTWISE_CLOSURE hXi
    (GLOBAL_STORAGE_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE hStorage)

/-- Native Mathlib RH from Xi analytics plus global GP/BKQR storage. -/
theorem ACTUAL_XI_PLUS_GLOBAL_STORAGE_IMPLIES_MATHLIB_RH
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    {safeThreshold : ℝ}
    {EscapeEvent : ℝ → ℝ → Prop}
    (hXi : XiAnalyticPointwisePackage
      ActualNontrivialZero HeatZero safeThreshold EscapeEvent)
    (hStorage : NativeFieldGlobalStoragePackage ActualNontrivialZero HeatZero) :
    RiemannHypothesis := by
  apply ACTUAL_POINTWISE_CLOSURE_IMPLIES_MATHLIB_RH
  exact XI_PLUS_GLOBAL_STORAGE_IMPLIES_POINTWISE_RH hXi hStorage

#check GLOBAL_STORAGE_CAPACITY_NONNEGATIVE
#check GLOBAL_STORAGE_PREFIX_CAPACITY_LE_TOTAL
#check GLOBAL_STORAGE_CONSTRUCTS_CAPACITY_MAJORANT
#check FIELD_INCREMENT_PLUS_GLOBAL_STORAGE_GIVES_RESERVE_FLOOR
#check GLOBAL_STORAGE_PACKAGE_CONSTRUCTS_FIELD_CAPACITY_PACKAGE
#check GLOBAL_STORAGE_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE
#check XI_PLUS_GLOBAL_STORAGE_IMPLIES_POINTWISE_RH
#check ACTUAL_XI_PLUS_GLOBAL_STORAGE_IMPLIES_MATHLIB_RH

#print axioms GLOBAL_STORAGE_CAPACITY_NONNEGATIVE
#print axioms GLOBAL_STORAGE_PREFIX_CAPACITY_LE_TOTAL
#print axioms GLOBAL_STORAGE_CONSTRUCTS_CAPACITY_MAJORANT
#print axioms FIELD_INCREMENT_PLUS_GLOBAL_STORAGE_GIVES_RESERVE_FLOOR
#print axioms GLOBAL_STORAGE_PACKAGE_CONSTRUCTS_FIELD_CAPACITY_PACKAGE
#print axioms GLOBAL_STORAGE_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE
#print axioms XI_PLUS_GLOBAL_STORAGE_IMPLIES_POINTWISE_RH
#print axioms ACTUAL_XI_PLUS_GLOBAL_STORAGE_IMPLIES_MATHLIB_RH

#check CAPACITY_CEILING_CONSTRUCTS_POSITIVE_EXCESS_PREFIX_BUDGET
#check POSITIVE_EXCESS_PREFIX_LE_CAPACITY_PREFIX
#check CAPACITY_MAJORANT_CONSTRUCTS_POSITIVE_EXCESS_CAPACITY_CEILING
#check CAPACITY_MAJORANT_CONSTRUCTS_POSITIVE_EXCESS_PREFIX_BUDGET
#check FIELD_INCREMENT_PLUS_CAPACITY_MAJORANT_GIVES_RESERVE_FLOOR
#check FIELD_CAPACITY_PACKAGE_CONSTRUCTS_FIELD_POSITIVE_EXCESS_PACKAGE
#check FIELD_CAPACITY_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE
#check XI_PLUS_FIELD_CAPACITY_IMPLIES_POINTWISE_RH
#check ACTUAL_XI_PLUS_FIELD_CAPACITY_IMPLIES_MATHLIB_RH

#print axioms CAPACITY_CEILING_CONSTRUCTS_POSITIVE_EXCESS_PREFIX_BUDGET
#print axioms CAPACITY_MAJORANT_CONSTRUCTS_POSITIVE_EXCESS_PREFIX_BUDGET
#print axioms FIELD_INCREMENT_PLUS_CAPACITY_MAJORANT_GIVES_RESERVE_FLOOR
#print axioms FIELD_CAPACITY_PACKAGE_CONSTRUCTS_FIELD_POSITIVE_EXCESS_PACKAGE
#print axioms FIELD_CAPACITY_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE
#print axioms XI_PLUS_FIELD_CAPACITY_IMPLIES_POINTWISE_RH
#print axioms ACTUAL_XI_PLUS_FIELD_CAPACITY_IMPLIES_MATHLIB_RH


/-! ## Canonical positive-excess storage reduction -/

/--
The capacity channel can be chosen canonically as the positive part of the
signed excess itself.  The only remaining storage hypotheses are summability
of that canonical sequence and strict total mass below the initial reserve.
-/
def CanonicalPositiveExcessStorage
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    {O : CollisionOpening B}
    (L : ExactGapExcessLedger O) : Prop :=
  Summable (fun n : ℕ => positivePart (L.excess n)) ∧
  (∑' n : ℕ, positivePart (L.excess n)) < gapReserve (O.gap 0)

/-- Canonical positive-excess storage natively realizes the global storage object. -/
theorem CANONICAL_POSITIVE_EXCESS_STORAGE_CONSTRUCTS_GLOBAL_STORAGE
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    {O : CollisionOpening B}
    {L : ExactGapExcessLedger O}
    (hCanonical : CanonicalPositiveExcessStorage L) :
    Nonempty (GPBKQRGlobalStorage L) := by
  rcases hCanonical with ⟨hSummable, hStrict⟩
  refine ⟨{
    capacity := fun n => positivePart (L.excess n)
    positiveExcessLeCapacity := ?_
    capacitySummable := hSummable
    totalCapacityBelowInitialReserve := hStrict
  }⟩
  intro n
  exact le_rfl

/--
Exact field increment plus canonical positive-excess summability below reserve
gives the uniform reserve floor, with no auxiliary capacity channel.
-/
theorem FIELD_INCREMENT_PLUS_CANONICAL_EXCESS_STORAGE_GIVES_RESERVE_FLOOR
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    {O : CollisionOpening B}
    (F : ExactFieldGapSquareIncrement O)
    (hCanonical : CanonicalPositiveExcessStorage
      (FIELD_GAP_SQUARE_INCREMENT_CONSTRUCTS_EXACT_EXCESS_LEDGER F)) :
    ∃ ε : ℝ, 0 < ε ∧ ∀ n : ℕ, ε ≤ gapReserve (O.gap n) := by
  obtain ⟨S⟩ := CANONICAL_POSITIVE_EXCESS_STORAGE_CONSTRUCTS_GLOBAL_STORAGE hCanonical
  exact FIELD_INCREMENT_PLUS_GLOBAL_STORAGE_GIVES_RESERVE_FLOOR F S

/--
Reduced theorem-level GP input: exact field increments plus summability of the
canonical positive excess with total mass strictly below initial reserve.
No arbitrary capacity sequence remains.
-/
def NativeFieldCanonicalExcessStoragePackage
    (NontrivialZero : ℝ → ℝ → Prop)
    (HeatZero : ℝ → ℝ → ℝ → Prop) : Prop :=
  ∀ β γ : ℝ, (B : PointwiseHeatBranch HeatZero β γ) →
    NontrivialZero β γ →
    ∀ O : CollisionOpening B,
      ∃ F : ExactFieldGapSquareIncrement O,
        CanonicalPositiveExcessStorage
          (FIELD_GAP_SQUARE_INCREMENT_CONSTRUCTS_EXACT_EXCESS_LEDGER F)

/-- Canonical excess storage constructs the previous global-storage package. -/
theorem CANONICAL_EXCESS_STORAGE_PACKAGE_CONSTRUCTS_GLOBAL_STORAGE_PACKAGE
    {NontrivialZero : ℝ → ℝ → Prop}
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    (hCanonical : NativeFieldCanonicalExcessStoragePackage NontrivialZero HeatZero) :
    NativeFieldGlobalStoragePackage NontrivialZero HeatZero := by
  intro β γ B hZero O
  obtain ⟨F, hStorage⟩ := hCanonical β γ B hZero O
  refine ⟨F, ?_⟩
  exact CANONICAL_POSITIVE_EXCESS_STORAGE_CONSTRUCTS_GLOBAL_STORAGE hStorage

/-- Canonical excess storage constructs the old GP/BKQR reserve package. -/
theorem CANONICAL_EXCESS_STORAGE_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE
    {NontrivialZero : ℝ → ℝ → Prop}
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    (hCanonical : NativeFieldCanonicalExcessStoragePackage NontrivialZero HeatZero) :
    GPBKQRPointwiseReservePackage NontrivialZero HeatZero := by
  exact GLOBAL_STORAGE_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE
    (CANONICAL_EXCESS_STORAGE_PACKAGE_CONSTRUCTS_GLOBAL_STORAGE_PACKAGE hCanonical)

/-- Native pointwise RH from Xi analytics plus canonical positive-excess storage. -/
theorem XI_PLUS_CANONICAL_EXCESS_STORAGE_IMPLIES_POINTWISE_RH
    {NontrivialZero : ℝ → ℝ → Prop}
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    {safeThreshold : ℝ}
    {EscapeEvent : ℝ → ℝ → Prop}
    (hXi : XiAnalyticPointwisePackage NontrivialZero HeatZero safeThreshold EscapeEvent)
    (hCanonical : NativeFieldCanonicalExcessStoragePackage NontrivialZero HeatZero) :
    RHPointwise NontrivialZero := by
  exact TWO_INTERFACE_POINTWISE_CLOSURE hXi
    (CANONICAL_EXCESS_STORAGE_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE hCanonical)

/-- Native Mathlib RH theorem from Xi analytics plus canonical positive-excess storage. -/
theorem ACTUAL_XI_PLUS_CANONICAL_EXCESS_STORAGE_IMPLIES_MATHLIB_RH
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    {safeThreshold : ℝ}
    {EscapeEvent : ℝ → ℝ → Prop}
    (hXi : XiAnalyticPointwisePackage
      ActualNontrivialZero HeatZero safeThreshold EscapeEvent)
    (hCanonical : NativeFieldCanonicalExcessStoragePackage
      ActualNontrivialZero HeatZero) :
    RiemannHypothesis := by
  apply ACTUAL_POINTWISE_CLOSURE_IMPLIES_MATHLIB_RH
  exact XI_PLUS_CANONICAL_EXCESS_STORAGE_IMPLIES_POINTWISE_RH hXi hCanonical

#check CANONICAL_POSITIVE_EXCESS_STORAGE_CONSTRUCTS_GLOBAL_STORAGE
#check FIELD_INCREMENT_PLUS_CANONICAL_EXCESS_STORAGE_GIVES_RESERVE_FLOOR
#check CANONICAL_EXCESS_STORAGE_PACKAGE_CONSTRUCTS_GLOBAL_STORAGE_PACKAGE
#check CANONICAL_EXCESS_STORAGE_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE
#check XI_PLUS_CANONICAL_EXCESS_STORAGE_IMPLIES_POINTWISE_RH
#check ACTUAL_XI_PLUS_CANONICAL_EXCESS_STORAGE_IMPLIES_MATHLIB_RH

#print axioms CANONICAL_POSITIVE_EXCESS_STORAGE_CONSTRUCTS_GLOBAL_STORAGE
#print axioms FIELD_INCREMENT_PLUS_CANONICAL_EXCESS_STORAGE_GIVES_RESERVE_FLOOR
#print axioms CANONICAL_EXCESS_STORAGE_PACKAGE_CONSTRUCTS_GLOBAL_STORAGE_PACKAGE
#print axioms CANONICAL_EXCESS_STORAGE_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE
#print axioms XI_PLUS_CANONICAL_EXCESS_STORAGE_IMPLIES_POINTWISE_RH
#print axioms ACTUAL_XI_PLUS_CANONICAL_EXCESS_STORAGE_IMPLIES_MATHLIB_RH


/-! ## Canonical reserve-variation reduction -/

/--
The signed excess can be defined canonically from the reserve sequence itself.
This removes the separate field-increment witness from the purely logical
reserve contradiction.
-/
def canonicalReserveExcess
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    (O : CollisionOpening B) (n : ℕ) : ℝ :=
  gapReserve (O.gap n) - gapReserve (O.gap (n + 1))

/-- The canonical reserve decrement gives an exact excess ledger definitionally. -/
def CANONICAL_RESERVE_EXCESS_CONSTRUCTS_EXACT_LEDGER
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    (O : CollisionOpening B) : ExactGapExcessLedger O where
  excess n := canonicalReserveExcess O n
  reserveIncrement n := by
    unfold canonicalReserveExcess
    ring

/--
The minimal reserve-side quantitative input: the positive variation of the
canonical reserve decrement is summable and its total mass is strictly below
the initial reserve.
-/
def CanonicalReserveVariationStorage
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    (O : CollisionOpening B) : Prop :=
  Summable (fun n : ℕ => positivePart (canonicalReserveExcess O n)) ∧
  (∑' n : ℕ, positivePart (canonicalReserveExcess O n)) <
    gapReserve (O.gap 0)

/-- Canonical reserve variation is exactly canonical positive-excess storage. -/
theorem CANONICAL_RESERVE_VARIATION_TO_CANONICAL_EXCESS_STORAGE
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    {O : CollisionOpening B}
    (hVariation : CanonicalReserveVariationStorage O) :
    CanonicalPositiveExcessStorage
      (CANONICAL_RESERVE_EXCESS_CONSTRUCTS_EXACT_LEDGER O) := by
  simpa [CanonicalReserveVariationStorage, CanonicalPositiveExcessStorage,
    CANONICAL_RESERVE_EXCESS_CONSTRUCTS_EXACT_LEDGER] using hVariation

/-- The canonical variation bound alone gives a uniform positive reserve floor. -/
theorem CANONICAL_RESERVE_VARIATION_GIVES_RESERVE_FLOOR
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    (O : CollisionOpening B)
    (hVariation : CanonicalReserveVariationStorage O) :
    ∃ ε : ℝ, 0 < ε ∧ ∀ n : ℕ, ε ≤ gapReserve (O.gap n) := by
  let L : ExactGapExcessLedger O :=
    CANONICAL_RESERVE_EXCESS_CONSTRUCTS_EXACT_LEDGER O
  have hCanonical : CanonicalPositiveExcessStorage L := by
    exact CANONICAL_RESERVE_VARIATION_TO_CANONICAL_EXCESS_STORAGE hVariation
  obtain ⟨S⟩ := CANONICAL_POSITIVE_EXCESS_STORAGE_CONSTRUCTS_GLOBAL_STORAGE hCanonical
  obtain ⟨M⟩ := GLOBAL_STORAGE_CONSTRUCTS_CAPACITY_MAJORANT S
  have hPositive : PositiveExcessPrefixBudget L :=
    CAPACITY_MAJORANT_CONSTRUCTS_POSITIVE_EXCESS_PREFIX_BUDGET L M
  have hPaid : CumulativePaidExcessBudget L :=
    POSITIVE_EXCESS_PREFIX_BUDGET_CONSTRUCTS_PAID_BUDGET L hPositive
  exact CUMULATIVE_PAID_EXCESS_GIVES_UNIFORM_RESERVE_FLOOR L hPaid

/--
Pointwise native input after removing the separate field-gap increment witness:
only the canonical reserve positive-variation bound remains.
-/
def NativeCanonicalReserveVariationPackage
    (NontrivialZero : ℝ → ℝ → Prop)
    (HeatZero : ℝ → ℝ → ℝ → Prop) : Prop :=
  ∀ β γ : ℝ, (B : PointwiseHeatBranch HeatZero β γ) →
    NontrivialZero β γ →
    ∀ O : CollisionOpening B,
      CanonicalReserveVariationStorage O

/-- Canonical reserve variation constructs the old GP/BKQR reserve package. -/
theorem CANONICAL_RESERVE_VARIATION_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE
    {NontrivialZero : ℝ → ℝ → Prop}
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    (hVariation : NativeCanonicalReserveVariationPackage NontrivialZero HeatZero) :
    GPBKQRPointwiseReservePackage NontrivialZero HeatZero := by
  refine ⟨?_⟩
  intro β γ B hZero
  unfold GPBKQRUniformOpeningReserveMargin
  intro O
  exact CANONICAL_RESERVE_VARIATION_GIVES_RESERVE_FLOOR O
    (hVariation β γ B hZero O)

/-- Native pointwise RH from Xi analytics plus only canonical reserve variation. -/
theorem XI_PLUS_CANONICAL_RESERVE_VARIATION_IMPLIES_POINTWISE_RH
    {NontrivialZero : ℝ → ℝ → Prop}
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    {safeThreshold : ℝ}
    {EscapeEvent : ℝ → ℝ → Prop}
    (hXi : XiAnalyticPointwisePackage NontrivialZero HeatZero safeThreshold EscapeEvent)
    (hVariation : NativeCanonicalReserveVariationPackage NontrivialZero HeatZero) :
    RHPointwise NontrivialZero := by
  exact TWO_INTERFACE_POINTWISE_CLOSURE hXi
    (CANONICAL_RESERVE_VARIATION_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE hVariation)

/-- Native Mathlib RH from Xi analytics plus canonical reserve variation. -/
theorem ACTUAL_XI_PLUS_CANONICAL_RESERVE_VARIATION_IMPLIES_MATHLIB_RH
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    {safeThreshold : ℝ}
    {EscapeEvent : ℝ → ℝ → Prop}
    (hXi : XiAnalyticPointwisePackage
      ActualNontrivialZero HeatZero safeThreshold EscapeEvent)
    (hVariation : NativeCanonicalReserveVariationPackage
      ActualNontrivialZero HeatZero) :
    RiemannHypothesis := by
  apply ACTUAL_POINTWISE_CLOSURE_IMPLIES_MATHLIB_RH
  exact XI_PLUS_CANONICAL_RESERVE_VARIATION_IMPLIES_POINTWISE_RH hXi hVariation

#check canonicalReserveExcess
#check CANONICAL_RESERVE_EXCESS_CONSTRUCTS_EXACT_LEDGER
#check CANONICAL_RESERVE_VARIATION_TO_CANONICAL_EXCESS_STORAGE
#check CANONICAL_RESERVE_VARIATION_GIVES_RESERVE_FLOOR
#check CANONICAL_RESERVE_VARIATION_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE
#check XI_PLUS_CANONICAL_RESERVE_VARIATION_IMPLIES_POINTWISE_RH
#check ACTUAL_XI_PLUS_CANONICAL_RESERVE_VARIATION_IMPLIES_MATHLIB_RH

#print axioms CANONICAL_RESERVE_EXCESS_CONSTRUCTS_EXACT_LEDGER
#print axioms CANONICAL_RESERVE_VARIATION_TO_CANONICAL_EXCESS_STORAGE
#print axioms CANONICAL_RESERVE_VARIATION_GIVES_RESERVE_FLOOR
#print axioms CANONICAL_RESERVE_VARIATION_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE
#print axioms XI_PLUS_CANONICAL_RESERVE_VARIATION_IMPLIES_POINTWISE_RH
#print axioms ACTUAL_XI_PLUS_CANONICAL_RESERVE_VARIATION_IMPLIES_MATHLIB_RH


/-! ## Native nonrecyclable storage-potential reduction -/

/--
Finite telescoping identity for an arbitrary real storage sequence.
This is the theorem-level bookkeeping behind a nonrecyclable GP/BKQR store.
-/
theorem STORAGE_DROP_TELESCOPES
    (storage : ℕ → ℝ) (n : ℕ) :
    Finset.sum (Finset.range n) (fun k => storage k - storage (k + 1)) =
      storage 0 - storage n := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [Finset.sum_range_succ, ih]
      ring

/--
A concrete nonnegative storage potential that pays every positive canonical
reserve drain by an actual decrease of storage.  The initial store is strictly
smaller than the initial gap reserve.
-/
structure CanonicalReserveStoragePotential
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    (O : CollisionOpening B) where
  storage : ℕ → ℝ
  storageNonnegative : ∀ n : ℕ, 0 ≤ storage n
  initialStrict : storage 0 < gapReserve (O.gap 0)
  paysPositiveDrain : ∀ n : ℕ,
    positivePart (canonicalReserveExcess O n) ≤ storage n - storage (n + 1)

/-- Every positive-variation prefix is bounded by the corresponding storage drop. -/
theorem POSITIVE_RESERVE_VARIATION_PREFIX_LE_STORAGE_DROP
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    {O : CollisionOpening B}
    (S : CanonicalReserveStoragePotential O) (n : ℕ) :
    Finset.sum (Finset.range n)
        (fun k => positivePart (canonicalReserveExcess O k)) ≤
      S.storage 0 - S.storage n := by
  calc
    Finset.sum (Finset.range n)
        (fun k => positivePart (canonicalReserveExcess O k)) ≤
        Finset.sum (Finset.range n)
          (fun k => S.storage k - S.storage (k + 1)) := by
            exact Finset.sum_le_sum (fun k _hk => S.paysPositiveDrain k)
    _ = S.storage 0 - S.storage n := STORAGE_DROP_TELESCOPES S.storage n

/-- Nonnegativity of the remaining store bounds every positive prefix by the initial store. -/
theorem POSITIVE_RESERVE_VARIATION_PREFIX_LE_INITIAL_STORAGE
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    {O : CollisionOpening B}
    (S : CanonicalReserveStoragePotential O) (n : ℕ) :
    Finset.sum (Finset.range n)
        (fun k => positivePart (canonicalReserveExcess O k)) ≤
      S.storage 0 := by
  have hDrop := POSITIVE_RESERVE_VARIATION_PREFIX_LE_STORAGE_DROP S n
  have hNonneg := S.storageNonnegative n
  linarith

/--
A nonrecyclable storage potential constructs the strict positive-excess prefix
budget.  The slack is canonical: `gapReserve(a₀) - storage 0`.
-/
theorem STORAGE_POTENTIAL_CONSTRUCTS_POSITIVE_EXCESS_PREFIX_BUDGET
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    {O : CollisionOpening B}
    (S : CanonicalReserveStoragePotential O) :
    PositiveExcessPrefixBudget
      (CANONICAL_RESERVE_EXCESS_CONSTRUCTS_EXACT_LEDGER O) := by
  let ε : ℝ := gapReserve (O.gap 0) - S.storage 0
  have hε : 0 < ε := by
    dsimp [ε]
    linarith [S.initialStrict]
  refine ⟨ε, hε, ?_⟩
  intro n
  have hPrefix := POSITIVE_RESERVE_VARIATION_PREFIX_LE_INITIAL_STORAGE S n
  have hEq : gapReserve (O.gap 0) - ε = S.storage 0 := by
    dsimp [ε]
    ring
  simpa [CANONICAL_RESERVE_EXCESS_CONSTRUCTS_EXACT_LEDGER, hEq] using hPrefix

/-- The storage potential directly yields a uniform positive gap-reserve floor. -/
theorem STORAGE_POTENTIAL_GIVES_RESERVE_FLOOR
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    (O : CollisionOpening B)
    (S : CanonicalReserveStoragePotential O) :
    ∃ ε : ℝ, 0 < ε ∧ ∀ n : ℕ, ε ≤ gapReserve (O.gap n) := by
  let L : ExactGapExcessLedger O :=
    CANONICAL_RESERVE_EXCESS_CONSTRUCTS_EXACT_LEDGER O
  have hPositive : PositiveExcessPrefixBudget L := by
    exact STORAGE_POTENTIAL_CONSTRUCTS_POSITIVE_EXCESS_PREFIX_BUDGET S
  have hPaid : CumulativePaidExcessBudget L :=
    POSITIVE_EXCESS_PREFIX_BUDGET_CONSTRUCTS_PAID_BUDGET L hPositive
  exact CUMULATIVE_PAID_EXCESS_GIVES_UNIFORM_RESERVE_FLOOR L hPaid

/--
Pointwise GP/BKQR input after removing all infinite-series bookkeeping:
every covered collision opening carries a concrete nonrecyclable storage
potential.
-/
def NativeCanonicalReserveStoragePotentialPackage
    (NontrivialZero : ℝ → ℝ → Prop)
    (HeatZero : ℝ → ℝ → ℝ → Prop) : Prop :=
  ∀ β γ : ℝ, (B : PointwiseHeatBranch HeatZero β γ) →
    NontrivialZero β γ →
    ∀ O : CollisionOpening B,
      Nonempty (CanonicalReserveStoragePotential O)

/-- The local storage-potential package constructs the old GP/BKQR reserve package. -/
theorem STORAGE_POTENTIAL_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE
    {NontrivialZero : ℝ → ℝ → Prop}
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    (hStorage : NativeCanonicalReserveStoragePotentialPackage NontrivialZero HeatZero) :
    GPBKQRPointwiseReservePackage NontrivialZero HeatZero := by
  refine ⟨?_⟩
  intro β γ B hZero
  unfold GPBKQRUniformOpeningReserveMargin
  intro O
  obtain ⟨S⟩ := hStorage β γ B hZero O
  exact STORAGE_POTENTIAL_GIVES_RESERVE_FLOOR O S

/-- Native pointwise RH from Xi analytics plus a nonrecyclable reserve-storage potential. -/
theorem XI_PLUS_STORAGE_POTENTIAL_IMPLIES_POINTWISE_RH
    {NontrivialZero : ℝ → ℝ → Prop}
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    {safeThreshold : ℝ}
    {EscapeEvent : ℝ → ℝ → Prop}
    (hXi : XiAnalyticPointwisePackage NontrivialZero HeatZero safeThreshold EscapeEvent)
    (hStorage : NativeCanonicalReserveStoragePotentialPackage NontrivialZero HeatZero) :
    RHPointwise NontrivialZero := by
  exact TWO_INTERFACE_POINTWISE_CLOSURE hXi
    (STORAGE_POTENTIAL_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE hStorage)

/-- Native Mathlib RH theorem from Xi analytics plus the local storage-potential package. -/
theorem ACTUAL_XI_PLUS_STORAGE_POTENTIAL_IMPLIES_MATHLIB_RH
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    {safeThreshold : ℝ}
    {EscapeEvent : ℝ → ℝ → Prop}
    (hXi : XiAnalyticPointwisePackage
      ActualNontrivialZero HeatZero safeThreshold EscapeEvent)
    (hStorage : NativeCanonicalReserveStoragePotentialPackage
      ActualNontrivialZero HeatZero) :
    RiemannHypothesis := by
  apply ACTUAL_POINTWISE_CLOSURE_IMPLIES_MATHLIB_RH
  exact XI_PLUS_STORAGE_POTENTIAL_IMPLIES_POINTWISE_RH hXi hStorage

#check STORAGE_DROP_TELESCOPES
#check POSITIVE_RESERVE_VARIATION_PREFIX_LE_STORAGE_DROP
#check POSITIVE_RESERVE_VARIATION_PREFIX_LE_INITIAL_STORAGE
#check STORAGE_POTENTIAL_CONSTRUCTS_POSITIVE_EXCESS_PREFIX_BUDGET
#check STORAGE_POTENTIAL_GIVES_RESERVE_FLOOR
#check STORAGE_POTENTIAL_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE
#check XI_PLUS_STORAGE_POTENTIAL_IMPLIES_POINTWISE_RH
#check ACTUAL_XI_PLUS_STORAGE_POTENTIAL_IMPLIES_MATHLIB_RH

#print axioms STORAGE_DROP_TELESCOPES
#print axioms POSITIVE_RESERVE_VARIATION_PREFIX_LE_STORAGE_DROP
#print axioms POSITIVE_RESERVE_VARIATION_PREFIX_LE_INITIAL_STORAGE
#print axioms STORAGE_POTENTIAL_CONSTRUCTS_POSITIVE_EXCESS_PREFIX_BUDGET
#print axioms STORAGE_POTENTIAL_GIVES_RESERVE_FLOOR
#print axioms STORAGE_POTENTIAL_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE
#print axioms XI_PLUS_STORAGE_POTENTIAL_IMPLIES_POINTWISE_RH
#print axioms ACTUAL_XI_PLUS_STORAGE_POTENTIAL_IMPLIES_MATHLIB_RH

/-! ## Native one-step nonrecyclable storage law reduction -/

/--
The most local storage statement used by the reserve argument.  A positive
canonical reserve drain plus the next stored amount is paid by the current
stored amount.  No prefix sum, infinite sum, or pre-built storage-potential
inequality is assumed.
-/
structure LocalNonrecyclableStorageLaw
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    (O : CollisionOpening B) where
  storage : ℕ → ℝ
  storageNonnegative : ∀ n : ℕ, 0 ≤ storage n
  initialStrict : storage 0 < gapReserve (O.gap 0)
  oneStepPayment : ∀ n : ℕ,
    positivePart (canonicalReserveExcess O n) + storage (n + 1) ≤ storage n

/-- The local paid-or-stored law implies the storage-drop payment inequality. -/
theorem LOCAL_STORAGE_LAW_PAYS_POSITIVE_DRAIN
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    {O : CollisionOpening B}
    (L : LocalNonrecyclableStorageLaw O) (n : ℕ) :
    positivePart (canonicalReserveExcess O n) ≤
      L.storage n - L.storage (n + 1) := by
  linarith [L.oneStepPayment n]

/-- The local one-step law constructs the previously used storage potential. -/
theorem LOCAL_STORAGE_LAW_CONSTRUCTS_STORAGE_POTENTIAL
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    {O : CollisionOpening B}
    (L : LocalNonrecyclableStorageLaw O) :
    Nonempty (CanonicalReserveStoragePotential O) := by
  refine ⟨{
    storage := L.storage
    storageNonnegative := L.storageNonnegative
    initialStrict := L.initialStrict
    paysPositiveDrain := ?_
  }⟩
  intro n
  exact LOCAL_STORAGE_LAW_PAYS_POSITIVE_DRAIN L n

/-- The local one-step law alone gives the strict uniform reserve floor. -/
theorem LOCAL_STORAGE_LAW_GIVES_RESERVE_FLOOR
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    (O : CollisionOpening B)
    (L : LocalNonrecyclableStorageLaw O) :
    ∃ ε : ℝ, 0 < ε ∧ ∀ n : ℕ, ε ≤ gapReserve (O.gap n) := by
  obtain ⟨S⟩ := LOCAL_STORAGE_LAW_CONSTRUCTS_STORAGE_POTENTIAL L
  exact STORAGE_POTENTIAL_GIVES_RESERVE_FLOOR O S

/--
Pointwise GP/BKQR input after reducing the global storage-potential package to
a local one-step paid-or-stored law on each collision opening.
-/
def NativeLocalStorageLawPackage
    (NontrivialZero : ℝ → ℝ → Prop)
    (HeatZero : ℝ → ℝ → ℝ → Prop) : Prop :=
  ∀ β γ : ℝ, (B : PointwiseHeatBranch HeatZero β γ) →
    NontrivialZero β γ →
    ∀ O : CollisionOpening B,
      Nonempty (LocalNonrecyclableStorageLaw O)

/-- The local law package constructs the old storage-potential package. -/
theorem LOCAL_STORAGE_LAW_PACKAGE_CONSTRUCTS_STORAGE_POTENTIAL_PACKAGE
    {NontrivialZero : ℝ → ℝ → Prop}
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    (hLocal : NativeLocalStorageLawPackage NontrivialZero HeatZero) :
    NativeCanonicalReserveStoragePotentialPackage NontrivialZero HeatZero := by
  intro β γ B hZero O
  obtain ⟨L⟩ := hLocal β γ B hZero O
  exact LOCAL_STORAGE_LAW_CONSTRUCTS_STORAGE_POTENTIAL L

/-- The local paid-or-stored law therefore constructs the GP/BKQR reserve package. -/
theorem LOCAL_STORAGE_LAW_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE
    {NontrivialZero : ℝ → ℝ → Prop}
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    (hLocal : NativeLocalStorageLawPackage NontrivialZero HeatZero) :
    GPBKQRPointwiseReservePackage NontrivialZero HeatZero := by
  exact STORAGE_POTENTIAL_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE
    (LOCAL_STORAGE_LAW_PACKAGE_CONSTRUCTS_STORAGE_POTENTIAL_PACKAGE hLocal)

/-- Native pointwise RH from Xi analytics plus only the local one-step storage law. -/
theorem XI_PLUS_LOCAL_STORAGE_LAW_IMPLIES_POINTWISE_RH
    {NontrivialZero : ℝ → ℝ → Prop}
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    {safeThreshold : ℝ}
    {EscapeEvent : ℝ → ℝ → Prop}
    (hXi : XiAnalyticPointwisePackage NontrivialZero HeatZero safeThreshold EscapeEvent)
    (hLocal : NativeLocalStorageLawPackage NontrivialZero HeatZero) :
    RHPointwise NontrivialZero := by
  exact TWO_INTERFACE_POINTWISE_CLOSURE hXi
    (LOCAL_STORAGE_LAW_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE hLocal)

/-- Native Mathlib RH theorem from Xi analytics plus the local one-step storage law. -/
theorem ACTUAL_XI_PLUS_LOCAL_STORAGE_LAW_IMPLIES_MATHLIB_RH
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    {safeThreshold : ℝ}
    {EscapeEvent : ℝ → ℝ → Prop}
    (hXi : XiAnalyticPointwisePackage
      ActualNontrivialZero HeatZero safeThreshold EscapeEvent)
    (hLocal : NativeLocalStorageLawPackage
      ActualNontrivialZero HeatZero) :
    RiemannHypothesis := by
  apply ACTUAL_POINTWISE_CLOSURE_IMPLIES_MATHLIB_RH
  exact XI_PLUS_LOCAL_STORAGE_LAW_IMPLIES_POINTWISE_RH hXi hLocal

#check LOCAL_STORAGE_LAW_PAYS_POSITIVE_DRAIN
#check LOCAL_STORAGE_LAW_CONSTRUCTS_STORAGE_POTENTIAL
#check LOCAL_STORAGE_LAW_GIVES_RESERVE_FLOOR
#check LOCAL_STORAGE_LAW_PACKAGE_CONSTRUCTS_STORAGE_POTENTIAL_PACKAGE
#check LOCAL_STORAGE_LAW_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE
#check XI_PLUS_LOCAL_STORAGE_LAW_IMPLIES_POINTWISE_RH
#check ACTUAL_XI_PLUS_LOCAL_STORAGE_LAW_IMPLIES_MATHLIB_RH

#print axioms LOCAL_STORAGE_LAW_PAYS_POSITIVE_DRAIN
#print axioms LOCAL_STORAGE_LAW_CONSTRUCTS_STORAGE_POTENTIAL
#print axioms LOCAL_STORAGE_LAW_GIVES_RESERVE_FLOOR
#print axioms LOCAL_STORAGE_LAW_PACKAGE_CONSTRUCTS_STORAGE_POTENTIAL_PACKAGE
#print axioms LOCAL_STORAGE_LAW_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE
#print axioms XI_PLUS_LOCAL_STORAGE_LAW_IMPLIES_POINTWISE_RH
#print axioms ACTUAL_XI_PLUS_LOCAL_STORAGE_LAW_IMPLIES_MATHLIB_RH

/-! ## Native M7/BKQR one-step payment certificate reduction -/

/--
A local M7/BKQR payment certificate separates the two roles hidden inside the
one-step storage law:

* `reserveDrainPaid`: positive reserve drain is bounded by the paid action;
* `paymentDebitedFromStorage`: that same paid action is removed from the
  nonrecyclable store before the next step.

No global prefix, summability, or reserve-floor assumption occurs here.
-/
structure M7BKQROneStepPaymentCertificate
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    (O : CollisionOpening B) where
  storage : ℕ → ℝ
  payment : ℕ → ℝ
  storageNonnegative : ∀ n : ℕ, 0 ≤ storage n
  paymentNonnegative : ∀ n : ℕ, 0 ≤ payment n
  initialStrict : storage 0 < gapReserve (O.gap 0)
  reserveDrainPaid : ∀ n : ℕ,
    positivePart (canonicalReserveExcess O n) ≤ payment n
  paymentDebitedFromStorage : ∀ n : ℕ,
    payment n + storage (n + 1) ≤ storage n

/-- The M7 paid action and the nonrecyclable debit compose to the local storage law. -/
theorem M7_BKQR_PAYMENT_CERTIFICATE_PAYS_POSITIVE_DRAIN
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    {O : CollisionOpening B}
    (P : M7BKQROneStepPaymentCertificate O) (n : ℕ) :
    positivePart (canonicalReserveExcess O n) + P.storage (n + 1) ≤
      P.storage n := by
  linarith [P.reserveDrainPaid n, P.paymentDebitedFromStorage n]

/-- A local M7/BKQR payment certificate constructs the previous local storage law. -/
theorem M7_BKQR_PAYMENT_CERTIFICATE_CONSTRUCTS_LOCAL_STORAGE_LAW
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    {O : CollisionOpening B}
    (P : M7BKQROneStepPaymentCertificate O) :
    Nonempty (LocalNonrecyclableStorageLaw O) := by
  refine ⟨{
    storage := P.storage
    storageNonnegative := P.storageNonnegative
    initialStrict := P.initialStrict
    oneStepPayment := ?_
  }⟩
  intro n
  exact M7_BKQR_PAYMENT_CERTIFICATE_PAYS_POSITIVE_DRAIN P n

/-- The payment certificate already yields the strict reserve floor. -/
theorem M7_BKQR_PAYMENT_CERTIFICATE_GIVES_RESERVE_FLOOR
    {HeatZero : ℝ → ℝ → ℝ → Prop} {β γ : ℝ}
    {B : PointwiseHeatBranch HeatZero β γ}
    (O : CollisionOpening B)
    (P : M7BKQROneStepPaymentCertificate O) :
    ∃ ε : ℝ, 0 < ε ∧ ∀ n : ℕ, ε ≤ gapReserve (O.gap n) := by
  obtain ⟨L⟩ := M7_BKQR_PAYMENT_CERTIFICATE_CONSTRUCTS_LOCAL_STORAGE_LAW P
  exact LOCAL_STORAGE_LAW_GIVES_RESERVE_FLOOR O L

/--
Pointwise GP/BKQR input reduced to the local M7 payment certificate on every
putative collision opening.
-/
def NativeM7BKQROneStepPaymentPackage
    (NontrivialZero : ℝ → ℝ → Prop)
    (HeatZero : ℝ → ℝ → ℝ → Prop) : Prop :=
  ∀ β γ : ℝ, (B : PointwiseHeatBranch HeatZero β γ) →
    NontrivialZero β γ →
    ∀ O : CollisionOpening B,
      Nonempty (M7BKQROneStepPaymentCertificate O)

/-- The pointwise M7 payment package constructs the previous local-law package. -/
theorem M7_BKQR_PAYMENT_PACKAGE_CONSTRUCTS_LOCAL_STORAGE_LAW_PACKAGE
    {NontrivialZero : ℝ → ℝ → Prop}
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    (hM7 : NativeM7BKQROneStepPaymentPackage NontrivialZero HeatZero) :
    NativeLocalStorageLawPackage NontrivialZero HeatZero := by
  intro β γ B hZero O
  obtain ⟨P⟩ := hM7 β γ B hZero O
  exact M7_BKQR_PAYMENT_CERTIFICATE_CONSTRUCTS_LOCAL_STORAGE_LAW P

/-- The M7 payment package therefore constructs the GP/BKQR reserve package. -/
theorem M7_BKQR_PAYMENT_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE
    {NontrivialZero : ℝ → ℝ → Prop}
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    (hM7 : NativeM7BKQROneStepPaymentPackage NontrivialZero HeatZero) :
    GPBKQRPointwiseReservePackage NontrivialZero HeatZero := by
  exact LOCAL_STORAGE_LAW_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE
    (M7_BKQR_PAYMENT_PACKAGE_CONSTRUCTS_LOCAL_STORAGE_LAW_PACKAGE hM7)

/-- Native pointwise RH from Xi analytics plus the local M7/BKQR payment package. -/
theorem XI_PLUS_M7_BKQR_PAYMENT_IMPLIES_POINTWISE_RH
    {NontrivialZero : ℝ → ℝ → Prop}
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    {safeThreshold : ℝ}
    {EscapeEvent : ℝ → ℝ → Prop}
    (hXi : XiAnalyticPointwisePackage NontrivialZero HeatZero safeThreshold EscapeEvent)
    (hM7 : NativeM7BKQROneStepPaymentPackage NontrivialZero HeatZero) :
    RHPointwise NontrivialZero := by
  exact TWO_INTERFACE_POINTWISE_CLOSURE hXi
    (M7_BKQR_PAYMENT_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE hM7)

/-- Native Mathlib RH from Xi analytics plus the local M7/BKQR payment package. -/
theorem ACTUAL_XI_PLUS_M7_BKQR_PAYMENT_IMPLIES_MATHLIB_RH
    {HeatZero : ℝ → ℝ → ℝ → Prop}
    {safeThreshold : ℝ}
    {EscapeEvent : ℝ → ℝ → Prop}
    (hXi : XiAnalyticPointwisePackage
      ActualNontrivialZero HeatZero safeThreshold EscapeEvent)
    (hM7 : NativeM7BKQROneStepPaymentPackage
      ActualNontrivialZero HeatZero) :
    RiemannHypothesis := by
  apply ACTUAL_POINTWISE_CLOSURE_IMPLIES_MATHLIB_RH
  exact XI_PLUS_M7_BKQR_PAYMENT_IMPLIES_POINTWISE_RH hXi hM7

#check M7_BKQR_PAYMENT_CERTIFICATE_PAYS_POSITIVE_DRAIN
#check M7_BKQR_PAYMENT_CERTIFICATE_CONSTRUCTS_LOCAL_STORAGE_LAW
#check M7_BKQR_PAYMENT_CERTIFICATE_GIVES_RESERVE_FLOOR
#check M7_BKQR_PAYMENT_PACKAGE_CONSTRUCTS_LOCAL_STORAGE_LAW_PACKAGE
#check M7_BKQR_PAYMENT_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE
#check XI_PLUS_M7_BKQR_PAYMENT_IMPLIES_POINTWISE_RH
#check ACTUAL_XI_PLUS_M7_BKQR_PAYMENT_IMPLIES_MATHLIB_RH

#print axioms M7_BKQR_PAYMENT_CERTIFICATE_PAYS_POSITIVE_DRAIN
#print axioms M7_BKQR_PAYMENT_CERTIFICATE_CONSTRUCTS_LOCAL_STORAGE_LAW
#print axioms M7_BKQR_PAYMENT_CERTIFICATE_GIVES_RESERVE_FLOOR
#print axioms M7_BKQR_PAYMENT_PACKAGE_CONSTRUCTS_LOCAL_STORAGE_LAW_PACKAGE
#print axioms M7_BKQR_PAYMENT_PACKAGE_CONSTRUCTS_GP_BKQR_RESERVE_PACKAGE
#print axioms XI_PLUS_M7_BKQR_PAYMENT_IMPLIES_POINTWISE_RH
#print axioms ACTUAL_XI_PLUS_M7_BKQR_PAYMENT_IMPLIES_MATHLIB_RH

end
end RHGPNativeReserveReduction
