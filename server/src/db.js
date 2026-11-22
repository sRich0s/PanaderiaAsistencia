import sql from 'mssql';
import 'dotenv/config';

const pool = new sql.ConnectionPool({
  server: process.env.DB_SERVER,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  options: { trustServerCertificate: true },
});

export const poolReady = pool.connect();
export { sql, pool };
