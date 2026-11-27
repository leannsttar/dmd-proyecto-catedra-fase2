@echo off
rem Ejecuta el job completo del ETL (Pentaho Data Integration 9.4) con Kitchen.
rem Uso: pentaho\ejecutar_etl.bat   (opcional: set PDI_HOME=C:\ruta\data-integration)
setlocal
if "%PDI_HOME%"=="" set "PDI_HOME=C:\pentaho\data-integration"
if not exist "%PDI_HOME%\Kitchen.bat" (
  echo No se encontro Kitchen.bat en %PDI_HOME%. Defina PDI_HOME con la carpeta data-integration.
  exit /b 1
)
if not exist "%~dp0logs" mkdir "%~dp0logs"
if exist "%~dp0logs\etl.log" del "%~dp0logs\etl.log"
rem Kitchen falla si la carpeta actual termina en \ (por ejemplo C:\); se ejecuta desde PDI_HOME.
pushd "%PDI_HOME%"
call "%PDI_HOME%\Kitchen.bat" /file:"%~dp0andina_etl.kjb" /level:Basic /logfile:"%~dp0logs\etl.log" %*
set RC=%ERRORLEVEL%
popd
echo Kitchen termino con codigo %RC% (0 = carga correcta). Registro: %~dp0logs\etl.log
exit /b %RC%
