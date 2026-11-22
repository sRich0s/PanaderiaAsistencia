import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import Tableta from './pages/Tableta.jsx';
import Login from './pages/Login.jsx';
import PanelAsistencia from './pages/PanelAsistencia.jsx';

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/tableta" element={<Tableta />} />
        <Route path="/login" element={<Login />} />
        <Route path="/panel" element={<PanelAsistencia />} />
        <Route path="*" element={<Navigate to="/login" replace />} />
      </Routes>
    </BrowserRouter>
  );
}
