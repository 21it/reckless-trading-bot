{-# LANGUAGE EmptyDataDecls #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE UndecidableInstances #-}
{-# OPTIONS_GHC -Wno-missing-export-lists #-}

module RecklessTradingBot.Data.Model where

import qualified BitfinexClient as Bfx
import Database.Persist.Quasi
import Database.Persist.TH
import RecklessTradingBot.Data.Money
import RecklessTradingBot.Data.Type
import RecklessTradingBot.Import.External

--
-- TODO : remove this ugly workaround when Persistent TH
-- issue will be fixed https://github.com/yesodweb/persistent/issues/1166
--

type CurrencyCode'Base = CurrencyCode 'Bfx.Base

type CurrencyCode'Quote = CurrencyCode 'Bfx.Quote

type ExchangeRate'Buy = ExchangeRate 'Bfx.Buy

type ExchangeRate'Sell = ExchangeRate 'Bfx.Sell

type MoneyAmount'Quote = MoneyAmount 'Bfx.Quote

type OrderExchangeId'Buy = OrderExchangeId 'Bfx.Buy

type OrderExchangeId'Sell = OrderExchangeId 'Bfx.Sell

-- You can define all of your database entities in the entities file.
-- You can find more information on persistent and how to declare entities
-- at:
-- http://www.yesodweb.com/book/persistent/
share
  [mkPersist sqlSettings, mkMigrate "migrateAuto"]
  $(persistFileWith lowerCaseSettings "config/model")
