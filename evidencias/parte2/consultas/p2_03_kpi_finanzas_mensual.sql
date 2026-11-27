-- KPIs de Finanzas por mes y alerta de margen bruto < 40 %
SELECT nombre_mes, ingresos, margen_bruto_pct, margen_neto_pct, indice_gastos_operativos_pct,
       roi_pct, flujo_caja, flujo_caja_acumulado, alerta_margen_bruto
FROM dbo.vw_KPI_Finanzas_Mensual
ORDER BY mes_key;
