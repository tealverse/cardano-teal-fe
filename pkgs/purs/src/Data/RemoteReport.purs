module Data.RemoteReport
  ( RemoteReport(..)
  , getData
  , subscibeRemoteReport
  , unRemoteReport
  ) where

import Prelude

import Control.Monad.Error.Class (class MonadError, catchError)
import Data.DateTime.Instant (Instant)
import Data.Maybe (Maybe(..))

data RemoteReport e a
  = NotAsked
  | Loading
      { timestamp :: Instant
      , previousData :: Maybe a
      }
  | Failure
      { error :: e
      , timestamp :: Instant
      , previousData :: Maybe a
      }
  | Success
      { data :: a
      , previousData :: Maybe a
      , timestamp :: Instant
      }

derive instance Functor (RemoteReport e)

unRemoteReport :: { onNotAsked :: _, onLoading :: _, onFailure :: _, onSuccess :: _ } -> _
unRemoteReport c = case _ of
  NotAsked -> c.onNotAsked unit
  Loading x -> c.onLoading x
  Failure x -> c.onFailure x
  Success x -> c.onSuccess x

getData :: forall e a. RemoteReport e a -> Maybe a
getData = case _ of
  NotAsked -> Nothing
  Loading { previousData } -> previousData
  Failure { previousData } -> previousData
  Success { data: data_ } -> Just data_

subscibeRemoteReport :: forall e a m. MonadError e m => m Instant -> ((RemoteReport e a -> RemoteReport e a) -> m Unit) -> m a -> m Unit
subscibeRemoteReport getTime onRemoteReportEvent effectComputation = do
  timeOnLoading <- getTime
  onRemoteReportEvent (\rp -> Loading { timestamp: timeOnLoading, previousData: getData rp })
  ( do
      timeOnSuccess <- getTime
      x <- effectComputation
      onRemoteReportEvent (\rp -> Success { data: x, previousData: getData rp, timestamp: timeOnSuccess })
  ) `catchError`
    ( \error -> do
        timeOnFailure <- getTime
        onRemoteReportEvent (\rp -> Failure { error, timestamp: timeOnFailure, previousData: getData rp })
    )