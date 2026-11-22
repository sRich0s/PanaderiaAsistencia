import { useEffect, useRef, useState } from 'react';
import { api, getTabletaId } from '../api.js';

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
    <main className="tableta">
      <header className="tableta-head">
        <h1>Marcaje de asistencia</h1>
        <p>{sucursal || 'Conectando…'}</p>
      </header>

      <video ref={video} autoPlay muted playsInline className={camara ? 'cam on' : 'cam'} />

      <div className="display" aria-live="polite" aria-label="Número de empleado">
        {[0, 1, 2, 3].map(i => (
          <span key={i} className={id[i] ? 'dig lleno' : 'dig'}>{id[i] || ''}</span>
        ))}
      </div>

      <div className="teclado">
        {TECLAS.map(t => (
          <button key={t} className={t.length > 1 ? 'tecla util' : 'tecla'} onClick={() => presionar(t)}>
            {t}
          </button>
        ))}
      </div>

      <div className="acciones">
        <button className="btn entrada" disabled={busy || id.length !== 4} onClick={() => marcar('entrada')}>
          Entrada
        </button>
        <button className="btn salida" disabled={busy || id.length !== 4} onClick={() => marcar('salida')}>
          Salida
        </button>
      </div>

      <div className={msg ? (msg.ok ? 'aviso ok' : 'aviso error') : 'aviso'} role="status">
        {msg?.texto}
      </div>
    </main>
  );
}
