{-# LANGUAGE LambdaCase #-}

module Toolbox.Tools.Tx (tx) where

import Data.Char (isAlphaNum, isLetter)
import Data.Function ((&))
import qualified Data.List as L
import System.Directory (getCurrentDirectory)
import System.Environment (getArgs)
import System.FilePath (dropExtension, takeBaseName)
import System.Posix (executeFile)
import System.Process (readProcess)
import Text.Printf (printf)
import Toolbox.Helpers (exitFailureWithMessage)
import Toolbox.Tool (Tool (..))

tx :: Tool
tx =
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
    _invalidArgs -> exitFailureWithMessage "Usage: tx [<SESSION>|<PATH>]"

tryAttachOrNew :: String -> IO a
tryAttachOrNew name' =
  case deriveSessionName name' of
    Nothing -> exitFailureWithMessage $ printf "can't derive session name from '%s'" name'
    Just name -> do
      sessions <- listSessions
      if name `elem` sessions
        then executeFile "tmux" True ["attach", "-t", name] Nothing
        else executeFile "tmux" True ["new", "-s", name] Nothing

listSessions :: IO [String]
listSessions = do
  output <- readProcess "tmux" ["list-sessions"] mempty
  L.lines output
    & map (L.takeWhile (/= ':'))
    & filter (not . null)
    & pure

deriveSessionName :: String -> Maybe String
deriveSessionName "/" = Just "root"
deriveSessionName path =
  case takeBaseName path & dropExtension & filter isValidChar of
    [] -> Nothing
    baseName@(n : _) | isLetter n -> Just baseName
    _invalidName -> Nothing
  where
    isValidChar c = isAlphaNum c || c == '-'
