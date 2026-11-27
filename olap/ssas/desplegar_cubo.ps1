# Despliega y procesa el cubo AndinaRetail_Cubo; reemplaza la opción Deploy de Visual Studio.
# Motivo: Deploy falla en SQL Server 2025 Standard Developer ("The current edition
# 'StandardDeveloper64' ... is not supported by the client") porque la extensión de
# Visual Studio no reconoce esa edición. El proveedor MSOLAP sí la reconoce, así que este
# script envía al servidor la misma definición que compila Visual Studio y la procesa.
# Uso: en Visual Studio, Build (genera bin\AndinaRetail_Cubo.asdatabase); luego:
#   powershell -ExecutionPolicy Bypass -File olap\ssas\desplegar_cubo.ps1
param(
  [string]$Servidor = "localhost",
  [string]$AsDatabase = "$PSScriptRoot\AndinaRetail_Cubo\bin\AndinaRetail_Cubo.asdatabase"
)
$ErrorActionPreference = "Stop"

function Invoke-Xmla([System.Data.OleDb.OleDbConnection]$cn, [string]$xmla) {
  $cmd = $cn.CreateCommand(); $cmd.CommandTimeout = 0; $cmd.CommandText = $xmla
  [void]$cmd.ExecuteNonQuery()
}

$def = (Get-Content $AsDatabase -Raw -Encoding utf8) -replace '^\s*<\?xml[^>]*\?>', ''
# El servidor rechaza los elementos de solo lectura que trae la definición compilada
foreach ($ro in 'CreatedTimestamp','LastSchemaUpdate','LastProcessed','LastUpdate','State','ImpersonationInfoSecurity','CurrentStorageMode') {
  $def = $def -replace "<$ro>[^<]*</$ro>", '' -replace "<$ro\s*/>", ''
}
$dbId = ([xml]$def).Database.ID
$ns = 'http://schemas.microsoft.com/analysisservices/2003/engine'

$cn = New-Object System.Data.OleDb.OleDbConnection "Provider=MSOLAP;Data Source=$Servidor;Integrated Security=SSPI"
$cn.Open()
try {
  $t = [Diagnostics.Stopwatch]::StartNew()
  Invoke-Xmla $cn "<Create AllowOverwrite=""true"" xmlns=""$ns""><ObjectDefinition>$def</ObjectDefinition></Create>"
  Write-Host "1. Base '$dbId' desplegada ($([int]$t.Elapsed.TotalSeconds) s)"
  $t.Restart()
  Invoke-Xmla $cn "<Process xmlns=""$ns""><Object><DatabaseID>$dbId</DatabaseID></Object><Type>ProcessFull</Type></Process>"
  Write-Host "2. ProcessFull completado ($([int]$t.Elapsed.TotalSeconds) s)"
} finally { $cn.Close() }

# Verificación: totales del cubo (comparar con vw_KPI_Anual: 705113.80 · 850 · 120)
$cn = New-Object System.Data.OleDb.OleDbConnection "Provider=MSOLAP;Data Source=$Servidor;Initial Catalog=$dbId;Integrated Security=SSPI"
$cn.Open()
try {
  $cmd = $cn.CreateCommand()
  $cmd.CommandText = "SELECT { [Measures].[Total], [Measures].[Hecho Ventas Count], [Measures].[Clientes Distintos] } ON 0 FROM [Cubo Ventas]"
  $r = $cmd.ExecuteReader()
  while ($r.Read()) { for ($i = 0; $i -lt $r.FieldCount; $i++) { Write-Host ("3. {0} = {1}" -f $r.GetName($i), $r.GetValue($i)) } }
  $r.Close()
} finally { $cn.Close() }
