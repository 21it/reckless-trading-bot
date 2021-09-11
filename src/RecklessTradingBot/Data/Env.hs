{-# LANGUAGE BangPatterns #-}

module RecklessTradingBot.Data.Env
  ( Env (..),
    RawConfig (..),
    rawConfig,
    newEnv,
  )
where

import Env ((<=<), auto, header, help, keep, nonempty, parse, str, var)
import RecklessTradingBot.Data.Type
import RecklessTradingBot.Import.External

data Env
  = Env
      { -- general
        envEndpointPort :: Int,
        -- logging
        envKatipNS :: Namespace,
        envKatipCTX :: LogContexts,
        envKatipLE :: LogEnv,
        -- app
        envMsgAlert :: TChan (),
        envMsgHistory :: TVar [Message]
      }

data RawConfig
  = RawConfig
      { -- general
        rawConfigEndpointPort :: Int,
        -- katip
        rawConfigLogEnv :: Text,
        rawConfigLogFormat :: LogFormat,
        rawConfigLogVerbosity :: Verbosity
      }

rawConfig :: IO RawConfig
rawConfig =
  parse (header "RecklessTradingBot config") $
    RawConfig
      <$> var (auto <=< nonempty) "RECKLESS_TRADING_BOT_ENDPOINT_PORT" op
      <*> var (str <=< nonempty) "RECKLESS_TRADING_BOT_LOG_ENV" op
      <*> var (auto <=< nonempty) "RECKLESS_TRADING_BOT_LOG_FORMAT" op
      <*> var (auto <=< nonempty) "RECKLESS_TRADING_BOT_LOG_VERBOSITY" op
  where
    op = keep <> help ""

newEnv :: RawConfig -> KatipContextT IO Env
newEnv !rc = do
  le <- getLogEnv
  ctx <- getKatipContext
  ns <- getKatipNamespace
  ma <- liftIO $ atomically newBroadcastTChan
  mh <- liftIO $ atomically $ newTVar []
  return $
    Env
      { -- general
        envEndpointPort = rawConfigEndpointPort rc,
        -- logging
        envKatipLE = le,
        envKatipCTX = ctx,
        envKatipNS = ns,
        -- app
        envMsgAlert = ma,
        envMsgHistory = mh
      }
