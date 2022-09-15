import { css, styled } from 'twin.macro';
import Button from '../../Button';
import { CenterTitle } from '../../text';

export const NotConnected = () => {
  console.log(window.cardano);

  return (
    <>
      <CenterTitle>Your Cardano Wallet</CenterTitle>
      <Button
        variant="primary"
        onClick={() => {
          if (window.cardano.yoroi) {
            window.cardano.yoroi.enable().then(wallet => {
              console.log(wallet);
              console.log(wallet.getBalance().then(console.log));
              console.log(wallet.getChangeAddress().then(console.log));
              // console.log(wallet.getCollateral().then(console.log));
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
          if (window.cardano.eternl) {
            window.cardano.eternl.enable().then(wallet => {
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
