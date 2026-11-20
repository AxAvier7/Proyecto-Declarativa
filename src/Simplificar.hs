-- | Módulo Simplificar
-- Propósito: reducir expresiones aplicando identidades algebraicas.
module Simplificar (simplificar, contarNodos) where

import Expr (Expr(..))

-- | Simplifica una expresión recorriéndola de abajo hacia arriba.
--
-- Primero se simplifican los hijos y después se aplican las reglas al nodo.
-- Las reglas son:
--
-- * Plegado de constantes para 'Suma', 'Resta', 'Mult' y 'Div' cuando el
--   divisor no es cero.
-- * Identidades con 0 y 1: @0 + x@, @x + 0@, @x - 0@, @x * 1@, @1 * x@,
--   @x * 0@, @0 * x@, @x / 1@ y @0 / x@.
-- * Cancelaciones simbólicas: @x - x = 0@ y @x / x = 1@.
--
-- La regla @x / x = 1@ solo es válida si @x /= 0@; por eso no se aplica
-- cuando @x@ es el literal cero. Lo mismo sucede con @0 / x = 0@. Para
-- expresiones simbólicas se asume que la variable no es cero.
--
-- La función es idempotente, no aumenta el número de nodos y nunca evalúa
-- una división por cero: @Div e (Lit 0)@ se deja tal cual.
simplificar :: Expr -> Expr
simplificar (Lit n) = Lit n
simplificar (Var x) = Var x
simplificar (Suma a b) =
  let a' = simplificar a
      b' = simplificar b
  in case (a', b') of
       (Lit 0, y)     -> y
       (x, Lit 0)     -> x
       (Lit x, Lit y) -> Lit (x + y)
       (x, y)         -> Suma x y
simplificar (Resta a b) =
  let a' = simplificar a
      b' = simplificar b
  in case (a', b') of
       (x, Lit 0) -> x
       (x, y)
         | x == y -> Lit 0
       (Lit x, Lit y) -> Lit (x - y)
       (x, y)         -> Resta x y
simplificar (Mult a b) =
  let a' = simplificar a
      b' = simplificar b
  in case (a', b') of
       (Lit 0, _)     -> Lit 0
       (_, Lit 0)     -> Lit 0
       (Lit 1, y)     -> y
       (x, Lit 1)     -> x
       (Lit x, Lit y) -> Lit (x * y)
       (x, y)         -> Mult x y
simplificar (Div a b) =
  let a' = simplificar a
      b' = simplificar b
  in case (a', b') of
       (_, Lit 1) -> a'
       (x, y)
         | x == y && x /= Lit 0 -> Lit 1
       (Lit 0, y)
         | y /= Lit 0 -> Lit 0
       (Lit x, Lit y)
         | y /= 0 -> Lit (x `div` y)
       _ -> Div a' b'

-- | Cuenta el número de nodos (constructores) de una expresión.
--
-- Es útil para comprobar que 'simplificar' no aumenta el tamaño del árbol.
contarNodos :: Expr -> Int
contarNodos (Lit _) = 1
contarNodos (Var _) = 1
contarNodos (Suma a b) = 1 + contarNodos a + contarNodos b
contarNodos (Resta a b) = 1 + contarNodos a + contarNodos b
contarNodos (Mult a b) = 1 + contarNodos a + contarNodos b
contarNodos (Div a b) = 1 + contarNodos a + contarNodos b