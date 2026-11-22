import sql from 'mssql';
import 'dotenv/config';

const pool = new sql.ConnectionPool({
  server: process.env.DB_SERVER || 'localhost',
  database: process.env.DB_NAME || 'PanaderiaDB',
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  port: process.env.DB_PORT ? Number(process.env.DB_PORT) : undefined,
  options: { trustServerCertificate: true, encrypt: false },
});

export const poolReady = pool.connect();
export { sql, pool };
