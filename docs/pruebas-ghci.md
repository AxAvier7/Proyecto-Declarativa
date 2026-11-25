# Guion de pruebas en GHCi

Sesión real de GHCi para comprobar las funciones del proyecto sin construir un
ejecutable.

## Requisitos

- GHC/GHCi 9.10.3.
- Ejecutar desde la raíz del repositorio.
- Sin librerías externas.

## Carga de módulos

```text
$ ghci -isrc
GHCi, version 9.10.3: https://www.haskell.org/ghc/  :? for help
ghci> :load src/Expr.hs src/Pretty.hs src/Simplificar.hs src/Derivar.hs src/Arbol.hs
Ok, five modules loaded.
ghci> :module + Expr Pretty Simplificar Derivar Arbol
ghci>
```

> Si ejecutas `:module` sin argumentos, GHCi reinicia el contexto interactivo.
> Vuelve a ejecutar `:module + Expr Pretty Simplificar Derivar Arbol`.

## Tipos principales

```text
ghci> :type eval
eval :: Expr -> Maybe Integer
ghci> :type evalCon
evalCon :: [(String, Integer)] -> Expr -> Maybe Integer
ghci> :type pretty
pretty :: Expr -> String
ghci> :type simplificar
simplificar :: Expr -> Expr
ghci> :type derivar
derivar :: String -> Expr -> Expr
ghci> :type insertar
insertar :: Ord a => a -> Arbol a -> Arbol a
ghci> :type contiene
contiene :: Ord a => a -> Arbol a -> Bool
ghci> :type elems
elems :: Arbol a -> [a]
ghci> :type variables
variables :: Expr -> [String]
```

## Evaluación

```text
ghci> eval (Suma (Lit 2) (Lit 3))
Just 5
ghci> evalCon [("x", 4)] (Mult (Var "x") (Lit 3))
Just 12
ghci> eval (Div (Lit 1) (Lit 0))
Nothing
ghci> eval (Var "x")
Nothing
```

## Impresión legible

```text
ghci> pretty (Suma (Lit 1) (Mult (Lit 2) (Lit 3)))
"1 + 2 * 3"
ghci> pretty (Mult (Suma (Lit 1) (Lit 2)) (Lit 3))
"(1 + 2) * 3"
ghci> pretty (Resta (Lit 1) (Resta (Lit 2) (Lit 3)))
"1 - (2 - 3)"
```

## Simplificación

```text
ghci> simplificar (Suma (Lit 0) (Mult (Lit 1) (Var "x")))
Var "x"
ghci> simplificar (Resta (Var "x") (Var "x"))
Lit 0
ghci> simplificar (Div (Lit 1) (Lit 0))
Div (Lit 1) (Lit 0)
```

## Derivación

```text
ghci> pretty (derivar "x" (Mult (Var "x") (Var "x")))
"x + x"
ghci> pretty (derivar "x" (Div (Lit 1) (Var "x")))
"(-1) / (x * x)"
ghci> pretty (derivar "x" (Suma (Mult (Lit 2) (Var "x")) (Lit 5)))
"2"
```

## Árbol binario de búsqueda

```text
ghci> let a = foldr insertar Vacio [5, 3, 7, 1, 4 :: Int]
ghci> elems a
[1,3,4,5,7]
ghci> contiene 4 a
True
ghci> contiene 9 a
False
ghci> elems (insertar 2 (insertar 2 (Vacio :: Arbol Int)))
[2]
ghci> elems (Vacio :: Arbol Int)
[]
```

## Variables de una expresión

```text
ghci> variables (Suma (Var "y") (Mult (Var "x") (Var "y")))
["y","x"]
```

## Ejecutar la suite

```powershell
ghc --make tests/Pruebas.hs -isrc -o pruebas.exe
.\pruebas.exe
```

Salida esperada al final:

```text
Total: 75
OK: 75
Fallos: 0
Resultado: todas las pruebas pasaron.
```

Con `runghc`:

```powershell
runghc -isrc tests/Pruebas.hs
```