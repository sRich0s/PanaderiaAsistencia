# Panadería · Equipo 1: Control de asistencia

Aplicación para registrar entradas y salidas del personal de una panadería y consultar la asistencia por sucursal.

- **Frontend:** React, Vite y React Router.
- **Backend:** Node.js y Express.
- **Base de datos:** Microsoft SQL Server.
- **Entorno recomendado para empezar:** Docker Compose para SQL Server y backend; Vite se ejecuta localmente.

## Contenido

- [Requisitos](#requisitos)
- [Primer inicio con Docker](#primer-inicio-con-docker)
- [Inicios posteriores y cómo detenerlo](#inicios-posteriores-y-cómo-detenerlo)
- [Páginas y cómo usar la tableta](#páginas-y-cómo-usar-la-tableta)
- [Cuentas y datos de prueba](#cuentas-y-datos-de-prueba)
- [Cómo se inicializa SQL Server](#cómo-se-inicializa-sql-server)
- [Base de datos compartida por el equipo](#base-de-datos-compartida-por-el-equipo)
- [Inicio manual sin Docker](#inicio-manual-sin-docker)
- [Problemas frecuentes](#problemas-frecuentes)

## Requisitos

Para el inicio recomendado:

- Windows, macOS o Linux.
- [Git](https://git-scm.com/).
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) iniciado, con Docker Compose disponible.
- [Node.js 18 o superior](https://nodejs.org/), para ejecutar el frontend.

No necesitas instalar SQL Server en tu computadora si usas Docker Compose.

## Primer inicio con Docker

Abre PowerShell en la carpeta donde quieras guardar el proyecto y clónalo:

```powershell
git clone https://github.com/sRich0s/PanaderiaAsistencia.git
cd PanaderiaAsistencia
```

Confirma que Docker Desktop esté abierto. Crea tu configuración local a partir del ejemplo:

```powershell
Copy-Item .env.example .env
```

El `.env` de la raíz configura la contraseña de SQL Server, el secreto JWT y los puertos. Los valores incluidos son solo para desarrollo local; puedes cambiarlos antes de iniciar.

Construye e inicia SQL Server y el backend:

```powershell
docker compose up --build -d
```

La primera vez Docker descargará las imágenes, lo cual puede tardar varios minutos. Compose crea la base `PanaderiaDB` y ejecuta `server/sql/PanaderiaDB.sql` cuando el volumen de datos está vacío. Luego inicia el backend.

Instala e inicia el frontend en una segunda terminal:

```powershell
cd client
npm install
npm run dev
```

Abre en el navegador:

- **Inicio de sesión y panel:** <http://localhost:5173/login>
- **Tableta de Centro:** <http://localhost:5173/tableta>
- **API (comprobación):** <http://localhost:4000/api/health>

La respuesta del endpoint de salud debe ser `{"ok":true}`.

## Inicios posteriores y cómo detenerlo

Después de completar la instalación, para iniciar SQL Server y el backend:

```powershell
docker compose up -d
```

Si también se modificó el código o el Dockerfile del backend, reconstruye la imagen:

```powershell
docker compose up --build -d
```

El frontend se inicia por separado desde `client` con `npm run dev`. Para detener el frontend, presiona `Ctrl+C` en su terminal. Para detener los contenedores sin borrar la base:

```powershell
docker compose down
```

Los datos de SQL Server se conservan en un volumen de Docker aunque detengas los contenedores.

> **Cuidado:** `docker compose down -v` elimina los volúmenes, incluida la base de datos y las fotos guardadas por el backend. Úsalo solo si quieres borrar los datos locales y empezar de cero. No lo ejecutes si necesitas conservar información.

## Páginas y cómo usar la tableta

El login, el panel y la tableta son páginas del mismo frontend:

| Dirección | Uso |
|---|---|
| <http://localhost:5173/login> | Inicio de sesión del dueño |
| <http://localhost:5173/panel> | Panel de asistencia del dueño; requiere iniciar sesión |
| <http://localhost:5173/tableta> | Registro de asistencia en la tableta |

La sucursal de la tableta se elige con un identificador. Ábrela una vez con el código que corresponda:

| Sucursal | Dirección |
|---|---|
| Centro | <http://localhost:5173/tableta?id=TAB-CEN-01> |
| Norte | <http://localhost:5173/tableta?id=TAB-NOR-01> |
| Sur | <http://localhost:5173/tableta?id=TAB-SUR-01> |

El identificador queda guardado en el navegador de esa tableta. Para cambiarla de sucursal, abre la dirección con el nuevo identificador.

La cámara funciona en `localhost` o en una conexión HTTPS. Si abres la página desde otro dispositivo de la red local, necesitarás configurar HTTPS para que el navegador permita usar la cámara.

## Cuentas y datos de prueba

Estas cuentas y contraseñas son exclusivamente para desarrollo local y la base de demostración:

| Usuario | Contraseña | Rol |
|---|---|---|
| `dueno` | `Panaderia2026!` | Dueño |
| `encargado.centro` | `Encargado2026!` | Encargado |
| `encargado.norte` | `Encargado2026!` | Encargado |
| `encargado.sur` | `Encargado2026!` | Encargado |

Para probar la tableta, ingresa un número de empleado de cuatro dígitos. La base de demostración incluye empleados `1001` a `1015`; por ejemplo, `1002` pertenece a Centro.

Empleados de prueba: `1001` a `1015`. Primeros empleados por sucursal:

- Centro: `1001`, `1002`, `1003`
- Norte: `1006`, `1007`, `1008`
- Sur: `1011`, `1012`, `1013`

## Cómo se inicializa SQL Server

El servicio `db-init` de `compose.yaml` espera a que SQL Server esté listo, crea `PanaderiaDB` si no existe y ejecuta `server/sql/PanaderiaDB.sql` si la base aún no tiene sus tablas. La inicialización es automática en un volumen nuevo.

Si el equipo tiene un script SQL oficial más reciente, colócalo en `server/sql/PanaderiaDB.sql` antes de crear la base. El script debe crear las tablas y datos dentro de la base `PanaderiaDB` que Compose ya prepara. La configuración actual no vuelve a ejecutar el script sobre una base existente para evitar duplicar o sobrescribir datos; para actualizar una base existente, aplica cambios mediante una migración o un procedimiento SQL revisado.

El SQL Server de Docker es para desarrollo local. La contraseña `sa` se toma de `MSSQL_SA_PASSWORD` en el `.env` de la raíz.

## Base de datos compartida por el equipo

Con la configuración predeterminada, cada integrante obtiene una base local e independiente. Aunque todos usen el mismo script, los datos registrados en una computadora no aparecen automáticamente en las bases de los demás.

Para que todo el equipo use los mismos datos, se necesita una sola instancia de SQL Server accesible en la red (por ejemplo, en una computadora o servidor central). Cada backend debe conectarse a esa instancia con `DB_SERVER`, `DB_PORT`, `DB_NAME`, `DB_USER` y `DB_PASS` configurados en `server/.env`. No publiques las credenciales en Git ni compartas el usuario administrador `sa` para uso cotidiano.

El Compose de este repositorio inicia una base SQL Server local; no configura por sí solo una base central compartida ni abre el servidor central a la red.

## Inicio manual sin Docker

Usa esta opción solo si ya tienes una instancia de SQL Server y una base `PanaderiaDB` accesibles.

En una terminal, configura e inicia el backend:

```powershell
cd server
npm install
Copy-Item .env.example .env
```

Edita `server/.env` para indicar los datos de conexión de tu SQL Server (`DB_SERVER`, `DB_PORT`, `DB_NAME`, `DB_USER` y `DB_PASS`) y un `JWT_SECRET` propio. Después ejecuta:

```powershell
npm run dev
```

En otra terminal, instala e inicia el frontend:

```powershell
cd client
npm install
npm run dev
```

## Problemas frecuentes

- **Docker no inicia:** abre Docker Desktop y espera a que indique que el motor está funcionando.
- **El puerto ya está ocupado:** cambia `DB_PUBLIC_PORT` o `API_PORT` en el `.env` de la raíz. Si cambias `API_PORT`, actualiza también el proxy de Vite en `client/vite.config.js`.
- **El login muestra error de conexión:** comprueba que `docker compose ps` muestre `db` saludable y `backend` activo. Revisa los detalles con `docker compose logs backend db-init`.
- **El script SQL no se vuelve a ejecutar:** es el comportamiento esperado si la base ya está inicializada; protege los datos existentes. No borres el volumen sin respaldo.
- **La tableta muestra otra sucursal:** vuelve a abrir la URL con el identificador correcto para actualizar el valor guardado en ese navegador.

## Funcionalidad

- `/tableta`: registro de entrada y salida con número de empleado y captura opcional de foto.
- `/login` y `/panel`: acceso del dueño y consulta de asistencia por sucursal.
- El horario de asistencia se calcula con la hora de SQL Server (`SYSDATETIME()`).
- El panel actualiza la información periódicamente.
