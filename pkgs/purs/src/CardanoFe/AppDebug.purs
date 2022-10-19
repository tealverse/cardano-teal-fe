module CardanoFe.AppDebug where

import Prelude

import Data.String (joinWith)
import Data.Symbol (class IsSymbol, reflectSymbol)
import Heterogeneous.Folding (class FoldingWithIndex, class HFoldlWithIndex, hfoldlWithIndex)
import Heterogeneous.Mapping (hmap)
import Type.Proxy (Proxy(..))

class AppDebug a where
  appDebug :: a -> String

--

instance AppDebug Int where
  appDebug = show

instance AppDebug Number where
  appDebug = show

instance AppDebug String where
  appDebug = show

instance AppDebug Char where
  appDebug = show

instance AppDebug Boolean where
  appDebug = show

instance AppDebug Unit where
  appDebug = show

--

instance AppDebug a => AppDebug (Array a) where
  appDebug arr = "[" <> joinWith ", " (map appDebug arr) <> "]"

--

instance HFoldlWithIndex AppDebugProps String { | r } String => AppDebug (Record r) where
  appDebug r = "{ " <> hfoldlWithIndex AppDebugProps "" r <> " }"

data AppDebugProps = AppDebugProps

instance
  ( AppDebug a
  , IsSymbol sym
  ) =>
  FoldingWithIndex AppDebugProps (Proxy sym) String a String where
  foldingWithIndex AppDebugProps prop str a =
    pre <> reflectSymbol prop <> ": " <> appDebug a
    where
    pre
      | str == "" = ""
      | otherwise = str <> ", "

--