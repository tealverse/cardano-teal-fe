module CardanoFe.Modules where

import Prelude

import CardanoFe.Main as CardanoFe.Main
import Effect (Effect)
import TsBridge (TsProgram, tsModuleFile, tsProgram, tsTypeAlias)
import TsBridge.Cli (mkTypeGenCli)
import Type.Proxy (Proxy(..))

myTsProgram :: TsProgram
myTsProgram =
  tsProgram
    [ tsModuleFile "CardanoFe.Main/index"
        [ tsTypeAlias "WalletState" (Proxy :: _ CardanoFe.Main.WalletState) ]
    ]

main :: Effect Unit
main = mkTypeGenCli myTsProgram