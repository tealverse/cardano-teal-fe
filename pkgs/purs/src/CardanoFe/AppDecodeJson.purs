module CardanoFe.AppDecodeJson where

import Prelude

import Data.Argonaut (decodeJson)
import Data.Argonaut.Core (Json, toObject)
import Data.Argonaut.Decode.Decoders (decodeArray, decodeBoolean, decodeForeignObject, decodeInt, decodeMap, decodeMaybe, decodeNumber, decodeString)
import Data.Argonaut.Decode.Error (JsonDecodeError(..))
import Data.Bifunctor (lmap)
import Data.Either (Either(..))
import Data.Map (Map)
import Data.Maybe (Maybe(..))
import Data.Symbol (class IsSymbol, reflectSymbol)
import Foreign.Object (Object)
import Foreign.Object as FO
import Prim.Row as Row
import Prim.RowList as RL
import Record as Record
import Type.Proxy (Proxy(..))

class AppDecodeJson a where
  appDecodeJson :: Json -> Either JsonDecodeError a

instance AppDecodeJson Int where
  appDecodeJson = decodeInt

instance AppDecodeJson Number where
  appDecodeJson = decodeNumber

instance AppDecodeJson String where
  appDecodeJson = decodeString

instance AppDecodeJson Boolean where
  appDecodeJson = decodeBoolean

instance AppDecodeJson Json where
  appDecodeJson = decodeJson

instance AppDecodeJson a => AppDecodeJson (Object a) where
  appDecodeJson = decodeForeignObject appDecodeJson

instance (Ord k, AppDecodeJson k, AppDecodeJson v) => AppDecodeJson (Map k v) where
  appDecodeJson = decodeMap appDecodeJson appDecodeJson

instance (AppDecodeJson a) => AppDecodeJson (Maybe a) where
  appDecodeJson = decodeMaybe appDecodeJson

instance (AppDecodeJson a) => AppDecodeJson (Array a) where
  appDecodeJson = decodeArray appDecodeJson

--

instance
  ( GDecodeJson row list
  , RL.RowToList row list
  ) =>
  AppDecodeJson (Record row) where
  appDecodeJson json =
    case toObject json of
      Just object -> gDecodeJson object (Proxy :: Proxy list)
      Nothing -> Left $ TypeMismatch "Object"

class GDecodeJson (row :: Row Type) (list :: RL.RowList Type) | list -> row where
  gDecodeJson :: forall proxy. FO.Object Json -> proxy list -> Either JsonDecodeError (Record row)

instance gDecodeJsonNil :: GDecodeJson () RL.Nil where
  gDecodeJson _ _ = Right {}

instance gDecodeJsonCons ::
  ( DecodeJsonField value
  , GDecodeJson rowTail tail
  , IsSymbol field
  , Row.Cons field value rowTail row
  , Row.Lacks field rowTail
  ) =>
  GDecodeJson row (RL.Cons field value tail) where
  gDecodeJson object _ = do
    let
      _field = Proxy :: Proxy field
      fieldName = reflectSymbol _field
      fieldValue = FO.lookup fieldName object

    case decodeJsonField fieldValue of
      Just fieldVal -> do
        val <- lmap (AtKey fieldName) fieldVal
        rest <- gDecodeJson object (Proxy :: Proxy tail)
        Right $ Record.insert _field val rest

      Nothing ->
        Left $ AtKey fieldName MissingValue

class DecodeJsonField a where
  decodeJsonField :: Maybe Json -> Maybe (Either JsonDecodeError a)

instance decodeFieldMaybe ::
  AppDecodeJson a =>
  DecodeJsonField (Maybe a) where
  decodeJsonField Nothing = Just $ Right Nothing
  decodeJsonField (Just j) = Just $ appDecodeJson j

else instance decodeFieldId ::
  AppDecodeJson a =>
  DecodeJsonField a where
  decodeJsonField j = appDecodeJson <$> j

--