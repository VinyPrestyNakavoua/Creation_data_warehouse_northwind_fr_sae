-- ==============================================
-- vues_dwh.sql
-- Vues de restitution (F1..F8 & L1..L5) au-dessus des tables du DWH
-- NB: adapter les alias/colonnes si besoin selon vos consignes
-- ==============================================

SET search_path TO dw, public;

-- F1 : Top remises par produit
CREATE OR REPLACE VIEW dw.v_f1_top_remises_produits AS
SELECT
  p.nomprod,
  c.nomcateg,
  ROUND(AVG(f.ligne_remise)*100,2) AS remise_moy_pct,
  SUM(f.montant_remise)            AS montant_remise_total,
  SUM(f.montant_net)               AS ca_net
FROM dw.fact_ventes f
JOIN dw.dim_produit p   ON p.produit_key = f.produit_key
JOIN dw.dim_categorie c ON c.categorie_key = f.categorie_key
GROUP BY p.nomprod, c.nomcateg
ORDER BY remise_moy_pct DESC NULLS LAST;

-- F2 : CA par produit
CREATE OR REPLACE VIEW dw.v_f2_ca_par_produit AS
SELECT
  c.nomcateg,
  p.nomprod,
  SUM(f.montant_net) AS chiffre_affaires
FROM dw.fact_ventes f
JOIN dw.dim_produit p   ON p.produit_key = f.produit_key
JOIN dw.dim_categorie c ON c.categorie_key = f.categorie_key
GROUP BY c.nomcateg, p.nomprod
ORDER BY c.nomcateg, chiffre_affaires DESC;

-- F3 : CA par pays de livraison
CREATE OR REPLACE VIEW dw.v_f3_ca_par_pays AS
SELECT
  g.pays,
  SUM(f.montant_net) AS chiffre_affaires
FROM dw.fact_ventes f
JOIN dw.dim_geo_livraison g ON g.geo_key = f.geo_key
GROUP BY g.pays
ORDER BY chiffre_affaires DESC;

-- F4 : CA mensuel (toutes ventes)
CREATE OR REPLACE VIEW dw.v_f4_ca_mensuel AS
SELECT
  d.year,
  d.month,
  SUM(f.montant_net) AS ca_net
FROM dw.fact_ventes f
JOIN dw.dim_date d ON d.date_key = f.datecom_key
GROUP BY d.year, d.month
ORDER BY d.year, d.month;

-- F5 : CA par employé
CREATE OR REPLACE VIEW dw.v_f5_ca_par_employe AS
SELECT
  e.noemp,
  e.prenom || ' ' || e.nom AS employe,
  SUM(f.montant_net) AS ca_net
FROM dw.fact_ventes f
JOIN dw.dim_employe e ON e.employe_key = f.employe_key
GROUP BY e.noemp, employe
ORDER BY ca_net DESC;

-- F6 : CA par client
CREATE OR REPLACE VIEW dw.v_f6_ca_par_client AS
SELECT
  c.codecli,
  c.societe,
  SUM(f.montant_net) AS ca_net
FROM dw.fact_ventes f
JOIN dw.dim_client c ON c.client_key = f.client_key
GROUP BY c.codecli, c.societe
ORDER BY ca_net DESC;

-- F7 : CA par transporteur
CREATE OR REPLACE VIEW dw.v_f7_ca_par_transporteur AS
SELECT
  t.nomtran,
  SUM(f.montant_net) AS ca_net
FROM dw.fact_ventes f
JOIN dw.dim_transporteur t ON t.transporteur_key = f.transporteur_key
GROUP BY t.nomtran
ORDER BY ca_net DESC;

-- F8 : CA par fournisseur
CREATE OR REPLACE VIEW dw.v_f8_ca_par_fournisseur AS
SELECT
  fou.societe AS fournisseur,
  SUM(f.montant_net) AS ca_net
FROM dw.fact_ventes f
JOIN dw.dim_fournisseur fou ON fou.fournisseur_key = f.fournisseur_key
GROUP BY fournisseur
ORDER BY ca_net DESC;

-- L1 : plus grands écarts (objectif vs envoi) (en jours)
CREATE OR REPLACE VIEW dw.v_l1_ecarts_livraison AS
SELECT
  nocom,
  ecart_obj_liv_jours
FROM dw.fact_livraisons
ORDER BY ecart_obj_liv_jours DESC NULLS LAST;

-- L2 : délai d'expédition moyen par transporteur
CREATE OR REPLACE VIEW dw.v_l2_delai_moy_par_transporteur AS
SELECT
  t.nomtran,
  ROUND(AVG(fl.delai_expedition_jours)::numeric,2) AS delai_moyen_jours
FROM dw.fact_livraisons fl
JOIN dw.dim_transporteur t ON t.transporteur_key = fl.transporteur_key
GROUP BY t.nomtran
ORDER BY delai_moyen_jours;

-- L3 : volumétrie expédiée par mois
CREATE OR REPLACE VIEW dw.v_l3_qte_par_mois AS
SELECT
  d.year,
  d.month,
  SUM(fl.qte_totale) AS qte_total
FROM dw.fact_livraisons fl
JOIN dw.dim_date d ON d.date_key = fl.dateenv_key
GROUP BY d.year, d.month
ORDER BY d.year, d.month;

-- L4 : frais de port par pays
CREATE OR REPLACE VIEW dw.v_l4_port_par_pays AS
SELECT
  g.pays,
  SUM(fl.frais_port) AS frais_total
FROM dw.fact_livraisons fl
JOIN dw.dim_geo_livraison g ON g.geo_key = fl.geo_key
GROUP BY g.pays
ORDER BY frais_total DESC;

-- L5 : top commandes en quantité
CREATE OR REPLACE VIEW dw.v_l5_top_commandes_qte AS
SELECT
  fl.nocom,
  fl.qte_totale
FROM dw.fact_livraisons fl
ORDER BY fl.qte_totale DESC NULLS LAST;

-- (Optionnel) Vues matérialisées pour accélérer : décommentez si besoin
-- CREATE MATERIALIZED VIEW dw.mv_f3_ca_par_pays AS SELECT * FROM dw.v_f3_ca_par_pays;
-- REFRESH MATERIALIZED VIEW dw.mv_f3_ca_par_pays;
