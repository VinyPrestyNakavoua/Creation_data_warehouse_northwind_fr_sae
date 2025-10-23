# Projet DWH (PostgreSQL) — Schémas `operationnel` & `dwh`

- **Schéma opérationnel** : `operationnel` (tables/vues OLTP)
- **Schéma Data Warehouse** : `dwh` (dimensions, faits, vues F1..F8 & L1..L5)

## 🎯 Objectif
Projet clé en main pour construire un entrepôt Northwind FR :
1) Création de la BDD  
2) Création des schémas `operationnel` & `dwh`  
3) Création des tables/vues **opérationnelles**  
4) Création + **chargement** du **DWH**  
5) Création des vues de **restitution**  
6) Maintenance + **tests qualité** (DQ)

---

## 🚀 Démarrage « from scratch » (1 seule commande)

### Option A — PostgreSQL **local** (psql installé)
À la **racine du projet** :
```bash
./tooling/run_from_zero.sh
```
Ce script appelle `psql` et exécute `sql/bootstrap/00_from_zero.psql`, qui enchaîne **toutes** les étapes (BDD → schémas → OLTP → DWH → vues → maintenance/tests).

### Option B — PostgreSQL en **Docker**
1) Démarrer Postgres en conteneur :
```bash
docker compose -f tooling/docker/docker-compose.yml up -d
```
2) À la **racine du projet**, lancer le même script :
```bash
./tooling/run_from_zero.sh
```
> Si ton PostgreSQL local occupe déjà `5432`, change le port mappé dans `docker-compose.yml` (ex. `5433:5432`) et mets `PGPORT=5433` dans `.env`.


### Option C — PostgreSQL avec **Makefile**
À la **racine du projet** :
```bash
make
```

---

## 🔧 Variables d’environnement (facultatif mais recommandé)
 **`.env`** :

```
PGHOST=localhost
PGPORT=5432
PGDATABASE=northwind_fr_sae
PGUSER=postgres
PGPASSWORD=MDP
```
`run_from_zero.sh` lira ces valeurs automatiquement.

---

## 📂 Arborescence du projet
```
.
├─ README.md
├─ .env.example                # modèle des variables PG (copier → .env)
├─ .gitignore
│
├─ bi/                         # visualisation de données
│
├─ data/                       # données alimentant la bdd
│                       
├─ docs/
│  ├─ cahier_charges/          # exemples + ton cahier des charges
│  ├─ TP_Conception.pdf        # document de conception (si fourni)
│  └─ dictionnaire_donnees.md  # définitions champs/mesures (CA, délais…)
│
├─ models_merise/              # images MCD / modèles Merise
│
├─ sql/
│  ├─ bootstrap/
│  │  ├─ 00_from_zero.psql     # all-in-one psql : BDD → schémas → OLTP → DWH → vues → tests
│  │  └─ 01_init_schemas.sql   # crée schémas `operationnel` & `dwh` + extensions + search_path
│  │
│  ├─ source_oltp/             # couche opérationnelle (schéma `operationnel`)
│  │  ├─ 01_create_tables.sql  # tables `_client`, `_commande`, `_detailcommande`, ...
│  │  └─ 02_create_views.sql   # vues opérationnelles
│  │
│  ├─ dwh/                     # couche data warehouse (schéma `dwh`)
│  │  ├─ 01_creation_dwh.sql   # dimensions `dim_*`, faits `fact_*`, index
│  │  ├─ 02_chargement_dwh.sql # ELT: remplit `dim_*` & `fact_*` depuis `operationnel`
│  │  └─ 03_vues_dwh.sql       # vues F1..F8 & L1..L5
│  │
│  └─ maintenance/
│     ├─ 10_indexes.sql        # index + VACUUM/ANALYZE
│     └─ 20_refresh_mv.sql     # (à compléter) REFRESH MV si besoin
│
├─ tests/
│  ├─ dq/
│  │  ├─ t01_fk_non_null.sql       # fact_ventes : FKs non nulles
│  │  ├─ t02_no_dup_keys.sql       # fact_livraisons : unicité nocom (grain)
│  │  └─ t03_metrics_consistency.sql # cohérence montants (ventes)
│  └─ perf/
│     └─ explain_samples.sql       # EXPLAIN ANALYZE d’une requête type
│
└─ tooling/
   ├─ run_from_zero.sh         # lance 00_from_zero.psql (local ou docker, selon .env)
   ├─ Makefile                 # cible `projet` = run_from_zero.sh (+ autres cibles utiles)
   └─ docker/
      └─ docker-compose.yml    # service Postgres (ports/variables/volume init)
```

---

## 🧰 `tooling/` — ce qu’il y a et à quoi ça sert
- **`run_from_zero.sh`** : script **principal**. Appelle `psql` pour exécuter `sql/bootstrap/00_from_zero.psql`.  
  → Crée la BDD, les schémas, l’opérationnel, le DWH, les vues, puis lance maintenance & tests.
- **`Makefile`** : raccourcis utiles. Ex. `make -C tooling projet` pour lancer `run_from_zero.sh` ; autres cibles : `init`, `load`, `views`, `maintenance`, `test`.
- **`docker/docker-compose.yml`** : démarre un **PostgreSQL en conteneur** (exposé sur 5432).

---

## 🧪 Interprétation rapide des tests DQ
- `t01_fk_non_null.sql` → **0** attendu (sinon, faits orphelins)  
- `t02_no_dup_keys.sql` → **0** attendu (sinon, grain non respecté)  
- `t03_metrics_consistency.sql` → **0** attendu (sinon, calculs incohérents)

---

## 🆘 Dépannage rapide
- `psql: command not found` → installe PostgreSQL/psql ou exécute via Docker.
- `could not connect` → vérifie `PGHOST/PGPORT` et que Postgres est **up**.
- Conflit de port `5432` → mappe `5433:5432` dans docker-compose + `PGPORT=5433` dans `.env`.
- 2ᵉ exécution “from zero” → l’étape `CREATE DATABASE` peut échouer (base existante) :  
  ignorer, ou `dropdb northwind_fr_sae`, ou en Docker `docker compose down -v` puis `up -d`.
