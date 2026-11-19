-- | Módulo Expr
-- Propósito: definir el tipo recursivo que representa expresiones aritméticas
-- y simbólicas, junto con sus instancias básicas.
module Expr (Expr(..), eval, evalCon) where
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

    -- | Evalúa una expresión cerrada (sin variables libres).
    --
    -- Devuelve 'Nothing' si aparece una variable no ligada o una división
    -- por cero. La división es entera y redondea hacia menos infinito
    -- (comportamiento de 'div').
    eval :: Expr -> Maybe Integer
    eval = evalCon []

    -- | Evalúa una expresión bajo un ambiente que asocia nombres de variable
    -- con valores enteros.
    --
    -- * Una variable se busca con 'lookup'; si no aparece, el resultado es
    --   'Nothing' (variable libre).
    -- * Si el ambiente repite un nombre, se usa la primera aparición.
    -- * 'Div' devuelve 'Nothing' cuando el divisor evalúa a cero; en otro
    --   caso usa 'div', que redondea hacia menos infinito (por ejemplo,
    --   @div (-7) 2 == -4@).
    -- * Si cualquier subexpresión falla, falla la expresión completa.
    evalCon :: [(String, Integer)] -> Expr -> Maybe Integer
    evalCon _   (Lit n)     = Just n
    evalCon env (Var x)     = lookup x env
    evalCon env (Suma a b)  = aplicar2 (+) (evalCon env a) (evalCon env b)
    evalCon env (Resta a b) = aplicar2 (-) (evalCon env a) (evalCon env b)
    evalCon env (Mult a b)  = aplicar2 (*) (evalCon env a) (evalCon env b)
    evalCon env (Div a b)   =
        case evalCon env b of
            Nothing -> Nothing
            Just 0  -> Nothing
            Just y  -> (`div` y) <$> evalCon env a

    -- | Aplica un operador binario a dos evaluaciones, propagando 'Nothing'.
    aplicar2 :: (Integer -> Integer -> Integer)
                -> Maybe Integer -> Maybe Integer -> Maybe Integer
    aplicar2 f (Just x) (Just y) = Just (f x y)
    aplicar2 _ _        _        = Nothing
