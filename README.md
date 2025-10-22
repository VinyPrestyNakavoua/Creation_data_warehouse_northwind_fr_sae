# Projet DWH (PostgreSQL)

Ce dépôt contient :
- Schéma source OLTP (tables + vues)
- Schéma décisionnel DWH (dimensions + faits)
- Scripts de chargement (ELT) et vues de restitution (F1..F8, L1..L5)
- Outils d'exécution (Makefile, scripts) et tests de qualité

## Ordre d'exécution

```bash
# 1) Source OLTP
psql -f sql/source_oltp/01_create_tables.sql
psql -f sql/source_oltp/02_create_views.sql

# 2) Data Warehouse
psql -f sql/dwh/01_creation_dwh.sql
psql -f sql/dwh/02_chargement_dwh.sql
psql -f sql/dwh/03_vues_dwh.sql

# 3) Tests
psql -f tests/dq/t01_fk_non_null.sql
psql -f tests/dq/t02_no_dup_keys.sql
psql -f tests/dq/t03_metrics_consistency.sql
```

> Les connexions (hôte, base, utilisateur) peuvent être fournies via variables ENV ou `.env`.
