module CardanoFe.TsBridge where

import Prelude

import Control.Promise (Promise)
import Data.Either (Either)
import Data.Maybe (Maybe)
import Effect (Effect)
import Effect.Aff (Aff)
import Heterogeneous.Mapping (class Mapping)
import Prim.RowList (class RowToList)
import TsBridge (class GenRecord, A, B, C, TsBridgeM, TsType, Z, defaultArray, defaultBoolean, defaultEffect, defaultFunction, defaultNumber, defaultPromise, defaultProxy, defaultRecord, defaultString, defaultUnit, tsOpaqueType1, tsOpaqueType2, tsTypeVar)
import Type.Proxy (Proxy)

moduleName :: String
moduleName = "CardanoFe.TsBridge"

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
  toTsBridge = tsOpaqueType1 MP moduleName "Aff" "A"

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
  toTsBridge = tsOpaqueType1 MP "Data.Maybe" "Maybe" "A"

instance (ToTsBridge a, ToTsBridge b) => ToTsBridge (Either a b) where
  toTsBridge = tsOpaqueType2 MP "Data.Either" "Either" "A" "B"

instance ToTsBridge A where
  toTsBridge _ = tsTypeVar "A"

instance ToTsBridge B where
  toTsBridge _ = tsTypeVar "B"

instance ToTsBridge C where
  toTsBridge _ = tsTypeVar "C"

--

instance ToTsBridge Z where
  toTsBridge _ = tsTypeVar "Z"

--

data MappingToTsBridge = MP

instance ToTsBridge a => Mapping MappingToTsBridge a (TsBridgeM TsType) where
  mapping _ = toTsBridge