import React, { useEffect } from 'react';
import { useStateMachine } from '../../../hooks/useStateMachine';
import { mkMsg, unState } from '../../../state-machine';
import { CenterTitle } from '../../text';
import { pipe } from 'fp-ts/lib/function';
import Button from '../../Button';
import { SupportedWallets } from '../../../types/supported-wallets';
import { css, styled } from 'twin.macro';

export const CardanoWallet = () => {
  const [state, act] = useStateMachine();

  useEffect(() => {
    act(mkMsg.mkGetAvailableWallets({}));
  }, []);

  return pipe(
    state,
    unState(null, {
      onLanding: st => (
        <div>
          <CenterTitle>Landing</CenterTitle>
          {Object.values(SupportedWallets).map(wallet => {
            return (
              <ButtonContainer key={wallet}>
                <Button
                  variant="primary"
                  disabled={!st.availableWallets.includes(wallet)}
                  onClick={() => {
                    if (window.cardano[wallet]) {
                      window.cardano.yoroi.enable().then(walletApi => {
                        console.log(walletApi);
                        console.log(walletApi.getBalance().then(console.log));
                        console.log(
                          walletApi.getChangeAddress().then(console.log),
                        );
                        wallet !== 'yoroi' &&
                          console.log(
                            walletApi.getCollateral().then(console.log),
                          );
                        console.log(walletApi.getNetworkId().then(console.log));
                        console.log(
                          walletApi.getRewardAddresses().then(console.log),
                        );
                        console.log(
                          walletApi.getUnusedAddresses().then(console.log),
                        );
                        console.log(
                          walletApi.getUsedAddresses().then(console.log),
                        );
                        console.log(walletApi.getUtxos().then(console.log));
                      });
                    }
                  }}
                >
                  Connect {wallet.toUpperCase()} Wallet
                </Button>
              </ButtonContainer>
            );
          })}
        </div>
      ),
      onApp: () => <h2>App</h2>,
    }),
  );
};

const ButtonContainer = styled.div(() => [
  css`
    margin: 1rem 0;
  `,
]);
