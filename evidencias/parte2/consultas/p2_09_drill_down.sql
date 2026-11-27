-- Drill-down: de trimestre a mes
SELECT p.categoria, t.trimestre, t.mes_numero, t.nombre_mes, SUM(v.total) AS ventas
FROM dbo.Hecho_Ventas v
JOIN dbo.Dim_Tiempo t ON t.tiempo_key = v.tiempo_key
JOIN dbo.Dim_Producto p ON p.producto_key = v.producto_key
GROUP BY p.categoria, t.trimestre, t.mes_numero, t.nombre_mes
ORDER BY p.categoria, t.mes_numero;
