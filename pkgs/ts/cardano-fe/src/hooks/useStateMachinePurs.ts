import { useState } from 'react';
import { controlMsg, initState, Msg, State } from '../state-machine';

type WrappedState = {
  state: State;
};

export const useStateMachine = (): [
  state: State,
  act: (msg: Msg) => Promise<void>,
] => {
  const [state, setState] = useState<WrappedState>({
    state: initState,
  });

  const forceUpdate = useForceUpdate();

  const act = async (msg: Msg) => {
    controlMsg(async updateState => {
      console.log(`Updating State: ${state.state.tag}`, state.state.value);
      state.state = updateState(state.state);
      forceUpdate();
      setState(state);
    })(async () => state.state)(msg);
  };

  return [state.state, act];
};

function useForceUpdate() {
  const [value, setValue] = useState(0); // integer state
  return () => setValue(value => value + 1); // update the state to force render
}
