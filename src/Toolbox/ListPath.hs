{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

module Toolbox.ListPath (main, completion) where

import Control.Exception (onException)
import qualified Data.Text as T
import System.Environment (getArgs)
import System.Posix (executeFile)
import Toolbox.Helpers (usage)
import Turtle (Line, die, format, isRegularFile, pwd, s, stat, (%))

completion :: [Line]
completion = mempty

main :: IO ()
main =
  getArgs >>= \case
    [] -> pwd >>= listPath
    [path] -> listPath path
    _invalidArgs -> usage "[PATH]"

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
