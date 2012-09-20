-- Example 1

import Control.Applicative
import Data.Traversable (sequenceA)
import Data.Char (toUpper)
import Control.Exception (try, IOException)

-- Helpers
wrap = Right
end = either (const $ error "unexpected error") id

-- Example 1
example1 = print $ end $ do
  v <- wrap 1
  if v == 1
    then return 2
    else return 3

example1applicative = print $ end $ f `fmap` wrap 1
  where f 1 = 2
        f _ = 3

-- Example 2
example2 = print $ end $ do
  x <- wrap 4
  y <- return $ process1 x
  z <- return $ process2 y
  return z
  where process1 x = x + 2
        process2 x = x * 3

example2applicative = print $ end $ process2 <$> process1 <$> wrap 4
  where process1 x = x + 2
        process2 x = x * 3

-- Example 3
example3 = print $ defaultOnError 5 $ do
  x <- wrap 3
  y <- process x
  return y
  where process :: b -> Either String c
        process _ = Left "error"
        defaultOnError d = either (const d) id

example3applicative = print $ defaultOnError 5 $ process $ wrap 3
  where process :: Either a b -> Either String c
        process _ = Left "error"
        defaultOnError d = either (const d) id

-- Example 4
example4 = print $ end $ do
  x <- wrap 1
  y <- wrap 2
  return $ x + y

example4applicative = print $ end $ (+) <$> wrap 1 <*> wrap 2

-- Example 5
example5 = print $ end $ do
  x <- wrap 1
  y <- wrap 2
  z <- wrap 3
  return $ foldr (+) 4 [x, y, z]

example5b = print $ end $ let
    mx = wrap 1
    my = wrap 2
    mz = wrap 3
  in do
    xs <- sequence [mx, my, mz]
    return $ foldr (+) 4 xs

{-
-- sequenceA for the lists

f :: Applicative f => [f a] -> f [a]
f [] = pure []
f (x:xs) = (:) <$> x <*> f xs
-}

example5applicative = print $ end $ foldr (+) 4 <$> sequenceA [mx, my, mz]
  where mx = wrap 1
        my = wrap 2
        mz = wrap 3

-- Example 6
example6 = do
  d <- readFile "Promises.hs"
  putStrLn $ f d
    where f = map toUpper . take 100

t :: IO a -> IO (Either IOException a)
t = try

example6b = do
  d <- t $ readFile "Promises.hs"
  putStrLn $ end $ f <$> d
  where f = map toUpper . take 100

 -- Running examples
main :: IO ()
main = do
  example1
  example1applicative
  example2
  example2applicative
  example3
  example3applicative
  example4
  example4applicative
  example5
  example5b
  example5applicative
  example6
  example6b
