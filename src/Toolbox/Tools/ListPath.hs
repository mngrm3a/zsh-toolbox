{-# LANGUAGE LambdaCase #-}

module Toolbox.Tools.ListPath (tool) where

import Control.Monad (when)
import System.Directory (doesDirectoryExist, doesFileExist, getCurrentDirectory)
import System.Environment (getArgs)
import System.Posix (executeFile)
import Text.Printf (printf)
import Toolbox.Helpers (exitFailureWithMessage, usageError)
import Toolbox.Tool (Tool (..))

tool :: Tool
tool =
  Tool
    { toolMain = main,
      toolCompletion = mempty
    }

main :: IO ()
main =
  getArgs >>= \case
    [] -> getCurrentDirectory >>= listPath
    [path] -> listPath path
    _invalidArgs -> usageError "[path]"

listPath :: FilePath -> IO ()
listPath path = do
  (isFile, isDirectory) <- (,) <$> doesFileExist path <*> doesDirectoryExist path
  when isFile $ executeFile "bat" True batArgs Nothing
  when isDirectory $ executeFile "exa" True ezaArgs Nothing
  exitFailureWithMessage $ printf "'%s' does not exit" path
  where
    batArgs = [path]
    ezaArgs =
      "--group"
        : "--long"
        : "--icons"
        : "--git"
        : "--git-ignore"
        : [path]
