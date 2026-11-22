import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../api.js';

export default function Login() {
  const [usuario, setUsuario] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [busy, setBusy] = useState(false);
  const nav = useNavigate();

  const entrar = async (ev) => {
    ev.preventDefault();
    setError('');
    setBusy(true);
    try {
      const r = await api('/auth/login', { method: 'POST', body: { usuario, password } });
      if (r.rol !== 'Dueño') throw new Error('Este panel es solo para el dueño');
      sessionStorage.setItem('token', r.token);
      nav('/panel');
    } catch (e) {
      setError(e.message);
    } finally {
      setBusy(false);
    }
  };

  return (
    <main className="login">
      <form onSubmit={entrar} className="login-card">
        <h1>Panel del dueño</h1>
        <p className="sub">Inicia sesión para ver la asistencia de tus sucursales.</p>
        <label>Usuario
          <input value={usuario} onChange={e => setUsuario(e.target.value)} autoFocus autoComplete="username" />
        </label>
        <label>Contraseña
          <input type="password" value={password} onChange={e => setPassword(e.target.value)} autoComplete="current-password" />
        </label>
        <button className="btn primario" disabled={busy || !usuario || !password}>Iniciar sesión</button>
        {error && <p className="error-txt">{error}</p>}
      </form>
    </main>
  );
}
