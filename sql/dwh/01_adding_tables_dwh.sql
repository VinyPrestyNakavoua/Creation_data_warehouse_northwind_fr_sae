-- ==============================================
-- 01_creation_dwh.sql — Schéma & tables DWH
-- ==============================================

CREATE SCHEMA IF NOT EXISTS dwh;

-- ---------- Dimensions ----------
CREATE TABLE IF NOT EXISTS dwh.dim_date (
  date_key      int PRIMARY KEY,            -- yyyymmdd
  full_date     date NOT NULL,
  year          int  NOT NULL,
  quarter       int  NOT NULL,
  month         int  NOT NULL,
  month_name    text NOT NULL,
  week          int  NOT NULL,
  day           int  NOT NULL,
  is_weekend    boolean NOT NULL
);

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

CREATE TABLE IF NOT EXISTS dwh.dim_fournisseur (
  fournisseur_key int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nofourn         int UNIQUE,
  societe         text,
  pays            text,
  ville           text,
  region          text
);

CREATE TABLE IF NOT EXISTS dwh.dim_categorie (
  categorie_key int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  codecateg     int UNIQUE,
  nomcateg      text
);

CREATE TABLE IF NOT EXISTS dwh.dim_transporteur (
  transporteur_key int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  notran           int UNIQUE,
  nomtran          text
);

CREATE TABLE IF NOT EXISTS dwh.dim_geo_livraison (
  geo_key      int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  pays         text,
  region       text,
  ville        text
);

CREATE TABLE IF NOT EXISTS dwh.dim_produit (
  produit_key     int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  refprod         int UNIQUE,
  nomprod         text,
  prix_catalogue  numeric(12,2),
  categorie_key   int REFERENCES dwh.dim_categorie(categorie_key),
  fournisseur_key int REFERENCES dwh.dim_fournisseur(fournisseur_key)
);

-- ---------- Fait VENTES (grain = ligne de commande) ----------
CREATE TABLE IF NOT EXISTS dwh.fact_ventes (
  fact_ventes_id   bigserial PRIMARY KEY,
  -- clé dégénérée (utile en analyse)
  nocom            text NOT NULL,

  -- FKs (NOT NULL) : la date de commande et les dimensions
  datecom_key      int NOT NULL REFERENCES dwh.dim_date(date_key),
  client_key       int NOT NULL REFERENCES dwh.dim_client(client_key),
  employe_key      int NOT NULL REFERENCES dwh.dim_employe(employe_key),
  produit_key      int NOT NULL REFERENCES dwh.dim_produit(produit_key),
  transporteur_key int REFERENCES dwh.dim_transporteur(transporteur_key),
  geo_key          int REFERENCES dwh.dim_geo_livraison(geo_key),

  -- Mesures au niveau ligne
  refprod          int NOT NULL,
  ligne_qte        int,
  ligne_prix_unit  numeric(12,2),
  ligne_remise     numeric(5,4),
  montant_brut     numeric(14,2),
  montant_remise   numeric(14,2),
  montant_net      numeric(14,2),
  port_reparti     numeric(14,2),

  -- Unicité logique de la ligne (si pas de N° de ligne, (nocom, refprod) suffit)
  UNIQUE (nocom, refprod)
);

CREATE INDEX IF NOT EXISTS ix_fact_ventes_dimkeys
  ON dwh.fact_ventes (datecom_key, client_key, employe_key, produit_key, transporteur_key, geo_key);

-- ---------- Fait LIVRAISONS (grain = ligne expédiée) ----------
CREATE TABLE IF NOT EXISTS dwh.fact_livraisons (
  fact_livraisons_id bigserial PRIMARY KEY,

  -- clé dégénérée
  nocom              text NOT NULL,

  -- FKs (rôles de dates) : objectif vs envoi réel
  dateobjliv_key     int NOT NULL REFERENCES dwh.dim_date(date_key),
  dateenv_key        int NOT NULL REFERENCES dwh.dim_date(date_key),

  produit_key        int NOT NULL REFERENCES dwh.dim_produit(produit_key),
  transporteur_key   int REFERENCES dwh.dim_transporteur(transporteur_key),
  geo_key            int REFERENCES dwh.dim_geo_livraison(geo_key),
  employe_key        int REFERENCES dwh.dim_employe(employe_key),
  client_key         int REFERENCES dwh.dim_client(client_key),

  -- Mesures niveau ligne expédition
  refprod            int NOT NULL,
  qte                int,
  frais_port_ligne   numeric(12,2),     -- si tu répartis le port au niveau ligne
  delai_expedition_jours int,           -- (dateenv - datecom) si utile
  ecart_obj_liv_jours   int,            -- (dateenv - dateobjliv)

  -- Unicité logique au niveau ligne expédiée
  UNIQUE (nocom, refprod)
);

CREATE INDEX IF NOT EXISTS ix_fact_livraisons_dimkeys
  ON dwh.fact_livraisons (dateobjliv_key, dateenv_key, transporteur_key, geo_key, employe_key, client_key, produit_key);
