module CardanoFe.TsBridge where

import Data.Either (Either)
import Data.Maybe (Maybe)
import Heterogeneous.Mapping (class Mapping)
import Prim.RowList (class RowToList)
import Type.Proxy (Proxy)
import TsBridge
  ( class GenRecord
  , A
  , B
  , C
  , TsBridgeM
  , TsType
  )
import TsBridge.Class
  ( defaultArray
  , defaultBoolean
  , defaultFunction
  , defaultNumber
  , defaultProxy
  , defaultRecord
  , defaultString
  , tsOpaqueType1
  , tsOpaqueType2
  , tsTypeVar
  )

class ToTsBridge a where
  toTsBridge :: a -> TsBridgeM TsType

instance ToTsBridge a => ToTsBridge (Proxy a) where
  toTsBridge = defaultProxy MP

instance ToTsBridge Number where
  toTsBridge = defaultNumber

instance ToTsBridge String where
  toTsBridge = defaultString

instance ToTsBridge Boolean where
  toTsBridge = defaultBoolean

instance ToTsBridge a => ToTsBridge (Array a) where
  toTsBridge = defaultArray MP

instance (ToTsBridge a, ToTsBridge b) => ToTsBridge (a -> b) where
  toTsBridge = defaultFunction MP

instance (GenRecord MappingToTsBridge rl, RowToList r rl) => ToTsBridge (Record r) where
  toTsBridge = defaultRecord MP

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

data MappingToTsBridge = MP

instance ToTsBridge a => Mapping MappingToTsBridge a (TsBridgeM TsType) where
  mapping _ = toTsBridge