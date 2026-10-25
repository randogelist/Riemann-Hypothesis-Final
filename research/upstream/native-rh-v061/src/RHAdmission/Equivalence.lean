import RHAdmission.PositiveMetric

/-!
# Main native equivalence

BOTH directions are proved using the literal Mathlib proposition
`_root_.RiemannHypothesis`.  No `sorry`, fresh axiom, or imported unproved
"native calibration" assumption appears in these theorem declarations.

IMPORTANT SCOPE: the positive metric is for the explicit algebraic
Cayley-numerator channel `channelStep`, not yet the Mellin Hilbert-space
operator of the analytic research program.
-/

namespace RHAdmission

/-- Native RH constructs one common positive diagonal metric immediately. -/
theorem native_RH_implies_admission
    (hRH : _root_.RiemannHypothesis) : HypotheticalAdmission := by
  let H : PositiveDiagonalMetric :=
    { plus := 1, minus := 1, plus_pos := by norm_num,
      minus_pos := by norm_num }
  refine ⟨H, ?_⟩
  intro s hs
  exact critical_implies_metric_passivity H s
    (hRH s hs.1 hs.2.1 hs.2.2)

/-- The hypothetical positive metric cannot coexist with an off-line
    actual nontrivial Riemann-zeta zero. -/
theorem admission_implies_native_RH
    (hAdmission : HypotheticalAdmission) : _root_.RiemannHypothesis := by
  obtain ⟨H, hpass⟩ := hAdmission
  intro s hz htriv hne
  exact metric_passivity_forces_critical H s
    (hpass s ⟨hz, htriv, hne⟩)

/-- MAIN DELIVERABLE: hypothetical admission IF AND ONLY IF actual RH. -/
theorem HYPOTHETICAL_ADMISSION_IFF_RH :
    HypotheticalAdmission ↔ _root_.RiemannHypothesis :=
  ⟨admission_implies_native_RH, native_RH_implies_admission⟩

/-- The equivalent reverse orientation. -/
theorem RH_IFF_HYPOTHETICAL_ADMISSION :
    _root_.RiemannHypothesis ↔ HypotheticalAdmission :=
  HYPOTHETICAL_ADMISSION_IFF_RH.symm

end RHAdmission
