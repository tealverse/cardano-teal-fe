import { ReactElement, useEffect } from 'react';
import {
  AppError,
  AppState,
  Msg,
  mkMsg,
  LoginState,
  printWallet,
  Wallet,
} from '~/CardanoFe.Main';
import { CenterTitle } from '../text';
import { Either } from '~/Data.Either';
import Button from '../Button';
import { css, styled } from 'twin.macro';
import * as _Maybe from '../../../core/Simple.Data.Maybe/index';
import { pipe } from 'fp-ts/lib/function';

type LoginProps = {
  state: LoginState;
  act: (msg: Msg) => Promise<Either<AppError, void>>;
};

export const Login = (props: LoginProps): ReactElement => {
  const { state, act } = props;

  useEffect(() => {
    act(mkMsg.getAvailableWallets);
  }, []);

  return (
    <div>
      <CenterTitle>Landing</CenterTitle>
      {state.supportedWallets.map(w => (
        <WalletSelector
          wallet={w.wallet}
          key={printWallet(w.wallet)}
          {...props}
        />
      ))}
    </div>
  );
};

type WalletSelectorProps = {
  wallet: Wallet;
} & LoginProps;

export const WalletSelector = ({ wallet, act }: WalletSelectorProps) => {
  return (
    <SelectorRow>
      <h2>{printWallet(wallet)}</h2>
      <div>
        <Button
          variant="primary"
          onClick={() => act(mkMsg.selectWallet(wallet))}
        >
          Enable
        </Button>
      </div>
    </SelectorRow>
  );
};

const SelectorRow = styled.div(() => [
  css`
    display: flex;
    width: 15rem;
    justify-content: space-between;
  `,
]);
