-- | Módulo Pretty
-- Propósito: imprimir expresiones de forma legible, con los paréntesis
-- mínimos necesarios según la precedencia y la asociatividad.
module Pretty (pretty, prettyPrec) where

import Expr (Expr(..))

-- | Precedencia de cada constructor de 'Expr'.
--
-- Los átomos tienen la precedencia máxima (8). La suma y la resta comparten
-- la precedencia 6; la multiplicación y la división comparten la 7.
precedencia :: Expr -> Int
precedencia (Lit _)     = 8
precedencia (Var _)     = 8
precedencia (Suma _ _)  = 6
precedencia (Resta _ _) = 6
precedencia (Mult _ _)  = 7
precedencia (Div _ _)   = 7

-- | Convierte una expresión en una cadena legible.
--
-- Los operadores se separan con espacios y solo se añaden los paréntesis
-- necesarios para respetar la precedencia y la asociatividad.
pretty :: Expr -> String
pretty = prettyPrec 0

-- | Imprime una expresión en un contexto de precedencia dado.
--
-- El primer argumento es la precedencia mínima que debe tener la expresión
-- para imprimirse sin paréntesis. Si la precedencia del nodo es menor que
-- el contexto, se envuelve entre paréntesis.
--
-- La asociatividad es a la izquierda: el hijo izquierdo se imprime con la
-- precedencia del operador y el hijo derecho con una unidad más, salvo en
-- 'Suma' y 'Mult', donde la misma precedencia no necesita paréntesis.
--
-- Los literales negativos se imprimen entre paréntesis cuando aparecen
-- dentro de otra operación (contexto mayor que 0), por ejemplo @2 * (-3)@.
prettyPrec :: Int -> Expr -> String
prettyPrec ctx e
  | precedencia e < ctx = "(" ++ prettyPrec 0 e ++ ")"
  | otherwise = case e of
      Lit n     -> if n < 0 && ctx > 0 then "(" ++ show n ++ ")" else show n
      Var x     -> x
      Suma a b  -> prettyPrec 6 a ++ " + " ++ prettyPrec 6 b
      Resta a b -> prettyPrec 6 a ++ " - " ++ prettyPrec 7 b
      Mult a b  -> prettyPrec 7 a ++ " * " ++ prettyPrec 7 b
      Div a b   -> prettyPrec 7 a ++ " / " ++ prettyPrec 8 b