module Toolbox.Tool (Tool (..)) where

data Tool = Tool
  { toolMain :: !(IO ()),
    toolCompletion :: !String
  }
