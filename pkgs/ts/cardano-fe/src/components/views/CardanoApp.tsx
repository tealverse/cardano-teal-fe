import React, { useEffect } from 'react';
import { pipe } from 'fp-ts/lib/function';
import {
  AppError,
  AppState,
  mkMsg,
  Msg,
  Page,
  printWallet,
  unPage,
  Wallet,
} from '~/CardanoFe.Main';
import * as _Maybe from '../../../core/Simple.Data.Maybe/index';
import { Either } from '~/Data.Either';
import { css, styled } from 'twin.macro';
import { CardanoLogo } from '../CardanoLogo';
import { CenteredLayout } from '../../App';

type CardanoAppProps = {
  state: [Wallet, Page];
  act: (msg: Msg) => Promise<Either<AppError, void>>;
};

export const CardanoApp = ({ state, act }: CardanoAppProps) => {
  const [wallet, page] = state;

  useEffect(() => {
    act(mkMsg.syncWallet)
  }, [wallet])

  return (
    <AppLayout>
      {pipe(
        page,
        unPage({
          onPageDashboard: () => (
            <div>
              <WalletDetails>
                <pre>{printWallet(wallet.type)}</pre>
              </WalletDetails>
              <CenteredLayout>
                <CardanoLogo size={20} />
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
  `,
]);

const AppLayout = styled.div(() => [
  css`
    position: relative;
  `,
]);
