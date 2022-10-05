import React from 'react';
import { css, styled } from 'twin.macro';
import {
  AppError,
  mkMsg,
  Msg,
  printWallet,
  SupportedWallet,
} from '~/CardanoFe.Main';
import { WalletId } from '~/CardanoFe.Main';
import { Either } from '~/Data.Either';
import Button from './Button';

type WalletSwitcherProps = {
  supportedWallets: Array<SupportedWallet>;
  selectWallet: (w: WalletId) => void;
};

export const WalletSwitcher = ({
  supportedWallets,
  selectWallet,
}: WalletSwitcherProps) => (
  <>
    {supportedWallets.map(w => (
      <WalletSelector
        wallet={w.wallet}
        selectWallet={selectWallet}
        key={printWallet(w.wallet)}
      />
    ))}
  </>
);

type WalletSelectorProps = {
  wallet: WalletId;
  selectWallet: (w: WalletId) => void;
};

export const WalletSelector = ({
  wallet,
  selectWallet,
}: WalletSelectorProps) => {
  return (
    <SelectorRow>
      <h2>{printWallet(wallet)}</h2>
      <div>
        <Button variant="primary" onClick={() => selectWallet(wallet)}>
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
