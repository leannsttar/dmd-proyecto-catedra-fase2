-- Dice: subcubo de 2 categorías, 2 regiones y 2 trimestres
SELECT p.categoria, r.region AS region_venta, t.trimestre, SUM(v.total) AS ventas
FROM dbo.Hecho_Ventas v
JOIN dbo.Dim_Tiempo t ON t.tiempo_key = v.tiempo_key
JOIN dbo.Dim_Producto p ON p.producto_key = v.producto_key
JOIN dbo.Dim_Region r ON r.region_key = v.region_venta_key
WHERE p.categoria IN (N'Electrónica', N'Línea Blanca')
  AND r.region IN (N'Región Central', N'Región Occidental')
  AND t.trimestre IN (3, 4)
GROUP BY p.categoria, r.region, t.trimestre
ORDER BY p.categoria, r.region, t.trimestre;
