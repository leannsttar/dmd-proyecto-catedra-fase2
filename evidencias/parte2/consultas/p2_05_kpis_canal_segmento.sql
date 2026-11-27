-- Ticket promedio y participación por canal
SELECT c.canal, SUM(v.total) AS ventas, COUNT(*) AS ordenes,
       CAST(SUM(v.total) / COUNT(*) AS DECIMAL(14,2)) AS ticket_promedio,
       CAST(100.0 * SUM(v.total) / SUM(SUM(v.total)) OVER () AS DECIMAL(5,2)) AS participacion_pct
FROM dbo.Hecho_Ventas v
JOIN dbo.Dim_Canal c ON c.canal_key = v.canal_key
GROUP BY c.canal;

-- Tasa de conversión web por segmento y grupo K-means
SELECT cl.segmento, cl.segmento_cluster,
       SUM(w.visitas_web) AS visitas, SUM(w.conversiones_web) AS conversiones,
       CAST(100.0 * SUM(w.conversiones_web) / NULLIF(SUM(w.visitas_web), 0) AS DECIMAL(5,2)) AS tasa_conversion_pct
FROM dbo.Hecho_Trafico_Web w
JOIN dbo.Dim_Cliente cl ON cl.cliente_key = w.cliente_key
GROUP BY cl.segmento, cl.segmento_cluster
ORDER BY cl.segmento, cl.segmento_cluster;
