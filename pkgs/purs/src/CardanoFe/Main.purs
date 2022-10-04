module CardanoFe.Main where

import Prelude

import CardanoFe.TsBridge (class ToTsBridge, MappingToTsBridge(..))
import Control.Monad.Error.Class (class MonadThrow, liftEither, try)
import Control.Monad.Except (class MonadError, ExceptT, runExceptT)
import Control.Promise (Promise, toAff, toAffE)
import Data.Array (foldM)
import Data.Bifunctor (lmap)
import Data.Either (Either)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Show.Generic (genericShow)
import Data.String as Str
import Data.Typelevel.Undefined (undefined)
import Effect (Effect)
import Effect.Aff (Aff, Error)
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Console (log)
import TsBridge (tsOpaqueType, tsOpaqueType1)

moduleName :: String
moduleName = "CardanoFe.Main"

data Wallet
  = Yoroi
  | Eternl
  | Ccvault
  | Nami
  | Flint
  | Begin

type WalletApi =
  { getBalance :: AppM String
  }

type WalletApiImpl =
  { getBalance :: Effect (Promise String)
  }

convertWalletApi :: WalletApiImpl -> WalletApi
convertWalletApi wai = { getBalance: liftPromise wai.getBalance mapError }

mapError :: Error -> AppError
mapError = undefined

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
  }

newtype Balance = Balance Int

newtype Address = Address String

newtype Utxo = Utxo
  { from :: Address
  , to :: Address
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
  = PageDashboard
  | PageSelectWallet

data AppState
  = StLogin LoginState
  | StApp WalletState Page

type LoginState =
  { supportedWallets :: Array SupportedWallet
  , unsupportedWallets :: Array UnsupportedWallet
  , selectedWallet :: Maybe WalletState
  }

newtype AppM a = AppM (ExceptT AppError Aff a)

unAppState :: { onLogin :: _, onApp :: _ } -> _
unAppState { onLogin, onApp } = case _ of
  StLogin x -> onLogin x
  StApp x1 x2 -> onApp x1 x2

initState :: AppState
initState = StLogin
  { supportedWallets: []
  , unsupportedWallets: []
  , selectedWallet: Nothing
  }

data Msg = MsgGetAvailableWallets | MsgSelectWallet Wallet

type AppEnv =
  { updateState :: (AppState -> AppState) -> AppM Unit
  , getState :: AppM AppState
  }

mkMsg :: { getAvailableWallets :: _, selectWallet :: _ }
mkMsg = { getAvailableWallets: MsgGetAvailableWallets, selectWallet: MsgSelectWallet }

control :: AppEnv -> Msg -> AppM Unit
control { updateState, getState } msg =
  do
    state <- getState

    case state, msg of
      StLogin _, MsgGetAvailableWallets -> do
        browserWallets <- getBrowserWallets
        result <- getSupportedWallets browserWallets
        updateState case _ of
          StLogin ls -> StLogin ls
            { supportedWallets = result.supportedWallets
            , unsupportedWallets = result.unsupportedWallets
            }
          st -> st

      StLogin _, MsgSelectWallet w -> do
        updateState case _ of
          StLogin ls -> StLogin ls
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
      Just wallet -> pure $ accum { supportedWallets = accum.supportedWallets <> [ { wallet } ] }

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

runAppM :: forall a. AppM a -> Aff (Either AppError a)
runAppM (AppM ma) = runExceptT ma

liftPromise :: forall a. Effect (Promise a) -> (Error -> AppError) -> AppM a
liftPromise f mapErr = f
  # toAffE
  # try
  <#> lmap mapErr
  # liftAffAppM
  >>= liftEither

liftAffAppM :: forall a. Aff a -> AppM a
liftAffAppM = liftAff

--

instance ToTsBridge Wallet where
  toTsBridge = tsOpaqueType moduleName "Wallet"

instance ToTsBridge Balance where
  toTsBridge = tsOpaqueType moduleName "Balance"

instance ToTsBridge Address where
  toTsBridge = tsOpaqueType moduleName "Address"

instance ToTsBridge Utxo where
  toTsBridge = tsOpaqueType moduleName "Utxo"

instance ToTsBridge AppState where
  toTsBridge = tsOpaqueType moduleName "AppState"

instance ToTsBridge Page where
  toTsBridge = tsOpaqueType moduleName "Page"

instance ToTsBridge Msg where
  toTsBridge = tsOpaqueType moduleName "Msg"

instance ToTsBridge a => ToTsBridge (AppM a) where
  toTsBridge = tsOpaqueType1 MP moduleName "AppM" "A"

instance ToTsBridge AppError where
  toTsBridge = tsOpaqueType moduleName "AppError"

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

foreign import getWalletApiImpl :: String -> Promise WalletApiImpl