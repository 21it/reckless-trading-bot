module RecklessTradingBot.Class
  ( EnvM (..),
  )
where

import RecklessTradingBot.Data.Env (Env (..))
import RecklessTradingBot.Import.External

class MonadIO m => EnvM m where
  getEnv :: m Env
