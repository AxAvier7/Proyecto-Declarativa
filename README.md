# Evaluador de expresiones y árboles con tipos recursivos en Haskell

Proyecto final de **Programación Declarativa**: una pequeña biblioteca de expresiones aritméticas y simbólicas construida sobre el tipo recursivo `Expr`, con un ejecutable de demostración y un árbol binario de búsqueda (`Arbol`). Incluye evaluación con y sin ambiente, impresión legible, simplificación, derivación simbólica y una suite de 75 aserciones. Todo el código está escrito en Haskell puro, sin librerías externas.

## Requisitos

- **GHC y GHCi 9.10.3** (instalados con GHCup). La versión usada en las pruebas documentadas es 9.10.3; verifícala con `ghc --version`.
- **`runghc`**, incluido en la instalación de GHC, para ejecutar la suite sin generar un ejecutable.
- **Sin librerías externas**: solo módulos de `base` (`Data.List`, `Text.Read`, `System.Exit`). No hay `cabal`, `stack` ni dependencias que instalar.
- **PowerShell** en Windows para los comandos de esta guía. En Linux/macOS, sustituye `.\programa.exe` por `./programa`.
- Opcional: GitHub CLI (`gh`) para consultar los issues; no hace falta para compilar ni para ejecutar.

## Estructura del repositorio

```text
Proyecto-Declarativa/
├── README.md               Esta guía
├── app/
│   └── Main.hs             Menú interactivo de demostración
├── src/
│   ├── Expr.hs             Tipo recursivo Expr, eval, evalCon, variables
│   ├── Pretty.hs           Impresión legible con paréntesis mínimos
│   ├── Simplificar.hs      Simplificación y contador de nodos
│   ├── Derivar.hs          Derivación simbólica
│   └── Arbol.hs            Árbol binario de búsqueda polimórfico
├── tests/
│   └── Pruebas.hs          Suite de 75 aserciones ejecutable con GHC/runghc
├── docs/
│   └── pruebas-ghci.md     Sesión real de GHCi con tipos y ejemplos
└── .gitignore              Excluye .hi, .o, .exe y extras/
```

Archivos locales opcionales que pueden aparecer en una copia de trabajo, pero **no** en un clon limpio: `.ghci` (añade `-isrc` al arrancar GHCi) y `hie.yaml` (configuración equivalente para HLS). Esta guía no depende de ellos: todos los comandos pasan el flag `-isrc` explícitamente.

| Ruta | Responsabilidad |
|---|---|
| `app/Main.hs` | Imprime el menú, lee enteros con `readMaybe`, construye el ambiente solo con las variables presentes y muestra los cinco casos de demo. |
| `src/Expr.hs` | Define `Expr` (`Lit`, `Var`, `Suma`, `Resta`, `Mult`, `Div`), `eval`, `evalCon` y `variables`. |
| `src/Pretty.hs` | `pretty` y `prettyPrec`: convierten `Expr` en texto respetando precedencia y asociatividad. |
| `src/Simplificar.hs` | `simplificar` aplica identidades y plegado de constantes; `contarNodos` cuenta constructores. |
| `src/Derivar.hs` | `derivar` calcula la derivada y la simplifica; `deriv` es el helper privado sin simplificar. |
| `src/Arbol.hs` | Define `Arbol a` (`Vacio`/`Nodo`), `insertar`, `contiene` y `elems`. |
| `tests/Pruebas.hs` | helper `verifica`, siete grupos de pruebas, resumen y `exitFailure` si hay fallos. |
| `docs/pruebas-ghci.md` | Comandos `:load`, `:type` y ejemplos con su salida real. |

## Funcionalidades

| Módulo | API principal |
|---|---|
| `Expr` | `Expr(..)`, `eval`, `evalCon`, `variables` |
| `Pretty` | `pretty`, `prettyPrec` |
| `Simplificar` | `simplificar`, `contarNodos` |
| `Derivar` | `derivar` (helper privado `deriv`) |
| `Arbol` | `Arbol(..)`, `insertar`, `contiene`, `elems` |
| `Main` | Menú de evaluar, simplificar, derivar, imprimir y demo del árbol |
| `tests/Pruebas.hs` | 75 aserciones con resumen y código de salida |

- `eval` y `evalCon` devuelven `Maybe Integer`: una variable no ligada o una división por cero producen `Nothing`.
- `variables` devuelve los nombres distintos en orden de primera aparición; el menú lo usa para preguntar solo por las variables que aparecen.
- `pretty` añade solo los paréntesis necesarios y no usa el `Show` derivado.
- `derivar` aplica las reglas de suma, resta, producto y cociente, y simplifica el resultado con `simplificar`.

## Cómo compilar y ejecutar desde un clon limpio

Ejecuta todo desde la raíz del repositorio:

```powershell
git clone https://github.com/AxAvier7/Proyecto-Declarativa.git
cd Proyecto-Declarativa

ghc --version    # debe mostrar 9.10.3 (o una versión compatible)
ghc -Wall -fforce-recomp --make app/Main.hs -isrc -o evaluador.exe
.\evaluador.exe
```

La compilación termina sin errores ni advertencias con `-Wall` y genera los siete módulos (`Arbol`, `Expr`, `Pretty`, `Simplificar`, `Derivar`, `Main`). `evaluador.exe` está ignorado por Git, así que puedes regenerarlo sin ensuciar el repositorio.

> **Importante:** `-isrc` es obligatorio. GHC busca los módulos importados desde el directorio de trabajo, no desde la carpeta del archivo; sin esa opción, compilar `src/Pretty.hs` falla con `Could not find module 'Expr'`.

### Pruebas

```powershell
ghc -Wall -fforce-recomp --make tests/Pruebas.hs -isrc -o pruebas.exe
.\pruebas.exe
$LASTEXITCODE

# Sin generar ejecutable:
runghc -isrc tests/Pruebas.hs
```

El resumen real al final de la suite es:

```text
Total: 75
OK: 75
Fallos: 0
Resultado: todas las pruebas pasaron.
```

`$LASTEXITCODE` es `0`. Si alguna aserción falla, aparece una línea `FALLO`, el resumen indica los fallos y `exitFailure` hace que el código de salida sea distinto de `0`.

### GHCi

```powershell
ghci -isrc
```

Dentro de GHCi:

```haskell
:load src/Expr.hs src/Pretty.hs src/Simplificar.hs src/Derivar.hs src/Arbol.hs
:module + Expr Pretty Simplificar Derivar Arbol
```

Si ejecutas `:module` sin argumentos, GHCi reinicia el contexto interactivo: vuelve a escribir la segunda línea. Para una sesión más larga, consulta [`docs/pruebas-ghci.md`](docs/pruebas-ghci.md).

Ejemplos reales, uno por línea de entrada:

```text
ghci> eval (Suma (Lit 2) (Lit 3))
Just 5
ghci> eval (Div (Lit 7) (Lit 2))
Just 3
ghci> eval (Div (Lit (-7)) (Lit 2))
Just (-4)
ghci> eval (Div (Lit 1) (Lit 0))
Nothing
ghci> evalCon [("x", 4)] (Mult (Var "x") (Lit 3))
Just 12
ghci> evalCon [("x", 4)] (Var "y")
Nothing
ghci> pretty (Suma (Lit 1) (Mult (Lit 2) (Lit 3)))
"1 + 2 * 3"
ghci> pretty (Mult (Suma (Lit 1) (Lit 2)) (Lit 3))
"(1 + 2) * 3"
ghci> simplificar (Suma (Lit 0) (Mult (Lit 1) (Var "x")))
Var "x"
ghci> pretty (derivar "x" (Mult (Var "x") (Var "x")))
"x + x"
ghci> pretty (derivar "x" (Div (Lit 1) (Var "x")))
"(-1) / (x * x)"
ghci> variables (Suma (Var "y") (Mult (Var "x") (Var "y")))
["y","x"]
ghci> let a = foldr insertar Vacio [5, 3, 7, 1, 4 :: Int]
ghci> elems a
[1,3,4,5,7]
ghci> contiene 4 a
True
ghci> contiene 9 a
False
ghci> take 2 (elems a)
[1,3]
```

## Uso del ejecutable

Al arrancar, el menú se muestra así:

```text
Evaluador de expresiones

1. Evaluar
2. Simplificar
3. Derivar respecto a x
4. Imprimir con pretty
5. Demo del arbol
0. Salir
Opcion:
```

Después aparece el listado fijo de expresiones:

```text
Elige una expresion:
  1. constante: 2 + 3
  2. lineal: 2 * x + 1
  3. cuadratica: x * x
  4. cociente: 1 / x
  5. dos variables: x + y
  6. division entera: 7 / 2
```

El menú vuelve a mostrarse tras cada operación. Estas son entradas y salidas reales comprobadas (en las filas con `→` cada número se introduce en una línea distinta):

| Entrada | Operación | Salida |
|---|---|---|
| `1` → `1` | Evaluar `2 + 3` | `Resultado: 5` |
| `1` → `2` → `4` | Evaluar `2 * x + 1` con `x = 4` | `Resultado: 9` |
| `1` → `5` → `4` → `3` | Evaluar `x + y` con `x = 4`, `y = 3` | `Resultado: 7` |
| `1` → `4` → `0` | Evaluar `1 / x` con `x = 0` | `Resultado: indefinido` |
| `1` → `6` | Evaluar `7 / 2` | `Resultado: 3` |
| `2` → `1` | Simplificar `2 + 3` | `Antes: 2 + 3` y `Despues: 5` |
| `3` → `3` | Derivar `x * x` | `f(x) = x * x` y `f'(x) = x + x` |
| `3` → `4` | Derivar `1 / x` | `f(x) = 1 / x` y `f'(x) = (-1) / (x * x)` |
| `4` → `2` | Imprimir `2 * x + 1` | `2 * x + 1` |
| `5` | Demo del árbol | `Arbol vacio: []`, `Arbol de 5 nodos: [1,3,4,5,7]`, `contiene 4: True`, `contiene 9: False` |
| `X` | Opción no válida | `Opcion no valida.` |
| `1` → `99` | Índice fuera de rango | `Indice fuera de rango.` |
| `1` → `2` → `hola` | Valor no entero | `Valor no valido; se esperaba un entero.` |
| `0` | Salir | `Hasta luego.` y código de salida `0` |

El menú solo pide valores para las variables que aparecen en la expresión: no pide `x` para `2 + 3`, y pide `x` e `y` solo para `x + y`.

## Mapa de conceptos del curso

Ambientes Haskell y Prolog comparten el espíritu declarativo (se describe *qué* se quiere, no *cómo* calcularlo paso a paso) pero difieren en el mecanismo. En Haskell las funciones puras están tipadas y devuelven un valor determinado (`evalCon :: [(String, Integer)] -> Expr -> Maybe Integer`); en Prolog se define una **relación**, por ejemplo `eval(Expr, Env, Val)`, y la respuesta se obtiene por **unificación y backtracking**. Los tipos algebraicos de Haskell corresponden a términos/functores de Prolog, el `pattern matching` a la selección de cláusulas por unificación, y `Maybe` a un fallo controlado (en Prolog, una cláusula que no unify o `fail`).

| Concepto | Módulo / función en el proyecto | Cómo se usa aquí | Equivalente en Prolog |
|---|---|---|---|
| Tipos recursivos (ADT) | `Expr` (`src/Expr.hs`), `Arbol` (`src/Arbol.hs`) | `Expr` se define en términos de `Expr`; `Arbol a` contiene dos `Arbol a` | Términos y listas recursivas como `suma(X,Y)` o `[H\|T]` |
| Pattern matching | `evalCon`, `insertar`, `contiene`, `simplificar` | Cada ecuación selecciona un constructor: `evalCon env (Var x) = lookup x env` | Unificación de la cabeza de cada cláusula con el objetivo |
| Recursión estructural | `variables`, `deriv`, `elems`, `contarNodos` | Cada llamada recorre subexpresiones o subárboles más pequeños | Predicados recursivos sobre términos, por ejemplo recorrer una lista |
| Pureza | Todas las funciones de `src/` | Mismo argumento → mismo resultado; sin efectos ni estado mutable | Predicados puros ideales; `assert`, `retract` o cortes rompen la transparencia |
| `Maybe` para fallos parciales | `eval`, `evalCon` (`Nothing`), `readMaybe` en `Main` | Variable libre, división por cero y entradas no enteras se representan como `Nothing` | Un objetivo que no prueba, `fail/0` o una excepción; no hay un tipo `Maybe` |
| `Show` / `Eq` / `Ord` | `deriving (Show, Eq)` en `Expr` y `Arbol`; `Ord a =>` en `insertar`/`contiene` | `Eq` permite comparar expresiones en las pruebas; `Ord` guía el BST | Comparación estructural de términos y unificación; sin clases de tipos estáticas |
| Funciones de orden superior | `foldr` en `Main`, `mapM_` en `Main`, `filter`/`length` en `Pruebas` | `foldr insertar Vacio [5,3,7,1,4]` construye el árbol de demo | Metapredicados como `maplist/2` o `foldl/4` |
| Composición | `variables = nub . vars`, `derivar v = simplificar . deriv v` | `(.)` encadena funciones puras en una sola definición | Reglas encadenadas con `:-`; no hay operador de composición de primer orden |
| Pereza | `elems` (`src/Arbol.hs`) | `take 2 (elems a)` evalúa solo `[1,3]` y no recorre el árbol completo | No es estándar: la resolución evalúa metas bajo demanda, pero no hay listas infinitas perezosas nativas |
| Polimorfismo | `Arbol a`, `insertar :: Ord a => a -> Arbol a -> Arbol a` | El mismo árbol funciona con `Int` y con `String` | Los términos no están tipados estáticamente; cualquier functor encaja |
| E/S controlada | `Main` (`IO`, `getLine`, `putStrLn`) | Los efectos se aíslan en tipo `IO`; el núcleo sigue siendo puro | E/S con `read`/`write` y efectos laterales que rompen la pureza |
| Elección declarativa | `derivar` y `simplificar` | Se escriben las reglas; GHC aplica las ecuaciones | Cláusulas + unificación + backtracking para explorar alternativas |

## Limitaciones

- **División entera:** `Div` usa `div` sobre `Integer`. `7 / 2` es `3` y `(-7) / 2` es `-4` (redondeo hacia menos infinito). No hay racionales ni decimales, y `x / 0` da `Nothing` en `eval`/`evalCon`.
- **Simplificación parcial:** se pliegan constantes y se aplican identidades, pero no se combinan términos semejantes ni se factoriza: `x + x` no se convierte en `2 * x`. La regla `x / x = 1` asume `x /= 0` salvo que sea el literal `0`; `Div e (Lit 0)` se deja sin simplificar para no evaluar una división por cero.
- **Derivación simbólica:** `derivar` simplifica el resultado, pero mantiene la convención `x * x → x + x`. La regla del cociente presupone denominador no nulo; no se comprueba en tiempo de derivación.
- **Sin parser** (#13, opcional): no se escribe texto libre como `2*x+1`; las expresiones se construyen con los constructores de `Expr` o se eligen entre los seis ejemplos fijos del menú.
- **`Main` solo lee enteros:** cualquier otro valor produce `Valor no valido; se esperaba un entero.` y vuelve al menú. La derivación del menú es siempre respecto a `x`.
- **El árbol no está balanceado:** `insertar` mantiene el orden BST e ignora duplicados, pero no reequilibra ni soporta borrado.
- Los archivos `.exe`, `.hi` y `.o` son artefactos locales ignorados por Git.

## Enlaces

- Repositorio: <https://github.com/AxAvier7/Proyecto-Declarativa>
- Guion de pruebas en GHCi: [`docs/pruebas-ghci.md`](docs/pruebas-ghci.md)
- Suite ejecutable: [`tests/Pruebas.hs`](tests/Pruebas.hs)

## Autoría

Adrián Xavier ([@AxAvier7](https://github.com/AxAvier7)) — proyecto final de Programación Declarativa, curso 2026.
