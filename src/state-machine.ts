import { pipe } from 'fp-ts/lib/function';

export type Tagged<K, V> = { tag: K; value: V };

export const tagged = <K, V>(k: K, v: V): Tagged<K, V> => ({
  tag: k,
  value: v,
});

type PayloadOfState<K> = Extract<State, { tag: K }>['value'];
type PayloadOfMsg<K> = Extract<Msg, { tag: K }>['value'];

export const mkState = {
  mkLanding: (x: PayloadOfState<'Landing'>): State => tagged('Landing', x),
  mkApp: (x: PayloadOfState<'App'>): State => tagged('App', x),
};

export const mkMsg = {
  mkGetAvailableWallets: (x: PayloadOfMsg<'GetAvailableWallets'>): Msg =>
    tagged('GetAvailableWallets', x),
  mkSomeOtherAction: (x: PayloadOfMsg<'SomeOtherAction'>): Msg =>
    tagged('SomeOtherAction', x),
};

export const unState =
  <Z>(
    def: Z,
    cases: {
      onLanding?: (x: PayloadOfState<'Landing'>) => Z;
      onApp?: (x: PayloadOfState<'App'>) => Z;
    },
  ) =>
  (state: State): Z => {
    switch (state.tag) {
      case 'Landing':
        return cases.onLanding ? cases.onLanding(state.value) : def;
      case 'App':
        return cases.onApp ? cases.onApp(state.value) : def;
    }
  };

export const unMsg =
  <Z>(
    def: Z,
    cases: {
      onGetAvailableWallets?: (x: PayloadOfMsg<'GetAvailableWallets'>) => Z;
      onSomeOtherAction?: (x: PayloadOfMsg<'SomeOtherAction'>) => Z;
    },
  ) =>
  (msg: Msg): Z => {
    switch (msg.tag) {
      case 'GetAvailableWallets':
        return cases.onGetAvailableWallets
          ? cases.onGetAvailableWallets(msg.value)
          : def;
      case 'SomeOtherAction':
        return cases.onSomeOtherAction
          ? cases.onSomeOtherAction(msg.value)
          : def;
    }
  };

export type State =
  | Tagged<'Landing', { availableWallets: string[] }>
  | Tagged<'App', {}>;

export const initState = mkState.mkLanding({ availableWallets: [] });

export type Msg =
  | Tagged<'GetAvailableWallets', {}>
  | Tagged<'SomeOtherAction', {}>;

export const controlMsg =
  (updateState: (updateFn: (prev: State) => State) => Promise<void>) =>
  (getState: () => Promise<State>) =>
  async (msg: Msg): Promise<void> => {
    const currentState = await getState();

    pipe(
      currentState,
      unState(undefined, {
        onLanding: () => {
          pipe(
            msg,
            unMsg(undefined, {
              onGetAvailableWallets: async () => {
                if (window?.cardano && typeof window.cardano === 'object') {
                  const walletIds = Object.keys(window.cardano);
                  await updateState((prevState: State) =>
                    pipe(
                      prevState,
                      unState(prevState, {
                        onLanding: st =>
                          mkState.mkLanding({
                            ...st,
                            availableWallets: walletIds,
                          }),
                      }),
                    ),
                  );
                }
              },
            }),
          );
        },

        onApp: () => {
          pipe(
            msg,
            unMsg(undefined, {
              onGetAvailableWallets: async () => {},
              onSomeOtherAction: async () => {},
            }),
          );
        },
      }),
    );
  };
