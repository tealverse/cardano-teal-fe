import React, { useEffect } from 'react';
import { useStateMachine } from '../../../hooks/useStateMachine';
import { mkMsg, unState } from '../../../state-machine';
import { CenterTitle } from '../../text';
import { pipe } from 'fp-ts/lib/function';

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
          <h2>Landing</h2>
          {JSON.stringify(st.availableWallets, null, 2)}
        </div>
      ),
      onApp: () => <h2>App</h2>,
    }),
  );

  return (
    <>
      <CenterTitle>Cardano Wallet</CenterTitle>
    </>
  );
};
