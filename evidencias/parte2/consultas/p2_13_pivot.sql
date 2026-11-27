-- Pivot: los trimestres pasan a columnas
SELECT categoria, [1] AS T1, [2] AS T2, [3] AS T3, [4] AS T4
FROM (
    SELECT p.categoria, t.trimestre, v.total
    FROM dbo.Hecho_Ventas v
    JOIN dbo.Dim_Tiempo t ON t.tiempo_key = v.tiempo_key
    JOIN dbo.Dim_Producto p ON p.producto_key = v.producto_key
) AS origen
PIVOT (SUM(total) FOR trimestre IN ([1], [2], [3], [4])) AS pv
ORDER BY categoria;
