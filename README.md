# Evaluador de expresiones y árboles con tipos recursivos en Haskell

Proyecto final de Programación Declarativa: un pequeño lenguaje de expresiones
aritméticas y simbólicas construido sobre un tipo recursivo `Expr`, con
evaluación, simplificación, derivación simbólica e impresión legible.

## Requisitos

- **GHC 9.10.3** (instalado con GHCup)
- **GHCi 9.10.3**
- `runghc` para ejecutar las pruebas
- Sin librerías externas: solo `base` y el toolchain de GHC

## Estructura

```text
src/Expr.hs          -- tipo recursivo Expr, eval y evalCon
src/Pretty.hs        -- impresión legible con paréntesis mínimos
src/Simplificar.hs   -- simplificación de expresiones
src/Derivar.hs       -- derivación simbólica
src/Arbol.hs         -- árbol binario de búsqueda (pendiente, #8)
app/Main.hs          -- programa principal (esqueleto, #7)
tests/Pruebas.hs     -- suite de pruebas (pendiente, #9)
docs/                -- informe y material de apoyo
.ghci                -- configuración de GHCi (-isrc), si está presente
hie.yaml             -- configuración de HLS (-isrc), si está presente
```

## Funcionalidades implementadas

| Módulo | API principal | Estado |
|---|---|---|
| `Expr` | `Expr(..)`, `eval`, `evalCon` | Completo (#2, #3) |
| `Pretty` | `pretty`, `prettyPrec` | Completo (#4) |
| `Simplificar` | `simplificar`, `contarNodos` | Completo (#5) |
| `Derivar` | `derivar` (helper privado `deriv`) | Completo (#6) |
| `Arbol` | `Arbol`, `insertar`, `contiene`, `elems` | Pendiente (#8) |
| `Main` | menú de demostración | Pendiente (#7) |
| `tests/Pruebas.hs` | suite de aserciones | Pendiente (#9) |

- `eval` y `evalCon` usan `Maybe Integer`: las variables no ligadas y la
  división por cero producen `Nothing`.
- `pretty` añade solo los paréntesis necesarios y no depende de `Show`.
- `simplificar` pliega constantes y aplica identidades algebraicas; incluye
  `contarNodos` como auxiliar para las pruebas.
- `derivar` aplica las reglas de suma, resta, producto y cociente, y simplifica
  el resultado.

## Uso rápido en GHCi

Carga los módulos del núcleo:

```powershell
ghci -isrc src/Expr.hs src/Pretty.hs src/Simplificar.hs src/Derivar.hs
```

Añade los módulos al contexto interactivo:

```haskell
:module + Expr Pretty Simplificar Derivar
```

Ejemplos:

```haskell
eval (Suma (Lit 2) (Lit 3))                       -- Just 5
eval (Div (Lit 1) (Lit 0))                        -- Nothing
evalCon [("x", 4)] (Mult (Var "x") (Lit 3))       -- Just 12
pretty (Suma (Lit 1) (Mult (Lit 2) (Lit 3)))      -- "1 + 2 * 3"
simplificar (Suma (Lit 0) (Var "x"))              -- Var "x"
pretty (derivar "x" (Mult (Var "x") (Var "x")))   -- "x + x"
```

> **Nota:** si ejecutas `:module` sin argumentos, GHCi reinicia el contexto
> interactivo. Para recuperarlo, vuelve a ejecutar
> `:module + Expr Pretty Simplificar Derivar`.

## Compilación y ejecución

```powershell
ghc --make app/Main.hs -isrc -o evaluador.exe
.\evaluador.exe

ghc --make tests/Pruebas.hs -isrc -o pruebas.exe
.\pruebas.exe
```

- `evaluador.exe` compila, pero `Main` todavía muestra el mensaje de esqueleto
  hasta que se complete el issue #7.
- `pruebas.exe` compila, pero la suite todavía muestra el mensaje de pendiente
  hasta que se complete el issue #9.

Para comprobar los módulos del núcleo con advertencias:

```powershell
ghc -Wall -fforce-recomp -isrc -c src/Expr.hs src/Pretty.hs src/Simplificar.hs src/Derivar.hs
```

> **Importante:** el flag `-isrc` es obligatorio siempre que se compile desde
> la raíz. GHC busca los módulos importados en el directorio de trabajo actual,
> no en la carpeta del archivo; sin `-isrc`, un `ghc src/Pretty.hs` falla con
> `Could not find module 'Expr'`. Para cargar módulos en GHCi, arranca `ghci`
> desde la raíz y ejecuta `:set -isrc` (o usa el archivo `.ghci`, si está
> presente). El archivo `hie.yaml`, si está presente, hace lo mismo para el
> editor (HLS); si el editor ya estaba abierto antes de añadirlo, reinicia el
> servidor (*Developer: Reload Window* o *Haskell: Restart Haskell Language
> Server*).

## Estado de los issues

| Issue | Estado | Contenido |
|---|---|---|
| #1 | Cerrado | Entorno GHC, repositorio y esqueleto de módulos |
| #2 | Cerrado | Tipo recursivo `Expr` |
| #3 | Cerrado | `eval` y `evalCon` con `Maybe` |
| #4 | Cerrado | `pretty` con paréntesis mínimos |
| #5 | Cerrado | `simplificar` |
| #6 | Cerrado | Derivación simbólica |
| #7 | Abierto | Integrar `Main.hs` con casos de demostración |
| #8 | Abierto | Árbol binario de búsqueda |
| #9 | Abierto | Suite de pruebas en GHCi/runghc |
| #10 | Abierto / en progreso | README con guía de uso y mapa de conceptos (este documento) |
| #11 | Abierto | Informe breve y comparación declarativa vs. imperativa/Prolog |
| #12 | Abierto | Guion de demo y checklist final |
| #13 | Abierto | Parser de expresiones para entrada por consola (opcional) |
| #15 | Abierto | Hoja de ruta del proyecto |

**Resumen:** el núcleo del evaluador está completo (#1–#6). Faltan la
integración de `Main` (#7), el árbol binario (#8), la suite de pruebas (#9), la
documentación y la demo (#10–#12). El parser (#13) es una extensión opcional.

## Limitaciones actuales

- `eval` usa `Integer` y `div`: la división es entera y redondea hacia menos
  infinito; no hay números racionales.
- `simplificar` aplica identidades algebraicas, pero no combina términos
  semejantes ni factoriza. Por ejemplo, `x + x` no se convierte en `2 * x`.
- `derivar` es simbólica y presupone denominadores no nulos en la regla del
  cociente; no evalúa divisiones por cero.
- Todavía no hay parser de entrada por consola (#13, opcional): las expresiones
  se construyen con los constructores de `Expr`.
- `Main` y `tests/Pruebas.hs` son esqueletos hasta completar #7 y #9.
- `Arbol` aún no está implementado (#8).

## Próximos pasos

1. Integrar `Main.hs` con un menú y casos de demostración (#7).
2. Implementar el árbol binario de búsqueda (#8).
3. Crear la suite de pruebas y el guion de GHCi (#9).
4. Completar el README con la tabla de conceptos y la autoría (#10).
5. Redactar el informe (#11).
6. Preparar el guion de demo y el checklist final (#12).
7. Añadir el parser de expresiones, si se conserva el alcance opcional (#13).

## Enlaces

- Repositorio: <https://github.com/AxAvier7/Proyecto-Declarativa>
- Issues: <https://github.com/AxAvier7/Proyecto-Declarativa/issues>
- Fecha de entrega prevista: antes del 11 de diciembre de 2026 (ver #15).
