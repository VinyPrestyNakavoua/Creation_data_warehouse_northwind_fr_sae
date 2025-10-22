-- ==============================================
-- chargement_dwh.sql
-- Chargement initial des dimensions et faits (ELT)
-- Hypothèse: les tables source sont dans le schéma public avec les noms _client, _commande, _detailcommande, etc.
-- ==============================================

SET search_path TO public, dw;

-- 1) DIMENSIONS

-- dim_date : couvre l'intervalle des dates présentes dans _commande
WITH limites AS (
  SELECT
    min(NULLIF(datecom,'')::date) AS dmin,
    GREATEST(
      max(NULLIF(datecom,'')::date),
      max(NULLIF(dateenv,'')::date),
      max(NULLIF(dateobjliv,'')::date)
    ) AS dmax
  FROM public._commande
), dates AS (
  SELECT generate_series(dmin, dmax, interval '1 day')::date AS d FROM limites
)
INSERT INTO dw.dim_date (date_key, full_date, year, quarter, month, month_name, week, day, is_weekend)
SELECT
  EXTRACT(YEAR FROM d)::int*10000 + EXTRACT(MONTH FROM d)::int*100 + EXTRACT(DAY FROM d)::int AS date_key,
  d,
  EXTRACT(YEAR FROM d)::int,
  EXTRACT(QUARTER FROM d)::int,
  EXTRACT(MONTH FROM d)::int,
  TO_CHAR(d,'TMMonth'),
  EXTRACT(WEEK FROM d)::int,
  EXTRACT(DAY FROM d)::int,
  EXTRACT(ISODOW FROM d) IN (6,7)
FROM dates
ON CONFLICT (date_key) DO NOTHING;

-- dim_client
INSERT INTO dw.dim_client (codecli, societe, contact, pays, ville, region, codepostal)
SELECT DISTINCT codecli, societe, contact, pays, ville, region, codepostal
FROM public._client
WHERE codecli IS NOT NULL
ON CONFLICT (codecli) DO NOTHING;

-- dim_employe
INSERT INTO dw.dim_employe (noemp, nom, prenom, fonction, pays, ville, region)
SELECT DISTINCT noemp, nom, prenom, fonction, pays, ville, region
FROM public._employe
WHERE noemp IS NOT NULL
ON CONFLICT (noemp) DO NOTHING;

-- dim_fournisseur
INSERT INTO dw.dim_fournisseur (nofourn, societe, pays, ville, region)
SELECT DISTINCT nofourn, societe, pays, ville, region
FROM public._fournisseur
WHERE nofourn IS NOT NULL
ON CONFLICT (nofourn) DO NOTHING;

-- dim_categorie
INSERT INTO dw.dim_categorie (codecateg, nomcateg)
SELECT DISTINCT codecateg, nomcateg
FROM public._categorie
WHERE codecateg IS NOT NULL
ON CONFLICT (codecateg) DO NOTHING;

-- dim_transporteur
INSERT INTO dw.dim_transporteur (notran, nomtran)
SELECT DISTINCT notran, nomtran
FROM public._transporteur
WHERE notran IS NOT NULL
ON CONFLICT (notran) DO NOTHING;

-- dim_geo_livraison
INSERT INTO dw.dim_geo_livraison (pays, region, ville)
SELECT DISTINCT COALESCE(paysliv,'(NON RENSEIGNE)'), COALESCE(regionliv,'(NON RENSEIGNE)'), COALESCE(villeliv,'(NON RENSEIGNE)')
FROM public._commande;

-- dim_produit
INSERT INTO dw.dim_produit (refprod, nomprod, prix_catalogue, categorie_key, fournisseur_key)
SELECT
  p.refprod, p.nomprod, p.prixunit,
  dc.categorie_key, df.fournisseur_key
FROM public._produit p
LEFT JOIN dw.dim_categorie dc ON dc.codecateg = p.codecateg
LEFT JOIN dw.dim_fournisseur df ON df.nofourn = p.nofourn
ON CONFLICT (refprod) DO NOTHING;

-- 2) FAITS

-- fact_ventes
INSERT INTO dw.fact_ventes (
  nocom, refprod, ligne_qte, ligne_prix_unit, ligne_remise,
  montant_brut, montant_remise, montant_net,
  datecom_key, client_key, employe_key, produit_key, categorie_key, fournisseur_key, transporteur_key, geo_key
)
SELECT
  dc.nocom,
  dc.refprod,
  dc.qte,
  dc.prixunit::numeric(12,2),
  COALESCE(dc.remise,0)::numeric(5,4),
  (dc.qte * dc.prixunit)::numeric(14,2)                            AS montant_brut,
  (dc.qte * dc.prixunit * COALESCE(dc.remise,0))::numeric(14,2)    AS montant_remise,
  (dc.qte * dc.prixunit * (1-COALESCE(dc.remise,0)))::numeric(14,2) AS montant_net,
  dd.date_key,
  dcli.client_key,
  demp.employe_key,
  dprod.produit_key,
  dcat.categorie_key,
  dfou.fournisseur_key,
  dtra.transporteur_key,
  dgeo.geo_key
FROM public._detailcommande dc
JOIN public._commande co           ON co.nocom = dc.nocom
LEFT JOIN dw.dim_client dcli       ON dcli.codecli = co.codecli
LEFT JOIN dw.dim_employe demp      ON demp.noemp = co.noemp
LEFT JOIN dw.dim_transporteur dtra ON dtra.notran = co.notran
LEFT JOIN dw.dim_geo_livraison dgeo ON dgeo.pays = COALESCE(co.paysliv,'(NON RENSEIGNE)')
                                   AND dgeo.region = COALESCE(co.regionliv,'(NON RENSEIGNE)')
                                   AND dgeo.ville  = COALESCE(co.villeliv,'(NON RENSEIGNE)')
LEFT JOIN dw.dim_produit dprod      ON dprod.refprod = dc.refprod
LEFT JOIN dw.dim_categorie dcat     ON dcat.categorie_key = dprod.categorie_key
LEFT JOIN dw.dim_fournisseur dfou   ON dfou.fournisseur_key = dprod.fournisseur_key
LEFT JOIN dw.dim_date dd            ON dd.full_date = NULLIF(co.datecom,'')::date;

-- fact_livraisons
INSERT INTO dw.fact_livraisons (
  nocom, frais_port, qte_totale, delai_expedition_jours, ecart_obj_liv_jours,
  datecom_key, dateenv_key, dateobjliv_key, transporteur_key, geo_key, employe_key, client_key
)
SELECT
  co.nocom,
  COALESCE(co.port,0)::numeric(12,2) AS frais_port,
  SUM(dc.qte)::int                   AS qte_totale,
  CASE WHEN co.dateenv IS NOT NULL AND co.datecom IS NOT NULL AND trim(co.dateenv)<>'' AND trim(co.datecom)<>'' 
       THEN (co.dateenv::date - co.datecom::date) ELSE NULL END AS delai_expedition_jours,
  CASE WHEN co.dateenv IS NOT NULL AND co.dateobjliv IS NOT NULL AND trim(co.dateenv)<>'' AND trim(co.dateobjliv)<>'' 
       THEN (co.dateenv::date - co.dateobjliv::date) ELSE NULL END AS ecart_obj_liv_jours,
  dd_com.date_key,
  dd_env.date_key,
  dd_obj.date_key,
  dtra.transporteur_key,
  dgeo.geo_key,
  demp.employe_key,
  dcli.client_key
FROM public._commande co
LEFT JOIN public._detailcommande dc ON dc.nocom = co.nocom
LEFT JOIN dw.dim_client dcli        ON dcli.codecli = co.codecli
LEFT JOIN dw.dim_employe demp       ON demp.noemp = co.noemp
LEFT JOIN dw.dim_transporteur dtra  ON dtra.notran = co.notran
LEFT JOIN dw.dim_geo_livraison dgeo ON dgeo.pays = COALESCE(co.paysliv,'(NON RENSEIGNE)')
                                   AND dgeo.region = COALESCE(co.regionliv,'(NON RENSEIGNE)')
                                   AND dgeo.ville  = COALESCE(co.villeliv,'(NON RENSEIGNE)')
LEFT JOIN dw.dim_date dd_com ON dd_com.full_date = NULLIF(co.datecom,'')::date
LEFT JOIN dw.dim_date dd_env ON dd_env.full_date = NULLIF(co.dateenv,'')::date
LEFT JOIN dw.dim_date dd_obj ON dd_obj.full_date = NULLIF(co.dateobjliv,'')::date
GROUP BY co.nocom, co.port, co.datecom, co.dateenv, co.dateobjliv,
         dd_com.date_key, dd_env.date_key, dd_obj.date_key,
         dtra.transporteur_key, dgeo.geo_key, demp.employe_key, dcli.client_key;
