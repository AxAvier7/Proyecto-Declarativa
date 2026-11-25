-- | Suite de pruebas ejecutable con runghc o compilada con GHC.
module Main (main) where

import Arbol (Arbol(Vacio), contiene, elems, insertar)
import Derivar (derivar)
import Expr (Expr(..), eval, evalCon, variables)
import Pretty (pretty)
import Simplificar (contarNodos, simplificar)
import System.Exit (exitFailure)

-- | Ejecuta una aserción y devuelve su resultado.
verifica :: String -> Bool -> IO Bool
verifica nombre resultado = do
  putStrLn ((if resultado then "OK    " else "FALLO ") ++ nombre)
  pure resultado

-- | Árbol de cinco nodos usado en varias pruebas.
arbolDemo :: Arbol Int
arbolDemo = foldr insertar Vacio [5, 3, 7, 1, 4]

-- | Árbol de tres nodos usado en los criterios del issue #8.
arbolTres :: Arbol Int
arbolTres = insertar 3 (insertar 1 (insertar 2 Vacio))

-- | Expresión usada para comprobar idempotencia y tamaño.
expresionIdempotente :: Expr
expresionIdempotente = Suma (Lit 0) (Mult (Lit 1) (Var "x"))

-- | Expresión que se reduce mucho al simplificar.
expresionGrande :: Expr
expresionGrande = Suma (Lit 0) (Mult (Lit 1) (Suma (Lit 2) (Lit 3)))

-- | Derivada usada para comprobar estabilidad.
derivadaCuadratica :: Expr
derivadaCuadratica = derivar "x" (Mult (Var "x") (Var "x"))

-- | Pruebas de 'eval'.
grupoEval :: IO [Bool]
grupoEval = do
  putStrLn "\n== eval =="
  sequence
    [ verifica "eval (Lit 5) == Just 5"
        (eval (Lit 5) == Just 5)
    , verifica "eval (Suma (Lit 2) (Lit 3)) == Just 5"
        (eval (Suma (Lit 2) (Lit 3)) == Just 5)
    , verifica "eval (Resta (Lit 2) (Lit 3)) == Just (-1)"
        (eval (Resta (Lit 2) (Lit 3)) == Just (-1))
    , verifica "eval (Mult (Lit 4) (Lit 5)) == Just 20"
        (eval (Mult (Lit 4) (Lit 5)) == Just 20)
    , verifica "eval (Div (Lit 7) (Lit 2)) == Just 3"
        (eval (Div (Lit 7) (Lit 2)) == Just 3)
    , verifica "eval (Div (Lit (-7)) (Lit 2)) == Just (-4)"
        (eval (Div (Lit (-7)) (Lit 2)) == Just (-4))
    , verifica "eval (Div (Lit 1) (Lit 0)) == Nothing"
        (eval (Div (Lit 1) (Lit 0)) == Nothing)
    , verifica "eval (Var \"x\") == Nothing"
        (eval (Var "x") == Nothing)
    , verifica "eval (Suma (Lit 1) (Var \"x\")) == Nothing"
        (eval (Suma (Lit 1) (Var "x")) == Nothing)
    , verifica "eval (Suma (Lit 1) (Div (Lit 1) (Lit 0))) == Nothing"
        (eval (Suma (Lit 1) (Div (Lit 1) (Lit 0))) == Nothing)
    ]

-- | Pruebas de 'evalCon' y del ambiente.
grupoEvalCon :: IO [Bool]
grupoEvalCon = do
  putStrLn "\n== evalCon =="
  sequence
    [ verifica "evalCon [(\"x\",4)] (Var \"x\") == Just 4"
        (evalCon [("x", 4)] (Var "x") == Just 4)
    , verifica "evalCon [(\"x\",4)] (Var \"y\") == Nothing"
        (evalCon [("x", 4)] (Var "y") == Nothing)
    , verifica "evalCon [(\"x\",4)] (Mult (Var \"x\") (Lit 3)) == Just 12"
        (evalCon [("x", 4)] (Mult (Var "x") (Lit 3)) == Just 12)
    , verifica "evalCon [(\"x\",1),(\"x\",2)] (Var \"x\") == Just 1"
        (evalCon [("x", 1), ("x", 2)] (Var "x") == Just 1)
    , verifica "evalCon [] (Lit 9) == Just 9"
        (evalCon [] (Lit 9) == Just 9)
    , verifica "evalCon [(\"x\",0)] (Div (Lit 1) (Var \"x\")) == Nothing"
        (evalCon [("x", 0)] (Div (Lit 1) (Var "x")) == Nothing)
    , verifica "evalCon [(\"x\",2),(\"y\",3)] (Suma (Var \"x\") (Var \"y\")) == Just 5"
        (evalCon [("x", 2), ("y", 3)] (Suma (Var "x") (Var "y")) == Just 5)
    ]

-- | Pruebas de 'variables'.
grupoVariables :: IO [Bool]
grupoVariables = do
  putStrLn "\n== variables =="
  sequence
    [ verifica "variables (Lit 5) == []"
        (variables (Lit 5) == [])
    , verifica "variables (Var \"x\") == [\"x\"]"
        (variables (Var "x") == ["x"])
    , verifica "variables (Suma (Var \"x\") (Var \"y\")) == [\"x\",\"y\"]"
        (variables (Suma (Var "x") (Var "y")) == ["x", "y"])
    , verifica "variables (Mult (Var \"x\") (Var \"x\")) == [\"x\"]"
        (variables (Mult (Var "x") (Var "x")) == ["x"])
    , verifica "variables conserva el orden de primera aparición"
        (variables (Resta (Div (Var "z") (Var "x")) (Suma (Var "z") (Var "w"))) == ["z", "x", "w"])
    , verifica "variables elimina duplicados"
        (variables (Suma (Var "x") (Suma (Var "y") (Var "x"))) == ["x", "y"])
    ]

-- | Pruebas de 'pretty'.
grupoPretty :: IO [Bool]
grupoPretty = do
  putStrLn "\n== pretty =="
  sequence
    [ verifica "pretty (Suma (Lit 1) (Mult (Lit 2) (Lit 3))) == \"1 + 2 * 3\""
        (pretty (Suma (Lit 1) (Mult (Lit 2) (Lit 3))) == "1 + 2 * 3")
    , verifica "pretty (Mult (Suma (Lit 1) (Lit 2)) (Lit 3)) == \"(1 + 2) * 3\""
        (pretty (Mult (Suma (Lit 1) (Lit 2)) (Lit 3)) == "(1 + 2) * 3")
    , verifica "pretty (Resta (Lit 1) (Resta (Lit 2) (Lit 3))) == \"1 - (2 - 3)\""
        (pretty (Resta (Lit 1) (Resta (Lit 2) (Lit 3))) == "1 - (2 - 3)")
    , verifica "pretty (Div (Lit 1) (Mult (Var \"x\") (Var \"x\"))) == \"1 / (x * x)\""
        (pretty (Div (Lit 1) (Mult (Var "x") (Var "x"))) == "1 / (x * x)")
    , verifica "pretty (Mult (Lit (-2)) (Var \"x\")) == \"(-2) * x\""
        (pretty (Mult (Lit (-2)) (Var "x")) == "(-2) * x")
    , verifica "pretty (Resta (Var \"x\") (Suma (Var \"y\") (Var \"z\"))) == \"x - (y + z)\""
        (pretty (Resta (Var "x") (Suma (Var "y") (Var "z"))) == "x - (y + z)")
    ]

-- | Pruebas de 'simplificar' y 'contarNodos'.
grupoSimplificar :: IO [Bool]
grupoSimplificar = do
  putStrLn "\n== simplificar =="
  sequence
    [ verifica "simplificar (Suma (Lit 0) (Var \"x\")) == Var \"x\""
        (simplificar (Suma (Lit 0) (Var "x")) == Var "x")
    , verifica "simplificar (Suma (Var \"x\") (Lit 0)) == Var \"x\""
        (simplificar (Suma (Var "x") (Lit 0)) == Var "x")
    , verifica "simplificar (Resta (Var \"x\") (Lit 0)) == Var \"x\""
        (simplificar (Resta (Var "x") (Lit 0)) == Var "x")
    , verifica "simplificar (Resta (Var \"x\") (Var \"x\")) == Lit 0"
        (simplificar (Resta (Var "x") (Var "x")) == Lit 0)
    , verifica "simplificar (Mult (Lit 1) (Var \"x\")) == Var \"x\""
        (simplificar (Mult (Lit 1) (Var "x")) == Var "x")
    , verifica "simplificar (Mult (Var \"x\") (Lit 0)) == Lit 0"
        (simplificar (Mult (Var "x") (Lit 0)) == Lit 0)
    , verifica "simplificar (Suma (Lit 2) (Lit 3)) == Lit 5"
        (simplificar (Suma (Lit 2) (Lit 3)) == Lit 5)
    , verifica "simplificar (Mult (Lit 4) (Lit 5)) == Lit 20"
        (simplificar (Mult (Lit 4) (Lit 5)) == Lit 20)
    , verifica "simplificar (Div (Lit 7) (Lit 2)) == Lit 3"
        (simplificar (Div (Lit 7) (Lit 2)) == Lit 3)
    , verifica "simplificar (Div (Var \"x\") (Var \"x\")) == Lit 1"
        (simplificar (Div (Var "x") (Var "x")) == Lit 1)
    , verifica "simplificar (Div (Lit 1) (Lit 0)) deja la división"
        (simplificar (Div (Lit 1) (Lit 0)) == Div (Lit 1) (Lit 0))
    , verifica "simplificar (Div (Lit 0) (Var \"x\")) == Lit 0"
        (simplificar (Div (Lit 0) (Var "x")) == Lit 0)
    , verifica "simplificar (Div (Lit 0) (Lit 0)) deja la división"
        (simplificar (Div (Lit 0) (Lit 0)) == Div (Lit 0) (Lit 0))
    , verifica "simplificar (Mult (Suma (Lit 1) (Lit 2)) (Lit 3)) == Lit 9"
        (simplificar (Mult (Suma (Lit 1) (Lit 2)) (Lit 3)) == Lit 9)
    , verifica "simplificar es idempotente sobre expresionIdempotente"
        (simplificar (simplificar expresionIdempotente) == simplificar expresionIdempotente)
    , verifica "simplificar no aumenta el número de nodos"
        (contarNodos (simplificar expresionIdempotente) <= contarNodos expresionIdempotente)
    , verifica "simplificar reduce expresionGrande"
        (contarNodos (simplificar expresionGrande) < contarNodos expresionGrande)
    ]

-- | Pruebas de 'derivar'.
grupoDerivar :: IO [Bool]
grupoDerivar = do
  putStrLn "\n== derivar =="
  sequence
    [ verifica "derivar \"x\" (Lit 5) == Lit 0"
        (derivar "x" (Lit 5) == Lit 0)
    , verifica "derivar \"x\" (Var \"x\") == Lit 1"
        (derivar "x" (Var "x") == Lit 1)
    , verifica "derivar \"x\" (Var \"y\") == Lit 0"
        (derivar "x" (Var "y") == Lit 0)
    , verifica "derivar \"x\" (Suma (Var \"x\") (Lit 3)) == Lit 1"
        (derivar "x" (Suma (Var "x") (Lit 3)) == Lit 1)
    , verifica "derivar \"x\" (Mult (Var \"x\") (Var \"x\")) == Suma (Var \"x\") (Var \"x\")"
        (derivar "x" (Mult (Var "x") (Var "x")) == Suma (Var "x") (Var "x"))
    , verifica "derivar \"x\" (Div (Lit 1) (Var \"x\")) == Div (Lit (-1)) (Mult (Var \"x\") (Var \"x\"))"
        (derivar "x" (Div (Lit 1) (Var "x")) == Div (Lit (-1)) (Mult (Var "x") (Var "x")))
    , verifica "derivar \"x\" (Suma (Mult (Lit 2) (Var \"x\")) (Lit 5)) == Lit 2"
        (derivar "x" (Suma (Mult (Lit 2) (Var "x")) (Lit 5)) == Lit 2)
    , verifica "derivar \"x\" (Resta (Var \"x\") (Var \"x\")) == Lit 0"
        (derivar "x" (Resta (Var "x") (Var "x")) == Lit 0)
    , verifica "derivar \"x\" (Div (Var \"x\") (Var \"x\")) == Lit 0"
        (derivar "x" (Div (Var "x") (Var "x")) == Lit 0)
    , verifica "derivar \"y\" (Mult (Var \"x\") (Var \"x\")) == Lit 0"
        (derivar "y" (Mult (Var "x") (Var "x")) == Lit 0)
    , verifica "derivar \"x\" (Suma (Var \"x\") (Var \"y\")) == Lit 1"
        (derivar "x" (Suma (Var "x") (Var "y")) == Lit 1)
    , verifica "derivar \"x\" (Mult (Lit 3) (Var \"x\")) == Lit 3"
        (derivar "x" (Mult (Lit 3) (Var "x")) == Lit 3)
    , verifica "derivar \"x\" (Div (Lit 1) (Lit 2)) == Lit 0"
        (derivar "x" (Div (Lit 1) (Lit 2)) == Lit 0)
    , verifica "derivar es estable bajo simplificar"
        (simplificar derivadaCuadratica == derivadaCuadratica)
    ]

-- | Pruebas de 'Arbol'.
grupoArbol :: IO [Bool]
grupoArbol = do
  putStrLn "\n== Arbol =="
  sequence
    [ verifica "elems (Vacio :: Arbol Int) == []"
        (elems (Vacio :: Arbol Int) == [])
    , verifica "contiene 1 (Vacio :: Arbol Int) == False"
        (contiene 1 (Vacio :: Arbol Int) == False)
    , verifica "elems arbolTres == [1,2,3]"
        (elems arbolTres == [1, 2, 3])
    , verifica "contiene 2 arbolTres == True"
        (contiene 2 arbolTres == True)
    , verifica "contiene 4 arbolTres == False"
        (contiene 4 arbolTres == False)
    , verifica "los duplicados no se insertan dos veces"
        (elems (insertar 2 (insertar 2 (Vacio :: Arbol Int))) == [2])
    , verifica "elems arbolDemo == [1,3,4,5,7]"
        (elems arbolDemo == [1, 3, 4, 5, 7])
    , verifica "contiene 4 arbolDemo == True"
        (contiene 4 arbolDemo == True)
    , verifica "contiene 9 arbolDemo == False"
        (contiene 9 arbolDemo == False)
    , verifica "inserción ascendente mantiene el orden"
        (elems (foldr insertar Vacio [1, 2, 3, 4, 5 :: Int]) == [1, 2, 3, 4, 5])
    , verifica "inserción descendente mantiene el orden"
        (elems (foldr insertar Vacio [5, 4, 3, 2, 1 :: Int]) == [1, 2, 3, 4, 5])
    , verifica "duplicados en una lista no se repiten"
        (elems (foldr insertar Vacio [3, 1, 3, 2, 1 :: Int]) == [1, 2, 3])
    , verifica "el árbol funciona con String"
        (elems (foldr insertar Vacio ["b", "a", "c"]) == ["a", "b", "c"])
    , verifica "insertar 3 dos veces produce el mismo árbol"
        (insertar 3 (insertar 3 (Vacio :: Arbol Int)) == (insertar 3 Vacio :: Arbol Int))
    , verifica "un solo nodo produce una lista unitaria"
        (elems (insertar 5 (Vacio :: Arbol Int)) == [5])
    ]

-- | Punto de entrada de la suite.
main :: IO ()
main = do
  putStrLn "Suite de pruebas del proyecto"
  grupos <- sequence
    [ grupoEval
    , grupoEvalCon
    , grupoVariables
    , grupoPretty
    , grupoSimplificar
    , grupoDerivar
    , grupoArbol
    ]
  let resultados = concat grupos
      total = length resultados
      aprobadas = length (filter id resultados)
      fallidas = total - aprobadas
  putStrLn ""
  putStrLn ("Total: " ++ show total)
  putStrLn ("OK: " ++ show aprobadas)
  putStrLn ("Fallos: " ++ show fallidas)
  if fallidas == 0
    then putStrLn "Resultado: todas las pruebas pasaron."
    else do
      putStrLn "Resultado: hay pruebas fallidas."
      exitFailure