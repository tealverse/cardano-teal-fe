import { Pair } from '~/Data.Pair';
import { unPair } from '~/Simple.Data.Pair';
import { pipe } from 'fp-ts/lib/function';

export const pairToTsTuple = <A>(pair: Pair<A>): [A, A] =>
  pipe(
    pair,
    unPair(id1 => id2 => [id1, id2]),
  );
