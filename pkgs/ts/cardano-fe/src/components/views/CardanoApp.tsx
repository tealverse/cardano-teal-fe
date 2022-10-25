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
import { unMaybe } from '../../../core/Simple.Data.Maybe/index';
import { SortableTable } from '../SortableTable';
import { pairToTsTuple } from '../../pursTsInterop';
import { useInterval } from '../../hooks/useInterval';

type CardanoAppProps = {
  state: [Wallet, Page];
  act: (msg: Msg) => Promise<Either<AppError, void>>;
};

export const CardanoApp = ({ state, act }: CardanoAppProps) => {
  const [wallet, page] = state;

  useInterval(10000, () => {
    console.log('poll wallet sync');
    act(mkMsg.syncWallet);
  });

  useInterval(100000, () => {
    console.log('poll muesli ticker sync');
    act(mkMsg.getMuesliTicker);
  });

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
  const tableData = muesliTicker?.map(mt => {
    return {
      tradingFrom: pairToTsTuple(mt.tradingPair)[0],
      tradingTo: pairToTsTuple(mt.tradingPair)[1],
      lastPrice: pipe(
        mt.lastPrice,
        unMaybe({
          onJust: x => x,
          onNothing: () => 0,
        }),
      ),
      baseVolume: mt.baseVolume,
      priceChange: mt.priceChange,
    };
  });

  return (
    <SortableTable
      columns={[
        { label: 'From', selector: 'tradingFrom', sortable: false },
        { label: 'To', selector: 'tradingTo', sortable: false },
        { label: 'Price', selector: 'lastPrice', sortable: false },
        { label: 'Price Change', selector: 'priceChange', sortable: false },
        { label: 'Volume', selector: 'baseVolume', sortable: false },
      ]}
      data={tableData || []}
    />
  );
};
