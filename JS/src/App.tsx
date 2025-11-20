import { AppRouter } from './app/router';
import { useSocket } from './hooks/useSocket';

function App() {
    useSocket(); // Initialize socket connection
    return (
        <AppRouter />
    );
}

export default App;
