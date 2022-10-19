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
import Control.Alt ((<|>))
import Data.Argonaut (Json, JsonDecodeError(..), decodeJson)
import Data.Either (Either(..))
import Data.Map (Map)
import Data.Map as Map
import Data.Maybe (Maybe(..))
import Data.Number (log)
import Data.Pair (Pair)
import Data.Traversable (traverse)
import Data.Tuple (Tuple)
import Data.Tuple.Nested ((/\))
import Data.Typelevel.Undefined (undefined)
import Effect.Aff (Aff, runAff_)
import Foreign (Foreign)
import Foreign.Object (Object, toUnfoldable)
import Foreign.Object as Obj

newtype Currency = Currency String

newtype MuesliId = MuesliId String

derive newtype instance Ord MuesliId

type TradingPair = Pair Currency

newtype MuesliTicker = MuesliTicker (Array MuesliValue)

type MuesliValue =
  { id :: MuesliId
  , tradingPair :: TradingPair
  , lastPrice :: Maybe Number
  , baseVolume :: Int
  , quoteVolume :: Number
  , priceChange :: Number
  }

instance AppDecodeJson MuesliTicker where
  appDecodeJson json = appDecodeJson json >>= parseMuesliTicker

--

parseMuesliTicker :: MuesliTickerImpl -> Either JsonDecodeError MuesliTicker
parseMuesliTicker obj = obj
  # Obj.toUnfoldable
  # traverse parseMuesliValue
  <#> MuesliTicker

parseId :: String -> Either JsonDecodeError (Tuple MuesliId TradingPair)
parseId = undefined

parseLastPrice :: Json -> Either JsonDecodeError (Maybe Number)
parseLastPrice json = do
  result :: Either Number String <-
    (appDecodeJson json <#> Right) <|> (appDecodeJson json <#> Left)
  case result of
    Left n -> Right $ Just n
    Right "NA" -> Right $ Nothing
    _ -> Left $ TypeMismatch "not a valid number"

parseMuesliValue :: Tuple String MuesliValueImpl -> Either JsonDecodeError MuesliValue
parseMuesliValue (key /\ impl) = do
  id /\ tradingPair <- parseId key
  lastPrice <- parseLastPrice impl.last_price

  pure
    { id
    , tradingPair
    , lastPrice
    , baseVolume: impl.base_volume
    , quoteVolume: impl.quote_volume
    , priceChange: impl.price_change
    }

data ApiError
  = ErrAffjax Affjax.Error
  | ErrDecode JsonDecodeError

getMuesliTicker :: AffjaxDriver -> Aff (Either ApiError MuesliTicker)
getMuesliTicker driver = do
  get driver json "http://analyticsv2.muesliswap.com/ticker"
    <#> handleApiResponse appDecodeJson

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

--

type MuesliTickerImpl = Object MuesliValueImpl

type MuesliValueImpl =
  { last_price :: Json
  , base_volume :: Int
  , quote_volume :: Number
  , price_change :: Number
  }