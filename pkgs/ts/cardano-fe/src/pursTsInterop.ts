import { Pair } from '~/Data.Pair';
import { mkPair, unPair } from '~/Simple.Data.Pair';
import { pipe } from 'fp-ts/lib/function';
import { Maybe } from '~/Data.Maybe';
import { mkMaybe, unMaybe } from '~/Simple.Data.Maybe';

export const pairToTsTuple = <A>(pair: Pair<A>): [A, A] =>
  pipe(
    pair,
    unPair(id1 => id2 => [id1, id2]),
  );

export const tsTupleToPair = <A>([x1, x2]: [A, A]): Pair<A> => mkPair(x1)(x2)

// export const tsTupleToTuple = <A,B>([x1,x2] : [A,B]): Tuple<A,B> => mkTuple(x1)(x2)
// export const tupleToTsTuple = <A,B>(x : Tuple<A,B> ): [A,B] => mkTuple(x1)(x2)


export const maybeToTs = <A>(x: Maybe<A>): A | undefined => pipe(x, unMaybe({
  onJust: (x) => x,
  onNothing: () => undefined
}))

export const tsToMaybe = <A>(x: undefined | A): Maybe<A> => {
  if (typeof x === "undefined") return mkMaybe.mkNothing()
  return mkMaybe.mkJust(x)
}

