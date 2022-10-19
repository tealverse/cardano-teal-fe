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
import Affjax.ResponseFormat (json)
import CardanoFe.AppDebug (class AppDebug, appDebug)
import CardanoFe.AppDecodeJson (class AppDecodeJson, appDecodeJson)
import Control.Alt ((<|>))
import Data.Argonaut (Json, JsonDecodeError(..))
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Pair (Pair(..))
import Data.String (Pattern(..), split)
import Data.Traversable (traverse)
import Data.Tuple (Tuple)
import Data.Tuple.Nested ((/\))
import Effect.Aff (Aff)
import Foreign.Object (Object)
import Foreign.Object as Obj

newtype MuesliTicker = MuesliTicker (Array MuesliValue)

type MuesliValue =
  { id :: MuesliId
  , tradingPair :: TradingPair
  , lastPrice :: Maybe Number
  , baseVolume :: Number
  , quoteVolume :: Number
  , priceChange :: Number
  }

newtype Currency = Currency String

newtype MuesliId = MuesliId String

type TradingPair = Pair Currency

--

parseMuesliTicker :: MuesliTickerImpl -> Either JsonDecodeError MuesliTicker
parseMuesliTicker obj = obj
  # Obj.toUnfoldable
  # traverse parseMuesliValue
  <#> MuesliTicker

-- parseMuesliMaybe :: Tuple String MuesliValueImpl -> Maybe MuesliValue
-- parseMuesliMaybe t =
--   let
--     x = parseMuesliValue t
--   in
--     case x of
--       Left _ -> Nothing
--       Right mv -> Just mv

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

parseId :: String -> Either JsonDecodeError (Tuple MuesliId TradingPair)
parseId str = str
  # split (Pattern ".")
  # case _ of
      [ id, tp ] -> tp
        # split (Pattern "_")
        # case _ of
            [ a, b ] -> Right $ (MuesliId id) /\ Pair (Currency a) (Currency b)
            _ -> Left $ TypeMismatch "could not identify trading pairs"
      _ -> Left $ TypeMismatch "wrong dot count"

parseLastPrice :: Json -> Either JsonDecodeError (Maybe Number)
parseLastPrice json = do
  result :: Either Number String <-
    (appDecodeJson json <#> Right) <|> (appDecodeJson json <#> Left)
  case result of
    Left n -> Right $ Just n
    Right "NA" -> Right $ Nothing
    _ -> Left $ TypeMismatch "not a valid number"

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
  , base_volume :: Number
  , quote_volume :: Number
  , price_change :: Number
  }

--

instance AppDebug ApiError where
  appDebug = case _ of
    ErrAffjax e -> appDebug e
    ErrDecode e -> appDebug e

derive newtype instance AppDebug Currency
derive newtype instance Ord MuesliId

derive newtype instance Eq MuesliId

derive newtype instance AppDebug MuesliId
instance AppDecodeJson MuesliTicker where
  appDecodeJson json = appDecodeJson json >>= parseMuesliTicker

derive newtype instance AppDebug MuesliTicker