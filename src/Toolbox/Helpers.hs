module Toolbox.Helpers (exitFailureWithMessage, usageError) where

import System.Environment (getProgName)
import System.Exit (exitFailure)
import System.IO (hPutStrLn, stderr)
import Text.Printf (PrintfArg, printf)

exitFailureWithMessage :: String -> IO a
exitFailureWithMessage message =
  hPutStrLn stderr message >> exitFailure

usageError :: (PrintfArg a) => a -> IO ()
usageError args = do
  prog <- getProgName
  exitFailureWithMessage $ printf "Usage: %s %s" prog args
