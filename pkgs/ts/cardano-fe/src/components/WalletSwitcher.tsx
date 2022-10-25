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
      <Label>{printWallet(wallet)}</Label>
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

const Label = styled.h2(() => [
  css`
    font-size: 1.75rem;
  `,
]);
