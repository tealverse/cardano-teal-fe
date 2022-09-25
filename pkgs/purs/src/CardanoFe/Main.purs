module CardanoFe.Main where

import Prelude

import Control.Promise (Promise, toAff)
import Data.Array (foldM, foldr)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Show.Generic (genericShow)
import Data.String as Str
import Data.Typelevel.Undefined (undefined)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Console (log)
import TsBridge (class ToTsBridge, tsOpaqueType)

moduleName :: String
moduleName = "CardanoFe.Main"

data Wallet
  = Yoroi
  | Eternl
  | Ccvault
  | Nami
  | Flint
  | Begin

parseWallet :: String -> Maybe Wallet
parseWallet = case _ of
  "yoroi" -> Just $ Yoroi
  "eternl" -> Just $ Eternl
  "ccvault" -> Just $ Ccvault
  "nami" -> Just $ Nami
  "flint" -> Just $ Flint
  "begin" -> Just $ Begin
  _ -> Nothing

printWallet :: Wallet -> String
printWallet = show >>> Str.toLower

type UnsupportedWallet =
  { walletName :: String
  }

type SupportedWallet =
  { wallet :: Wallet
  , enabled :: Boolean
  }

newtype Balance = Balance Int

newtype Address = Address String

newtype Utxo = Utxo
  { from :: String
  , to :: String
  , amount :: Balance
  }

type WalletState =
  { type :: Wallet
  , balance :: Maybe Balance
  , usedAddresses :: Array Address
  , unUsedAddresses :: Array Address
  , rewardAddresses :: Array Address
  , utxos :: Array Utxo
  }

data Page
  = Dashboard
  | SelectWallet

data AppState
  = Login
      { supportedWallets :: Array SupportedWallet
      , unsupportedWallets :: Array UnsupportedWallet
      , selectedWallet :: Maybe WalletState
      }
  | App WalletState Page

initState :: AppState
initState = Login
  { supportedWallets: []
  , unsupportedWallets: []
  , selectedWallet: Nothing
  }

data Msg = GetAvailableWallets | SetWallet Wallet

type AppEnv =
  { updateState :: (AppState -> AppState) -> Aff Unit
  , getState :: Aff AppState
  }

control :: AppEnv -> Msg -> Aff Unit
control { updateState, getState } msg =
  do
    state <- getState

    case state, msg of
      Login _, GetAvailableWallets -> do
        browserWallets <- getBrowserWallets
        result <- getSupportedWallets browserWallets
        updateState case _ of
          Login ls -> Login ls
            { supportedWallets = result.supportedWallets
            , unsupportedWallets = result.unsupportedWallets
            }
          st -> st

      Login _, SetWallet w -> do
        updateState case _ of
          Login ls -> Login ls
            { selectedWallet = Just $ initWalletState w
            }
          st -> st

      _, _ -> pure unit

getBrowserWallets :: Aff (Array UnsupportedWallet)
getBrowserWallets = getBrowserWalletsImpl
  <#> map (\walletName -> { walletName })
  # liftEffect

getSupportedWallets
  :: Array UnsupportedWallet
  -> Aff
       { supportedWallets :: Array SupportedWallet
       , unsupportedWallets :: Array UnsupportedWallet
       }
getSupportedWallets = foldM reducer { supportedWallets: [], unsupportedWallets: [] }
  where
  reducer accum uw =
    case parseWallet uw.walletName of
      Nothing -> pure $ accum { unsupportedWallets = accum.unsupportedWallets <> [ uw ] }
      Just wallet -> do
        enabled <- isWalletEnabled $ printWallet wallet
        pure $ accum { supportedWallets = accum.supportedWallets <> [ { enabled, wallet } ] }

isWalletEnabled :: String -> Aff Boolean
isWalletEnabled = toAff <<< isWalletEnabledImpl

initWalletState :: Wallet -> WalletState
initWalletState w =
  { type: w
  , balance: Nothing
  , usedAddresses: []
  , unUsedAddresses: []
  , rewardAddresses: []
  , utxos: []
  }

main :: Effect Unit
main = do
  log "Hello"

--

instance ToTsBridge Wallet where
  toTsBridge = tsOpaqueType moduleName "Wallet" []

instance ToTsBridge Balance where
  toTsBridge = tsOpaqueType moduleName "Balance" []

instance ToTsBridge Address where
  toTsBridge = tsOpaqueType moduleName "Address" []

instance ToTsBridge Utxo where
  toTsBridge = tsOpaqueType moduleName "Utxo" []

derive instance Generic Wallet _

instance Show Wallet where
  show = genericShow

foreign import isWalletEnabledImpl :: String -> Promise Boolean

foreign import getBrowserWalletsImpl :: Effect (Array String)