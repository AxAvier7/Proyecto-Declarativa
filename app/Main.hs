-- | Punto de entrada del evaluador de expresiones.
module Main (main) where

import Arbol (Arbol(Vacio), contiene, elems, insertar)
import Derivar (derivar)
import Expr (Expr(..), evalCon, variables)
import Pretty (pretty)
import Simplificar (simplificar)
import Text.Read (readMaybe)

-- | Ejemplo de demostración: nombre legible y expresión asociada.
data Ejemplo = Ejemplo
  { nombreEjemplo :: String
  , exprEjemplo   :: Expr
  }

-- | Casos listos para usar en el menú.
ejemplos :: [Ejemplo]
ejemplos =
  [ Ejemplo "constante" (Suma (Lit 2) (Lit 3))
  , Ejemplo "lineal" (Suma (Mult (Lit 2) (Var "x")) (Lit 1))
  , Ejemplo "cuadratica" (Mult (Var "x") (Var "x"))
  , Ejemplo "cociente" (Div (Lit 1) (Var "x"))
  , Ejemplo "dos variables" (Suma (Var "x") (Var "y"))
  , Ejemplo "division entera" (Div (Lit 7) (Lit 2))
  ]

-- | Árbol de ejemplo con cinco nodos.
arbolDemo :: Arbol Int
arbolDemo = foldr insertar Vacio [5, 3, 7, 1, 4]

-- | Muestra el listado y devuelve el ejemplo elegido, o 'Nothing' si la
-- entrada no es válida.
elegirEjemplo :: IO (Maybe Ejemplo)
elegirEjemplo = do
  putStrLn "Elige una expresion:"
  mapM_ mostrar (zip [1 :: Int ..] ejemplos)
  entrada <- getLine
  case readMaybe entrada :: Maybe Int of
    Nothing -> putStrLn "Opcion no valida." >> pure Nothing
    Just i ->
      case lookup i (zip [1 :: Int ..] ejemplos) of
        Just ej  -> pure (Just ej)
        Nothing  -> putStrLn "Indice fuera de rango." >> pure Nothing
  where
    mostrar (i, ej) =
      putStrLn
        ("  " ++ show i ++ ". " ++ nombreEjemplo ej ++ ": " ++ pretty (exprEjemplo ej))

-- | Lee un entero por teclado. Nunca usa 'read' directamente.
leerEntero :: String -> IO (Maybe Integer)
leerEntero mensaje = do
  putStr mensaje
  entrada <- getLine
  case readMaybe entrada :: Maybe Integer of
    Just n  -> pure (Just n)
    Nothing -> putStrLn "Valor no valido; se esperaba un entero." >> pure Nothing

-- | Construye el ambiente preguntando solo por las variables que aparecen
-- en la expresión. Si no hay variables, devuelve un ambiente vacío.
leerAmbiente :: Expr -> IO (Maybe [(String, Integer)])
leerAmbiente e = leerVariables (variables e)
  where
    leerVariables [] = pure (Just [])
    leerVariables (v:vs) = do
      mn <- leerEntero ("Valor de " ++ v ++ ": ")
      case mn of
        Nothing -> pure Nothing
        Just n  -> do
          resto <- leerVariables vs
          pure (fmap ((v, n) :) resto)

-- | Opción 1: evaluar el ejemplo con el ambiente leído.
casoEvaluar :: IO ()
casoEvaluar = do
  mEjemplo <- elegirEjemplo
  case mEjemplo of
    Nothing -> pure ()
    Just ej -> do
      mAmbiente <- leerAmbiente (exprEjemplo ej)
      case mAmbiente of
        Nothing -> pure ()
        Just env ->
          putStrLn
            ("Resultado: " ++ maybe "indefinido" show (evalCon env (exprEjemplo ej)))

-- | Opción 2: mostrar la expresión antes y después de simplificar.
casoSimplificar :: IO ()
casoSimplificar = do
  mEjemplo <- elegirEjemplo
  case mEjemplo of
    Nothing -> pure ()
    Just ej -> do
      putStrLn ("Antes: " ++ pretty (exprEjemplo ej))
      putStrLn ("Despues: " ++ pretty (simplificar (exprEjemplo ej)))

-- | Opción 3: derivar respecto de x.
casoDerivar :: IO ()
casoDerivar = do
  mEjemplo <- elegirEjemplo
  case mEjemplo of
    Nothing -> pure ()
    Just ej -> do
      putStrLn ("f(x) = " ++ pretty (exprEjemplo ej))
      putStrLn ("f'(x) = " ++ pretty (derivar "x" (exprEjemplo ej)))

-- | Opción 4: imprimir con pretty, sin usar el Show derivado de Expr.
casoImprimir :: IO ()
casoImprimir = do
  mEjemplo <- elegirEjemplo
  case mEjemplo of
    Nothing -> pure ()
    Just ej -> putStrLn (pretty (exprEjemplo ej))

-- | Opción 5: demo del árbol binario de búsqueda.
casoArbol :: IO ()
casoArbol = do
  putStrLn ("Arbol vacio: " ++ show (elems (Vacio :: Arbol Int)))
  putStrLn ("Arbol de 5 nodos: " ++ show (elems arbolDemo))
  putStrLn ("contiene 4: " ++ show (contiene 4 arbolDemo))
  putStrLn ("contiene 9: " ++ show (contiene 9 arbolDemo))

-- | Bucle principal. Vuelve al menú después de cada opción.
bucle :: IO ()
bucle = do
  putStrLn ""
  putStrLn "1. Evaluar"
  putStrLn "2. Simplificar"
  putStrLn "3. Derivar respecto a x"
  putStrLn "4. Imprimir con pretty"
  putStrLn "5. Demo del arbol"
  putStrLn "0. Salir"
  putStr "Opcion: "
  opcion <- getLine
  case opcion of
    "1" -> casoEvaluar >> bucle
    "2" -> casoSimplificar >> bucle
    "3" -> casoDerivar >> bucle
    "4" -> casoImprimir >> bucle
    "5" -> casoArbol >> bucle
    "0" -> putStrLn "Hasta luego."
    _   -> putStrLn "Opcion no valida." >> bucle

-- | Punto de entrada.
main :: IO ()
main = do
  putStrLn "Evaluador de expresiones"
  bucle