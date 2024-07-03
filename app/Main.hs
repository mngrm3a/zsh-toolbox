{-# LANGUAGE LambdaCase #-}

module Main (main) where

import System.Environment (getArgs, getProgName)
import Text.Printf (printf)
import Toolbox (getTool, toolboxCompletions)
import Toolbox.Helpers (exitFailureWithMessage)

main :: IO ()
main =
  getArgs >>= \case
    ["--completions"] -> putStrLn toolboxCompletions
    _otherArgs -> do
      toolName <- getProgName
      case getTool toolName of
        Just runTool -> runTool
        Nothing -> exitFailureWithMessage $ printf "unknown tool '%s'" toolName
