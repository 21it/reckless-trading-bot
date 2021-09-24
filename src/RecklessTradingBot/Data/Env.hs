{-# LANGUAGE BangPatterns #-}

module RecklessTradingBot.Data.Env
  ( Env (..),
    RawConfig (..),
    rawConfig,
    newEnv,
  )
where

import qualified BitfinexClient as Bfx
import Env
  ( Error (UnreadError),
    auto,
    header,
    help,
    keep,
    nonempty,
    parse,
    str,
    var,
  )
import RecklessTradingBot.Data.Time
import RecklessTradingBot.Data.Type
import RecklessTradingBot.Import.External

data Env = Env
  { -- logging
    envKatipNS :: Namespace,
    envKatipCTX :: LogContexts,
    envKatipLE :: LogEnv,
    -- app
    envPriceTtl :: Seconds,
    envBfx :: Bfx.Env
  }

data RawConfig = RawConfig
  { -- general
    rawConfigBfx :: Bfx.Env,
    rawConfigPriceTtl :: Seconds,
    -- katip
    rawConfigLogEnv :: Text,
    rawConfigLogFormat :: LogFormat,
    rawConfigLogVerbosity :: Verbosity
  }

rawConfig :: IO RawConfig
rawConfig = do
  env <- Bfx.newEnv
  parse (header "RecklessTradingBot config") $
    RawConfig env
      <$> var
        (err . newSeconds <=< auto <=< nonempty)
        "RECKLESS_TRADING_BOT_PRICE_TTL"
        op
      <*> var
        (str <=< nonempty)
        "RECKLESS_TRADING_BOT_LOG_ENV"
        op
      <*> var
        (auto <=< nonempty)
        "RECKLESS_TRADING_BOT_LOG_FORMAT"
        op
      <*> var
        (auto <=< nonempty)
        "RECKLESS_TRADING_BOT_LOG_VERBOSITY"
        op
  where
    op = keep <> help ""
    err = first $ UnreadError . show

newEnv :: RawConfig -> KatipContextT IO Env
newEnv !rc = do
  le <- getLogEnv
  ctx <- getKatipContext
  ns <- getKatipNamespace
  return $
    Env
      { -- logging
        envKatipLE = le,
        envKatipCTX = ctx,
        envKatipNS = ns,
        -- app
        envPriceTtl = rawConfigPriceTtl rc,
        envBfx = rawConfigBfx rc
      }
