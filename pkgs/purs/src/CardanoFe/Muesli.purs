module CardanoFe.Muesli
  ( ApiError
  , Currency
  , MuesliId
  , MuesliTicker
  , getMuesliTicker
  )
  where

import Prelude

import Affjax (AffjaxDriver, Response, get)
import Affjax as Affjax
import Affjax.ResponseFormat (ResponseFormat(..), json)
import Affjax.ResponseHeader (ResponseHeader)
import Affjax.StatusCode (StatusCode)
import CardanoFe.AppDebug (appDebug)
import CardanoFe.AppDecodeJson (class AppDecodeJson, appDecodeJson)
import Data.Argonaut (Json, JsonDecodeError, decodeJson)
import Data.Either (Either(..))
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

newtype MuesliTicker = MuesliTicker
  ( Map MuesliId
      { tradingPair :: TradingPair
      , lastPrice :: Maybe Number
      , baseVolume :: Int
      , quoteVolume :: Number
      , priceChange :: Number
      }
  )

instance AppDecodeJson MuesliTicker where
  appDecodeJson json = f1 json >>= f2

--

f1 :: Json -> Either JsonDecodeError MuesliTicker'
f1 = appDecodeJson

f2 :: MuesliTicker' -> Either JsonDecodeError MuesliTicker
f2 = undefined

type MuesliTicker' = Object
  { last_price :: Foreign
  , base_volume :: Int
  , quote_volume :: Number
  , price_change :: Number
  }

data ApiError
  = ErrAffjax Affjax.Error
  | ErrDecode JsonDecodeError

getMuesliTicker :: AffjaxDriver -> Aff (Either ApiError MuesliTicker)
getMuesliTicker driver = do
  get driver json "http://analyticsv2.muesliswap.com/ticker"
    <#> handleApiResponse parseMuesliTicker

parseMuesliTicker :: Json -> Either JsonDecodeError MuesliTicker
parseMuesliTicker = appDecodeJson

--

handleApiResponse
  :: forall a
   . (Json -> Either JsonDecodeError a)
  -> Either Affjax.Error (Response Json)
  -> Either ApiError a
handleApiResponse parseBody = case _ of
  Left e -> Left $ ErrAffjax e
  Right { body } -> case parseBody body of
    Left e -> Left $ ErrDecode e
    Right ok -> Right ok
