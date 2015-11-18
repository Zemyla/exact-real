{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE DataKinds #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Main (main) where

import Data.Ratio ((%))
import Test.Tasty (testGroup, TestTree)
import Test.Tasty.QuickCheck (Positive(..), testProperty, (===), Property, (==>), (.&&.), testProperty)
import Test.Tasty.TH (defaultMainGenerator)

import Data.CReal.Internal
import Data.CReal.Extra ()

import BoundedFunctions (boundedFunctions)
import Floating (floating)
import Ord (ord)
import Read (read')
import Real (real)
import RealFrac (realFrac)
import RealFloat (realFloat)

-- How many binary digits to use for comparisons TODO: Test with many different
-- precisions
type Precision = 10

{-# ANN test_floating "HLint: ignore Use camelCase" #-}
test_floating :: [TestTree]
test_floating = [floating (undefined :: CReal Precision)]

{-# ANN test_ord "HLint: ignore Use camelCase" #-}
test_ord :: [TestTree]
test_ord = [ ord (undefined :: CReal Precision) ]

{-# ANN test_real "HLint: ignore Use camelCase" #-}
test_real :: [TestTree]
test_real = [ real (\x -> 1 % toInteger (max 1 (crealPrecision (x::CReal Precision)))) ]

{-# ANN test_realFrac "HLint: ignore Use camelCase" #-}
test_realFrac :: [TestTree]
test_realFrac = [ realFrac (undefined :: CReal Precision) ]

{-# ANN test_realFloat "HLint: ignore Use camelCase" #-}
test_realFloat :: [TestTree]
test_realFloat = [ realFloat (undefined :: CReal Precision) ]

{-# ANN test_read "HLint: ignore Use camelCase" #-}
test_read :: [TestTree]
test_read = [ read' (undefined :: CReal Precision) ]

prop_decimalDigits :: Positive Int -> Property
prop_decimalDigits (Positive p) = let d = decimalDigitsAtPrecision p
                                  in 10^d >= (2^p :: Integer) .&&.
                                     (d > 0 ==> 10^(d-1) < (2^p :: Integer))

prop_showIntegral :: Integer -> Property
prop_showIntegral i = show i === show (fromInteger i :: CReal 0)

prop_shiftL :: CReal Precision -> Int -> Property
prop_shiftL x s = x `shiftL` s === x * 2 ** fromIntegral s

prop_shiftR :: CReal Precision -> Int -> Property
prop_shiftR x s = x `shiftR` s === x / 2 ** fromIntegral s

prop_showNumDigits :: Positive Int -> Rational -> Property
prop_showNumDigits (Positive places) x =
  let s = rationalToDecimal places x
  in length (dropWhile (/= '.') s) === places + 1

{-# ANN test_boundedFunctions "HLint: ignore Use camelCase" #-}
test_boundedFunctions :: [TestTree]
test_boundedFunctions = [ boundedFunctions (undefined :: CReal Precision) ]

main :: IO ()
main = $(defaultMainGenerator)

