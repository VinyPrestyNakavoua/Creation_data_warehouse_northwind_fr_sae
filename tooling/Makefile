    .PHONY: init load views maintenance test all

    export $(shell test -f .env && sed -n 's/^[^#].*//p' .env)

    PSQL=psql ${PGHOST:+-h $(PGHOST)} ${PGPORT:+-p $(PGPORT)} ${PGDATABASE:+-d $(PGDATABASE)} ${PGUSER:+-U $(PGUSER)}

    init:
		$(PSQL) -v ON_ERROR_STOP=1 -f sql/source_oltp/01_create_tables.sql
		$(PSQL) -v ON_ERROR_STOP=1 -f sql/source_oltp/02_create_views.sql

    load:
		$(PSQL) -v ON_ERROR_STOP=1 -f sql/dwh/01_creation_dwh.sql
		$(PSQL) -v ON_ERROR_STOP=1 -f sql/dwh/02_chargement_dwh.sql

    views:
		$(PSQL) -v ON_ERROR_STOP=1 -f sql/dwh/03_vues_dwh.sql

    maintenance:
		$(PSQL) -v ON_ERROR_STOP=1 -f sql/maintenance/10_indexes.sql

    test:
		$(PSQL) -v ON_ERROR_STOP=1 -f tests/dq/t01_fk_non_null.sql
		$(PSQL) -v ON_ERROR_STOP=1 -f tests/dq/t02_no_dup_keys.sql
		$(PSQL) -v ON_ERROR_STOP=1 -f tests/dq/t03_metrics_consistency.sql

    all: init load views maintenance test
