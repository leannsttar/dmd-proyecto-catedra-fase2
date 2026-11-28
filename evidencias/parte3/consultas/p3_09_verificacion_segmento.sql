-- Clientes por grupo K-means: una sola asignación por cliente y ninguno sin grupo
SELECT CASE WHEN GROUPING(segmento_cluster) = 1 THEN 'Total' ELSE CAST(segmento_cluster AS VARCHAR(5)) END AS segmento_cluster,
       COUNT(*) AS clientes,
       COUNT(DISTINCT cliente_id) AS clientes_distintos
FROM dbo.Dim_Cliente
GROUP BY ROLLUP (segmento_cluster)
ORDER BY GROUPING(segmento_cluster), segmento_cluster;

SELECT SUM(CASE WHEN segmento_cluster IS NULL THEN 1 ELSE 0 END) AS sin_grupo,
       COUNT(*) - COUNT(DISTINCT cliente_id) AS clientes_repetidos
FROM dbo.Dim_Cliente;
