import FiniteWitness.NativeXi

/-!
# GP / odd-zeta rational moment algebra

These are the exact rational moments used in the GP polynomial-measure
construction. Their positivity as actual Lebesgue integrals and any
ZETA_HYPERBOLIC/xi calibration are separate analytic bridges.
-/

namespace WitnessSolobolo

/-- Rational GP moment for integer weight Y. -/
def gpMoment (Y k : ℕ) : ℚ :=
  4 / (((k + 1 : ℕ) : ℚ) ^ Y)

/-- Hankel Gram-data matrix, without any claimed actual-xi calibration. -/
def gpHankel (Y d : ℕ) : Matrix (Fin d) (Fin d) ℚ :=
  fun i j => gpMoment Y (i.val + j.val)

/-- Shifted Hankel data underlying the GP positive-pencil template. -/
def gpShiftedHankel (Y d : ℕ) : Matrix (Fin d) (Fin d) ℚ :=
  fun i j => gpMoment Y (i.val + j.val + 1)

/-- Exact symmetry of the constructed rational Hankel data. -/
theorem gpHankel_symm (Y d : ℕ) (i j : Fin d) :
    gpHankel Y d i j = gpHankel Y d j i := by
  simp only [gpHankel, gpMoment, Nat.add_comm]

/-- The shifted pencil is also symmetric by construction. -/
theorem gpShiftedHankel_symm (Y d : ℕ) (i j : Fin d) :
    gpShiftedHankel Y d i j = gpShiftedHankel Y d j i := by
  simp only [gpShiftedHankel, gpMoment, Nat.add_comm]

end WitnessSolobolo
