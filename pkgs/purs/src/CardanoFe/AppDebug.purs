module CardanoFe.AppDebug where

import Prelude

import Affjax as Affjax
import Affjax.ResponseHeader as Affjax.ResponseHeader
import Affjax.StatusCode as Affjax.StatusCode
import Data.Argonaut as Argonaut
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Pair (Pair(..))
import Data.String (joinWith)
import Data.Symbol (class IsSymbol, reflectSymbol)
import Effect.Exception (Error)
import Heterogeneous.Folding (class FoldingWithIndex, class HFoldlWithIndex, hfoldlWithIndex)
import Type.Proxy (Proxy)

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

instance AppDebug Error where
  appDebug = show

instance AppDebug Affjax.Error where
  appDebug = Affjax.printError

instance AppDebug Affjax.ResponseHeader.ResponseHeader where
  appDebug = show

instance AppDebug Affjax.StatusCode.StatusCode where
  appDebug = show

instance AppDebug Argonaut.JsonDecodeError where
  appDebug = show

--

instance (AppDebug a, AppDebug b) => AppDebug (Either a b) where
  appDebug = case _ of
    Left a -> "(Left " <> appDebug a <> ")"
    Right b -> "(Right " <> appDebug b <> ")"

instance (AppDebug a) => AppDebug (Pair a) where
  appDebug (Pair a b) = "(Pair " <> appDebug a <> ", " <> appDebug b <> ")"

instance (AppDebug a) => AppDebug (Maybe a) where
  appDebug = case _ of
    Just a -> "(Just " <> appDebug a <> ")"
    Nothing -> "Nothing"

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

