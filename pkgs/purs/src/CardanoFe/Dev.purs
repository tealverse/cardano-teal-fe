module CardanoFe.Dev where

import Prelude

import Affjax.Node as AN
import CardanoFe.AppDebug (appDebug)
import CardanoFe.Muesli (getMuesliTicker)
import Effect (Effect)
import Effect.Aff (runAff_)
import Effect.Console (log)

runMuesliTicker ∷ Effect Unit
runMuesliTicker = runAff_ (appDebug >>> log) (getMuesliTicker AN.driver)