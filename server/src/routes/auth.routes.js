import { Router } from 'express';
import jwt from 'jsonwebtoken';
import { pool, sql } from '../db.js';

const r = Router();

r.post('/login', async (req, res) => {
  try {
    const { usuario, password } = req.body || {};
    if (!usuario || !password)
      return res.status(400).json({ error: 'Escribe usuario y contraseña' });

    const q = await pool.request()
      .input('u', sql.VarChar(50), usuario)
      .input('p', sql.NVarChar(200), password) // NVARCHAR: igual que el INSERT de prueba
      .query(`SELECT u.UsuarioId, u.NombreUsuario, u.SucursalId, r.Nombre AS Rol
              FROM Usuario u JOIN Rol r ON r.RolId = u.RolId
              WHERE u.NombreUsuario = @u AND u.Activo = 1
                AND u.PasswordHash = HASHBYTES('SHA2_256', @p)`);
    const u = q.recordset[0];
    if (!u) return res.status(401).json({ error: 'Usuario o contraseña incorrectos' });

    await pool.request().input('id', sql.Int, u.UsuarioId)
      .query('UPDATE Usuario SET UltimoAcceso = SYSDATETIME() WHERE UsuarioId = @id');

    const token = jwt.sign(
      { id: u.UsuarioId, rol: u.Rol, sucursalId: u.SucursalId },
      process.env.JWT_SECRET, { expiresIn: '8h' });
    res.json({ token, usuario: u.NombreUsuario, rol: u.Rol });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error del servidor' });
  }
});

export default r;
