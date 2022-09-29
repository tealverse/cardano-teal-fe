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
                    window.cardano[wallet].enable().then(walletApi => {
                      console.log(walletApi);

                      console.log(
                        walletApi
                          .getBalance()
                          .then(x => console.log('getBalance', x)),
                      );
                      console.log(
                        walletApi
                          .getChangeAddress()
                          .then(x => console.log('getChangeAddress', x)),
                      );
                      wallet !== 'yoroi' &&
                        console.log(
                          walletApi
                            .getCollateral()
                            .then(x => console.log('getCollateral', x)),
                        );
                      console.log(walletApi.getNetworkId().then(console.log));
                      console.log(
                        walletApi
                          .getRewardAddresses()
                          .then(x => console.log('getRewardAddresses', x)),
                      );
                      console.log(
                        walletApi
                          .getUnusedAddresses()
                          .then(x => console.log('getUnusedAddresses', x)),
                      );
                      console.log(
                        walletApi
                          .getUsedAddresses()
                          .then(x => console.log('getUsedAddresses', x)),
                      );
                      console.log(
                        walletApi
                          .getUtxos()
                          .then(x => console.log('getUtxos', x)),
                      );
                    });
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
