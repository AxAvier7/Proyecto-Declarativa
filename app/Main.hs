-- | Punto de entrada del evaluador de expresiones.
module Main (main) where

import Expr ()
import Simplificar ()
import Derivar ()
import Arbol ()
import Pretty ()

main :: IO ()
main = putStrLn "Evaluador de expresiones: esqueleto inicial"
