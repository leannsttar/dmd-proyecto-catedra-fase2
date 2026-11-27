# Parte 4: Power BI e interpretación

**Qué te toca:** armar el reporte de Power BI de Ventas y Finanzas de Andina Retail (5 páginas) y escribir qué significa cada página para el negocio.

**Qué ya está hecho y puedes usar tal cual:**

| Ya hecho | Dónde | Para qué te sirve |
|---|---|---|
| Los datos limpios del Excel (parte 1) | `data\sample\*.csv` y la base `AndinaRetailDW` | Es tu fuente de datos. Los CSV y la base tienen **exactamente** lo mismo |
| Las 10 consultas para cargar cada tabla, con los tipos de columna correctos | `powerbi\power_query\*.pq` | Las pegas en Power BI y no tienes que limpiar ni cambiar tipos |
| Las medidas DAX de los 10 KPIs, cada una con el valor que debe dar | `powerbi\medidas.dax` | Las pegas y compruebas que tu reporte cuadra |
| Los 10 KPIs calculados y verificados en SQL y en el cubo (parte 2) | `docs\kpis.md` | Son los valores "correctos" con los que comparas |
| Los grupos de clientes de K-means (parte 3) | Columna `segmento_cluster` de `Dim_Cliente` | Filtro "grupo K-means" en la página de Clientes |

> **No necesitas** Git, Pentaho, Visual Studio ni el cubo SSAS. El reporte se arma en modo **Importación** (decisión D5 en `docs/decisiones.md`).

## Qué entregas al informe (Google Doc)

| Dónde | Qué |
|---|---|
| **Sección 4.3** (Power BI como herramienta) | 2 o 3 párrafos: cómo se conectó a los datos, el modelo estrella en Power BI y las medidas DAX. Captura de la **vista de modelo** con las relaciones |
| **Sección 5** (diseño final) | Una línea sobre la conexión: Power BI en modo Importación desde SQL Server (o CSV), y por qué (D5) |
| **Sección 6** (reportes e interpretación) | Una captura por página + 1 o 2 frases de negocio por página |
| **Cronograma** | Tu fila: fecha real y quién lo hizo |
| **Video** | Un recorrido corto por las 5 páginas usando los filtros (ver `docs/entrega.md`) |

---

## Paso 0. Preparar tu computadora

Descarga el proyecto: [`docs/preparar_computadora.md`](../docs/preparar_computadora.md), paso 1. Con eso ya tienes los CSV y puedes empezar.

**¿CSV o SQL Server?** Las consultas leen cualquiera de los dos según un parámetro. Recomendación:

- **Empieza con CSV:** no hay que instalar ni cargar nada.
- **Al final, cambia a SQL Server** si quieres que el informe diga que Power BI lee del Datawarehouse (es lo que propuso la Fase 1). Para eso primero carga la base en tu SQL Server con los pasos 2 a 4 de `docs/preparar_computadora.md`, y luego cambias un solo parámetro (paso 7 de esta guía). Los números no cambian.

## Paso 1. Crear 4 parámetros

En Power BI Desktop, en el editor de Power Query (*Transformar datos*), crea 4 parámetros de tipo **Texto** (*Administrar parámetros → Nuevo*). Las consultas los usan para saber de dónde leer:

| Parámetro | Valor | Ojo |
|---|---|---|
| `FuenteDatos` | `CSV` | Cámbialo a `SQL` cuando quieras leer de la base |
| `CarpetaMuestra` | La ruta completa a `data\sample` en **tu** computadora, p. ej. `C:\dmd\dmd-proyecto-catedra-fase2\data\sample` | Sin `\` al final. Cópiala de la barra de direcciones del Explorador |
| `Servidor` | El nombre de tu servidor en SSMS (`localhost` o `localhost\SQLEXPRESS`) | Solo se usa con `SQL` |
| `BaseDatos` | `AndinaRetailDW` | Solo se usa con `SQL` |

Los nombres tienen que ser **exactamente** esos (mayúsculas incluidas), porque así los llaman las consultas.

## Paso 2. Cargar las 10 tablas

Por cada archivo de `powerbi\power_query\` (ábrelos con el Bloc de notas): crea una **consulta en blanco**, abre el **Editor avanzado**, borra lo que trae, pega el contenido del archivo y **renombra la consulta igual que el archivo**, sin `.pq` (`Hecho_Ventas`, `Dim_Cliente`, …). Al terminar las 10: *Cerrar y aplicar*.

**Comprobación rápida:** en la vista de datos, `Hecho_Ventas` debe tener **850 filas** y `Dim_Cliente` **120**.

Además, crea una **referencia** de la consulta `Dim_Region` y llámala `Dim_Region_Cliente` (la necesitas en el paso 3; abajo se explica por qué).

## Paso 3. Crear las relaciones

En la vista de modelo. Todas son **uno a muchos** con filtro en **una sola dirección** (de la dimensión al hecho). Si Power BI creó alguna sola y no está en esta tabla, bórrala.

| Desde (lado 1) | Hacia (lado muchos) | Columna |
|---|---|---|
| Dim_Mes | Hecho_Ventas | `mes_key` |
| Dim_Mes | Hecho_Finanzas_Mensual | `mes_key` |
| Dim_Tiempo | Hecho_Ventas | `tiempo_key` |
| Dim_Cliente | Hecho_Ventas | `cliente_key` |
| Dim_Cliente | Hecho_Trafico_Web | `cliente_key` |
| Dim_Producto | Hecho_Ventas | `producto_key` |
| Dim_Canal | Hecho_Ventas | `canal_key` |
| Dim_Vendedor | Hecho_Ventas | `vendedor_key` |
| Dim_Region | Hecho_Ventas | `region_venta_key` |
| Dim_Region_Cliente | Hecho_Ventas | `region_cliente_key` |
| Dim_Region_Cliente | Hecho_Trafico_Web | `region_cliente_key` |

Por qué está armado así (te sirve para la sección 4.3 y la defensa):

- **Es un esquema estrella:** las dimensiones solo se unen a los hechos, nunca entre ellas (Clase 3).
- **Dim_Mes une Ventas y Finanzas.** Para cualquier gráfico o filtro por mes usa **Dim_Mes**, no Dim_Tiempo: así un mismo filtro afecta ventas y finanzas. Dim_Tiempo es solo para el detalle por día.
- **Dos regiones:** cada venta tiene la región donde se vendió y la región del cliente, que son distintas en 638 de 850 órdenes. Power BI no permite dos relaciones activas entre las mismas dos tablas, por eso se duplica Dim_Region.
- **Hecho_Ventas y Hecho_Finanzas_Mensual no se relacionan entre sí.** Sus montos no concilian (ventas $705,113.80 vs. ingresos $2,331,474.57, está documentado); solo se comparan mes a mes por Dim_Mes.

Ajustes en el modelo:
- `Dim_Tiempo` → *Marcar como tabla de fechas*, columna `fecha`.
- En Dim_Tiempo y Dim_Mes, ordena `nombre_mes` por `mes_numero` (si no, los meses salen en orden alfabético).
- Oculta las columnas que terminan en `_key` en la vista de informe.

## Paso 4. Crear las medidas y comprobarlas

Crea una tabla vacía llamada `_Medidas` (*Especificar datos*, sin columnas útiles) y, dentro, una **nueva medida** por cada bloque de `medidas.dax`. Cada medida empieza con `Nombre =` y termina donde empieza la siguiente; las líneas con `//` son comentarios.

**Comprobación:** pon cada medida en una tarjeta **sin filtros**. Deben dar el número entre corchetes del archivo:

| Medida | Valor esperado | | Medida | Valor esperado |
|---|---|---|---|---|
| Ventas | 705,113.80 | | Margen bruto % | 41.57 % |
| Ordenes | 850 | | Margen neto % | 26.90 % |
| Ticket promedio | 829.55 | | Indice gastos operativos % | 14.66 % |
| Ventas por cliente | 5,875.95 | | ROI % | 106.71 % |
| Participacion e-commerce % | 44.00 % | | Flujo caja acumulado | 450,917.68 |
| Tasa conversion web % | 9.01 % | | | |

Para el crecimiento: tabla con `Dim_Mes[nombre_mes]`, `Crecimiento ventas %` y `Mes parcial`. Mayo debe dar −22.84 %, octubre +49.08 %, y solo diciembre debe tener `Mes parcial` = 1.

Si una tarjeta no cuadra, casi siempre es una relación mal hecha (revisa la tabla del paso 3) o un filtro de página olvidado.

## Paso 5. Armar las 5 páginas

Cada página responde una pregunta de negocio. Los visuales son una propuesta: puedes cambiarlos si responden mejor la pregunta. En todas las páginas pon segmentadores (filtros) de **mes y trimestre (Dim_Mes), categoría, canal, región, segmento y grupo K-means**.

| Página | Pregunta | Visuales sugeridos | Datos que ya sabemos y te sirven para interpretar |
|---|---|---|---|
| **Resumen** | ¿Cómo cerró 2024? | 10 tarjetas KPI; el margen bruto en rojo si < 40 % (medida `Alerta margen bruto`, en formato condicional) | Margen bruto 41.57 %, por encima de la meta de 40 % en el año. ROI 106.71 %: la utilidad supera lo invertido |
| **Ventas** | ¿Dónde crece, quién compra y por qué canal? | Línea de `Ventas` por `Dim_Mes[nombre_mes]` con leyenda `canal`; columnas de `Crecimiento ventas %` por mes; barras de ventas por `categoria`; matriz región de venta × región del cliente; `Ticket promedio` por canal | Mejor mes de crecimiento: octubre (+49.08 %); peor: mayo (−22.84 %). **Diciembre es parcial** (ventas hasta el día 20), su −56 % no es una caída real. Categoría que más vende: Línea Blanca ($236,368); la que menos: Cómputo ($85,987). E-commerce: 44 % de las ventas pero ticket más alto ($878.86 vs. $794.52 en tienda) |
| **Finanzas** | ¿Es rentable y hay liquidez mes a mes? | Líneas de `Margen bruto %` y `Margen neto %` por mes con una línea constante en 40 %; área de `Flujo caja acumulado`; `ROI %` por mes; columnas de ingresos, costo y gastos | El margen bruto cae **bajo el 40 %** en marzo (39.08 %), abril (39.50 %) y mayo (38.54 %): es la alerta que pidió Finanzas. El flujo acumulado cierra en $450,917.68 |
| **Clientes** | ¿Qué segmentos pesan más? | Ventas y ticket por `segmento` y por `segmento_cluster`; `Tasa conversion web %` por región del cliente y segmento | Pyme es el segmento que más compra ($278,174, 331 órdenes), luego Consumidor ($236,739) y Corporativo ($190,201). Conversión web total 9.01 %. Los nombres de los grupos K-means los pone la parte 3 |
| **Ventas vs. Ingresos** | ¿El crecimiento comercial acompaña al financiero? | Ventas (Hecho_Ventas) e ingresos (Finanzas) por `Dim_Mes[nombre_mes]`, en un gráfico de doble eje | Las dos cifras **no concilian** (ventas $705K vs. ingresos $2.33M): son fuentes distintas del Excel. Se compara la **tendencia**, no el monto. Pon una nota en la página |

Diseño (Clase 12): primero los datos, luego el formato, luego el boceto y al final la interactividad. Usa los mismos colores en todas las páginas y títulos que sean la pregunta.

## Paso 6. Interpretación (sección 6 del informe)

Por cada página, 1 o 2 frases que respondan **qué pasó, por qué y qué haría Andina** (Clase 17). Ejemplo para Finanzas: *"El margen bruto estuvo bajo la meta de 40 % solo de marzo a mayo (el mínimo fue mayo, 38.54 %) y se recuperó el resto del año. Andina debería revisar qué encareció el costo de ventas en ese trimestre para evitarlo en 2025."* Apóyate en los datos de la última columna de la tabla del paso 5 y en lo que veas con los filtros.

## Paso 7. (Opcional) Leer de SQL Server en vez de los CSV

1. Carga la base en tu SQL Server: `docs/preparar_computadora.md`, pasos 2 a 4.
2. En Power BI, cambia el parámetro `FuenteDatos` a `SQL` (y revisa `Servidor`) y pulsa **Actualizar**.
3. Si pregunta por el cifrado o el certificado, acepta la conexión (es un servidor local).

Las tarjetas deben seguir dando los mismos valores del paso 4.

## Los grupos de K-means (parte 3)

Trabaja con los grupos que ya están en los datos (`Dim_Cliente.segmento_cluster`, una corrida provisional con 3 grupos). La parte 3 se hace después y no cambia nada de tu reporte. En la página Clientes usa la columna tal cual; qué significa cada grupo lo explica la parte 3 en la sección 4.2.

## Si algo falla

| Problema | Qué hacer |
|---|---|
| `Expression.Error: The name 'CarpetaMuestra' wasn't recognized` (o `FuenteDatos`, `Servidor`) | Falta el parámetro o tiene otro nombre: revisa el paso 1, mayúsculas incluidas |
| `DataSource.Error: Could not find file …\Hecho_Ventas.csv` | `CarpetaMuestra` tiene mal la ruta. Debe terminar en `data\sample`, sin `\` al final |
| Una consulta da error de tipos o columnas | Revisa que pegaste el archivo completo y que la consulta se llama igual que el archivo. Si sigue, avisa en el grupo con el mensaje |
| Los meses salen en orden alfabético | Ordena `nombre_mes` por `mes_numero` (paso 3) |
| Un KPI da otro número | Revisa las relaciones (paso 3) y que la tarjeta no tenga filtros |
| Con `SQL`: no conecta | El nombre del servidor en `Servidor` debe ser el mismo que usas en SSMS, y la base tiene que estar cargada |

## Archivos de esta carpeta

| Archivo | Qué es | ¿Lo editas? |
|---|---|---|
| `power_query\*.pq` | Las 10 consultas (se generan desde `etl/contrato.py`) | No, solo las copias a Power BI |
| `medidas.dax` | Las medidas de los KPIs con su valor esperado | Puedes agregar medidas tuyas en Power BI |

## Cómo sabes que terminaste

- Las tarjetas sin filtros dan los valores del paso 4.
- Las 5 páginas responden su pregunta y tienen los filtros comunes.
- Cada página tiene su captura y su interpretación en el Google Doc (sección 6), y la sección 4.3 tiene la captura del modelo.
