import { useState } from 'react';
import {
  AppState,
  control,
  initState,
  Msg,
  runAppM,
  liftAffAppM,
  AppM,
  AppError,
} from '~/CardanoFe.Main';
import { pipe } from 'fp-ts/lib/function';
import { fromAff, toAff } from '~/Control.Promise';
import { Either } from '~/Data.Either';

type WrappedState = {
  state: AppState;
};

const promiseToAppM = <A>(p: Promise<A>) => pipe(p, toAff, liftAffAppM);

const appMToPromise = <A>(appM: AppM<A>) => pipe(appM, runAppM, fromAff);

export const useStateMachine = (): [
  state: AppState,
  act: (msg: Msg) => Promise<Either<AppError, void>>,
] => {
  const [state] = useState<WrappedState>({
    state: initState,
  });

  const forceUpdate = useForceUpdate();

  const act = (msg: Msg) =>
    appMToPromise(
      control({
        updateState: updateState =>
          promiseToAppM(
            new Promise(() => {
              state.state = updateState(state.state);
              forceUpdate();
            }),
          ),
        getState: promiseToAppM(new Promise(() => state.state)),
      })(msg),
    )();

  return [state.state, act];
};

function useForceUpdate() {
  const [, setValue] = useState(0);
  return () => setValue(value => value + 1);
}
