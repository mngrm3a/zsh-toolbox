module Toolbox (getTool, toolboxCompletions) where

import qualified Data.List as L
import Toolbox.Tool (Tool (toolCompletion, toolMain))
import Toolbox.Tools.Tx (tx)

getTool :: String -> Maybe (IO ())
getTool = fmap toolMain . flip L.lookup toolbox

toolboxCompletions :: String
toolboxCompletions = foldMap (toolCompletion . snd) toolbox

toolbox :: [(String, Tool)]
toolbox =
  [ ("tx", tx)
  ]
