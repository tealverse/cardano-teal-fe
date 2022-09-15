import React from 'react';
import { WalletApi } from '../types/cip-30';
import Button from './Button';

export const CardanoWallet = () => {
  console.log((window as any).cardano);

  return (
    <>
      <h2>Your Cardano Wallet</h2>
      <Button
        variant="primary"
        onClick={() => {
          if ((window as any).cardano.yoroi) {
            (window as any).cardano.yoroi.enable().then((wallet: WalletApi) => {
              console.log(wallet);
              console.log(wallet.getBalance().then(console.log));
              console.log(wallet.getChangeAddress().then(console.log));
              console.log(wallet.getNetworkId().then(console.log));
              console.log(wallet.getRewardAddresses().then(console.log));
              console.log(wallet.getUnusedAddresses().then(console.log));
              console.log(wallet.getUsedAddresses().then(console.log));
              console.log(wallet.getUtxos().then(console.log));
            });
          }
        }}
      >
        Connect Yoroi Wallet
      </Button>

      <Button
        variant="primary"
        onClick={() => {
          if ((window as any).cardano.eternl) {
            (window as any).cardano.eternl
              .enable()
              .then((wallet: WalletApi) => {
                console.log(wallet);
                console.log(wallet.getBalance().then(console.log));
                console.log(wallet.getChangeAddress().then(console.log));
                console.log(wallet.getCollateral().then(console.log));
                console.log(wallet.getNetworkId().then(console.log));
                console.log(wallet.getRewardAddresses().then(console.log));
                console.log(wallet.getUnusedAddresses().then(console.log));
                console.log(wallet.getUsedAddresses().then(console.log));
                console.log(wallet.getUtxos().then(console.log));
              });
          }
        }}
      >
        Connect Eternl Wallet
      </Button>
    </>
  );
};
