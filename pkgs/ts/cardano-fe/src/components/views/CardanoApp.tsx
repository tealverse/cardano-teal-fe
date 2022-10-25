import React, { useEffect } from 'react';
import { pipe } from 'fp-ts/lib/function';
import {
  AppError,
  AppState,
  mkMsg,
  Msg,
  Page,
  printAddress,
  printLovelace,
  printWallet,
  unPage,
  Wallet,
} from '~/CardanoFe.Main';
import * as _Maybe from '../../../core/Simple.Data.Maybe/index';
import { Either } from '~/Data.Either';
import { css, styled } from 'twin.macro';
import { CardanoLogo } from '../CardanoLogo';
import { CenteredLayout } from '../../App';
import { unRemoteReport } from '~/Data.RemoteReport';
import { printUtxoRaw } from '../../../core/CardanoFe.Main/index';
import { MuesliTicker } from '~/CardanoFe.Muesli';
import { unMaybe } from '../../../core/Simple.Data.Maybe/index.d';

type CardanoAppProps = {
  state: [Wallet, Page];
  act: (msg: Msg) => Promise<Either<AppError, void>>;
};

export const CardanoApp = ({ state, act }: CardanoAppProps) => {
  const [wallet, page] = state;

  useEffect(() => {
    console.log('init wallet sync');
    act(mkMsg.syncWallet);
  }, []);

  useEffect(() => {
    const walletPolling = setInterval(() => {
      console.log('poll wallet sync');
      act(mkMsg.syncWallet);
    }, 10000);

    return () => {
      console.log('clear wallet sync');
      clearInterval(walletPolling);
    };
  }, []);

  return (
    <AppLayout>
      {pipe(
        page,
        unPage({
          onPageDashboard: page => (
            <div>
              <WalletDetails>
                <pre>{printWallet(wallet.type)}</pre>
                <pre>
                  {pipe(
                    wallet.balance,
                    unRemoteReport({
                      onNotAsked: () => 'na',
                      onLoading: () => 'loading bal...',
                      onFailure: () => 'failed',
                      onSuccess: x => printLovelace(x.data),
                    }),
                  )}
                </pre>
                <pre>
                  {pipe(
                    wallet.unusedAddresses,
                    unRemoteReport({
                      onNotAsked: () => 'na',
                      onLoading: () => 'loading addrs...',
                      onFailure: () => 'failed',
                      onSuccess: x => {
                        const x0 = x.data[0];
                        if (!x0) return '[]';
                        return printAddress(x0).substring(0, 15);
                      },
                    }),
                  )}
                </pre>
                <pre>
                  {pipe(
                    wallet.utxos,
                    unRemoteReport({
                      onNotAsked: () => 'na',
                      onLoading: () => 'loading utxos...',
                      onFailure: () => 'failed',
                      onSuccess: x => {
                        const x0 = x.data[0];
                        if (!x0) return '[]';
                        return printUtxoRaw(x0).substring(0, 15);
                      },
                    }),
                  )}
                </pre>
              </WalletDetails>
              <CenteredLayout>
                <CardanoLogo size={20} />
                <MuesliTickerTable
                  muesliTicker={pipe(
                    page.muesliTicker,
                    unRemoteReport({
                      onNotAsked: () => undefined,
                      onLoading: x =>
                        pipe(
                          x.previousData,
                          unMaybe({
                            onJust: x => x,
                            onNothing: () => undefined,
                          }),
                        ),
                      onFailure: () => undefined,
                      onSuccess: x => x.data,
                    }),
                  )}
                />
              </CenteredLayout>
            </div>
          ),
          onPageSelectWallet: () => null,
        }),
      )}
    </AppLayout>
  );
};

const WalletDetails = styled.div(() => [
  css`
    position: absolute;
    top: 0;
    right: 0;
    padding: 1rem;
    width: 12rem;
  `,
]);

const AppLayout = styled.div(() => [
  css`
    position: relative;
  `,
]);

const MuesliTickerTable = ({
  muesliTicker,
}: {
  muesliTicker?: MuesliTicker;
}) => {
  return <div>muesli!!</div>;
};
