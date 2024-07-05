{-# LANGUAGE OverloadedStrings #-}

module Toolbox (pickTool, tools, completions) where

import qualified Data.List as L (lookup)
import Data.Text (Text)
import qualified Toolbox.EnterTmux as EnterTmux (completion, main)
import qualified Toolbox.ListPath as ListPath (completion, main)
import Turtle (Line, textToLine)

pickTool :: Text -> Maybe (IO ())
pickTool name = textToLine name >>= fmap fst . flip L.lookup toolbox

tools :: [Line]
tools = map fst toolbox

completions :: [Line]
completions = foldMap (snd . snd) toolbox

type Tool = (IO (), [Line])

toolbox :: [(Line, Tool)]
toolbox =
  [ ("tx", (EnterTmux.main, EnterTmux.completion)),
    ("l", (ListPath.main, ListPath.completion))
  ]
