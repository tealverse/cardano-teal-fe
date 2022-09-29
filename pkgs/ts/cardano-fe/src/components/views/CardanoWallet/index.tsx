import React, { useEffect } from 'react';
import { useStateMachine } from '../../../hooks/useStateMachine';
import { mkMsg, unState } from '../../../state-machine';
import { CenterTitle } from '../../text';
import { pipe } from 'fp-ts/lib/function';
import Button from '../../Button';
import { SupportedWallets } from '../../../types/supported-wallets';
import { css, styled } from 'twin.macro';

export const CardanoWallet = () => {
  // return pipe(
  //   state,
  //   unState(null, {
  //     onLanding: st => (
  //       <div>
  //         <CenterTitle>Landing</CenterTitle>
  //       </div>
  //     ),
  //     onApp: () => <h2>App</h2>,
  //   }),
  // );
};

const ButtonContainer = styled.div(() => [
  css`
    margin: 1rem 0;
  `,
]);
