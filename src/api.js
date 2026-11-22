const API = '/api';

/* La tableta se identifica con un código (ej. TAB-CEN-01) guardado en el navegador.
   Se configura una sola vez abriendo:  /tableta?id=TAB-NOR-01  */
export function getTabletaId() {
  const url = new URLSearchParams(window.location.search).get('id');
  if (url) localStorage.setItem('tabletaId', url);
  return localStorage.getItem('tabletaId') || 'TAB-CEN-01';
}

export async function api(path, { method = 'GET', body, token, headers = {} } = {}) {
  const isForm = body instanceof FormData;
  const res = await fetch(API + path, {
    method,
    headers: {
      ...(isForm ? {} : { 'Content-Type': 'application/json' }),
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...headers,
    },
    body: body ? (isForm ? body : JSON.stringify(body)) : undefined,
  });
  let data = {};
  try { data = await res.json(); } catch { /* respuesta sin cuerpo */ }
  if (!res.ok) {
    const err = new Error(data.error || 'Error de conexión');
    err.status = res.status;
    throw err;
  }
  return data;
}
