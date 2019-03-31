{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Std.Data.Builder as B
import Std.Data.Parser as P
import Std.IO.Buffered
import Std.Data.CBytes as CBytes
import Std.Data.JSON.Value
import Std.IO.FileSystem
import Std.IO.Resource
import Std.IO.StdStream
import System.IO
import System.Environment
import System.Exit

main :: IO ()
main = do
    progName <- getProgName
    args <- getArgs
    case args of
        [file] -> do
            contents <- withResource (initUVFile (CBytes.pack file) O_RDWR DEFAULT_MODE) $ \ f ->
                newBufferedInput f 4096 >>= readAll'
            case parseValue' contents of
                Right v ->
                  print v
                Left e -> do
                  writeBuilder stderrBuf ("error: " >> B.string7 (show e))
                  exitWith (ExitFailure 1)
        _ -> do
          writeBuilder stderrBuf ("Usage: " >> B.string7 progName >> " file.json")
          exitWith (ExitFailure 1)
