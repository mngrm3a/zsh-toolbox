{-# LANGUAGE LambdaCase #-}

module Main (main) where

import System.Environment (getArgs, getProgName)
import System.Posix (getSymbolicLinkStatus, readSymbolicLink)
import System.Posix.Files (isSymbolicLink)
import Text.Printf (printf)
import Toolbox (getTool, toolboxCompletions, toolboxTools)
import Toolbox.Helpers (exitFailureWithMessage)

main :: IO ()
main =
  getArgs >>= \case
    ["--toolbox-tools"] -> mapM_ putStrLn toolboxTools
    ["--toolbox-completions"] -> putStrLn toolboxCompletions
    ["--toolbox-trace-link", path] -> traceLink path
    _toolArgs -> do
      toolName <- getProgName
      case getTool toolName of
        Just runTool -> runTool
        Nothing -> exitFailureWithMessage $ printf "unknown tool '%s'" toolName

traceLink :: FilePath -> IO ()
traceLink path = do
  fileStatus <- getSymbolicLinkStatus path
  if isSymbolicLink fileStatus
    then do
      putStrLn $ printf "link: %s" path
      target <- readSymbolicLink path
      traceLink target
    else putStrLn $ printf "root: %s" path
