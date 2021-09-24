{-# LANGUAGE TemplateHaskell #-}

module RecklessTradingBot.Data.Type
  ( LogFormat (..),
    Error (..),
    OrderExchangeId (..),
    OrderStatus (..),
  )
where

import qualified BitfinexClient as Bfx
import RecklessTradingBot.Import.External

data LogFormat
  = Bracket
  | Json
  deriving stock (Read)

data Error
  = ErrorBfx Bfx.Error
  | ErrorSmartCon Text
  deriving stock (Show)

newtype OrderExchangeId (a :: Bfx.ExchangeAction)
  = OrderExchangeId Natural
  deriving newtype (Eq, Ord, Show)

deriving via
  Int64
  instance
    PersistFieldSql (OrderExchangeId a)

instance PersistField (OrderExchangeId a) where
  toPersistValue (OrderExchangeId x) =
    case tryFrom x of
      Right id0 -> PersistInt64 id0
      Left {} -> error $ "OrderExchangeId Int64 overflow " <> show x
  fromPersistValue = \case
    x@(PersistInt64 id0) ->
      bimap (const $ failure x) OrderExchangeId $ tryFrom id0
    x ->
      Left $ failure x
    where
      failure x = "OrderExchangeId PersistValue is invalid " <> show x

data OrderStatus
  = OrderNew
  | OrderActive
  | OrderExecuted
  | OrderCancelled
  deriving stock (Eq, Ord, Show, Read)

derivePersistField "OrderStatus"
