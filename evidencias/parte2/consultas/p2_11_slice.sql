-- Slice: solo el canal E-commerce
SELECT p.categoria, t.trimestre, SUM(v.total) AS ventas_ecommerce
FROM dbo.Hecho_Ventas v
JOIN dbo.Dim_Tiempo t ON t.tiempo_key = v.tiempo_key
JOIN dbo.Dim_Producto p ON p.producto_key = v.producto_key
JOIN dbo.Dim_Canal c ON c.canal_key = v.canal_key
WHERE c.canal = N'E-commerce'
GROUP BY p.categoria, t.trimestre
ORDER BY p.categoria, t.trimestre;
