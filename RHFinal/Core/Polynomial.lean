import Std

/-!
Finite integer polynomials used by the local SOLOBOLO certificate search.
Coefficients are in ascending order. Equality is literal coefficient equality;
trailing zeroes are not discarded, so the checker may reject equivalent inputs.
-/

namespace RHFinal.Polynomial

abbrev Poly := List Int

def add : Poly → Poly → Poly
  | [], q => q
  | p, [] => p
  | a :: p, b :: q => (a + b) :: add p q

def scale (a : Int) (p : Poly) : Poly := p.map (fun b => a * b)

def mul : Poly → Poly → Poly
  | [], _ => []
  | a :: p, q => add (scale a q) (0 :: mul p q)

def eval : Poly → Int → Int
  | [], _ => 0
  | a :: p, x => a + x * eval p x

theorem eval_add (p q : Poly) (x : Int) :
    eval (add p q) x = eval p x + eval q x := by
  induction p generalizing q with
  | nil => simp [add, eval]
  | cons a p ih =>
      cases q with
      | nil => simp [add, eval]
      | cons b q =>
          simp only [add, eval, ih, Int.mul_add]
          omega

theorem eval_scale (a : Int) (p : Poly) (x : Int) :
    eval (scale a p) x = a * eval p x := by
  induction p with
  | nil => simp [scale, eval]
  | cons b p ih =>
      simp only [scale, List.map, eval] at *
      rw [ih]
      rw [← Int.mul_assoc x a (eval p x), Int.mul_comm x a,
        Int.mul_assoc a x (eval p x), ← Int.mul_add a b (x * eval p x)]

theorem eval_mul (p q : Poly) (x : Int) :
    eval (mul p q) x = eval p x * eval q x := by
  induction p with
  | nil => simp [mul, eval]
  | cons a p ih =>
      rw [mul, eval_add, eval_scale]
      simp only [eval, Int.zero_add]
      rw [ih]
      rw [← Int.mul_assoc x (eval p x) (eval q x),
        ← Int.add_mul a (x * eval p x) (eval q x)]

def sumSquares : List Poly → Poly
  | [] => []
  | p :: ps => add (mul p p) (sumSquares ps)

def squareValues : List Poly → Int → Int
  | [], _ => 0
  | p :: ps, x => eval p x * eval p x + squareValues ps x

theorem eval_sumSquares (ps : List Poly) (x : Int) :
    eval (sumSquares ps) x = squareValues ps x := by
  induction ps with
  | nil => rfl
  | cons p ps ih =>
      simp only [sumSquares, squareValues, eval_add, eval_mul, ih]

end RHFinal.Polynomial
