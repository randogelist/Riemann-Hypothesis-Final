import AWPI.PhiRH.MathlibBridge

namespace AWPI.PhiRH.DyadicScale

open AWPI.PhiRH
open AWPI.PhiRH.MathlibBridge

universe v
variable {Jet : Type v}

/-- Literal dyadic scale: 2^a, represented through the real exponential.
    This is the concrete scale used by the gain laws. -/
noncomputable def dyadicScale (a : ℝ) : ℝ :=
  Real.exp (a * Real.log 2)

/-- PHIRH242 is now a theorem about the literal dyadic scale. -/
theorem dyadicScale_at_zero : dyadicScale 0 = 1 := by
  simp [dyadicScale]

/-- PHIRH243 is now a theorem about the literal dyadic scale. -/
theorem dyadicScale_strictMono : StrictMono dyadicScale := by
  intro a b hab
  unfold dyadicScale
  apply Real.exp_lt_exp.mpr
  have hlog : 0 < Real.log (2 : ℝ) := Real.log_pos (by norm_num)
  exact mul_lt_mul_of_pos_right hab hlog

/-- Literal model with both Mathlib zeta semantics and the dyadic scale fixed
    definitionally.  Six model components remain explicit. -/
noncomputable def dyadicModel
    (state : ℂ → Jet)
    (energyPlus : Jet → ℝ)
    (energyMinus : Jet → ℝ)
    (plusTailSource : ℕ → ℂ → ℝ)
    (minusTailSource : ℕ → ℂ → ℝ)
    (sourceFormula : Prop) : Model ℂ Jet :=
  literalModel state energyPlus energyMinus dyadicScale
    plusTailSource minusTailSource sourceFormula

/-- The former `Scale2Facts` premise is discharged by the literal dyadic scale. -/
theorem dyadicScaleFacts
    (state : ℂ → Jet)
    (energyPlus energyMinus : Jet → ℝ)
    (plusTailSource minusTailSource : ℕ → ℂ → ℝ)
    (sourceFormula : Prop) :
    Scale2Facts
      (dyadicModel state energyPlus energyMinus
        plusTailSource minusTailSource sourceFormula) := by
  constructor
  · exact dyadicScale_at_zero
  · exact dyadicScale_strictMono

/-- The model RH predicate for the dyadic literal model is exactly Mathlib RH,
    with neither semantic-binding nor scale premises. -/
theorem dyadicModelRH_iff_mathlibRiemannHypothesis
    (state : ℂ → Jet)
    (energyPlus energyMinus : Jet → ℝ)
    (plusTailSource minusTailSource : ℕ → ℂ → ℝ)
    (sourceFormula : Prop) :
    (dyadicModel state energyPlus energyMinus
      plusTailSource minusTailSource sourceFormula).RH ↔ RiemannHypothesis := by
  exact literalModelRH_iff_mathlibRiemannHypothesis
    state energyPlus energyMinus dyadicScale
    plusTailSource minusTailSource sourceFormula

/-- v0.1.8 forward endpoint.  `scale2` and `Scale2Facts` have disappeared from
    the theorem signature.  The remaining load-bearing premises are the six
    explicit analytic/model components, PHIRH233, and the constructor. -/
theorem PHIRH286_DYADIC_SCALE_C_IMPLIES_MATHLIB_RIEMANN_HYPOTHESIS
    (state : ℂ → Jet)
    (energyPlus energyMinus : Jet → ℝ)
    (plusTailSource minusTailSource : ℕ → ℂ → ℝ)
    (sourceFormula : Prop)
    (v23 : NormalizedDyadicMultiplierFacts
      (dyadicModel state energyPlus energyMinus
        plusTailSource minusTailSource sourceFormula))
    (hC : Constructor
      (dyadicModel state energyPlus energyMinus
        plusTailSource minusTailSource sourceFormula)) :
    RiemannHypothesis := by
  exact PHIRH286_LITERAL_MODEL_C_IMPLIES_MATHLIB_RIEMANN_HYPOTHESIS
    state energyPlus energyMinus dyadicScale
    plusTailSource minusTailSource sourceFormula
    v23
    (dyadicScaleFacts state energyPlus energyMinus
      plusTailSource minusTailSource sourceFormula)
    hC

/-- v0.1.8 reverse/equivalence endpoint.  The scale facts are now internal
    theorems rather than external hypotheses. -/
theorem dyadicConstructorIffMathlibRiemannHypothesisUnderBackground
    (state : ℂ → Jet)
    (energyPlus energyMinus : Jet → ℝ)
    (plusTailSource minusTailSource : ℕ → ℂ → ℝ)
    (sourceFormula : Prop)
    (v23 : NormalizedDyadicMultiplierFacts
      (dyadicModel state energyPlus energyMinus
        plusTailSource minusTailSource sourceFormula))
    (hB : Background
      (dyadicModel state energyPlus energyMinus
        plusTailSource minusTailSource sourceFormula)) :
    Constructor
      (dyadicModel state energyPlus energyMinus
        plusTailSource minusTailSource sourceFormula) ↔ RiemannHypothesis := by
  exact literalConstructorIffMathlibRiemannHypothesisUnderBackground
    state energyPlus energyMinus dyadicScale
    plusTailSource minusTailSource sourceFormula
    v23
    (dyadicScaleFacts state energyPlus energyMinus
      plusTailSource minusTailSource sourceFormula)
    hB

end AWPI.PhiRH.DyadicScale
