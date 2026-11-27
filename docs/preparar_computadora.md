# Preparar tu computadora (partes 3 y 4)

Esta guía es para lo que se hace **una sola vez** en tu computadora: descargar el proyecto, instalar Python y cargar la base en tu SQL Server. Después de esto, cada parte sigue su propia guía.

**No necesitas Pentaho ni Visual Studio.** El ETL y el cubo ya están hechos (partes 1 y 2).

| Si te toca… | Qué necesitas de esta guía |
|---|---|
| **Parte 3 (K-means)** | Pasos 1, 2 y 3 (y el 4 cuando termines, para meter tus grupos en la base) |
| **Parte 4 (Power BI)** | Paso 1. Los pasos 2 a 4 solo si quieres que Power BI lea de SQL Server en vez de los CSV |

---

## 1. Descargar el proyecto

Opción simple: en https://github.com/leannsttar/dmd-proyecto-catedra-fase2 → botón verde **Code → Download ZIP**, y descomprímelo en una carpeta **sin espacios ni tildes en la ruta**, por ejemplo `C:\dmd\dmd-proyecto-catedra-fase2`.

Si ya usas Git: `git clone https://github.com/leannsttar/dmd-proyecto-catedra-fase2.git`.

En esa carpeta están los datos ya limpios en `data\sample\` (un CSV por tabla). **Son exactamente los mismos datos que tiene la base de SQL Server.**

> Cuando alguien del equipo avise que cambió algo (por ejemplo, la parte 3 terminó los grupos), vuelve a descargar el ZIP o reemplaza solo los archivos que te indiquen.

## 2. Instalar Python y las librerías del proyecto

1. Instala **Python 3.12** desde python.org. En el instalador marca **"Add python.exe to PATH"**.
2. Abre **PowerShell dentro de la carpeta del proyecto**: en el Explorador de archivos, entra a la carpeta, escribe `powershell` en la barra de direcciones y pulsa Enter. (O en VS Code: *Terminal → New Terminal* con la carpeta abierta.)
3. Copia y pega estas dos líneas, una por una:

   ```powershell
   python -m venv .venv
   .venv\Scripts\python -m pip install -r requirements.txt
   ```

   La primera crea una carpeta `.venv` con un Python propio del proyecto. La segunda instala ahí las librerías (pandas, scikit-learn, Jupyter…). Tarda unos minutos; al final debe decir `Successfully installed …`.

**Por qué `.venv\Scripts\python` y no solo `python`:** así siempre se usa el Python del proyecto, con las librerías correctas, sin tener que "activar" nada.

## 3. Conectar el proyecto a tu SQL Server

El proyecto lee la conexión de un archivo `.env`. Créalo copiando el de ejemplo:

```powershell
copy .env.example .env
```

Ábrelo con el Bloc de notas o VS Code y revisa **una sola línea**: `DB_SERVER`.

- Pon el **mismo nombre de servidor que usas para conectarte en SQL Server Management Studio** (SSMS), el que aparece en la ventana *Connect to Server*.
- Si instalaste SQL Server Express, casi siempre es `localhost\SQLEXPRESS`. Si es la instalación normal (Developer), es `localhost`.
- Lo demás déjalo igual: usa tu usuario de Windows, sin contraseña.

El proyecto también necesita el **ODBC Driver 18 for SQL Server**. Para ver si lo tienes:

```powershell
Get-OdbcDriver -Name "*SQL Server*" | Select-Object Name
```

Si en la lista no aparece `ODBC Driver 18 for SQL Server`, descárgalo e instálalo desde la página de Microsoft (busca "Download ODBC Driver for SQL Server").

## 4. Cargar la base en tu SQL Server

```powershell
.venv\Scripts\python -m etl.run_etl
```

Lee el Excel original, lo limpia, crea la base `AndinaRetailDW` si no existe y carga las tablas. **Debe terminar diciendo `OK`.** Tarda menos de un minuto.

Para comprobarlo, en SSMS:

```sql
SELECT * FROM AndinaRetailDW.dbo.vw_KPI_Anual;
```

Debe dar, entre otros, `ventas_total` = 705113.80, `ordenes` = 850 y `margen_bruto_pct` = 41.57.

Puedes volver a correr este comando todas las veces que quieras: borra y recarga todo, siempre con el mismo resultado. **Si eres de la parte 3, este mismo comando es el que mete tus grupos de K-means en la base** (lee `mining\output\segmentos_cliente.csv`).

---

## Si algo falla

| Mensaje | Qué pasa | Qué hacer |
|---|---|---|
| `python : El término 'python' no se reconoce…` | Python no quedó en el PATH | Reinstala Python marcando "Add python.exe to PATH", o usa `py -3.12` en lugar de `python` en el paso 2 |
| `No such file or directory: requirements.txt` o `.venv\Scripts\python` no existe | PowerShell no está abierto en la carpeta del proyecto | Escribe `cd` + la ruta de la carpeta, o ábrelo como dice el paso 2 |
| `…cannot be loaded because running scripts is disabled…` | Intentaste "activar" el entorno | No hace falta activarlo: usa siempre `.venv\Scripts\python …` |
| `Data source name not found and no default driver specified` | Falta el ODBC Driver 18 | Instálalo (paso 3) |
| `Login timeout expired`, `A network-related … error` o `Named Pipes Provider` | El nombre del servidor en `.env` no es el tuyo | Copia el nombre exacto de la ventana de conexión de SSMS a `DB_SERVER` |
| `Login failed for user …` | Tu usuario de Windows no tiene permiso en SQL Server | Conéctate en SSMS con el mismo usuario; si SSMS sí entra, revisa que `DB_USER` y `DB_PASSWORD` estén vacíos en `.env` |
| `certificate chain … not trusted` | El certificado del SQL Server local | Revisa que `.env` tenga `DB_TRUST_SERVER_CERTIFICATE=yes` |
| Termina con `FALLÓ` en vez de `OK` | Algún control de calidad no cuadró | Abre `data\sample\reporte_carga.md`: dice qué control falló. Avisa en el grupo con esa línea |

Si te atoras, copia el mensaje de error completo y pégalo en el grupo (o en tu IA del navegador junto con el nombre del paso).
