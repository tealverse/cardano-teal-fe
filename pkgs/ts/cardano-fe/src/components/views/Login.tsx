import React, { ReactElement, useEffect } from 'react';
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
import { unRemoteReport } from '~/Data.RemoteReport';
import { WalletSwitcher } from '../WalletSwitcher';

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
      <WalletSwitcher
        supportedWallets={state.supportedWallets}
        selectWallet={w => act(mkMsg.selectWallet(w))}
      />
      <>
        {unRemoteReport({
          onNotAsked: () => 'notAsked',
          onLoading: () => 'loading',
          onFailure: () => 'failure',
          onSuccess: () => 'success',
        })(state.selectedWallet)}
      </>
    </div>
  );
};
