-- | Módulo Derivar
-- Propósito: derivación simbólica respecto de una variable.
module Derivar (derivar) where

import Expr (Expr(..))
import Simplificar (simplificar)

-- | Derivada simbólica sin simplificar.
--
-- Aplica las reglas de derivación de forma estructural:
--
-- * La derivada de un literal es 0.
-- * La derivada de una variable es 1 si coincide con la variable de
--   derivación y 0 en otro caso.
-- * Suma y resta se derivan término a término.
-- * Producto: @(u * v)' = u' * v + u * v'@.
-- * Cociente: @(u / v)' = (u' * v - u * v') / (v * v)@.
--
-- No aplica 'simplificar'; para el resultado legible se usa 'derivar'.
deriv :: String -> Expr -> Expr
deriv _ (Lit _) = Lit 0
deriv v (Var y)
  | y == v = Lit 1
  | otherwise = Lit 0
deriv v (Suma a b) = Suma (deriv v a) (deriv v b)
deriv v (Resta a b) = Resta (deriv v a) (deriv v b)
deriv v (Mult a b) =
  Suma (Mult (deriv v a) b) (Mult a (deriv v b))
deriv v (Div a b) =
  Div (Resta (Mult (deriv v a) b) (Mult a (deriv v b)))
      (Mult b b)

-- | Derivada simbólica de una expresión respecto de una variable.
--
-- El resultado se simplifica con 'simplificar'. La convención de salida es
-- simbólica: no se combinan términos semejantes ni se factoriza. Por
-- ejemplo, @derivar "x" (Mult (Var "x") (Var "x"))@ produce
-- @Suma (Var "x") (Var "x")@, no @Mult (Lit 2) (Var "x")@.
--
-- La regla del cociente presupone que el denominador no se anula; si
-- @v = 0@, la expresión original no está definida. La derivación es
-- simbólica y no evalúa divisiones por cero.
derivar :: String -> Expr -> Expr
derivar v e = simplificar (deriv v e)