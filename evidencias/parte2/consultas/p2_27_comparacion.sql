-- KPIs anuales en SQL (misma fuente que el cubo)
SELECT anio, margen_bruto_pct, margen_neto_pct, indice_gastos_operativos_pct, roi_pct, flujo_caja_acumulado,
       ventas_por_cliente, tasa_conversion_web_pct, ticket_promedio, participacion_ecommerce_pct,
       ventas_total, ordenes, clientes
FROM dbo.vw_KPI_Anual;
