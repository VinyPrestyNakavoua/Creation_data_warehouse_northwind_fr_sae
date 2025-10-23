-- 01_init_schemas.sql
-- A exécuter DANS la base 'northwind_fr_sae' pour créer les schémas & extensions

CREATE SCHEMA IF NOT EXISTS operationnel;
CREATE SCHEMA IF NOT EXISTS dwh;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Search path pratique
SET search_path TO operationnel, dwh, public;
