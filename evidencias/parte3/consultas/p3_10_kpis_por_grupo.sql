-- KPIs de venta por grupo K-means
SELECT c.segmento_cluster,
       COUNT(DISTINCT c.cliente_key) AS clientes,
       COUNT(*) AS ordenes,
       SUM(v.total) AS ventas,
       CAST(SUM(v.total) / COUNT(*) AS DECIMAL(10,2)) AS ticket_promedio,
       CAST(SUM(v.total) / COUNT(DISTINCT c.cliente_key) AS DECIMAL(10,2)) AS ventas_por_cliente,
       CAST(100.0 * SUM(CASE WHEN ca.canal = 'E-commerce' THEN v.total ELSE 0 END) / SUM(v.total) AS DECIMAL(5,2)) AS pct_ecommerce,
       CAST(100.0 * SUM(v.total) / SUM(SUM(v.total)) OVER () AS DECIMAL(5,2)) AS pct_ventas
FROM dbo.Hecho_Ventas v
JOIN dbo.Dim_Cliente c ON c.cliente_key = v.cliente_key
JOIN dbo.Dim_Canal ca ON ca.canal_key = v.canal_key
GROUP BY c.segmento_cluster
ORDER BY c.segmento_cluster;
