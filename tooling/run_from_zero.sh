#!/usr/bin/env bash
set -euo pipefail

# Charge .env si présent (facultatif)
if [ -f ".env" ]; then
  export $(grep -v '^#' .env | xargs -d '\n' -r)
fi

# Paramètres par défaut si non fournis
PGHOST=${PGHOST:-localhost}
PGPORT=${PGPORT:-5432}
PGUSER=${PGUSER:-postgres}
ADMINDB=${ADMINDB:-postgres}

echo "Connexion: host=$PGHOST port=$PGPORT user=$PGUSER db=$ADMINDB"
psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$ADMINDB" -v ON_ERROR_STOP=1   -f sql/bootstrap/00_from_zero.psql
