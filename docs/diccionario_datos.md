# Diccionario de datos

> Generado por `python -m etl.generar` desde `etl/contrato.py`. No editar a mano.

Convenciones: **PK** llave primaria, **FK** llave foránea, montos en USD. La columna *Origen* es el mapeo origen → destino (Clase 7) y la *Clasificación* sigue los tipos de hechos y dimensiones de la Clase 5. Diagrama y relaciones: [esquema_estrella.md](esquema_estrella.md).

## Dim_Mes

*Tipo:* dimension · *Grano:* Un mes calendario · *Clasificación:* Conformada (la comparten Hecho_Ventas y Hecho_Finanzas_Mensual) · SCD tipo 1

| Columna | Tipo | Nulo | Llave | Origen (Excel → destino) | Descripción |
|---|---|---|---|---|---|
| `mes_key` | INT | no | PK | Generada; Finanzas_Mensual.Mes y Ventas.Fecha se traducen a ella | Llave AAAAMM, p. ej. 202401 |
| `mes_numero` | TINYINT | no |  | Generado (calendario) | Número de mes, 1 a 12 |
| `nombre_mes` | NVARCHAR(20) | no |  | Generado (calendario) | Nombre del mes en español |
| `trimestre` | TINYINT | no |  | Generado (calendario) | Trimestre, 1 a 4 |
| `semestre` | TINYINT | no |  | Generado (calendario) | Semestre, 1 o 2 |
| `anio` | SMALLINT | no |  | Año fiscal de los datos (2024) | Año |

## Dim_Tiempo

*Tipo:* dimension · *Grano:* Un día calendario · *Clasificación:* Dimensión tiempo · SCD tipo 0 (calendario fijo)

| Columna | Tipo | Nulo | Llave | Origen (Excel → destino) | Descripción |
|---|---|---|---|---|---|
| `tiempo_key` | INT | no | PK | Generada; Ventas.Fecha se traduce a ella | Llave AAAAMMDD, p. ej. 20240131 |
| `fecha` | DATE | no |  | Generado: los 366 días del año fiscal | Fecha del día |
| `dia_semana` | NVARCHAR(10) | no |  | Generado (calendario) | Nombre del día en español (Lunes..Domingo) |
| `mes_numero` | TINYINT | no |  | Generado (calendario) | Número de mes, 1 a 12 |
| `nombre_mes` | NVARCHAR(20) | no |  | Generado (calendario) | Nombre del mes en español |
| `trimestre` | TINYINT | no |  | Generado (calendario) | Trimestre, 1 a 4 |
| `semestre` | TINYINT | no |  | Generado (calendario) | Semestre, 1 o 2 |
| `anio` | SMALLINT | no |  | Generado (calendario) | Año |

## Dim_Cliente

*Tipo:* dimension · *Grano:* Un cliente · *Clasificación:* SCD tipo 1 (la carga total sobrescribe; no guarda historia del segmento)

| Columna | Tipo | Nulo | Llave | Origen (Excel → destino) | Descripción |
|---|---|---|---|---|---|
| `cliente_key` | INT | no | PK | Generada por el ETL | Llave sustituta |
| `cliente_id` | NVARCHAR(20) | no |  | Clientes.ClienteID | Código original del cliente (CLI-0001) |
| `nombre` | NVARCHAR(100) | no |  | Clientes.Nombre | Nombre; solo descriptivo, NO es único |
| `segmento` | NVARCHAR(30) | no |  | Clientes.Segmento | Segmento del Excel: Consumidor, Pyme o Corporativo |
| `fecha_registro` | DATE | no |  | Clientes.FechaRegistro (texto → DATE) | Fecha de registro del cliente |
| `segmento_cluster` | INT | sí |  | K-means: mining/output/segmentos_cliente.csv | Grupo asignado por K-means (parte 3); NULL hasta que exista |

## Dim_Producto

*Tipo:* dimension · *Grano:* Un producto · *Clasificación:* SCD tipo 1

| Columna | Tipo | Nulo | Llave | Origen (Excel → destino) | Descripción |
|---|---|---|---|---|---|
| `producto_key` | INT | no | PK | Generada por el ETL | Llave sustituta |
| `producto` | NVARCHAR(100) | no |  | Ventas.Producto | Nombre del producto |
| `categoria` | NVARCHAR(50) | no |  | Ventas.Categoria | Categoría: Cómputo, Electrónica, Hogar o Línea Blanca |

## Dim_Canal

*Tipo:* dimension · *Grano:* Un canal de venta · *Clasificación:* SCD tipo 1

| Columna | Tipo | Nulo | Llave | Origen (Excel → destino) | Descripción |
|---|---|---|---|---|---|
| `canal_key` | INT | no | PK | Generada por el ETL | Llave sustituta |
| `canal` | NVARCHAR(30) | no |  | Ventas.Canal | Tienda física o E-commerce |

## Dim_Vendedor

*Tipo:* dimension · *Grano:* Un equipo de venta · *Clasificación:* SCD tipo 1

| Columna | Tipo | Nulo | Llave | Origen (Excel → destino) | Descripción |
|---|---|---|---|---|---|
| `vendedor_key` | INT | no | PK | Generada por el ETL | Llave sustituta |
| `equipo` | NVARCHAR(50) | no |  | Ventas.Vendedor | Equipo que registra la venta |

## Dim_Region

*Tipo:* dimension · *Grano:* Una región (dimensión con dos roles en Hecho_Ventas) · *Clasificación:* Role-playing (región del cliente y región de la venta) · SCD tipo 1

| Columna | Tipo | Nulo | Llave | Origen (Excel → destino) | Descripción |
|---|---|---|---|---|---|
| `region_key` | INT | no | PK | Generada por el ETL | Llave sustituta |
| `region` | NVARCHAR(50) | no |  | Ventas.Region ∪ Clientes.Region | Nombre de la región |

## Hecho_Ventas

*Tipo:* hecho · *Grano:* Una orden de venta (cada orden tiene un solo producto) · *Clasificación:* Transaction fact table (máximo detalle); orden_id es dimensión degenerada

| Columna | Tipo | Nulo | Llave | Origen (Excel → destino) | Descripción |
|---|---|---|---|---|---|
| `tiempo_key` | INT | no | FK → Dim_Tiempo.tiempo_key | Ventas.Fecha → AAAAMMDD | Fecha de la orden |
| `mes_key` | INT | no | FK → Dim_Mes.mes_key | Ventas.Fecha → AAAAMM | Mes de la orden: Dim_Mes es la dimensión conformada que comparte con Hecho_Finanzas_Mensual |
| `cliente_key` | INT | no | FK → Dim_Cliente.cliente_key | Ventas.ClienteID → Dim_Cliente | Cliente que compra |
| `producto_key` | INT | no | FK → Dim_Producto.producto_key | Ventas.Producto → Dim_Producto | Producto vendido |
| `canal_key` | INT | no | FK → Dim_Canal.canal_key | Ventas.Canal → Dim_Canal | Canal de la venta |
| `vendedor_key` | INT | no | FK → Dim_Vendedor.vendedor_key | Ventas.Vendedor → Dim_Vendedor | Equipo que vende |
| `region_cliente_key` | INT | no | FK → Dim_Region.region_key | Clientes.Region (vía Ventas.ClienteID) → Dim_Region | Región asignada al cliente (hoja Clientes) |
| `region_venta_key` | INT | no | FK → Dim_Region.region_key | Ventas.Region → Dim_Region | Región donde se realizó la venta (hoja Ventas) |
| `orden_id` | NVARCHAR(20) | no | PK | Ventas.OrdenID | Dimensión degenerada: código de la orden (AR-20001) |
| `cantidad` | INT | no |  | Ventas.Cantidad | Unidades vendidas (aditiva) |
| `precio_unitario` | DECIMAL(12,2) | no |  | Ventas.PrecioUnitario | Precio unitario en USD (no aditiva: usar total/cantidad) |
| `total` | DECIMAL(14,2) | no |  | Recalculado: Cantidad × PrecioUnitario (Ventas.Total es fórmula) | cantidad × precio_unitario en USD (aditiva) |

## Hecho_Finanzas_Mensual

*Tipo:* hecho · *Grano:* Un mes de resultados financieros · *Clasificación:* Periodic snapshot fact table (mensual)

| Columna | Tipo | Nulo | Llave | Origen (Excel → destino) | Descripción |
|---|---|---|---|---|---|
| `mes_key` | INT | no | PK FK → Dim_Mes.mes_key | Finanzas_Mensual.Mes (nombre → número) → AAAAMM | Mes del resultado |
| `ingresos` | DECIMAL(14,2) | no |  | Finanzas_Mensual.Ingresos | Ingresos del mes, USD |
| `costo_ventas` | DECIMAL(14,2) | no |  | Finanzas_Mensual.CostoVentas | Costo de ventas, USD |
| `gastos_operativos` | DECIMAL(14,2) | no |  | Finanzas_Mensual.GastosOperativos | Gastos operativos, USD |
| `utilidad_neta` | DECIMAL(14,2) | no |  | Recalculada: Ingresos − CostoVentas − GastosOperativos | ingresos − costo_ventas − gastos_operativos, USD |
| `flujo_caja` | DECIMAL(14,2) | no |  | Finanzas_Mensual.FlujoCaja | Flujo de caja del mes, USD |
| `inversiones_realizadas` | DECIMAL(14,2) | no |  | Finanzas_Mensual.InversionesRealizadas | Inversiones del mes, USD |
| `retorno_inversion` | DECIMAL(12,6) | no |  | Recalculado: UtilidadNeta ÷ InversionesRealizadas | utilidad_neta ÷ inversiones_realizadas, como razón (0.94); no aditiva |

## Hecho_Trafico_Web

*Tipo:* hecho · *Grano:* Un cliente por año · *Clasificación:* Periodic snapshot fact table (anual); anio es dimensión degenerada

| Columna | Tipo | Nulo | Llave | Origen (Excel → destino) | Descripción |
|---|---|---|---|---|---|
| `cliente_key` | INT | no | PK FK → Dim_Cliente.cliente_key | Clientes.ClienteID → Dim_Cliente | Cliente |
| `region_cliente_key` | INT | no | FK → Dim_Region.region_key | Clientes.Region → Dim_Region | Región del cliente |
| `anio` | SMALLINT | no | PK | Año del encabezado (VisitasWeb2024) | Dimensión degenerada: año de los totales |
| `visitas_web` | INT | no |  | Clientes.VisitasWeb2024 | Visitas web del año |
| `conversiones_web` | INT | no |  | Clientes.ConversionesWeb2024 | Conversiones web del año |

## Etl_Rechazos

*Tipo:* control · *Grano:* Una fila de origen que no se cargó · *Clasificación:* Tabla de control del ETL (fuera del modelo)

| Columna | Tipo | Nulo | Llave | Origen (Excel → destino) | Descripción |
|---|---|---|---|---|---|
| `rechazo_id` | INT | no | PK | ETL | Consecutivo |
| `hoja` | NVARCHAR(50) | no |  | ETL | Hoja de origen |
| `fila_excel` | INT | no |  | ETL | Número de fila en el Excel (1 = encabezado) |
| `llave_origen` | NVARCHAR(50) | sí |  | ETL | OrdenID, ClienteID o Mes de la fila |
| `causa` | NVARCHAR(300) | no |  | ETL | Motivo del rechazo |

## Etl_Observaciones

*Tipo:* control · *Grano:* Un dato cargado que requiere revisión · *Clasificación:* Tabla de control del ETL (fuera del modelo)

| Columna | Tipo | Nulo | Llave | Origen (Excel → destino) | Descripción |
|---|---|---|---|---|---|
| `observacion_id` | INT | no | PK | ETL | Consecutivo |
| `hoja` | NVARCHAR(50) | no |  | ETL | Hoja de origen |
| `fila_excel` | INT | no |  | ETL | Número de fila en el Excel (1 = encabezado) |
| `llave_origen` | NVARCHAR(50) | sí |  | ETL | OrdenID, ClienteID o Mes de la fila |
| `tipo` | NVARCHAR(50) | no |  | ETL | Categoría de la observación |
| `detalle` | NVARCHAR(300) | no |  | ETL | Descripción |
