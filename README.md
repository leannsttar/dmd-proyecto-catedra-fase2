# DMD · Proyecto de Cátedra Fase 2: Datawarehouse Andina Retail Corp

Datawarehouse y Minería de Datos (DMD 941) · Universidad Don Bosco.

**Entrega: 27 de noviembre de 2026, 11:59 p. m.** (Aula Digital): un PDF con 6 secciones + enlace al video de defensa. La defensa oral es obligatoria y su fecha aún no se ha anunciado.

## Qué hay aquí, en un minuto

El Excel del caso (`datos_andina_retail_corp.xlsx`) **ya está limpio y cargado** en un Datawarehouse en SQL Server, con el esquema estrella de la Fase 1. Sobre esa base ya funcionan los 10 KPIs y una segmentación K-means. Todo está verificado: los totales y los KPIs coinciden con el Excel original.

La misma base está también **en archivos CSV** (`data/sample/`), con exactamente las mismas tablas y columnas. Quien no tenga SQL Server puede trabajar igual con esos archivos.

> **Qué se entrega, la rúbrica y qué falta:** [`docs/entrega.md`](docs/entrega.md).

## ¿Qué me toca? Empieza por tu fila

Cada carpeta tiene un README con el mismo orden: **qué es, qué ya está hecho, tus pasos, qué archivos tocar y cómo saber que terminaste.**

| Si te toca… | Lee primero | Qué ya está hecho | Qué te falta |
|---|---|---|---|
| **1. ETL y DW** | [`pentaho/README.md`](pentaho/README.md) | ETL en **Pentaho** (job + 8 transformaciones, como propuso la Fase 1), verificado contra el Excel y contra el ETL de Python | Capturas en Spoon y redactar la sección 2 del informe |
| **2. KPIs y cubo** | [`sql/README.md`](sql/README.md), luego [`olap/README.md`](olap/README.md) | Los 10 KPIs en SQL con valores verificados; consultas para capturas; cubo hecho en SQL | Construir el cubo SSAS siguiendo la guía paso a paso |
| **3. Minería** | [`mining/README.md`](mining/README.md) | Notebook de K-means que corre completo | Elegir el número de grupos, ponerle nombre a cada uno e interpretarlos |
| **4. Power BI** | [`powerbi/README.md`](powerbi/README.md) | Consultas para pegar, relaciones, medidas de los 10 KPIs y boceto de 5 páginas | Armar el reporte y escribir la interpretación |
| **Informe PDF** | [`docs/README.md`](docs/README.md) | Material por sección del informe, decisiones de diseño y relación con las clases | Redactar, hacer capturas y armar la portada |

## Primer uso (una vez por computadora)

Requisitos: Windows, Python 3.12 y Git. Para usar la base: SQL Server con autenticación de Windows y **ODBC Driver 18 for SQL Server**. Las partes 3 y 4 pueden empezar sin SQL Server.

```powershell
git clone https://github.com/leannsttar/dmd-proyecto-catedra-fase2.git
cd dmd-proyecto-catedra-fase2
python -m venv .venv
.venv\Scripts\python -m pip install -r requirements.txt
copy .env.example .env                        # ajustar si el servidor no es localhost

.venv\Scripts\python -m etl.run_etl           # carga todo en SQL Server y regenera los CSV
```

Debe terminar diciendo `OK`. El detalle queda en [`data/sample/reporte_carga.md`](data/sample/reporte_carga.md).

| Comando | Para qué |
|---|---|
| `.venv\Scripts\python -m etl.run_etl` | Cargar la base completa (y regenerar los CSV) |
| `.venv\Scripts\python -m etl.run_etl --sin-bd` | Sin SQL Server: solo regenerar los CSV |
| `pentaho\ejecutar_etl.bat` | Cargar la base con el ETL de Pentaho (ver `pentaho/README.md`) |
| `.venv\Scripts\python -m etl.run_etl --validar-bd` | No carga nada: valida una base cargada con otra herramienta (p. ej. Pentaho) contra el Excel |
| `.venv\Scripts\python -m jupyter nbconvert --to notebook --execute --inplace mining\01_kmeans_clientes.ipynb` | Ejecutar el notebook de K-means de principio a fin |
| `.venv\Scripts\python -m etl.generar` | Solo si cambiaste `etl/contrato.py`: regenera tablas, diccionario y consultas de Power BI |

## Qué propuso la Fase 1 y qué hay hoy

| Pieza | Fase 1 | Hoy en el repo |
|---|---|---|
| Base de datos | SQL Server | ✅ SQL Server (`AndinaRetailDW`) |
| ETL | **Pentaho** | ✅ Pentaho Data Integration 9.4 (`pentaho/andina_etl.kjb`). El ETL de Python queda como validador y genera los CSV |
| Cubo OLAP | SSAS multidimensional | Guía + fórmulas MDX; **cubo por construir**. Mientras tanto hay un cubo hecho en SQL como respaldo |
| Minería | K-means en Python | ✅ Notebook funcionando |
| Reporte | Power BI conectado en vivo al cubo | Guía para Power BI en modo importación (no depende del cubo). **Decisión abierta** |

Las decisiones abiertas y los cambios de diseño están explicados en [`docs/decisiones.md`](docs/decisiones.md).

## Números de referencia (2024)

Sirven para comprobar que lo que armes cuadra con la base:

| Concepto | Valor |
|---|---|
| Ventas | 850 órdenes · $705,113.80 |
| Ingresos (Finanzas) | $2,331,474.57 (no concilian con las ventas; está documentado) |
| Margen bruto / neto | 41.57 % / 26.90 % |
| Ticket promedio / ventas por cliente | $829.55 / $5,875.95 |
| Participación del e-commerce / conversión web | 44.00 % / 9.01 % |

Los 10 KPIs con su fórmula están en [`docs/kpis.md`](docs/kpis.md).

## Palabras que vas a ver

| Término | Qué significa aquí |
|---|---|
| **ETL** | El proceso que lee el Excel, lo limpia y lo carga en la base |
| **Datawarehouse (DW)** | La base `AndinaRetailDW` en SQL Server, organizada para análisis |
| **Hecho / dimensión** | Tabla de números (ventas, finanzas) / tabla que describe esos números (cliente, producto, fecha…) |
| **Contrato** | La lista fija de tablas y columnas (`etl/contrato.py`). Todos trabajan contra ella |
| **Muestra / CSV** | La base completa exportada a `data/sample/` para trabajar sin SQL Server |
| **Cubo** | La base organizada para navegar por niveles (año → mes, categoría → producto) |

## Reglas del equipo

- `main` siempre funciona: el ETL corre y da `OK`.
- Una rama por tarea (`parte3-kmeans-k`, `parte4-pagina-finanzas`, …) y un **PR revisado por otra persona del equipo**. Con el plazo actual, PRs pequeños y revisados el mismo día.
- No edites a mano lo que se genera solo: `data/sample/`, `sql/ddl/01_tablas.sql`, `docs/diccionario_datos.md` y `powerbi/power_query/`.
- No subir `.env`, `.pbix` ni respaldos `.bak` (ya están en `.gitignore`).

## Mapa de carpetas

```
data/raw/      Excel original del caso                                  → todos (no editar)
data/sample/   La base limpia en CSV + reportes de la carga               → partes 3 y 4 (lo genera el ETL)
pentaho/       ETL en Pentaho: job, transformaciones y ejecutor             → parte 1
etl/           ETL en Python: validador independiente y extracto CSV        → parte 1 y todos
sql/           Tablas, vistas de KPIs, cubo en SQL y consultas de evidencia → parte 2
olap/          Guía y fórmulas para el cubo SSAS                          → parte 2
mining/        Notebook de K-means y sus resultados                       → parte 3
powerbi/       Guía, consultas y medidas DAX (aquí se guardará el .pbip)  → parte 4
docs/          Material para redactar el informe                          → quien redacte
```
