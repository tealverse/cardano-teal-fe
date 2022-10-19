module CardanoFe.Muesli
  ( Currency(..)
  , MuesliId(..)
  , foo
  , getMuesliTicker
  ) where

import Prelude

import Affjax (Error)
import Affjax.ResponseFormat (ResponseFormat(..))
import Affjax.ResponseHeader (ResponseHeader)
import Affjax.StatusCode (StatusCode)
import Affjax.Web (get)
import Data.Argonaut (Json)
import Data.Either (Either)
import Data.Map (Map)
import Data.Maybe (Maybe)
import Data.Pair (Pair)
import Data.Typelevel.Undefined (undefined)
import Effect.Aff (Aff)
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

getMuesliTicker :: Aff (Either Error MuesliTicker)
getMuesliTicker = undefined -- get Json "http://analyticsv2.muesliswap.com/ticker"

foo
  :: Aff
       ( Either Error
           { body :: Json
           , headers :: Array ResponseHeader
           , status :: StatusCode
           , statusText :: String
           }
       )
foo = get (Json identity) "http://analyticsv2.muesliswap.com/ticker"

-- runAff_ (\res -> log $ show $ lmap message $ map (lmap printError) $ res) foo