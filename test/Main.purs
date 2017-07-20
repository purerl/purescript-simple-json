module Test.Main where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Except (runExcept)
import Data.Either (Either, isRight)
import Data.Foreign (MultipleErrors)
import Data.Foreign.NullOrUndefined (NullOrUndefined)
import Simple.JSON (class ReadForeign, readJSON)
import Test.Spec (describe, it)
import Test.Spec.Assertions (shouldEqual)
import Test.Spec.Reporter (consoleReporter)
import Test.Spec.Runner (RunnerEffects, run)

type E a = Either MultipleErrors a

handleJSON :: forall a. ReadForeign a => String -> E a
handleJSON json = runExcept $ readJSON json

type MyTest =
  { a :: Int
  , b :: String
  , c :: Boolean
  , d :: Array String
  }

type MyTestNull =
  { a :: Int
  , b :: String
  , c :: Boolean
  , d :: Array String
  , e :: NullOrUndefined (Array String)
  }


main :: Eff (RunnerEffects ()) Unit
main = run [consoleReporter] do
  describe "readJSON" do
    it "works with proper JSON" do
      let result = handleJSON """
        { "a": 1, "b": "asdf", "c": true, "d": ["A", "B"]}
      """
      isRight (result :: E MyTest) `shouldEqual` true
    it "fails with invalid JSON" do
      let result = handleJSON """
        { "c": 1, "d": 2}
      """
      isRight (result :: E MyTest) `shouldEqual` false
    it "works with JSON lacking NullOrUndefined field" do
      let result = handleJSON """
        { "a": 1, "b": "asdf", "c": true, "d": ["A", "B"]}
      """
      isRight (result :: E MyTestNull) `shouldEqual` true
    it "works with JSON containing NullOrUndefined field" do
      let result = handleJSON """
        { "a": 1, "b": "asdf", "c": true, "d": ["A", "B"], "e": ["C", "D"]}
      """
      isRight (result :: E MyTestNull) `shouldEqual` true