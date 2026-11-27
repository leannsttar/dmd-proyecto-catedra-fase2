-- Consulta base: ventas por categoría y trimestre
SELECT p.categoria, t.trimestre, SUM(v.total) AS ventas
FROM dbo.Hecho_Ventas v
JOIN dbo.Dim_Tiempo t ON t.tiempo_key = v.tiempo_key
JOIN dbo.Dim_Producto p ON p.producto_key = v.producto_key
GROUP BY p.categoria, t.trimestre
ORDER BY p.categoria, t.trimestre;
