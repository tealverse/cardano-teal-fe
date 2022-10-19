module CardanoFe.AppDebug where

import Prelude

import Data.String (joinWith)

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
