{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ViewPatterns #-}

module Toolbox.EnterTmux (main, completion) where

import Data.Char (isAlpha, isAlphaNum, isPunctuation)
import Data.Maybe (mapMaybe)
import qualified Data.Text as T
import System.Posix (executeFile)
import Toolbox.Helpers (usage)
import Turtle
  ( ExitCode (..),
    Line,
    MonadIO,
    Text,
    arguments,
    basename,
    d,
    die,
    format,
    procStrictWithErr,
    pwd,
    s,
    (%),
  )

completion :: [Line]
completion =
  [ "_tx() { words[1]=(tmux attach-session -t); (( CURRENT+=2 )); service=tmux; _tmux }",
    "compdef _tx tx"
  ]

main :: IO ()
main =
  arguments >>= \case
    [] -> pwd >>= attachOrNewSession . T.pack . basename
    [name] -> attachOrNewSession name
    _invalidArgs -> usage "[SESSION|PATH]"

attachOrNewSession :: Text -> IO ()
attachOrNewSession name = withSessionName name $ \sessionName -> do
  listSessions >>= \case
    SessionList sessions ->
      if sessionName `elem` sessions
        then attachSession sessionName
        else newSession sessionName
    NoServer -> newSession sessionName
    UnrecoverableError code stdErr ->
      die $ format ("tmux:" % d % ": " % s) code stdErr
  where
    newSession (T.unpack -> sn) =
      executeFile "tmux" True ["new", "-s", sn] Nothing
    attachSession (T.unpack -> sn) =
      executeFile "tmux" True ["attach-session", "-t", sn] Nothing

withSessionName :: Text -> (Text -> IO a) -> IO a
withSessionName name action = case T.uncons sessionName of
  Just (c, _) | isAlpha c -> action sessionName
  _invalidName -> die $ format ("can't derive session name from '" % s % "'") name
  where
    sessionName = T.filter isValidChar . T.map replacePunctuation $ name
    replacePunctuation c = if isPunctuation c then '-' else c
    isValidChar c = isAlphaNum c || c == '-'

data ListSessions
  = SessionList ![Text]
  | NoServer
  | UnrecoverableError !Int !Text
  deriving (Eq)

listSessions :: (MonadIO m) => m ListSessions
listSessions = do
  (exitCode, stdOut, stdErr) <- procStrictWithErr "tmux" ["list-sessions"] mempty
  case exitCode of
    ExitSuccess -> pure $ SessionList $ mapMaybe getSessionName $ T.lines stdOut
    ExitFailure code ->
      pure $
        if isNoSocktError stdErr || isNoServerError stdErr
          then NoServer
          else UnrecoverableError code stdErr
  where
    getSessionName str =
      let name = T.takeWhile (/= ':') str
       in if T.null name then Nothing else Just name
    isNoSocktError = T.isPrefixOf "error connecting to"
    isNoServerError = T.isPrefixOf "no server running on"
