# Panadería · Equipo 1: Control de asistencia

Backend Express + SQL Server y frontend React (Vite).

## Requisitos

- Node.js 18+
- SQL Server con la base `PanaderiaDB` creada con el script del proyecto
- VS Code (extensión "SQL Server (mssql)" para correr el script)

## Puesta en marcha

1. Ejecuta el script SQL de `PanaderiaDB` en SQL Server.
2. Servidor:
   ```bash
   cd server
   npm install
   # edita .env con tus datos de conexión
   npm run dev
   ```
3. Cliente (otra terminal):
   ```bash
   cd client
   npm install
   npm run dev
   ```

## Pantallas

| Ruta                     | Quién                   | Historia |
| ------------------------ | ------------------------ | -------- |
| `/tableta`             | Empleados (tableta fija) | 1 y 3    |
| `/login` → `/panel` | Dueño                   | 2        |

- Tableta de otra sucursal: abre una vez `http://localhost:5173/tableta?id=TAB-NOR-01` (o `TAB-SUR-01`); el código queda guardado en el navegador.
- Prueba: empleado `1002` en Centro. Dueño: `dueno` / `Panaderia2026!`.

## Notas

- La hora siempre es la del servidor (`SYSDATETIME()`).
- Cámara: `getUserMedia` solo funciona en `localhost` o HTTPS. En una tableta real por red local usa HTTPS (por ejemplo `@vitejs/plugin-basic-ssl`).
- Si el SQL Server usa una instancia con nombre o puerto distinto, ajusta `DB_SERVER` (ej. `localhost\SQLEXPRESS`) y habilita TCP/IP.
- Miguel (1003) ya tiene una asistencia hoy (21/nov/2026) como apoyo temporal en Norte, así que en Centro verá "Ya registraste tu entrada hoy".
