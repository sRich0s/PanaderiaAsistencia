
import sql from 'mssql/msnodesqlv8.js';
import 'dotenv/config';

const config = {
    connectionString:
        'Driver={ODBC Driver 18 for SQL Server};' +
        'Server=127.0.0.1,1433;' +
        'Database=PanaderiaDB;' +
        'Trusted_Connection=Yes;' +
        'Encrypt=Yes;' +
        'TrustServerCertificate=Yes;',

    pool: {
        max: 10,
        min: 0,
        idleTimeoutMillis: 30000
    }
};

const pool = new sql.ConnectionPool(config);

export const poolReady = pool.connect()
    .then(() => {
        console.log('Conexión exitosa a SQL Server');
        return pool;
    })
    .catch((error) => {
        console.error('Error al conectar con SQL Server:');
        console.dir(error, { depth: null });
        throw error;
    });

export { sql, pool };
