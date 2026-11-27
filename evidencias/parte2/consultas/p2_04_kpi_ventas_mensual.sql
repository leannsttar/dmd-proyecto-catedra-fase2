-- KPIs de Ventas por mes y crecimiento respecto al mes anterior
SELECT nombre_mes, ventas, ordenes, ticket_promedio, participacion_ecommerce_pct,
       crecimiento_ventas_pct, mes_parcial
FROM dbo.vw_KPI_Ventas_Mensual
ORDER BY mes_key;
