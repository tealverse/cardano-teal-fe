import React from 'react';
import { useStateMachine } from '../../../hooks/useStateMachinePurs';
import { CenterTitle } from '../../text';
import { pipe } from 'fp-ts/lib/function';
import { css, styled } from 'twin.macro';
import { unAppState } from '~/CardanoFe.Main';
import { Login } from '../Login';

export const CardanoWallet = () => {
  const [state, act] = useStateMachine();

  return pipe(
    state,
    unAppState({
      onLogin: st => <Login state={st} act={act} />,
      onApp: st => page => <h2>App</h2>,
    }),
  );
};

const ButtonContainer = styled.div(() => [
  css`
    margin: 1rem 0;
  `,
]);
