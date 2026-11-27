-- Los KPIs anuales de 2024 leídos de dbo.vw_KPI_Anual.

SELECT k.n AS [#], k.area, k.kpi, k.valor, k.unidad
FROM dbo.vw_KPI_Anual AS a
CROSS APPLY (VALUES
    (1, N'Finanzas', N'Margen bruto',                CAST(a.margen_bruto_pct             AS DECIMAL(14,2)), N'%'),
    (2, N'Finanzas', N'Margen neto',                 CAST(a.margen_neto_pct              AS DECIMAL(14,2)), N'%'),
    (3, N'Finanzas', N'Índice de gastos operativos', CAST(a.indice_gastos_operativos_pct AS DECIMAL(14,2)), N'%'),
    (4, N'Finanzas', N'ROI',                         CAST(a.roi_pct                      AS DECIMAL(14,2)), N'%'),
    (5, N'Finanzas', N'Flujo de caja acumulado',     CAST(a.flujo_caja_acumulado         AS DECIMAL(14,2)), N'USD'),
    (6, N'Ventas',   N'Ventas por cliente',          CAST(a.ventas_por_cliente           AS DECIMAL(14,2)), N'USD'),
    (7, N'Ventas',   N'Ticket promedio',             CAST(a.ticket_promedio              AS DECIMAL(14,2)), N'USD'),
    (8, N'Ventas',   N'Participación del e-commerce',CAST(a.participacion_ecommerce_pct  AS DECIMAL(14,2)), N'%'),
    (9, N'Web',      N'Tasa de conversión web',      CAST(a.tasa_conversion_web_pct      AS DECIMAL(14,2)), N'%'),
    (10, N'Control', N'Ventas totales',              CAST(a.ventas_total                 AS DECIMAL(14,2)), N'USD'),
    (11, N'Control', N'Órdenes',                     CAST(a.ordenes                      AS DECIMAL(14,2)), N'órdenes'),
    (12, N'Control', N'Clientes con compra',         CAST(a.clientes                     AS DECIMAL(14,2)), N'clientes')
) AS k (n, area, kpi, valor, unidad)
ORDER BY k.n;
