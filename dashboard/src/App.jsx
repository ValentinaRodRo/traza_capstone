import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import Sidebar from './components/layout/Sidebar';
import Login   from './pages/Login';
import Panel   from './pages/Panel';
import Detalle from './pages/Detalle';
import Mapa    from './pages/Mapa';
import Alertas from './pages/Alertas';
import Policial from './pages/Policial';
import BI      from './pages/BI';

function ProtectedLayout() {
  const { isAuthenticated } = useAuth();
  if (!isAuthenticated) return <Navigate to="/login" replace />;

  return (
    <div style={{ display: 'flex' }}>
      <Sidebar />
      <main style={{ marginLeft: 230, flex: 1, minHeight: '100vh', background: '#F5F7FC' }}>
        <Routes>
          <Route path="/"              element={<Panel />} />
          <Route path="/detalle/:id"   element={<Detalle />} />
          <Route path="/alertas"       element={<Alertas />} />
          <Route path="/mapa"          element={<Mapa />} />
          <Route path="/bi"            element={<BI />} />
          <Route path="/policial"      element={<Policial />} />
          <Route path="*"              element={<Navigate to="/" replace />} />
        </Routes>
      </main>
    </div>
  );
}

function AppRoutes() {
  const { isAuthenticated } = useAuth();
  return (
    <Routes>
      <Route
        path="/login"
        element={isAuthenticated ? <Navigate to="/" replace /> : <Login />}
      />
      <Route path="/*" element={<ProtectedLayout />} />
    </Routes>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <AppRoutes />
      </BrowserRouter>
    </AuthProvider>
  );
}
