import tw, { css, styled } from 'twin.macro';
import { CardanoApp } from './components/views/CardanoApp';
import { Login } from './components/views/Login';
import { unAppState } from '~/CardanoFe.Main';
import { pipe } from 'fp-ts/lib/function';
import { useStateMachine } from './hooks/useStateMachine';
import { useEffect } from 'react';

const App = () => {
  const [state, act] = useStateMachine();

  useEffect(() => {
    console.log('Fresh state!');
  }, [state]);

  return (
    <AppLayout>
      {pipe(
        state,
        unAppState({
          onLogin: st => (
            <CenteredLayout gap={5}>
              <Login state={st} act={act} />
            </CenteredLayout>
          ),
          onApp: wallet => page => {
            console.log('render wallet');
            return <CardanoApp state={[wallet, page]} act={act} />;
          },
        }),
      )}
    </AppLayout>
  );
};

export default App;

type CenteredLayoutProps = {
  gap?: number;
};

export const CenteredLayout = styled.div<CenteredLayoutProps>(({ gap = 0 }) => [
  tw`flex flex-col items-center justify-center`,
  css`
    gap: ${gap}rem;
    min-height: 100vh;
  `,
]);

const AppLayout = styled.div(() => [
  tw`bg-gradient-to-b from-electric to-ribbon min-h-screen bg-fixed`,
  css`
    position: relative;
  `,
]);
