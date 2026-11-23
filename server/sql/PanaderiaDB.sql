SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sucursal](
	[SucursalId] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [nvarchar](60) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[Direccion] [nvarchar](150) COLLATE Modern_Spanish_CI_AS NULL,
	[Telefono] [varchar](15) COLLATE Modern_Spanish_CI_AS NULL,
	[Activa] [bit] NOT NULL,
	[FechaRegistro] [datetime2](0) NOT NULL,
 CONSTRAINT [PK_Sucursal] PRIMARY KEY CLUSTERED 
(
	[SucursalId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_Sucursal_Nombre] UNIQUE NONCLUSTERED 
(
	[Nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Puesto](
	[PuestoId] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [nvarchar](60) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[Descripcion] [nvarchar](200) COLLATE Modern_Spanish_CI_AS NULL,
 CONSTRAINT [PK_Puesto] PRIMARY KEY CLUSTERED 
(
	[PuestoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_Puesto_Nombre] UNIQUE NONCLUSTERED 
(
	[Nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Turno](
	[TurnoId] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [nvarchar](30) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[HoraEntrada] [time](0) NOT NULL,
	[HoraSalida] [time](0) NOT NULL,
	[ToleranciaMinutos] [int] NOT NULL,
 CONSTRAINT [PK_Turno] PRIMARY KEY CLUSTERED 
(
	[TurnoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_Turno_Nombre] UNIQUE NONCLUSTERED 
(
	[Nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Empleado](
	[EmpleadoId] [int] IDENTITY(1001,1) NOT NULL,
	[Nombre] [nvarchar](60) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[ApellidoPaterno] [nvarchar](60) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[ApellidoMaterno] [nvarchar](60) COLLATE Modern_Spanish_CI_AS NULL,
	[RFC] [char](13) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[CURP] [char](18) COLLATE Modern_Spanish_CI_AS NULL,
	[NSS] [char](11) COLLATE Modern_Spanish_CI_AS NULL,
	[FechaNacimiento] [date] NULL,
	[FechaIngreso] [date] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[PuestoId] [int] NOT NULL,
	[TurnoId] [int] NOT NULL,
	[SalarioPorHora] [decimal](10, 2) NOT NULL,
	[Clabe] [char](18) COLLATE Modern_Spanish_CI_AS NULL,
	[Telefono] [varchar](15) COLLATE Modern_Spanish_CI_AS NULL,
	[Email] [varchar](100) COLLATE Modern_Spanish_CI_AS NULL,
	[Estatus] [varchar](10) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[FechaRegistro] [datetime2](0) NOT NULL,
 CONSTRAINT [PK_Empleado] PRIMARY KEY CLUSTERED 
(
	[EmpleadoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_Empleado_RFC] UNIQUE NONCLUSTERED 
(
	[RFC] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* ==========================================================================
   9. VISTAS DE APOYO (lectura para todos los equipos)
   ========================================================================== */

CREATE   VIEW vw_EmpleadoDetalle AS
SELECT e.EmpleadoId,
       CONCAT(e.Nombre, ' ', e.ApellidoPaterno, ' ', e.ApellidoMaterno) AS NombreCompleto,
       e.RFC, e.NSS, e.FechaIngreso, e.SalarioPorHora, e.Estatus,
       s.SucursalId, s.Nombre AS Sucursal,
       p.PuestoId,   p.Nombre AS Puesto,
       t.TurnoId,    t.Nombre AS Turno, t.HoraEntrada, t.HoraSalida
FROM Empleado e
JOIN Sucursal s ON s.SucursalId = e.SucursalId
JOIN Puesto   p ON p.PuestoId   = e.PuestoId
JOIN Turno    t ON t.TurnoId    = e.TurnoId;

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Asistencia](
	[AsistenciaId] [int] IDENTITY(1,1) NOT NULL,
	[EmpleadoId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[TabletaId] [int] NULL,
	[Fecha] [date] NOT NULL,
	[HoraEntrada] [datetime2](0) NOT NULL,
	[HoraSalida] [datetime2](0) NULL,
	[HorasTrabajadas]  AS (case when [HoraSalida] IS NULL then NULL else CONVERT([decimal](5,2),datediff(minute,[HoraEntrada],[HoraSalida])/(60.0)) end) PERSISTED,
	[FotoEntradaRuta] [nvarchar](260) COLLATE Modern_Spanish_CI_AS NULL,
	[FotoSalidaRuta] [nvarchar](260) COLLATE Modern_Spanish_CI_AS NULL,
	[EsApoyoTemporal] [bit] NOT NULL,
 CONSTRAINT [PK_Asistencia] PRIMARY KEY CLUSTERED 
(
	[AsistenciaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_Asistencia_EmpleadoFecha] UNIQUE NONCLUSTERED 
(
	[EmpleadoId] ASC,
	[Fecha] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW vw_AsistenciaDiaria AS
SELECT a.AsistenciaId, a.Fecha,
       e.EmpleadoId,
       CONCAT(e.Nombre, ' ', e.ApellidoPaterno) AS Empleado,
       a.SucursalId, s.Nombre AS SucursalMarcaje,
       e.SucursalId AS SucursalAsignadaId,
       a.HoraEntrada, a.HoraSalida, a.HorasTrabajadas, a.EsApoyoTemporal,
       CASE WHEN DATEDIFF(MINUTE, CAST(a.Fecha AS DATETIME2(0)), a.HoraEntrada)
                 > DATEDIFF(MINUTE, CAST('00:00' AS TIME(0)), t.HoraEntrada) + t.ToleranciaMinutos
            THEN 'Retardo' ELSE 'A tiempo' END AS EstatusLlegada
FROM Asistencia a
JOIN Empleado e ON e.EmpleadoId = a.EmpleadoId
JOIN Turno    t ON t.TurnoId    = e.TurnoId
JOIN Sucursal s ON s.SucursalId = a.SucursalId;

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Nomina](
	[NominaId] [int] IDENTITY(1,1) NOT NULL,
	[PeriodoNominaId] [int] NOT NULL,
	[EmpleadoId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[ValidacionSemanalId] [int] NULL,
	[SalarioPorHora] [decimal](10, 2) NOT NULL,
	[SalarioDiario] [decimal](10, 2) NOT NULL,
	[SDI] [decimal](10, 2) NOT NULL,
	[HorasNormales] [decimal](6, 2) NOT NULL,
	[HorasExtraDobles] [decimal](6, 2) NOT NULL,
	[HorasExtraTriples] [decimal](6, 2) NOT NULL,
	[TotalPercepciones] [decimal](12, 2) NOT NULL,
	[TotalDeducciones] [decimal](12, 2) NOT NULL,
	[NetoPagar]  AS ([TotalPercepciones]-[TotalDeducciones]) PERSISTED,
	[Estatus] [varchar](12) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[FechaCalculo] [datetime2](0) NOT NULL,
	[UUIDTimbrado] [varchar](36) COLLATE Modern_Spanish_CI_AS NULL,
 CONSTRAINT [PK_Nomina] PRIMARY KEY CLUSTERED 
(
	[NominaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_Nomina] UNIQUE NONCLUSTERED 
(
	[PeriodoNominaId] ASC,
	[EmpleadoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PeriodoNomina](
	[PeriodoNominaId] [int] IDENTITY(1,1) NOT NULL,
	[FechaInicio] [date] NOT NULL,
	[FechaFin] [date] NOT NULL,
	[FechaPago] [date] NOT NULL,
	[Periodicidad] [varchar](10) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[Estatus] [varchar](15) COLLATE Modern_Spanish_CI_AS NOT NULL,
 CONSTRAINT [PK_PeriodoNomina] PRIMARY KEY CLUSTERED 
(
	[PeriodoNominaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_Periodo] UNIQUE NONCLUSTERED 
(
	[FechaInicio] ASC,
	[Periodicidad] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW vw_NominaPorSucursal AS
SELECT s.SucursalId, s.Nombre AS Sucursal,
       p.PeriodoNominaId, p.FechaInicio, p.FechaFin,
       COUNT(n.NominaId)        AS Empleados,
       SUM(n.TotalPercepciones) AS TotalPercepciones,
       SUM(n.TotalDeducciones)  AS TotalDeducciones,
       SUM(n.NetoPagar)         AS TotalNeto
FROM Nomina n
JOIN Sucursal      s ON s.SucursalId      = n.SucursalId
JOIN PeriodoNomina p ON p.PeriodoNominaId = n.PeriodoNominaId
WHERE n.Estatus <> 'Cancelada'
GROUP BY s.SucursalId, s.Nombre, p.PeriodoNominaId, p.FechaInicio, p.FechaFin;

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Baja](
	[BajaId] [int] IDENTITY(1,1) NOT NULL,
	[EmpleadoId] [int] NOT NULL,
	[MotivoBajaId] [int] NOT NULL,
	[FechaEfectiva] [date] NOT NULL,
	[Comentario] [nvarchar](300) COLLATE Modern_Spanish_CI_AS NULL,
	[ProcesadaPor] [int] NULL,
	[FechaRegistro] [datetime2](0) NOT NULL,
 CONSTRAINT [PK_Baja] PRIMARY KEY CLUSTERED 
(
	[BajaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_Baja_Empleado] UNIQUE NONCLUSTERED 
(
	[EmpleadoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConceptoNomina](
	[ConceptoNominaId] [int] IDENTITY(1,1) NOT NULL,
	[Clave] [varchar](10) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[Nombre] [nvarchar](60) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[Tipo] [varchar](11) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[ClaveSAT] [char](3) COLLATE Modern_Spanish_CI_AS NULL,
 CONSTRAINT [PK_ConceptoNomina] PRIMARY KEY CLUSTERED 
(
	[ConceptoNominaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_Concepto_Clave] UNIQUE NONCLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CreditoInfonavit](
	[CreditoInfonavitId] [int] IDENTITY(1,1) NOT NULL,
	[EmpleadoId] [int] NOT NULL,
	[NumeroCredito] [varchar](20) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[TipoDescuento] [varchar](10) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[ValorDescuento] [decimal](12, 4) NOT NULL,
	[FechaInicio] [date] NOT NULL,
	[FechaFin] [date] NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [PK_CreditoInfonavit] PRIMARY KEY CLUSTERED 
(
	[CreditoInfonavitId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_Credito_Numero] UNIQUE NONCLUSTERED 
(
	[NumeroCredito] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CuotaIMSS](
	[CuotaIMSSId] [int] IDENTITY(1,1) NOT NULL,
	[Anio] [smallint] NOT NULL,
	[Ramo] [nvarchar](60) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[Concepto] [nvarchar](80) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[PorcentajeObrero] [decimal](6, 4) NOT NULL,
	[BaseCalculo] [varchar](20) COLLATE Modern_Spanish_CI_AS NOT NULL,
 CONSTRAINT [PK_CuotaIMSS] PRIMARY KEY CLUSTERED 
(
	[CuotaIMSSId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Finiquito](
	[FiniquitoId] [int] IDENTITY(1,1) NOT NULL,
	[BajaId] [int] NOT NULL,
	[SalarioDiario] [decimal](10, 2) NOT NULL,
	[DiasPendientesPago] [decimal](5, 2) NOT NULL,
	[ImporteDiasPendientes] [decimal](12, 2) NOT NULL,
	[DiasVacacionesPendientes] [decimal](5, 2) NOT NULL,
	[ImporteVacaciones] [decimal](12, 2) NOT NULL,
	[ImportePrimaVacacional] [decimal](12, 2) NOT NULL,
	[DiasAguinaldoProporcional] [decimal](6, 2) NOT NULL,
	[ImporteAguinaldo] [decimal](12, 2) NOT NULL,
	[ImporteIndemnizacion] [decimal](12, 2) NOT NULL,
	[ImportePrimaAntiguedad] [decimal](12, 2) NOT NULL,
	[ISRRetenido] [decimal](12, 2) NOT NULL,
	[TotalNeto]  AS (((((([ImporteDiasPendientes]+[ImporteVacaciones])+[ImportePrimaVacacional])+[ImporteAguinaldo])+[ImporteIndemnizacion])+[ImportePrimaAntiguedad])-[ISRRetenido]) PERSISTED,
	[Estatus] [varchar](12) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[FechaCalculo] [datetime2](0) NOT NULL,
 CONSTRAINT [PK_Finiquito] PRIMARY KEY CLUSTERED 
(
	[FiniquitoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_Finiquito_Baja] UNIQUE NONCLUSTERED 
(
	[BajaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Incidencia](
	[IncidenciaId] [int] IDENTITY(1,1) NOT NULL,
	[EmpleadoId] [int] NOT NULL,
	[PeriodoNominaId] [int] NOT NULL,
	[Fecha] [date] NOT NULL,
	[TipoIncidenciaId] [int] NOT NULL,
	[Horas] [decimal](5, 2) NULL,
	[Comentario] [nvarchar](300) COLLATE Modern_Spanish_CI_AS NULL,
	[JustificanteRuta] [nvarchar](260) COLLATE Modern_Spanish_CI_AS NULL,
	[RegistradaPor] [int] NULL,
	[FechaRegistro] [datetime2](0) NOT NULL,
 CONSTRAINT [PK_Incidencia] PRIMARY KEY CLUSTERED 
(
	[IncidenciaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MotivoBaja](
	[MotivoBajaId] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [nvarchar](60) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[PagaIndemnizacion] [bit] NOT NULL,
	[PagaPrimaAntiguedad] [bit] NOT NULL,
 CONSTRAINT [PK_MotivoBaja] PRIMARY KEY CLUSTERED 
(
	[MotivoBajaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_MotivoBaja] UNIQUE NONCLUSTERED 
(
	[Nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NominaDetalle](
	[NominaDetalleId] [int] IDENTITY(1,1) NOT NULL,
	[NominaId] [int] NOT NULL,
	[ConceptoNominaId] [int] NOT NULL,
	[Importe] [decimal](12, 2) NOT NULL,
	[ImporteGravado] [decimal](12, 2) NOT NULL,
	[ImporteExento] [decimal](12, 2) NOT NULL,
 CONSTRAINT [PK_NominaDetalle] PRIMARY KEY CLUSTERED 
(
	[NominaDetalleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ParametroFiscal](
	[ParametroFiscalId] [int] IDENTITY(1,1) NOT NULL,
	[FechaInicioVigencia] [date] NOT NULL,
	[FechaFinVigencia] [date] NULL,
	[UMADiaria] [decimal](10, 2) NOT NULL,
	[SalarioMinimoDiario] [decimal](10, 2) NOT NULL,
	[DiasAguinaldo] [int] NOT NULL,
	[PorcentajePrimaVacacional] [decimal](5, 2) NOT NULL,
	[TopeSBC_UMAs] [int] NOT NULL,
	[ExcedenteEyM_UMAs] [int] NOT NULL,
 CONSTRAINT [PK_ParametroFiscal] PRIMARY KEY CLUSTERED 
(
	[ParametroFiscalId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Rol](
	[RolId] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [nvarchar](30) COLLATE Modern_Spanish_CI_AS NOT NULL,
 CONSTRAINT [PK_Rol] PRIMARY KEY CLUSTERED 
(
	[RolId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_Rol_Nombre] UNIQUE NONCLUSTERED 
(
	[Nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TablaISR](
	[TablaISRId] [int] IDENTITY(1,1) NOT NULL,
	[Anio] [smallint] NOT NULL,
	[Periodicidad] [varchar](10) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[LimiteInferior] [decimal](12, 2) NOT NULL,
	[LimiteSuperior] [decimal](12, 2) NULL,
	[CuotaFija] [decimal](12, 2) NOT NULL,
	[PorcentajeExcedente] [decimal](5, 2) NOT NULL,
 CONSTRAINT [PK_TablaISR] PRIMARY KEY CLUSTERED 
(
	[TablaISRId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TablaVacaciones](
	[TablaVacacionesId] [int] IDENTITY(1,1) NOT NULL,
	[AniosDesde] [int] NOT NULL,
	[AniosHasta] [int] NOT NULL,
	[DiasVacaciones] [int] NOT NULL,
 CONSTRAINT [PK_TablaVacaciones] PRIMARY KEY CLUSTERED 
(
	[TablaVacacionesId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tableta](
	[TabletaId] [int] IDENTITY(1,1) NOT NULL,
	[SucursalId] [int] NOT NULL,
	[Nombre] [nvarchar](60) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[Identificador] [varchar](50) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[Activa] [bit] NOT NULL,
 CONSTRAINT [PK_Tableta] PRIMARY KEY CLUSTERED 
(
	[TabletaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_Tableta_Ident] UNIQUE NONCLUSTERED 
(
	[Identificador] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TipoIncidencia](
	[TipoIncidenciaId] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [nvarchar](50) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[ConGoce] [bit] NOT NULL,
	[AfectaNomina] [bit] NOT NULL,
 CONSTRAINT [PK_TipoIncidencia] PRIMARY KEY CLUSTERED 
(
	[TipoIncidenciaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_TipoIncidencia] UNIQUE NONCLUSTERED 
(
	[Nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Usuario](
	[UsuarioId] [int] IDENTITY(1,1) NOT NULL,
	[NombreUsuario] [varchar](50) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[PasswordHash] [varbinary](64) NOT NULL,
	[RolId] [int] NOT NULL,
	[EmpleadoId] [int] NULL,
	[SucursalId] [int] NULL,
	[Activo] [bit] NOT NULL,
	[UltimoAcceso] [datetime2](0) NULL,
 CONSTRAINT [PK_Usuario] PRIMARY KEY CLUSTERED 
(
	[UsuarioId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_Usuario_Nombre] UNIQUE NONCLUSTERED 
(
	[NombreUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VacacionesTomadas](
	[VacacionId] [int] IDENTITY(1,1) NOT NULL,
	[EmpleadoId] [int] NOT NULL,
	[FechaInicio] [date] NOT NULL,
	[FechaFin] [date] NOT NULL,
	[Dias] [int] NOT NULL,
	[AutorizadaPor] [int] NULL,
 CONSTRAINT [PK_VacacionesTomadas] PRIMARY KEY CLUSTERED 
(
	[VacacionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ValidacionSemanal](
	[ValidacionSemanalId] [int] IDENTITY(1,1) NOT NULL,
	[EmpleadoId] [int] NOT NULL,
	[PeriodoNominaId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[HorasNormales] [decimal](6, 2) NOT NULL,
	[HorasExtra] [decimal](6, 2) NOT NULL,
	[DiasTrabajados] [int] NOT NULL,
	[Faltas] [int] NOT NULL,
	[FaltasJustificadasConGoce] [int] NOT NULL,
	[Retardos] [int] NOT NULL,
	[Estatus] [varchar](25) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[ValidadoPor] [int] NULL,
	[FechaValidacion] [datetime2](0) NULL,
	[Comentario] [nvarchar](300) COLLATE Modern_Spanish_CI_AS NULL,
 CONSTRAINT [PK_ValidacionSemanal] PRIMARY KEY CLUSTERED 
(
	[ValidacionSemanalId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_Validacion] UNIQUE NONCLUSTERED 
(
	[EmpleadoId] ASC,
	[PeriodoNominaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE NONCLUSTERED INDEX [IX_Asistencia_SucursalFecha] ON [dbo].[Asistencia]
(
	[SucursalId] ASC,
	[Fecha] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
CREATE NONCLUSTERED INDEX [IX_Empleado_Sucursal] ON [dbo].[Empleado]
(
	[SucursalId] ASC,
	[Estatus] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Incidencia_EmpleadoPeriodo] ON [dbo].[Incidencia]
(
	[EmpleadoId] ASC,
	[PeriodoNominaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Nomina_SucursalPeriodo] ON [dbo].[Nomina]
(
	[SucursalId] ASC,
	[PeriodoNominaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
CREATE NONCLUSTERED INDEX [IX_TablaISR] ON [dbo].[TablaISR]
(
	[Anio] ASC,
	[Periodicidad] ASC,
	[LimiteInferior] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Asistencia] ADD  CONSTRAINT [DF_Asistencia_Apoyo]  DEFAULT ((0)) FOR [EsApoyoTemporal]
GO
ALTER TABLE [dbo].[Baja] ADD  CONSTRAINT [DF_Baja_Fecha]  DEFAULT (sysdatetime()) FOR [FechaRegistro]
GO
ALTER TABLE [dbo].[CreditoInfonavit] ADD  CONSTRAINT [DF_Credito_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [dbo].[Empleado] ADD  CONSTRAINT [DF_Empleado_Estatus]  DEFAULT ('Activo') FOR [Estatus]
GO
ALTER TABLE [dbo].[Empleado] ADD  CONSTRAINT [DF_Empleado_Fecha]  DEFAULT (sysdatetime()) FOR [FechaRegistro]
GO
ALTER TABLE [dbo].[Finiquito] ADD  CONSTRAINT [DF_Fin_DP]  DEFAULT ((0)) FOR [DiasPendientesPago]
GO
ALTER TABLE [dbo].[Finiquito] ADD  CONSTRAINT [DF_Fin_IDP]  DEFAULT ((0)) FOR [ImporteDiasPendientes]
GO
ALTER TABLE [dbo].[Finiquito] ADD  CONSTRAINT [DF_Fin_DV]  DEFAULT ((0)) FOR [DiasVacacionesPendientes]
GO
ALTER TABLE [dbo].[Finiquito] ADD  CONSTRAINT [DF_Fin_IV]  DEFAULT ((0)) FOR [ImporteVacaciones]
GO
ALTER TABLE [dbo].[Finiquito] ADD  CONSTRAINT [DF_Fin_IPV]  DEFAULT ((0)) FOR [ImportePrimaVacacional]
GO
ALTER TABLE [dbo].[Finiquito] ADD  CONSTRAINT [DF_Fin_DA]  DEFAULT ((0)) FOR [DiasAguinaldoProporcional]
GO
ALTER TABLE [dbo].[Finiquito] ADD  CONSTRAINT [DF_Fin_IA]  DEFAULT ((0)) FOR [ImporteAguinaldo]
GO
ALTER TABLE [dbo].[Finiquito] ADD  CONSTRAINT [DF_Fin_II]  DEFAULT ((0)) FOR [ImporteIndemnizacion]
GO
ALTER TABLE [dbo].[Finiquito] ADD  CONSTRAINT [DF_Fin_IPA]  DEFAULT ((0)) FOR [ImportePrimaAntiguedad]
GO
ALTER TABLE [dbo].[Finiquito] ADD  CONSTRAINT [DF_Fin_ISR]  DEFAULT ((0)) FOR [ISRRetenido]
GO
ALTER TABLE [dbo].[Finiquito] ADD  CONSTRAINT [DF_Fin_Estatus]  DEFAULT ('Calculado') FOR [Estatus]
GO
ALTER TABLE [dbo].[Finiquito] ADD  CONSTRAINT [DF_Fin_Fecha]  DEFAULT (sysdatetime()) FOR [FechaCalculo]
GO
ALTER TABLE [dbo].[Incidencia] ADD  CONSTRAINT [DF_Incidencia_Fecha]  DEFAULT (sysdatetime()) FOR [FechaRegistro]
GO
ALTER TABLE [dbo].[Nomina] ADD  CONSTRAINT [DF_Nom_HN]  DEFAULT ((0)) FOR [HorasNormales]
GO
ALTER TABLE [dbo].[Nomina] ADD  CONSTRAINT [DF_Nom_HED]  DEFAULT ((0)) FOR [HorasExtraDobles]
GO
ALTER TABLE [dbo].[Nomina] ADD  CONSTRAINT [DF_Nom_HET]  DEFAULT ((0)) FOR [HorasExtraTriples]
GO
ALTER TABLE [dbo].[Nomina] ADD  CONSTRAINT [DF_Nom_TP]  DEFAULT ((0)) FOR [TotalPercepciones]
GO
ALTER TABLE [dbo].[Nomina] ADD  CONSTRAINT [DF_Nom_TD]  DEFAULT ((0)) FOR [TotalDeducciones]
GO
ALTER TABLE [dbo].[Nomina] ADD  CONSTRAINT [DF_Nom_Estatus]  DEFAULT ('Calculada') FOR [Estatus]
GO
ALTER TABLE [dbo].[Nomina] ADD  CONSTRAINT [DF_Nom_Fecha]  DEFAULT (sysdatetime()) FOR [FechaCalculo]
GO
ALTER TABLE [dbo].[NominaDetalle] ADD  CONSTRAINT [DF_ND_Grav]  DEFAULT ((0)) FOR [ImporteGravado]
GO
ALTER TABLE [dbo].[NominaDetalle] ADD  CONSTRAINT [DF_ND_Exen]  DEFAULT ((0)) FOR [ImporteExento]
GO
ALTER TABLE [dbo].[ParametroFiscal] ADD  CONSTRAINT [DF_PF_Aguinaldo]  DEFAULT ((15)) FOR [DiasAguinaldo]
GO
ALTER TABLE [dbo].[ParametroFiscal] ADD  CONSTRAINT [DF_PF_Prima]  DEFAULT ((25.00)) FOR [PorcentajePrimaVacacional]
GO
ALTER TABLE [dbo].[ParametroFiscal] ADD  CONSTRAINT [DF_PF_Tope]  DEFAULT ((25)) FOR [TopeSBC_UMAs]
GO
ALTER TABLE [dbo].[ParametroFiscal] ADD  CONSTRAINT [DF_PF_Exc]  DEFAULT ((3)) FOR [ExcedenteEyM_UMAs]
GO
ALTER TABLE [dbo].[PeriodoNomina] ADD  CONSTRAINT [DF_Periodo_Period]  DEFAULT ('SEMANAL') FOR [Periodicidad]
GO
ALTER TABLE [dbo].[PeriodoNomina] ADD  CONSTRAINT [DF_Periodo_Estatus]  DEFAULT ('Abierto') FOR [Estatus]
GO
ALTER TABLE [dbo].[Sucursal] ADD  CONSTRAINT [DF_Sucursal_Activa]  DEFAULT ((1)) FOR [Activa]
GO
ALTER TABLE [dbo].[Sucursal] ADD  CONSTRAINT [DF_Sucursal_Fecha]  DEFAULT (sysdatetime()) FOR [FechaRegistro]
GO
ALTER TABLE [dbo].[Tableta] ADD  CONSTRAINT [DF_Tableta_Activa]  DEFAULT ((1)) FOR [Activa]
GO
ALTER TABLE [dbo].[Turno] ADD  CONSTRAINT [DF_Turno_Tol]  DEFAULT ((10)) FOR [ToleranciaMinutos]
GO
ALTER TABLE [dbo].[Usuario] ADD  CONSTRAINT [DF_Usuario_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [dbo].[ValidacionSemanal] ADD  CONSTRAINT [DF_Val_HN]  DEFAULT ((0)) FOR [HorasNormales]
GO
ALTER TABLE [dbo].[ValidacionSemanal] ADD  CONSTRAINT [DF_Val_HE]  DEFAULT ((0)) FOR [HorasExtra]
GO
ALTER TABLE [dbo].[ValidacionSemanal] ADD  CONSTRAINT [DF_Val_DT]  DEFAULT ((0)) FOR [DiasTrabajados]
GO
ALTER TABLE [dbo].[ValidacionSemanal] ADD  CONSTRAINT [DF_Val_F]  DEFAULT ((0)) FOR [Faltas]
GO
ALTER TABLE [dbo].[ValidacionSemanal] ADD  CONSTRAINT [DF_Val_FJ]  DEFAULT ((0)) FOR [FaltasJustificadasConGoce]
GO
ALTER TABLE [dbo].[ValidacionSemanal] ADD  CONSTRAINT [DF_Val_R]  DEFAULT ((0)) FOR [Retardos]
GO
ALTER TABLE [dbo].[ValidacionSemanal] ADD  CONSTRAINT [DF_Val_Estatus]  DEFAULT ('Pendiente') FOR [Estatus]
GO
ALTER TABLE [dbo].[Asistencia]  WITH CHECK ADD  CONSTRAINT [FK_Asistencia_Empleado] FOREIGN KEY([EmpleadoId])
REFERENCES [dbo].[Empleado] ([EmpleadoId])
GO
ALTER TABLE [dbo].[Asistencia] CHECK CONSTRAINT [FK_Asistencia_Empleado]
GO
ALTER TABLE [dbo].[Asistencia]  WITH CHECK ADD  CONSTRAINT [FK_Asistencia_Sucursal] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[Sucursal] ([SucursalId])
GO
ALTER TABLE [dbo].[Asistencia] CHECK CONSTRAINT [FK_Asistencia_Sucursal]
GO
ALTER TABLE [dbo].[Asistencia]  WITH CHECK ADD  CONSTRAINT [FK_Asistencia_Tableta] FOREIGN KEY([TabletaId])
REFERENCES [dbo].[Tableta] ([TabletaId])
GO
ALTER TABLE [dbo].[Asistencia] CHECK CONSTRAINT [FK_Asistencia_Tableta]
GO
ALTER TABLE [dbo].[Baja]  WITH CHECK ADD  CONSTRAINT [FK_Baja_Empleado] FOREIGN KEY([EmpleadoId])
REFERENCES [dbo].[Empleado] ([EmpleadoId])
GO
ALTER TABLE [dbo].[Baja] CHECK CONSTRAINT [FK_Baja_Empleado]
GO
ALTER TABLE [dbo].[Baja]  WITH CHECK ADD  CONSTRAINT [FK_Baja_Motivo] FOREIGN KEY([MotivoBajaId])
REFERENCES [dbo].[MotivoBaja] ([MotivoBajaId])
GO
ALTER TABLE [dbo].[Baja] CHECK CONSTRAINT [FK_Baja_Motivo]
GO
ALTER TABLE [dbo].[Baja]  WITH CHECK ADD  CONSTRAINT [FK_Baja_Usuario] FOREIGN KEY([ProcesadaPor])
REFERENCES [dbo].[Usuario] ([UsuarioId])
GO
ALTER TABLE [dbo].[Baja] CHECK CONSTRAINT [FK_Baja_Usuario]
GO
ALTER TABLE [dbo].[CreditoInfonavit]  WITH CHECK ADD  CONSTRAINT [FK_Credito_Empleado] FOREIGN KEY([EmpleadoId])
REFERENCES [dbo].[Empleado] ([EmpleadoId])
GO
ALTER TABLE [dbo].[CreditoInfonavit] CHECK CONSTRAINT [FK_Credito_Empleado]
GO
ALTER TABLE [dbo].[Empleado]  WITH CHECK ADD  CONSTRAINT [FK_Empleado_Puesto] FOREIGN KEY([PuestoId])
REFERENCES [dbo].[Puesto] ([PuestoId])
GO
ALTER TABLE [dbo].[Empleado] CHECK CONSTRAINT [FK_Empleado_Puesto]
GO
ALTER TABLE [dbo].[Empleado]  WITH CHECK ADD  CONSTRAINT [FK_Empleado_Sucursal] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[Sucursal] ([SucursalId])
GO
ALTER TABLE [dbo].[Empleado] CHECK CONSTRAINT [FK_Empleado_Sucursal]
GO
ALTER TABLE [dbo].[Empleado]  WITH CHECK ADD  CONSTRAINT [FK_Empleado_Turno] FOREIGN KEY([TurnoId])
REFERENCES [dbo].[Turno] ([TurnoId])
GO
ALTER TABLE [dbo].[Empleado] CHECK CONSTRAINT [FK_Empleado_Turno]
GO
ALTER TABLE [dbo].[Finiquito]  WITH CHECK ADD  CONSTRAINT [FK_Finiquito_Baja] FOREIGN KEY([BajaId])
REFERENCES [dbo].[Baja] ([BajaId])
GO
ALTER TABLE [dbo].[Finiquito] CHECK CONSTRAINT [FK_Finiquito_Baja]
GO
ALTER TABLE [dbo].[Incidencia]  WITH CHECK ADD  CONSTRAINT [FK_Incidencia_Empleado] FOREIGN KEY([EmpleadoId])
REFERENCES [dbo].[Empleado] ([EmpleadoId])
GO
ALTER TABLE [dbo].[Incidencia] CHECK CONSTRAINT [FK_Incidencia_Empleado]
GO
ALTER TABLE [dbo].[Incidencia]  WITH CHECK ADD  CONSTRAINT [FK_Incidencia_Periodo] FOREIGN KEY([PeriodoNominaId])
REFERENCES [dbo].[PeriodoNomina] ([PeriodoNominaId])
GO
ALTER TABLE [dbo].[Incidencia] CHECK CONSTRAINT [FK_Incidencia_Periodo]
GO
ALTER TABLE [dbo].[Incidencia]  WITH CHECK ADD  CONSTRAINT [FK_Incidencia_Tipo] FOREIGN KEY([TipoIncidenciaId])
REFERENCES [dbo].[TipoIncidencia] ([TipoIncidenciaId])
GO
ALTER TABLE [dbo].[Incidencia] CHECK CONSTRAINT [FK_Incidencia_Tipo]
GO
ALTER TABLE [dbo].[Incidencia]  WITH CHECK ADD  CONSTRAINT [FK_Incidencia_Usuario] FOREIGN KEY([RegistradaPor])
REFERENCES [dbo].[Usuario] ([UsuarioId])
GO
ALTER TABLE [dbo].[Incidencia] CHECK CONSTRAINT [FK_Incidencia_Usuario]
GO
ALTER TABLE [dbo].[Nomina]  WITH CHECK ADD  CONSTRAINT [FK_Nomina_Empleado] FOREIGN KEY([EmpleadoId])
REFERENCES [dbo].[Empleado] ([EmpleadoId])
GO
ALTER TABLE [dbo].[Nomina] CHECK CONSTRAINT [FK_Nomina_Empleado]
GO
ALTER TABLE [dbo].[Nomina]  WITH CHECK ADD  CONSTRAINT [FK_Nomina_Periodo] FOREIGN KEY([PeriodoNominaId])
REFERENCES [dbo].[PeriodoNomina] ([PeriodoNominaId])
GO
ALTER TABLE [dbo].[Nomina] CHECK CONSTRAINT [FK_Nomina_Periodo]
GO
ALTER TABLE [dbo].[Nomina]  WITH CHECK ADD  CONSTRAINT [FK_Nomina_Sucursal] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[Sucursal] ([SucursalId])
GO
ALTER TABLE [dbo].[Nomina] CHECK CONSTRAINT [FK_Nomina_Sucursal]
GO
ALTER TABLE [dbo].[Nomina]  WITH CHECK ADD  CONSTRAINT [FK_Nomina_Validacion] FOREIGN KEY([ValidacionSemanalId])
REFERENCES [dbo].[ValidacionSemanal] ([ValidacionSemanalId])
GO
ALTER TABLE [dbo].[Nomina] CHECK CONSTRAINT [FK_Nomina_Validacion]
GO
ALTER TABLE [dbo].[NominaDetalle]  WITH CHECK ADD  CONSTRAINT [FK_NominaDetalle_Concepto] FOREIGN KEY([ConceptoNominaId])
REFERENCES [dbo].[ConceptoNomina] ([ConceptoNominaId])
GO
ALTER TABLE [dbo].[NominaDetalle] CHECK CONSTRAINT [FK_NominaDetalle_Concepto]
GO
ALTER TABLE [dbo].[NominaDetalle]  WITH CHECK ADD  CONSTRAINT [FK_NominaDetalle_Nomina] FOREIGN KEY([NominaId])
REFERENCES [dbo].[Nomina] ([NominaId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[NominaDetalle] CHECK CONSTRAINT [FK_NominaDetalle_Nomina]
GO
ALTER TABLE [dbo].[Tableta]  WITH CHECK ADD  CONSTRAINT [FK_Tableta_Sucursal] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[Sucursal] ([SucursalId])
GO
ALTER TABLE [dbo].[Tableta] CHECK CONSTRAINT [FK_Tableta_Sucursal]
GO
ALTER TABLE [dbo].[Usuario]  WITH CHECK ADD  CONSTRAINT [FK_Usuario_Empleado] FOREIGN KEY([EmpleadoId])
REFERENCES [dbo].[Empleado] ([EmpleadoId])
GO
ALTER TABLE [dbo].[Usuario] CHECK CONSTRAINT [FK_Usuario_Empleado]
GO
ALTER TABLE [dbo].[Usuario]  WITH CHECK ADD  CONSTRAINT [FK_Usuario_Rol] FOREIGN KEY([RolId])
REFERENCES [dbo].[Rol] ([RolId])
GO
ALTER TABLE [dbo].[Usuario] CHECK CONSTRAINT [FK_Usuario_Rol]
GO
ALTER TABLE [dbo].[Usuario]  WITH CHECK ADD  CONSTRAINT [FK_Usuario_Sucursal] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[Sucursal] ([SucursalId])
GO
ALTER TABLE [dbo].[Usuario] CHECK CONSTRAINT [FK_Usuario_Sucursal]
GO
ALTER TABLE [dbo].[VacacionesTomadas]  WITH CHECK ADD  CONSTRAINT [FK_Vacaciones_Empleado] FOREIGN KEY([EmpleadoId])
REFERENCES [dbo].[Empleado] ([EmpleadoId])
GO
ALTER TABLE [dbo].[VacacionesTomadas] CHECK CONSTRAINT [FK_Vacaciones_Empleado]
GO
ALTER TABLE [dbo].[VacacionesTomadas]  WITH CHECK ADD  CONSTRAINT [FK_Vacaciones_Usuario] FOREIGN KEY([AutorizadaPor])
REFERENCES [dbo].[Usuario] ([UsuarioId])
GO
ALTER TABLE [dbo].[VacacionesTomadas] CHECK CONSTRAINT [FK_Vacaciones_Usuario]
GO
ALTER TABLE [dbo].[ValidacionSemanal]  WITH CHECK ADD  CONSTRAINT [FK_Validacion_Empleado] FOREIGN KEY([EmpleadoId])
REFERENCES [dbo].[Empleado] ([EmpleadoId])
GO
ALTER TABLE [dbo].[ValidacionSemanal] CHECK CONSTRAINT [FK_Validacion_Empleado]
GO
ALTER TABLE [dbo].[ValidacionSemanal]  WITH CHECK ADD  CONSTRAINT [FK_Validacion_Periodo] FOREIGN KEY([PeriodoNominaId])
REFERENCES [dbo].[PeriodoNomina] ([PeriodoNominaId])
GO
ALTER TABLE [dbo].[ValidacionSemanal] CHECK CONSTRAINT [FK_Validacion_Periodo]
GO
ALTER TABLE [dbo].[ValidacionSemanal]  WITH CHECK ADD  CONSTRAINT [FK_Validacion_Sucursal] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[Sucursal] ([SucursalId])
GO
ALTER TABLE [dbo].[ValidacionSemanal] CHECK CONSTRAINT [FK_Validacion_Sucursal]
GO
ALTER TABLE [dbo].[ValidacionSemanal]  WITH CHECK ADD  CONSTRAINT [FK_Validacion_Usuario] FOREIGN KEY([ValidadoPor])
REFERENCES [dbo].[Usuario] ([UsuarioId])
GO
ALTER TABLE [dbo].[ValidacionSemanal] CHECK CONSTRAINT [FK_Validacion_Usuario]
GO
ALTER TABLE [dbo].[Asistencia]  WITH CHECK ADD  CONSTRAINT [CK_Asistencia_Horas] CHECK  (([HoraSalida] IS NULL OR [HoraSalida]>[HoraEntrada]))
GO
ALTER TABLE [dbo].[Asistencia] CHECK CONSTRAINT [CK_Asistencia_Horas]
GO
ALTER TABLE [dbo].[ConceptoNomina]  WITH CHECK ADD  CONSTRAINT [CK_Concepto_Tipo] CHECK  (([Tipo]='DEDUCCION' OR [Tipo]='PERCEPCION'))
GO
ALTER TABLE [dbo].[ConceptoNomina] CHECK CONSTRAINT [CK_Concepto_Tipo]
GO
ALTER TABLE [dbo].[CreditoInfonavit]  WITH CHECK ADD  CONSTRAINT [CK_Credito_Tipo] CHECK  (([TipoDescuento]='CUOTA_FIJA' OR [TipoDescuento]='PORCENTAJE' OR [TipoDescuento]='VSM'))
GO
ALTER TABLE [dbo].[CreditoInfonavit] CHECK CONSTRAINT [CK_Credito_Tipo]
GO
ALTER TABLE [dbo].[CuotaIMSS]  WITH CHECK ADD  CONSTRAINT [CK_CuotaIMSS_Base] CHECK  (([BaseCalculo]='EXCEDENTE_3UMA' OR [BaseCalculo]='SBC'))
GO
ALTER TABLE [dbo].[CuotaIMSS] CHECK CONSTRAINT [CK_CuotaIMSS_Base]
GO
ALTER TABLE [dbo].[Empleado]  WITH CHECK ADD  CONSTRAINT [CK_Empleado_Estatus] CHECK  (([Estatus]='Inactivo' OR [Estatus]='Activo'))
GO
ALTER TABLE [dbo].[Empleado] CHECK CONSTRAINT [CK_Empleado_Estatus]
GO
ALTER TABLE [dbo].[Empleado]  WITH CHECK ADD  CONSTRAINT [CK_Empleado_Id4Digitos] CHECK  (([EmpleadoId]>=(1000) AND [EmpleadoId]<=(9999)))
GO
ALTER TABLE [dbo].[Empleado] CHECK CONSTRAINT [CK_Empleado_Id4Digitos]
GO
ALTER TABLE [dbo].[Empleado]  WITH CHECK ADD  CONSTRAINT [CK_Empleado_RFC] CHECK  ((len([RFC])=(13)))
GO
ALTER TABLE [dbo].[Empleado] CHECK CONSTRAINT [CK_Empleado_RFC]
GO
ALTER TABLE [dbo].[Empleado]  WITH CHECK ADD  CONSTRAINT [CK_Empleado_Salario] CHECK  (([SalarioPorHora]>(0)))
GO
ALTER TABLE [dbo].[Empleado] CHECK CONSTRAINT [CK_Empleado_Salario]
GO
ALTER TABLE [dbo].[Finiquito]  WITH CHECK ADD  CONSTRAINT [CK_Finiquito_Estatus] CHECK  (([Estatus]='Cancelado' OR [Estatus]='Pagado' OR [Estatus]='Calculado'))
GO
ALTER TABLE [dbo].[Finiquito] CHECK CONSTRAINT [CK_Finiquito_Estatus]
GO
ALTER TABLE [dbo].[Nomina]  WITH CHECK ADD  CONSTRAINT [CK_Nomina_Estatus] CHECK  (([Estatus]='Cancelada' OR [Estatus]='Pagada' OR [Estatus]='Autorizada' OR [Estatus]='Calculada'))
GO
ALTER TABLE [dbo].[Nomina] CHECK CONSTRAINT [CK_Nomina_Estatus]
GO
ALTER TABLE [dbo].[PeriodoNomina]  WITH CHECK ADD  CONSTRAINT [CK_Periodo_Estatus] CHECK  (([Estatus]='Pagado' OR [Estatus]='Cerrado' OR [Estatus]='En validación' OR [Estatus]='Abierto'))
GO
ALTER TABLE [dbo].[PeriodoNomina] CHECK CONSTRAINT [CK_Periodo_Estatus]
GO
ALTER TABLE [dbo].[PeriodoNomina]  WITH CHECK ADD  CONSTRAINT [CK_Periodo_Fechas] CHECK  (([FechaFin]>=[FechaInicio]))
GO
ALTER TABLE [dbo].[PeriodoNomina] CHECK CONSTRAINT [CK_Periodo_Fechas]
GO
ALTER TABLE [dbo].[VacacionesTomadas]  WITH CHECK ADD  CONSTRAINT [CK_Vacaciones_Fechas] CHECK  (([FechaFin]>=[FechaInicio]))
GO
ALTER TABLE [dbo].[VacacionesTomadas] CHECK CONSTRAINT [CK_Vacaciones_Fechas]
GO
ALTER TABLE [dbo].[ValidacionSemanal]  WITH CHECK ADD  CONSTRAINT [CK_Validacion_Estatus] CHECK  (([Estatus]='Rechazado' OR [Estatus]='Validado por Sucursal' OR [Estatus]='Pendiente'))
GO
ALTER TABLE [dbo].[ValidacionSemanal] CHECK CONSTRAINT [CK_Validacion_Estatus]
GO

/* Datos mínimos reproducibles para Docker Compose */
IF NOT EXISTS (SELECT 1 FROM [dbo].[Sucursal] WHERE [SucursalId] = 1)
BEGIN
    SET IDENTITY_INSERT [dbo].[Sucursal] ON
    INSERT [dbo].[Sucursal] ([SucursalId], [Nombre], [Direccion], [Telefono], [Activa], [FechaRegistro]) VALUES
        (1, N'Sucursal Centro', N'Calle Hidalgo 245, Zona Centro', '8441000001', 1, SYSDATETIME()),
        (2, N'Sucursal Norte', N'Blvd. Norte 1180, Col. Lomas', '8441000002', 1, SYSDATETIME()),
        (3, N'Sucursal Sur', N'Av. del Sur 530, Col. Jardines', '8441000003', 1, SYSDATETIME())
    SET IDENTITY_INSERT [dbo].[Sucursal] OFF
END
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[Rol])
BEGIN
    SET IDENTITY_INSERT [dbo].[Rol] ON
    INSERT [dbo].[Rol] ([RolId], [Nombre]) VALUES
        (1, N'Dueño'), (2, N'Encargado'), (3, N'Empleado')
    SET IDENTITY_INSERT [dbo].[Rol] OFF
END
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[Puesto])
BEGIN
    SET IDENTITY_INSERT [dbo].[Puesto] ON
    INSERT [dbo].[Puesto] ([PuestoId], [Nombre]) VALUES
        (1, N'Encargado de sucursal'), (2, N'Panadero'), (3, N'Cajero'),
        (4, N'Ayudante de panadería'), (5, N'Repartidor')
    SET IDENTITY_INSERT [dbo].[Puesto] OFF
END
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[Turno])
BEGIN
    SET IDENTITY_INSERT [dbo].[Turno] ON
    INSERT [dbo].[Turno] ([TurnoId], [Nombre], [HoraEntrada], [HoraSalida], [ToleranciaMinutos]) VALUES
        (1, N'Matutino', '06:00:00', '14:00:00', 10),
        (2, N'Vespertino', '14:00:00', '22:00:00', 10)
    SET IDENTITY_INSERT [dbo].[Turno] OFF
END
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[Tableta])
BEGIN
    SET IDENTITY_INSERT [dbo].[Tableta] ON
    INSERT [dbo].[Tableta] ([TabletaId], [SucursalId], [Nombre], [Identificador], [Activa]) VALUES
        (1, 1, N'Tableta mostrador Centro', 'TAB-CEN-01', 1),
        (2, 2, N'Tableta mostrador Norte', 'TAB-NOR-01', 1),
        (3, 3, N'Tableta mostrador Sur', 'TAB-SUR-01', 1)
    SET IDENTITY_INSERT [dbo].[Tableta] OFF
END
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[Empleado] WHERE [EmpleadoId] = 1001)
BEGIN
    SET IDENTITY_INSERT [dbo].[Empleado] ON
    INSERT [dbo].[Empleado]
        ([EmpleadoId],[Nombre],[ApellidoPaterno],[ApellidoMaterno],[RFC],[FechaIngreso],[SucursalId],[PuestoId],[TurnoId],[SalarioPorHora],[Estatus],[FechaRegistro]) VALUES
        (1001,N'Laura',N'Martínez',N'Ríos','MARL800101ABC', '2024-01-01',1,1,1,75.00,'Activo',SYSDATETIME()),
        (1002,N'José',N'Hernández',N'López','HELJ901202ABC', '2024-01-10',1,2,1,55.00,'Activo',SYSDATETIME()),
        (1003,N'Miguel',N'Torres',N'Garza','TOGM920303ABC', '2024-02-01',1,2,2,55.00,'Activo',SYSDATETIME()),
        (1004,N'Ana',N'Sánchez',N'Flores','SAFA930404ABC', '2024-02-10',1,3,1,45.00,'Activo',SYSDATETIME()),
        (1005,N'Pedro',N'Ramírez',N'Cruz','RACP940505ABC', '2024-03-01',1,5,2,48.00,'Activo',SYSDATETIME()),
        (1006,N'Rosa',N'Castillo',N'Vega','CAVR950606ABC', '2024-01-05',2,1,1,75.00,'Activo',SYSDATETIME()),
        (1007,N'Luis',N'Morales',N'Ortiz','MOOL960707ABC', '2024-01-15',2,2,1,55.00,'Activo',SYSDATETIME()),
        (1008,N'Carmen',N'Jiménez',N'Ruiz','JIRC970808ABC', '2024-02-05',2,2,2,55.00,'Activo',SYSDATETIME()),
        (1009,N'Daniel',N'Reyes',N'Mendoza','REMD980909ABC', '2024-03-10',2,3,2,45.00,'Activo',SYSDATETIME()),
        (1010,N'Sofía',N'Aguilar',N'Navarro','AUNS991010ABC', '2024-03-15',2,4,1,42.00,'Activo',SYSDATETIME()),
        (1011,N'Jorge',N'Domínguez',N'Salas','DOSJ000111ABC', '2024-01-08',3,1,1,75.00,'Activo',SYSDATETIME()),
        (1012,N'Patricia',N'Vargas',N'Luna','VALP010212ABC', '2024-02-12',3,2,1,55.00,'Activo',SYSDATETIME()),
        (1013,N'Ricardo',N'Medina',N'Rojas','MERR020313ABC', '2024-02-20',3,2,2,55.00,'Activo',SYSDATETIME()),
        (1014,N'Fernanda',N'Herrera',N'Soto','HESF030414ABC', '2024-03-12',3,3,1,45.00,'Activo',SYSDATETIME()),
        (1015,N'Alejandro',N'Guzmán',N'Peña','GUPA040515ABC', '2024-03-20',3,4,2,42.00,'Activo',SYSDATETIME())
    SET IDENTITY_INSERT [dbo].[Empleado] OFF
END
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario] WHERE [NombreUsuario] = 'dueno')
BEGIN
    INSERT [dbo].[Usuario] ([NombreUsuario],[PasswordHash],[RolId],[EmpleadoId],[SucursalId],[Activo]) VALUES
        ('dueno', HASHBYTES('SHA2_256', N'Panaderia2026!'), 1, NULL, NULL, 1),
        ('encargado.centro', HASHBYTES('SHA2_256', N'Encargado2026!'), 2, 1001, 1, 1),
        ('encargado.norte', HASHBYTES('SHA2_256', N'Encargado2026!'), 2, 1006, 2, 1),
        ('encargado.sur', HASHBYTES('SHA2_256', N'Encargado2026!'), 2, 1011, 3, 1)
END
GO
