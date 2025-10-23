-- ==============================================
-- 01_creation_dwh.sql
-- Schéma & tables du Data Warehouse (PostgreSQL) — schema dwh
-- ==============================================

CREATE SCHEMA IF NOT EXISTS dwh;

-- dim_date
CREATE TABLE IF NOT EXISTS dwh.dim_date (
  date_key      int PRIMARY KEY,
  full_date     date NOT NULL,
  year          int  NOT NULL,
  quarter       int  NOT NULL,
  month         int  NOT NULL,
  month_name    text NOT NULL,
  week          int  NOT NULL,
  day           int  NOT NULL,
  is_weekend    boolean NOT NULL
);

-- dim_client
CREATE TABLE IF NOT EXISTS dwh.dim_client (
  client_key    int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  codecli       text UNIQUE,
  societe       text,
  contact       text,
  pays          text,
  ville         text,
  region        text,
  codepostal    text
);

-- dim_employe
CREATE TABLE IF NOT EXISTS dwh.dim_employe (
  employe_key   int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  noemp         int UNIQUE,
  nom           text,
  prenom        text,
  fonction      text,
  pays          text,
  ville         text,
  region        text
);

-- dim_fournisseur
CREATE TABLE IF NOT EXISTS dwh.dim_fournisseur (
  fournisseur_key int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nofourn         int UNIQUE,
  societe         text,
  pays            text,
  ville           text,
  region          text
);

-- dim_categorie
CREATE TABLE IF NOT EXISTS dwh.dim_categorie (
  categorie_key int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  codecateg     int UNIQUE,
  nomcateg      text
);

-- dim_transporteur
CREATE TABLE IF NOT EXISTS dwh.dim_transporteur (
  transporteur_key int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  notran           int UNIQUE,
  nomtran          text
);

-- dim_geo_livraison
CREATE TABLE IF NOT EXISTS dwh.dim_geo_livraison (
  geo_key      int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  pays         text,
  region       text,
  ville        text
);

-- dim_produit
CREATE TABLE IF NOT EXISTS dwh.dim_produit (
  produit_key     int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  refprod         int UNIQUE,
  nomprod         text,
  prix_catalogue  numeric(12,2),
  categorie_key   int REFERENCES dwh.dim_categorie(categorie_key),
  fournisseur_key int REFERENCES dwh.dim_fournisseur(fournisseur_key)
);

-- fact_ventes (grain = ligne de commande)
CREATE TABLE IF NOT EXISTS dwh.fact_ventes (
  fact_ventes_id   bigserial PRIMARY KEY,
  nocom            int NOT NULL,
  refprod          int NOT NULL,
  ligne_qte        int,
  ligne_prix_unit  numeric(12,2),
  ligne_remise     numeric(5,4),
  montant_brut     numeric(14,2),
  montant_remise   numeric(14,2),
  montant_net      numeric(14,2),
  datecom_key      int REFERENCES dwh.dim_date(date_key),
  client_key       int REFERENCES dwh.dim_client(client_key),
  employe_key      int REFERENCES dwh.dim_employe(employe_key),
  produit_key      int REFERENCES dwh.dim_produit(produit_key),
  categorie_key    int REFERENCES dwh.dim_categorie(categorie_key),
  fournisseur_key  int REFERENCES dwh.dim_fournisseur(fournisseur_key),
  transporteur_key int REFERENCES dwh.dim_transporteur(transporteur_key),
  geo_key          int REFERENCES dwh.dim_geo_livraison(geo_key)
);

-- fact_livraisons (grain = commande expédiée)
CREATE TABLE IF NOT EXISTS dwh.fact_livraisons (
  fact_livraisons_id bigserial PRIMARY KEY,
  nocom              int UNIQUE,
  frais_port         numeric(12,2),
  qte_totale         int,
  delai_expedition_jours int,
  ecart_obj_liv_jours   int,
  datecom_key        int REFERENCES dwh.dim_date(date_key),
  dateenv_key        int REFERENCES dwh.dim_date(date_key),
  dateobjliv_key     int REFERENCES dwh.dim_date(date_key),
  transporteur_key   int REFERENCES dwh.dim_transporteur(transporteur_key),
  geo_key            int REFERENCES dwh.dim_geo_livraison(geo_key),
  employe_key        int REFERENCES dwh.dim_employe(employe_key),
  client_key         int REFERENCES dwh.dim_client(client_key)
);

CREATE INDEX IF NOT EXISTS ix_fact_ventes_keys
  ON dwh.fact_ventes (datecom_key, client_key, employe_key, produit_key, categorie_key, fournisseur_key, transporteur_key, geo_key);

CREATE INDEX IF NOT EXISTS ix_fact_livraisons_keys
  ON dwh.fact_livraisons (datecom_key, dateenv_key, dateobjliv_key, transporteur_key, geo_key, employe_key, client_key);
