-- | Módulo Arbol
-- Propósito: árbol binario de búsqueda (BST) como segundo ejemplo de tipo
-- recursivo polimórfico.
module Arbol (Arbol(..), insertar, contiene, elems) where

-- | Árbol binario de búsqueda.
--
-- En un 'Nodo', todos los valores de la rama izquierda son menores y todos
-- los de la rama derecha son mayores. Los duplicados se ignoran.
--
-- Ejemplos con árbol vacío:
--
-- >>> elems (Vacio :: Arbol Int)
-- []
--
-- >>> contiene 1 (Vacio :: Arbol Int)
-- False
--
-- Ejemplo con cinco nodos:
--
-- >>> elems (foldr insertar Vacio [5, 3, 7, 1, 4 :: Int])
-- [1,3,4,5,7]
--
-- >>> contiene 4 (foldr insertar Vacio [5, 3, 7, 1, 4 :: Int])
-- True
--
-- >>> contiene 9 (foldr insertar Vacio [5, 3, 7, 1, 4 :: Int])
-- False
--
-- Los duplicados no se repiten:
--
-- >>> elems (insertar 3 (insertar 3 (Vacio :: Arbol Int)))
-- [3]
data Arbol a
  = Vacio
  | Nodo a (Arbol a) (Arbol a)
  deriving (Show, Eq)

-- | Inserta un valor respetando el orden del BST.
--
-- * Si el árbol está vacío, se crea un 'Nodo' hoja.
-- * Si @x < y@, se inserta en la rama izquierda.
-- * Si @x > y@, se inserta en la rama derecha.
-- * Si @x == y@, se devuelve el árbol sin cambios: los duplicados se ignoran.
insertar :: Ord a => a -> Arbol a -> Arbol a
insertar x Vacio = Nodo x Vacio Vacio
insertar x (Nodo y izq der)
  | x < y     = Nodo y (insertar x izq) der
  | x > y     = Nodo y izq (insertar x der)
  | otherwise = Nodo y izq der

-- | Comprueba si un valor pertenece al árbol.
--
-- La búsqueda está guiada por comparaciones: baja por la izquierda cuando
-- @x < y@, por la derecha cuando @x > y@ y termina en 'True' cuando @x == y@.
-- No convierte el árbol en lista ni recorre todos sus nodos.
contiene :: Ord a => a -> Arbol a -> Bool
contiene _ Vacio = False
contiene x (Nodo y izq der)
  | x < y     = contiene x izq
  | x > y     = contiene x der
  | otherwise = True

-- | Devuelve los valores del árbol en orden creciente.
--
-- Es un recorrido in-order: izquierda, nodo, derecha. Se usa un acumulador
-- para evitar concatenar listas con @++@ en cada nodo.
elems :: Arbol a -> [a]
elems = go []
  where
    go acc Vacio = acc
    go acc (Nodo x izq der) = go (x : go acc der) izq