module CardanoFe.Muesli
  ( Currency(..)
  , MuesliId(..)
  , getTicker
  , getMuesliTicker
  ) where

import Prelude

import Affjax (AffjaxDriver, Error, get)
import Affjax.ResponseFormat (ResponseFormat(..), json)
import Affjax.ResponseHeader (ResponseHeader)
import Affjax.StatusCode (StatusCode)
import CardanoFe.AppDebug (appDebug)
import Data.Argonaut (Json)
import Data.Either (Either)
import Data.Map (Map)
import Data.Maybe (Maybe)
import Data.Number (log)
import Data.Pair (Pair)
import Data.Typelevel.Undefined (undefined)
import Effect.Aff (Aff, runAff_)
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

getMuesliTicker :: AffjaxDriver -> Aff (Either Error MuesliTicker)
getMuesliTicker driver = undefined -- runAff_ (\res -> log $ appDebug res) (getTicker driver)

foo :: Maybe Json -> Maybe MuesliTicker
foo = undefined

getTicker
  :: AffjaxDriver
  -> Aff
       ( Either Error
           { body :: Json
           , headers :: Array ResponseHeader
           , status :: StatusCode
           , statusText :: String
           }
       )
getTicker driver = get driver json "http://analyticsv2.muesliswap.com/ticker"
