-- Forcer le schéma opérationnel
CREATE SCHEMA IF NOT EXISTS operationnel;
SET search_path TO operationnel, public;

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

-- Extension plpgsql
CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
COMMENT ON EXTENSION plpgsql IS 'langage procédural PL/pgSQL';

SET default_tablespace = '';
SET default_with_oids = false;

-- Table : _categorie
CREATE TABLE IF NOT EXISTS operationnel._categorie (
    codecateg smallint,
    nomcateg varchar(255) DEFAULT NULL,
    description varchar(255) DEFAULT NULL
);
ALTER TABLE operationnel._categorie OWNER TO postgres;

-- Table : _client
CREATE TABLE IF NOT EXISTS operationnel._client (
    codecli varchar(255) DEFAULT NULL,
    societe varchar(255) DEFAULT NULL,
    contact varchar(255) DEFAULT NULL,
    fonction varchar(255) DEFAULT NULL,
    adresse varchar(255) DEFAULT NULL,
    ville varchar(255) DEFAULT NULL,
    region varchar(255) DEFAULT NULL,
    codepostal varchar(255) DEFAULT NULL,
    pays varchar(255) DEFAULT NULL,
    tel varchar(255) DEFAULT NULL,
    fax varchar(255) DEFAULT NULL
);
ALTER TABLE operationnel._client OWNER TO postgres;

-- Table : _commande
CREATE TABLE IF NOT EXISTS operationnel._commande (
    nocom integer,
    codecli varchar(255) DEFAULT NULL,
    noemp smallint,
    datecom varchar(255) DEFAULT NULL,
    dateobjliv varchar(255) DEFAULT NULL,
    dateenv varchar(255) DEFAULT NULL,
    notran smallint,
    port smallint,
    destinataire varchar(255) DEFAULT NULL,
    adrliv varchar(255) DEFAULT NULL,
    villeliv varchar(255) DEFAULT NULL,
    regionliv varchar(255) DEFAULT NULL,
    codepostalliv varchar(255) DEFAULT NULL,
    paysliv varchar(255) DEFAULT NULL
);
ALTER TABLE operationnel._commande OWNER TO postgres;

-- Table : _detailcommande
CREATE TABLE IF NOT EXISTS operationnel._detailcommande (
    nocom integer,
    refprod smallint,
    prixunit smallint,
    qte smallint,
    remise numeric(3,2) DEFAULT NULL
);
ALTER TABLE operationnel._detailcommande OWNER TO postgres;

-- Table : _employe
CREATE TABLE IF NOT EXISTS operationnel._employe (
    noemp smallint,
    nom varchar(255) DEFAULT NULL,
    prenom varchar(255) DEFAULT NULL,
    fonction varchar(255) DEFAULT NULL,
    titrecourtoisie varchar(255) DEFAULT NULL,
    datenaissance varchar(255) DEFAULT NULL,
    dateembauche varchar(255) DEFAULT NULL,
    adresse varchar(255) DEFAULT NULL,
    ville varchar(255) DEFAULT NULL,
    region varchar(255) DEFAULT NULL,
    codepostal varchar(255) DEFAULT NULL,
    pays varchar(255) DEFAULT NULL,
    teldom varchar(255) DEFAULT NULL,
    extension smallint,
    rendcomptea varchar(255) DEFAULT NULL
);
ALTER TABLE operationnel._employe OWNER TO postgres;

-- Table : _fournisseur
CREATE TABLE IF NOT EXISTS operationnel._fournisseur (
    nofourn smallint,
    societe varchar(255) DEFAULT NULL,
    contact varchar(255) DEFAULT NULL,
    fonction varchar(255) DEFAULT NULL,
    adresse varchar(255) DEFAULT NULL,
    ville varchar(255) DEFAULT NULL,
    region varchar(255) DEFAULT NULL,
    codepostal varchar(255) DEFAULT NULL,
    pays varchar(255) DEFAULT NULL,
    tel varchar(255) DEFAULT NULL,
    fax varchar(255) DEFAULT NULL,
    pageaccueil varchar(255) DEFAULT NULL
);
ALTER TABLE operationnel._fournisseur OWNER TO postgres;

-- Table : _transporteur
CREATE TABLE IF NOT EXISTS operationnel._transporteur (
    notran smallint,
    nomtran varchar(255) DEFAULT NULL,
    tel varchar(255) DEFAULT NULL
);
ALTER TABLE operationnel._transporteur OWNER TO postgres;

-- Table : _produit
CREATE TABLE IF NOT EXISTS operationnel._produit (
    refprod smallint,
    nomprod varchar(255) DEFAULT NULL,
    nofourn smallint,
    codecateg smallint,
    qteparunit varchar(255) DEFAULT NULL,
    prixunit numeric(6,2) DEFAULT NULL,
    unitstock smallint,
    unitescom smallint,
    niveaureap smallint,
    indisponible smallint
);
ALTER TABLE operationnel._produit OWNER TO postgres;
