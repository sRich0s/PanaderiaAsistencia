import { Router } from 'express';
import { pool, sql } from '../db.js';
import { requireAuth } from '../middleware/auth.js';

const r = Router();
r.use(requireAuth(['Dueño']));

r.get('/sucursales', async (req, res) => {
  try {
    const q = await pool.request()
      .query('SELECT SucursalId, Nombre FROM Sucursal WHERE Activa = 1 ORDER BY Nombre');
    res.json(q.recordset);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error del servidor' });
  }
});

r.get('/asistencia/:sucursalId', async (req, res) => {
  try {
    const suc = parseInt(req.params.sucursalId, 10);
    if (Number.isNaN(suc)) return res.status(400).json({ error: 'Sucursal inválida' });

    const presentes = await pool.request().input('s', sql.Int, suc).query(`
      SELECT e.EmpleadoId, CONCAT(e.Nombre,' ',e.ApellidoPaterno) AS Empleado, p.Nombre AS Puesto,
             t.Nombre AS Turno, a.HoraEntrada, a.HoraSalida, a.HorasTrabajadas,
             a.EsApoyoTemporal, a.FotoEntradaRuta, a.FotoSalidaRuta,
             CASE WHEN DATEDIFF(MINUTE, CAST(a.Fecha AS DATETIME2(0)), a.HoraEntrada)
                       > DATEDIFF(MINUTE, CAST('00:00' AS TIME(0)), t.HoraEntrada) + t.ToleranciaMinutos
                  THEN 1 ELSE 0 END AS Retardo
      FROM Asistencia a
      JOIN Empleado e ON e.EmpleadoId = a.EmpleadoId
      JOIN Puesto   p ON p.PuestoId   = e.PuestoId
      JOIN Turno    t ON t.TurnoId    = e.TurnoId
      WHERE a.SucursalId = @s AND a.Fecha = CAST(SYSDATETIME() AS DATE)
      ORDER BY a.HoraEntrada`);

    const sinRegistro = await pool.request().input('s', sql.Int, suc).query(`
      SELECT e.EmpleadoId, CONCAT(e.Nombre,' ',e.ApellidoPaterno) AS Empleado,
             p.Nombre AS Puesto, t.Nombre AS Turno
      FROM Empleado e
      JOIN Puesto p ON p.PuestoId = e.PuestoId
      JOIN Turno  t ON t.TurnoId  = e.TurnoId
      WHERE e.SucursalId = @s AND e.Estatus = 'Activo'
        AND NOT EXISTS (SELECT 1 FROM Asistencia a
                        WHERE a.EmpleadoId = e.EmpleadoId AND a.Fecha = CAST(SYSDATETIME() AS DATE))
      ORDER BY t.TurnoId, e.Nombre`);

    res.json({ presentes: presentes.recordset, sinRegistro: sinRegistro.recordset });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error del servidor' });
  }
});

export default r;
