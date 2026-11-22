import { Router } from 'express';
import multer from 'multer';
import fs from 'fs';
import { pool, sql } from '../db.js';

fs.mkdirSync('uploads', { recursive: true });
const upload = multer({
  storage: multer.diskStorage({
    destination: 'uploads',
    filename: (req, file, cb) =>
      cb(null, `${Date.now()}-${Math.round(Math.random() * 1e6)}.jpg`),
  }),
  limits: { fileSize: 2 * 1024 * 1024 },
});

const r = Router();

/* Datos de la tableta (nombre de la sucursal) para mostrarlos en pantalla */
r.get('/info', async (req, res) => {
  try {
    const q = await pool.request()
      .input('i', sql.VarChar(50), req.header('x-tableta-id'))
      .query(`SELECT t.Nombre AS Tableta, s.Nombre AS Sucursal
              FROM Tableta t JOIN Sucursal s ON s.SucursalId = t.SucursalId
              WHERE t.Identificador = @i AND t.Activa = 1`);
    if (!q.recordset[0]) return res.status(403).json({ error: 'Tableta no autorizada' });
    res.json(q.recordset[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error del servidor' });
  }
});

/* Historias 1 y 3: marcar entrada / salida */
r.post('/marcar', upload.single('foto'), async (req, res) => {
  const descartarFoto = () => { if (req.file) fs.unlink(req.file.path, () => {}); };
  try {
    const { accion } = req.body;
    const tabletaIdent = req.header('x-tableta-id');
    const fotoRuta = req.file ? `/uploads/${req.file.filename}` : null;

    if (!/^\d{4}$/.test(req.body.empleadoId || '')) {
      descartarFoto();
      return res.status(400).json({ error: 'El número de empleado debe tener 4 dígitos' });
    }
    const empleadoId = parseInt(req.body.empleadoId, 10);
    if (!['entrada', 'salida'].includes(accion)) {
      descartarFoto();
      return res.status(400).json({ error: 'Acción inválida' });
    }

    // 1) Tableta -> sucursal
    const t = (await pool.request().input('i', sql.VarChar(50), tabletaIdent)
      .query('SELECT TabletaId, SucursalId FROM Tableta WHERE Identificador = @i AND Activa = 1')).recordset[0];
    if (!t) { descartarFoto(); return res.status(403).json({ error: 'Tableta no autorizada' }); }

    // 2) Empleado activo y de esta sucursal
    const e = (await pool.request().input('id', sql.Int, empleadoId)
      .query('SELECT Nombre, SucursalId, Estatus FROM Empleado WHERE EmpleadoId = @id')).recordset[0];
    if (!e || e.Estatus !== 'Activo') {
      descartarFoto();
      return res.status(404).json({ error: 'Número de empleado no válido' });
    }
    if (e.SucursalId !== t.SucursalId) {
      descartarFoto();
      return res.status(403).json({ error: 'No perteneces a esta sucursal' });
    }

    if (accion === 'entrada') {
      try {
        const ins = await pool.request()
          .input('emp', sql.Int, empleadoId).input('suc', sql.Int, t.SucursalId)
          .input('tab', sql.Int, t.TabletaId).input('foto', sql.NVarChar(260), fotoRuta)
          .query(`INSERT INTO Asistencia (EmpleadoId, SucursalId, TabletaId, Fecha, HoraEntrada, FotoEntradaRuta)
                  OUTPUT inserted.HoraEntrada
                  VALUES (@emp, @suc, @tab, CAST(SYSDATETIME() AS DATE), SYSDATETIME(), @foto)`);
        return res.json({
          mensaje: `¡Hola ${e.Nombre}! Entrada registrada con éxito`,
          hora: ins.recordset[0].HoraEntrada,
        });
      } catch (err) {
        descartarFoto();
        if (err.number === 2627 || err.number === 2601)
          return res.status(409).json({ error: 'Ya registraste tu entrada hoy' });
        throw err;
      }
    }

    // salida
    try {
      const upd = await pool.request()
        .input('emp', sql.Int, empleadoId).input('foto', sql.NVarChar(260), fotoRuta)
        .query(`UPDATE Asistencia
                SET HoraSalida = SYSDATETIME(), FotoSalidaRuta = @foto
                OUTPUT inserted.HoraSalida, inserted.HorasTrabajadas
                WHERE EmpleadoId = @emp AND Fecha = CAST(SYSDATETIME() AS DATE) AND HoraSalida IS NULL`);
      if (!upd.recordset.length) {
        descartarFoto();
        return res.status(409).json({ error: 'No tienes una entrada abierta hoy (o ya registraste salida)' });
      }
      const row = upd.recordset[0];
      return res.json({
        mensaje: `¡Hasta luego ${e.Nombre}! Salida registrada. Horas trabajadas: ${row.HorasTrabajadas}`,
        hora: row.HoraSalida, horasTrabajadas: row.HorasTrabajadas,
      });
    } catch (err) {
      descartarFoto();
      if (err.number === 547) // CK_Asistencia_Horas: salida en el mismo instante que la entrada
        return res.status(400).json({ error: 'Espera unos segundos antes de registrar la salida' });
      throw err;
    }
  } catch (err) {
    descartarFoto();
    console.error(err);
    res.status(500).json({ error: 'Error del servidor' });
  }
});

export default r;
