# Evidencias · Parte 2 (KPIs y cubo OLAP)

Qué se hizo en la Parte 2, qué resultado dio y qué captura lo respalda. Las consultas están en [`consultas/`](consultas/) tal como se ejecutaron y las capturas en [`capturas/`](capturas/).

**Valores de referencia** (`dbo.vw_KPI_Anual`, año 2024): margen bruto 41.57 % · margen neto 26.90 % · gastos operativos 14.66 % · ROI 106.71 % · flujo de caja acumulado $450,917.68 · ventas por cliente $5,875.95 · ticket promedio $829.55 · participación e-commerce 44.00 % · conversión web 9.01 % · ventas $705,113.80 · 850 órdenes · 120 clientes.

## Pasos y resultados

| # | Qué se hizo | Consulta o archivo | Resultado obtenido | Captura |
|---|---|---|---|---|
| 0 | Comprobar el entorno y que la Parte 1 dejó la base cargada | `python -m etl.run_etl`; `SELECT @@VERSION` | ETL `OK` (0 rechazos). SQL Server 2025 (17.0.1000.7) y Analysis Services 17.0 en modo multidimensional | — |
| 1 | KPIs anuales de 2024 leídos de `vw_KPI_Anual`, y código de la vista con las fórmulas | `consultas/p2_01_kpi_anual.sql`; `sql/kpis/01_vistas_kpi.sql` | 41.57 · 26.90 · 14.66 · 106.71 · 450917.68 · 5875.95 · 829.55 · 44.00 · 9.01 · 705113.80 · 850 · 120 | `p2_01_kpi_anual.png`, `p2_02_vista_kpi_anual_sql.png` |
| 2 | KPIs de Finanzas por mes, con alerta de margen bruto < 40 % | `consultas/p2_03_kpi_finanzas_mensual.sql` | 12 meses. Alerta solo en marzo (39.08), abril (39.50) y mayo (38.54). El flujo acumulado de diciembre (450917.68) es igual al KPI anual | `p2_03_kpi_finanzas_mensual.png` |
| 3 | KPIs de Ventas por mes, con crecimiento respecto al mes anterior | `consultas/p2_04_kpi_ventas_mensual.sql` | 12 meses. Crecimiento mínimo en mayo (−22.84 %) y máximo en octubre (+49.08 %). Diciembre (−56.13 %) se marca como mes parcial. Las órdenes suman 850 | `p2_04_kpi_ventas_mensual.png` |
| 4 | KPIs por canal y conversión web por segmento y grupo K-means | `consultas/p2_05_kpis_canal_segmento.sql` | E-commerce: 310238.22 · 353 órdenes · ticket 878.86 · 44.00 %. Tienda física: 394875.58 · 497 · 794.52 · 56.00 %. Segmento × grupo: 25,374 visitas y 2,285 conversiones (9.01 %) | `p2_05_kpis_canal_segmento.png` |
| 5 | Comprobación de dos KPIs en el Excel de origen | Margen bruto `=(SUM(B2:B13)-SUM(C2:C13))/SUM(B2:B13)`; ticket `=SUM(I2:I851)/COUNTA(A2:A851)` | 41.57 % y 829.55, iguales a `vw_KPI_Anual` | `p2_06_excel_margen_bruto.png`, `p2_07_excel_ticket.png` |
| 6 | Los 5 operadores OLAP en SQL sobre el esquema estrella, a partir de ventas por categoría × trimestre | `consultas/p2_08_olap_base.sql` a `p2_13_pivot.sql`; `sql/olap/02_operadores_olap.sql` | Base: 16 filas. Drill-down a mes: 48 filas (los 3 meses de Cómputo suman su T1, 21744.45). Roll-up: total 705113.80. Slice (e-commerce): 16 filas. Dice (Electrónica, Región Central, T3): 13211.08. Pivot: 4 × 4 | `p2_08_olap_base.png` a `p2_13_pivot.png` |
| 7 | Cubo ROLAP `vw_Cubo_Ventas` (ROLLUP sobre tiempo y CUBE sobre 5 dimensiones): corte categoría × canal y celda "Todos" | `consultas/p2_14_cubo_rolap.sql` | Celda "Todos": 705113.80 · 850 · 829.55, igual que `vw_KPI_Anual` | `p2_15_cubo_rolap.png` |
| 8 | Permiso de lectura para la cuenta del servicio de Analysis Services | `consultas/p2_16_permiso_ssas.sql` | `NT Service\MSSQLServerOLAPService` en `db_datareader` de `AndinaRetailDW` | — |
| 9 | Proyecto SSAS `olap/ssas/AndinaRetail_Cubo`: data source y vista de datos (DSV) con las 10 tablas del DW | `AndinaRetailDW.ds`, `DSV_AndinaRetail.dsv` | Conexión correcta. 11 relaciones tomadas de las llaves foráneas: Región dos veces en Ventas (región de la venta y del cliente) y Mes en Ventas y Finanzas | `p2_16_datasource.png`, `p2_16b_test_conexion.png`, `p2_16c_connection_manager.png`, `p2_17_dsv.png` |
| 10 | 6 dimensiones con jerarquías. Tiempo: Anio → Semestre → Trimestre → Nombre Mes → Fecha. Mes: Anio → Trimestre → Mes. Producto: Categoria → Producto. Además Cliente (segmento y grupo K-means), Canal y Region. Las claves de nivel incluyen el año (p. ej. `2024-T4`) | `Tiempo.dim`, `Mes.dim`, `Producto.dim`, `Cliente.dim`, `Canal.dim`, `Region.dim` | Las 6 dimensiones abren sin advertencias. Vendedor no se incluyó porque ningún KPI la usa | `p2_18_dim_tiempo.png`, `p2_19_dim_producto.png` |
| 11 | Cubo `Cubo Ventas`: un grupo de medidas por hecho (Ventas, Finanzas mensual, Tráfico web) y otro para `Clientes Distintos` (conteo distinto de `cliente_key`). Se excluyeron `retorno_inversion` y `precio_unitario`, que no se pueden sumar | `Cubo Ventas.cube` | `Hecho Ventas Count` = 850 órdenes; `Clientes Distintos` = 120 | `p2_20_estructura_cubo.png` |
| 12 | Uso de dimensiones: Región con dos roles (Region Venta y Region Cliente); Mes como dimensión conformada entre Ventas y Finanzas; Tiempo solo en Ventas | `Cubo Ventas.cube` (Dimension Usage) | Coincide con el diseño del DW | `p2_21_dimension_usage.png` |
| 13 | 10 miembros calculados en MDX: Ticket Promedio, Ventas por Cliente, Participación E-commerce, Crecimiento Ventas, Margen Bruto, Margen Neto, Índice Gastos Operativos, ROI, Flujo Caja Acumulado y Tasa Conversión Web. Cada razón se calcula desde sumas | `olap/ssas/kpis_calculados.mdx` | Script sin errores; el cubo guarda los 10 `CREATE MEMBER` | `p2_22_calculos.png` |
| 14 | Build, despliegue y procesamiento completo (MOLAP) | `olap/ssas/desplegar_cubo.ps1` | Tras procesar: Total 705113.8 · 850 órdenes · 120 clientes, igual que `vw_KPI_Anual` | `p2_23a_deploy_error_edicion.png`, `p2_23_deploy_proceso.png` |
| 15 | Navegación del cubo (Browser): drill-down por la jerarquía Calendario, con Total y Ticket Promedio | Visual Studio, pestaña Browser | Los 12 meses coinciden con SQL sobre `Hecho_Ventas` (p. ej., enero 64264.33 y 931.37; diciembre 30550.46 y 745.13). La suma de los meses es 705113.80 | `p2_25_browser.png` |
| 16 | KPIs del cubo en MDX comparados con la vista SQL | `consultas/p2_26_mdx_kpis.mdx`, `consultas/p2_27_comparacion.sql` | Los 12 valores coinciden: 41.57 % · 26.90 % · 14.66 % · 106.71 % · $450,917.68 · $5,875.95 · 9.01 % · $829.55 · 44.00 % · 705113.8 · 850 · 120 | `p2_26_mdx_kpis.png`, `p2_27_comparacion.png` |

## Problemas técnicos y cómo se resolvieron

**P1 · Filtros con tildes devolvían 0 filas en sqlcmd.** El DICE filtra por `N'Región Central'` y `N'Electrónica'`. Los archivos `.sql` están en UTF-8 sin BOM y sqlcmd los lee con la página de códigos de Windows, así que `Región` llegaba como `RegiÃ³n`. Solución: ejecutar con `sqlcmd -f 65001`, que devolvió las 8 filas esperadas.

**P2 · El roll-up repetía cada subtotal.** `GROUP BY ROLLUP (p.categoria, t.anio, t.trimestre)` generaba una fila "2024" y otra "todos los años" con el mismo valor, porque el DW tiene un solo año. Solución: `GROUP BY t.anio, ROLLUP (p.categoria)`, que da 4 categorías y el total del año (705,113.80). Corregido en `sql/olap/02_operadores_olap.sql`.

**P3 · La cuenta del servicio de Analysis Services no podía leer el DW.** El data source usa la cuenta del servicio (`NT Service\MSSQLServerOLAPService`), que no tenía usuario en `AndinaRetailDW`, así que el procesamiento habría fallado. Solución: `consultas/p2_16_permiso_ssas.sql` la agrega a `db_datareader` (solo lectura). Hay que ejecutarlo una vez en cada computadora.

**P4 · El data source no tenía base de datos.** La cadena de conexión no incluía `Initial Catalog`, así que la vista de datos habría mostrado las tablas de `master`. Solución: en el diseñador del data source, *Initial catalog* = `AndinaRetailDW`.

**P5 · Deploy de Visual Studio rechazó la edición del servidor.** En la máquina donde se construyó el cubo, Deploy falló con "The current edition 'StandardDeveloper64' … is not supported by the client": la extensión de Analysis Services de Visual Studio no reconoció la edición Standard Developer de SQL Server 2025. Solución: `olap/ssas/desplegar_cubo.ps1` envía al servidor la definición que compila Visual Studio (`bin/AndinaRetail_Cubo.asdatabase`) mediante el proveedor MSOLAP, ejecuta ProcessFull y comprueba los totales.

**P6 · El script MDX fallaba por un `;` de más.** Visual Studio agrega `;` al final del script, y como el script ya terminaba en `;` quedaba una sentencia vacía. Solución: `olap/ssas/kpis_calculados.mdx` no termina en `;`.

**P7 · Los KPIs de Finanzas no cambian por mes en la dimensión Tiempo.** No es un error. `Hecho_Finanzas_Mensual` tiene grano mensual y se relaciona con la dimensión conformada Mes, no con Tiempo (día). Una dimensión no relacionada devuelve el total del grupo de medidas. Para cruzar ventas y finanzas por periodo se usa la jerarquía `[Mes].[Calendario]`.

**P8 · Flujo Caja Acumulado sale vacío sin un año en contexto.** El miembro usa `PERIODSTODATE([Mes].[Calendario].[Anio], …)`, un acumulado desde el inicio del año; en el total general no hay año desde donde sumar. Solución: consultar con `WHERE [Mes].[Calendario].[Anio].&[2024]`.
