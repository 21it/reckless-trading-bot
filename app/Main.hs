{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE TemplateHaskell #-}

module Main
  ( main,
  )
where

import RecklessTradingBot.Data.AppM (runApp)
import RecklessTradingBot.Import
import qualified RecklessTradingBot.Wai.Chat as Chat (app)
import qualified Network.Wai.Handler.Warp as Warp

main :: IO ()
main = do
  !rc <- rawConfig
  handleScribe <-
    mkHandleScribeWithFormatter
      ( case rawConfigLogFormat rc of
          Bracket -> bracketFormat
          JSON -> jsonFormat
      )
      ColorIfTerminal
      stdout
      (permitItem InfoS)
      (rawConfigLogVerbosity rc)
  let mkLogEnv =
        registerScribe "stdout" handleScribe defaultScribeSettings
          =<< initLogEnv "RecklessTradingBot" (Environment $ rawConfigLogEnv rc)
  bracket mkLogEnv closeScribes $ \le ->
    runKatipContextT le (mempty :: LogContexts) mempty $ do
      !env <- newEnv rc
      res <- lift $ runApp env $ liftIO $ Chat.app env $ \app ->
        Warp.run (envEndpointPort env) app
      $(logTM) ErrorS
        $ logStr
        $ "Terminate program with result " <> (show res :: Text)
