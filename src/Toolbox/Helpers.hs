module Toolbox.Helpers (exitFailureWithMessage) where

import System.Exit (exitFailure)
import System.IO (hPutStrLn, stderr)

exitFailureWithMessage :: String -> IO a
exitFailureWithMessage message =
  hPutStrLn stderr message >> exitFailure
