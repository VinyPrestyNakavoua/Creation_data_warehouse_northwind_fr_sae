#!/usr/bin/env bash
set -euo pipefail

# Se placer à la racine du projet (script dans devtools/)
cd "$(dirname "$0")/.."

# Charger .env si présent (portable Linux/macOS)
if [ -f ".env" ]; then
  set -a
  . ./.env
  set +a
fi

# Paramètres par défaut
PGHOST=${PGHOST:-localhost}
PGPORT=${PGPORT:-5432}
PGUSER=${PGUSER:-postgres}
ADMINDB=${ADMINDB:-postgres}

echo "Connexion: host=$PGHOST port=$PGPORT user=$PGUSER db=$ADMINDB"
psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$ADMINDB" -v ON_ERROR_STOP=1 \
  -f sql/setup/00_setup_op_dwh.psql

echo "OK : environnement 'northwind_fr_sae' prêt (operationnel + dwh)."
