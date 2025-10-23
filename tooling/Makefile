# === Makefile racine ===
# Objectif par défaut : "projet" (tout créer via run_from_zero.sh)
SHELL := /usr/bin/env bash
.ONESHELL:
.DEFAULT_GOAL := projet

# Charge .env (PGHOST, PGPORT, PGUSER...) s’il existe
ENV_FILE := .env
export $(shell test -f $(ENV_FILE) && sed -n 's/^[^#].*//p' $(ENV_FILE))

projet:
	@echo "== Bootstrap complet (BDD + schémas + OLTP + DWH + vues + tests) =="
	@chmod +x tooling/run_from_zero.sh
	./tooling/run_from_zero.sh

# --- Cibles utiles en bonus (optionnelles) ---

# Lance seulement l’opérationnel
init:
	psql ${PGHOST:+-h $$PGHOST} ${PGPORT:+-p $$PGPORT} -d "$$PGDATABASE" ${PGUSER:+-U $$PGUSER} -v ON_ERROR_STOP=1 \
		-f sql/source_oltp/01_create_tables.sql
	psql ${PGHOST:+-h $$PGHOST} ${PGPORT:+-p $$PGPORT} -d "$$PGDATABASE" ${PGUSER:+-U $$PGUSER} -v ON_ERROR_STOP=1 \
		-f sql/source_oltp/02_create_views.sql

# Crée + charge le DWH
load:
	psql ${PGHOST:+-h $$PGHOST} ${PGPORT:+-p $$PGPORT} -d "$$PGDATABASE" ${PGUSER:+-U $$PGUSER} -v ON_ERROR_STOP=1 \
		-f sql/dwh/01_creation_dwh.sql
	psql ${PGHOST:+-h $$PGHOST} ${PGPORT:+-p $$PGPORT} -d "$$PGDATABASE" ${PGUSER:+-U $$PGUSER} -v ON_ERROR_STOP=1 \
		-f sql/dwh/02_chargement_dwh.sql

# Vues DWH
views:
	psql ${PGHOST:+-h $$PGHOST} ${PGPORT:+-p $$PGPORT} -d "$$PGDATABASE" ${PGUSER:+-U $$PGUSER} -v ON_ERROR_STOP=1 \
		-f sql/dwh/03_vues_dwh.sql

# Maintenance & tests DQ
maintenance:
	psql ${PGHOST:+-h $$PGHOST} ${PGPORT:+-p $$PGPORT} -d "$$PGDATABASE" ${PGUSER:+-U $$PGUSER} -v ON_ERROR_STOP=1 \
		-f sql/maintenance/10_indexes.sql

test:
	psql ${PGHOST:+-h $$PGHOST} ${PGPORT:+-p $$PGPORT} -d "$$PGDATABASE" ${PGUSER:+-U $$PGUSER} -v ON_ERROR_STOP=1 \
		-f tests/dq/t01_fk_non_null.sql
	psql ${PGHOST:+-h $$PGHOST} ${PGPORT:+-p $$PGPORT} -d "$$PGDATABASE" ${PGUSER:+-U $$PGUSER} -v ON_ERROR_STOP=1 \
		-f tests/dq/t02_no_dup_keys.sql
	psql ${PGHOST:+-h $$PGHOST} ${PGPORT:+-p $$PGPORT} -d "$$PGDATABASE" ${PGUSER:+-U $$PGUSER} -v ON_ERROR_STOP=1 \
		-f tests/dq/t03_metrics_consistency.sql

.PHONY: projet init load views maintenance test
