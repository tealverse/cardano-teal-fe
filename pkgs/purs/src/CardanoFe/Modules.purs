module CardanoFe.Modules where

import Prelude

import CardanoFe.Main as CardanoFe.Main
import CardanoFe.Muesli as CardanoFe.Muesli
import CardanoFe.TsBridge (MappingToTsBridge(..))
import Control.Promise as Control.Promise
import Data.RemoteReport as Data.RemoteReport
import Effect (Effect)
import Simple.Data.Maybe as Simple.Data.Maybe
import Simple.Data.Pair as Simple.Data.Pair
import TsBridge (TsProgram, Var, tsModuleFile, tsOpaqueType, tsProgram, tsTypeAlias, tsValue)
import TsBridge.Cli (mkTypeGenCli)
import Type.Proxy (Proxy(..))

myTsProgram :: TsProgram
myTsProgram =
  tsProgram
    [ tsModuleFile "CardanoFe.Main/index"
        [ tsValue MP "control" CardanoFe.Main.control
        , tsValue MP "unAppState" (CardanoFe.Main.unAppState :: _ -> _ -> (Var "Z"))
        , tsValue MP "initState" CardanoFe.Main.initState
        , tsValue MP "initWallet" CardanoFe.Main.initWallet
        , tsValue MP "printWallet" CardanoFe.Main.printWallet
        , tsValue MP "printAddress" CardanoFe.Main.printAddress
        , tsValue MP "printUtxoRaw" CardanoFe.Main.printUtxoRaw
        , tsValue MP "printLovelace" CardanoFe.Main.printLovelace
        , tsValue MP "parseWallet" CardanoFe.Main.parseWallet
        , tsValue MP "getBrowserWallets" CardanoFe.Main.getBrowserWallets
        , tsValue MP "getSupportedWallets" CardanoFe.Main.getSupportedWallets
        , tsValue MP "isWalletEnabled" CardanoFe.Main.isWalletEnabled
        , tsValue MP "mkMsg" CardanoFe.Main.mkMsg
        , tsValue MP "runAppM" (CardanoFe.Main.runAppM :: _ (Var "A") -> _)
        , tsTypeAlias MP "Wallet" (Proxy :: _ CardanoFe.Main.Wallet)
        , tsTypeAlias MP "SupportedWallet" (Proxy :: _ CardanoFe.Main.SupportedWallet)
        , tsTypeAlias MP "LoginState" (Proxy :: _ CardanoFe.Main.LoginState)
        , tsValue MP "liftAffAppM" (CardanoFe.Main.liftAffAppM :: _ (Var "A") -> _)
        , tsValue MP "liftEffectAppM" (CardanoFe.Main.liftEffectAppM :: _ (Var "A") -> _)
        , tsValue MP "unPage" (CardanoFe.Main.unPage :: _ -> _ -> (Var "Z"))
        ]
    , tsModuleFile "Control.Promise/index"
        [ tsValue MP "fromAff" (Control.Promise.fromAff :: _ (Var "A") -> _)
        , tsValue MP "toAff" (Control.Promise.toAff :: _ (Var "A") -> _)
        ]
    , tsModuleFile "Simple.Data.Maybe/index"
        [ tsValue MP "unMaybe" (Simple.Data.Maybe.unMaybe :: _ -> _ (Var "A") -> (Var "C"))
        , tsValue MP "mkMaybe" (Simple.Data.Maybe.mkMaybe :: { mkJust :: (Var "A") -> _, mkNothing :: _ })
        ]
    , tsModuleFile "Simple.Data.Pair/index"
        [ tsValue MP "unPair" (Simple.Data.Pair.unPair :: _ -> _ (Var "A") -> (Var "C"))
        , tsValue MP "mkPair" (Simple.Data.Pair.mkPair :: _ -> _ -> _ (Var "A"))
        ]
    , tsModuleFile "Data.RemoteReport/index"
        [ tsValue MP "getData" (Data.RemoteReport.getData :: Data.RemoteReport.RemoteReport (Var "E") (Var "A") -> _)
        , tsValue MP "unRemoteReport" (Data.RemoteReport.unRemoteReport :: _ -> Data.RemoteReport.RemoteReport (Var "E") (Var "A") -> (Var "Z"))
        ]
    , tsModuleFile "CardanoFe.Muesli/index"
        [ tsOpaqueType MP "MuesliTicker" (Proxy :: _ CardanoFe.Muesli.MuesliTicker)

        ]
    ]

main :: Effect Unit
main = mkTypeGenCli myTsProgram