module CardanoFe.TsBridge where

import Prelude

import CardanoFe.Main (Address, AppError, AppM, AppState, Lovelace, Msg, Page, Utxo, UtxoRaw, WalletId)
import CardanoFe.Muesli (Currency(..), MuesliId(..), MuesliTicker)
import Control.Promise (Promise)
import Data.DateTime.Instant (Instant)
import Data.Either (Either)
import Data.Maybe (Maybe)
import Data.Pair (Pair(..))
import Data.RemoteReport (RemoteReport)
import Data.Symbol (class IsSymbol)
import Effect (Effect)
import Effect.Aff (Aff)
import Heterogeneous.Mapping (class Mapping)
import Prim.RowList (class RowToList)
import TsBridge (class GenRecord, A, B, C, D, E, TsBridgeM, TsType, Var, Z, defaultArray, defaultBoolean, defaultBrandedType, defaultEffect, defaultFunction, defaultNumber, defaultOpaqueType, defaultPromise, defaultProxy, defaultRecord, defaultString, defaultTypeVar, defaultUnit, tsOpaqueType)
import Type.Proxy (Proxy(..))

class ToTsBridge a where
  toTsBridge :: a -> TsBridgeM TsType

instance ToTsBridge a => ToTsBridge (Proxy a) where
  toTsBridge = defaultProxy MP

instance ToTsBridge Number where
  toTsBridge = defaultNumber

instance ToTsBridge String where
  toTsBridge = defaultString

instance ToTsBridge Unit where
  toTsBridge = defaultUnit

instance ToTsBridge Boolean where
  toTsBridge = defaultBoolean

instance ToTsBridge a => ToTsBridge (Aff a) where
  toTsBridge =  defaultOpaqueType "Data.Aff" "Aff" ["A"] [toTsBridge (Proxy :: _ a)] 

instance ToTsBridge Instant where
  toTsBridge = defaultOpaqueType "Effect.Aff" "Instant" [] []

instance (ToTsBridge e, ToTsBridge a) => ToTsBridge (RemoteReport e a) where
  toTsBridge = defaultOpaqueType "Data.RemoteReport" "RemoteReport" [ "A", "B" ]
    [ toTsBridge (Proxy :: _ e), toTsBridge (Proxy :: _ a) ]

instance ToTsBridge a => ToTsBridge (Effect a) where
  toTsBridge = defaultEffect MP

instance ToTsBridge a => ToTsBridge (Array a) where
  toTsBridge = defaultArray MP

instance (ToTsBridge a, ToTsBridge b) => ToTsBridge (a -> b) where
  toTsBridge = defaultFunction MP

instance (GenRecord MappingToTsBridge rl, RowToList r rl) => ToTsBridge (Record r) where
  toTsBridge = defaultRecord MP

instance ToTsBridge a => ToTsBridge (Promise a) where
  toTsBridge = defaultPromise MP

instance ToTsBridge a => ToTsBridge (Maybe a) where
  toTsBridge = defaultOpaqueType "Data.Maybe" "Maybe" [ "A" ]
    [ toTsBridge (Proxy :: _ a) ]

instance (ToTsBridge a, ToTsBridge b) => ToTsBridge (Either a b) where
  toTsBridge = defaultOpaqueType "Data.Either" "Either" [ "A", "B" ]
    [ toTsBridge (Proxy :: _ a), toTsBridge (Proxy :: _ b) ]

instance (ToTsBridge a) => ToTsBridge (Pair a) where
  toTsBridge = defaultOpaqueType "Data.Pair" "Pair" [ "A" ]
    [ toTsBridge (Proxy :: _ a) ]

instance ToTsBridge WalletId where
  toTsBridge = defaultOpaqueType "CardanoFe.Main" "WalletId" [] []

instance ToTsBridge Lovelace where
  toTsBridge = defaultOpaqueType "CardanoFe.Main" "Lovelace" [] []

instance ToTsBridge Address where
  toTsBridge = defaultOpaqueType "CardanoFe.Main" "Address" [] []  

instance ToTsBridge Utxo where
  toTsBridge = defaultOpaqueType "CardanoFe.Main" "Utxo" [] []

instance ToTsBridge UtxoRaw where
  toTsBridge = defaultOpaqueType "CardanoFe.Main" "UtxoRaw" [] []

instance ToTsBridge AppState where
  toTsBridge = defaultOpaqueType "CardanoFe.Main" "AppState" [] []

instance ToTsBridge Page where
  toTsBridge = defaultOpaqueType "CardanoFe.Main" "Page" [] []

instance ToTsBridge Msg where
  toTsBridge = defaultOpaqueType "CardanoFe.Main" "Msg" [] []

instance ToTsBridge a => ToTsBridge (AppM a) where
  toTsBridge = defaultOpaqueType "CardanoFe.Main" "AppM" [ "A" ]
    [ toTsBridge (Proxy :: _ a) ]

instance ToTsBridge AppError where
  toTsBridge = defaultOpaqueType "CardanoFe.Main" "AppError" [] []

instance ToTsBridge MuesliTicker where
  toTsBridge = defaultBrandedType MP "CardanoFe.Muesli" "MuesliTicker" [] []

instance ToTsBridge MuesliId where
  toTsBridge = defaultBrandedType MP "CardanoFe.Muesli" "MuesliId" [] []

instance ToTsBridge Currency where
  toTsBridge = defaultBrandedType MP "CardanoFe.Muesli" "Currency" [] []

instance IsSymbol s => ToTsBridge (Var s) where
  toTsBridge = defaultTypeVar

-- instance ToTsBridge A where
--   toTsBridge _ = defaultTypeVar "A"

-- instance ToTsBridge B where
--   toTsBridge _ = defaultTypeVar "B"

-- instance ToTsBridge C where
--   toTsBridge _ = defaultTypeVar "C"

-- instance ToTsBridge D where
--   toTsBridge _ = defaultTypeVar "D"

-- instance ToTsBridge E where
--   toTsBridge _ = defaultTypeVar "E"

-- --

-- instance ToTsBridge Z where
--   toTsBridge = defaultTypeVar "Z"

--

data MappingToTsBridge = MP

instance ToTsBridge a => Mapping MappingToTsBridge a (TsBridgeM TsType) where
  mapping _ = toTsBridge