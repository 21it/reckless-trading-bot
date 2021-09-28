{-# LANGUAGE BangPatterns #-}

module RecklessTradingBot.Data.Env
  ( Env (..),
    RawConfig (..),
    rawConfig,
    newEnv,
  )
where

import qualified BitfinexClient as Bfx
import qualified Data.Aeson as A
import qualified Data.ByteString.Char8 as C8
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
    envBfx :: Bfx.Env,
    envPairs :: Set Bfx.CurrencyPair,
    envProfit :: Bfx.ProfitRate,
    envPriceTtl :: Seconds,
    envOrderTtl :: Seconds
  }

data RawConfig = RawConfig
  { -- general
    rawConfigBfx :: Bfx.Env,
    rawConfigPairs :: Set Bfx.CurrencyPair,
    rawConfigProfit :: Bfx.ProfitRate,
    rawConfigPriceTtl :: Seconds,
    rawConfigOrderTtl :: Seconds,
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
        (json <=< nonempty)
        "RECKLESS_TRADING_BOT_PAIRS"
        op
      <*> var
        (auto <=< nonempty)
        "RECKLESS_TRADING_BOT_PROFIT"
        op
      <*> var
        (err . newSeconds <=< auto <=< nonempty)
        "RECKLESS_TRADING_BOT_PRICE_TTL"
        op
      <*> var
        (err . newSeconds <=< auto <=< nonempty)
        "RECKLESS_TRADING_BOT_ORDER_TTL"
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
    --json :: FromJSON a => String -> Either Env.Error a
    json = first UnreadError . A.eitherDecodeStrict . C8.pack

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
