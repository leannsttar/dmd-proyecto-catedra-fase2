-- Roll-up: de trimestre a año, con el total general
SELECT COALESCE(p.categoria, N'Total') AS categoria, t.anio, SUM(v.total) AS ventas
FROM dbo.Hecho_Ventas v
JOIN dbo.Dim_Tiempo t ON t.tiempo_key = v.tiempo_key
JOIN dbo.Dim_Producto p ON p.producto_key = v.producto_key
GROUP BY t.anio, ROLLUP (p.categoria)
ORDER BY GROUPING(p.categoria), p.categoria;
