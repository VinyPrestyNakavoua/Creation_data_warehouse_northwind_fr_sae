# devtools/run_from_zero.ps1 — ultra simple (exécuter depuis la RACINE du projet)
$ErrorActionPreference = "Stop"

# 1) charger .env (chaque ligne formée de key=value)
Get-Content .\.env | ForEach-Object {
  $kv = $_.Split('=', 2)
  [Environment]::SetEnvironmentVariable($kv[0], $kv[1], "Process")
}

# 2) lancer psql avec les variables chargées
psql -h $Env:PGHOST -p $Env:PGPORT -U $Env:PGUSER -d $Env:ADMINDB -v ON_ERROR_STOP=1 `
  -f sql/setup/00_setup_op_dwh.psql
