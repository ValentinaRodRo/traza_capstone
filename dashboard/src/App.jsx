// src/App.jsx
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Sidebar from './components/layout/Sidebar';
import Panel    from './pages/Panel';
import Detalle  from './pages/Detalle';
import Mapa     from './pages/Mapa';
import Alertas  from './pages/Alertas';
import Policial from './pages/Policial';

export default function App() {
  return (
    <BrowserRouter>
      <div style={{ display: 'flex' }}>
        <Sidebar />
        <main style={{ marginLeft: 220, flex: 1, minHeight: '100vh' }}>
          <Routes>
            <Route path="/"              element={<Panel />} />
            <Route path="/detalle/:id"   element={<Detalle />} />
            <Route path="/alertas"       element={<Alertas />} />
            <Route path="/mapa"          element={<Mapa />} />
            <Route path="/policial"      element={<Policial />} />
          </Routes>
        </main>
      </div>
    </BrowserRouter>
  );
}