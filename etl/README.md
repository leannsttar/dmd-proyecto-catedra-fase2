# Parte 1: ETL y Datawarehouse (versión en Python)

> **El ETL de la entrega está en Pentaho:** ver [`pentaho/README.md`](../pentaho/README.md). Este programa de Python produce exactamente las mismas tablas; se usa para validar la carga de Pentaho (`--validar-bd`) y para regenerar los CSV de `data/sample/`.

**Qué es esta carpeta:** el programa que toma el Excel del caso, lo limpia y lo carga en la base de datos `AndinaRetailDW` de SQL Server. También genera la copia en CSV (`data/sample/`) que usan las partes 3 y 4.

**Para quién:** la persona de la parte 1. Las demás solo necesitan ejecutarlo (paso 1).

## Qué ya está hecho

- El ETL completo funciona y está verificado: 850 órdenes, 120 clientes y 12 meses cargados, **0 filas rechazadas**.
- Cada regla de limpieza de la Fase 1 (sección 2.4) está implementada y explicada en [`docs/reglas_limpieza.md`](../docs/reglas_limpieza.md).
- Al final de cada carga se genera un reporte que compara el Excel, los CSV y la base: [`data/sample/reporte_carga.md`](../data/sample/reporte_carga.md).

## Tus pasos

1. **Ejecutar la carga** (desde la raíz del repo, con el entorno instalado; ver el README principal):
   ```powershell
   .venv\Scripts\python -m etl.run_etl
   ```
   Debe terminar con `OK`. Si no tienes SQL Server, usa `--sin-bd` (solo regenera los CSV).
2. **Decidido: Pentaho** (decisión D4, ya aplicada en [`pentaho/`](../pentaho/README.md)). Lo que sigue queda como referencia de cómo se construyó.
   - **Si se queda Python:** listo. Para el informe, justifica el cambio con el texto de D4.
   - **Si se hace en Pentaho:**
     1. Crea las tablas con [`sql/ddl/01_tablas.sql`](../sql/ddl/01_tablas.sql) (en SSMS).
     2. Arma el job y las transformaciones siguiendo la Tabla 10 de la Fase 1. Las reglas exactas (qué se convierte, qué se rechaza, qué se anota) están en [`docs/reglas_limpieza.md`](../docs/reglas_limpieza.md), y la columna **Origen** de [`docs/diccionario_datos.md`](../docs/diccionario_datos.md) dice de dónde sale cada columna.
     3. Usa las mismas llaves que Python: `tiempo_key` = AAAAMMDD, `mes_key` = AAAAMM, y las demás 1, 2, 3… en orden alfabético. **No uses IDENTITY**: si las llaves cambian, los CSV que usan las partes 3 y 4 dejan de coincidir con la base.
     4. Ejecuta el job y valida lo que cargó Pentaho con:
        ```powershell
        .venv\Scripts\python -m etl.run_etl --validar-bd
        ```
        Esto **no carga nada**: compara lo que hay en la base con el Excel. Debe dar `OK`.
3. **Capturas para el informe (sección 2):** el reporte de carga, el conteo de filas por tabla en SSMS y [`data/sample/perfil_atributos.md`](../data/sample/perfil_atributos.md) (perfilado del Excel).

## Archivos

| Archivo | Qué hace | ¿Lo editas? |
|---|---|---|
| `contrato.py` | Define **todas las tablas y columnas** (nombres, tipos, llaves, origen) | Solo si cambia el diseño (ver abajo) |
| `run_etl.py` | El comando principal: ejecuta todo en orden | No |
| `extract.py` | Lee las 3 hojas del Excel | No |
| `transform.py` | Aplica las reglas de limpieza y arma las tablas | Si cambia una regla |
| `load.py` | Escribe los CSV y carga SQL Server | No |
| `validate.py` | Compara Excel, CSV y base, y escribe el reporte | No |
| `perfilado.py` | Genera el perfilado del Excel (Clase 15.3) | No |
| `generar.py` | Regenera el DDL, el diccionario y las consultas de Power BI a partir de `contrato.py` | No |
| `config.py` | Rutas y conexión (lee `.env`) | No |

**Si cambias el diseño de una tabla:** edita `contrato.py`, ejecuta `python -m etl.generar` y luego `python -m etl.run_etl`, y avisa en el PR a las partes 3 y 4.

## Cómo sabes que terminaste

El reporte dice `Resultado: OK` y ventas = **$705,113.80**, ingresos = **$2,331,474.57**, 25,374 visitas y 2,285 conversiones.
