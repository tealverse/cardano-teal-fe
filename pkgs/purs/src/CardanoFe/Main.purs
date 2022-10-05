module CardanoFe.Main where

import Prelude

import Control.Monad.Error.Class (class MonadThrow, liftEither, try)
import Control.Monad.Except (class MonadError, ExceptT, runExceptT)
import Control.Promise (Promise, toAffE)
import Data.Array (foldM)
import Data.Bifunctor (lmap)
import Data.DateTime.Instant (Instant)
import Data.Either (Either)
import Data.Generic.Rep (class Generic)
import Data.Int (decimal, toStringAs)
import Data.Maybe (Maybe(..))
import Data.RemoteReport (RemoteReport(..))
import Data.RemoteReport as RR
import Data.Show.Generic (genericShow)
import Data.String as Str
import Effect (Effect)
import Effect.Aff (Aff, Error)
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Now as I

--------------------------------------------------------------------------------
-- Wallet
--------------------------------------------------------------------------------

data WalletId
  = Yoroi
  | Eternl
  | Ccvault
  | Nami
  | Flint
  | Begin

type WalletApi =
  { getBalance :: AppM Lovelace
  , getUnusedAddresses :: AppM (Array Address)
  , getUtxos :: AppM (Array UtxoRaw)
  }

type WalletApiImpl =
  { getBalance :: Effect (Promise AdaRaw)
  , getUnusedAddresses :: Effect (Promise (Array String))
  , getUtxos :: Effect (Promise (Array UtxoRaw))
  }

convertWalletApi :: WalletApiImpl -> WalletApi
convertWalletApi wai =
  { getBalance:
      adaRawToLovelace <$> liftPromise (\_ -> ErrGetBalance) wai.getBalance
  , getUnusedAddresses:
      map Address <$> liftPromise (\_ -> ErrUnusedAddresses) wai.getUnusedAddresses
  , getUtxos:
      liftPromise (\_ -> ErrUtxos) wai.getUtxos
  }

parseWallet :: String -> Maybe WalletId
parseWallet = case _ of
  "yoroi" -> Just $ Yoroi
  "eternl" -> Just $ Eternl
  "ccvault" -> Just $ Ccvault
  "nami" -> Just $ Nami
  "flint" -> Just $ Flint
  "begin" -> Just $ Begin
  _ -> Nothing

printWallet :: WalletId -> String
printWallet = show >>> Str.toLower

printAddress :: Address -> String
printAddress (Address a) = a

printUtxoRaw :: UtxoRaw -> String
printUtxoRaw (UtxoRaw a) = a

printLovelace :: Lovelace -> String
printLovelace (Lovelace a) = toStringAs decimal a

type UnsupportedWallet =
  { walletName :: String
  }

type SupportedWallet =
  { wallet :: WalletId
  }

--------------------------------------------------------------------------------
-- Wallet
--------------------------------------------------------------------------------
type Wallet =
  { type :: WalletId
  , balance :: AppRemoteReport Lovelace
  , unusedAddresses :: AppRemoteReport (Array Address)
  , utxos :: AppRemoteReport (Array UtxoRaw)
  }

initWallet :: WalletId -> Wallet
initWallet w =
  { type: w
  , balance: NotAsked
  , unusedAddresses: NotAsked
  , utxos: NotAsked
  }

newtype Lovelace = Lovelace Int

newtype AdaRaw = AdaRaw String

newtype UtxoRaw = UtxoRaw String

foreign import adaRawToLovelace :: AdaRaw -> Lovelace

newtype Address = Address String

newtype Utxo = Utxo
  { from :: Address
  , to :: Address
  , amount :: Lovelace
  }

--------------------------------------------------------------------------------
-- AppError
--------------------------------------------------------------------------------

data AppError
  = ErrWalletNotFound String
  | ErrHttp
  | ErrUnknown
  | ErrLiteral String
  | ErrGetBalance
  | ErrUtxos
  | ErrUnusedAddresses
  | ErrGetWalletApi WalletId

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

data AppState
  = StLogin LoginState
  | StApp Wallet Page

type LoginState =
  { supportedWallets :: Array SupportedWallet
  , unsupportedWallets :: Array UnsupportedWallet
  , selectedWallet :: RemoteReport AppError Wallet
  }

unAppState :: { onLogin :: _, onApp :: _ } -> _
unAppState { onLogin, onApp } = case _ of
  StLogin x -> onLogin x
  StApp x1 x2 -> onApp x1 x2

initState :: AppState
initState = StLogin
  { supportedWallets: []
  , unsupportedWallets: []
  , selectedWallet: NotAsked
  }

--------------------------------------------------------------------------------
-- Message
--------------------------------------------------------------------------------

data Msg = MsgGetAvailableWallets | MsgSelectWallet WalletId | MsgSyncWallet

mkMsg :: { getAvailableWallets :: _, selectWallet :: _, syncWallet :: _ }
mkMsg =
  { getAvailableWallets: MsgGetAvailableWallets
  , selectWallet: MsgSelectWallet
  , syncWallet: MsgSyncWallet
  }

--------------------------------------------------------------------------------
-- Page
--------------------------------------------------------------------------------

data Page
  = PageDashboard
  | PageSelectWallet

unPage :: { onPageDashboard :: _, onPageSelectWallet :: _ } -> _
unPage { onPageDashboard, onPageSelectWallet } = case _ of
  PageDashboard -> onPageDashboard unit
  PageSelectWallet -> onPageSelectWallet unit

--------------------------------------------------------------------------------
-- App
--------------------------------------------------------------------------------

newtype AppM a = AppM (ExceptT AppError Aff a)

type AppEnv =
  { updateState :: (AppState -> AppState) -> AppM Unit
  , getState :: AppM AppState
  }

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
        _ <- subscibeRemoteReport
          ( \updateRemoteReport -> do
              updateState case _ of
                StLogin s -> StLogin s
                  { selectedWallet = updateRemoteReport s.selectedWallet
                  }
                st -> st
          )
          (getWalletApi w <#> \_ -> initWallet w)

        updateState case _ of
          StLogin _ -> StApp (initWallet w) PageDashboard
          st -> st

      StApp wallet _, MsgSyncWallet -> do
        api <- getWalletApi wallet.type

        _ <- subscibeRemoteReport
          ( \updateRemoteReport -> do
              updateState case _ of
                StApp s p -> StApp s { balance = updateRemoteReport s.balance } p
                st -> st
          )
          (api.getBalance)

        _ <- subscibeRemoteReport
          ( \updateRemoteReport -> do
              updateState case _ of
                StApp s p -> StApp s { unusedAddresses = updateRemoteReport s.unusedAddresses } p
                st -> st
          )
          (api.getUnusedAddresses)

        _ <- subscibeRemoteReport
          ( \updateRemoteReport -> do
              updateState case _ of
                StApp s p -> StApp s { utxos = updateRemoteReport s.utxos } p
                st -> st
          )
          (api.getUtxos)

        pure unit

      _, _ -> pure unit

getWalletApi :: WalletId -> AppM WalletApi
getWalletApi wallet = wallet
  # printWallet
  # getWalletApiImpl
  # pure
  # liftPromise (\_ -> ErrGetWalletApi wallet)
  <#> convertWalletApi

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
isWalletEnabled str = str
  # isWalletEnabledImpl
  # pure
  # liftPromise (\_ -> ErrWalletNotFound str)

--------------------------------------------------------------------------------
-- Util
--------------------------------------------------------------------------------

type AppRemoteReport = RemoteReport AppError

runAppM :: forall a. AppM a -> Aff (Either AppError a)
runAppM (AppM ma) = runExceptT ma

subscibeRemoteReport :: forall a. ((RemoteReport AppError a -> RemoteReport AppError a) -> AppM Unit) -> AppM a -> AppM Unit
subscibeRemoteReport = RR.subscibeRemoteReport now

now :: AppM Instant
now = liftEffect I.now

-- runAppMEffect :: forall a. AppM a -> Effect Unit
-- runAppMEffect (AppM ma) = runExceptT ma # launchAff_

liftPromise :: forall a. (Error -> AppError) -> Effect (Promise a) -> AppM a
liftPromise mapErr f = f
  # toAffE
  # try
  <#> lmap mapErr
  # liftAffAppM
  >>= liftEither

liftAffAppM :: forall a. Aff a -> AppM a
liftAffAppM = liftAff

liftEffectAppM :: forall a. Effect a -> AppM a
liftEffectAppM = liftEffect

--------------------------------------------------------------------------------
-- Instances
--------------------------------------------------------------------------------

derive newtype instance Functor AppM
derive newtype instance Apply AppM
derive newtype instance Applicative AppM
derive newtype instance Bind AppM
derive newtype instance Monad AppM
derive newtype instance MonadAff AppM
derive newtype instance MonadEffect AppM
derive newtype instance MonadError AppError AppM
derive newtype instance MonadThrow AppError AppM

derive instance Generic WalletId _
instance Show WalletId where
  show = genericShow

derive instance Generic Address _
instance Show Address where
  show = genericShow

--------------------------------------------------------------------------------
-- Foreign Imports
--------------------------------------------------------------------------------

foreign import isWalletEnabledImpl :: String -> Promise Boolean

foreign import getBrowserWalletsImpl :: Effect (Array String)

foreign import getWalletApiImpl :: String -> Promise WalletApiImpl

