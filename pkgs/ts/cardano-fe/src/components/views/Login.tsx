import { ReactElement, useEffect } from 'react';
import {
  AppError,
  AppState,
  Msg,
  mkMsg,
  LoginState,
  printWallet,
} from '~/CardanoFe.Main';
import { CenterTitle } from '../text';
import { Either } from '~/Data.Either';

type LoginProps = {
  state: LoginState;
  act: (msg: Msg) => Promise<Either<AppError, void>>;
};

export const Login = ({ state, act }: LoginProps): ReactElement => {
  useEffect(() => {
    act(mkMsg.getAvailableWallets);
  }, []);

  console.log(state);

  return (
    <div>
      <CenterTitle>Landing</CenterTitle>
      {state.supportedWallets.map(wallet => (
        <div>
          <h2>{printWallet(wallet.wallet)}</h2>
        </div>
      ))}
    </div>
  );
};
