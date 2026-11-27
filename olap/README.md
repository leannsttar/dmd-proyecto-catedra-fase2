# Parte 2 (cubo): cubo OLAP en SSAS

**Qué es esta carpeta:** el **cubo SSAS multidimensional** que prometió la Fase 1, ya construido, y cómo montarlo en otra computadora.

**Para quién:** cualquiera del equipo que necesite desplegar el cubo, por ejemplo para navegarlo en la defensa o conectarlo desde Power BI.

## Qué hay

| Pieza | Archivo |
|---|---|
| Proyecto SSAS (Visual Studio) | `ssas/AndinaRetail_Cubo/` (abrir `AndinaRetail_Cubo.slnx`) |
| KPIs como miembros calculados (MDX) | `ssas/kpis_calculados.mdx`, ya incluido en el cubo |
| Despliegue y procesamiento | `ssas/desplegar_cubo.ps1` |
| Permiso de lectura del servicio SSAS | `ssas/permiso_servicio_ssas.sql` |
| Cubo ROLAP en SQL (respaldo) | `dbo.vw_Cubo_Ventas` y `sql/olap/02_operadores_olap.sql` |

Evidencias, resultados y problemas resueltos: [`evidencias/parte2/README.md`](../evidencias/parte2/README.md).

## Diseño del cubo

- **Data source:** SQL Server `localhost`, base `AndinaRetailDW`, con la cuenta del servicio.
- **Vista de datos (DSV):** las 10 tablas del DW. Las 11 relaciones salen de las llaves foráneas.
- **Dimensiones y jerarquías:**
  - *Tiempo* (Dim_Tiempo), jerarquía `Calendario`: Anio → Semestre → Trimestre → Nombre Mes → Fecha. Las claves de nivel llevan el año (`2024-T4`, `2024-11`) para que no se mezclen periodos de años distintos.
  - *Mes* (Dim_Mes), jerarquía `Calendario`: Anio → Trimestre → Mes.
  - *Producto*, jerarquía `Categorias`: Categoria → Producto.
  - *Cliente*: Segmento y Segmento Cluster (grupo de K-means).
  - *Canal* y *Region*.
  - *Vendedor* no se incluyó porque ningún KPI la usa.
- **Grupos de medidas:**
  - *Hecho Ventas*: Total, Cantidad y Hecho Ventas Count (= órdenes).
  - *Ventas Clientes Distintos*: Clientes Distintos, el conteo distinto de `cliente_key`. Va en un grupo aparte porque un conteo distinto no se puede sumar entre celdas.
  - *Hecho Finanzas Mensual*: Ingresos, Costo Ventas, Gastos Operativos, Utilidad Neta, Flujo Caja e Inversiones Realizadas. No incluye `retorno_inversion`, porque un porcentaje no se suma: el ROI se recalcula en MDX.
  - *Hecho Trafico Web*: Visitas Web y Conversiones Web.
- **Uso de dimensiones:**
  - *Region* aparece dos veces en Ventas: *Region Venta* por `region_venta_key` y *Region Cliente* por `region_cliente_key`.
  - *Mes* es la dimensión conformada entre Ventas y Finanzas (`mes_key`).
  - *Tiempo* solo se relaciona con Ventas.
- **Miembros calculados** (`kpis_calculados.mdx`): Ticket Promedio, Ventas por Cliente, Participacion Ecommerce, Crecimiento Ventas, Margen Bruto, Margen Neto, Indice Gastos Operativos, ROI, Flujo Caja Acumulado y Tasa Conversion Web. Cada razón se calcula desde sumas.

## Cómo montarlo en otra computadora

Requisitos:
- SQL Server con el servicio *SQL Server Analysis Services* en modo **Multidimensional**.
- Visual Studio con la extensión *Analysis Services Projects*.

1. **Carga la base.** `.venv\Scripts\python -m etl.run_etl` debe dar `OK`.
2. **Da permiso al servicio SSAS.** Ejecuta `olap/ssas/permiso_servicio_ssas.sql` en SSMS (una vez por computadora).
3. **Compila.** En Visual Studio, abre `olap/ssas/AndinaRetail_Cubo/AndinaRetail_Cubo.slnx` y elige **Build**. Se genera `bin/AndinaRetail_Cubo.asdatabase`.
4. **Despliega y procesa** desde la raíz del repo:
   ```powershell
   powershell -ExecutionPolicy Bypass -File olap\ssas\desplegar_cubo.ps1
   ```
   El script envía el cubo a `localhost`, ejecuta ProcessFull e imprime Total, órdenes y clientes. Deben dar `705113.8 · 850 · 120`.

   No uses el botón Deploy de Visual Studio: con SQL Server 2025 *Standard Developer* falla con *"The current edition 'StandardDeveloper64' … is not supported by the client"*. El script hace lo mismo con el proveedor MSOLAP, que sí reconoce esa edición.
5. **Verifica los KPIs.** En SSMS, conéctate a Analysis Services (`localhost`) y elige la base `AndinaRetail_Cubo` en el combo de bases. Ejecuta `evidencias/parte2/consultas/p2_26_mdx_kpis.mdx` y compara con `SELECT * FROM dbo.vw_KPI_Anual`. Los 12 valores deben coincidir.

## Detalles que conviene saber al consultar el cubo

- **Ventas y finanzas por periodo:** usa la jerarquía `[Mes].[Calendario]`. Las medidas de Finanzas no se relacionan con *Tiempo* (su grano es mensual), así que cortadas por *Tiempo* muestran el total del año en cada fila.
- **Flujo Caja Acumulado:** es un acumulado desde el inicio del año (`PERIODSTODATE`). Necesita un año o un mes en contexto, por ejemplo `WHERE [Mes].[Calendario].[Anio].&[2024]`. En el total general sale vacío.
- **Crecimiento Ventas:** solo tiene valor en el nivel *Nombre Mes* de *Tiempo*, porque compara cada mes con el anterior.

## Respaldo ROLAP

`dbo.vw_Cubo_Ventas` precalcula en SQL todas las combinaciones con `ROLLUP` y `CUBE`, es decir, un cubo ROLAP (Clase 10). Sirve como evidencia de análisis multidimensional si no hay SSAS disponible, por ejemplo en otra computadora:

```sql
-- Ventas por categoría y canal (el resto de dimensiones en "Todos")
SELECT categoria, canal, ventas, ordenes, ticket_promedio
FROM dbo.vw_Cubo_Ventas
WHERE anio IS NULL   -- total general del ROLLUP (con un solo año, es igual al total de 2024)
  AND nivel_todas_categorias = 0 AND nivel_todos_canales = 0
  AND nivel_todas_regiones = 1 AND nivel_todos_segmentos = 1 AND nivel_todos_clusters = 1
ORDER BY categoria, canal;
```
