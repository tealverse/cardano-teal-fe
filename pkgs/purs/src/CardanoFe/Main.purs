module CardanoFe.Main where

import Prelude

import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Show.Generic (genericShow)
import Data.Typelevel.Undefined (undefined)
import Effect (Effect)
import Effect.Aff (Aff)
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

control
  :: { updateState :: (AppState -> AppState) -> Aff Unit
     , getState :: Aff AppState
     }
  -> Msg
  -> Aff Unit
control { updateState, getState } msg =
  do
    state <- getState

    case state, msg of
      Login _, GetAvailableWallets -> do
        browserWallets <- getBrowserWallets
        let result = getSupportedWallets browserWallets
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
getBrowserWallets = undefined

getSupportedWallets
  :: Array UnsupportedWallet
  -> { supportedWallets :: Array SupportedWallet
     , unsupportedWallets :: Array UnsupportedWallet
     }
getSupportedWallets _ = undefined

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