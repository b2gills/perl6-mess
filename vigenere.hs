-- vigenereCipher.hs
module VigenereCipher where

import Data.List (cycle)
import Data.Char (toUpper)
import Data.Maybe (fromJust)

--
-- Vigenere Functions
--

data Operation = Hide | Reveal

findNumFromChar :: Char -> Int
findNumFromChar x = fromJust $ lookup x alphaList
  where alphaList :: [(Char, Int)]
        alphaList = zip ['A'..'Z'] [0..25]

findLetterFromNum :: Int -> Char
findLetterFromNum x | x > 25    = fromJust $ lookup (mod x 26) numList
                    | x < 0     = fromJust $ lookup (length numList + x) numList
                    | otherwise = fromJust $ lookup x numList
  where numList :: [(Int, Char)]
        numList = zip [0..25] ['A'..'Z']

createCipher :: String -> String -> [(Char, Char)]
createCipher phrase keyword = go (map toUpper phrase) (cycle (map toUpper keyword))
  where go []       (k:ks) = []
        go (' ':ps) (k:ks) = (' ', ' ') : go ps (k:ks)
        go (p:ps)   (k:ks) = (p, k)     : go ps ks

shiftChar :: Operation -> (Char, Char) -> Char
shiftChar _  (' ', ' ') = ' '
shiftChar Hide   (x, y) = findLetterFromNum ((findNumFromChar x) + (findNumFromChar y))
shiftChar Reveal (x, y) = findLetterFromNum ((findNumFromChar x) - (findNumFromChar y))

vigenere :: Operation -> String -> String  -> String
vigenere op phrase keyword  = map (shiftChar op) $ createCipher phrase keyword

--
-- IO and Imperative Code
--

questionToAnswer :: String -> IO String
questionToAnswer question = do 
  putStrLn question
  s <- getLine
  return s

getOperation :: IO Operation
getOperation = do
    response <- questionToAnswer "(H)ide or (R)eveal text?"
    case response of
        "H" -> return Hide
        "R" -> return Reveal
        _   -> putStrLn "Please use 'H' or 'R' only." >> getOperation

main :: IO ()
main = do
  op <- getOperation
  phrase <- questionToAnswer "Enter you text that you want to change:"
  keyword <- questionToAnswer "Enter your keyword:"
  putStrLn $ vigenere op phrase keyword
  
