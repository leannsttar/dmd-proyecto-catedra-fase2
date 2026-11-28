# Parte 3: minería de datos (K-means)

**Qué te toca:** revisar el análisis de K-means que agrupa a los 120 clientes según cómo compran, tomar 3 decisiones (variables, número de grupos y nombre de cada grupo) y explicarlo en la sección 4.2 del informe. Es la técnica que eligió la Fase 1.

**Qué ya está hecho y puedes usar tal cual:**

| Ya hecho | Dónde |
|---|---|
| Los datos limpios del Excel (parte 1) | `data\sample\*.csv` y la base `AndinaRetailDW` |
| El notebook completo, que corre de principio a fin sin errores (unos 40 segundos) | `mining\01_kmeans_clientes.ipynb` |
| **Resultado final (27-nov):** las 7 variables de la Fase 1, k = 3 (silueta 0.19) y los nombres "Compra poco y en tienda" (44 clientes), "Ticket alto y en línea" (19) y "Frecuentes y de mayor gasto" (57). El notebook lee la base (`FUENTE=bd`) | `mining\output\`; evidencias en [`evidencias/parte3/`](../evidencias/parte3/README.md) |
| Ese resultado ya está en la base, en los CSV y en el cubo (`Dim_Cliente.segmento_cluster`, atributo `Segmento Cluster`), así que Power BI y el cubo ya filtran por grupo | — |

**Lo que hace el notebook**, siguiendo las fases del proceso KDD (Clase 13):
1. Arma 7 variables por cliente (las de la Fase 1): venta total, número de órdenes, ticket promedio, % de compras en e-commerce, categorías compradas, visitas web y tasa de conversión.
2. Las estandariza, para que ninguna pese más solo por estar en dólares.
3. Prueba k = 3, 4, 5 y 6 con el método del codo y el coeficiente de silueta.
4. Forma los grupos y describe el perfil promedio de cada uno.
5. Guarda el resultado en `mining\output\`.

> **No necesitas** Pentaho, Visual Studio ni el cubo.

## Qué entregas al informe (Google Doc)

| Dónde | Qué |
|---|---|
| **Sección 4.2** (K-means) | Las 2 figuras de `mining\output\figuras\`: `eleccion_k.png` (codo y silueta) y `perfil_grupos.png` (mapa de perfiles). La tabla de perfil (`mining\output\perfil_segmentos.csv`). Por qué ese k. El nombre y una interpretación de negocio de cada grupo. La advertencia de la silueta baja (abajo) |
| **Cronograma** | Tu fila: fecha real y quién lo hizo |
| **Video** | Codo y silueta, el perfil de los grupos y la columna `segmento_cluster` ya en `Dim_Cliente` (ver `docs/entrega.md`) |

---

## Paso 1. Preparar tu computadora

Sigue [`docs/preparar_computadora.md`](../docs/preparar_computadora.md), pasos 1, 2 y 3: descargar el proyecto, crear el entorno de Python e indicar tu servidor de SQL Server. Con eso ya tienes todas las librerías del notebook.

Para abrir el notebook necesitas **VS Code** con la extensión **Jupyter** (de Microsoft). Al abrir el `.ipynb`, arriba a la derecha elige el kernel (*Select Kernel → Python Environments*) y escoge el que está en **`.venv`** dentro de la carpeta del proyecto. Si eliges otro Python, fallará con `ModuleNotFoundError`.

**Alternativa sin VS Code:** ejecuta el notebook completo desde PowerShell, en la carpeta del proyecto. Deja los resultados dentro del mismo archivo y en `mining\output\`:

```powershell
.venv\Scripts\python -m jupyter nbconvert --to notebook --execute --inplace mining\01_kmeans_clientes.ipynb
```

## Paso 2. Correrlo una vez y entender el resultado

Ejecuta todo (*Run All*). Lee las tablas y figuras de arriba abajo. Lo importante:

- **Elección de k** (`eleccion_k.png`): con el codo buscas dónde la curva deja de bajar mucho; con la silueta, el k con el valor más alto. Hoy la mejor silueta es **k = 3 (0.19)**.
- **Perfil de los grupos** (`perfil_grupos.png` y la tabla `perfil`): en rojo, lo que el grupo tiene por encima del promedio; en azul, por debajo. De ahí salen los nombres.

## Paso 3. Tomar las 3 decisiones

Están en 3 celdas marcadas **🟨 DECISIÓN DEL EQUIPO**. Cambia solo esas líneas:

**a) Variables** (celda que empieza con `VARIABLES = [`). Por defecto, las 7 de la Fase 1. Si dos variables están muy correlacionadas (mira la tabla de correlación que imprime esa celda, valores cerca de 1 o −1), puedes quitar una y justificarlo. Si no, déjalas.

**b) Número de grupos** (celda con `K_ELEGIDO`). `None` usa el de mejor silueta. Para fijar otro:

```python
K_ELEGIDO = 4   # p. ej. 4; None = mejor silueta
```

Elige el k que tenga buena silueta **y** grupos que se puedan describir con una frase.

**c) Nombres** (celda con `NOMBRES`). Escribe un nombre corto por grupo, mirando el perfil. Tiene que haber exactamente tantos como el k elegido. Por ejemplo, con k = 3:

```python
NOMBRES = {1: "Compra poco y en tienda", 2: "Ticket alto, mitad en línea", 3: "Clientes frecuentes y de mayor gasto"}
```

(Ejemplo basado en la corrida actual: el grupo 1 tiene la menor venta total y el menor % de e-commerce; el 2, el ticket más alto, $1,315; el 3, el mayor número de órdenes y de venta total. Revisa los tuyos.)

Después, **vuelve a ejecutar todo** (*Run All*). Se actualizan las figuras y los archivos de `mining\output\`.

**Ojo con la silueta baja:** 0.19 indica que los grupos se separan poco. Dilo en el informe e interprétalos con cuidado: son tendencias, no grupos tajantes. Si no se pueden describir, el plan B de la Fase 1 es usar los 3 segmentos del Excel (Consumidor, Pyme, Corporativo).

## Paso 4. Meter tus grupos en la base

Cuando tengas la versión final, carga la base con tus grupos. Es el paso 4 de [`docs/preparar_computadora.md`](../docs/preparar_computadora.md):

```powershell
.venv\Scripts\python -m etl.run_etl
```

El ETL lee `mining\output\segmentos_cliente.csv` y llena la columna `segmento_cluster` de `Dim_Cliente`, en la base y en los CSV de `data\sample\`. Debe terminar en `OK`.

Compruébalo en SSMS (te sirve como captura para el informe):

```sql
SELECT segmento_cluster, COUNT(*) AS clientes
FROM AndinaRetailDW.dbo.Dim_Cliente
GROUP BY segmento_cluster ORDER BY segmento_cluster;
```

Debe dar una fila por grupo y sumar 120 clientes.

## Si algo falla

| Problema | Qué hacer |
|---|---|
| `ModuleNotFoundError: No module named 'sklearn'` (o `pandas`) | El notebook usa otro Python: elige el kernel de `.venv` (paso 1) |
| VS Code no muestra `.venv` como kernel | Abre en VS Code la **carpeta** del proyecto (no solo el archivo) y vuelve a buscar el kernel; o usa la alternativa por PowerShell |
| Un grupo sale con nombre `NaN` en la tabla de perfil | Faltan nombres en `NOMBRES`: debe haber uno por grupo, numerados del 1 al k |
| El ETL no conecta o no termina en `OK` | Ver la tabla de errores de `docs/preparar_computadora.md` |

## Archivos de esta carpeta

| Archivo | Qué es | ¿Lo editas? |
|---|---|---|
| `01_kmeans_clientes.ipynb` | El análisis completo | Solo las 3 celdas 🟨 |
| `datos.py` | Carga las tablas desde los CSV (lo usa el notebook) | No |
| `output\segmentos_cliente.csv` | El grupo de cada cliente. **El ETL lo lee** para llenar `Dim_Cliente` | No (lo genera el notebook) |
| `output\perfil_segmentos.csv` | Promedio de cada variable por grupo, con su nombre | No (lo genera el notebook) |
| `output\evaluacion_k.csv`, `output\figuras\` | Codo, silueta y mapa de perfiles | No (lo genera el notebook) |

## Por qué no hay reglas de asociación ni árbol de decisión

La Fase 1 los evaluó y los descartó, y los datos lo confirman: cada orden tiene **un solo producto**, así que no hay canastas para las reglas, y no hay una variable que predecir para el árbol. Ver [`docs/decisiones.md`](../docs/decisiones.md), D7. Si te lo preguntan en la defensa, esa es la respuesta.

## Cómo sabes que terminaste

- Los grupos tienen nombre y el k está justificado.
- El ETL dio `OK` y `Dim_Cliente.segmento_cluster` tiene tus grupos.
- La sección 4.2 del Google Doc tiene las 2 figuras, la tabla de perfil y la interpretación.
