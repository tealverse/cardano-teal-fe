module CardanoFe.Muesli where

import Prelude

import Data.Map (Map)
import Data.Maybe (Maybe)
import Data.Pair (Pair(..))
import Foreign (Foreign)
import Foreign.Object (Object)

newtype Currency = Currency String

newtype MuesliId = MuesliId String

type TradingPair = Pair Currency

type MuesliTicker = Map MuesliId
  { tradingPair :: TradingPair
  , lastPrice :: Maybe Number
  , baseVolume :: Int
  , quoteVolume :: Number
  , priceChange :: Number
  }

type MuesliTicker' = Object
  { last_price :: Foreign
  , base_volume :: Int
  , quote_volume :: Number
  , price_change :: Number
  }