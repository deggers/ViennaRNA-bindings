
module Main where

import Test.Tasty
import Test.Tasty.HUnit
import Test.Tasty.Silver as S
import Test.Tasty.Silver.Interactive as SI
import Test.Tasty.TH
import Data.Array ((!))

import BioInf.ViennaRNA.Bindings as V



a =~ b = abs (b - a) <= 0.01



case_mfe_001 :: Assertion
case_mfe_001 = do
  (e,s) <- V.mfe "cccaaaggg"
  assertBool "energy" $ e =~ (-1.2)
  assertBool "structure" $ s == "(((...)))"

case_mfe_002 :: Assertion
case_mfe_002 = do
  (e,s) <- V.mfe "uguagcuagcuagcuagcuacguacguagcuagc"
  assertBool "energy" $ e =~ (-14.0)
  assertBool "structure" $ s == "............(((((((((....)))))))))"

-- RNAfold webserver test sequence, allowing for isolated base pairs

case_mfe_003 :: Assertion
case_mfe_003 = do
  (e,s) <- V.mfe "GGGCUAUUAGCUCAGUUGGUUAGAGCGCACCCCUGAUAAGGGUGAGGUCGCUGAUUCGAAUUCAGCAUAGCCCA"
  assertBool "energy" $ e =~ (-29.90)
  assertBool "structure" $ s == "(((((((..(((.((((.(....(((((.(((((....)))).)..).))))....).)))).))))))))))."

--case_circmfe_001 :: Assertion
--case_circmfe_001 = do
--  (e,s) <- V.circmfe "GGGCUAUUAGCUCAGUUGGUUAGAGCGCA&CCCCUGAUAAGGGUGAGGUCGCUGAUUCGAAUUCAGCAUAGCCCA"
--  assertBool "energy" $ e =~ (-19.50)
--  assertBool "structure" $ s == ".((((((..(((.((((.(....(((((.(((((....)))).)..).))))....).)))).))))))))).."

case_eos_001 :: Assertion
case_eos_001 = do
  e <- V.eos "ACGAUCAGAGAUCAGAGCAUACGACAGCAG" "..((((...))))...((........)).."
  assertBool "eos" $ e =~ (-2.90)

-- TODO more on @arr@ checks !

case_part_001 :: Assertion
case_part_001 = do
  (e,s,arr) <- V.part "GGGCUAUUAGCUCAGUUGGUUAGAGCGCACCCCUGAUAAGGGUGAGGUCGCUGAUUCGAAUUCAGCAUAGCCCA"
  assertBool "energy" $ e =~ (-31.43)
  assertBool "structure" $ s == "(((((((..(((.{{{{,|,,.,({({((((({(....})))}).,,,)|||,,..}.}}}),))))))))))."
  assertBool "1,13" $ arr ! (1,13) =~ 0.010
  assertBool "4,70" $ arr ! (4,70) =~ 0.999

case_duplexfold_001 :: Assertion
case_duplexfold_001 = do
  d <- V.duplexFold "ACGATCAGAGATCAGAGCATACGACAGCAG" "ACGAAAAAAAGAGCATACGACAGCAG"
  assertBool "energy" $ energy d =~ (-4.10)
  assertBool "structure" $ structure d == ".((...((...((.&.))...))...))."



main :: IO ()
main = $(defaultMainGenerator)

