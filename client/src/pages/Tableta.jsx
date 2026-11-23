import { useEffect, useRef, useState } from 'react';
import { api, getTabletaId } from '../api.js';
import './Tableta.css';

const TECLAS = ['1', '2', '3', '4', '5', '6', '7', '8', '9', 'Borrar', '0', 'Limpiar'];

export default function Tableta() {
  const tabletaId = useRef(getTabletaId()).current;
  const [sucursal, setSucursal] = useState('');
  const [id, setId] = useState('');
  const [msg, setMsg] = useState(null); // { ok, texto }
  const [busy, setBusy] = useState(false);
  const [camara, setCamara] = useState(false);
  const video = useRef(null);
  const timer = useRef(null);

  // Nombre de la sucursal de esta tableta
  useEffect(() => {
    api('/tableta/info', { headers: { 'x-tableta-id': tabletaId } })
      .then(d => setSucursal(d.Sucursal))
      .catch(e => setMsg({ ok: false, texto: e.message }));
  }, [tabletaId]);

  // Cámara frontal (opcional)
  useEffect(() => {
    let stream;
    navigator.mediaDevices?.getUserMedia({ video: { facingMode: 'user' } })
      .then(s => {
        stream = s;
        if (video.current) video.current.srcObject = s;
        setCamara(true);
      })
      .catch(() => setCamara(false));
    return () => stream?.getTracks().forEach(t => t.stop());
  }, []);

  const capturarFoto = () => new Promise(resolve => {
    if (!camara || !video.current?.videoWidth) return resolve(null);
    const c = document.createElement('canvas');
    c.width = 320; c.height = 240;
    c.getContext('2d').drawImage(video.current, 0, 0, 320, 240);
    c.toBlob(resolve, 'image/jpeg', 0.7);
  });

  const mostrar = (m) => {
    setMsg(m);
    clearTimeout(timer.current);
    timer.current = setTimeout(() => setMsg(null), 4500);
  };

  const marcar = async (accion) => {
    if (id.length !== 4 || busy) return;
    setBusy(true);
    try {
      const fd = new FormData();
      fd.append('empleadoId', id);
      fd.append('accion', accion);
      const foto = await capturarFoto();
      if (foto) fd.append('foto', foto, 'foto.jpg');
      const r = await api('/tableta/marcar', {
        method: 'POST', body: fd, headers: { 'x-tableta-id': tabletaId },
      });
      mostrar({ ok: true, texto: r.mensaje });
    } catch (e) {
      mostrar({ ok: false, texto: e.message });
    } finally {
      setBusy(false);
      setId('');
    }
  };

  const presionar = (t) => {
    if (busy) return;
    if (t === 'Borrar') setId(id.slice(0, -1));
    else if (t === 'Limpiar') setId('');
    else if (id.length < 4) setId(id + t);
  };

  return (
    <main className="tb">
      <section className="tb-card">
        {/* Lado izquierdo: bienvenida, sucursal y cámara */}
        <div className="tb-info">
          <div className="tb-marca" aria-hidden="true">🥖</div>
          <h1 className="tb-titulo">Marcaje de asistencia</h1>
          <p className="tb-sucursal">{sucursal || 'Conectando…'}</p>

          <div className={camara ? 'tb-cam on' : 'tb-cam'}>
            <video ref={video} autoPlay muted playsInline />
          </div>

          <p className="tb-ayuda">
            Escribe tu número de empleado de 4 dígitos y elige <strong>Entrada</strong> o <strong>Salida</strong>.
          </p>
        </div>

        {/* Lado derecho: teclado y acciones */}
        <div className="tb-teclado-lado">
          <div className="tb-display" aria-live="polite" aria-label="Número de empleado">
            {[0, 1, 2, 3].map(i => (
              <span
                key={i}
                className={'tb-dig' + (id[i] ? ' lleno' : '') + (i === id.length ? ' activo' : '')}
              >
                {id[i] || ''}
              </span>
            ))}
          </div>

          <div className="tb-teclado">
            {TECLAS.map(t => (
              <button
                key={t}
                type="button"
                className={t.length > 1 ? 'tb-tecla util' : 'tb-tecla'}
                onClick={() => presionar(t)}
              >
                {t === 'Borrar' ? '⌫ Borrar' : t}
              </button>
            ))}
          </div>

          <div className="tb-acciones">
            <button
              type="button"
              className="tb-btn entrada"
              disabled={busy || id.length !== 4}
              onClick={() => marcar('entrada')}
            >
              Entrada
            </button>
            <button
              type="button"
              className="tb-btn salida"
              disabled={busy || id.length !== 4}
              onClick={() => marcar('salida')}
            >
              Salida
            </button>
          </div>

          <div className={msg ? (msg.ok ? 'tb-aviso ok' : 'tb-aviso error') : 'tb-aviso'} role="status">
            {msg?.texto}
          </div>
        </div>
      </section>
    </main>
  );
}
