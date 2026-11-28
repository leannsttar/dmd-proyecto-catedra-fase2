# Evidencias · Parte 3 (segmentación de clientes con K-means)

Qué se hizo en la Parte 3, qué resultado dio y qué captura lo respalda. Las consultas están en [`consultas/`](consultas/) tal como se ejecutaron y las capturas en [`capturas/`](capturas/). El análisis completo está en [`mining/01_kmeans_clientes.ipynb`](../../mining/01_kmeans_clientes.ipynb).

**Resultado:** 120 clientes en 3 grupos, con las 7 variables de la Fase 1 y k elegido con el codo y la silueta (k = 3, silueta 0.19). Cada cliente tiene un solo grupo, guardado en `Dim_Cliente.segmento_cluster`, y los KPIs de venta se pueden filtrar por grupo en SQL y en el cubo.

| Grupo | Nombre | Clientes | Venta total promedio | Órdenes promedio | Ticket promedio | % e-commerce promedio |
|---|---|---|---|---|---|---|
| 1 | Compra poco y en tienda | 44 | $3,233.89 | 5.57 | $566.17 | 28.44 % |
| 2 | Ticket alto y en línea | 19 | $6,192.78 | 4.79 | $1,314.80 | 56.01 % |
| 3 | Frecuentes y de mayor gasto | 57 | $7,809.82 | 9.02 | $872.15 | 44.53 % |

## Pasos y resultados

| # | Qué se hizo (fase KDD) | Consulta o archivo | Resultado obtenido | Captura |
|---|---|---|---|---|
| 1 | Selección: el notebook lee las tablas del Datawarehouse (`FUENTE=bd`) | Notebook, celda 1 | 10 tablas; 120 clientes y 850 ventas | `p3_01_seleccion_datos.png` |
| 2 | Preparación: 7 variables por cliente (venta total, órdenes, ticket, % e-commerce, categorías, visitas web, conversión) | Notebook, celda 2 | 120 filas, sin nulos; venta por cliente promedio $5,875.95 (= KPI) | `p3_02_variables.png` |
| 3 | Correlación entre variables | Notebook, celda 3 | La más alta es 0.71 (venta total y órdenes); ninguna repite a otra, así que se mantienen las 7. Las variables web casi no se relacionan con las de compra | `p3_03_correlacion.png` |
| 4 | Transformación y minería: estandarización y K-means para k = 3 a 6, con codo y silueta | Notebook, celda 5 | Silueta 0.19 · 0.17 · 0.15 · 0.15; la mejor es k = 3. El codo no muestra un quiebre claro | `p3_04_eleccion_k.png` |
| 5 | Modelo final (k = 3, semilla 42) | Notebook, celda 7 | Grupos de 44, 19 y 57 clientes | `p3_05_modelo_final.png` |
| 6 | Evaluación e interpretación: perfil de cada grupo frente al promedio | Notebook, celda 9 | Grupo 1 bajo en todo; grupo 2 con ticket alto (+1.4 desv.) y más e-commerce; grupo 3 con más órdenes y categorías | `p3_06_perfil_grupos.png` |
| 7 | ¿Los grupos repiten el Segmento del Excel? | Notebook, celda 10 | No: cada grupo mezcla Consumidor, Pyme y Corporativo, así que K-means aporta una segmentación nueva | `p3_07_cruce_segmento.png` |
| 8 | Nombre de cada grupo | Notebook, celda 11; `mining/output/perfil_segmentos.csv` | "Compra poco y en tienda", "Ticket alto y en línea" y "Frecuentes y de mayor gasto" | `p3_08_perfil_nombres.png` |
| 9 | Difusión: el grupo de cada cliente está en `Dim_Cliente.segmento_cluster` (lo carga el ETL desde `mining/output/segmentos_cliente.csv`) | `consultas/p3_09_verificacion_segmento.sql` | 44 + 19 + 57 = 120; 0 clientes sin grupo y 0 repetidos | `p3_09_verificacion_segmento.png` |
| 10 | KPIs de venta por grupo en SQL | `consultas/p3_10_kpis_por_grupo.sql` | El grupo 3 hace el 63.13 % de las ventas; el grupo 2 tiene el ticket más alto ($1,293.00) | `p3_10_kpis_por_grupo.png` |
| 11 | Los mismos KPIs en el cubo SSAS, por el atributo `Segmento Cluster` | `consultas/p3_11_cubo_por_grupo.mdx` | Iguales a SQL en los 3 grupos y en el total (705113.80 · 850 · 120 · $829.55) | `p3_11_cubo_por_grupo.png` |

**Prueba de sensibilidad (no cambia el resultado):** sin las dos variables web, la silueta con k = 3 sube a 0.28. Se mantuvieron las 7 variables de la Fase 1 porque los grupos se describen igual de bien y así el resultado coincide con lo propuesto.
