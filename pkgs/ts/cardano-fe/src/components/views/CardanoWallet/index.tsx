import React from 'react';
import { useStateMachine } from '../../../hooks/useStateMachinePurs';
import { pipe } from 'fp-ts/lib/function';
import { css, styled } from 'twin.macro';
import { unAppState } from '~/CardanoFe.Main';
import { Login } from '../Login';
import { CardanoApp } from '../CardanoApp';

export const CardanoWallet = () => {
  const [state, act] = useStateMachine();

  return pipe(
    state,
    unAppState({
      onLogin: st => <Login state={st} act={act} />,
      onApp: wallet => page => <CardanoApp state={[wallet, page]} act={act} />,
    }),
  );
};
