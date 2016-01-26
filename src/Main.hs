module Main where

import Control.Monad (filterM)
import Data.List (sort)
import Options.Applicative
import Magic.Data
import Magic.Init
import Magic.Operations
import System.Directory (getCurrentDirectory, getDirectoryContents, doesFileExist)
import System.Path (secureAbsNormPath, recurseDir)
import System.IO.HVFS

data Options = Options { recursive :: Bool
                       , paths :: [FilePath]
                       }

options :: Parser Options
options =
  Options <$> switch ( long "recursive"
                       <> short 'r'
                       <> help "Check all child directories of the given path."
                     )
  <*> many (argument str (metavar "PATH"))

run :: Options -> IO ()
run (Options recurse paths) = case paths of
                                [] -> do currentDir <- getCurrentDirectory
                                         f recurse [currentDir]
                                _ -> f recurse paths
  where f False paths = do
          files <- filterExistingFiles =<< return . sort . concat =<< mapM absGetDirectoryContents paths
          fileMagicTest files
        f True paths = do
          files <- filterExistingFiles =<< return . sort . concat =<< mapM (recurseDir SystemFS) paths
          fileMagicTest files

absGetDirectoryContents :: FilePath -> IO [FilePath]
absGetDirectoryContents path =
  do contents <- getDirectoryContents path
     let absContents = map (secureAbsNormPath path) $ filter (\x -> x /= "." && x /= "..") contents
     return . map (\(Just x) -> x) $ filter (\x -> case x of
                                                     Just _ -> True
                                                     _      -> False) absContents

fileMagicTest :: [FilePath] -> IO ()
fileMagicTest files =
  do magicObj <- magicOpen [MagicMimeType]
     magicLoadDefault magicObj
     results <- mapM (\x -> return . (\y -> x ++ ": " ++ y) =<< magicFile magicObj x) files
     mapM_ putStrLn results

filterExistingFiles :: [FilePath] -> IO [FilePath]
filterExistingFiles = filterM doesFileExist

main :: IO ()
main = run =<< execParser (options `withInfo` "Checks the MIME type of file(s) in the given path.")
  where withInfo opts desc = info (helper <*> opts) $ progDesc desc
