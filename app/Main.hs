{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import qualified Data.Text as T
import System.Environment (getArgs, getProgName)
import Toolbox (completions, pickTool, tools)
import Turtle (echo, eprintf, isSymbolicLink, lstat, printf, readlink, s, (%))

main :: IO ()
main =
  getArgs >>= \case
    ["--toolbox-tools"] -> mapM_ echo tools
    ["--toolbox-completions"] -> mapM_ echo completions
    ["--toolbox-trace-link", path] -> traceLink path
    _args -> do
      name <- T.pack <$> getProgName
      case pickTool name of
        Just toolMain -> toolMain
        Nothing -> eprintf ("unknown tool '" % s % "'") name

traceLink :: FilePath -> IO ()
traceLink path = do
  status <- lstat path
  if isSymbolicLink status
    then trace "link" path >> readlink path >>= traceLink
    else trace "root" path
  where
    trace n = printf (s % ": " % s) n . T.pack
