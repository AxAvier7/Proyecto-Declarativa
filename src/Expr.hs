-- | Módulo Expr
-- Propósito: definir el tipo recursivo que representa expresiones aritméticas
-- y simbólicas, junto con sus instancias básicas.
module Expr (Expr(..)) where
    data Expr 
        = Lit Integer       
        -- ^ Literal entero
        | Var String
        -- ^ Variable simbolica
        | Suma Expr Expr    
        -- ^ Suma de dos subexpresiones
        | Resta Expr Expr   
        -- ^ Resta de dos subexpresiones
        | Mult Expr Expr    
        -- ^ Multiplicacion de dos subexpresiones
        | Div Expr Expr
        -- ^ Division entera de dos subexpresiones
        deriving(Show, Eq)
