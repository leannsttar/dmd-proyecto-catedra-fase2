-- Copia de sql/ddl/01_tablas.sql sin separadores GO (el paso SQL de Pentaho separa por ';').
-- No editar a mano: se regenera desde sql/ddl/01_tablas.sql.
-- Carga total: borra y recrea todas las tablas (Fase 1, sección 2.2).

IF OBJECT_ID(N'dbo.Etl_Observaciones', N'U') IS NOT NULL DROP TABLE dbo.Etl_Observaciones;
IF OBJECT_ID(N'dbo.Etl_Rechazos', N'U') IS NOT NULL DROP TABLE dbo.Etl_Rechazos;
IF OBJECT_ID(N'dbo.Hecho_Trafico_Web', N'U') IS NOT NULL DROP TABLE dbo.Hecho_Trafico_Web;
IF OBJECT_ID(N'dbo.Hecho_Finanzas_Mensual', N'U') IS NOT NULL DROP TABLE dbo.Hecho_Finanzas_Mensual;
IF OBJECT_ID(N'dbo.Hecho_Ventas', N'U') IS NOT NULL DROP TABLE dbo.Hecho_Ventas;
IF OBJECT_ID(N'dbo.Dim_Region', N'U') IS NOT NULL DROP TABLE dbo.Dim_Region;
IF OBJECT_ID(N'dbo.Dim_Vendedor', N'U') IS NOT NULL DROP TABLE dbo.Dim_Vendedor;
IF OBJECT_ID(N'dbo.Dim_Canal', N'U') IS NOT NULL DROP TABLE dbo.Dim_Canal;
IF OBJECT_ID(N'dbo.Dim_Producto', N'U') IS NOT NULL DROP TABLE dbo.Dim_Producto;
IF OBJECT_ID(N'dbo.Dim_Cliente', N'U') IS NOT NULL DROP TABLE dbo.Dim_Cliente;
IF OBJECT_ID(N'dbo.Dim_Tiempo', N'U') IS NOT NULL DROP TABLE dbo.Dim_Tiempo;
IF OBJECT_ID(N'dbo.Dim_Mes', N'U') IS NOT NULL DROP TABLE dbo.Dim_Mes;
CREATE TABLE dbo.Dim_Mes (
    mes_key INT NOT NULL,
    mes_numero TINYINT NOT NULL,
    nombre_mes NVARCHAR(20) NOT NULL,
    trimestre TINYINT NOT NULL,
    semestre TINYINT NOT NULL,
    anio SMALLINT NOT NULL,
    CONSTRAINT PK_Dim_Mes PRIMARY KEY (mes_key)
);
CREATE TABLE dbo.Dim_Tiempo (
    tiempo_key INT NOT NULL,
    fecha DATE NOT NULL,
    dia_semana NVARCHAR(10) NOT NULL,
    mes_numero TINYINT NOT NULL,
    nombre_mes NVARCHAR(20) NOT NULL,
    trimestre TINYINT NOT NULL,
    semestre TINYINT NOT NULL,
    anio SMALLINT NOT NULL,
    CONSTRAINT PK_Dim_Tiempo PRIMARY KEY (tiempo_key)
);
CREATE TABLE dbo.Dim_Cliente (
    cliente_key INT NOT NULL,
    cliente_id NVARCHAR(20) NOT NULL,
    nombre NVARCHAR(100) NOT NULL,
    segmento NVARCHAR(30) NOT NULL,
    fecha_registro DATE NOT NULL,
    segmento_cluster INT NULL,
    CONSTRAINT PK_Dim_Cliente PRIMARY KEY (cliente_key)
);
CREATE TABLE dbo.Dim_Producto (
    producto_key INT NOT NULL,
    producto NVARCHAR(100) NOT NULL,
    categoria NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_Dim_Producto PRIMARY KEY (producto_key)
);
CREATE TABLE dbo.Dim_Canal (
    canal_key INT NOT NULL,
    canal NVARCHAR(30) NOT NULL,
    CONSTRAINT PK_Dim_Canal PRIMARY KEY (canal_key)
);
CREATE TABLE dbo.Dim_Vendedor (
    vendedor_key INT NOT NULL,
    equipo NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_Dim_Vendedor PRIMARY KEY (vendedor_key)
);
CREATE TABLE dbo.Dim_Region (
    region_key INT NOT NULL,
    region NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_Dim_Region PRIMARY KEY (region_key)
);
CREATE TABLE dbo.Hecho_Ventas (
    tiempo_key INT NOT NULL,
    mes_key INT NOT NULL,
    cliente_key INT NOT NULL,
    producto_key INT NOT NULL,
    canal_key INT NOT NULL,
    vendedor_key INT NOT NULL,
    region_cliente_key INT NOT NULL,
    region_venta_key INT NOT NULL,
    orden_id NVARCHAR(20) NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(12,2) NOT NULL,
    total DECIMAL(14,2) NOT NULL,
    CONSTRAINT PK_Hecho_Ventas PRIMARY KEY (orden_id),
    CONSTRAINT FK_Hecho_Ventas_tiempo_key FOREIGN KEY (tiempo_key) REFERENCES dbo.Dim_Tiempo (tiempo_key),
    CONSTRAINT FK_Hecho_Ventas_mes_key FOREIGN KEY (mes_key) REFERENCES dbo.Dim_Mes (mes_key),
    CONSTRAINT FK_Hecho_Ventas_cliente_key FOREIGN KEY (cliente_key) REFERENCES dbo.Dim_Cliente (cliente_key),
    CONSTRAINT FK_Hecho_Ventas_producto_key FOREIGN KEY (producto_key) REFERENCES dbo.Dim_Producto (producto_key),
    CONSTRAINT FK_Hecho_Ventas_canal_key FOREIGN KEY (canal_key) REFERENCES dbo.Dim_Canal (canal_key),
    CONSTRAINT FK_Hecho_Ventas_vendedor_key FOREIGN KEY (vendedor_key) REFERENCES dbo.Dim_Vendedor (vendedor_key),
    CONSTRAINT FK_Hecho_Ventas_region_cliente_key FOREIGN KEY (region_cliente_key) REFERENCES dbo.Dim_Region (region_key),
    CONSTRAINT FK_Hecho_Ventas_region_venta_key FOREIGN KEY (region_venta_key) REFERENCES dbo.Dim_Region (region_key)
);
CREATE TABLE dbo.Hecho_Finanzas_Mensual (
    mes_key INT NOT NULL,
    ingresos DECIMAL(14,2) NOT NULL,
    costo_ventas DECIMAL(14,2) NOT NULL,
    gastos_operativos DECIMAL(14,2) NOT NULL,
    utilidad_neta DECIMAL(14,2) NOT NULL,
    flujo_caja DECIMAL(14,2) NOT NULL,
    inversiones_realizadas DECIMAL(14,2) NOT NULL,
    retorno_inversion DECIMAL(12,6) NOT NULL,
    CONSTRAINT PK_Hecho_Finanzas_Mensual PRIMARY KEY (mes_key),
    CONSTRAINT FK_Hecho_Finanzas_Mensual_mes_key FOREIGN KEY (mes_key) REFERENCES dbo.Dim_Mes (mes_key)
);
CREATE TABLE dbo.Hecho_Trafico_Web (
    cliente_key INT NOT NULL,
    region_cliente_key INT NOT NULL,
    anio SMALLINT NOT NULL,
    visitas_web INT NOT NULL,
    conversiones_web INT NOT NULL,
    CONSTRAINT PK_Hecho_Trafico_Web PRIMARY KEY (cliente_key, anio),
    CONSTRAINT FK_Hecho_Trafico_Web_cliente_key FOREIGN KEY (cliente_key) REFERENCES dbo.Dim_Cliente (cliente_key),
    CONSTRAINT FK_Hecho_Trafico_Web_region_cliente_key FOREIGN KEY (region_cliente_key) REFERENCES dbo.Dim_Region (region_key)
);
CREATE TABLE dbo.Etl_Rechazos (
    rechazo_id INT NOT NULL,
    hoja NVARCHAR(50) NOT NULL,
    fila_excel INT NOT NULL,
    llave_origen NVARCHAR(50) NULL,
    causa NVARCHAR(300) NOT NULL,
    CONSTRAINT PK_Etl_Rechazos PRIMARY KEY (rechazo_id)
);
CREATE TABLE dbo.Etl_Observaciones (
    observacion_id INT NOT NULL,
    hoja NVARCHAR(50) NOT NULL,
    fila_excel INT NOT NULL,
    llave_origen NVARCHAR(50) NULL,
    tipo NVARCHAR(50) NOT NULL,
    detalle NVARCHAR(300) NOT NULL,
    CONSTRAINT PK_Etl_Observaciones PRIMARY KEY (observacion_id)
);
