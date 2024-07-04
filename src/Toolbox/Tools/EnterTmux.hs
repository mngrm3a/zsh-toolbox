{-# LANGUAGE LambdaCase #-}

module Toolbox.Tools.EnterTmux (tool) where

import Data.Char (isAlphaNum, isLetter)
import Data.Function ((&))
import qualified Data.List as L
import GHC.IO.Exception (ExitCode (..))
import System.Directory (getCurrentDirectory)
import System.Environment (getArgs)
import System.FilePath (dropExtension, takeBaseName)
import System.Posix (executeFile)
import System.Process (readProcessWithExitCode)
import Text.Printf (printf)
import Toolbox.Helpers (exitFailureWithMessage, usageError)
import Toolbox.Tool (Tool (..))

tool :: Tool
tool =
  Tool
    { toolMain = main,
      toolCompletion =
        "_tx() { words[1]=(tmux attach-session -t); (( CURRENT+=2 )); service=tmux; _tmux }\n\
        \compdef _tx tx\n"
    }

main :: IO ()
main =
  getArgs >>= \case
    [] -> getCurrentDirectory >>= tryAttachOrNew
    ["."] -> getCurrentDirectory >>= tryAttachOrNew
    [name] -> tryAttachOrNew name
    _invalidArgs -> usageError "[<SESSION>|<PATH>]"

tryAttachOrNew :: String -> IO a
tryAttachOrNew nameOrPath = do
  sessionName <- case deriveSessionName nameOrPath of
    Just sessionName -> pure sessionName
    Nothing ->
      exitFailureWithMessage $
        printf "can't derive session name from '%s" nameOrPath
  (exitCode, stdOut, stdErr) <-
    readProcessWithExitCode
      "tmux"
      ["list-sessions"]
      mempty
  case exitCode of
    ExitFailure _ ->
      if isNoServerError stdErr
        then newSession sessionName
        else exitFailureWithMessage $ printf "tmux: %s" stdErr
    ExitSuccess -> do
      let sessions =
            L.lines stdOut
              & map (L.takeWhile (/= ':'))
              & filter (not . null)
      if sessionName `elem` sessions
        then attachSession sessionName
        else newSession sessionName
  where
    isNoServerError stdErr = "no server running on" `L.isPrefixOf` stdErr
    attachSession name = executeFile "tmux" True ["attach", "-t", name] Nothing
    newSession name = executeFile "tmux" True ["new", "-s", name] Nothing

deriveSessionName :: String -> Maybe String
deriveSessionName "/" = Just "root"
deriveSessionName path =
  case takeBaseName path & dropExtension & filter isValidChar of
    [] -> Nothing
    baseName@(n : _) | isLetter n -> Just baseName
    _invalidName -> Nothing
  where
    isValidChar c = isAlphaNum c || c == '-'
