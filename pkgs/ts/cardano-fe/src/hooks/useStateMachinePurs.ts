import { useState } from 'react';
import { AppState, control, initState, Msg, runAppM } from '~/CardanoFe.Main';
import { pipe } from 'fp-ts/lib/function';
import { fromAff } from '~/Control.Promise';

type WrappedState = {
  state: AppState;
};

export const useStateMachine = (): [
  state: AppState,
  act: (msg: Msg) => Promise<void>,
] => {
  const [state, setState] = useState<WrappedState>({
    state: initState,
  });

  const forceUpdate = useForceUpdate();

  const act = async (msg: Msg) => {
    const controlMsg = control({
      updateState: () => {
        // console.log(`Updating State: ${state.state.tag}`, state.state.value);
        // state.state = updateState(state.state);
        // forceUpdate();
        // setState(state);
      },
      getState: () => {},
    })(msg);

    const promise = pipe(controlMsg, runAppM, fromAff)();
  };

  return [state.state, act];
};

function useForceUpdate() {
  const [value, setValue] = useState(0);
  return () => setValue(value => value + 1);
}
