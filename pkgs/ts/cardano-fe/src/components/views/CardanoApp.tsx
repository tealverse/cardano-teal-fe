import { pipe } from 'fp-ts/lib/function';
import {
  AppError,
  AppState,
  Msg,
  Page,
  printWallet,
  unPage,
  WalletState,
} from '~/CardanoFe.Main';
import * as _Maybe from '../../../core/Simple.Data.Maybe/index';
import { Either } from '~/Data.Either';

type CardanoAppProps = {
  state: [WalletState, Page];
  act: (msg: Msg) => Promise<Either<AppError, void>>;
};

export const CardanoApp = ({ state, act }: CardanoAppProps) => {
  const [wallet, page] = state;

  return pipe(
    page,
    unPage({
      onPageDashboard: () => <pre>{printWallet(wallet.type)}</pre>,
      onPageSelectWallet: () => null,
    }),
  );
};
