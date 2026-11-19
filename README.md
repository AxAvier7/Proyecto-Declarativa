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
src/Expr.hs          -- tipo recursivo Expr
src/Simplificar.hs   -- simplificación de expresiones
src/Derivar.hs       -- derivación simbólica
src/Arbol.hs         -- árbol binario de búsqueda
app/Main.hs          -- programa principal
tests/Pruebas.hs     -- suite de pruebas
docs/                -- informe y material de apoyo
```

## Compilación y ejecución

```powershell
ghc --make app/Main.hs -isrc -o evaluador.exe
.\evaluador.exe

ghc --make tests/Pruebas.hs -isrc -o pruebas.exe
.\pruebas.exe
```

## Estado

Etapa 0 completada: entorno GHC 9.10.3 y esqueleto de módulos listos.
