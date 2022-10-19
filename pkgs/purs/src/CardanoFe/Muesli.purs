module CardanoFe.Muesli
  ( ApiError
  , Currency
  , MuesliId
  , MuesliTicker
  , getMuesliTicker
  ) where

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
import Data.Map as Map
import Data.Maybe (Maybe)
import Data.Number (log)
import Data.Pair (Pair)
import Data.Tuple (Tuple)
import Data.Tuple.Nested ((/\))
import Data.Typelevel.Undefined (undefined)
import Effect.Aff (Aff, runAff_)
import Foreign (Foreign)
import Foreign.Object (Object, toUnfoldable)

newtype Currency = Currency String

newtype MuesliId = MuesliId String

derive newtype instance Ord MuesliId

type TradingPair = Pair Currency

newtype MuesliTicker = MuesliTicker (Map MuesliId MuesliValue)

type MuesliValue =
  { tradingPair :: TradingPair
  , lastPrice :: Maybe Number
  , baseVolume :: Int
  , quoteVolume :: Number
  , priceChange :: Number
  }

instance AppDecodeJson MuesliTicker where
  appDecodeJson json = f1 json >>= f2

--

f1 :: Json -> Either JsonDecodeError MuesliTicker'
f1 = appDecodeJson

f2 :: MuesliTicker' -> Either JsonDecodeError MuesliTicker
f2 mt' =
  let
    x = (toUnfoldable mt' :: Array _)
    y = map f5 x
  in
    Right $ MuesliTicker $ Map.fromFoldable y

f3 :: String -> Tuple MuesliId TradingPair
f3 = undefined

f4 :: TradingPair -> MuesliValue' -> MuesliValue
f4 = undefined

f5 :: Tuple String MuesliValue' -> Tuple MuesliId MuesliValue
f5 = undefined

type MuesliTicker' = Object MuesliValue'

type MuesliValue' =
  { last_price :: Json
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
