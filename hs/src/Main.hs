{-# LANGUAGE OverloadedStrings #-}

import Control.Monad
import Data.IORef (IORef, newIORef, readIORef, writeIORef)
import System.Exit
import DBus
import DBus.Client

main :: IO ()
main = do
    client <- connectSession
    requestResult <- requestName client (busName_ "je.sappel.Greet") []

    when (requestResult /= NamePrimaryOwner) $ do
        putStrLn "Another service owns the \"je.sappel.Greet\" bus name"
        exitFailure

    nameRef <- newIORef "Groot"

    export client "/je/sappel/Greet" defaultInterface {
            interfaceName = "je.sappel.Greet"
            , interfaceMethods =
                [
                    autoMethod "Greet" (greetMethod client nameRef)
                ]
            ,   interfaceProperties =
                [
                    autoProperty "Name" (Just $ nameGetter nameRef) (Just $ const $ return ())
                ]
            }

    waitForTermination

greetMethod :: Client -> IORef String -> String -> IO ()
greetMethod client nameRef newName = do
    writeIORef nameRef newName
    emitPropertiesChanged client nameRef
    putStrLn $ "Greeted with: " ++ newName

nameGetter :: IORef String -> IO String
nameGetter = readIORef

emitPropertiesChanged :: Client -> IORef String -> IO ()
emitPropertiesChanged client nameRef = do
    name <- readIORef nameRef
    let nameChanged = (signal (objectPath_ "/je/sappel/Greet") "org.freedesktop.DBus.Properties" "PropertiesChanged")
            { signalBody = [ toVariant ("je.sappel.Greet" :: String)
                           , toVariant [("Name" :: String, toVariant name)]
                           , toVariant ([] :: [String])
                           ]
            }
    emit client nameChanged

waitForTermination :: IO ()
waitForTermination = getLine >> return ()
