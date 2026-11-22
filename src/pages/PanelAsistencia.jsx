import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../api.js';

// El servidor devuelve la hora local de SQL Server serializada como UTC;
// por eso se muestra con timeZone 'UTC' (así se ve la hora real de la sucursal).
const hora = (d) => d
  ? new Date(d).toLocaleTimeString('es-MX', { hour: '2-digit', minute: '2-digit', timeZone: 'UTC' })
  : '—';

export default function PanelAsistencia() {
  const token = sessionStorage.getItem('token');
  const nav = useNavigate();
  const [sucursales, setSucursales] = useState([]);
  const [sel, setSel] = useState(null);
  const [data, setData] = useState({ presentes: [], sinRegistro: [] });
  const [actualizado, setActualizado] = useState(null);
  const [error, setError] = useState('');
  const [foto, setFoto] = useState(null);

  const salir = () => { sessionStorage.removeItem('token'); nav('/login'); };

  useEffect(() => {
    if (!token) return nav('/login');
    api('/panel/sucursales', { token })
      .then(s => { setSucursales(s); setSel(s[0]?.SucursalId ?? null); })
      .catch(() => salir());
  }, []);

  useEffect(() => {
    if (!sel) return;
    let vivo = true;
    const cargar = () => api(`/panel/asistencia/${sel}`, { token })
      .then(d => { if (vivo) { setData(d); setActualizado(new Date()); setError(''); } })
      .catch(e => { if (e.status === 401 || e.status === 403) salir(); else setError(e.message); });
    cargar();
    const t = setInterval(cargar, 10000); // "tiempo real" por polling
    return () => { vivo = false; clearInterval(t); };
  }, [sel]);

  const enTurno = data.presentes.filter(p => !p.HoraSalida).length;
  const total = data.presentes.length + data.sinRegistro.length;

  return (
    <main className="panel">
      <header className="panel-head">
        <div>
          <h1>Asistencia de hoy</h1>
          <p className="sub">
            {actualizado ? `Actualizado a las ${actualizado.toLocaleTimeString('es-MX', { hour: '2-digit', minute: '2-digit', second: '2-digit' })}` : 'Cargando…'}
          </p>
        </div>
        <div className="head-acciones">
          <select value={sel || ''} onChange={e => setSel(Number(e.target.value))} aria-label="Sucursal">
            {sucursales.map(s => <option key={s.SucursalId} value={s.SucursalId}>{s.Nombre}</option>)}
          </select>
          <button className="btn sec" onClick={salir}>Cerrar sesión</button>
        </div>
      </header>

      {error && <p className="error-txt">{error}</p>}

      <section className="resumen">
        <div><strong>{data.presentes.length}</strong><span>de {total} ya marcaron</span></div>
        <div><strong>{enTurno}</strong><span>siguen en turno</span></div>
        <div><strong>{data.sinRegistro.length}</strong><span>sin registro</span></div>
      </section>

      <h2>Presentes</h2>
      {data.presentes.length === 0 ? (
        <p className="vacio">Nadie ha marcado entrada hoy en esta sucursal.</p>
      ) : (
        <div className="tabla-wrap">
          <table>
            <thead>
              <tr><th>ID</th><th>Empleado</th><th>Puesto</th><th>Turno</th><th>Llegada</th><th>Salida</th><th>Horas</th><th>Foto</th></tr>
            </thead>
            <tbody>
              {data.presentes.map(p => (
                <tr key={p.EmpleadoId}>
                  <td>{p.EmpleadoId}</td>
                  <td>
                    {p.Empleado}
                    {p.EsApoyoTemporal ? <span className="chip apoyo">Apoyo temporal</span> : null}
                  </td>
                  <td>{p.Puesto}</td>
                  <td>{p.Turno}</td>
                  <td>{hora(p.HoraEntrada)}{p.Retardo ? <span className="chip retardo">Retardo</span> : null}</td>
                  <td>{hora(p.HoraSalida)}</td>
                  <td>{p.HorasTrabajadas ?? <span className="chip turno">En turno</span>}</td>
                  <td>{p.FotoEntradaRuta
                    ? <button className="link" onClick={() => setFoto(p)}>Ver</button>
                    : '—'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      <h2>Aún sin registro</h2>
      {data.sinRegistro.length === 0 ? (
        <p className="vacio">Todo el personal activo ya marcó entrada.</p>
      ) : (
        <ul className="faltan">
          {data.sinRegistro.map(p => (
            <li key={p.EmpleadoId}><strong>{p.Empleado}</strong> {p.Puesto}, turno {p.Turno.toLowerCase()}</li>
          ))}
        </ul>
      )}

      {foto && (
        <div className="modal" onClick={() => setFoto(null)}>
          <div className="modal-card" onClick={e => e.stopPropagation()}>
            <h3>{foto.Empleado}</h3>
            <div className="fotos">
              <figure><img src={foto.FotoEntradaRuta} alt="Foto de entrada" /><figcaption>Entrada {hora(foto.HoraEntrada)}</figcaption></figure>
              {foto.FotoSalidaRuta && (
                <figure><img src={foto.FotoSalidaRuta} alt="Foto de salida" /><figcaption>Salida {hora(foto.HoraSalida)}</figcaption></figure>
              )}
            </div>
            <button className="btn sec" onClick={() => setFoto(null)}>Cerrar</button>
          </div>
        </div>
      )}
    </main>
  );
}
