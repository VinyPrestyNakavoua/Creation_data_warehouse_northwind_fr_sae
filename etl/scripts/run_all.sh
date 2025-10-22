#!/usr/bin/env bash
set -euo pipefail
export $(grep -v '^#' .env 2>/dev/null | xargs -d '\n' -r)

PSQL="psql ${PGHOST:+-h $PGHOST} ${PGPORT:+-p $PGPORT} ${PGDATABASE:+-d $PGDATABASE} ${PGUSER:+-U $PGUSER}"

echo "== Source OLTP =="
$PSQL -v ON_ERROR_STOP=1 -f sql/source_oltp/01_create_tables.sql
$PSQL -v ON_ERROR_STOP=1 -f sql/source_oltp/02_create_views.sql

echo "== Data Warehouse =="
$PSQL -v ON_ERROR_STOP=1 -f sql/dwh/01_creation_dwh.sql
$PSQL -v ON_ERROR_STOP=1 -f sql/dwh/02_chargement_dwh.sql
$PSQL -v ON_ERROR_STOP=1 -f sql/dwh/03_vues_dwh.sql

echo '== Maintenance =='
$PSQL -v ON_ERROR_STOP=1 -f sql/maintenance/10_indexes.sql

echo '== Tests DQ =='
$PSQL -v ON_ERROR_STOP=1 -f tests/dq/t01_fk_non_null.sql
$PSQL -v ON_ERROR_STOP=1 -f tests/dq/t02_no_dup_keys.sql
$PSQL -v ON_ERROR_STOP=1 -f tests/dq/t03_metrics_consistency.sql

echo 'OK.'
