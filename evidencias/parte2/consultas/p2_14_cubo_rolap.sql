-- Cubo ROLAP (vw_Cubo_Ventas): ventas por categoría y canal, resto de dimensiones en "Todos"
SELECT categoria, canal, ventas, ordenes, ticket_promedio
FROM dbo.vw_Cubo_Ventas
WHERE anio IS NULL
  AND nivel_todas_categorias = 0 AND nivel_todos_canales = 0
  AND nivel_todas_regiones = 1 AND nivel_todos_segmentos = 1 AND nivel_todos_clusters = 1
ORDER BY categoria, canal;

-- Celda "Todos" del cubo: debe dar los KPIs anuales
SELECT ventas, ordenes, ticket_promedio
FROM dbo.vw_Cubo_Ventas
WHERE anio IS NULL
  AND nivel_todas_categorias = 1 AND nivel_todos_canales = 1
  AND nivel_todas_regiones = 1 AND nivel_todos_segmentos = 1 AND nivel_todos_clusters = 1;
