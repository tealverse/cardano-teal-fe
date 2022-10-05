module CardanoFe.Modules where

import Prelude

import CardanoFe.Main as CardanoFe.Main
import CardanoFe.TsBridge (MappingToTsBridge(..))
import Control.Promise as Control.Promise
import Data.RemoteReport as Data.RemoteReport
import Effect (Effect)
import Simple.Data.Maybe as Simple.Data.Maybe
import TsBridge (A, C, E, TsProgram, Z, tsModuleFile, tsProgram, tsTypeAlias, tsValue)
import TsBridge.Cli (mkTypeGenCli)
import Type.Proxy (Proxy(..))

myTsProgram :: TsProgram
myTsProgram =
  tsProgram
    [ tsModuleFile "CardanoFe.Main/index"
        [ tsValue MP "control" CardanoFe.Main.control
        , tsValue MP "unAppState" (CardanoFe.Main.unAppState :: _ -> _ -> Z)
        , tsValue MP "initState" CardanoFe.Main.initState
        , tsValue MP "initWallet" CardanoFe.Main.initWallet
        , tsValue MP "printWallet" CardanoFe.Main.printWallet
        , tsValue MP "parseWallet" CardanoFe.Main.parseWallet
        , tsValue MP "getBrowserWallets" CardanoFe.Main.getBrowserWallets
        , tsValue MP "getSupportedWallets" CardanoFe.Main.getSupportedWallets
        , tsValue MP "isWalletEnabled" CardanoFe.Main.isWalletEnabled
        , tsValue MP "mkMsg" CardanoFe.Main.mkMsg
        , tsValue MP "runAppM" (CardanoFe.Main.runAppM :: _ A -> _)
        , tsTypeAlias MP "Wallet" (Proxy :: _ CardanoFe.Main.Wallet)
        , tsTypeAlias MP "SupportedWallet" (Proxy :: _ CardanoFe.Main.SupportedWallet)
        , tsTypeAlias MP "LoginState" (Proxy :: _ CardanoFe.Main.LoginState)
        , tsValue MP "liftAffAppM" (CardanoFe.Main.liftAffAppM :: _ A -> _)
        , tsValue MP "liftEffectAppM" (CardanoFe.Main.liftEffectAppM :: _ A -> _)
        , tsValue MP "unPage" (CardanoFe.Main.unPage :: _ -> _ -> Z)
        ]
    , tsModuleFile "Control.Promise/index"
        [ tsValue MP "fromAff" (Control.Promise.fromAff :: _ A -> _)
        , tsValue MP "toAff" (Control.Promise.toAff :: _ A -> _)
        ]
    , tsModuleFile "Simple.Data.Maybe/index"
        [ tsValue MP "unMaybe" (Simple.Data.Maybe.unMaybe :: _ -> _ A -> C)
        , tsValue MP "mkMaybe" (Simple.Data.Maybe.mkMaybe :: { mkJust :: A -> _, mkNothing :: _ })
        ]
    , tsModuleFile "Data.RemoteReport/index"
        [ tsValue MP "getData" (Data.RemoteReport.getData :: Data.RemoteReport.RemoteReport E A -> _)
        , tsValue MP "unRemoteReport" (Data.RemoteReport.unRemoteReport :: _ -> Data.RemoteReport.RemoteReport E A -> Z)
        ]
    ]

main :: Effect Unit
main = mkTypeGenCli myTsProgram