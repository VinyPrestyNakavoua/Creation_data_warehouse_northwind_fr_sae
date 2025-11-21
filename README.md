# Projet DWH (PostgreSQL) — Schémas `operationnel` & `dwh`

* **Schéma opérationnel** : `operationnel` (tables/vues OLTP)
* **Schéma Data Warehouse** : `dwh` (dimensions, faits, vues F1..F8 & L1..L5)

## 🎯 Objectif

Projet clé en main pour construire un entrepôt Northwind FR :

1. Création de la BDD
2. Création des schémas `operationnel` & `dwh`
3. Création des tables/vues **opérationnelles**
4. Création + **chargement** du **DWH**
5. Création des vues de **restitution**
6. Maintenance + **tests qualité** (DQ)

---

## 🚀 Démarrage « from scratch » (1 seule commande)

la procédure est décrit dans le fichier **devtools/installation_guide_DBS.md**

## 🔧 Variables d’environnement

**`.env`** :

```
PGHOST=localhost
PGPORT=5432
PGDATABASE=northwind
PGUSER=postgres
PGPASSWORD=MDP
ADMINDB=postgres
```

`run_from_zero.sh`  ou `run_from_zero.ps1` selon le OS, lira ces valeurs automatiquement.

---

## 📂 Arborescence du projet

```
.
├─ README.md
├─ .env.example
├─ .gitignore
│
├─ bi/                         # visualisation (ex. TDB.pbix)
├─ data/                       # CSV sources (client, commande, ...)
│
├─ docs/
│  ├─ SRS_past_reports/
│  └─ SRS_reports/             # exemples + structure de cahier des charges
│
├─ uml_diagrams/
│  ├─ DWH_model/               # .drawio / .odb pour le schéma dwh
│  └─ operational_model/       # .drawio / .odb pour le schéma opérationnel
│
├─ sql/
│  ├─ setup/
│  │  ├─ 00_setup_op_dwh.psql  # all-in-one psql : BDD → schémas → OLTP → DWH → vues → tests
│  │  └─ 01_adding_schemas.sql # crée `operationnel` & `dwh` + extensions + search_path
│  │
│  ├─ source_oltp/             # couche opérationnelle (schéma `operationnel`)
│  │  ├─ 01_create_tables.sql
│  │  └─ 02_create_views.sql
│  │
│  ├─ dwh/                     # couche data warehouse (schéma `dwh`)
│  │  ├─ 01_adding_tables_dwh.sql
│  │  ├─ 02_adding_data_dwh.sql
│  │  └─ 03_adding_views_dwh.sql
│  │
│  └─ maintenance/
│     └─ 10_indexes.sql
│
├─ tests/
│  ├─ dq/
│  │  ├─ t01_fk_non_null.sql
│  │  ├─ t02_no_dup_keys.sql
│  │  └─ t03_metrics_consistency.sql
│  └─ perf/
│     └─ explain_samples.sql
│
└─ devtools/
   ├─ run_from_zero.sh           # lance sql/setup/00_setup_op_dwh.psql pour linux/bash
   ├─ run_from_zero.ps1          # lance sql/setup/00_setup_op_dwh.psql pour powershell
   ├─ installation_guide_DBS.md  # guide pour lancer la création du système depuis un os windows ou linux
   └─ perspectives/
│     └─ docker/
         └─ docker-compose.yml    # service Postgres (optionnel)
```

---

## 🧪 Interprétation rapide des tests DQ

* `t01_fk_non_null.sql` → **0** attendu (sinon, faits orphelins)
* `t02_no_dup_keys.sql` → **0** attendu (sinon, grain non respecté)
* `t03_metrics_consistency.sql` → **0** attendu (sinon, calculs incohérents)

---

## 🆘 Dépannage rapide

* `psql: command not found` → installe PostgreSQL/psql.
* `could not connect` → vérifie `PGHOST/PGPORT` et que Postgres est **up**.
* Conflit de port `5432` → utilise `5433:5432` (Docker) + `PGPORT=5433` dans `.env`.
* 2ᵉ exécution “from scratch” → l’étape `CREATE DATABASE` peut échouer (base existante) : ignorer, ou `dropdb northwind_fr_sae`.
