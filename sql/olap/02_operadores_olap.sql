-- Operadores OLAP (Clase 15.4, UIA4) sobre el esquema estrella: evidencia para el informe.
-- Cada consulta parte de la misma pregunta base y aplica un operador. No las ejecuta el ETL.
-- Pregunta base: ventas por categoría y trimestre de 2024.

-- 0. Consulta base: categoría × trimestre
SELECT p.categoria, t.trimestre, SUM(v.total) AS ventas
FROM dbo.Hecho_Ventas v
JOIN dbo.Dim_Tiempo t ON t.tiempo_key = v.tiempo_key
JOIN dbo.Dim_Producto p ON p.producto_key = v.producto_key
GROUP BY p.categoria, t.trimestre
ORDER BY p.categoria, t.trimestre;

-- 1. DRILL (down): más detalle siguiendo la jerarquía de tiempo, de trimestre a mes
SELECT p.categoria, t.trimestre, t.mes_numero, t.nombre_mes, SUM(v.total) AS ventas
FROM dbo.Hecho_Ventas v
JOIN dbo.Dim_Tiempo t ON t.tiempo_key = v.tiempo_key
JOIN dbo.Dim_Producto p ON p.producto_key = v.producto_key
GROUP BY p.categoria, t.trimestre, t.mes_numero, t.nombre_mes
ORDER BY p.categoria, t.mes_numero;

-- 2. ROLL (up): menos detalle, de trimestre al año; ROLLUP agrega además el total general
SELECT COALESCE(p.categoria, N'Total') AS categoria, t.anio, SUM(v.total) AS ventas
FROM dbo.Hecho_Ventas v
JOIN dbo.Dim_Tiempo t ON t.tiempo_key = v.tiempo_key
JOIN dbo.Dim_Producto p ON p.producto_key = v.producto_key
GROUP BY t.anio, ROLLUP (p.categoria)
ORDER BY GROUPING(p.categoria), p.categoria;

-- 3. SLICE: se fija UNA dimensión en un valor (canal = E-commerce) y se mira el resto
SELECT p.categoria, t.trimestre, SUM(v.total) AS ventas_ecommerce
FROM dbo.Hecho_Ventas v
JOIN dbo.Dim_Tiempo t ON t.tiempo_key = v.tiempo_key
JOIN dbo.Dim_Producto p ON p.producto_key = v.producto_key
JOIN dbo.Dim_Canal c ON c.canal_key = v.canal_key
WHERE c.canal = N'E-commerce'
GROUP BY p.categoria, t.trimestre
ORDER BY p.categoria, t.trimestre;

-- 4. DICE: subcubo con condiciones en VARIAS dimensiones
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

-- 5. PIVOT: se reorientan los ejes (trimestres pasan a columnas)
SELECT categoria, [1] AS T1, [2] AS T2, [3] AS T3, [4] AS T4
FROM (
    SELECT p.categoria, t.trimestre, v.total
    FROM dbo.Hecho_Ventas v
    JOIN dbo.Dim_Tiempo t ON t.tiempo_key = v.tiempo_key
    JOIN dbo.Dim_Producto p ON p.producto_key = v.producto_key
) AS origen
PIVOT (SUM(total) FOR trimestre IN ([1], [2], [3], [4])) AS pv
ORDER BY categoria;
