# Entrega de la Fase 2: qué se entrega y cómo se evalúa

Fuentes: enunciado `Proyecto_Catedra_Fase2_Estudiante.pdf`, actividad del Aula Digital, *Ruta de Aprendizaje - DMD941.pdf* y retroalimentación de la Fase 1 (revisados el 26 nov 2026).

## Qué se entrega

**Viernes 27 de noviembre de 2026, 11:59 p. m.**, por el enlace de la actividad *Proyecto de Cátedra — Fase 2* del Aula Digital. La actividad **cierra a esa hora** (no acepta entregas tarde).

1. **Un solo PDF** con las seis secciones desarrolladas: el Google Doc del equipo exportado (*Archivo → Descargar → PDF*).
2. **El enlace a un video** que demuestre que la solución completa funciona, desde los datos crudos hasta los reportes. Va en el doc (sección *Video de demostración*) y también en el comentario de la entrega.
3. **Defensa oral, obligatoria y virtual.** La fecha aún no se anuncia; se publicará en el foro del curso.

> **Ojo:** en el Aula Digital la actividad **no está configurada como entrega de grupo**. Para no arriesgar la nota de nadie, **cada integrante sube el mismo PDF y el mismo enlace** desde su cuenta.

No hay checkpoints pendientes: los de la Fase 2 (C1 y C2) nunca se abrieron en el aula. El foro de la Fase 2 no tiene mensajes.

## Rúbrica: 9 criterios, cada uno de 0 a 10

Escala de la **Ruta de Aprendizaje** (más detallada que la del enunciado, que omite un nivel):

| Nivel | Nota | Qué significa |
|---|---|---|
| Inicial | 0.00–3.99 | Criterio no completado |
| Básico | 4.00–5.99 | Criterio incompleto |
| Competente | 6.00–7.99 | Parcialmente completo, con errores visibles |
| Destacado | 8.00–8.99 | Completo, pero se detectan errores |
| **Estratégico** | **9.00–10.00** | **Completo y sin errores** |

Es decir: **completo no basta para 9–10, tiene que estar sin errores.** Un `[Completar]` olvidado, una figura sin citar o una falta de ortografía bajan el criterio a Destacado (8–8.99).

Además de la rúbrica, la Ruta lista como criterios de evaluación de la Fase 2: **«Solución y configuración adecuada de todos los ejercicios establecidos»** y **«Defensa de las fases del proyecto»**, y dice que «la defensa se realizará mediante la elaboración de un video que demuestre y garantice el correcto funcionamiento de la solución». O sea, el video **es** la defensa (más la defensa oral virtual que anuncia el enunciado). Grupos de 4 estudiantes.

| # | Criterio | Dónde está en el doc | Estado (26 nov, 19:10) | Responsable |
|---|---|---|---|---|
| 1 | Documentación y presentación | Portada, Tabla 1, **Figura 1 (arquitectura)**, evidencia gráfica de **cada** etapa | Portada lista. Evidencia del ETL lista (Figuras 2–6). Falta Figura 1 y la evidencia de KPIs, cubo, K-means y Power BI; faltan 4 celdas de la Tabla 1 | Todos |
| 2 | Definición del problema | Sección inicial | ✅ Escrita | — |
| 3 | Recolección y preparación de datos | Sección 2 (2.1–2.4) | ✅ Completa con 5 figuras y la Tabla 3 | Parte 1 ✅ |
| 4 | Definición (cálculo) de KPIs | Sección 3, Tabla 4 | ❌ Faltan los 10 valores, la evidencia de las consultas y los meses bajo el umbral de 40 % | Parte 2 |
| 5 | Selección (aplicación) de herramientas y técnicas | 4.1 Cubo · 4.2 K-means · 4.3 Power BI | ❌ Las tres subsecciones están pendientes | Partes 2, 3 y 4 |
| 6 | Especificaciones del diseño | 5.1 figura · 5.2 · 5.3 | 5.2 ✅; 5.3 ✅ (5 ajustes, ETL incluido); falta la **figura del esquema estrella final** y la *Conexión de Power BI* | Parte 4 y quien haga la figura |
| 7 | Cronograma de trabajo | Tabla 6 | Filas 2–5 ✅. Faltan *Fechas reales* y *Quién lo hizo* de las filas 1 y 6–10 (12 celdas) | Cada parte su fila |
| 8 | Ortografía y gramática | Todo el doc | Revisar al final (acentos, mayúsculas, números con su unidad) | Quien exporte el PDF |
| 9 | Puntualidad y seguimiento de indicaciones | Entrega | PDF + enlace del video antes del 27 nov 23:59; cada integrante sube | Todos |

Lo que más pesa en lo que falta: los criterios 4 y 5 (KPIs y herramientas) son 2 de los 9 criterios y hoy están vacíos, y el criterio 1 depende de que **cada** etapa tenga capturas.

## Retroalimentación de la Fase 1 (93/100) que hay que cumplir

> «La llave primaria de Hecho_Ventas no necesita combinar todas las llaves foráneas; con orden_id (o una llave sustituta) basta, porque cada orden es única.»

✅ Aplicado (decisión D10): la llave primaria de `Hecho_Ventas` es ahora solo `orden_id`, y está explicado en la sección 5.3.

## Video de defensa (sugerencia de orden, unos 8 a 10 minutos)

| Bloque | Qué mostrar | Quién |
|---|---|---|
| 1. El problema | El Excel crudo y qué necesitan Finanzas y Ventas | Cualquiera |
| 2. ETL (≈1.5 min) | Job de Pentaho ejecutándose, `t05` con Step Metrics, validación y conteos en SQL Server. Guion en el README de `pentaho/` y en el texto del informe | Parte 1 |
| 3. KPIs y cubo | Consultas de los KPIs con su resultado; el cubo navegado con drill-down, roll-up, slice, dice y pivot | Parte 2 |
| 4. K-means | Codo, silueta y perfil de los grupos; el segmento ya dentro de `Dim_Cliente` | Parte 3 |
| 5. Power BI | Cada página del reporte, sus filtros y la interpretación para Andina | Parte 4 |
| 6. Cierre | Qué decisiones apoya la solución | Cualquiera |

El enunciado pide mostrar «el flujo completo, desde los datos crudos hasta los reportes finales».

## Antes de exportar el PDF (lista final)

- [ ] Ningún `[Completar]` en el doc y ningún texto resaltado en amarillo.
- [ ] Figuras numeradas en orden (Figura 1, 2, 3…) y cada una citada en el texto.
- [ ] Tabla de contenido actualizada (en Google Docs: clic en la tabla → actualizar).
- [ ] Enlace del video y enlace del repositorio (anexo) funcionando y públicos.
- [ ] Cronograma con las fechas reales y quién hizo cada actividad.
- [ ] PDF revisado por otra persona y subido por **cada** integrante antes de las 11:59 p. m.
