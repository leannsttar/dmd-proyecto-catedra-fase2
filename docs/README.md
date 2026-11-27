# Documentación: material para el informe

**Qué es esta carpeta:** textos y tablas listos para adaptar al PDF de la entrega. Cada archivo indica a qué sección del informe sirve.

**Para quién:** quien redacte el informe y cualquiera que necesite entender una decisión del diseño.

## Qué usar en cada sección del informe

El PDF de la Fase 2 pide 6 secciones; la rúbrica además evalúa definición del problema, cronograma, ortografía y puntualidad.

| Sección del informe | Qué usar | Dónde |
|---|---|---|
| 1. Documentación y presentación | Portada formal y capturas de cada etapa (cada README dice qué capturar) | Los README de cada carpeta |
| 2. Recolección y preparación (ETL) | ETL en Pentaho con su verificación, capturas listas, reglas de limpieza, perfilado del Excel y reporte de carga | [`../pentaho/README.md`](../pentaho/README.md), [`img/etl/`](img/etl/), [reglas_limpieza.md](reglas_limpieza.md), `../data/sample/perfil_atributos.md`, `../data/sample/reporte_carga.md` |
| 3. Cálculo de KPIs | Fórmula, grano, valor 2024 y comprobación manual de cada KPI | [kpis.md](kpis.md), `../sql/kpis/02_consultas_kpi.sql` |
| 4. Herramientas y técnicas | Cubo, operadores OLAP, K-means | `../olap/README.md`, `../sql/olap/02_operadores_olap.sql`, `../mining/README.md` |
| 5. Especificaciones del diseño (final) | Diagrama, diccionario de datos y **cambios respecto a la Fase 1 con su justificación** | [esquema_estrella.md](esquema_estrella.md), [diccionario_datos.md](diccionario_datos.md), [decisiones.md](decisiones.md) |
| 6. Reportes e interpretación | Páginas del dashboard e interpretación para Andina | `../powerbi/README.md` |
| Todas | Qué concepto de cada clase (unidades 1 a 5) se aplicó y dónde, para citar el material del curso | [marco_teorico.md](marco_teorico.md) |

## Archivos

| Archivo | Qué es |
|---|---|
| [diccionario_datos.md](diccionario_datos.md) | Cada tabla y columna: tipo, llave, **de qué columna del Excel sale** y su clasificación (Clase 5). Se genera desde `etl/contrato.py`: no editarlo a mano |
| [esquema_estrella.md](esquema_estrella.md) | Diagrama del modelo, grano, volúmenes y jerarquías. También está el diagrama original de la Fase 1 (`esquema_estrella_fase1.png`) |
| [reglas_limpieza.md](reglas_limpieza.md) | Cada problema del Excel, la regla que lo trata y cuántos casos hubo |
| [kpis.md](kpis.md) | Los 10 KPIs: fórmula, unidad, valor 2024 y notas (p. ej. diciembre incompleto) |
| [decisiones.md](decisiones.md) | En qué se apartó la implementación de la Fase 1 y por qué. **Algunas siguen abiertas** (Pentaho vs. Python, Power BI en vivo vs. importación) |
| [marco_teorico.md](marco_teorico.md) | Mapa clase → concepto → dónde se aplica → sección del informe |
