{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

module Toolbox.Tools.ListPath (tool) where

import Control.Exception (onException)
import qualified Data.Text as T
import System.Environment (getArgs)
import System.Posix (executeFile)
import Toolbox.Tool (Tool (..))
import Turtle (die, format, isRegularFile, pwd, s, stat, (%))

tool :: Tool
tool =
  Tool
    { toolMain = main,
      toolCompletion = mempty
    }

main :: IO ()
main =
  getArgs >>= \case
    [] -> pwd >>= listPath
    [path] -> listPath path
    _invalidArgs -> die "Usage: [PATH]"

listPath :: FilePath -> IO ()
listPath path = do
  isFile <-
    (isRegularFile <$> stat path)
      `onException` die (format ("can't find '" % s % "'") $ T.pack path)
  if isFile
    then exec "bat" [path]
    else exec "exa" ["--group", "--long", "--icons", "--git", "--git-ignore", path]
  where
    exec prog args = executeFile prog True args Nothing
