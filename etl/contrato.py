"""Contrato de datos del Datawarehouse de Andina Retail Corp.

Es la única fuente de verdad del esquema estrella: nombres de tablas y columnas,
tipos, llaves y descripción. Lo usan el ETL (orden y tipos de columnas), la
validación (compara la BD contra este contrato) y el generador del diccionario
de datos (docs/diccionario_datos.md).

Si cambias algo aquí, cambia también sql/ddl/01_tablas.sql y regenera el
diccionario con:  python -m etl.generar_diccionario
"""

from dataclasses import dataclass


@dataclass(frozen=True)
class Columna:
    nombre: str
    tipo_sql: str
    descripcion: str
    pk: bool = False
    fk: str | None = None  # "Tabla.columna" referenciada
    nula: bool = False
    origen: str = ""  # columna(s) del Excel o regla que la produce (mapeo origen → destino, Clase 7)


@dataclass(frozen=True)
class Tabla:
    nombre: str
    tipo: str  # "dimension" | "hecho" | "control"
    grano: str
    columnas: tuple[Columna, ...]
    clasificacion: str = ""  # tipo de hecho o de dimensión (Clase 5)

    @property
    def nombres(self) -> list[str]:
        return [c.nombre for c in self.columnas]


C = Columna

DIM_MES = Tabla(
    "Dim_Mes", "dimension", "Un mes calendario",
    (
        C("mes_key", "INT", "Llave AAAAMM, p. ej. 202401", pk=True, origen="Generada; Finanzas_Mensual.Mes y Ventas.Fecha se traducen a ella"),
        C("mes_numero", "TINYINT", "Número de mes, 1 a 12", origen="Generado (calendario)"),
        C("nombre_mes", "NVARCHAR(20)", "Nombre del mes en español", origen="Generado (calendario)"),
        C("trimestre", "TINYINT", "Trimestre, 1 a 4", origen="Generado (calendario)"),
        C("semestre", "TINYINT", "Semestre, 1 o 2", origen="Generado (calendario)"),
        C("anio", "SMALLINT", "Año", origen="Año fiscal de los datos (2024)"),
    ),
    clasificacion="Conformada (la comparten Hecho_Ventas y Hecho_Finanzas_Mensual) · SCD tipo 1",
)

DIM_TIEMPO = Tabla(
    "Dim_Tiempo", "dimension", "Un día calendario",
    (
        C("tiempo_key", "INT", "Llave AAAAMMDD, p. ej. 20240131", pk=True, origen="Generada; Ventas.Fecha se traduce a ella"),
        C("fecha", "DATE", "Fecha del día", origen="Generado: los 366 días del año fiscal"),
        C("dia_semana", "NVARCHAR(10)", "Nombre del día en español (Lunes..Domingo)", origen="Generado (calendario)"),
        C("mes_numero", "TINYINT", "Número de mes, 1 a 12", origen="Generado (calendario)"),
        C("nombre_mes", "NVARCHAR(20)", "Nombre del mes en español", origen="Generado (calendario)"),
        C("trimestre", "TINYINT", "Trimestre, 1 a 4", origen="Generado (calendario)"),
        C("semestre", "TINYINT", "Semestre, 1 o 2", origen="Generado (calendario)"),
        C("anio", "SMALLINT", "Año", origen="Generado (calendario)"),
    ),
    clasificacion="Dimensión tiempo · SCD tipo 0 (calendario fijo)",
)

DIM_CLIENTE = Tabla(
    "Dim_Cliente", "dimension", "Un cliente",
    (
        C("cliente_key", "INT", "Llave sustituta", pk=True, origen="Generada por el ETL"),
        C("cliente_id", "NVARCHAR(20)", "Código original del cliente (CLI-0001)", origen="Clientes.ClienteID"),
        C("nombre", "NVARCHAR(100)", "Nombre; solo descriptivo, NO es único", origen="Clientes.Nombre"),
        C("segmento", "NVARCHAR(30)", "Segmento del Excel: Consumidor, Pyme o Corporativo", origen="Clientes.Segmento"),
        C("fecha_registro", "DATE", "Fecha de registro del cliente", origen="Clientes.FechaRegistro (texto → DATE)"),
        C("segmento_cluster", "INT", "Grupo asignado por K-means (parte 3); NULL hasta que exista", nula=True, origen="K-means: mining/output/segmentos_cliente.csv"),
    ),
    clasificacion="SCD tipo 1 (la carga total sobrescribe; no guarda historia del segmento)",
)

DIM_PRODUCTO = Tabla(
    "Dim_Producto", "dimension", "Un producto",
    (
        C("producto_key", "INT", "Llave sustituta", pk=True, origen="Generada por el ETL"),
        C("producto", "NVARCHAR(100)", "Nombre del producto", origen="Ventas.Producto"),
        C("categoria", "NVARCHAR(50)", "Categoría: Cómputo, Electrónica, Hogar o Línea Blanca", origen="Ventas.Categoria"),
    ),
    clasificacion="SCD tipo 1",
)

DIM_CANAL = Tabla(
    "Dim_Canal", "dimension", "Un canal de venta",
    (
        C("canal_key", "INT", "Llave sustituta", pk=True, origen="Generada por el ETL"),
        C("canal", "NVARCHAR(30)", "Tienda física o E-commerce", origen="Ventas.Canal"),
    ),
    clasificacion="SCD tipo 1",
)

DIM_VENDEDOR = Tabla(
    "Dim_Vendedor", "dimension", "Un equipo de venta",
    (
        C("vendedor_key", "INT", "Llave sustituta", pk=True, origen="Generada por el ETL"),
        C("equipo", "NVARCHAR(50)", "Equipo que registra la venta", origen="Ventas.Vendedor"),
    ),
    clasificacion="SCD tipo 1",
)

DIM_REGION = Tabla(
    "Dim_Region", "dimension", "Una región (dimensión con dos roles en Hecho_Ventas)",
    (
        C("region_key", "INT", "Llave sustituta", pk=True, origen="Generada por el ETL"),
        C("region", "NVARCHAR(50)", "Nombre de la región", origen="Ventas.Region ∪ Clientes.Region"),
    ),
    clasificacion="Role-playing (región del cliente y región de la venta) · SCD tipo 1",
)

HECHO_VENTAS = Tabla(
    "Hecho_Ventas", "hecho", "Una orden de venta (cada orden tiene un solo producto)",
    (
        C("tiempo_key", "INT", "Fecha de la orden", fk="Dim_Tiempo.tiempo_key", origen="Ventas.Fecha → AAAAMMDD"),
        C("mes_key", "INT", "Mes de la orden: Dim_Mes es la dimensión conformada que comparte con Hecho_Finanzas_Mensual", fk="Dim_Mes.mes_key", origen="Ventas.Fecha → AAAAMM"),
        C("cliente_key", "INT", "Cliente que compra", fk="Dim_Cliente.cliente_key", origen="Ventas.ClienteID → Dim_Cliente"),
        C("producto_key", "INT", "Producto vendido", fk="Dim_Producto.producto_key", origen="Ventas.Producto → Dim_Producto"),
        C("canal_key", "INT", "Canal de la venta", fk="Dim_Canal.canal_key", origen="Ventas.Canal → Dim_Canal"),
        C("vendedor_key", "INT", "Equipo que vende", fk="Dim_Vendedor.vendedor_key", origen="Ventas.Vendedor → Dim_Vendedor"),
        C("region_cliente_key", "INT", "Región asignada al cliente (hoja Clientes)", fk="Dim_Region.region_key", origen="Clientes.Region (vía Ventas.ClienteID) → Dim_Region"),
        C("region_venta_key", "INT", "Región donde se realizó la venta (hoja Ventas)", fk="Dim_Region.region_key", origen="Ventas.Region → Dim_Region"),
        C("orden_id", "NVARCHAR(20)", "Dimensión degenerada: código de la orden (AR-20001)", pk=True, origen="Ventas.OrdenID"),
        C("cantidad", "INT", "Unidades vendidas (aditiva)", origen="Ventas.Cantidad"),
        C("precio_unitario", "DECIMAL(12,2)", "Precio unitario en USD (no aditiva: usar total/cantidad)", origen="Ventas.PrecioUnitario"),
        C("total", "DECIMAL(14,2)", "cantidad × precio_unitario en USD (aditiva)", origen="Recalculado: Cantidad × PrecioUnitario (Ventas.Total es fórmula)"),
    ),
    clasificacion="Transaction fact table (máximo detalle); orden_id es dimensión degenerada",
)

HECHO_FINANZAS = Tabla(
    "Hecho_Finanzas_Mensual", "hecho", "Un mes de resultados financieros",
    (
        C("mes_key", "INT", "Mes del resultado", pk=True, fk="Dim_Mes.mes_key", origen="Finanzas_Mensual.Mes (nombre → número) → AAAAMM"),
        C("ingresos", "DECIMAL(14,2)", "Ingresos del mes, USD", origen="Finanzas_Mensual.Ingresos"),
        C("costo_ventas", "DECIMAL(14,2)", "Costo de ventas, USD", origen="Finanzas_Mensual.CostoVentas"),
        C("gastos_operativos", "DECIMAL(14,2)", "Gastos operativos, USD", origen="Finanzas_Mensual.GastosOperativos"),
        C("utilidad_neta", "DECIMAL(14,2)", "ingresos − costo_ventas − gastos_operativos, USD", origen="Recalculada: Ingresos − CostoVentas − GastosOperativos"),
        C("flujo_caja", "DECIMAL(14,2)", "Flujo de caja del mes, USD", origen="Finanzas_Mensual.FlujoCaja"),
        C("inversiones_realizadas", "DECIMAL(14,2)", "Inversiones del mes, USD", origen="Finanzas_Mensual.InversionesRealizadas"),
        C("retorno_inversion", "DECIMAL(12,6)", "utilidad_neta ÷ inversiones_realizadas, como razón (0.94); no aditiva", origen="Recalculado: UtilidadNeta ÷ InversionesRealizadas"),
    ),
    clasificacion="Periodic snapshot fact table (mensual)",
)

HECHO_TRAFICO = Tabla(
    "Hecho_Trafico_Web", "hecho", "Un cliente por año",
    (
        C("cliente_key", "INT", "Cliente", pk=True, fk="Dim_Cliente.cliente_key", origen="Clientes.ClienteID → Dim_Cliente"),
        C("region_cliente_key", "INT", "Región del cliente", fk="Dim_Region.region_key", origen="Clientes.Region → Dim_Region"),
        C("anio", "SMALLINT", "Dimensión degenerada: año de los totales", pk=True, origen="Año del encabezado (VisitasWeb2024)"),
        C("visitas_web", "INT", "Visitas web del año", origen="Clientes.VisitasWeb2024"),
        C("conversiones_web", "INT", "Conversiones web del año", origen="Clientes.ConversionesWeb2024"),
    ),
    clasificacion="Periodic snapshot fact table (anual); anio es dimensión degenerada",
)

ETL_RECHAZOS = Tabla(
    "Etl_Rechazos", "control", "Una fila de origen que no se cargó",
    (
        C("rechazo_id", "INT", "Consecutivo", pk=True),
        C("hoja", "NVARCHAR(50)", "Hoja de origen"),
        C("fila_excel", "INT", "Número de fila en el Excel (1 = encabezado)"),
        C("llave_origen", "NVARCHAR(50)", "OrdenID, ClienteID o Mes de la fila", nula=True),
        C("causa", "NVARCHAR(300)", "Motivo del rechazo"),
    ),
    clasificacion="Tabla de control del ETL (fuera del modelo)",
)

ETL_OBSERVACIONES = Tabla(
    "Etl_Observaciones", "control", "Un dato cargado que requiere revisión",
    (
        C("observacion_id", "INT", "Consecutivo", pk=True),
        C("hoja", "NVARCHAR(50)", "Hoja de origen"),
        C("fila_excel", "INT", "Número de fila en el Excel (1 = encabezado)"),
        C("llave_origen", "NVARCHAR(50)", "OrdenID, ClienteID o Mes de la fila", nula=True),
        C("tipo", "NVARCHAR(50)", "Categoría de la observación"),
        C("detalle", "NVARCHAR(300)", "Descripción"),
    ),
    clasificacion="Tabla de control del ETL (fuera del modelo)",
)

# Orden de carga: dimensiones (respetando sus FK), hechos y control.
TABLAS: tuple[Tabla, ...] = (
    DIM_MES, DIM_TIEMPO, DIM_CLIENTE, DIM_PRODUCTO, DIM_CANAL, DIM_VENDEDOR, DIM_REGION,
    HECHO_VENTAS, HECHO_FINANZAS, HECHO_TRAFICO,
    ETL_RECHAZOS, ETL_OBSERVACIONES,
)
POR_NOMBRE = {t.nombre: t for t in TABLAS}
