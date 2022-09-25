module CardanoFe.Main where

import Prelude

import Control.Monad.Error.Class (class MonadThrow, liftEither, try)
import Control.Monad.Except (class MonadError, ExceptT, runExceptT)
import Control.Promise (Promise, toAff)
import Data.Array (foldM)
import Data.Bifunctor (lmap)
import Data.Either (Either)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Show.Generic (genericShow)
import Data.String as Str
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class (class MonadEffect, liftEffect)
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

data AppError
  = ErrWalletNotFound String
  | ErrHttp
  | ErrUnknown

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

newtype AppM a = AppM (ExceptT AppError Aff a)

initState :: AppState
initState = Login
  { supportedWallets: []
  , unsupportedWallets: []
  , selectedWallet: Nothing
  }

data Msg = GetAvailableWallets | SetWallet Wallet

type AppEnv =
  { updateState :: (AppState -> AppState) -> AppM Unit
  , getState :: AppM AppState
  }

control :: AppEnv -> Msg -> AppM Unit
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

getBrowserWallets :: AppM (Array UnsupportedWallet)
getBrowserWallets = getBrowserWalletsImpl
  <#> map (\walletName -> { walletName })
  # liftEffect

getSupportedWallets
  :: Array UnsupportedWallet
  -> AppM
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

runAppM :: forall a. AppM a -> Aff (Either AppError a)
runAppM (AppM ma) = runExceptT ma

isWalletEnabled :: String -> AppM Boolean
isWalletEnabled str = isWalletEnabledImpl str
  # toAff
  # try
  <#> lmap (\_ -> ErrWalletNotFound str)
  # liftAff
  >>= liftEither

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

derive newtype instance Functor AppM
derive newtype instance Apply AppM
derive newtype instance Applicative AppM
derive newtype instance Bind AppM
derive newtype instance Monad AppM
derive newtype instance MonadAff AppM
derive newtype instance MonadEffect AppM
derive newtype instance MonadError AppError AppM
derive newtype instance MonadThrow AppError AppM

instance Show Wallet where
  show = genericShow

foreign import isWalletEnabledImpl :: String -> Promise Boolean

foreign import getBrowserWalletsImpl :: Effect (Array String)

