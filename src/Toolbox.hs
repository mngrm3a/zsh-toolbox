module Toolbox (getTool, toolboxTools, toolboxCompletions) where

import qualified Data.List as L
import Toolbox.Tool (Tool (toolCompletion, toolMain))
import qualified Toolbox.Tools.EnterTmux (tool)
import qualified Toolbox.Tools.ListPath (tool)

getTool :: String -> Maybe (IO ())
getTool = fmap toolMain . flip L.lookup toolbox

toolboxTools :: [String]
toolboxTools = map fst toolbox

toolboxCompletions :: String
toolboxCompletions = foldMap (toolCompletion . snd) toolbox

toolbox :: [(String, Tool)]
toolbox =
  [ ("tx", Toolbox.Tools.EnterTmux.tool),
    ("l", Toolbox.Tools.ListPath.tool)
  ]
