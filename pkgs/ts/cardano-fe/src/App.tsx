import tw, { styled } from 'twin.macro';
import { CardanoApp } from './components/views/CardanoApp';
import { Login } from './components/views/Login';
import { unAppState } from '~/CardanoFe.Main';
import { pipe } from 'fp-ts/lib/function';
import { useStateMachine } from './hooks/useStateMachine';

const App = () => {
  const [state, act] = useStateMachine();

  return (
    <div tw="bg-gradient-to-b from-electric to-ribbon h-screen">
      {pipe(
        state,
        unAppState({
          onLogin: st => (
            <CenteredLayout>
              <Login state={st} act={act} />
            </CenteredLayout>
          ),
          onApp: wallet => page =>
            <CardanoApp state={[wallet, page]} act={act} />,
        }),
      )}
    </div>
  );
};

export default App;

export const CenteredLayout = styled.div(() => [
  tw`flex flex-col items-center justify-center h-screen`,
]);
