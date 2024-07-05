{-# LANGUAGE OverloadedStrings #-}

module Toolbox.Helpers (usage) where

import qualified Data.Text as T
import System.Environment (getProgName)
import Turtle (Text, die, format, s, (%), (<$>))

usage :: Turtle.Text -> IO b
usage args = do
  prog <- T.pack Turtle.<$> getProgName
  die $ format ("Usage: " % s % " " % s) prog args
